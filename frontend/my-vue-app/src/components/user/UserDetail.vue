<template>
  <div class="h-full bg-gray-50 overflow-y-auto" style="font-family: 'Noto Sans SC', sans-serif; background-color: #f7f9fc;">
    <main class="p-4 lg:p-6">
      <div class="container mx-auto">
        <!-- 页面标题 -->
        <div class="mb-6">
          <h1 class="text-2xl font-bold text-gray-800 mb-2">User Detail</h1>
          <p class="text-gray-600">View and manage your personal information and ensure account security.</p>
        </div>
        
        <div class="mb-6 border-b border-gray-200"></div>
        
        <!-- 主要内容 -->
        <div class="grid grid-cols-1 lg:grid-cols-3 gap-6">
          <!-- 左侧：用户信息卡片 -->
          <div class="lg:col-span-1">
            <div class="card p-6">
              <div class="text-center">
                <h3 class="text-lg font-medium text-gray-800">{{ userProfile.name || 'User' }}</h3>
              </div>
              
              <div class="mt-6 pt-6 border-t border-gray-100">
                <div class="flex justify-between items-center mb-3">
                  <span class="text-gray-500">Registration Time</span>
                  <span class="text-gray-700">{{ userProfile.registeredAt || '—' }}</span>
                </div>
              </div>
            </div>
          </div>
          
          <!-- 右侧：用户详情表单 -->
          <div class="lg:col-span-2">
            <div class="card p-6">
              <form @submit.prevent="handleFormSubmit">
                <h3 class="text-lg font-medium text-gray-800 mb-4">Basic Information</h3>
                
                <!-- 用户名 -->
                <div class="mb-4">
                  <label for="username" class="block text-sm font-medium text-gray-700 mb-1">Nickname</label>
                  <input 
                    type="text" 
                    id="username" 
                    v-model="formData.username"
                    class="w-full p-2.5 rounded-lg border border-gray-300 focus:ring-2 focus:ring-indigo-200 focus:border-indigo-600 outline-none transition-all" 
                    :placeholder="isLoading ? 'Loading...' : 'Enter your nickname'"
                    :disabled="isLoading"
                  />
                </div>
                
                <!-- 邮箱 -->
                <div class="mb-4">
                  <label for="email" class="block text-sm font-medium text-gray-700 mb-1">Email</label>
                  <input 
                    type="email" 
                    id="email" 
                    v-model="formData.email"
                    class="w-full p-2.5 rounded-lg border border-gray-300 focus:ring-2 focus:ring-indigo-200 focus:border-indigo-600 outline-none transition-all" 
                    :placeholder="isLoading ? 'Loading...' : 'Enter your email'"
                    :disabled="isLoading"
                  />
                </div>
                
                <!-- 修改密码部分 -->
                <div class="mb-6 pt-6 border-t border-gray-200">
                  <h4 class="font-medium text-gray-800 mb-4">Change Password</h4>
                  
                  <!-- 当前密码 -->
                  <div class="mb-4">
                    <label for="current-password" class="block text-sm font-medium text-gray-700 mb-1">Current Password</label>
                    <div class="relative">
                      <input 
                        :type="showCurrentPassword ? 'text' : 'password'" 
                        id="current-password" 
                        v-model="formData.currentPassword"
                        class="w-full p-2.5 rounded-lg border border-gray-300 focus:ring-2 focus:ring-indigo-200 focus:border-indigo-600 outline-none transition-all" 
                        placeholder="Please enter your current password"
                      />
                      <button 
                        type="button" 
                        @click="showCurrentPassword = !showCurrentPassword"
                        class="absolute right-3 top-1/2 transform -translate-y-1/2 text-gray-400 hover:text-gray-600"
                      >
                        <iconify-icon 
                          :icon="showCurrentPassword ? 'solar:eye-closed-outline' : 'solar:eye-outline'" 
                          width="18" 
                          height="18"
                        ></iconify-icon>
                      </button>
                    </div>
                  </div>
                  
                  <!-- 新密码 -->
                  <div class="mb-4">
                    <label for="new-password" class="block text-sm font-medium text-gray-700 mb-1">New Password</label>
                    <div class="relative">
                      <input 
                        :type="showNewPassword ? 'text' : 'password'" 
                        id="new-password" 
                        v-model="formData.newPassword"
                        @input="checkPasswordStrength"
                        class="w-full p-2.5 rounded-lg border border-gray-300 focus:ring-2 focus:ring-indigo-200 focus:border-indigo-600 outline-none transition-all" 
                        placeholder="Please enter your new password"
                      />
                      <button 
                        type="button" 
                        @click="showNewPassword = !showNewPassword"
                        class="absolute right-3 top-1/2 transform -translate-y-1/2 text-gray-400 hover:text-gray-600"
                      >
                        <iconify-icon 
                          :icon="showNewPassword ? 'solar:eye-closed-outline' : 'solar:eye-outline'" 
                          width="18" 
                          height="18"
                        ></iconify-icon>
                      </button>
                    </div>
                    <div class="password-strength mt-2">
                      <div 
                        class="password-strength-indicator transition-all duration-300" 
                        :class="passwordStrengthClass"
                        :style="{ width: passwordStrength + '%' }"
                      ></div>
                    </div>
                    <p class="text-xs text-gray-500 mt-1">Password must contain at least 8 characters, one uppercase letter and one number</p>
                  </div>
                  
                  <!-- 确认新密码 -->
                  <div class="mb-4">
                    <label for="confirm-password" class="block text-sm font-medium text-gray-700 mb-1">Confirm New Password</label>
                    <div class="relative">
                      <input 
                        :type="showConfirmPassword ? 'text' : 'password'" 
                        id="confirm-password" 
                        v-model="formData.confirmPassword"
                        @input="checkPasswordMatch"
                        :class="[
                          'w-full p-2.5 rounded-lg border focus:ring-2 focus:ring-indigo-200 focus:border-indigo-600 outline-none transition-all',
                          passwordMatchClass
                        ]"
                        placeholder="Please enter your new password again"
                      />
                      <button 
                        type="button" 
                        @click="showConfirmPassword = !showConfirmPassword"
                        class="absolute right-3 top-1/2 transform -translate-y-1/2 text-gray-400 hover:text-gray-600"
                      >
                        <iconify-icon 
                          :icon="showConfirmPassword ? 'solar:eye-closed-outline' : 'solar:eye-outline'" 
                          width="18" 
                          height="18"
                        ></iconify-icon>
                      </button>
                    </div>
                  </div>
                </div>
                
                <!-- 保存按钮 -->
                <div class="flex justify-end">
                  <button 
                    type="submit" 
                    :disabled="isSubmitting"
                    class="px-6 py-2.5 bg-indigo-600 text-white rounded-lg hover:bg-indigo-700 transition-all flex items-center disabled:opacity-50 disabled:cursor-not-allowed"
                  >
                    <iconify-icon 
                      :icon="isSubmitting ? 'solar:refresh-outline' : 'solar:diskette-outline'" 
                      width="18" 
                      height="18" 
                      class="mr-2"
                      :class="{ 'animate-spin': isSubmitting }"
                    ></iconify-icon>
                    {{ isSubmitting ? 'Saving...' : 'Save' }}
                  </button>
                </div>
              </form>
            </div>
          </div>
        </div>
      </div>
    </main>
    
    <!-- 底部内边距 -->
    <div style="width: 100%; height: 20px; background-color: #f7f9fc;"></div>
  </div>
</template>

<script>
import { ref, reactive, computed, onMounted } from 'vue'

// API 服务类
class UserDetailService {
  constructor() {
    this.API_BASE = import.meta.env.VITE_API_BASE || 'http://localhost:8080'
  }

  async request(path, { method = 'GET', body } = {}) {
    // const url = new URL(this.API_BASE + path, window.location.origin)
    const url = this.API_BASE + path
    const token = localStorage.getItem('token')


    const res = await fetch(url, {
      method,
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
        ...(token ? { 'Authorization': `Bearer ${token}` } : {})
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

  // 获取用户资料
  async getUserProfile(userId) {
    return this.request(`/api/users/${userId}`)
  }

  // 更新用户资料
  async updateUserProfile(data) {
    return this.request('/user/profile', { method: 'PATCH', body: data })
  }

  // 修改密码
  async changePassword(userId, data) {
    // 后端当前是 @PostMapping("/{userId}/password")
    return this.request(`/api/users/${userId}/password`, { method: 'POST', body: data })
  }
}

export default {
  name: 'UserDetail',
  props: {
    user: {
      type: Object,
      default: () => ({
        name: 'User',
        email: 'user@example.com',
        registeredAt: '2025-11-03'
      })
    }
  },
  emits: ['userUpdated'],
  setup(props, { emit }) {
    // 初始化 API 服务
    const userDetailService = new UserDetailService()
    // 从登录/注册时保存的 userSession 里取 id（你注册时已保存 user 到 localStorage）
    const session = JSON.parse(localStorage.getItem('userSession') || '{}')
    const userId = ref(session.userId || session.id)  // 视后端 user 对象字段名而定
    // 响应式数据
    const isLoading = ref(false)
    const isSubmitting = ref(false)

    // 用户信息
    const userProfile = reactive({
      name: props.user?.name || 'Kirin',
      email: props.user?.email || 'kirin@example.com',
      registeredAt: props.user?.registeredAt || '2025-11-03'
    })

    // 表单数据
    const formData = reactive({
      username: userProfile.name,
      email: userProfile.email,
      currentPassword: '',
      newPassword: '',
      confirmPassword: ''
    })

    // —— 立刻用 localStorage 兜底一次（防止刷新后 props 为空）——
    try {
      const saved = JSON.parse(localStorage.getItem('userSession') || '{}')
      if (saved) {
        if (saved.nickname || saved.name) {
          userProfile.name = saved.nickname || saved.name
          formData.username = userProfile.name
        }
        if (saved.email) {
          userProfile.email = saved.email
          formData.email = saved.email
        }
        if (!userId.value) {
          userId.value = saved.userId || saved.id || null
        }
      }
    } catch (e) {
      console.warn('Failed to parse userSession from localStorage:', e)
    }


    // 密码显示控制
    const showCurrentPassword = ref(false)
    const showNewPassword = ref(false)
    const showConfirmPassword = ref(false)

    // 密码强度
    const passwordStrength = ref(0)
    const passwordMatch = ref(false)

    // 计算属性
    const passwordStrengthClass = computed(() => {
      if (passwordStrength.value <= 25) return 'bg-red-400'
      if (passwordStrength.value <= 50) return 'bg-yellow-400'
      if (passwordStrength.value <= 75) return 'bg-blue-400'
      return 'bg-green-400'
    })

    const passwordMatchClass = computed(() => {
      if (!formData.confirmPassword) return 'border-gray-300'
      return passwordMatch.value ? 'border-green-300' : 'border-red-300'
    })

    // 方法
    const checkPasswordStrength = () => {
      const password = formData.newPassword
      let strength = 0
      
      if (password.length >= 8) strength += 25
      if (password.match(/[A-Z]/)) strength += 25
      if (password.match(/[0-9]/)) strength += 25
      if (password.match(/[^a-zA-Z0-9]/)) strength += 25
      
      passwordStrength.value = strength
    }

    const checkPasswordMatch = () => {
      passwordMatch.value = formData.confirmPassword === formData.newPassword && formData.confirmPassword !== ''
    }

    const validateForm = () => {
      if (!formData.currentPassword) {
        alert('Please enter your current password')
        return false
      }
      if (!formData.newPassword) {
        alert('Please enter your new password')
        return false
      }
      if (formData.newPassword.length < 8) {
        alert('New password must contain at least 8 characters')
        return false
      }
      if (!/[A-Z]/.test(formData.newPassword)) {
        alert('New password must contain at least one uppercase letter')
        return false
      }
      if (!/[0-9]/.test(formData.newPassword)) {
        alert('New password must contain at least one number')  
        return false
      }
      if (!formData.confirmPassword) {
        alert('Please confirm your new password')
        return false
      }
      if (formData.newPassword !== formData.confirmPassword) {
        alert('New password and confirm password do not match')
        return false
      }
      if (formData.currentPassword === formData.newPassword) {
        alert('New password cannot be the same as current password')
        return false
      }
      return true
    }

    const resetForm = () => {
      formData.currentPassword = ''
      formData.newPassword = ''
      formData.confirmPassword = ''
      passwordStrength.value = 0
      passwordMatch.value = false
    }

    const handleFormSubmit = async () => {
      if (!validateForm()) return
      
      if (!confirm('Are you sure you want to change your password?')) return

      isSubmitting.value = true

      try {
        // 调用后端 API 修改密码
        // const response = await userDetailService.changePassword({
        //   currentPassword: formData.currentPassword,
        //   newPassword: formData.newPassword
        // })
        const uid = userId.value
        if (!uid) {
          alert('No user id, please login again.')
          return
        }
        const response = await userDetailService.changePassword(uid, {
          currentPassword: formData.currentPassword,
          newPassword: formData.newPassword,
          confirmNewPassword: formData.confirmPassword,
        })

        console.log('🔐 Password changed via API:', response)
        alert('Password changed successfully!')
        resetForm()
        
        // 通知父组件用户信息已更新
        emit('userUpdated', {
          name: formData.username,
          email: formData.email
        })
        
      } catch (error) {
        console.error('Password change failed:', error)
        alert(error.message || 'Failed to change password, please try again')
      } finally {
        isSubmitting.value = false
      }
    }

    const loadUserProfile = async () => {
      isLoading.value = true
      
      try {
        // 首先使用传入的用户数据
        if (props.user) {
          userProfile.name = props.user.name || userProfile.name
          userProfile.email = props.user.email || userProfile.email
          userProfile.registeredAt = props.user.registeredAt || userProfile.registeredAt
          
          formData.username = userProfile.name
          formData.email = userProfile.email
        }

        // 调用后端 API 获取最新用户资料
        try {
          let profile = null
          if (!userId.value) {
            console.warn('No userId in localStorage, cannot load profile')
          } else {
            profile = await userDetailService.getUserProfile(userId.value) // 传 userId
          }
          if (profile) {
            userProfile.name = profile.name || profile.nickname || userProfile.name
            userProfile.email = profile.email || userProfile.email
            userProfile.registeredAt = profile.registeredAt || userProfile.registeredAt

            formData.username = userProfile.name
            formData.email = userProfile.email

            // 反向更新 localStorage（可选，让显示更稳）
            const saved = JSON.parse(localStorage.getItem('userSession') || '{}')
            localStorage.setItem('userSession', JSON.stringify({
              ...saved,
              userId: saved?.userId ?? saved?.id ?? userId.value,
              nickname: userProfile.name,
              name: userProfile.name,
              email: userProfile.email
            }))

            console.log('📋 User profile loaded from API:', profile)
          }
        } catch (apiError) {
          console.warn('Failed to load user profile from API, using local cache:', apiError)
        }

        console.log('📋 User profile loaded:', userProfile)
        
      } catch (error) {
        console.error('Failed to load user profile:', error)
      } finally {
        isLoading.value = false
      }
    }

    // 生命周期
    onMounted(() => {
      loadUserProfile()
      console.log('👤 UserDetail component mounted')
    })

    return {
      // 响应式数据
      isLoading,
      isSubmitting,
      userProfile,
      formData,
      
      // 密码显示控制
      showCurrentPassword,
      showNewPassword,
      showConfirmPassword,
      
      // 密码验证
      passwordStrength,
      passwordMatch,
      passwordStrengthClass,
      passwordMatchClass,
      
      // 方法
      checkPasswordStrength,
      checkPasswordMatch,
      handleFormSubmit,
      resetForm
    }
  }
}
</script>

<style scoped>
@import url('https://fonts.googleapis.com/css2?family=Noto+Sans+SC:wght@300;400;500;700&display=swap');

.dropdown-content {
  max-height: 0;
  overflow: hidden;
  transition: max-height 0.3s ease;
}

.dropdown-content.open {
  max-height: 1000px;
}

.card {
  background-color: #fff;
  border-radius: 12px;
  box-shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.1), 0 2px 4px -1px rgba(0, 0, 0, 0.06);
  transition: all 0.3s ease;
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

.user-dropdown, .category-dropdown {
  position: relative;
}

.user-menu, .category-menu {
  position: absolute;
  right: 0;
  top: 100%;
  width: 200px;
  background-color: white;
  border-radius: 8px;
  box-shadow: 0 10px 15px -3px rgba(0, 0, 0, 0.1);
  opacity: 0;
  visibility: hidden;
  transform: translateY(10px);
  transition: all 0.2s ease;
  z-index: 30;
}

.user-dropdown:hover .user-menu, 
.category-dropdown:hover .category-menu {
  opacity: 1;
  visibility: visible;
  transform: translateY(0);
}

.nav-item {
  padding: 0.75rem 1rem;
  border-radius: 0.5rem;
  cursor: pointer;
  transition: all 0.2s ease;
}

.nav-item:hover {
  background-color: #f3f4f6;
}

.nav-item.active {
  background-color: #eef2ff;
  color: #4f46e5;
  font-weight: 500;
}

.avatar-container {
  position: relative;
  width: 120px;
  height: 120px;
  margin: 0 auto;
}

.avatar-overlay {
  position: absolute;
  top: 0;
  left: 0;
  width: 100%;
  height: 100%;
  background-color: rgba(0, 0, 0, 0.4);
  color: white;
  display: flex;
  align-items: center;
  justify-content: center;
  opacity: 0;
  transition: all 0.3s ease;
  border-radius: 50%;
}

.avatar-container:hover .avatar-overlay {
  opacity: 1;
}

.tab-content {
  display: none;
}

.tab-content.active {
  display: block;
}

/* 动画效果 */
.fade-enter-active, .fade-leave-active {
  transition: opacity 0.3s ease;
}

.fade-enter-from, .fade-leave-to {
  opacity: 0;
}

@keyframes spin {
  from {
    transform: rotate(0deg);
  }
  to {
    transform: rotate(360deg);
  }
}

.animate-spin {
  animation: spin 1s linear infinite;
}
</style>
