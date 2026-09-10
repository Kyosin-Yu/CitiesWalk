const corsHeaders = {
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
  'Access-Control-Allow-Methods': 'POST, OPTIONS',
}

const supportedContentTypes = new Set(['image/jpeg', 'image/png', 'image/webp'])
const unsafeLikelihoods = new Set(['LIKELY', 'VERY_LIKELY'])
const maximumBase64Length = 7 * 1024 * 1024

type SafeSearchAnnotation = {
  adult?: string
  racy?: string
  violence?: string
}

Deno.serve(async (request) => {
  if (request.method === 'OPTIONS') {
    return response({}, 200)
  }
  if (request.method !== 'POST') {
    return response({ message: 'Only POST is supported.' }, 405)
  }

  const apiKey = Deno.env.get('GOOGLE_CLOUD_VISION_API_KEY')
  if (!apiKey) {
    return response({ message: 'Photo moderation is not configured.' }, 503)
  }

  try {
    const body = await request.json()
    const image = typeof body.image === 'string' ? body.image : ''
    const contentType = typeof body.contentType === 'string' ? body.contentType : ''
    if (!supportedContentTypes.has(contentType)) {
      return response({ approved: false, message: 'Only JPEG, PNG, or WebP photos can be attached.' }, 400)
    }
    if (image.length === 0 || image.length > maximumBase64Length) {
      return response({ approved: false, message: 'The selected photo is invalid or too large.' }, 400)
    }

    const safeSearch = await detectSafeSearch(image, apiKey)
    if (isUnsafe(safeSearch)) {
      return response({ approved: false, message: 'This photo cannot be attached because it contains inappropriate content.' })
    }
    return response({ approved: true })
  } catch (error) {
    console.error('Review image moderation failed', error)
    return response({ message: 'Unable to verify this photo. Please try again later.' }, 503)
  }
})

async function detectSafeSearch(
  image: string,
  apiKey: string,
): Promise<SafeSearchAnnotation> {
  const visionResponse = await fetch(
    `https://vision.googleapis.com/v1/images:annotate?key=${encodeURIComponent(apiKey)}`,
    {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({
        requests: [
          {
            image: { content: image },
            features: [{ type: 'SAFE_SEARCH_DETECTION' }],
          },
        ],
      }),
    },
  )
  const payload = await visionResponse.json()
  if (!visionResponse.ok || payload.responses?.[0]?.error) {
    throw new Error(payload.error?.message ?? payload.responses?.[0]?.error?.message ?? 'Vision request failed.')
  }
  return payload.responses?.[0]?.safeSearchAnnotation ?? {}
}

function isUnsafe(annotation: SafeSearchAnnotation): boolean {
  return [annotation.adult, annotation.racy, annotation.violence].some((likelihood) =>
    unsafeLikelihoods.has(likelihood ?? 'UNKNOWN')
  )
}

function response(data: unknown, status = 200) {
  return new Response(JSON.stringify(data), {
    status,
    headers: { ...corsHeaders, 'Content-Type': 'application/json' },
  })
}
