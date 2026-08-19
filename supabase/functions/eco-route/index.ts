type Coordinates = { latitude: number; longitude: number }

const corsHeaders = {
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
  'Access-Control-Allow-Methods': 'POST, OPTIONS',
}

const googleRoutesUrl = 'https://routes.googleapis.com/directions/v2:computeRoutes'
const googlePlacesUrl = 'https://places.googleapis.com/v1/places:searchText'
const railModes = new Set(['SUBWAY', 'TRAIN', 'LIGHT_RAIL', 'RAIL', 'MONORAIL'])

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
      return response({ places: await searchPlaces(nearbyQuery(category), origin, apiKey) })
    }

    if (action === 'search') {
      const query = typeof body.query === 'string' ? body.query.trim() : ''
      if (query.length < 2 || query.length > 120) {
        return response({ error: 'Enter between 2 and 120 characters to search.' }, 400)
      }
      return response({ places: await searchPlaces(query, origin, apiKey) })
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

async function searchPlaces(query: string, origin: Coordinates, apiKey: string) {
  const googleResponse = await fetch(googlePlacesUrl, {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
      'X-Goog-Api-Key': apiKey,
      'X-Goog-FieldMask': 'places.id,places.displayName,places.formattedAddress,places.location,places.primaryType,places.types',
    },
    body: JSON.stringify({
      textQuery: query,
      maxResultCount: 12,
      locationBias: {
        circle: {
          center: { latitude: origin.latitude, longitude: origin.longitude },
          radius: 10000,
        },
      },
      languageCode: 'en',
    }),
  })

  const payload = await googleResponse.json()
  if (!googleResponse.ok) {
    throw new Error(payload.error?.message ?? 'Google Places search failed.')
  }

  return (payload.places ?? [])
    .filter((place: Record<string, unknown>) => place.location)
    .map((place: Record<string, unknown>) => ({
      id: String(place.id),
      name: String((place.displayName as Record<string, unknown> | undefined)?.text ?? 'Unnamed place'),
      category: friendlyCategory(String(place.primaryType ?? 'place')),
      description: String(place.formattedAddress ?? 'Kuala Lumpur'),
      latitude: Number((place.location as Record<string, unknown>).latitude),
      longitude: Number((place.location as Record<string, unknown>).longitude),
    }))
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
  const selectedRoute = transitRoute ?? walkingResponse.routes?.[0]
  if (!selectedRoute) throw new Error('No safe walking route is available for this journey.')

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

function findRailOnlyRoute(routes: Record<string, unknown>[]) {
  return routes.find((route) => {
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

  return grouped.map((segment, index) => {
    if (segment.type !== 'walk') return segment
    const isFirst = index === 0
    const isLast = index === grouped.length - 1
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
      origin: { location: { latLng: origin } },
      destination: { location: { latLng: destination } },
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
  return { latitude, longitude }
}

function parseDurationSeconds(value: string) {
  const match = /^(\d+(?:\.\d+)?)s$/.exec(value)
  return match ? Number(match[1]) : 0
}

function friendlyCategory(primaryType: string) {
  if (primaryType.includes('restaurant') || primaryType.includes('food')) return 'Local food'
  if (primaryType.includes('park')) return 'Park'
  if (primaryType.includes('museum')) return 'Museum'
  if (primaryType.includes('market')) return 'Market'
  if (primaryType.includes('historical') || primaryType.includes('tourist')) return 'Landmark'
  return 'Place to visit'
}

function nearbyQuery(category: string) {
  const queries: Record<string, string> = {
    all: 'tourist attractions, parks, historical landmarks and local food',
    food: 'local Malaysian food restaurants and cafes',
    attractions: 'tourist attractions and sights',
    history: 'historical landmarks and heritage sites',
    parks: 'parks and gardens',
    museums: 'museums and cultural centres',
    markets: 'local markets and craft markets',
  }
  return queries[category] ?? queries.all
}

function response(data: unknown, status = 200) {
  return new Response(JSON.stringify(data), {
    status,
    headers: { ...corsHeaders, 'Content-Type': 'application/json' },
  })
}
