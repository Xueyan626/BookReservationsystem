<template>
  <div class="container">
    <section class="page">
      <!-- Header -->
      <header class="header">
        <div>
          <h1>Book Management</h1>
          <p>Manage book information and storage</p>
        </div>

        <div class="actions">
          <input
            v-model="keyword"
            type="search"
            class="search"
            placeholder="Search by title or author"
          />
          <button class="btn primary" @click="openPopup()">+ New</button>
        </div>
      </header>

      <!-- List -->
      <section class="list">
        <article v-for="b in filteredBooks" :key="b.id" class="card">
          <img v-if="b.cover" :src="b.cover" :alt="b.title" class="cover" />
          <div v-else class="cover">{{ initials(b.title) }}</div>

          <div class="meta">
            <p class="title" :title="b.title">{{ b.title }}</p>
            <p class="sub" :title="subtitle(b)">{{ subtitle(b) }}</p>
          </div>

          <div class="ops">
            <button class="iconbtn" title="Edit" @click="openPopup(b)">✎</button>
            <button class="iconbtn danger" title="Delete" @click="deleteBook(b.id)">🗑</button>
          </div>
        </article>

        <p v-if="!filteredBooks.length" class="empty">No books found.</p>
      </section>
    </section>

    <!-- Popup -->
    <div v-if="showPopup" class="popup-backdrop" @click="closePopup">
      <div class="popup" @click.stop>
        <h3>{{ editingId ? 'Edit Book' : 'Add Book' }}</h3>

        <label>Book Name</label>
        <input v-model.trim="form.title" />

        <label>Author</label>
        <input v-model.trim="form.author" />

        <label>Quantity</label>
        <input type="number" v-model.number="form.qty" min="0" />

        <label>Label ID</label>
        <input type="number" v-model.number="form.labelId" min="0" />

        <label>Cover Image</label>
        <div class="cover-selector">
          <select v-model="form.avatar" class="cover-select">
            <option value="">Select an image...</option>
            <option v-for="img in availableImages" :key="img.path" :value="img.path">
              {{ img.name }}
            </option>
          </select>
          <div v-if="form.avatar" class="preview-container">
            <img :src="selectedImagePreview" class="preview" alt="preview"/>
            <small class="hint">{{ form.avatar }}</small>
          </div>
          <small v-else class="hint">Select an image from available covers</small>
        </div>

        <label>Description</label>
        <textarea v-model.trim="form.desc"></textarea>

        <div class="popup-actions">
          <button @click="closePopup">Cancel</button>
          <button class="primary" @click="savePopup" :disabled="saving">
            {{ saving ? 'Saving...' : 'Save' }}
          </button>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
// --- imports ---
import { ref, computed, onMounted } from 'vue'
import { BooksAPI } from '../../api/api'   // 模块化 API

// --- state ---
const books = ref([])
const keyword = ref('')
const showPopup = ref(false)
const saving = ref(false)
const editingId = ref(null)

// format data
const form = ref({ title: '', author: '', qty: 0, labelId: null, desc: '', avatar: '' })

// Available cover images from frontend assets
const availableImages = [
  { name: 'AI Health - Health Care', path: '/img/covers/ai_health.jpg' },
  { name: 'AI Law', path: '/img/covers/ai_law.jpg' },
  { name: 'AI Optimization', path: '/img/covers/ai_opt.jpg' },
  { name: 'Data Analysis', path: '/img/covers/data_analysis.jpg' },
  { name: 'Data Visualization', path: '/img/covers/dataviz.jpg' },
  { name: 'Engineering Drawing', path: '/img/covers/eng_drawing.jpg' },
  { name: 'Materials Science', path: '/img/covers/materials.jpg' },
  { name: 'Medical Imaging', path: '/img/covers/med_image.jpg' },
  { name: 'Medical Statistics', path: '/img/covers/med_stats.jpg' },
  { name: 'ML Introduction', path: '/img/covers/ml_intro.jpg' },
  { name: 'Project Management', path: '/img/covers/project_mgmt.jpg' },
  { name: 'Python Project', path: '/img/covers/python_project.jpg' },
  { name: 'Python Web', path: '/img/covers/python_web.jpg' },
  { name: 'Python 1', path: '/img/covers/python1.jpg' },
  { name: 'Python 2', path: '/img/covers/python2.jpg' }
]

// Preview selected image
const selectedImagePreview = computed(() => {
  if (!form.value.avatar) return ''
  return `/src/assets${form.value.avatar}`
})

// --- helpers ---
const initials = (s) =>
  (s || '').split(/\s+/).map(x => x[0]).filter(Boolean).slice(0, 2).join('').toUpperCase()

const subtitle = (b) =>
  `${b.author || 'Unknown'} • Stock: ${b.qty ?? 0} • Favorites: ${b.fav ?? 0} • Reservations: ${b.resv ?? 0}`

const filteredBooks = computed(() => {
  const kw = keyword.value.trim().toLowerCase()
  if (!kw) return books.value
  return books.value.filter(b =>
    (b.title || '').toLowerCase().includes(kw) ||
    (b.author || '').toLowerCase().includes(kw)
  )
})

// cover from backend
function mapRow(row) {
  const avatar = String(row.avatar || '').trim()
  let cover = ''
  if (avatar) {
    const norm = avatar.startsWith('/') ? avatar : '/' + avatar
    cover = `/src/assets${norm}`
  }
  return {
    id: row.bookId,
    title: row.bookName,
    author: row.author,
    qty: row.quantity,
    desc: row.description,
    fav: row.numFavorite,
    resv: row.numReservation,
    labelId: row.labelId,
    cover,
    rawAvatar: avatar
  }
}

// --- CRUD ---
async function loadBooks() {
  const resp = await BooksAPI.list().catch(() => null)
  const rows = Array.isArray(resp) ? resp : (resp?.data || [])
  books.value = rows.map(mapRow)
}

function openPopup(book = null) {
  showPopup.value = true
  if (book) {
    editingId.value = book.id
    form.value = {
      title: book.title || '',
      author: book.author || '',
      qty: Number(book.qty || 0),
      labelId: book.labelId ?? null,
      desc: book.desc || '',
      avatar: book.rawAvatar || ''
    }
  } else {
    editingId.value = null
    form.value = { title: '', author: '', qty: 0, labelId: null, desc: '', avatar: '' }
  }
}

function closePopup() {
  showPopup.value = false
}

async function savePopup() {
  if (!form.value.title) return alert('Please enter book name')
  saving.value = true
  try {
    const payload = {
      bookName: form.value.title,
      author: form.value.author,
      quantity: Number(form.value.qty || 0),
      labelId: form.value.labelId ?? null,
      description: form.value.desc,
      avatar: form.value.avatar || ''
    }

    if (editingId.value) {
      // edit
      await BooksAPI.update(editingId.value, payload)
    } else {
      // new create
      await BooksAPI.create(payload)
    }
    await loadBooks()
    closePopup()
  } catch (e) {
    alert(e.message || 'Save failed')
  } finally {
    saving.value = false
  }
}

async function deleteBook(id) {
  if (!confirm('Delete this book?')) return
  await BooksAPI.remove(id).catch(e => alert(e.message || 'Delete failed'))
  books.value = books.value.filter(b => String(b.id) !== String(id))
}

onMounted(loadBooks)
</script>

<style scoped>
/* layout inside page */
.container{max-width:1120px;margin:0 auto;padding:24px}
.page{background:#f2f3f5;border:1px solid #e5e7eb;border-radius:20px;padding:20px}

.header{display:flex;justify-content:space-between;align-items:center;gap:16px;margin-bottom:16px}
h1{margin:0 0 6px;font-size:22px}
.header p{margin:0;color:#6b7280}
.actions{display:flex;gap:12px;align-items:center}
.search{width:320px;max-width:48vw;padding:10px 12px;border:1px solid #e5e7eb;border-radius:12px;background:#fff}
.btn{padding:10px 14px;border-radius:12px;border:1px solid transparent;cursor:pointer}
.btn.primary{background:#2563eb;color:#fff}

/* list */
.list{display:flex;flex-direction:column;gap:18px}
.card{display:flex;gap:16px;align-items:center;background:#fff;border:1px solid #e5e7eb;border-radius:16px;padding:16px}
.cover{width:64px;height:88px;border-radius:10px;background:#e5e7eb;display:flex;align-items:center;justify-content:center;font-weight:700;color:#4b5563;object-fit:cover;overflow:hidden}
.meta{min-width:0;flex:1}
.title{font-weight:600;margin:0 0 6px;white-space:nowrap;overflow:hidden;text-overflow:ellipsis}
.sub{margin:0;color:#6b7280;white-space:nowrap;overflow:hidden;text-overflow:ellipsis}
.ops{display:flex;gap:8px}
.iconbtn{background:#fff;border:1px solid #e5e7eb;border-radius:10px;padding:8px;cursor:pointer}
.iconbtn.danger{border-color:#fecaca}

/* empty */
.empty{color:#6b7280;text-align:center;padding:36px 0}

/* popup */
.popup-backdrop{position:fixed;inset:0;background:rgba(0,0,0,.4);display:flex;align-items:center;justify-content:center}
.popup{background:#fff;padding:16px;border-radius:10px;box-shadow:0 4px 12px rgba(0,0,0,.2);width:360px;max-width:92vw}
.popup h3{margin:0 0 10px}
.popup label{display:block;margin:8px 0 6px;font-weight:600}
.popup input,.popup textarea{width:100%;padding:8px;border:1px solid #ddd;border-radius:8px}
.popup textarea{resize:vertical;min-height:64px}
.cover-selector{display:flex;flex-direction:column;gap:10px}
.cover-select{width:100%;padding:8px;border:1px solid #ddd;border-radius:8px}
.preview-container{display:flex;gap:12px;align-items:center}
.preview{width:80px;height:88px;border-radius:8px;object-fit:cover;border:1px solid #e5e7eb}
.hint{color:#9ca3af;font-size:12px}
.popup-actions{display:flex;justify-content:flex-end;gap:8px;margin-top:12px}
.popup-actions .primary{background:#2563eb;color:#fff;border:1px solid transparent;border-radius:8px;padding:8px 12px}
</style>
