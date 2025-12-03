import { CONFIG } from '../config/config'

// Common request helper
async function request(path, { method = 'GET', params, body } = {}) {
  // Build URL with query params
  const url = new URL(CONFIG.API_BASE.replace(/\/+$/,'') + path, window.location.origin)
  if (params) {
    Object.entries(params).forEach(([k, v]) => {
      if (v != null) url.searchParams.set(k, v)
    })
  }

  const res = await fetch(url, {
    method,
    headers: { 'Accept': 'application/json', 'Content-Type': 'application/json' },
    body: body ? JSON.stringify(body) : undefined
  })

  if (!res.ok) {
    const text = await res.text().catch(() => '')
    throw new Error(`HTTP ${res.status} ${res.statusText} – ${text}`)
  }
  return res.status === 204 ? null : res.json()
}

// ----- API groups -----

export const BooksAPI = {
  // GET /api/books → [{...}] or { data:[...] }
  list  : (params)     => request('/api/books', { params }),
  create: (data)       => request('/api/books', { method: 'POST', body: data }),
  update: (id, data)   => request(`/api/books/${id}`, { method: 'PUT', body: data }),
  remove: (id)         => request(`/api/books/${id}`, { method: 'DELETE' }),
  uploadCover: async (file) => {
    const fd = new FormData()
    fd.append('file', file)
    const res = await fetch('/api/books/cover', { method: 'POST', body: fd })
    if (!res.ok) throw new Error('Upload failed')
    return await res.json()
  }
}

export const LabelsAPI = {
  list  : (params)     => request('/api/labels', { params }),
  create: (data)       => request('/api/labels', { method: 'POST', body: data }),
  //update: (id, data)   => request(`/api/labels/${id}`, { method: 'PUT', body: data }),
  remove: (id)         => request(`/api/labels/${id}`, { method: 'DELETE' })
}

export const UsersAPI = {
  search: (username) =>
      request('/api/admin/users/search', {
        method: 'GET',
        params: { username }
      }),
  reset: (userId) =>
      request(`/api/admin/users/${encodeURIComponent(userId)}/reset-password`, {
        method: 'POST'
      }),
  ban: (userId) =>
      request(`/api/admin/users/${encodeURIComponent(userId)}/ban`, {
        method: 'PATCH'
      }),
  unban: (userId) =>
      request(`/api/admin/users/${encodeURIComponent(userId)}/unban`, {
        method: 'PATCH'
      })
}

export const CommentsAPI = {
    listAllForAdmin: (authorType = 1) =>
        request('/api/comments/admin/all', { params: { authorType } }),

  // Hide comment
  hide: (commentId, authorType = 1) =>
      request(`/api/comments/hide/${commentId}`, {
        method: 'PUT',
        params: { authorType },
          responseType: 'text'
      }),

  // Restore comment
  restore: (commentId, authorType = 1) =>
      request(`/api/comments/restore/${commentId}`, {
        method: 'PUT',
        params: { authorType },
          responseType: 'text'
      })

}

export const ReservationsAPI = {
  // 1 Get books with status 1 and 4
  list: (params) => request('/api/reservations/admin/all', { params }),

  // 2 Borrow book (renamed from reserve to pickup)
  pickup: (reservationId) =>
      request(`/api/reservations/admin/pickup/${reservationId}`, { method: 'POST' }),

  // 3 Return book: 4 -> 2
  returnById: (reservationId) =>
      request(`/api/reservations/return/${reservationId}`, { method: 'POST' }),

  // 4 Query reservation record by isbn and userId
}


