<template>
  <div class="container">
    <section class="page">
      <!-- ===== Header ===== -->
      <header class="page-header">
        <div>
          <h1>Comments Management</h1>
          <p class="sub">Manage book comments and reviews</p>
        </div>

        <div class="toolbar">
          <!-- 关键字：书名 / 用户名 / 评论文本 -->
          <input
              v-model.trim="keyword"
              type="search"
              class="search"
              placeholder="Search by book title / user / comment…"
              autocomplete="off"
          />

          <select v-model="status" class="select">
            <option value="all">All Status</option>
            <option value="visible">Visible</option>
            <option value="hidden">Hidden</option>
          </select>

          <button class="btn" @click="reload" :disabled="busy === 'load'">
            {{ busy === 'load' ? 'Refreshing…' : 'Refresh' }}
          </button>

        </div>

      </header>

      <!-- 已加载书名提示 -->
      <div v-if="bookTitle" class="book-hint">
        Current Book: <span class="book-title">{{ bookTitle }}</span>
        <button class="link" @click="reload">Reload</button>
      </div>

      <!-- ===== Table ===== -->
      <section class="table-wrap">
        <table class="table">
          <thead>
          <tr>
            <th>Comment ID</th>
            <th>Date</th>
            <th>User</th>
            <th>Comment Text</th>
            <th>Book Title</th>
            <th class="th-status">Status</th>
          </tr>
          </thead>

          <tbody>
          <tr v-for="c in filtered" :key="c.commentId">
            <td><a class="link-id">C{{ String(c.commentId).padStart(3,'0') }}</a></td>
            <td>{{ formatDate(c.date) }}</td>
            <td>{{ c.user }}</td>
            <td class="col-text" :title="c.text">{{ c.text }}</td>
            <td>{{ c.book }}</td>
            <td class="status-td">
              <button
                  class="status-pill"
                  :class="Number(c.status) === 1 ? 'is-visible' : 'is-hidden'"
                  @click="toggle(c)"
                  :disabled="busy === 'toggle:' + c.commentId"
              >
                <span v-if="busy === 'toggle:' + c.commentId">Saving…</span>
                <span v-else>{{ Number(c.status) === 1 ? 'Visible' : 'Hidden' }}</span>
              </button>
            </td>
          </tr>

          <tr v-if="!filtered.length && rows.length && !isLoading">
            <td colspan="6" class="muted">No comments match current filters.</td>
          </tr>
          <tr v-if="!rows.length && !isLoading">
            <td colspan="6" class="muted">Load comments by entering a Book ID above.</td>
          </tr>
          <tr v-if="isLoading">
            <td colspan="6" class="muted">Loading comments…</td>
          </tr>
          </tbody>
        </table>
      </section>

      <!-- 结果统计 -->
      <footer class="footer" v-if="rows.length">
        <span>Total: {{ rows.length }}</span>
        <span>Showing: {{ filtered.length }}</span>
      </footer>
    </section>
  </div>
</template>

<script setup>
import { ref, computed } from 'vue'
import { CommentsAPI } from '../../api/api' // 去掉 BooksAPI

/* ---- state ---- */
const rows = ref([])
const keyword = ref('')
const status = ref('all')
const authorType = ref(1) // 管理员
const busy = ref('')
const isLoading = computed(() => busy.value === 'load')

/* ---- utils ---- */
const formatDate = (s) => (s ? String(s).slice(0, 10) : '-')

function mapRow(d) {
  // 后端返回 AdminCommentViewDTO:
  // { commentId, bookName, userName, content, createDate, status }
  return {
    commentId: d.commentId,
    user: d.userName ?? '-',
    book: d.bookName ?? '-',
    text: d.content ?? '',
    date: d.createDate ?? '-',
    status: Number(d.status) === 1 ? 1 : 0
  }
}

/* ---- filters ---- */
const filtered = computed(() => {
  const kw = keyword.value.trim().toLowerCase()
  const st = status.value
  return rows.value.filter(c => {
    const okKw =
        !kw ||
        (c.user || '').toLowerCase().includes(kw) ||
        (c.book || '').toLowerCase().includes(kw) ||
        (c.text || '').toLowerCase().includes(kw)

    const vis = Number(c.status)
    const okSt =
        st === 'all' ||
        (st === 'visible' && vis === 1) ||
        (st === 'hidden'  && vis === 0)

    return okKw && okSt
  })
})

function clearFilters() {
  keyword.value = ''
  status.value = 'all'
}

/* ---- load / reload ---- */
async function load() {
  busy.value = 'load'
  rows.value = []
  try {
    const res = await CommentsAPI.listAllForAdmin(authorType.value)
    const list = Array.isArray(res) ? res : (res?.data || [])
    rows.value = list.map(mapRow)
  } catch (e) {
    console.error('Load failed:', e)
  } finally {
    busy.value = ''
  }
}
function reload() {
  load()
}

/* ---- toggle visibility (成功后再更新) ---- */
async function toggle(c) {
  if (c?.commentId == null) {
    alert('Comment id missing')
    return
  }
  const cur = Number(c.status) === 1 ? 1 : 0
  const next = cur === 1 ? 0 : 1

  busy.value = 'toggle:' + c.commentId
  try {
    if (cur === 1) {
      await CommentsAPI.hide(c.commentId, authorType.value)
    } else {
      await CommentsAPI.restore(c.commentId, authorType.value)
    }
    c.status = next
  } catch (e) {
    console.error('Update failed:', e)
    alert('Failed to update status. Please try again.')
  } finally {
    busy.value = ''
  }
}

/* 初始化拉一次 */
load()
</script>


<style scoped>
/* layout */
.container{max-width:1120px;margin:0 auto;padding:24px}
.page{background:#f6f7f9;border:1px solid #e5e7eb;border-radius:16px;padding:20px}
.page-header{display:flex;align-items:center;justify-content:space-between;gap:12px;margin-bottom:12px}
h1{margin:0 0 6px;font-size:22px;font-weight:700}
.sub{margin:0;color:#6b7280}

/* toolbar */
.toolbar{display:flex;gap:10px;align-items:center;flex-wrap:wrap}
.search{width:320px;padding:10px 12px;border:1px solid #e5e7eb;border-radius:12px;background:#fff}
.search.short{width:160px}
.select{padding:10px 12px;border:1px solid #e5e7eb;border-radius:12px;background:#fff}
.btn{padding:10px 12px;border:1px solid #e5e7eb;border-radius:12px;background:#fff;cursor:pointer}
.btn:disabled{opacity:.6;cursor:not-allowed}
.btn.ghost{background:transparent}

/* current book */
.book-hint{margin:8px 2px 4px;color:#374151}
.book-title{font-weight:700}
.link{border:0;background:transparent;color:#2563eb;cursor:pointer;margin-left:8px}

/* table */
.table-wrap{margin-top:8px; padding-right:96px; overflow-x:auto;} /* 右侧预留，防浮标遮挡 */
.table{width:100%;border-collapse:separate;border-spacing:0 8px}
.table thead th{font-size:13px;color:#6b7280;font-weight:600;padding:10px 12px;text-align:left}
.table tbody tr{background:#fff;box-shadow:0 1px 0 0 #eef0f3;border-radius:10px}
.table tbody td{padding:12px;vertical-align:middle}
.table tbody tr:hover{background:#fafafa}
.col-text{max-width:420px;white-space:nowrap;overflow:hidden;text-overflow:ellipsis}
.link-id{color:#3b82f6;text-decoration:none;font-weight:600}
.link-id:hover{text-decoration:underline}
.muted{color:#6b7280;text-align:center;padding:20px}

/* 让最后一列稳定可见、宽度足够 */
.th-status,
.table thead th:last-child,
.table tbody td:last-child{
  min-width:160px;
  white-space:nowrap;
  position:sticky;
  right:0;
  z-index:1;
}

.status-td{display:flex;align-items:center;justify-content:flex-start}

/* status pill */
.status-pill{
  padding:6px 12px;border-radius:999px;font-size:12px;font-weight:700;border:1px solid transparent;cursor:pointer;
  display:inline-flex;align-items:center;justify-content:center;min-height:28px;
}
/* 可见：绿色 */
.status-pill.is-visible{background:#dcfce7;color:#166534;border-color:#86efac}
/* 隐藏：灰色（可换成黄色/红色方案） */
.status-pill.is-hidden{background:#f3f4f6;color:#374151;border-color:#d1d5db}

/* footer */
.footer{display:flex;gap:16px;color:#6b7280;margin-top:8px}
</style>
