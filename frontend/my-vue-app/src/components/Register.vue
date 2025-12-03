<template>
  <div class="min-h-screen flex items-center justify-center px-3 sm:px-6 py-4 sm:py-8 relative overflow-hidden" style="font-family: 'Noto Sans SC', sans-serif; background-color: #f7f9fc;">
    <div class="container mx-auto" style="width: 870px;">
      <div class="flex flex-col-reverse md:flex-row rounded-2xl overflow-hidden register-card shadow-xl">
        <!-- Register -->
        <div class="w-full md:w-7/12 p-3 sm:p-6 md:p-8">
          <div class="mb-3 sm:mb-4">
            <div class="flex items-center mb-2">
              <iconify-icon icon="solar:book-2-bold" width="28" height="28" class="text-indigo-600 mr-2"></iconify-icon>
              <h2 class="font-bold text-gray-800" style="font-size: 18px;">Library Reservation System</h2>
            </div>
            <p class="text-gray-500 text-sm">Create your account and start your learning journey</p>
          </div>

          <form @submit.prevent="handleRegister" class="space-y-3">
            <div>
              <label for="username" class="block text-xs font-medium text-gray-700 mb-1">Nickname</label>
              <div class="relative">
                <div class="absolute inset-y-0 left-0 pl-3 flex items-center pointer-events-none">
                  <iconify-icon icon="solar:user-outline" width="18" height="18" class="text-gray-400"></iconify-icon>
                </div>
                <input 
                  type="text" 
                  id="username" 
                  v-model="formData.username"
                  class="input-field pl-10 pr-3 py-2 w-full rounded-lg focus:outline-none text-sm" 
                  placeholder="Please enter your nickname"
                />
              </div>
            </div>
            
            <div>
              <label for="email" class="block text-xs font-medium text-gray-700 mb-1">Email</label>
              <div class="flex gap-2">
                <div class="relative flex-1">
                  <div class="absolute inset-y-0 left-0 pl-3 flex items-center pointer-events-none">
                    <iconify-icon icon="solar:letter-outline" width="18" height="18" class="text-gray-400"></iconify-icon>
                  </div>
                  <input 
                    type="email" 
                    id="email" 
                    v-model="formData.email"
                    class="input-field pl-10 pr-3 py-2 w-full rounded-lg focus:outline-none text-sm" 
                    placeholder="example@domain.com"
                  />
                </div>
                <button 
                  type="button" 
                  @click="sendVerificationCode"
                  :disabled="isCountingDown"
                  class="verification-btn px-3 py-2 rounded-lg text-xs font-medium border border-indigo-600 text-indigo-600 hover:bg-indigo-50 focus:outline-none focus:ring-2 focus:ring-indigo-500 focus:ring-offset-2 transition-all duration-200 whitespace-nowrap"
                >
                  {{ verificationButtonText }}
                </button>
              </div>
            </div>
            
            <div>
              <label for="verification-code" class="block text-xs font-medium text-gray-700 mb-1">Verification Code</label>
              <div class="relative">
                <div class="absolute inset-y-0 left-0 pl-3 flex items-center pointer-events-none">
                  <iconify-icon icon="solar:shield-check-outline" width="18" height="18" class="text-gray-400"></iconify-icon>
                </div>
                <input 
                  type="text" 
                  id="verification-code" 
                  v-model="formData.verificationCode"
                  :class="verificationCodeClass"
                  class="input-field pl-10 pr-3 py-2 w-full rounded-lg focus:outline-none text-sm" 
                  placeholder="Please enter the 6-digit verification code"
                  maxlength="6"
                />
              </div>
            </div>

            <div>
              <label for="phone" class="block text-xs font-medium text-gray-700 mb-1">Phone</label>
              <div class="relative">
                <div class="absolute inset-y-0 left-0 pl-3 flex items-center pointer-events-none">
                  <iconify-icon icon="solar:phone-outline" width="18" height="18" class="text-gray-400"></iconify-icon>
                </div>
                <input 
                  type="tel" 
                  id="phone" 
                  v-model="formData.phone"
                  class="input-field pl-10 pr-3 py-2 w-full rounded-lg focus:outline-none text-sm" 
                  placeholder="e.g. +61 412 345 678"
                />
              </div>
            </div>
            
            <div>
              <label for="password" class="block text-xs font-medium text-gray-700 mb-1">Password</label>
              <div class="relative">
                <div class="absolute inset-y-0 left-0 pl-3 flex items-center pointer-events-none">
                  <iconify-icon icon="solar:lock-outline" width="18" height="18" class="text-gray-400"></iconify-icon>
                </div>
                <input 
                  :type="showPassword ? 'text' : 'password'" 
                  id="password" 
                  v-model="formData.password"
                  @input="checkPasswordStrength"
                  class="input-field pl-10 pr-10 py-2 w-full rounded-lg focus:outline-none text-sm" 
                  placeholder="Please set your password"
                />
                <div class="absolute inset-y-0 right-0 pr-3 flex items-center">
                  <button 
                    type="button" 
                    @click="togglePasswordVisibility"
                    class="text-gray-400 hover:text-gray-500 focus:outline-none"
                  >
                    <iconify-icon 
                      :icon="showPassword ? 'solar:eye-closed-outline' : 'solar:eye-outline'" 
                      width="18" 
                      height="18"
                    ></iconify-icon>
                  </button>
                </div>
              </div>
              <div class="password-strength mt-2">
                <div 
                  class="password-strength-indicator" 
                  :class="passwordStrengthClass"
                  :style="{ width: passwordStrengthWidth + '%' }"
                ></div>
              </div>
              <p class="text-xs text-gray-500 mt-1">Password must contain at least 8 characters, one uppercase letter and one number</p>
            </div>
            
            <div>
              <label for="confirm-password" class="block text-xs font-medium text-gray-700 mb-1">Confirm Password</label>
              <div class="relative">
                <div class="absolute inset-y-0 left-0 pl-3 flex items-center pointer-events-none">
                  <iconify-icon icon="solar:lock-keyhole-outline" width="18" height="18" class="text-gray-400"></iconify-icon>
                </div>
                <input 
                  type="password" 
                  id="confirm-password" 
                  v-model="formData.confirmPassword"
                  :class="confirmPasswordClass"
                  class="input-field pl-10 pr-3 py-2 w-full rounded-lg focus:outline-none text-sm" 
                  placeholder="Please enter your password again"
                />
              </div>
            </div>
            
            <div class="flex items-start mt-2">
              <div class="flex items-center h-5">
                <input 
                  id="terms" 
                  v-model="formData.acceptTerms"
                  type="checkbox" 
                  class="focus:ring-indigo-500 h-4 w-4 text-indigo-600 border-gray-300 rounded"
                />
              </div>
              <div class="ml-3 text-xs">
                <label for="terms" class="font-medium text-gray-700">I have read and agree </label>
                <a href="#" class="text-indigo-600 hover:text-indigo-500 font-medium">User Agreement</a>
                <span class="text-gray-700"> and </span>
                <a href="#" class="text-indigo-600 hover:text-indigo-500 font-medium">Privacy Policy</a>
              </div>
            </div>
        
            <button 
              type="submit" 
              class="btn-primary w-full py-2 px-4 rounded-lg text-white font-medium text-sm mt-3"
            >
              Create an account
            </button>
          </form>

          <div class="mt-4 text-center" style="margin-top: 7px;">
            <p class="text-xs text-gray-600">
              Already have an account?
              <a href="#" @click="$emit('switchToLogin')" class="font-medium text-indigo-600 hover:text-indigo-500">Login</a>
            </p>
          </div>
        </div>
        
        <!-- Illustration (right side) -->
        <div class="w-full md:w-6/12 bg-indigo-500 p-4 sm:p-6 md:p-8 flex items-center justify-center">
          <div class="text-center register-animation">
            <img id="1" src="../assets/img/register1.jpeg" class="w-full max-w-sm mx-auto mb-3 sm:mb-4" />
            <h2 class="text-lg sm:text-xl font-bold text-white mb-2 sm:mb-3">Library Reservation System</h2>
            <p class="text-indigo-100 mb-3 sm:mb-4 max-w-md mx-auto text-xs sm:text-sm">After creating an account, you can discover, share and trade high-quality books to help you learn and grow</p>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script>
import { ref, computed, reactive } from 'vue'

// API service class
class RegisterService {
  constructor() {
    this.API_BASE = import.meta.env.VITE_API_BASE || 'http://localhost:8080'
  }

  async request(path, { method = 'GET', body } = {}) {
    // Build complete URL
    let url
    if (this.API_BASE.startsWith('http://') || this.API_BASE.startsWith('https://')) {
      // Absolute URL, direct concatenation
      url = new URL(path.startsWith('/') ? path : '/' + path, this.API_BASE)
    } else {
      // Relative path, use current origin
      url = new URL(path.startsWith('/') ? path : '/' + path, window.location.origin)
    }
    
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

  // Send verification code
  async sendCode(data) {
    return this.request('/api/auth/register/start', { method: 'POST', body: data })
  }

  // User registration
  async userRegister(data) {
    return this.request('/api/auth/register/submit', { method: 'POST', body: data })
  }
}

export default {
  name: 'Register',
  emits: ['switchToLogin', 'registerSuccess'],
  setup(props, { emit }) {
    // Reactive data
    const formData = reactive({
      username: '',
      email: '',
      verificationCode: '',
      phone: '',
      password: '',
      confirmPassword: '',
      acceptTerms: false
    })

    const showPassword = ref(false)
    const passwordStrength = ref(0)
    const isCountingDown = ref(false)
    const countdown = ref(60)
    // const generatedVerificationCode = ref('')
    const challengeToken = ref('')
    const isCodeSent = ref(false)
    const isLoading = ref(false)

    // Initialize API service
    const registerService = new RegisterService()

    // Computed properties
    const passwordStrengthWidth = computed(() => passwordStrength.value)
    
    const passwordStrengthClass = computed(() => {
      if (passwordStrength.value <= 25) return 'bg-red-400'
      if (passwordStrength.value <= 50) return 'bg-yellow-400'
      return 'bg-green-400'
    })

    const confirmPasswordClass = computed(() => {
      if (!formData.confirmPassword) return ''
      return formData.password === formData.confirmPassword ? 'border-green-300' : 'border-red-300'
    })

    const verificationCodeClass = computed(() => {
      return formData.verificationCode.length === 6 ? 'border-green-300' : ''
    })

    const verificationButtonText = computed(() => {
      if (!isCodeSent.value) return 'Verification'
      if (isCountingDown.value) return `${countdown.value}s`
      return 'Resend'
    })

    // Methods
    const togglePasswordVisibility = () => {
      showPassword.value = !showPassword.value
    }

    const checkPasswordStrength = () => {
      const password = formData.password
      let strength = 0

      if (password.length >= 8) strength += 25
      if (password.match(/[A-Z]/)) strength += 25
      if (password.match(/[0-9]/)) strength += 25
      if (password.match(/[^a-zA-Z0-9]/)) strength += 25

      passwordStrength.value = strength
    }

    const sendVerificationCode = async () => {
      const email = formData.email.trim()
      const nickname = formData.username.trim()
      const telephone = formData.phone.trim()

      // Validate email format
      const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/
      if (!email) {
        alert('Please enter your email address')
        return
      }

      if (!emailRegex.test(email)) {
        alert('Please enter the correct email format')
        return
      }

      // Validate nickname
      if (!nickname) {
        alert('Please enter your nickname')
        return
      }

      // Validate phone
      if (!telephone) {
        alert('Please enter your phone number')
        return
      }

      // Phone number format validation
      const phoneRegex = /^[+]?\d[\d\s-]{7,}$/
      if (!phoneRegex.test(telephone)) {
        alert('Please enter a valid phone number')
        return
      }

      try {
        isLoading.value = true

        // Call backend API to send verification code (backend returns challengeToken)
        // Backend requires three fields: email, nickname, telephone
        const response = await registerService.sendCode({ 
          email,
          nickname,
          telephone
        })
        challengeToken.value = response?.challengeToken || ''

        console.log('register challengeToken:', challengeToken.value)

        console.log('Verification code sent to:', email)
        alert(`Verification code has been sent to ${email}`)
        
        isCodeSent.value = true
        isCountingDown.value = true

        // Start countdown
        const timer = setInterval(() => {
          countdown.value--
          
          if (countdown.value <= 0) {
            clearInterval(timer)
            isCountingDown.value = false
            countdown.value = 60
          }
        }, 1000)

      } catch (err) {
        console.error('Send verification code error:', err)
        alert(err.message || 'Failed to send verification code')
      } finally {
        isLoading.value = false
      }
    }

    const handleRegister = async () => {
      const { username, email, password, confirmPassword, verificationCode, phone, acceptTerms } = formData

      // Form validation
      if (!username || !email || !password || !confirmPassword || !phone) {
        alert('Please fill in all required fields')
        return
      }

      // Phone number format validation
      const phoneRegex = /^[+]?\d[\d\s-]{7,}$/
      if (!phoneRegex.test(phone)) {
        alert('Please enter a valid phone number')
        return
      }

      if (!isCodeSent.value) {
        alert('Please send the email verification code first')
        return
      }

      if (!verificationCode || verificationCode.length !== 6 || !/^\d{6}$/.test(verificationCode)) {
        alert('Please enter the 6-digit verification code')
        return
      }

      if (password !== confirmPassword) {
        alert('The passwords entered twice do not match')
        return
      }

      if (!acceptTerms) {
        alert('Please read and agree to the user agreement and privacy policy')
        return
      }

      // Registration logic
      try {
        isLoading.value = true
        
        // Call backend API for user registration
        const response = await registerService.userRegister({
          nickname: username,
          email,
          telephone: phone,
          password,
          confirmPassword,
          code: verificationCode,
          challengeToken: challengeToken.value
        })

        // Save user information to localStorage (if backend returns)
        // try {
        //   if (response?.token) {
        //     localStorage.setItem('token', response.token)
        //   }
        //   if (response?.user) {
        //     localStorage.setItem('userSession', JSON.stringify(response.user))
        //   }
        // } catch (e) {
        //   console.warn('Failed to save session data:', e)
        // }
        // Save token & normalized user information (ensure userId exists)
        try {
          if (response?.token) {
            localStorage.setItem('token', response.token)
            }
          const rawUser = response?.user ?? response ?? {}
          const normalizedUser = {
              userId: rawUser.userId ?? rawUser.id ?? rawUser.user_id ?? null,
              email:  rawUser.email ?? email ?? null,
              nickname: rawUser.nickname ?? rawUser.name ?? formData.username,
              name: rawUser.nickname ?? rawUser.name ?? formData.username,
              avatar: rawUser.avatar ?? null,
              role:   'user'
          }
          localStorage.setItem('userSession', JSON.stringify(normalizedUser))
          } catch (e) {
            console.warn('Failed to save session data:', e)
        }

        console.log('Registration successful:', response)
        alert('Registration successful!')
        
        // Pass user data to parent component
        // const user = response?.user || {
        //   name: username,
        //   email: email,
        //   role: 'user',
        //   avatar: null
        // }
        // Pass user data to parent component (consistent with localStorage)
        const user = JSON.parse(localStorage.getItem('userSession')) || {
            userId: null,
            name: username,
            email: email,
            role: 'user',
            avatar: null
        }
        
        emit('registerSuccess', user)
      } catch (err) {
        console.error('Registration error:', err)
        alert(err.message || 'Registration failed, please try again')
      } finally {
        isLoading.value = false
      }
    }

    return {
      formData,
      showPassword,
      passwordStrength,
      isCountingDown,
      countdown,
      isLoading,
      passwordStrengthWidth,
      passwordStrengthClass,
      confirmPasswordClass,
      verificationCodeClass,
      verificationButtonText,
      togglePasswordVisibility,
      checkPasswordStrength,
      sendVerificationCode,
      handleRegister
    }
  }
}
</script>

<style scoped>
@import url('https://fonts.googleapis.com/css2?family=Noto+Sans+SC:wght@300;400;500;700&display=swap');

.register-card {
  box-shadow: 0 10px 25px rgba(0, 0, 0, 0.05);
  background-image: linear-gradient(to right bottom, #ffffff, #f9fbff);
  transition: all 0.3s ease;
}

.register-card:hover {
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

.register-animation {
  animation: float 3s ease-in-out infinite;
}

@keyframes float {
  0%, 100% {
    transform: translateY(0px);
  }
  50% {
    transform: translateY(-10px);
  }
}

.particles {
  position: absolute;
  width: 100%;
  height: 100%;
  z-index: -1;
}

.password-strength {
  height: 5px;
  border-radius: 2px;
  margin-top: 8px;
  transition: all 0.3s ease;
  background: #e5e7eb;
}

.password-strength-indicator {
  height: 100%;
  border-radius: 2px;
  width: 0%;
  transition: all 0.3s ease;
}

.verification-btn:disabled {
  opacity: 0.6;
  cursor: not-allowed;
  background-color: #f3f4f6;
  color: #9ca3af;
  border-color: #d1d5db;
}

.verification-btn:disabled:hover {
  background-color: #f3f4f6;
  transform: none;
}
</style>
