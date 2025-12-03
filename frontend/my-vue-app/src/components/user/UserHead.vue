<template>
  <div class="bg-gray-50 min-h-screen" style="font-family: 'Noto Sans SC', sans-serif; background-color: #f7f9fc; overflow: hidden;">
    <!-- 导航栏 -->
    <header class="bg-white shadow-sm sticky top-0 z-40" style="height: 70px;">
      <div class="container mx-auto px-0">
        <div class="flex justify-between items-center h-16">
          <!-- Logo -->
          <div class="flex items-center" style="margin-left: -25px;">
            <a href="javascript:void(0)" @click="navigateTo(PAGES.HOME)">
              <button 
                id="sidebar-toggle" 
                class="mr-2 p-2 rounded-md lg:hidden text-gray-500 hover:text-gray-600 hover:bg-gray-100"
              >
                <iconify-icon icon="solar:hamburger-menu-outline" width="24" height="24"></iconify-icon>
              </button>
              <div class="flex items-center">
                <iconify-icon icon="solar:book-2-bold" width="32" height="32" class="text-indigo-600 mr-2"></iconify-icon>
                <h1 class="text-xl font-bold text-gray-800">Library Reservation System</h1>
              </div>
            </a>
          </div>
          
          <div class="flex items-center space-x-2">
            <!-- 图书分类 -->
            <div class="category-dropdown">
              <button class="flex items-center space-x-2 focus:outline-none">
                <iconify-icon icon="solar:document-text-outline" width="20" height="20" class="text-gray-600"></iconify-icon>
                <span class="hidden md:block text-gray-700">Category</span>
                <iconify-icon icon="solar:alt-arrow-down-outline" width="16" height="16" class="text-gray-400"></iconify-icon>
              </button>
              
              <div class="category-menu">
                <div class="p-2">
                  <a 
                    v-for="category in categories" 
                    :key="category"
                    href="javascript:void(0)" 
                    @click="selectCategory(category)"
                    class="flex items-center space-x-2 p-2 hover:bg-gray-100 rounded-md"
                  >
                    <span class="text-gray-700">{{ category }}</span>
                  </a>
                </div>
              </div>
            </div>

            <!-- 用户 -->
            <div class="user-dropdown">
              <button class="flex items-center space-x-2 focus:outline-none">
                <div class="w-8 h-8 rounded-full bg-indigo-100 flex items-center justify-center">
                  <span class="text-indigo-700 font-medium">{{ userInitial }}</span>
                </div>
                <span class="hidden md:block text-gray-700">{{ userName }}</span>
                <iconify-icon icon="solar:alt-arrow-down-outline" width="16" height="16" class="text-gray-400"></iconify-icon>
              </button>
              
              <div class="user-menu">
                <div class="p-2">
                  <a 
                    href="javascript:void(0)" 
                    @click="navigateTo(PAGES.USER_DETAIL)"
                    class="flex items-center space-x-2 p-2 hover:bg-gray-100 rounded-md"
                  >
                    <iconify-icon icon="solar:user-outline" width="18" height="18" class="text-gray-500"></iconify-icon>
                    <span class="text-gray-700">User Detail</span>
                  </a>
                  <a 
                    href="javascript:void(0)" 
                    @click="navigateTo(PAGES.FAVORITE)"
                    class="flex items-center space-x-2 p-2 hover:bg-gray-100 rounded-md"
                  >
                    <iconify-icon icon="solar:bookmark-outline" width="18" height="18" class="text-gray-500"></iconify-icon>
                    <span class="text-gray-700">Favorite</span>
                  </a>
                  <a 
                    href="javascript:void(0)" 
                    @click="navigateTo(PAGES.SUBSCRIPTION)"
                    class="flex items-center space-x-2 p-2 hover:bg-gray-100 rounded-md"
                  >
                    <iconify-icon icon="solar:history-outline" width="18" height="18" class="text-gray-500"></iconify-icon>
                    <span class="text-gray-700">Subscription</span>
                  </a>
                </div>
                <div class="p-2 border-t border-gray-100">
                  <a 
                    href="javascript:void(0)" 
                    @click="logout"
                    class="flex items-center space-x-2 p-2 text-red-500 hover:bg-red-50 rounded-md"
                  >
                    <iconify-icon icon="solar:logout-3-outline" width="18" height="18"></iconify-icon>
                    <span>Log out</span>
                  </a>
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>
    </header>
    
    <!-- 主内容区域 -->
    <div id="mainpage" style="width:100%;height: calc(100vh - 70px); overflow: hidden; display: flex; flex-direction: column;">
      <!-- 首页 -->
      <Home 
        v-if="currentPage === PAGES.HOME" 
        @viewBookDetails="handleViewBookDetails"
      />
      
      <!-- 用户详情页面 -->
      <UserDetail 
        v-else-if="currentPage === PAGES.USER_DETAIL" 
        :user="user"
        @userUpdated="handleUserUpdated"
      />
      
      <!-- 收藏夹页面 -->
      <Favorite 
        v-else-if="currentPage === PAGES.FAVORITE" 
        :user="user"
        @navigateToHome="navigateTo(PAGES.HOME)"
        @viewBookDetails="handleViewBookDetails"
      />
      
      <!-- 订阅列表页面 -->
      <SubscriptionList 
        v-else-if="currentPage === PAGES.SUBSCRIPTION" 
        :user="user"
        @navigateToHome="navigateTo(PAGES.HOME)"
        @viewBookDetails="handleViewBookDetails"
      />
      
      <!-- 书籍详情页面 -->
      <!--        @favoriteAdded="handleFavoriteAdded"-->
      <BookDetails 
        v-else-if="currentPage === PAGES.BOOK_DETAILS" 
        :bookId="bookDetailsData?.bookId || 1"
        :user="user"
        @subscribed="handleBookSubscribed"
        @reviewAdded="handleReviewAdded"
      />
      
      <!-- 分类页面 -->
      <Category 
        v-else-if="currentPage === PAGES.CATEGORY" 
        :categoryName="selectedCategory || 'Engineering'"
        :user="user"
        @viewBookDetails="handleViewBookDetails"
      />
      
      <!-- 未知页面 -->
      <div v-else class="flex items-center justify-center h-full">
        <div class="text-center p-8">
          <iconify-icon icon="solar:question-circle-bold" width="64" height="64" class="text-gray-400 mx-auto mb-4"></iconify-icon>
          <h3 class="text-lg font-medium text-gray-900 mb-2">Unknown Page</h3>
          <p class="text-gray-500 mb-4">Page "{{ currentPage }}" is not recognized</p>
          <button 
            @click="navigateTo(PAGES.HOME)"
            class="bg-indigo-600 text-white px-4 py-2 rounded-lg hover:bg-indigo-700 transition"
          >
            Go to Home
          </button>
        </div>
      </div>
    </div>
  </div>
</template>

<script>
import { ref, reactive, computed, onMounted, onBeforeUnmount } from 'vue'
import Home from './Home.vue'
import UserDetail from './UserDetail.vue'
import Favorite from './Favorite.vue'
import SubscriptionList from './SubscriptionList.vue'
import BookDetails from './BookDetails.vue'
import Category from './Category.vue'

// API 服务类
class UserHeadService {
  constructor() {
    this.API_BASE = import.meta.env.VITE_API_BASE || 'http://localhost:8080'
  }
  withApiPrefix(path) {
    return path.startsWith('/api') ? path : `/api${path.startsWith('/') ? '' : '/'}${path}`
  }
  async request(path, { method = 'GET', body, params } = {}) {
    const apiPath = this.withApiPrefix(path)
    const url = new URL(this.API_BASE + apiPath)

    if (params) {
      Object.entries(params).forEach(([k, v]) => {
        if (v != null) url.searchParams.set(k, v)
      })
    }

    const headers = { Accept: 'application/json' }
    if (body != null) headers['Content-Type'] = 'application/json'

    // 统一附带 X-USER-ID
    try {
      const session = JSON.parse(localStorage.getItem('userSession') || '{}')
      if (session?.userId != null) headers['X-USER-ID'] = String(session.userId)
    } catch {}

    const res = await fetch(url.toString(), {
      method, headers, body: body ? JSON.stringify(body) : undefined
    })
    if (!res.ok) {
      const text = await res.text().catch(() => '')
      throw new Error(`HTTP ${res.status} ${res.statusText} – ${text}`)
    }
    if (res.status === 204) return null
    const ct = res.headers.get('content-type') || ''
    return ct.includes('application/json') ? res.json() : res.text()
  }

  // 分类相关 API
  async getCategories() {
    return this.request('/labels')
  }

  async getBooksByCategory(category) {
    return this.request('/books', { params: { category } })
  }

  // 用户相关 API
  async getUserProfile() {
    return this.request('/user/profile')
  }

  async updateUserProfile(data) {
    return this.request('/user/profile', { method: 'PATCH', body: data })
  }

  async changePassword(data) {
    return this.request('/user/change-password', { method: 'POST', body: data })
  }

  // 认证相关 API
  async logout() {
    return this.request('/logout', { method: 'POST' })
  }

  // 图书相关 API
  async getBooks(params) {
    return this.request('/books', { params })
  }

  async getPopularBooks() {
    return this.request('/books/popular')
  }

  async getBookDetail(bookId) {
    return this.request(`/books/${bookId}`)
  }

  // 收藏相关 API
  async getFavorites() {
    return this.request('/favorites')
  }

  async addFavorite(bookId) {
    return this.request(`/books/${bookId}/favorite`, { method: 'POST' })
  }

  async removeFavorite(bookId) {
    return this.request(`/favorites/${bookId}`, { method: 'DELETE' })
  }

  // 订阅相关 API
  async getReservations() {
    return this.request('/reservations')
  }

  async addReservation(bookId) {
    return this.request(`/books/${bookId}/reservation`, { method: 'POST' })
  }

  async removeReservation(subscriptionId) {
    return this.request(`/reservations/${subscriptionId}`, { method: 'DELETE' })
  }

  // 评论相关 API
  async getReviews(bookId) {
    return this.request(`/books/${bookId}/reviews`)
  }

  async addReview(bookId, data) {
    return this.request(`/books/${bookId}/reviews`, { method: 'POST', body: data })
  }
}

export default {
  name: 'UserHead',
  components: {
    Home,
    UserDetail,
    Favorite,
    SubscriptionList,
    BookDetails,
    Category
  },
  props: {
    user: {
      type: Object,
      default: () => ({
        name: 'User',
        email: 'user@example.com',
        avatar: null,
        role: 'user'
      })
    }
  },
  emits: ['logout', 'navigateToPage'],
  setup(props, { emit }) {
    // 初始化 API 服务
    const userHeadService = new UserHeadService()
    // 页面配置
    const PAGES = {
      HOME: 'home',
      USER_DETAIL: 'user_detail',
      FAVORITE: 'favorite', 
      SUBSCRIPTION: 'subscription_list',
      CATEGORY: 'category',
      BOOK_DETAILS: 'book_details'
    }

    // 响应式数据
    const categories = ref([
      'Engineering',
      'Mathematics', 
      'Business',
      'Architecture',
      'Law'
    ])

    const currentPage = ref(PAGES.HOME)
    const selectedCategory = ref(null)
    const bookDetailsData = ref(null)

    // 获取用户信息 - 从localStorage读取，如果不存在则使用props
    const getUserFromStorage = () => {
      try {
        const session = JSON.parse(localStorage.getItem('userSession') || '{}')
        if (session && session.nickname) {
          return {
            name: session.nickname,
            email: session.email,
            userId: session.userId,
            ...session
          }
        }
      } catch (e) {
        console.warn('Failed to parse userSession from localStorage:', e)
      }
      return props.user
    }

    // 创建响应式的用户数据
    const localUser = ref(getUserFromStorage())

    // 计算属性 - 基于本地存储的用户数据
    const userName = computed(() => localUser.value?.name || props.user?.name || 'User')
    const userInitial = computed(() => {
      const name = localUser.value?.name || props.user?.name || 'User'
      return name[0]?.toUpperCase() || 'U'
    })
    const userEmail = computed(() => localUser.value?.email || props.user?.email || 'user@example.com')

    // 页面导航方法
    const pushUserHeadState = (state) => {
      try { history.pushState({ scope: 'userhead', ...state }, '') } catch {}
    }

    const navigateTo = (page) => {
      currentPage.value = page
      selectedCategory.value = null // 清除分类选择
      console.log('📄 Navigate to page:', page)
      
      // 保存当前页面到localStorage
      try {
        localStorage.setItem('currentPage', page)
        // 如果不是书籍详情页，清除bookId
        if (page !== PAGES.BOOK_DETAILS) {
          localStorage.removeItem('currentBookId')
        }
        // 如果不是分类页面，清除分类状态
        if (page !== PAGES.CATEGORY) {
          localStorage.removeItem('currentCategory')
        }
      } catch (error) {
        console.warn('Failed to save page to localStorage:', error)
      }
      
      // 通知父组件页面变化
      emit('navigateToPage', { page, user: props.user })

      // 写入浏览器历史
      pushUserHeadState({ page })
    }

    const selectCategory = (category) => {
      currentPage.value = PAGES.CATEGORY
      selectedCategory.value = category
      console.log('🏷️ Selected category:', category)
      
      // 保存当前页面和分类到localStorage
      try {
        localStorage.setItem('currentPage', PAGES.CATEGORY)
        localStorage.setItem('currentCategory', category)
        localStorage.removeItem('currentBookId')
      } catch (error) {
        console.warn('Failed to save page to localStorage:', error)
      }
      
      // 通知父组件分类变化
      emit('navigateToPage', { 
        page: PAGES.CATEGORY, 
        category, 
        user: props.user
      })

      pushUserHeadState({ page: PAGES.CATEGORY, category })
    }

    // 分类数据加载 - 从后端label表获取
    const loadCategories = async () => {
      try {
        console.log('📚 Loading categories from API (label table)...')
        const response = await userHeadService.getCategories()

        // 处理API响应数据 - 根据LabelController返回的List<Label>格式
        let categoryData = []
        if (response && Array.isArray(response)) {
          // LabelController.getAllLabels() 直接返回 List<Label>
          // Label模型包含: { labelId, labelName, createDate }
          categoryData = response.map(item => {
            // 提取labelName字段（Label模型的主要字段）
            return item.labelName || item.name || item
          })
          console.log('📚 Raw API response from /api/labels:', response)
          console.log('📚 Processed categories (labelName extracted):', categoryData)
        } else {
          console.log('📚 API response is not an array:', response)
        }

        if (categoryData && categoryData.length > 0) {
          categories.value = categoryData
          console.log('📚 Categories loaded from API (label table):', categoryData)
        } else {
          console.log('📚 No categories from API, using default data')
        }
      } catch (error) {
        console.warn('Failed to load categories from API (label table), using default data:', error)
        console.error('API Error details:', error.message)
        // 保持默认分类数据
      }
    }

    const logout = async () => {
      try {
        console.log('🚪 Logging out user:', props.user?.name || 'Unknown')
        
        // 调用后端登出 API
        try {
          await userHeadService.logout()
          console.log('🚪 Logout API call successful')
        } catch (apiError) {
          console.warn('Logout API call failed, but continuing with local logout:', apiError)
        }
        
        // 清理本地会话信息 - 清除所有相关内容
        try { 
          localStorage.removeItem('token')
          localStorage.removeItem('userSession')
          localStorage.removeItem('currentPage')
          localStorage.removeItem('currentBookId')
          localStorage.removeItem('currentCategory')
          sessionStorage.clear()
          
          console.log('🧹 Cleared all session data from localStorage')
        } catch (e) {
          console.warn('Failed to clear localStorage:', e)
        }
        
        // 清除浏览器历史记录，防止回退
        try {
          window.history.pushState(null, '', window.location.href)
          console.log('📝 Added history state to prevent back navigation')
        } catch (e) {
          console.warn('Failed to add history state:', e)
        }
        
        // 发送登出事件给父组件，触发跳转到登录页
        emit('logout')
        
      } catch (e) {
        console.error('Logout failed:', e)
        // 即使失败也要登出
        emit('logout')
      }
    }

    const handleUserUpdated = async (updatedUserData) => {
      console.log('👤 User updated:', updatedUserData)
      
      try {
        // 调用后端 API 更新用户信息
        const response = await userHeadService.updateUserProfile(updatedUserData)
        console.log('👤 User profile updated via API:', response)
        
        // 更新本地存储的用户信息
        if (response?.user) {
          localStorage.setItem('userSession', JSON.stringify(response.user))
        }
        
        // 通知父组件用户信息已更新
        emit('navigateToPage', { 
          page: 'userUpdated', 
          userData: response?.user || updatedUserData,
          user: props.user
        })
      } catch (error) {
        console.error('Failed to update user profile via API:', error)
        // 即使 API 失败，也通知父组件（可能只是本地更新）
        emit('navigateToPage', { 
          page: 'userUpdated', 
          userData: updatedUserData,
          user: props.user
        })
      }
    }

    const handleViewBookDetails = (bookInfo) => {
      console.log('📖 Viewing book details:', bookInfo)
      
      // 设置书籍详情数据
      bookDetailsData.value = {
        bookId: bookInfo.bookId,
        bookName: bookInfo.bookName,
        ...bookInfo
      }
      
      // 导航到书籍详情页面
      currentPage.value = PAGES.BOOK_DETAILS
      
      // 保存当前页面和bookId到localStorage
      try {
        localStorage.setItem('currentPage', PAGES.BOOK_DETAILS)
        localStorage.setItem('currentBookId', bookInfo.bookId)
      } catch (error) {
        console.warn('Failed to save page to localStorage:', error)
      }
      
      // 通知父组件
      emit('navigateToPage', { 
        page: PAGES.BOOK_DETAILS, 
        bookData: bookInfo,
        user: props.user
      })

      pushUserHeadState({ page: PAGES.BOOK_DETAILS, bookId: bookInfo.bookId })
    }

    const handleFavoriteAdded = async (favoriteInfo) => {
      // console.log('⭐ Book added to favorites:', favoriteInfo)
      //
      // try {
      //   // 调用后端 API 添加收藏
      //   const response = await userHeadService.addFavorite(favoriteInfo.bookId)
      //   console.log('⭐ Favorite added via API:', response)
      //
      //   // 通知父组件收藏已添加
      //   emit('navigateToPage', {
      //     page: 'favoriteAdded',
      //     favoriteData: favoriteInfo,
      //     user: props.user
      //   })
      // } catch (error) {
      //   console.error('Failed to add favorite via API:', error)
      //   // 即使 API 失败，也通知父组件（可能只是本地更新）
      //   emit('navigateToPage', {
      //     page: 'favoriteAdded',
      //     favoriteData: favoriteInfo,
      //     user: props.user
      //   })
      // }
    }

    const handleBookSubscribed = async (subscriptionInfo) => {
      console.log('📚 Book subscribed:', subscriptionInfo)
      
      try {
        // 调用后端 API 添加订阅
        const response = await userHeadService.addReservation(subscriptionInfo.bookId)
        console.log('📚 Reservation added via API:', response)
        
        // 通知父组件订阅已添加
        emit('navigateToPage', { 
          page: 'bookSubscribed', 
          subscriptionData: subscriptionInfo,
          user: props.user
        })
      } catch (error) {
        console.error('Failed to add reservation via API:', error)
        // 即使 API 失败，也通知父组件（可能只是本地更新）
        emit('navigateToPage', { 
          page: 'bookSubscribed', 
          subscriptionData: subscriptionInfo,
          user: props.user
        })
      }
    }

    const handleReviewAdded = async (reviewInfo) => {
      console.log('💬 Review added:', reviewInfo)
      
      try {
        // 调用后端 API 添加评论
        const response = await userHeadService.addReview(reviewInfo.bookId, {
          content: reviewInfo.content,
          rating: reviewInfo.rating
        })
        console.log('💬 Review added via API:', response)
        
        // 通知父组件评论已添加
        emit('navigateToPage', { 
          page: 'reviewAdded', 
          reviewData: reviewInfo,
          user: props.user
        })
      } catch (error) {
        console.error('Failed to add review via API:', error)
        // 即使 API 失败，也通知父组件（可能只是本地更新）
        emit('navigateToPage', { 
          page: 'reviewAdded', 
          reviewData: reviewInfo,
          user: props.user
        })
      }
    }

    // 生命周期
    const handlePopState = (e) => {
      const state = e?.state
      if (!state || state.scope !== 'userhead') return
      const page = state.page || PAGES.HOME
      
      // 更新页面状态
      currentPage.value = page
      
      // 根据页面类型更新相关状态
      if (page === PAGES.CATEGORY) {
        selectedCategory.value = state.category || null
        // 同步更新localStorage
        try {
          localStorage.setItem('currentPage', PAGES.CATEGORY)
          if (state.category) {
            localStorage.setItem('currentCategory', state.category)
          } else {
            localStorage.removeItem('currentCategory')
          }
          localStorage.removeItem('currentBookId')
        } catch (error) {
          console.warn('Failed to update localStorage on popstate:', error)
        }
      } else if (page === PAGES.BOOK_DETAILS) {
        bookDetailsData.value = { bookId: state.bookId || 1 }
        // 同步更新localStorage
        try {
          localStorage.setItem('currentPage', PAGES.BOOK_DETAILS)
          if (state.bookId) {
            localStorage.setItem('currentBookId', state.bookId)
          } else {
            localStorage.removeItem('currentBookId')
          }
          localStorage.removeItem('currentCategory')
        } catch (error) {
          console.warn('Failed to update localStorage on popstate:', error)
        }
      } else {
        // 其他页面（如HOME）
        selectedCategory.value = null
        bookDetailsData.value = null
        // 同步更新localStorage
        try {
          localStorage.setItem('currentPage', page)
          localStorage.removeItem('currentCategory')
          localStorage.removeItem('currentBookId')
        } catch (error) {
          console.warn('Failed to update localStorage on popstate:', error)
        }
      }
      
      console.log('🔄 Popstate handled:', page, state)
    }

    onMounted(() => {
      // 刷新时从localStorage恢复用户信息
      if (!props.user || !props.user.name) {
        const session = getUserFromStorage()
        if (session && session.name) {
          localUser.value = session
          console.log('📱 Restored user from localStorage:', session.name)
        }
      } else {
        localUser.value = props.user
        console.log('📱 User from props:', props.user.name)
      }
      
      // 尝试从localStorage恢复当前页面
      try {
        const savedPage = localStorage.getItem('currentPage')
        if (savedPage && Object.values(PAGES).includes(savedPage)) {
          // 如果是书籍详情页，同时恢复bookId
          if (savedPage === PAGES.BOOK_DETAILS) {
            const savedBookId = localStorage.getItem('currentBookId')
            if (savedBookId) {
              bookDetailsData.value = { bookId: savedBookId }
              currentPage.value = savedPage
              console.log('📖 Restored book details page with bookId:', savedBookId)
            } else {
              // 没有bookId则保持当前状态，不强制跳转
              console.log('⚠️ No bookId found for book details page, keeping current state')
            }
          } else if (savedPage === PAGES.CATEGORY) {
            // 如果是分类页面，同时恢复分类状态
            const savedCategory = localStorage.getItem('currentCategory')
            if (savedCategory) {
              selectedCategory.value = savedCategory
              currentPage.value = savedPage
              console.log('🏷️ Restored category page with category:', savedCategory)
            } else {
              // 没有分类则保持当前状态，不强制跳转
              console.log('⚠️ No category found for category page, keeping current state')
            }
          } else {
            currentPage.value = savedPage
            console.log('📄 Restored page from localStorage:', savedPage)
          }
        } else {
          // 没有保存的页面信息时，确保设置为HOME页面
          currentPage.value = PAGES.HOME
          console.log('📄 No saved page found, setting to HOME')
        }
      } catch (error) {
        console.warn('Failed to restore page from localStorage:', error)
      }
      
      loadCategories()
      console.log('📱 UserHead mounted for user:', localUser.value?.name || 'Unknown')
      
      // 确保页面状态有效，如果无效则重置为HOME
      if (!Object.values(PAGES).includes(currentPage.value)) {
        currentPage.value = PAGES.HOME
        console.log('⚠️ Invalid page state detected, resetting to HOME')
      }
      
      try { history.replaceState({ scope: 'userhead', page: currentPage.value }, '') } catch {}
      window.addEventListener('popstate', handlePopState)
    })

    onBeforeUnmount(() => {
      window.removeEventListener('popstate', handlePopState)
    })

    return {
      // 计算属性
      userName,
      userInitial,
      userEmail,
      
      // 响应式数据
      categories,
      currentPage,
      selectedCategory,
      bookDetailsData,
      PAGES,
      
      // 方法
      navigateTo,
      selectCategory,
      logout,
      handleUserUpdated,
      handleViewBookDetails,
      handleFavoriteAdded,
      handleBookSubscribed,
      handleReviewAdded
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

.card:hover {
  box-shadow: 0 10px 15px -3px rgba(0, 0, 0, 0.1), 0 4px 6px -2px rgba(0, 0, 0, 0.05);
  transform: translateY(-2px);
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
</style>
