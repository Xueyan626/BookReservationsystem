<template>
  <div class="container">
    <section class="page">
      <header class="header">
        <div>
          <h1>Reservations</h1>
          <p>Manage book reservations (sorted by user)</p >
        </div>

        <div class="actions">
          <input
              v-model.trim="keyword"
              type="search"
              name="reservationSearch"
              class="search"
              placeholder="Search by user or book"
              autocomplete="off"
              @keyup.enter="load"
          />
          <button
              id="reservation-search-btn"
              name="reservationSearchBtn"
              class="btn primary"
              @click="load"
          >Search</button>
        </div>
      </header>

      <section>
        <table>
          <thead>
          <tr>
            <th style="width:24%">User</th>
            <th style="width:44%">Book name</th>
            <th style="width:12%">Status</th>
            <th style="width:20%">Operation</th>
          </tr>
          </thead>

          <tbody>
          <tr v-for="r in rows" :key="r.id">
            <td class="ellipsis" :title="r.userNickname">{{ r.userNickname || 'Unknown' }}</td>
            <td class="ellipsis" :title="r.bookName">{{ r.bookName || 'Unknown' }}</td>
            <td>
              <span v-if="r.status === 1">Ready</span>
              <span v-else-if="r.status === 4">Borrowed</span>
              <span v-else>{{ r.status }}</span>
            </td>
            <td class="ops">
              <button
                  v-if="r.status === 1"
                  class="pill"
                  :disabled="loadingKey === 'pickup:'+r.id"
                  @click="pickup(r)"
              >
                {{ loadingKey === 'pickup:'+r.id ? '...' : 'Pickup' }}
              </button>

              <button
                  v-if="r.status === 4"
                  class="pill ghost"
                  :disabled="loadingKey === 'return:'+r.id"
                  @click="returnOne(r)"
              >
                {{ loadingKey === 'return:'+r.id ? '...' : 'Return' }}
              </button>
            </td>
          </tr>

          <tr v-if="!rows.length">
            <td colspan="4" class="empty">No reservations</td>
          </tr>
          </tbody>
        </table>
      </section>
    </section>
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import { ReservationsAPI } from '../../api/api'

/* ---------- utils ---------- */
const arr = (x) => {
  if (!x) return []
  if (Array.isArray(x)) return x
  const d = x.data ?? x.result ?? x.payload ?? x.items ?? x.list ?? x.records ?? x.rows ?? x.content
  if (Array.isArray(d)) return d
  const dd = x.data && (x.data.content || x.data.records || x.data.items || x.data.list || x.data.rows)
  if (dd && Array.isArray(dd)) return dd
  for (const k of Object.keys(x)) {
    if (Array.isArray(x[k])) return x[k]
    if (x[k] && typeof x[k] === 'object') {
      for (const kk of Object.keys(x[k])) {
        if (Array.isArray(x[k][kk])) return x[k][kk]
      }
    }
  }
  return []
}
const toNum = (v, d = 0) => (Number.isFinite(Number(v)) ? Number(v) : d)
const nn = (s='') => String(s || '').toLowerCase().trim()

/* ---------- normalizer (按后台 AdminReservationDTO) ---------- */
const normRes = (r = {}) => ({
  id           : r?.reservationId ?? r?.id,
  userNickname : r?.userNickname ?? r?.nickname ?? r?.userName ?? null,
  bookId       : r?.bookId ?? r?.book?.id ?? null,
  bookName     : r?.bookName ?? r?.bookTitle ?? r?.book?.name ?? '',
  status       : toNum(r?.status, -1),
})

/* ---------- state ---------- */
const keyword = ref('')
const rows = ref([])
const loadingKey = ref('')

/* ---------- fetch reservations (ready + borrowed) ---------- */
async function fetchReservationRows() {
  const [q1, q4] = await Promise.allSettled([
    ReservationsAPI.list({ status: 1 }), // Ready
    ReservationsAPI.list({ status: 4 }), // Borrowed
  ])
  const ready = (q1.status === 'fulfilled' ? arr(q1.value) : []).map(normRes)
  const borrowed = (q4.status === 'fulfilled' ? arr(q4.value) : []).map(normRes)

  let all = [...ready, ...borrowed]

  // 搜索：书名或昵称
  const kw = nn(keyword.value)
  if (kw) {
    all = all.filter(r => nn(r.bookName).includes(kw) || nn(r.userNickname).includes(kw))
  }

  // 按 userNickname 排序（空值靠后；次序按 id）
  all.sort((a, b) => {
    const ua = a.userNickname ? nn(a.userNickname) : '~~~'
    const ub = b.userNickname ? nn(b.userNickname) : '~~~'
    const cmp = ua.localeCompare(ub)
    return cmp !== 0 ? cmp : (toNum(a.id) - toNum(b.id))
  })

  return all
}

/* ---------- lifecycle ---------- */
async function load() {
  rows.value = await fetchReservationRows()
}
onMounted(load)

/* ---------- actions (无弹窗) ---------- */
async function pickup(r) {
  loadingKey.value = 'pickup:' + r.id
  try {
    await ReservationsAPI.pickup(r.id) // POST /api/reservations/admin/pickup/{reservationId}
    await load()
  } catch {
    window.alert('Pickup failed')
  } finally {
    loadingKey.value = ''
  }
}

async function returnOne(r) {
  loadingKey.value = 'return:' + r.id
  try {
    const response = await ReservationsAPI.returnById(r.id)
    console.log('Return response:', response)
    await load()
    console.log('List reloaded after return')
  } catch (error) {
    console.error('Return failed:', error)
    window.alert(`Return failed: ${error.message || 'Unknown error'}`)
  } finally {
    loadingKey.value = ''
  }
}
</script>

<style scoped>
.container{max-width:1120px;margin:0 auto;padding:24px}
.page{background:#f2f3f5;border:1px solid #e5e7eb;border-radius:20px;padding:20px}
.header{display:flex;align-items:center;justify-content:space-between;margin-bottom:16px}
h1{margin:0 0 6px;font-size:22px}
.header p{margin:0;color:#6b7280}
.actions{display:flex;gap:12px;align-items:center}
.search{width:320px;max-width:48vw;padding:10px 12px;border:1px solid #e5e7eb;border-radius:12px;background:#fff}
.btn{padding:10px 14px;border-radius:12px;border:1px solid transparent;cursor:pointer}
.btn.primary{background:#2563eb;color:#fff}
table{width:100%;border-collapse:collapse;background:#fff;border-radius:16px;overflow:hidden}
th,td{padding:12px 14px;text-align:left;border-bottom:1px solid #e5e7eb}
th{background:#f9fafb;color:#6b7280;font-weight:600;font-size:13px}
tr:hover{background:#fafafa}
.ellipsis{max-width:420px;white-space:nowrap;overflow:hidden;text-overflow:ellipsis}
.empty{color:#6b7280;text-align:center;padding:36px 0}
.ops{display:flex;gap:8px}
.pill{padding:6px 12px;border-radius:8px;border:1px solid #e5e7eb;background:#fff;cursor:pointer}
.pill.ghost{background:#eef2ff;color:#4338ca;border-color:#e5e7eb}
.pill[disabled]{opacity:.6;cursor:not-allowed}
</style>