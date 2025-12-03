<template>
  <div class="h-full bg-gray-50 overflow-y-auto min-h-0" style="font-family: 'Noto Sans SC', sans-serif; background-color: #f7f9fc;">
    <div class="flex h-full min-h-0">
      <main class="flex-1 p-4 lg:p-6 pb-24 md:pb-16 lg:pb-12 min-h-0">
        <div class="container mx-auto">
          <!-- 页面标题和操作区 -->
          <div class="flex justify-between items-center mb-6">
            <div>
              <h1 class="text-2xl font-bold text-gray-800 mb-2">My Favorite</h1>
              <p class="text-gray-600">Manage your favorite learning materials for quick access and study.</p>
            </div>
            
            <!-- 搜索区域 -->
            <div class="flex space-x-3">
              <div class="relative">
                <input 
                  type="text" 
                  v-model="searchQuery"
                  @input="performSearch"
                  @keypress="handleKeyPress"
                  placeholder="Search for favorite..." 
                  class="pl-10 pr-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-indigo-200 focus:border-indigo-600 outline-none transition-all"
                />
                <iconify-icon 
                  icon="solar:magnifer-outline" 
                  class="absolute left-3 top-1/2 transform -translate-y-1/2 text-gray-400" 
                  width="18" 
                  height="18"
                ></iconify-icon>
              </div>
            </div>
          </div>

          <!-- 统计信息 -->
          <div class="mb-4" v-if="filteredFavorites.length !== favorites.length">
            <p class="text-sm text-gray-500">
              Showing {{ filteredFavorites.length }} of {{ favorites.length }} favorites
              <button @click="clearSearch" class="text-indigo-600 hover:text-indigo-800 ml-2">
                Clear Search
              </button>
            </p>
          </div>

          <!-- 收藏列表 -->
          <div class="grid grid-cols-1 gap-4">
            <!-- 没有收藏的情况 -->
            <div v-if="favorites.length === 0 && !isLoading" class="text-center py-12">
              <iconify-icon icon="solar:bookmark-outline" width="64" height="64" class="text-gray-400 mx-auto mb-4"></iconify-icon>
              <h3 class="text-lg font-medium text-gray-900 mb-2">No favorites yet</h3>
              <p class="text-gray-500 mb-4">Start adding books to your favorites for easy access</p>
              <button 
                @click="navigateToHome"
                class="bg-indigo-600 text-white px-4 py-2 rounded-lg hover:bg-indigo-700 transition"
              >
                Browse Books
              </button>
            </div>

            <!-- 无搜索结果 -->
            <div v-else-if="filteredFavorites.length === 0 && searchQuery" class="text-center py-12">
              <iconify-icon icon="solar:magnifer-outline" width="64" height="64" class="text-gray-400 mx-auto mb-4"></iconify-icon>
              <h3 class="text-lg font-medium text-gray-900 mb-2">No results found</h3>
              <p class="text-gray-500">No favorites match your search for "{{ searchQuery }}"</p>
            </div>

            <!-- 加载状态 -->
            <div v-else-if="isLoading" class="text-center py-12">
              <iconify-icon icon="solar:refresh-outline" width="48" height="48" class="text-indigo-600 mx-auto mb-4 animate-spin"></iconify-icon>
              <p class="text-gray-500">Loading your favorites...</p>
            </div>

            <!-- 收藏书籍列表 -->
            <div 
              v-else
              v-for="favorite in filteredFavorites" 
              :key="favorite.bookId"
              class="card p-4 flex items-center justify-between resource-card cursor-pointer hover:shadow-lg transition-shadow"
              @click="viewBookDetails(favorite)"
            >
              <div class="flex items-center">
                <div class="w-10 h-10 rounded-lg overflow-hidden mr-4">
                  <img 
                    :src="getBookCover(favorite)" 
                    :alt="favorite.bookName"
                    class="w-full h-full object-cover"
                    @error="handleImageError"
                  />
                </div>
                <div>
                  <h3 class="font-medium text-gray-800">{{ favorite.bookName }}</h3>
                  <div class="flex items-center mt-1">
                    <span class="text-xs px-2 py-0.5 bg-indigo-50 text-indigo-600 rounded-full mr-2">
                      {{ favorite.labelName || 'General' }}
                    </span>
                    <span class="text-xs text-gray-500">Author: {{ favorite.author || 'Unknown' }}</span>
                  </div>
                </div>
              </div>
              
              <!-- 操作按钮 -->
              <div class="resource-actions flex space-x-1">
                <button 
                  @click.stop="removeFavorite(favorite)"
                  :disabled="removing === favorite.bookId"
                  class="p-1.5 rounded-full hover:bg-gray-100 disabled:opacity-50 disabled:cursor-not-allowed transition-colors"
                  :title="removing === favorite.bookId ? 'Removing...' : 'Remove from favorites'"
                >
                  <iconify-icon 
                    :icon="removing === favorite.bookId ? 'solar:refresh-outline' : 'solar:trash-bin-trash-outline'" 
                    width="18" 
                    height="18" 
                    class="text-gray-600"
                    :class="{ 'animate-spin': removing === favorite.bookId }"
                  ></iconify-icon>
                </button>
              </div>
            </div>
          </div>
        </div>
      </main>
    </div>

    <!-- 底部内边距 -->
    <div style="width: 100%; height: 0px; background-color: #f7f9fc;"></div>
  </div>
</template>

<script>
import { ref, reactive, computed, onMounted } from 'vue'

// API 服务类
class FavoriteService {
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

  // 获取收藏列表
  async getFavorites() {
    return this.request('/api/favorites')
  }

  // 添加收藏
  async addFavorite(bookId) {
    return this.request(`/api/books/${bookId}/favorite`, { method: 'POST' })
  }

  // 删除收藏
  async removeFavorite(bookId) {
    return this.request(`/api/favorites/${bookId}`, { method: 'DELETE' })
  }

  // 检查是否已收藏
  async checkFavorite(bookId) {
    return this.request(`/api/favorites/${bookId}/check`)
  }

  // 批量删除收藏
  async removeMultipleFavorites(bookIds) {
    return this.request('/api/favorites/batch', {
      method: 'DELETE', 
      body: { bookIds } 
    })
  }

  // 获取所有标签
  async getAllLabels() {
    return this.request('/api/labels')
  }
}

export default {
  name: 'Favorite',
  props: {
    user: {
      type: Object,
      default: () => ({})
    }
  },
  emits: ['navigateToHome', 'viewBookDetails'],
  setup(props, { emit }) {
    // 初始化 API 服务
    const favoriteService = new FavoriteService()
    // 响应式数据
    const isLoading = ref(false)
    const removing = ref(null)
    const searchQuery = ref('')
    const favorites = ref([])
    const labelMap = ref({})  // 存储labelId -> labelName的映射

    // 图片路径处理
    const getImageUrl = (imagePath) => {
      try {
        return `/src/assets/img/${imagePath}`
      } catch (error) {
        return '/src/assets/img/img.jpg'
      }
    }

    const defaultImageUrl = '/src/assets/img/img.jpg'

    // 假数据：收藏书籍列表
    const fakeFavorites = [
      { 
        bookId: 1, 
        bookName: 'Deep Learning: Theory and Practice', 
        author: 'Xiaoming Wang', 
        labelName: 'Engineering', 
        avatar: 'covers/eng_drawing.jpg' 
      },
      { 
        bookId: 2, 
        bookName: 'Algorithm and Data Structure Video Tutorial', 
        author: 'Li Ming', 
        labelName: 'Computer Science', 
        avatar: 'covers/data_analysis.jpg' 
      },
      { 
        bookId: 3, 
        bookName: 'Advanced Mathematics Knowledge Summary', 
        author: 'Wang Lei', 
        labelName: 'Mathematics', 
        avatar: 'covers/ml_intro.jpg' 
      },
      { 
        bookId: 4, 
        bookName: 'Python Web Development Guide', 
        author: 'Zhang San', 
        labelName: 'Programming', 
        avatar: 'covers/python_web.jpg' 
      },
      { 
        bookId: 5, 
        bookName: 'Data Visualization Fundamentals', 
        author: 'Liu Wei', 
        labelName: 'Data Science', 
        avatar: 'covers/dataviz.jpg' 
      },
      { 
        bookId: 6, 
        bookName: 'AI in Healthcare Applications', 
        author: 'Chen Yu', 
        labelName: 'Healthcare', 
        avatar: 'covers/ai_health.jpg' 
      }
    ]

    // 计算属性
    const filteredFavorites = computed(() => {
      if (!searchQuery.value.trim()) return favorites.value
      
      const query = searchQuery.value.toLowerCase().trim()
      return favorites.value.filter(favorite => {
        const title = favorite.bookName.toLowerCase()
        const category = (favorite.labelName || '').toLowerCase()
        const author = (favorite.author || '').toLowerCase()
        
        return title.includes(query) || 
               category.includes(query) || 
               author.includes(query)
      })
    })

    // 方法
    const getBookCover = (book) => {
      if (book.avatar) {
        return getImageUrl(book.avatar.replace(/^\/+/, ''))
      }
      return defaultImageUrl
    }

    const handleImageError = (event) => {
      console.warn('图片加载失败，使用默认图片:', event.target.src)
      event.target.src = defaultImageUrl
    }

    const performSearch = () => {
      // 搜索逻辑已在 computed 中处理
      console.log('🔍 Searching favorites for:', searchQuery.value)
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

    const viewBookDetails = async (favorite) => {
      console.log('📖 Viewing book details:', favorite.bookName)
      
      try {
        // 可选：调用后端 API 检查收藏状态
        const favoriteStatus = await favoriteService.checkFavorite(favorite.bookId)
        console.log('⭐ Favorite status from API:', favoriteStatus)
        
        // 发送事件给父组件，包含收藏状态信息
        emit('viewBookDetails', {
          bookId: favorite.bookId,
          bookName: favorite.bookName,
          author: favorite.author,
          isFavorited: favoriteStatus?.favorited ?? true,
          ...favorite
        })
      } catch (error) {
        console.warn('Failed to check favorite status from API, using basic info:', error)
        
        // API 失败时使用基本信息
        emit('viewBookDetails', {
          bookId: favorite.bookId,
          bookName: favorite.bookName,
          author: favorite.author,
          ...favorite
        })
      }
    }

    const removeFavorite = async (favorite) => {
      if (!confirm(`Are you sure you want to remove "${favorite.bookName}" from your favorites?`)) {
        return
      }

      removing.value = favorite.bookId
      
      try {
        // 调用后端 API 删除收藏
        const response = await favoriteService.removeFavorite(favorite.bookId)
        console.log('❌ Removed favorite via API:', response)
        
        // 从本地列表中移除
        const index = favorites.value.findIndex(f => f.bookId === favorite.bookId)
        if (index !== -1) {
          favorites.value.splice(index, 1)
        }
        
        console.log('❌ Removed favorite:', favorite.bookName)
        
      } catch (error) {
        console.error('Failed to remove favorite:', error)
        alert(error.message || 'Failed to remove favorite. Please try again.')
      } finally {
        removing.value = null
      }
    }

    const loadFavorites = async () => {
      isLoading.value = true

      try {
        // 首先加载标签映射
        try {
          const labels = await favoriteService.getAllLabels()
          if (Array.isArray(labels)) {
            labels.forEach(label => {
              labelMap.value[label.labelId] = label.labelName
            })
            console.log('📋 Loaded labels:', Object.keys(labelMap.value).length)
          }
        } catch (labelError) {
          console.warn('Failed to load labels:', labelError)
        }

        // 调用后端 API 获取收藏列表
        try {
          const apiFavorites = await favoriteService.getFavorites()
          if (Array.isArray(apiFavorites) && apiFavorites.length > 0) {
            // 把后端 Book → 前端 FavoriteCard 需要的 shape，并添加labelName
            favorites.value = apiFavorites.map(b => ({
              bookId: b.bookId,
              bookName: b.bookName,
              author: b.author,
              labelId: b.labelId,
              labelName: labelMap.value[b.labelId] || `Label ${b.labelId}`,
              // 修正 avatar：去掉开头的 /img/ 或 /，再交给 getImageUrl 拼
              avatar: (b.avatar || '').replace(/^\/?img\//, '').replace(/^\//, '')
            }))
            console.log('📚 Loaded favorites from API:', favorites.value.length, favorites.value)
          } else {
            console.log('📚 No favorites from API')
            favorites.value = []
          }
        } catch (apiError) {
          console.warn('Failed to load favorites from API, using default data:', apiError)
          favorites.value = []
        }

        console.log('📚 Loaded', favorites.value.length, 'favorites')

      } catch (error) {
        console.error('Failed to load favorites:', error)
        favorites.value = []
      } finally {
        isLoading.value = false
      }
    }

    // 生命周期
    onMounted(() => {
      loadFavorites()
      console.log('⭐ Favorite component mounted')
    })

    // 返回响应式数据和方法
    return {
      // 响应式数据
      isLoading,
      removing,
      searchQuery,
      favorites,
      filteredFavorites,
      
      // 方法
      getBookCover,
      handleImageError,
      performSearch,
      clearSearch,
      handleKeyPress,
      navigateToHome,
      viewBookDetails,
      removeFavorite
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

.folder-tag {
  position: absolute;
  top: 0;
  right: 0;
  background-color: #4f46e5;
  color: white;
  padding: 4px 10px;
  border-radius: 0 8px 0 8px;
  font-size: 0.75rem;
  font-weight: 500;
}

.resource-card {
  transition: all 0.2s ease;
}

.resource-card:hover .resource-actions {
  opacity: 1;
}

.resource-actions {
  opacity: 0;
  transition: opacity 0.2s ease;
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

/* 搜索高亮效果 */
.highlight {
  background-color: #fef08a;
  padding: 0 2px;
  border-radius: 2px;
}
</style>
