import '@supabase/functions-js/edge-runtime.d.ts'
import { withSupabase } from '@supabase/server'

const corsHeaders = {
  'Access-Control-Allow-Headers':
    'authorization, x-client-info, apikey, content-type',
  'Access-Control-Allow-Methods': 'POST, OPTIONS',
}

const pointsPerWalkingKilometre = 30
const pointsPerCarbonKilogram = 45

type JourneyRow = {
  id: string
  status: string
  ended_at: string | null
  estimated_walking_distance_meters: number
  estimated_calories: number
  estimated_carbon_saved_kg: number
  actual_walking_distance_meters: number | null
  actual_calories_burned: number | null
  actual_carbon_saved_kg: number | null
}

const rewardsHandler = withSupabase({ auth: 'user' }, async (request, ctx) => {
  if (request.method !== 'POST') {
    return json({ error: 'Only POST is supported.' }, 405)
  }

  try {
    const journeyId = await parseJourneyId(request)
    const journey = await fetchCompletedJourney(ctx.supabase, journeyId)

    if (!journey) {
      return json({ error: 'Journey not found.' }, 404)
    }

    if (journey.status !== 'completed' || !journey.ended_at) {
      return json(
        { error: 'Only completed journeys are eligible for rewards.' },
        409,
      )
    }

    const metrics = resolveMetrics(journey)
    const points = Math.round(
      pointsPerWalkingKilometre * metrics.walkingDistanceKm +
        pointsPerCarbonKilogram * metrics.carbonSavedKg,
    )

    const existing = await ctx.supabaseAdmin
      .from('reward_point_transactions')
      .select('id, points')
      .eq('journey_id', journey.id)
      .maybeSingle()

    if (existing.error) {
      throw existing.error
    }

    if (existing.data) {
      return json({
        awarded: false,
        points: existing.data.points,
        message: 'This journey has already received rewards.',
      })
    }

    const result = await ctx.supabaseAdmin
      .from('reward_point_transactions')
      .insert({
        user_id: ctx.userClaims!.id,
        journey_id: journey.id,
        points,
        walking_distance_km: metrics.walkingDistanceKm,
        carbon_saved_kg: metrics.carbonSavedKg,
        calories_burned: metrics.caloriesBurned,
        metric_source: metrics.source,
        policy_version: 'v1',
        journey_completed_at: journey.ended_at,
      })
      .select('id, points')
      .maybeSingle()

    if (result.error) {
      if (result.error.code === '23505') {
        return json({
          awarded: false,
          points,
          message: 'This journey has already received rewards.',
        })
      }
      throw result.error
    }

    return json({ awarded: true, points: result.data?.points ?? points })
  } catch (error) {
    console.error('rewards-process failed', error)
    return json(
      {
        error: error instanceof Error ? error.message : 'Unable to process rewards.',
      },
      400,
    )
  }
})

export default {
  fetch: (request: Request) => {
    if (request.method === 'OPTIONS') {
      return new Response('ok', { headers: corsHeaders })
    }
    return rewardsHandler(request)
  },
}

async function parseJourneyId(request: Request): Promise<string> {
  let body: Record<string, unknown>
  try {
    body = (await request.json()) as Record<string, unknown>
  } catch (_) {
    throw new Error('A JSON request body is required.')
  }

  const journeyId = body.journeyId
  if (typeof journeyId !== 'string' || !isUuid(journeyId)) {
    throw new Error('A valid journeyId is required.')
  }
  return journeyId
}

async function fetchCompletedJourney(
  client: { from: (table: string) => any },
  journeyId: string,
): Promise<JourneyRow | null> {
  const result = await client
    .from('eco_journeys')
    .select(
      'id, status, ended_at, estimated_walking_distance_meters, '
        + 'estimated_calories, estimated_carbon_saved_kg, '
        + 'actual_walking_distance_meters, actual_calories_burned, '
        + 'actual_carbon_saved_kg',
    )
    .eq('id', journeyId)
    .maybeSingle()

  if (result.error) {
    throw result.error
  }
  return result.data as JourneyRow | null
}

function resolveMetrics(journey: JourneyRow) {
  const actualWalkingMeters = nonNegativeOrNull(
    journey.actual_walking_distance_meters,
  )
  const actualCarbonSavedKg = nonNegativeOrNull(journey.actual_carbon_saved_kg)
  const actualCaloriesBurned = nonNegativeOrNull(journey.actual_calories_burned)

  const walkingDistanceKm =
    (actualWalkingMeters ?? nonNegative(journey.estimated_walking_distance_meters)) /
    1000
  const carbonSavedKg =
    actualCarbonSavedKg ?? nonNegative(journey.estimated_carbon_saved_kg)
  const caloriesBurned = actualCaloriesBurned ?? nonNegative(journey.estimated_calories)

  const source =
    actualWalkingMeters !== null && actualCarbonSavedKg !== null
      ? 'actual'
      : actualWalkingMeters !== null || actualCarbonSavedKg !== null
      ? 'mixed'
      : 'estimated'

  return {
    walkingDistanceKm: roundToThreeDecimals(walkingDistanceKm),
    carbonSavedKg: roundToThreeDecimals(carbonSavedKg),
    caloriesBurned: Math.round(caloriesBurned),
    source,
  }
}

function nonNegative(value: number) {
  if (!Number.isFinite(value) || value < 0) {
    throw new Error('Journey metrics are invalid.')
  }
  return value
}

function nonNegativeOrNull(value: number | null) {
  if (value === null) return null
  return nonNegative(value)
}

function roundToThreeDecimals(value: number) {
  return Math.round(value * 1000) / 1000
}

function isUuid(value: string) {
  return /^[0-9a-f]{8}-[0-9a-f]{4}-[1-5][0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$/i.test(
    value,
  )
}

function json(data: unknown, status = 200) {
  return new Response(JSON.stringify(data), {
    status,
    headers: { ...corsHeaders, 'Content-Type': 'application/json' },
  })
}
