<template>
  <div class="h-full bg-gray-50 overflow-y-auto min-h-0" style="font-family: 'Noto Sans SC', sans-serif; background-color: #f7f9fc;">
    <div class="flex">
      <main class="flex-1 p-4 lg:p-6">
        <div class="container mx-auto">
          <!-- 页面标题 -->
          <div class="mb-6">
            <h1 class="text-2xl font-bold text-gray-800 mb-2">Subscription</h1>
            <p class="text-gray-600">Manage your book subscription records.</p>
          </div>
          
          <!-- 搜索区域 -->
          <div class="mb-6 flex flex-col md:flex-row md:justify-between md:items-center gap-4">
            <div class="relative">
              <input 
                type="text" 
                v-model="searchQuery"
                @input="performSearch"
                @keypress="handleKeyPress"
                placeholder="Search for subscription" 
                class="w-full sm:w-64 pr-10 pl-3 py-2 border border-gray-300 rounded-md focus:ring-2 focus:ring-indigo-200 focus:border-indigo-600 outline-none transition-all"
              />
              <button 
                @click="performSearch"
                class="absolute right-3 top-1/2 transform -translate-y-1/2 text-gray-400 hover:text-indigo-600"
              >
                <iconify-icon icon="solar:magnifer-outline" width="18" height="18"></iconify-icon>
              </button>
            </div>
          </div>

          <!-- 统计信息 -->
          <div class="mb-4" v-if="filteredSubscriptions.length !== subscriptions.length">
            <p class="text-sm text-gray-500">
              Showing {{ filteredSubscriptions.length }} of {{ subscriptions.length }} subscriptions
              <button @click="clearSearch" class="text-indigo-600 hover:text-indigo-800 ml-2">
                Clear Search
              </button>
            </p>
          </div>
          
          <!-- 订阅列表表格 -->
          <div class="bg-white rounded-lg shadow-sm overflow-hidden mb-6">
            <div class="overflow-x-auto">
              
              <!-- 空状态 -->
              <div v-if="subscriptions.length === 0 && !isLoading" class="text-center py-12">
                <iconify-icon icon="solar:history-outline" width="64" height="64" class="text-gray-400 mx-auto mb-4"></iconify-icon>
                <h3 class="text-lg font-medium text-gray-900 mb-2">No subscriptions yet</h3>
                <p class="text-gray-500 mb-4">You haven't subscribed to any books</p>
                <button 
                  @click="navigateToHome"
                  class="bg-indigo-600 text-white px-4 py-2 rounded-lg hover:bg-indigo-700 transition"
                >
                  Browse Books
                </button>
              </div>

              <!-- 无搜索结果 -->
              <div v-else-if="filteredSubscriptions.length === 0 && searchQuery" class="text-center py-12">
                <iconify-icon icon="solar:magnifer-outline" width="64" height="64" class="text-gray-400 mx-auto mb-4"></iconify-icon>
                <h3 class="text-lg font-medium text-gray-900 mb-2">No results found</h3>
                <p class="text-gray-500">No subscriptions match your search for "{{ searchQuery }}"</p>
              </div>

              <!-- 加载状态 -->
              <div v-else-if="isLoading" class="text-center py-12">
                <iconify-icon icon="solar:refresh-outline" width="48" height="48" class="text-indigo-600 mx-auto mb-4 animate-spin"></iconify-icon>
                <p class="text-gray-500">Loading your subscriptions...</p>
              </div>

              <!-- 订阅表格 -->
              <table v-else class="min-w-full divide-y divide-gray-200">
                <thead class="bg-gray-50">
                  <tr>
                    <th scope="col" class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                      Book
                    </th>
                    <th scope="col" class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                      Borrow Date
                    </th>
                    <th scope="col" class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                      Return Date
                    </th>
                    <th scope="col" class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                      Status
                    </th>
                    <th scope="col" class="px-6 py-3 text-right text-xs font-medium text-gray-500 uppercase tracking-wider">
                      Operation
                    </th>
                  </tr>
                </thead>
                <tbody class="bg-white divide-y divide-gray-200">
                  <tr 
                    v-for="subscription in filteredSubscriptions" 
                    :key="subscription.reservationId || subscription.sid"
                    class="order-row"
                  >
                    <!-- Book Info -->
                    <td class="px-6 py-4">
                      <div class="flex items-center">
                        <div class="flex-shrink-0 h-10 w-10 bg-indigo-100 rounded-md flex items-center justify-center">
                          <img 
                            :src="getBookCover(subscription)" 
                            :alt="subscription.bookName"
                            class="w-full h-full object-cover rounded-md"
                            @error="handleImageError"
                          />
                        </div>
                        <div class="ml-4">
                          <div class="text-sm font-medium text-gray-900">{{ subscription.bookName }}</div>
                        </div>
                      </div>
                    </td>
                    
                    <!-- Borrow Date -->
                    <td class="px-6 py-4 whitespace-nowrap">
                      <div class="text-sm text-gray-900">{{ formatDate(subscription.createDate) }}</div>
                    </td>
                    
                    <!-- Return Date -->
                    <td class="px-6 py-4 whitespace-nowrap">
                      <div class="text-sm text-gray-900">{{ formatDate(subscription.returnDate) }}</div>
                    </td>
                    
                    <!-- Status -->
                    <td class="px-6 py-4 whitespace-nowrap">
                      <span 
                        class="px-2 inline-flex text-xs leading-5 font-semibold rounded-full"
                        :class="getStatusClass(subscription.status)"
                      >
                        {{ getStatusText(subscription.status) }}
                      </span>
                    </td>
                    
                    <!-- Operations -->
                    <td class="px-6 py-4 whitespace-nowrap text-right text-sm font-medium">
                      <div class="flex justify-end items-center space-x-3">
                        <!-- 删除/退订 -->
                        <button 
                          @click="removeSubscription(subscription)"
                          :disabled="removing === (subscription.reservationId || subscription.sid) || !canDelete(subscription.status)"
                          class="flex items-center justify-center text-gray-600 hover:text-gray-900 bg-gray-50 hover:bg-gray-100 rounded-md w-9 h-9 transition-all disabled:opacity-50 disabled:cursor-not-allowed"
                          :title="!canDelete(subscription.status) ? 'Cannot delete completed subscriptions' : (removing === (subscription.reservationId || subscription.sid) ? 'Removing...' : 'Unsubscribe')"
                        >
                          <iconify-icon 
                            :icon="removing === (subscription.reservationId || subscription.sid) ? 'solar:refresh-outline' : 'solar:trash-bin-trash-outline'" 
                            width="18" 
                            height="18" 
                            class="block"
                            :class="{ 'animate-spin': removing === (subscription.reservationId || subscription.sid) }"
                          ></iconify-icon>
                        </button>
                        
                        <!-- 查看详情 -->
                        <button 
                          @click="viewBookDetails(subscription)"
                          class="flex items-center justify-center text-gray-600 hover:text-gray-900 bg-gray-50 hover:bg-gray-100 rounded-md w-9 h-9 transition-all"
                          title="View Details"
                        >
                          <iconify-icon icon="solar:info-circle-outline" width="18" height="18" class="block"></iconify-icon>
                        </button>
                      </div>
                    </td>
                  </tr>
                </tbody>
              </table>
            </div>
          </div>
        </div>
      </main>
    </div>
    
    <!-- 底部内边距 -->
    <div style="width: 100%; height: 20px; background-color: #f7f9fc;"></div>
  </div>
</template>

<script>
import { ref, reactive, computed, onMounted } from 'vue'

// API 服务类
class SubscriptionListService {
  constructor() {
    this.API_BASE = import.meta.env.VITE_API_BASE || 'http://localhost:8080'
  }

  async request(path, { method = 'GET', body, params } = {}) {
    // 组装 URL（你在调用处的 path 需已手动加上 /api 前缀）
    const url = new URL(this.API_BASE + path, window.location.origin)

    // 查询参数
    if (params) {
      Object.entries(params).forEach(([k, v]) => {
        if (v != null) url.searchParams.set(k, v)
      })
    }

    // 组装请求头：仅在有 body 时带 Content-Type；并追加当前用户 X-USER-ID
    const headers = { 'Accept': 'application/json' }
    if (body != null) headers['Content-Type'] = 'application/json'
    try {
      const session = JSON.parse(localStorage.getItem('userSession') || '{}')
      if (session?.userId != null) headers['X-USER-ID'] = String(session.userId)
    } catch { /* 忽略 localStorage 解析异常 */ }

    const res = await fetch(url.toString(), {
      method,
      headers,
      // credentials: 'include',                 // 若后端使用 Cookie 会话，保留；否则不影响
      body: body != null ? JSON.stringify(body) : undefined
    })

    if (!res.ok) {
      const text = await res.text().catch(() => '')
      throw new Error(`HTTP ${res.status} ${res.statusText} – ${text}`)
    }

    if (res.status === 204) return null
    const ct = res.headers.get('content-type') || ''
    return ct.includes('application/json') ? res.json() : res.text()
  }

  // 获取订阅列表
  async getReservations() {
    return this.request('/api/reservations')
  }

  // 添加订阅
  async addReservation(bookId) {
    return this.request(`/api/books/${bookId}/reservation`, { method: 'POST' })
  }

  // 删除订阅
  async removeReservation(subscriptionId) {
    return this.request(`/api/reservations/${subscriptionId}`, { method: 'DELETE' })
  }

  // 更新订阅状态
  async updateReservationStatus(subscriptionId, status) {
    return this.request(`/api/reservations/${subscriptionId}`, { 
      method: 'PATCH', 
      body: { status } 
    })
  }

  // 获取订阅详情
  async getReservationDetail(subscriptionId) {
    return this.request(`/api/reservations/${subscriptionId}`)
  }

  // 获取图书详情
  async getBookDetail(bookId) {
    return this.request(`/api/books/${bookId}`)
  }
}

export default {
  name: 'SubscriptionList',
  props: {
    user: {
      type: Object,
      default: () => ({})
    }
  },
  emits: ['navigateToHome', 'viewBookDetails'],
  setup(props, { emit }) {
    // 初始化 API 服务
    const subscriptionService = new SubscriptionListService()
    // 响应式数据
    const isLoading = ref(false)
    const removing = ref(null)
    const searchQuery = ref('')
    const subscriptions = ref([])

    // 图片路径处理
    const getImageUrl = (imagePath) => {
      try {
        return `/src/assets/${imagePath}`
      } catch (error) {
        return '/src/assets/img/img.jpg'
      }
    }

    const defaultImageUrl = '/src/assets/img/img.jpg'

    // 计算属性
    const filteredSubscriptions = computed(() => {
      if (!searchQuery.value.trim()) return subscriptions.value
      
      const query = searchQuery.value.toLowerCase().trim()
      return subscriptions.value.filter(subscription => {
        const sid = (subscription.reservationId || subscription.sid || '').toString().toLowerCase()
        const bookName = (subscription.bookName || '').toLowerCase()
        const status = getStatusText(subscription.status).toLowerCase()
        
        return sid.includes(query) || 
               bookName.includes(query) || 
               status.includes(query)
      })
    })

    // 方法
    const getBookCover = (subscription) => {
      // 参考 Favorite.vue 的实现
      if (subscription.avatar) {
        return getImageUrl(subscription.avatar.replace(/^\/+/, ''))
      }
      return defaultImageUrl
    }

    const handleImageError = (event) => {
      console.warn('图片加载失败，使用默认图片:', event.target.src)
      event.target.src = defaultImageUrl
    }

    const getStatusClass = (status) => {
      // 处理数字状态码
      const statusNum = typeof status === 'number' ? status : parseInt(status)
      switch (statusNum) {
        case 0:
          return 'bg-yellow-100 text-yellow-800' // 排队中
        case 1:
          return 'bg-blue-100 text-blue-800' // 已分配/可取书
        case 2:
          return 'bg-gray-100 text-gray-800' // 已归还
        case 3:
          return 'bg-red-100 text-red-800' // 已取消
        case 4:
          return 'bg-green-100 text-green-800' // 已取书
        default:
          return 'bg-gray-100 text-gray-800'
      }
    }

    const getStatusText = (status) => {
      // 将数字状态码转换为可读文本
      const statusNum = typeof status === 'number' ? status : parseInt(status)
      switch (statusNum) {
        case 0:
          return 'Queuing'
        case 1:
          return 'Available'
        case 2:
          return 'Returned'
        case 3:
          return 'Cancelled'
        case 4:
          return 'Taken'
        default:
          return 'Unknown'
      }
    }

    const canDelete = (status) => {
      // 只有 Queuing(0) 和 Available(1) 状态可以删除
      const statusNum = typeof status === 'number' ? status : parseInt(status)
      return statusNum === 0 || statusNum === 1
    }

    const formatDate = (date) => {
      if (!date) return '-'
      try {
        // 处理不同的日期格式
        if (typeof date === 'string') {
          return date.split('T')[0] // 只取日期部分
        }
        if (date instanceof Date) {
          return date.toISOString().split('T')[0]
        }
        return date.toString()
      } catch (error) {
        console.warn('Date formatting error:', error)
        return '-'
      }
    }

    const performSearch = () => {
      // 搜索逻辑已在 computed 中处理
      console.log('🔍 Searching subscriptions for:', searchQuery.value)
    }

    const clearSearch = () => {
      searchQuery.value = ''
      console.log('🔄 Search cleared')
    }

    const handleKeyPress = (event) => {
      if (event.key === 'Enter') {
        performSearch()
      }
    }

    const navigateToHome = () => {
      emit('navigateToHome')
      console.log('🏠 Navigating to home page')
    }

    const removeSubscription = async (subscription) => {
      if (!confirm(`Are you sure you want to unsubscribe "${subscription.bookName}"?`)) {
        return
      }

      const subscriptionId = subscription.reservationId || subscription.sid
      removing.value = subscriptionId
      
      try {
        // 调用后端 API 删除订阅
        const response = await subscriptionService.removeReservation(subscriptionId)
        console.log('❌ Removed subscription via API:', response)
        
        // 重新加载订阅列表
        await loadSubscriptions()
        console.log('❌ Removed subscription:', subscription.bookName)
        
      } catch (error) {
        console.error('Failed to remove subscription:', error)
        alert(error.message || 'Failed to unsubscribe. Please try again.')
      } finally {
        removing.value = null
      }
    }

    const viewBookDetails = async (subscription) => {
      console.log('📖 Viewing book details for:', subscription.bookName)
      
      try {
        // 可选：调用后端 API 获取订阅详情
        const subscriptionId = subscription.reservationId || subscription.sid
        const detail = await subscriptionService.getReservationDetail(subscriptionId)
        console.log('📖 Subscription detail from API:', detail)
        
        // 发送事件给父组件，包含详细信息
        emit('viewBookDetails', {
          bookId: subscription.bookId,
          bookName: subscription.bookName,
          ...detail // 包含 API 返回的额外信息
        })
      } catch (error) {
        console.warn('Failed to get subscription detail from API, using basic info:', error)
        
        // API 失败时使用基本信息
        emit('viewBookDetails', {
          bookId: subscription.bookId,
          bookName: subscription.bookName
        })
      }
    }

    const loadSubscriptions = async () => {
      isLoading.value = true
      
      try {
        // 直接调用后端 API 获取订阅列表
        try {
          const apiSubscriptions = await subscriptionService.getReservations()
          if (Array.isArray(apiSubscriptions) && apiSubscriptions.length > 0) {
            // 为每本图书获取详细信息和封面
            const subscriptionsWithDetails = await Promise.all(
              apiSubscriptions.map(async (subscription) => {
                try {
                  // 获取图书详细信息（包括封面）
                  const bookDetail = await subscriptionService.getBookDetail(subscription.bookId)
                  return {
                    ...subscription,
                    avatar: bookDetail?.avatar || ''
                  }
                } catch (error) {
                  console.warn(`Failed to get book detail for ${subscription.bookId}:`, error)
                  return subscription
                }
              })
            )
            subscriptions.value = subscriptionsWithDetails
            console.log('📋 Loaded subscriptions from API:', apiSubscriptions.length)
          } else {
            console.log('📋 No subscriptions from API')
            subscriptions.value = []
          }
        } catch (apiError) {
          console.warn('Failed to load subscriptions from API:', apiError)
          subscriptions.value = []
        }
        
        console.log('📋 Loaded', subscriptions.value.length, 'subscriptions')
        
      } catch (error) {
        console.error('Failed to load subscriptions:', error)
        subscriptions.value = []
      } finally {
        isLoading.value = false
      }
    }

    // 生命周期
    onMounted(() => {
      loadSubscriptions()
      console.log('📝 SubscriptionList component mounted')
    })

    // 返回响应式数据和方法
    return {
      // 响应式数据
      isLoading,
      removing,
      searchQuery,
      subscriptions,
      filteredSubscriptions,
      
      // 方法
      getBookCover,
      handleImageError,
      getStatusClass,
      getStatusText,
      canDelete,
      formatDate,
      performSearch,
      clearSearch,
      handleKeyPress,
      navigateToHome,
      removeSubscription,
      viewBookDetails
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

.order-row {
  transition: all 0.2s ease;
}

.order-row:hover {
  background-color: #f9fafb;
}

.pagination-btn {
  transition: all 0.2s ease;
}

.pagination-btn:hover:not(.disabled) {
  background-color: #eef2ff;
  color: #4f46e5;
}

.pagination-btn.active {
  background-color: #4f46e5;
  color: white;
}

.pagination-btn.disabled {
  opacity: 0.5;
  cursor: not-allowed;
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

/* 表格行悬浮效果 */
.order-row:hover {
  background-color: #f9fafb;
}

/* 状态标签样式增强 */
.status-pill {
  transition: all 0.2s ease;
}

.status-pill:hover {
  transform: scale(1.05);
}
</style>
