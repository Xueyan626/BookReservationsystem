<template>
  <aside class="sidebar">
    <nav class="side-nav" id="sideNav">
      <!-- ===== Books Group ===== -->
      <div class="group" :class="{ open: booksOpen }" id="group-books">
        <button class="group-toggle" type="button" @click="toggleBooks">
          <span>Books</span>
          <svg class="caret" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
            <path d="M6 9l6 6 6-6" />
          </svg>
        </button>

        <ul class="submenu" id="submenu-books" v-show="booksOpen">
          <li>
            <RouterLink
                :to="{ name: 'admin-books' }"
                class="submenu-link"
                :class="{ active: isActive('admin-books') }"
            >
              Book Management
            </RouterLink>
          </li>
          <li>
            <RouterLink
                :to="{ name: 'admin-labels' }"
                class="submenu-link"
                :class="{ active: isActive('admin-labels') }"
            >
              Label Management
            </RouterLink>
          </li>
        </ul>
      </div>

      <!-- ===== Other Top Links ===== -->
      <RouterLink
          :to="{ name: 'admin-reservations' }"
          class="top-link"
          :class="{ active: isActive('admin-reservations') }"
      >
        Reservation
      </RouterLink>
      <RouterLink
          :to="{ name: 'admin-comments' }"
          class="top-link"
          :class="{ active: isActive('admin-comments') }"
      >
        Comments
      </RouterLink>
      <RouterLink
          :to="{ name: 'admin-users' }"
          class="top-link"
          :class="{ active: isActive('admin-users') }"
      >
        Users
      </RouterLink>

      <!-- ===== LOG OUT ===== -->
      <button class="logout-btn" type="button" @click="handleLogout">
        <svg class="logout-icon" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
          <path d="M9 21H5a2 2 0 0 1-2-2V5a2 2 0 0 1 2-2h4" />
          <polyline points="16 17 21 12 16 7" />
          <line x1="21" y1="12" x2="9" y2="12" />
        </svg>
        LOG OUT
      </button>
    </nav>
  </aside>
</template>

<script setup>
import { ref, watch } from 'vue'
import { useRoute, useRouter } from 'vue-router'

const route = useRoute()
const router = useRouter()
const STORAGE_KEY = 'sidebar.books.open'

// restore open/close state
const booksOpen = ref(true)
try {
  const saved = JSON.parse(localStorage.getItem(STORAGE_KEY))
  if (typeof saved === 'boolean') booksOpen.value = saved
} catch {}

function toggleBooks() {
  booksOpen.value = !booksOpen.value
  try {
    localStorage.setItem(STORAGE_KEY, JSON.stringify(booksOpen.value))
  } catch {}
}

// highlight current route
// const isActive = (path) => route.path === path
const isActive = (name) => route.name === name

// // auto-open “Books” group when inside /book-management or /label-management
// watch(
//   () => route.path,
//   (newPath) => {
//     if (newPath.includes('book') || newPath.includes('label')) {
//       booksOpen.value = true
//     }
//   },
//   { immediate: true }
// )
watch(
    () => route.name,
    (n) => {
      if (n === 'admin-books' || n === 'admin-labels') booksOpen.value = true
    },
    { immediate: true }
)

// Handle logout
function handleLogout() {
  // Clear all session data
  localStorage.removeItem('token')
  localStorage.removeItem('userSession')
  localStorage.removeItem('currentPage')
  localStorage.removeItem('currentBookId')
  localStorage.removeItem('currentCategory')
  sessionStorage.clear()
  
  console.log('🧹 Cleared all admin session data')
  
  // Navigate to login page
  router.replace({ name: 'login' })
  
  // Prevent browser back navigation
  window.history.pushState(null, '', window.location.href)
  window.addEventListener('popstate', () => {
    if (!localStorage.getItem('token')) {
      router.replace({ name: 'login' })
    }
  })
}
</script>

<style scoped>
/* ——— Base layout ——— */
.sidebar {
  width: var(--sidebar-w, 240px);
  background: #fff;
  display: flex;
  flex-direction: column;
  padding: 24px 12px;
  border-right: 1px solid #e5e7eb;
  overflow-y: auto;
}

/* ——— Container ——— */
.side-nav {
  display: flex;
  flex-direction: column;
  gap: 12px;
  height: 100%;
}

/* ——— Group toggle ——— */
.group {
  padding: 6px 0;
  border-radius: 10px;
}

.group-toggle {
  width: 100%;
  background: none;
  border: none;
  cursor: pointer;
  text-align: left;
  display: flex;
  align-items: center;
  justify-content: space-between;
  padding: 10px 12px;
  border-radius: 10px;
  color: #6b7280;
  transition: background 0.2s;
}

.group-toggle:hover {
  background: #f9fafb;
}

.caret {
  width: 16px;
  height: 16px;
  transform: rotate(0deg);
  transition: transform 0.25s ease;
}

.group.open .caret {
  transform: rotate(180deg);
}

/* ——— Submenu ——— */
.submenu {
  list-style: none;
  margin: 8px 0 0;
  padding: 0 0 0 8px;
}

.submenu-link {
  display: block;
  padding: 10px 12px;
  margin: 4px 8px;
  border-radius: 10px;
  color: #6b7280;
  text-decoration: none;
  transition: all 0.2s;
}

.submenu-link:hover {
  background: #f3f4f6;
}

.submenu-link.active {
  background: #2563eb;
  color: #fff;
  font-weight: 600;
}

/* ——— Top links (outside Books group) ——— */
.top-link {
  display: block;
  padding: 10px 12px;
  border-radius: 10px;
  color: #6b7280;
  text-decoration: none;
  transition: all 0.2s;
}

.top-link:hover {
  background: #f3f4f6;
}

.top-link.active {
  background: #2563eb;
  color: #fff;
  font-weight: 600;
}

/* ——— LOG OUT button ——— */
.logout-btn {
  display: flex;
  align-items: center;
  gap: 10px;
  width: 100%;
  padding: 10px 12px;
  margin-top: auto;
  border-radius: 10px;
  border: none;
  background: none;
  cursor: pointer;
  color: #dc2626;
  font-weight: 600;
  transition: all 0.2s;
}

.logout-btn:hover {
  background: #fee2e2;
  color: #b91c1c;
}

.logout-icon {
  width: 18px;
  height: 18px;
}
</style>
