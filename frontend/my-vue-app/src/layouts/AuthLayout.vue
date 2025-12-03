<script setup>
import { computed, reactive, onMounted } from 'vue'
import { useRouter, useRoute } from 'vue-router'
import Login from '@/components/Login.vue'
import Register from '@/components/Register.vue'
import UserHead from '@/components/user/UserHead.vue'

// Simple "state" stored here (you can also use Pinia)
const state = reactive({
  user: null,
  isAuthenticated: false,
})

const router = useRouter()
const route = useRoute()

// Current sub-route: /login | /register | /user
const name = computed(() => route.name)

// Restore user state from localStorage
const restoreUserSession = () => {
  try {
    const session = JSON.parse(localStorage.getItem('userSession') || '{}')
    if (session && session.userId && session.nickname) {
      state.user = {
        name: session.nickname,
        email: session.email,
        userId: session.userId,
        role: session.role || 'user',
        ...session
      }
      state.isAuthenticated = true
      console.log('📱 Restored user session from localStorage:', session.nickname)
    }
  } catch (error) {
    console.warn('Failed to restore user session:', error)
  }
}

// Restore user state on page load
onMounted(() => {
  restoreUserSession()
})

function toLogin() { router.push({ name: 'login' }) }
function toRegister() { router.push({ name: 'register' }) }
function toUserHome(user) {
  if (user) {
    state.user = user
    state.isAuthenticated = true
  }
  router.push({ name: 'user' })
}

function handleLoginSuccess(userData) {
  const user = userData || { name: 'Kirin', email: 'kirin@example.com', role: 'user' }
  state.user = user
  state.isAuthenticated = true
  try { sessionStorage.setItem('user', JSON.stringify(user)) } catch {}

  // Key: Navigate based on role
  if (user.role === 'admin') {
    router.replace({ name: 'admin-books' })
  } else {
    router.replace({ name: 'user' })
  }
}
function handleRegisterSuccess(userData) {
  toUserHome(userData || { name: 'New User', email: 'user@example.com', role: 'user' })
}
function handleLogout() {
  // Clear user state
  state.user = null
  state.isAuthenticated = false
  
  // Clear all session and state information in localStorage
  try {
    localStorage.removeItem('userSession')
    localStorage.removeItem('token')
    localStorage.removeItem('currentPage')
    localStorage.removeItem('currentBookId')
    localStorage.removeItem('currentCategory')
    sessionStorage.clear()
    
    console.log('🧹 Cleared all user session data')
  } catch (error) {
    console.warn('Failed to clear storage:', error)
  }
  
  // Use router.replace instead of push to prevent browser back navigation
  router.replace({ name: 'login' })
  
  // Prevent browser back function, force redirect
  window.history.pushState(null, '', window.location.href)
  window.addEventListener('popstate', () => {
    if (!state.isAuthenticated) {
      router.replace({ name: 'login' })
    }
  })
}
</script>

<template>
  <div class="app-container">
    <main class="app-main">
      <Login
        v-if="name === 'login'"
        @switchToRegister="toRegister"
        @loginSuccess="handleLoginSuccess"
      />
      <Register
        v-else-if="name === 'register'"
        @switchToLogin="toLogin"
        @registerSuccess="handleRegisterSuccess"
      />
      <UserHead
        v-else-if="name === 'user'"
        :user="state.user"
        @logout="handleLogout"
      />
      <!-- Fallback: return to login when no match -->
      <div v-else>
        <p class="text-sm text-gray-500">Redirecting...</p>
      </div>
    </main>
  </div>
</template>

<style scoped>
.app-main { min-height: 100vh; background: #fff; }
</style>
