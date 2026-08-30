type Coordinates = { latitude: number; longitude: number }
type GooglePlace = Coordinates & {
  id: string
  name: string
  category: string
  description: string
}

const corsHeaders = {
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
  'Access-Control-Allow-Methods': 'POST, OPTIONS',
}

const googleRoutesUrl = 'https://routes.googleapis.com/directions/v2:computeRoutes'
const googlePlacesUrl = 'https://places.googleapis.com/v1/places:searchText'
const googleNearbyPlacesUrl = 'https://places.googleapis.com/v1/places:searchNearby'
// Google returns a more detailed vehicle value than the modes accepted by
// TransitPreferences. In Malaysia, MRT/LRT and KTM services are commonly
// labelled METRO_RAIL, COMMUTER_TRAIN, or HEAVY_RAIL. Treat every rail-based
// vehicle as eligible, while continuing to reject BUS, taxi, and car legs.
const railModes = new Set([
  'SUBWAY',
  'TRAIN',
  'LIGHT_RAIL',
  'RAIL',
  'MONORAIL',
  'METRO_RAIL',
  'COMMUTER_TRAIN',
  'HEAVY_RAIL',
  'LONG_DISTANCE_TRAIN',
  'HIGH_SPEED_TRAIN',
  'TRAM',
])
const maximumWalkingOnlyDistanceMeters = 8000
// Some Klang residential areas are just beyond the closest KTM station's
// walkable catchment. Six kilometres still avoids an impractical full walk
// while allowing a rail connection where Google has no local feeder rail.
const maximumStationAccessWalkingMeters = 6000

Deno.serve(async (request) => {
  if (request.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders })
  }

  if (request.method !== 'POST') {
    return response({ error: 'Only POST is supported.' }, 405)
  }

  const apiKey = Deno.env.get('GOOGLE_MAPS_SERVER_KEY')
  if (!apiKey) {
    return response({ error: 'Google Maps service is not configured.' }, 503)
  }

  try {
    const body = await request.json()
    const action = body.action as string | undefined
    const origin = parseCoordinates(body.origin)

    if (action === 'nearby') {
      const category = typeof body.category === 'string' ? body.category : 'all'
      const radiusKm = parseNearbyRadiusKm(body.radiusKm)
      const minimumRadiusKm = minimumNearbyRadiusKm(radiusKm)
      const places = await searchPlacesForCategory(origin, apiKey, radiusKm, category)
      const placesInBand = filterPlacesByDistance(
        origin,
        places,
        minimumRadiusKm,
        radiusKm,
      )
      if (placesInBand.length > 0 || minimumRadiusKm == 0) {
        return response({ places: placesInBand })
      }

      // Nearby Search supplies at most 20 closest places. When a dense city
      // fills that limit inside the previous band, search around the outer
      // ring so the 1–2 km and 2–5 km choices remain useful.
      const outerRingPlaces = await searchOuterBandPlaces(
        origin,
        apiKey,
        category,
        minimumRadiusKm,
        radiusKm,
      )
      return response({
        places: filterPlacesByDistance(
          origin,
          deduplicatePlaces([...places, ...outerRingPlaces]),
          minimumRadiusKm,
          radiusKm,
        ),
      })
    }

    if (action === 'search') {
      const query = typeof body.query === 'string' ? body.query.trim() : ''
      if (query.length < 2 || query.length > 120) {
        return response({ error: 'Enter between 2 and 120 characters to search.' }, 400)
      }
      const directMatches = await searchPlaces(query, origin, apiKey)
      if (directMatches.length > 0 || includesKualaLumpurContext(query)) {
        return response({ places: directMatches })
      }
      return response({
        places: await searchPlaces(`${query}, Kuala Lumpur, Malaysia`, origin, apiKey),
      })
    }

    if (action === 'route') {
      const destination = parseCoordinates(body.destination)
      const route = await buildRailAndWalkRoute(origin, destination, apiKey)
      return response(route)
    }

    return response({ error: 'Unsupported Eco-Route request.' }, 400)
  } catch (error) {
    console.error('eco-route failed', error)
    return response(
      { error: error instanceof Error ? error.message : 'Eco-Route request failed.' },
      400,
    )
  }
})

async function searchPlaces(
  query: string,
  origin: Coordinates,
  apiKey: string,
  nearbyRadiusKm?: number,
) {
  const radiusMeters = (nearbyRadiusKm ?? 10) * 1000
  const googleResponse = await fetch(googlePlacesUrl, {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
      'X-Goog-Api-Key': apiKey,
      'X-Goog-FieldMask': 'places.id,places.displayName,places.formattedAddress,places.location,places.primaryType,places.types',
    },
    body: JSON.stringify({
      textQuery: query,
      // Return as many nearby results as a single Places response supports.
      // The app still filters them strictly to the selected radius below.
      pageSize: 20,
      locationBias: {
        circle: {
          center: { latitude: origin.latitude, longitude: origin.longitude },
          radius: radiusMeters,
        },
      },
      languageCode: 'en',
      // Text Search uses this as a regional bias. Results are also filtered
      // against the Eco-Route service area before the app receives them.
      regionCode: 'MY',
    }),
  })

  const payload = await googleResponse.json()
  if (!googleResponse.ok) {
    throw new Error(payload.error?.message ?? 'Google Places search failed.')
  }

  return (payload.places ?? [])
    .filter((place: Record<string, unknown>) => place.location)
    .map((place: Record<string, unknown>) => mapGooglePlace(place))
    .filter((place: Coordinates) => isWithinWestMalaysia(place))
    .filter((place: Coordinates) =>
      nearbyRadiusKm == null || distanceBetweenKm(origin, place) <= nearbyRadiusKm,
    )
    .sort((first: Coordinates, second: Coordinates) =>
      distanceBetweenKm(origin, first) - distanceBetweenKm(origin, second),
    )
}

/// Returns a mixed, distance-ranked set of real nearby Google places. Omitting
/// type restrictions lets the Places API include food, parks, landmarks,
/// campuses, and other registered points of interest in one response.
async function searchAllNearbyPlaces(
  origin: Coordinates,
  apiKey: string,
  radiusKm: number,
) {
  const googleResponse = await fetch(googleNearbyPlacesUrl, {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
      'X-Goog-Api-Key': apiKey,
      'X-Goog-FieldMask': 'places.id,places.displayName,places.formattedAddress,places.location,places.primaryType,places.types',
    },
    body: JSON.stringify({
      maxResultCount: 20,
      rankPreference: 'DISTANCE',
      locationRestriction: {
        circle: {
          center: { latitude: origin.latitude, longitude: origin.longitude },
          radius: radiusKm * 1000,
        },
      },
      languageCode: 'en',
      regionCode: 'MY',
    }),
  })
  const payload = await googleResponse.json()
  if (!googleResponse.ok) {
    throw new Error(payload.error?.message ?? 'Google nearby places search failed.')
  }

  return (payload.places ?? [])
    .filter((place: Record<string, unknown>) => place.location)
    .map((place: Record<string, unknown>) => mapGooglePlace(place))
    .filter((place: Coordinates) => isWithinWestMalaysia(place))
    .filter((place: Coordinates) => distanceBetweenKm(origin, place) <= radiusKm)
    .sort((first: Coordinates, second: Coordinates) =>
      distanceBetweenKm(origin, first) - distanceBetweenKm(origin, second),
    )
}

/// Adds a small campus-focused set to the general recommendation list. Nearby
/// Search caps each response, so a dense area can otherwise be filled entirely
/// with unrelated points of interest before a campus cafeteria is considered.
async function searchRecommendedPlaces(
  origin: Coordinates,
  apiKey: string,
  radiusKm: number,
) {
  const [nearbyPlaces, campusPlaces] = await Promise.all([
    searchAllNearbyPlaces(origin, apiKey, radiusKm),
    searchNearbyPlacesByType(origin, apiKey, radiusKm, campusDiscoveryTypes),
  ])
  const uniquePlaces = new Map<string, GooglePlace>()
  for (const place of [...campusPlaces.slice(0, 5), ...nearbyPlaces]) {
    uniquePlaces.set(String(place.id), place)
  }
  return [...uniquePlaces.values()]
}

async function searchPlacesForCategory(
  origin: Coordinates,
  apiKey: string,
  radiusKm: number,
  category: string,
) {
  if (category === 'all') {
    return searchRecommendedPlaces(origin, apiKey, radiusKm)
  }
  const placeTypes = nearbyPlaceTypes(category)
  if (placeTypes != null) {
    return searchNearbyPlacesByType(origin, apiKey, radiusKm, placeTypes)
  }
  return searchPlaces(nearbyQuery(category), origin, apiKey, radiusKm)
}

async function searchOuterBandPlaces(
  origin: Coordinates,
  apiKey: string,
  category: string,
  minimumRadiusKm: number,
  maximumRadiusKm: number,
) {
  const ringRadiusKm = (minimumRadiusKm + maximumRadiusKm) / 2
  const searchRadiusKm = (maximumRadiusKm - minimumRadiusKm) / 2 + 0.35
  const ringCenters = [0, 90, 180, 270].map((bearingDegrees) =>
    pointAtDistance(origin, ringRadiusKm, bearingDegrees),
  )
  const groups = await Promise.all(
    ringCenters.map((center) =>
      searchPlacesForCategory(center, apiKey, searchRadiusKm, category),
    ),
  )
  return deduplicatePlaces(groups.flat())
}

function pointAtDistance(
  origin: Coordinates,
  distanceKm: number,
  bearingDegrees: number,
): Coordinates {
  const earthRadiusKm = 6371
  const angularDistance = distanceKm / earthRadiusKm
  const bearing = degreesToRadians(bearingDegrees)
  const latitude = degreesToRadians(origin.latitude)
  const longitude = degreesToRadians(origin.longitude)
  const destinationLatitude = Math.asin(
    Math.sin(latitude) * Math.cos(angularDistance) +
      Math.cos(latitude) * Math.sin(angularDistance) * Math.cos(bearing),
  )
  const destinationLongitude =
    longitude +
    Math.atan2(
      Math.sin(bearing) * Math.sin(angularDistance) * Math.cos(latitude),
      Math.cos(angularDistance) - Math.sin(latitude) * Math.sin(destinationLatitude),
    )
  return {
    latitude: (destinationLatitude * 180) / Math.PI,
    longitude: (destinationLongitude * 180) / Math.PI,
  }
}

/// Uses Google place-type filters where a single purpose-built category is
/// clearer than the mixed "All" list. This makes nearby malls and rail
/// stations discoverable even when general nearby results are dominated by
/// cafes or other dense local places.
async function searchNearbyPlacesByType(
  origin: Coordinates,
  apiKey: string,
  radiusKm: number,
  includedTypes: string[],
) {
  const googleResponse = await fetch(googleNearbyPlacesUrl, {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
      'X-Goog-Api-Key': apiKey,
      'X-Goog-FieldMask': 'places.id,places.displayName,places.formattedAddress,places.location,places.primaryType,places.types',
    },
    body: JSON.stringify({
      includedTypes,
      maxResultCount: 20,
      rankPreference: 'DISTANCE',
      locationRestriction: {
        circle: {
          center: { latitude: origin.latitude, longitude: origin.longitude },
          radius: radiusKm * 1000,
        },
      },
      languageCode: 'en',
      regionCode: 'MY',
    }),
  })
  const payload = await googleResponse.json()
  if (!googleResponse.ok) {
    throw new Error(payload.error?.message ?? 'Google nearby places search failed.')
  }

  return (payload.places ?? [])
    .filter((place: Record<string, unknown>) => place.location)
    .map((place: Record<string, unknown>) => mapGooglePlace(place))
    .filter((place: Coordinates) => isWithinWestMalaysia(place))
    .filter((place: Coordinates) => distanceBetweenKm(origin, place) <= radiusKm)
    .sort((first: Coordinates, second: Coordinates) =>
      distanceBetweenKm(origin, first) - distanceBetweenKm(origin, second),
    )
}

const railStationPlaceTypes = [
  'subway_station',
  'light_rail_station',
  'train_station',
]

const namedRailStationPattern = /\b(ktm|ktmb|komuter|mrt|lrt|monorail|rapid\s*rail)\b/i

/// Nearby Search can rank planned stations before operating ones. Combine it
/// with text searches for the named Malaysian rail networks and put those
/// confirmed rail results first, before falling back to generic station types.
async function searchRailStations(
  origin: Coordinates,
  apiKey: string,
) {
  const results = await Promise.allSettled([
    searchNearbyPlacesByType(origin, apiKey, 10, railStationPlaceTypes),
    searchPlaces('KTM Komuter railway station', origin, apiKey, 10),
    searchPlaces('MRT LRT monorail station', origin, apiKey, 10),
  ])
  const places = results.flatMap((result) =>
    result.status === 'fulfilled' ? result.value : [],
  )
  const namedRailStations = places
    .filter((place) => namedRailStationPattern.test(`${place.name} ${place.description}`))
    .sort((first, second) => distanceBetweenKm(origin, first) - distanceBetweenKm(origin, second))
  const fallbackStations = places
    .filter((place) => !namedRailStationPattern.test(`${place.name} ${place.description}`))
    .sort((first, second) => distanceBetweenKm(origin, first) - distanceBetweenKm(origin, second))
  return deduplicatePlaces([...namedRailStations, ...fallbackStations]).slice(0, 3)
}

function mapGooglePlace(place: Record<string, unknown>): GooglePlace {
  const location = place.location as Record<string, unknown>
  return {
    id: String(place.id),
    name: String((place.displayName as Record<string, unknown> | undefined)?.text ?? 'Unnamed place'),
    category: friendlyCategory(String(place.primaryType ?? 'place')),
    description: String(place.formattedAddress ?? 'Kuala Lumpur'),
    latitude: Number(location.latitude),
    longitude: Number(location.longitude),
  }
}

async function searchCampusPlaces(
  origin: Coordinates,
  apiKey: string,
  radiusKm: number,
) {
  const results = await Promise.all([
    searchNearbyPlacesByType(origin, apiKey, radiusKm, campusDiscoveryTypes),
    searchPlaces('university campus buildings and facilities', origin, apiKey, radiusKm),
    searchPlaces('university canteens, food courts and cafes', origin, apiKey, radiusKm),
    searchPlaces('university sports arenas and halls', origin, apiKey, radiusKm),
  ])
  const uniquePlaces = new Map<string, GooglePlace>()
  for (const place of results.flat()) {
    uniquePlaces.set(String(place.id), place)
  }
  return [...uniquePlaces.values()]
    .sort((first, second) =>
      distanceBetweenKm(origin, first as Coordinates) -
      distanceBetweenKm(origin, second as Coordinates),
    )
    .slice(0, 20)
}

async function buildRailAndWalkRoute(origin: Coordinates, destination: Coordinates, apiKey: string) {
  const [transitResult, walkingResult, drivingResult] = await Promise.allSettled([
    requestGoogleRoute(origin, destination, 'TRANSIT', apiKey),
    requestGoogleRoute(origin, destination, 'WALK', apiKey),
    requestGoogleRoute(origin, destination, 'DRIVE', apiKey),
  ])
  const transitResponse = transitResult.status === 'fulfilled' ? transitResult.value : { routes: [] }
  const walkingResponse = walkingResult.status === 'fulfilled' ? walkingResult.value : { routes: [] }
  const drivingResponse = drivingResult.status === 'fulfilled' ? drivingResult.value : { routes: [] }
  const transitRoute = findRailOnlyRoute(transitResponse.routes ?? [])
  const walkingRoute = walkingResponse.routes?.[0]
  const walkingOnlyDistanceMeters = Number(walkingRoute?.distanceMeters ?? 0)
  // A direct origin-to-destination transit query can prefer a feeder bus even
  // when there is a practical rail trip. For long journeys, try station-
  // assisted rail routing first. If no eligible rail option exists, retain
  // Google's pedestrian route so every accessible selected place remains
  // reviewable and navigable.
  const stationAssistedRoute =
    !transitRoute &&
    (!walkingRoute || walkingOnlyDistanceMeters > maximumWalkingOnlyDistanceMeters)
      ? await buildStationAssistedRailRoute(origin, destination, apiKey)
      : null
  const selectedRoute = transitRoute ?? stationAssistedRoute ?? walkingRoute
  if (!selectedRoute) {
    throw new Error('No eligible rail-and-walk or walking route is available for this journey.')
  }
  const steps = selectedRoute.legs?.flatMap((leg: Record<string, unknown>) => leg.steps ?? []) ?? []
  const routeSteps = steps
    .filter(
      (step: Record<string, unknown>) =>
        step.travelMode === 'WALK' || step.travelMode === 'TRANSIT',
    )
    .map((step: Record<string, unknown>) => mapStep(step))
  const segments = groupSteps(routeSteps)
  const walkingMeters = segments
    .filter((segment: Record<string, unknown>) => segment.type === 'walk')
    .reduce((total: number, segment: Record<string, unknown>) => total + Number(segment.distanceMeters), 0)
  const carDistanceMeters = Number(
    drivingResponse.routes?.[0]?.distanceMeters ?? selectedRoute.distanceMeters ?? 0,
  )

  return {
    segments,
    estimatedCalories: Math.round((walkingMeters / 1000) * 70),
    estimatedCarbonSavedKg: Number(((carDistanceMeters / 1000) * 0.192).toFixed(2)),
  }
}

async function buildStationAssistedRailRoute(
  origin: Coordinates,
  destination: Coordinates,
  apiKey: string,
) {
  let originStations: GooglePlace[]
  let destinationStations: GooglePlace[]
  try {
    [originStations, destinationStations] = await Promise.all([
      searchRailStations(origin, apiKey),
      searchRailStations(destination, apiKey),
    ])
  } catch (error) {
    console.warn('Rail station fallback is unavailable', error)
    return null
  }
  const stationPairs = originStations
    .slice(0, 2)
    .flatMap((originStation) =>
      destinationStations
        .slice(0, 2)
        .filter((destinationStation) => destinationStation.id !== originStation.id)
        .map((destinationStation) => ({ originStation, destinationStation })),
    )

  const candidateResults = await Promise.allSettled(
    stationPairs.map(async ({ originStation, destinationStation }) => {
      const [accessResponse, transitResponse, egressResponse] = await Promise.all([
        requestGoogleRoute(origin, originStation, 'WALK', apiKey),
        requestGoogleRoute(originStation, destinationStation, 'TRANSIT', apiKey),
        requestGoogleRoute(destinationStation, destination, 'WALK', apiKey),
      ])
      const accessRoute = accessResponse.routes?.[0]
      const railRoute = findRailOnlyRoute(transitResponse.routes ?? [])
      const egressRoute = egressResponse.routes?.[0]
      if (!accessRoute || !railRoute || !egressRoute) return null

      const accessDistance = Number(accessRoute.distanceMeters ?? 0)
      const egressDistance = Number(egressRoute.distanceMeters ?? 0)
      if (
        accessDistance > maximumStationAccessWalkingMeters ||
        egressDistance > maximumStationAccessWalkingMeters
      ) {
        return null
      }
      return combineRouteLegs([accessRoute, railRoute, egressRoute])
    }),
  )

  return candidateResults
    .filter(
      (result): result is PromiseFulfilledResult<Record<string, unknown> | null> =>
        result.status === 'fulfilled' && result.value != null,
    )
    .map((result) => result.value!)
    .sort((first, second) => {
      const walkingDifference = walkingDistanceMeters(first) - walkingDistanceMeters(second)
      if (walkingDifference !== 0) return walkingDifference
      return durationSeconds(first) - durationSeconds(second)
    })[0]
}

function combineRouteLegs(routes: Record<string, unknown>[]) {
  const distanceMeters = routes.reduce(
    (total, route) => total + Number(route.distanceMeters ?? 0),
    0,
  )
  const duration = routes.reduce((total, route) => total + durationSeconds(route), 0)
  return {
    distanceMeters,
    duration: `${duration}s`,
    legs: routes.flatMap(
      (route) => (route.legs as Record<string, unknown>[] | undefined) ?? [],
    ),
  }
}

function findRailOnlyRoute(routes: Record<string, unknown>[]) {
  const eligibleRoutes = routes.filter((route) => {
    const steps = (route.legs as Record<string, unknown>[] | undefined)?.flatMap(
      (leg) => (leg.steps as Record<string, unknown>[] | undefined) ?? [],
    ) ?? []
    const transitSteps = steps.filter((step) => step.travelMode === 'TRANSIT')
    return transitSteps.length > 0 && transitSteps.every((step) => {
      const transitDetails = step.transitDetails as Record<string, unknown> | undefined
      const transitLine = transitDetails?.transitLine as Record<string, unknown> | undefined
      const vehicle = transitLine?.vehicle as Record<string, unknown> | undefined
      return railModes.has(String(vehicle?.type ?? ''))
    })
  })
  // Google can return up to three alternatives. Prefer the one with the
  // least walking, then the shortest total duration when walking is equal.
  return eligibleRoutes.sort((first, second) => {
    const walkingDifference = walkingDistanceMeters(first) - walkingDistanceMeters(second)
    if (walkingDifference !== 0) return walkingDifference
    return durationSeconds(first) - durationSeconds(second)
  })[0]
}

function walkingDistanceMeters(route: Record<string, unknown>) {
  const steps = (route.legs as Record<string, unknown>[] | undefined)?.flatMap(
    (leg) => (leg.steps as Record<string, unknown>[] | undefined) ?? [],
  ) ?? []
  return steps
    .filter((step) => step.travelMode === 'WALK')
    .reduce((total, step) => total + Number(step.distanceMeters ?? 0), 0)
}

function durationSeconds(route: Record<string, unknown>) {
  return parseDurationSeconds(String(route.duration ?? route.staticDuration ?? '0s'))
}

function groupSteps(steps: Record<string, unknown>[]) {
  const grouped: Record<string, unknown>[] = []

  for (const step of steps) {
    const previous = grouped.at(-1)
    if (step.type === 'walk' && previous?.type === 'walk') {
      previous.distanceMeters = Number(previous.distanceMeters) + Number(step.distanceMeters)
      previous.durationMinutes = Number(previous.durationMinutes) + Number(step.durationMinutes)
      previous.encodedPolylines = [
        ...(previous.encodedPolylines as string[]),
        ...(step.encodedPolylines as string[]),
      ]
      previous.detail = 'Follow the pedestrian route to the next station or destination.'
      previous.instruction = String(step.instruction)
      continue
    }
    grouped.push({ ...step })
  }

  const hasTransit = grouped.some((segment) => segment.type === 'transit')

  return grouped.map((segment, index) => {
    if (segment.type !== 'walk') return segment
    const isFirst = index === 0
    const isLast = index === grouped.length - 1
    if (!hasTransit) {
      return {
        ...segment,
        title: 'Walk to destination',
        detail: 'Follow the pedestrian route to your destination.',
      }
    }
    return {
      ...segment,
      title: isFirst ? 'Walk to boarding station' : isLast ? 'Walk to destination' : 'Walk between stations',
      detail: isFirst
        ? 'Follow the pedestrian route to reach your rail station.'
        : isLast
        ? 'Follow the pedestrian route from the station to your destination.'
        : 'Follow the pedestrian route to the next rail connection.',
    }
  })
}

async function requestGoogleRoute(
  origin: Coordinates,
  destination: Coordinates,
  travelMode: 'TRANSIT' | 'WALK' | 'DRIVE',
  apiKey: string,
) {
  const isTransit = travelMode === 'TRANSIT'
  const needsStepDetails = travelMode === 'TRANSIT' || travelMode === 'WALK'
  const googleResponse = await fetch(googleRoutesUrl, {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
      'X-Goog-Api-Key': apiKey,
      'X-Goog-FieldMask': needsStepDetails
        ? 'routes.distanceMeters,routes.duration,routes.legs.steps.travelMode,routes.legs.steps.distanceMeters,routes.legs.steps.staticDuration,routes.legs.steps.polyline.encodedPolyline,routes.legs.steps.navigationInstruction.instructions,routes.legs.steps.transitDetails'
        : 'routes.distanceMeters',
    },
    body: JSON.stringify({
      // Station search results carry display metadata. Routes only accepts a
      // LatLng object, so pass coordinates explicitly rather than the full
      // GooglePlace object.
      origin: {
        location: {
          latLng: { latitude: origin.latitude, longitude: origin.longitude },
        },
      },
      destination: {
        location: {
          latLng: { latitude: destination.latitude, longitude: destination.longitude },
        },
      },
      travelMode,
      languageCode: 'en',
      units: 'METRIC',
      ...(isTransit
        ? {
            departureTime: new Date().toISOString(),
            computeAlternativeRoutes: true,
            transitPreferences: {
              allowedTravelModes: ['SUBWAY', 'TRAIN', 'LIGHT_RAIL', 'RAIL'],
              routingPreference: 'LESS_WALKING',
            },
          }
        : {}),
    }),
  })
  const payload = await googleResponse.json()
  if (!googleResponse.ok) {
    throw new Error(payload.error?.message ?? 'Google Routes request failed.')
  }
  return payload
}

function mapStep(step: Record<string, unknown>) {
  const isTransit = step.travelMode === 'TRANSIT'
  const transitDetails = (step.transitDetails ?? {}) as Record<string, unknown>
  const transitLine = (transitDetails.transitLine ?? {}) as Record<string, unknown>
  const stopDetails = (transitDetails.stopDetails ?? {}) as Record<string, unknown>
  const departureStop = (stopDetails.departureStop ?? {}) as Record<string, unknown>
  const arrivalStop = (stopDetails.arrivalStop ?? {}) as Record<string, unknown>
  const instruction = String(
    (step.navigationInstruction as Record<string, unknown> | undefined)?.instructions ??
      (isTransit
        ? `Take ${transitLine.nameShort ?? transitLine.name ?? 'rail service'} from ${departureStop.name ?? 'the station'} to ${arrivalStop.name ?? 'your stop'}.`
        : 'Follow the walking route.'),
  )
  const durationSeconds = parseDurationSeconds(String(step.staticDuration ?? step.duration ?? '0s'))

  return {
    type: isTransit ? 'transit' : 'walk',
    title: isTransit
      ? String(transitLine.name ?? transitLine.nameShort ?? 'Rail service')
      : 'Walk',
    detail: isTransit
      ? `${departureStop.name ?? 'Boarding station'} → ${arrivalStop.name ?? 'Alighting station'}`
      : 'Follow the pedestrian route.',
    instruction,
    boardingStation: isTransit ? String(departureStop.name ?? 'Boarding station') : null,
    distanceMeters: Number(step.distanceMeters ?? 0),
    durationMinutes: Math.max(1, Math.round(durationSeconds / 60)),
    encodedPolylines: [
      String(
        ((step.polyline ?? {}) as Record<string, unknown>).encodedPolyline ?? '',
      ),
    ],
  }
}

function parseCoordinates(value: unknown): Coordinates {
  const source = (value ?? {}) as Record<string, unknown>
  const latitude = Number(source.latitude)
  const longitude = Number(source.longitude)
  if (!Number.isFinite(latitude) || !Number.isFinite(longitude)) {
    throw new Error('A valid origin and destination are required.')
  }
  if (!isWithinWestMalaysia({ latitude, longitude })) {
    throw new Error(
      'Eco-Route is currently available in Peninsular Malaysia only. Choose a starting point and destination in West Malaysia.',
    )
  }
  return { latitude, longitude }
}

/// Keeps the first CitiesWalk release within its supported service area.
/// The outer bounds cover Peninsular Malaysia; the two conditions at the end
/// exclude Singapore and the southern Thai border rather than accepting an
/// unrealistic cross-country walk. Google search is also constrained to
/// Malaysia via `regionCode`.
function isWithinWestMalaysia(location: Coordinates) {
  const { latitude, longitude } = location
  if (latitude < 1.0 || latitude > 7.35 || longitude < 99.45 || longitude > 105.0) {
    return false
  }
  if (longitude < 101.6 && latitude > 6.9) {
    return false
  }
  if (latitude < 1.5 && longitude > 103.55) {
    return false
  }
  return true
}

function includesKualaLumpurContext(query: string) {
  const normalized = query.toLowerCase()
  return normalized.includes('kuala lumpur') || normalized.includes('malaysia')
}

function parseNearbyRadiusKm(value: unknown) {
  const radiusKm = Number(value)
  if (![1, 2, 5].includes(radiusKm)) {
    throw new Error('Choose a nearby distance of 1 km, 2 km, or 5 km.')
  }
  return radiusKm
}

function minimumNearbyRadiusKm(radiusKm: number) {
  if (radiusKm === 5) return 2
  if (radiusKm === 2) return 1
  return 0
}

function filterPlacesByDistance<T>(
  origin: Coordinates,
  places: T[],
  minimumRadiusKm: number,
  maximumRadiusKm: number,
) {
  return places
    .filter((place) => {
      const distanceKm = distanceBetweenKm(origin, place as T & Coordinates)
      return distanceKm > minimumRadiusKm && distanceKm <= maximumRadiusKm
    })
    .sort(
      (first, second) =>
        distanceBetweenKm(origin, first as T & Coordinates) -
        distanceBetweenKm(origin, second as T & Coordinates),
    )
}

function deduplicatePlaces<T extends { id: string }>(places: T[]) {
  return [...new Map(places.map((place) => [place.id, place])).values()]
}

function distanceBetweenKm(first: Coordinates, second: Coordinates) {
  const earthRadiusKm = 6371
  const latitudeDelta = degreesToRadians(second.latitude - first.latitude)
  const longitudeDelta = degreesToRadians(second.longitude - first.longitude)
  const a =
    Math.sin(latitudeDelta / 2) ** 2 +
    Math.cos(degreesToRadians(first.latitude)) *
      Math.cos(degreesToRadians(second.latitude)) *
      Math.sin(longitudeDelta / 2) ** 2
  return earthRadiusKm * 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a))
}

function degreesToRadians(value: number) {
  return (value * Math.PI) / 180
}

function parseDurationSeconds(value: string) {
  const match = /^(\d+(?:\.\d+)?)s$/.exec(value)
  return match ? Number(match[1]) : 0
}

function friendlyCategory(primaryType: string) {
  if (
    primaryType.includes('university') ||
    primaryType.includes('school') ||
    primaryType.includes('educational_institution') ||
    primaryType.includes('academic_department')
  ) return 'Campus'
  if (
    primaryType.includes('restaurant') ||
    primaryType.includes('food') ||
    primaryType.includes('cafe') ||
    primaryType.includes('cafeteria')
  ) return 'Local food'
  if (primaryType.includes('mall') || primaryType.includes('department_store')) return 'Shopping mall'
  if (primaryType.includes('station') || primaryType.includes('transit')) return 'Transit station'
  if (primaryType.includes('park')) return 'Park'
  if (primaryType.includes('museum')) return 'Museum'
  if (primaryType.includes('market')) return 'Market'
  if (primaryType.includes('historical') || primaryType.includes('tourist')) return 'Landmark'
  return 'Place to visit'
}

function nearbyQuery(category: string) {
  const queries: Record<string, string> = {
    all: 'tourist attractions, parks, historical landmarks, local food, university campuses, campus canteens and sports arenas',
    food: 'local Malaysian food restaurants and cafes',
    attractions: 'tourist attractions and sights',
    history: 'historical landmarks and heritage sites',
    parks: 'parks and gardens',
    museums: 'museums and cultural centres',
    markets: 'local markets and craft markets',
    campus: 'university campus buildings, sports arenas, canteens and cafes',
    malls: 'shopping malls and retail centres',
    transit: 'MRT LRT monorail and train stations',
  }
  return queries[category] ?? queries.all
}

function nearbyPlaceTypes(category: string): string[] | null {
  const categoryTypes: Record<string, string[]> = {
    food: ['restaurant', 'cafe', 'cafeteria', 'food_court'],
    attractions: [
      'amusement_park',
      'aquarium',
      'art_gallery',
      'botanical_garden',
      'zoo',
    ],
    history: ['historical_place', 'cultural_landmark', 'monument', 'museum'],
    parks: ['park', 'botanical_garden'],
    museums: ['museum', 'art_gallery'],
    markets: ['market'],
    campus: [
      'university',
      'school',
      'educational_institution',
      'academic_department',
    ],
    malls: ['shopping_mall', 'department_store'],
    transit: [
      'subway_station',
      'light_rail_station',
      'train_station',
    ],
  }
  return categoryTypes[category] ?? null
}

const campusDiscoveryTypes = [
  'university',
  'school',
  'educational_institution',
  'academic_department',
]

function response(data: unknown, status = 200) {
  return new Response(JSON.stringify(data), {
    status,
    headers: { ...corsHeaders, 'Content-Type': 'application/json' },
  })
}
