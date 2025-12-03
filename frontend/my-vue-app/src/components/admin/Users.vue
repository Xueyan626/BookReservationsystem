<template>
  <div class="container">
    <section class="page">
      <!-- header -->
      <header class="header">
        <div>
          <h1>User Management</h1>
          <p>Reset passwords and ban/unban users</p>
        </div>
      </header>

      <!-- two blocks -->
      <div class="grid">
        <!-- =========================
             Reset Password
             ========================= -->
        <section class="panel">
          <h2>Reset Password</h2>
          <div class="toolbar">
            <span>Search Username</span>
            <input v-model="qReset" type="search" placeholder="Type username..." />
            <button class="btn" @click="searchReset">Search</button>
          </div>

          <table>
            <thead>
              <tr>
                <th style="width:60%">Username</th>
                <th>Reset Password</th>
              </tr>
            </thead>
            <tbody>
            <tr v-for="u in resetUsers" :key="u.id">
              <td>
                {{ u.username }}
                <span v-if="u.banned" class="badge red">banned</span>
              </td>
              <td class="right">
                <button class="btn"
                        :disabled="busy === 'reset:'+u.id"
                        @click="reset(u.id)">
                  {{ busy === 'reset:'+u.id ? '...' : 'Reset to default' }}
                </button>
                </td>
              </tr>
              <tr v-if="!resetUsers.length">
                <td colspan="2" class="muted">No users</td>
              </tr>
            </tbody>
          </table>
        </section>

        <!-- =========================
             Ban / Unban
             ========================= -->
        <section class="panel">
          <h2>Ban/Unban Users</h2>
          <div class="toolbar">
            <span>Search Username</span>
            <input v-model="qBan" type="search" placeholder="Type username..." />
            <button class="btn" @click="searchBan">Search</button>
          </div>

          <table>
            <thead>
              <tr>
                <th style="width:60%">Username</th>
                <th>Actions</th>
              </tr>
            </thead>
            <tbody>
            <tr v-for="u in banUsers" :key="u.id">
              <td>{{ u.username }}</td>
              <td class="right">
                <button class="btn danger"
                        :disabled="u.banned || busy === 'ban:'+u.id"
                        @click="ban(u.id)">
                  {{ busy === 'ban:'+u.id ? '...' : 'Ban' }}
                </button>
                <button class="btn ghost"
                        :disabled="!u.banned || busy === 'unban:'+u.id"
                        @click="unban(u.id)">
                  {{ busy === 'unban:'+u.id ? '...' : 'Unban' }}
                </button>
                </td>
              </tr>
              <tr v-if="!banUsers.length">
                <td colspan="2" class="muted">No users</td>
              </tr>
            </tbody>
          </table>
        </section>
      </div>
    </section>
  </div>
</template>

<script setup>
// -----------------------------
// imports
// -----------------------------
import { ref, computed, onMounted } from 'vue'
import { UsersAPI } from '../../api/api'   // provides list/reset/ban/unban

// -----------------------------
// state
// -----------------------------
const resetUsers = ref([])
const banUsers   = ref([])

const qReset = ref('')         // search for reset table
const qBan = ref('')           // search for ban table
const busy = ref('')           // small busy flag for row actions

async function searchReset() {
  try {
    const list = await UsersAPI.search(qReset.value)
    resetUsers.value = normalize(list)
  } catch (e) {
    alert('Search failed: ' + (e.message || e))
  }
}

async function searchBan() {
  try {
    const list = await UsersAPI.search(qBan.value)
    banUsers.value = normalize(list)
  } catch (e) {
    alert('Search failed: ' + (e.message || e))
  }
}

async function reset(userId) {
  busy.value = 'reset:' + userId
  try {
    await UsersAPI.reset(userId)  // POST /api/admin/users/{userId}/reset-password
  } catch (e) {
    alert('Reset failed: ' + (e.message || e))
  } finally {
    busy.value = ''
  }
}

async function ban(userId) {
  busy.value = 'ban:' + userId
  try {
    await UsersAPI.ban(userId)    // PATCH /api/admin/users/{id}/ban
    const u = banUsers.value.find(x => x.id === userId)
    if (u) u.banned = true
  } catch (e) {
    alert('Ban failed: ' + (e.message || e))
  } finally {
    busy.value = ''
  }
}

async function unban(userId) {
  busy.value = 'unban:' + userId
  try {
    await UsersAPI.unban(userId)  // PATCH /api/admin/users/{id}/unban
    const u = banUsers.value.find(x => x.id === userId)
    if (u) u.banned = false
  } catch (e) {
    alert('Unban failed: ' + (e.message || e))
  } finally {
    busy.value = ''
  }
}

function toBooleanFlag(value) {
  if (typeof value === 'boolean') return value
  if (typeof value === 'number') {
    if (Number.isNaN(value)) return undefined
    return value !== 0
  }
  if (typeof value === 'string') {
    const normalized = value.trim().toLowerCase()
    if (!normalized) return undefined
    if ([
      'true', '1', 'yes', 'y', 'active', 'enabled', 'valid', 'available', 'open', 'unlocked'
    ].includes(normalized)) {
      return true
    }
    if ([
      'false', '0', 'no', 'n', 'inactive', 'disabled', 'invalid', 'blocked', 'banned', 'locked', 'closed'
    ].includes(normalized)) {
      return false
    }
  }
  return undefined
}

function normalize(raw) {
  const arr = Array.isArray(raw) ? raw : (Array.isArray(raw?.data) ? raw.data : [])
  return arr
      .map(item => {
        const id = item.id ?? item.userId ?? item.uid
        const username = item.username ?? item.nickname ?? item.name

        const bannedFlag = toBooleanFlag(item.banned ?? item.isBanned ?? item.suspended ?? item.locked ?? item.disabled)
        const activeFlag = toBooleanFlag(item.isActive ?? item.active ?? item.enabled ?? item.status ?? item.state)

        const banned = bannedFlag !== undefined
            ? bannedFlag
            : (activeFlag !== undefined ? !activeFlag : false)

        return {
          id,
          username,
          banned,
        }
      })
      .filter(x => x.id && x.username)
}
</script>

<style scoped>
/* layout inside page */
.container{max-width:1120px;margin:0 auto;padding:24px}
.page{background:#f2f3f5;border:1px solid #e5e7eb;border-radius:20px;padding:20px}

/* header */
.header{display:flex;align-items:center;justify-content:space-between;margin-bottom:8px}
h1{margin:0 0 6px;font-size:22px}
.header p{margin:0;color:#6b7280}

/* two panels */
.grid{display:grid;grid-template-columns:1fr 1fr;gap:28px;margin-top:18px}
@media (max-width:980px){.grid{grid-template-columns:1fr}}

.panel{background:#fff;border:1px solid #e5e7eb;border-radius:14px;padding:16px}
.panel h2{margin:4px 0 14px;text-align:center;font-size:20px}

/* toolbar */
.toolbar{display:flex;gap:8px;justify-content:center;align-items:center;margin-bottom:10px}
.toolbar input{width:280px;max-width:60%;padding:8px 10px;border:1px solid #e5e7eb;border-radius:8px;background:#fff}

/* table */
table{width:100%;border-collapse:collapse;border:1px solid #e5e7eb;border-radius:10px;overflow:hidden}
th,td{padding:10px 12px;border-bottom:1px solid #e5e7eb;text-align:left}
th{background:#f2f3f5;color:#555;font-weight:700}
tr:hover{background:#fafafa}

/* buttons / badges */
.btn{padding:8px 12px;border-radius:8px;border:1px solid transparent;cursor:pointer;background:#e5e7eb}
.btn.ghost{background:#eef2ff;color:#4338ca}
.btn.danger{background:#e35d5d;color:#fff}
.btn[disabled]{opacity:.6;cursor:not-allowed}
.right{display:flex;gap:8px;justify-content:flex-start}
.muted{color:#6b7280;text-align:center;padding:16px}
.badge{display:inline-block;padding:2px 8px;border-radius:999px;background:#f3f4f6;font-size:12px}
.badge.red{background:#fee2e2;color:#b91c1c}
</style>
  