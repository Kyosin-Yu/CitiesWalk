import '@supabase/functions-js/edge-runtime.d.ts'
import { withSupabase } from '@supabase/server'

const handler = withSupabase({ auth: 'user' }, async (request, ctx) => {
  if (request.method !== 'POST') {
    return Response.json({ error: 'Only POST is supported.' }, { status: 405 })
  }

  const userId = ctx.userClaims!.id
  const deletion = await ctx.supabaseAdmin
    .from('account_deletion_requests')
    .select('permanently_delete_at')
    .eq('user_id', userId)
    .maybeSingle()

  if (deletion.error) throw deletion.error
  if (!deletion.data) {
    return Response.json({ error: 'Deletion is not scheduled.' }, { status: 409 })
  }

  if (new Date(deletion.data.permanently_delete_at).getTime() > Date.now()) {
    return Response.json(
      { error: 'The 30-day recovery period has not expired.' },
      { status: 409 },
    )
  }

  await removeProfileImages(ctx.supabaseAdmin, userId)
  await removeReviewImages(ctx.supabaseAdmin, userId)

  const deleted = await ctx.supabaseAdmin.auth.admin.deleteUser(userId, false)
  if (deleted.error) throw deleted.error

  return Response.json({ deleted: true })
})

Deno.serve(handler)

async function removeProfileImages(admin: any, userId: string) {
  const listed = await admin.storage.from('profile-images').list(userId)
  if (listed.error) throw listed.error
  const paths = (listed.data ?? []).map((file: { name: string }) =>
    `${userId}/${file.name}`
  )
  if (paths.length === 0) return
  const removed = await admin.storage.from('profile-images').remove(paths)
  if (removed.error) throw removed.error
}

async function removeReviewImages(admin: any, userId: string) {
  const folders = await admin.storage.from('review-photos').list(userId)
  if (folders.error) throw folders.error
  const paths: string[] = []
  for (const folder of folders.data ?? []) {
    const listed = await admin.storage
      .from('review-photos')
      .list(`${userId}/${folder.name}`)
    if (listed.error) throw listed.error
    for (const file of listed.data ?? []) {
      paths.push(`${userId}/${folder.name}/${file.name}`)
    }
  }
  if (paths.length === 0) return
  const removed = await admin.storage.from('review-photos').remove(paths)
  if (removed.error) throw removed.error
}
