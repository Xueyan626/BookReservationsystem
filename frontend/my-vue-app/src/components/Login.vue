<template>
  <div class="flex items-center justify-center relative overflow-hidden min-h-screen" style="font-family: 'Noto Sans SC', sans-serif; background-color: #f7f9fc;">
    <div class="container mx-auto" style="width: 750px;">
      <div class="flex flex-col-reverse md:flex-row rounded-2xl overflow-hidden login-card shadow-xl">
        <!-- Login -->
        <div class="w-full md:w-7/12 p-3 sm:p-6 md:p-8">
          <div class="mb-3 sm:mb-4">
            <div class="flex items-center mb-2">
              <iconify-icon icon="solar:book-2-bold" width="28" height="28" class="text-indigo-600 mr-2"></iconify-icon>
              <h2 class="font-bold text-gray-800" style="font-size: 18px;">Library Reservation System</h2>
            </div>
            <p class="text-gray-500 text-sm">Welcome back, please log in to your account</p>
          </div>

          <!-- Role selection -->
          <div class="mb-4">
            <p class="text-gray-700 font-medium mb-2 text-sm" style="margin-bottom: 10px;">Please select your login identity:</p>
            <div class="grid grid-cols-2 gap-2">
              <div class="role-selector">
                <input
                    type="radio"
                    name="role"
                    id="user-role"
                    v-model="selectedRole"
                    value="user"
                />
                <label for="user-role" class="rounded-lg">
                  <div class="icon-wrapper">
                    <iconify-icon icon="solar:user-bold" width="18" height="18"></iconify-icon>
                  </div>
                  <span class="font-medium text-sm">User</span>
                </label>
              </div>

              <div class="role-selector">
                <input
                    type="radio"
                    name="role"
                    id="admin-role"
                    v-model="selectedRole"
                    value="admin"
                />
                <label for="admin-role" class="rounded-lg">
                  <div class="icon-wrapper">
                    <iconify-icon icon="solar:shield-user-bold" width="18" height="18"></iconify-icon>
                  </div>
                  <span class="font-medium text-sm">Admin</span>
                </label>
              </div>
            </div>
          </div>

          <form @submit.prevent="handleLogin" class="space-y-3">
            <div>
              <label for="email" class="block text-xs font-medium text-gray-700 mb-1">Email</label>
              <div class="flex space-x-2">
                <div class="relative flex-1">
                  <div class="absolute inset-y-0 left-0 pl-3 flex items-center pointer-events-none">
                    <iconify-icon icon="solar:user-outline" width="18" height="18" class="text-gray-400"></iconify-icon>
                  </div>
                  <input
                      type="email"
                      id="email"
                      v-model="email"
                      class="input-field pl-10 pr-3 py-2 w-full rounded-lg focus:outline-none text-sm"
                      placeholder="Enter your email address"
                  />
                </div>
                <!-- User role: Send verification code button -->
                <button
                    v-if="selectedRole === 'user'"
                    type="button"
                    @click="sendVerificationCode"
                    :disabled="!email || isSendingCode || countdown > 0"
                    class="verification-btn px-4 py-2 rounded-lg text-sm font-medium transition-colors"
                    :class="[
                    (!email || isSendingCode || countdown > 0)
                      ? 'bg-gray-300 text-gray-500 cursor-not-allowed'
                      : 'bg-indigo-600 text-white hover:bg-indigo-700'
                  ]"
                >
                  <span v-if="isSendingCode">Sending...</span>
                  <span v-else-if="countdown > 0">{{ countdown }}s</span>
                  <span v-else>Send Code</span>
                </button>
              </div>
            </div>

            <!-- User role: Verification code input -->
            <div v-if="selectedRole === 'user'">
              <label for="verification-code" class="block text-xs font-medium text-gray-700 mb-1">Verification Code</label>
              <div class="relative">
                <div class="absolute inset-y-0 left-0 pl-3 flex items-center pointer-events-none">
                  <iconify-icon icon="solar:shield-check-outline" width="18" height="18" class="text-gray-400"></iconify-icon>
                </div>
                <input
                    type="text"
                    id="verification-code"
                    v-model="verificationCode"
                    class="input-field pl-10 pr-3 py-2 w-full rounded-lg focus:outline-none text-sm"
                    placeholder="Enter verification code"
                    maxlength="6"
                />
              </div>
            </div>

            <!-- Admin or User role: Password input -->
            <div v-if="selectedRole === 'admin' || selectedRole === 'user'">
              <label for="password" class="block text-xs font-medium text-gray-700 mb-1">
                {{ selectedRole === 'user' ? 'Password' : 'Admin Password' }}
              </label>
              <div class="relative">
                <div class="absolute inset-y-0 left-0 pl-3 flex items-center pointer-events-none">
                  <iconify-icon icon="solar:lock-outline" width="18" height="18" class="text-gray-400"></iconify-icon>
                </div>
                <input
                    type="password"
                    id="password"
                    v-model="password"
                    class="input-field pl-10 pr-3 py-2 w-full rounded-lg focus:outline-none text-sm"
                    :placeholder="selectedRole === 'user' ? 'Enter your password' : 'Enter admin password'"
                />
              </div>
            </div>

            <div class="flex items-center justify-between">
              <a href="#" @click="forgetPassword" class="text-xs font-medium text-indigo-600 hover:text-indigo-500">Forgot password?</a>
            </div>

            <div style="margin-top: 15px;">
              <button type="submit"
                      :disabled="isLoading"
                      :class="[
                  'w-full py-2 px-4 rounded-lg text-white font-medium text-sm transition-colors disabled:opacity-60 disabled:cursor-not-allowed',
                  'btn-primary'
                ]"
              >
                <span v-if="isLoading">Signing in...</span>
                <span v-else>{{ loginButtonText }}</span>
              </button>
            </div>
          </form>

          <div class="mt-4 text-center" style="margin-top: 7px;">
            <p class="text-xs text-gray-600">
              Don't have an account yet?
              <a href="#" @click="$emit('switchToRegister')" class="font-medium text-indigo-600 hover:text-indigo-500">Register now</a>
            </p>
          </div>
        </div>

        <!-- Illustration (right side) -->
        <div class="w-full md:w-5/12 bg-indigo-500 p-4 sm:p-6 md:p-8 flex items-center justify-center">
          <div class="text-center login-animation">
            <img id="1" src="../assets/img/login1.jpeg" class="w-full max-w-sm mx-auto mb-3 sm:mb-4" />
            <h2 class="text-lg sm:text-xl font-bold text-white mb-2 sm:mb-3">Library Reservation System</h2>
            <p class="text-indigo-100 mb-4 sm:mb-6 max-w-md mx-auto text-sm sm:text-base">Books are the ladder of human progress</p>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script>
import { ref, computed } from 'vue'
import { useRouter } from 'vue-router'

// API service class
class AuthService {
  constructor() {
    this.API_BASE = import.meta.env.VITE_API_BASE || 'http://localhost:8080'
  }

  async request(path, { method = 'GET', body } = {}) {
    const url = new URL(this.API_BASE + path, window.location.origin)

    const res = await fetch(url, {
      method,
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json'
      },
      body: body ? JSON.stringify(body) : undefined
    })

    if (!res.ok) {
      const text = await res.text().catch(() => '')
      throw new Error(`HTTP ${res.status} ${res.statusText} – ${text}`)
    }

    if (res.status === 204) return null
    return res.json()
  }

  // User login
  // async userLogin(data) {
  //   return this.request('/login_user', { method: 'POST', body: data })
  // }

  // Admin login
  async adminLogin(data) {
    return this.request('/api/admin/auth/login', { method: 'POST', body: data })
  }

  // Send user email verification code
  async sendUserVerificationCode(email) {
    return this.request('/api/auth/login/request-code', { method: 'POST', body: { email } })
  }

  // User verification code login
  async userLoginWithCode(data) {
    return this.request('/api/auth/login/verify', { method: 'POST', body: data })
  }
}

function buildNormalizedUser(resp, fallbackEmail, role) {
  // Possible wrapper layers: user / admin / administrator / data / top level
  const raw =
      resp?.user ??
      resp?.admin ??
      resp?.administrator ??
      resp?.data ??
      resp ??
      {};

  // First get by common keys (for user)
  let userId = raw.userId ?? raw.id ?? raw.user_id ?? null;

  // If admin, add fallback for common admin keys
  if (role === 'admin') {
    userId =
        userId ??
        raw.adminId ??
        raw.administratorId ??
        raw.administrator_id ??
        resp?.adminId ??
        resp?.administratorId ??
        resp?.administrator_id ??
        null;
  }

  const displayName =
      raw.nickname ?? raw.name ?? raw.username ?? (role === 'admin' ? 'Admin' : 'User');

  return {
    userId,                                  // Key: now admin can also be correctly identified
    email:   raw.email ?? fallbackEmail ?? null,
    nickname: displayName,
    name:     displayName,
    avatar:   raw.avatar ?? null,
    role
  };
}


function saveSession(resp, fallbackEmail, role) {
  const normalized = buildNormalizedUser(resp, fallbackEmail, role)
  if (normalized.userId == null) {
    // Don't continue navigation, throw error directly to avoid subsequent "user_id is empty"
    throw new Error('Login succeeded but userId is missing in response')
  }
  try {
    if (resp?.token) localStorage.setItem('token', resp.token)
    localStorage.setItem('userSession', JSON.stringify(normalized))
  } catch (e) {
    console.warn('Failed to write localStorage:', e)
  }
  return normalized
}


export default {
  name: 'Login',
  emits: ['switchToRegister', 'loginSuccess'],
  setup(props, { emit }) {
    const router = useRouter()
    // Reactive data
    const email = ref('')
    const password = ref('')
    const selectedRole = ref('user')
    const isLoading = ref(false)
    const errorMessage = ref('')
    const verificationCode = ref('')
    const challengeToken = ref('')
    const isSendingCode = ref(false)
    const countdown = ref(0)

    // Initialize API service
    const authService = new AuthService()

    // Computed properties
    const loginButtonText = computed(() => {
      if (isLoading.value) {
        return 'Signing in...'
      }
      return selectedRole.value === 'admin' ? 'Admin Login' : 'User Login'
    })

    // Send verification code method
    const sendVerificationCode = async () => {
      if (selectedRole.value !== 'user') {
        alert('Verification code is only required for User login.')
        return
      }
      if (!email.value) {
        alert('Please enter your email address first')
        return
      }

      try {
        isSendingCode.value = true
        const resp = await authService.sendUserVerificationCode(email.value)
        // If backend returns challengeToken, store it
        challengeToken.value = resp?.challengeToken || ''

        // 60s countdown
        countdown.value = 60
        const timer = setInterval(() => {
          countdown.value--
          if (countdown.value <= 0) clearInterval(timer)
        }, 1000)

        alert('Verification code has been sent to your email, please check')
      } catch (err) {
        // Try to parse and display JSON errors from backend
        let msg = err?.message || 'Failed to send verification code, please try again'
        try {
          const m = /–\s*(\{.*\})$/.exec(msg)
          if (m) {
            const j = JSON.parse(m[1])
            msg = j.message || msg
          }
        } catch {}
        console.error('Send code failed:', err)
        alert(msg)
      } finally {
        isSendingCode.value = false
      }
    }

    // Login method
    const handleLogin = async () => {
      // Basic validation
      if (!email.value || !password.value) {
        alert('Please fill in your email and password')
        return
      }
      // User role requires verification code
      if (selectedRole.value === 'user' && !verificationCode.value) {
        alert('Please enter the verification code')
        return
      }

      try {
        isLoading.value = true
        errorMessage.value = ''

        let response
        if (selectedRole.value === 'admin') {
          // Admin login
          const payload = {
            email: email.value,
            password: password.value,
            code: verificationCode.value,
            challengeToken: challengeToken.value
          }
          response = await authService.adminLogin(payload)
        } else {
          // User verification code login (field names must align with backend DTO)
          const payload = {
            challengeToken: challengeToken.value,
            code: verificationCode.value,
            email: email.value,
            password: password.value
          }
          response = await authService.userLoginWithCode(payload)
        }

        // Unified session saving (ensure userId is written to localStorage)
        const normalizedUser = saveSession(response, email.value, selectedRole.value)

        // Report to parent component
        emit('loginSuccess', normalizedUser)

        // Navigate
        if (selectedRole.value === 'admin') {
          router.push({ name: 'admin-books' })
        } else {
          router.push('/user')
        }
        console.log('Login successful', normalizedUser)
      } catch (err) {
        console.error('Login error:', err)
        const text = err?.message || 'Login failed, please check your credentials and try again.'
        alert(text)
      } finally {
        isLoading.value = false
      }
    }


    const forgetPassword = () => {
      alert("Use the email of the registered account to contact the administrator to reset the password. The administrator's email is zhoushengqi414@gmail.com")
    }

    return {
      email,
      password,
      selectedRole,
      loginButtonText,
      isLoading,
      errorMessage,
      verificationCode,
      isSendingCode,
      countdown,
      handleLogin,
      sendVerificationCode,
      forgetPassword
    }
  }
}
</script>

<style scoped>
@import url('https://fonts.googleapis.com/css2?family=Noto+Sans+SC:wght@300;400;500;700&display=swap');

.login-card {
  box-shadow: 0 10px 25px rgba(0, 0, 0, 0.05);
  background-image: linear-gradient(to right bottom, #ffffff, #f9fbff);
  transition: all 0.3s ease;
}

.login-card:hover {
  box-shadow: 0 15px 30px rgba(0, 0, 0, 0.08);
  transform: translateY(-5px);
}

.input-field {
  transition: all 0.3s ease;
  border: 1px solid #e5e7eb;
}

.input-field:focus {
  border-color: #4f46e5;
  box-shadow: 0 0 0 4px rgba(79, 70, 229, 0.1);
}

.btn-primary {
  background-color: #4f46e5;
  transition: all 0.3s ease;
}

.btn-primary:hover {
  background-color: #4338ca;
  transform: translateY(-2px);
}

.btn-primary:active {
  transform: translateY(0);
}

.role-selector {
  position: relative;
  overflow: hidden;
  transition: all 0.3s ease;
}

.role-selector input[type="radio"] {
  position: absolute;
  opacity: 0;
  width: 0;
  height: 0;
}

.role-selector label {
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  padding: 1rem;
  border-radius: 0.5rem;
  border: 2px solid transparent;
  cursor: pointer;
  transition: all 0.3s ease;
}

.role-selector input[type="radio"]:checked + label {
  border-color: #4f46e5;
  background-color: rgba(79, 70, 229, 0.05);
}

.role-selector label:hover {
  background-color: rgba(79, 70, 229, 0.03);
}

.role-selector .icon-wrapper {
  width: 50px;
  height: 50px;
  border-radius: 50%;
  display: flex;
  align-items: center;
  justify-content: center;
  margin-bottom: 0.5rem;
  transition: all 0.3s ease;
}

.role-selector input[type="radio"]:checked + label .icon-wrapper {
  background-color: #4f46e5;
  color: white;
}

.role-selector label .icon-wrapper {
  background-color: #f3f4f6;
  color: #4b5563;
}

.verification-btn {
  min-width: 120px;
  white-space: nowrap;
  transition: all 0.3s ease;
}

.verification-btn:not(:disabled):hover {
  transform: translateY(-1px);
  box-shadow: 0 4px 8px rgba(79, 70, 229, 0.2);
}
</style>