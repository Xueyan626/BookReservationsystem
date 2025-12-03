<template>
  <div class="container">
    <section class="page">
      <!-- header -->
      <header class="header">
        <div>
          <h1>Label Management</h1>
          <p>Manage label categories used for organizing books</p>
        </div>

        <div class="actions">
          <input
            v-model="keyword"
            type="search"
            class="search"
            placeholder="Search by label name or ID"
          />
          <button class="btn primary" @click="openPopup()">+ New</button>
        </div>
      </header>

      <!-- table -->
      <section>
        <table>
          <thead>
            <tr>
              <th>Label ID</th>
              <th>Label Name</th>
              <th>Create Date</th>
              <th>Delete</th>
            </tr>
          </thead>

        <tbody>
          <tr v-for="l in filtered" :key="l.labelId">
            <td>{{ l.labelId }}</td>
            <td>{{ l.labelName }}</td>
            <td>{{ formatDate(l.createDate) }}</td>
            <td>
              <button class="delete-btn" @click="remove(l.labelId)">Delete</button>
            </td>
          </tr>
        </tbody>
        </table>

        <p v-if="!filtered.length" class="empty">No labels found.</p>
      </section>
    </section>

    <!-- popup -->
    <div v-if="showPopup" class="popup-backdrop" @click="closePopup">
      <div class="popup" @click.stop>
        <h3> Add Label </h3>
        <label>Label Name</label>
        <input v-model.trim="form.name" />

        <div class="actions">
          <button @click="closePopup">Cancel</button>
          <button class="btn primary" :disabled="saving" @click="save">
            {{ saving ? 'Saving...' : 'Save' }}
          </button>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
// -----------------------------
// imports
// -----------------------------
import { ref, computed, onMounted } from 'vue'
import { LabelsAPI } from '../../api/api'   // API

// -----------------------------
// state
// -----------------------------
const rows = ref([])            // all labels
const keyword = ref('')         // search keyword
const showPopup = ref(false)    // popup visible
const saving = ref(false)       // saving flag
const editingId = ref(null)     // null=new, number=edit
const form = ref({ name: '' })  // form data

// -----------------------------
// computed
// -----------------------------
const filtered = computed(() => {
  const kw = keyword.value.trim().toLowerCase()
  if (!kw) return rows.value
  return rows.value.filter((l) =>
    String(l.labelId).includes(kw) || (l.labelName || '').toLowerCase().includes(kw)
  )
})

// -----------------------------
// helpers
// -----------------------------
const formatDate = (s) => {
  if (!s) return '-'
  const d = new Date(s)
  return isNaN(d) ? '-' : d.toISOString().slice(0, 19).replace('T', ' ')
}

// -----------------------------
// crud
// -----------------------------
async function load() {
  // get label list
  const res = await LabelsAPI.list().catch(() => null)
  const data = Array.isArray(res) ? res : (res?.data || [])
  // normalize fields
  rows.value = data.map((x) => ({
    labelId: x.labelId,
    labelName: x.labelName,
    createDate: x.createDate,
  }))
}

async function save() {
  if (!form.value.name) return alert('Please enter label name.')
  saving.value = true
  try {
    await LabelsAPI.create({ labelName: form.value.name })
    await load()
    closePopup()
  } catch (e) {
    alert(e.message || 'Save failed')
  } finally {
    saving.value = false
  }
}

async function remove(id) {
  // delete label
  if (!confirm('Delete this label? This action cannot be undone.')) return
  await LabelsAPI.remove(id).catch((e) => alert(e.message || 'Delete failed'))
  rows.value = rows.value.filter((l) => String(l.labelId) !== String(id))
}

// -----------------------------
// popup
// -----------------------------
function openPopup(label = null) {
  showPopup.value = true
  form.value = { name: '' }
}

function closePopup() {
  showPopup.value = false
}

// -----------------------------
// init
// -----------------------------
onMounted(load)
</script>

<style scoped>
/* layout inside page */
.container{max-width:1120px;margin:0 auto;padding:24px}
.page{background:#f2f3f5;border:1px solid #e5e7eb;border-radius:20px;padding:20px}

/* header */
.header{display:flex;align-items:center;justify-content:space-between;margin-bottom:16px}
h1{margin:0 0 6px;font-size:22px}
.header p{margin:0;color:#6b7280}
.actions{display:flex;gap:12px;align-items:center}
.search{width:320px;max-width:48vw;padding:10px 12px;border:1px solid #e5e7eb;border-radius:12px;background:#fff}
.btn{padding:10px 14px;border-radius:12px;border:1px solid transparent;cursor:pointer}
.btn.primary{background:#2563eb;color:#fff}

/* table */
table{width:100%;border-collapse:collapse;background:#fff;border-radius:16px;overflow:hidden}
th,td{padding:12px 14px;text-align:left;border-bottom:1px solid #e5e7eb}
th{background:#f9fafb;color:#6b7280;font-weight:600;font-size:13px}
tr:hover{background:#fafafa}
.empty{color:#6b7280;text-align:center;padding:36px 0}
.delete-btn{background:#e35d5d;color:#fff;padding:6px 12px;border:none;border-radius:6px;cursor:pointer}
.delete-btn:hover{background:#c63e3e}

/* popup */
.popup-backdrop{position:fixed;inset:0;background:rgba(0,0,0,.4);display:flex;align-items:center;justify-content:center}
.popup{background:#fff;padding:16px;border-radius:10px;box-shadow:0 4px 12px rgba(0,0,0,.2);width:360px;max-width:92vw}
.popup h3{margin:0 0 10px}
.popup label{display:block;margin:8px 0 6px;font-weight:600}
.popup input,.popup textarea{width:100%;padding:8px;border:1px solid #ddd;border-radius:8px}
.actions{text-align:right;margin-top:10px}
</style>
  