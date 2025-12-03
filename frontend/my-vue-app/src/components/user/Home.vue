<template>
  <div class="h-full bg-gray-50 overflow-y-auto min-h-0" style="font-family: 'Noto Sans SC', sans-serif; background-color: #f7f9fc;">
    <main class="p-4 lg:p-6">
      <div class="container mx-auto">
        <!-- 搜索 -->
        <div class="mb-6">
          <div class="bg-white rounded-lg p-4 shadow-sm">
            <h2 class="text-lg font-medium text-gray-800 mb-4">Browse Books</h2>
            <div class="relative">
              <input 
                type="text" 
                v-model="searchQuery"
                @input="performSearch"
                @keypress="handleKeyPress"
                @focus="showSearchSuggestions"
                placeholder="Search for book name, author or keyword..." 
                class="input-field pl-5 pr-4 py-3 w-full rounded-lg focus:outline-none"
              />
              <button 
                @click="performSearch"
                class="absolute inset-y-0 right-0 flex items-center px-4 bg-indigo-600 text-white rounded-r-lg hover:bg-indigo-700 transition"
              >
                <iconify-icon icon="solar:magnifer-outline" width="25" height="25" class="text-white"></iconify-icon>
              </button>
            </div>
          </div>
        </div>
        
        <!-- 搜索结果统计 -->
        <div v-if="showSearchResults && searchResults.length > 0" class="mb-4">
          <div class="bg-blue-50 rounded-lg p-4">
            <div class="flex items-center justify-between">
              <div>
                <h3 class="font-medium text-blue-900">Search Results</h3>
                <p class="text-sm text-blue-700">Found {{ searchResults.length }} materials matching "{{ searchQuery }}"</p>
              </div>
              <button 
                @click="clearSearch"
                class="text-blue-600 hover:text-blue-800 text-sm font-medium"
              >
                Clear Search
              </button>
            </div>
          </div>
        </div>

        <!-- 无搜索结果 -->
        <div v-if="showSearchResults && searchResults.length === 0 && searchQuery" class="mb-8">
          <div class="text-center py-12">
            <iconify-icon icon="solar:magnifer-outline" width="48" height="48" class="text-gray-400 mx-auto mb-4"></iconify-icon>
            <h3 class="text-lg font-medium text-gray-900 mb-2">No materials found</h3>
            <p class="text-gray-500">No materials match your search for "{{ searchQuery }}"</p>
          </div>
        </div>
        
        <!-- 热门资料 / 搜索结果 -->
        <div class="mb-8">
          <div class="flex justify-between items-center mb-4" v-if="!showSearchResults">
            <h2 class="text-xl font-semibold text-gray-800">📚 Popular Books Collection</h2>
            <div class="text-sm text-gray-500">
              {{ popularBooks.length }} books available
            </div>
          </div>
          <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4">
            <!-- 搜索结果 -->
            <template v-if="showSearchResults">
              <div 
                v-for="book in searchResults" 
                :key="book.id"
                @click="viewBookDetails(book)"
                class="card p-4 search-result-item cursor-pointer"
                :data-score="book.matchScore"
              >
              <div class="relative">
                <img 
                  :src="book.image" 
                  :alt="book.title"
                  class="w-full h-40 object-cover rounded-lg mb-3"
                  @error="handleImageError"
                />
              </div>
              <h3 class="font-medium text-gray-800 mb-1" v-html="highlightSearchTerm(book.title, searchQuery)"></h3>
              <p class="text-gray-500 text-sm mb-2" style="margin-top: 5px;">Author: {{ book.description.split(' - ')[1] || 'Unknown' }}</p>
              <div class="flex items-center justify-between" style="margin-top: 10px;">
                <span class="resource-tag" v-html="highlightSearchTerm(book.category, searchQuery)"></span>
                <div class="flex items-center">
                  <iconify-icon icon="solar:bookmark-outline" class="text-gray-400 mr-1" width="14" height="14"></iconify-icon>
                  <span class="text-sm text-gray-500">{{ book.bookmarks }}</span>
                </div>
              </div>
              </div>
            </template>

            <!-- 热门图书 -->
            <template v-if="!showSearchResults">
              <div 
                v-for="book in popularBooks" 
                :key="book.bookId"
                @click="viewBookDetails(book)"
                class="block cursor-pointer"
              >
              <div class="card p-4">
                <div class="relative">
                  <img 
                    :src="getBookCover(book)" 
                    :alt="book.bookName"
                    class="w-full h-40 object-cover rounded-lg mb-3"
                    @error="handleImageError"
                  />
                </div>
                <h3 class="font-medium text-gray-800 mb-1">{{ book.bookName }}</h3>
                <p class="text-gray-500 text-sm mb-2" style="margin-top: 5px;">Author: {{ book.author }}</p>
                <div class="flex items-center justify-between" style="margin-top: 10px;">
                  <span class="resource-tag">{{ book.labelName }}</span>
                  <div class="flex items-center space-x-3">
                    <div class="flex items-center">
                      <iconify-icon icon="solar:bookmark-outline" class="text-gray-400 mr-1" width="14" height="14"></iconify-icon>
                      <span class="text-sm text-gray-500">{{ book.numFavorite }}</span>
                    </div>
                  </div>
                </div>
              </div>
              </div>
            </template>
          </div>
        </div>
      </div>
    </main>
    
    <!-- 底部内边距 -->
    <div style="width: 100%; height: 20px; background-color: #f7f9fc;"></div>
    
    <!-- ChatGPT 对话框组件 -->
    <ChatGptDialog />
  </div>
</template>

<script>
import { ref, reactive, computed, onMounted } from 'vue'
import ChatGptDialog from './ChatGptDialog.vue'

// API 服务类
class HomeService {
  constructor() {
    this.API_BASE = import.meta.env.VITE_API_BASE || 'http://localhost:8080'
  }

  async request(path, { method = 'GET', body, params } = {}) {
    const url = new URL(this.API_BASE + path, window.location.origin)
    
    // 处理查询参数
    if (params) {
      Object.entries(params).forEach(([k, v]) => {
        if (v != null) url.searchParams.set(k, v)
      })
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

  // 获取图书列表
  async getBooks(params) {
    return this.request('/api/books', { params })
  }

  // 获取热门图书
  async getPopularBooks() {
    return this.request('/api/books/popular')
  }

  // 搜索图书
  async searchBooks(query, params = {}) {
    return this.request('/api/books/search', {
      params: { q: query, ...params } 
    })
  }

  // 获取图书详情
  async getBookDetail(bookId) {
    return this.request(`/api/books/${bookId}`)
  }

  // 获取分类图书
  async getBooksByCategory(category) {
    return this.request('/api/books', { params: { category } })
  }

  // 获取所有标签
  async getAllLabels() {
    return this.request('/api/labels')
  }
}

export default {
  name: 'Home',
  components: {
    ChatGptDialog
  },
  emits: ['viewBookDetails'],
  setup(props, { emit }) {
    // 初始化 API 服务
    const homeService = new HomeService()
    // 响应式数据
    const searchQuery = ref('')
    const showSearchResults = ref(false)
    const searchResults = ref([])
    const popularBooks = ref([])
    const labelMap = ref({})  // 存储labelId -> labelName的映射
    
    // 静态资源导入 - 使用显式导入确保Vite处理
    const getImageUrl = (imagePath) => {
      // 图片映射表，确保Vite能正确处理这些资源
      const imageMap = {
        'covers/eng_drawing.jpg': () => import('../../assets/img/covers/eng_drawing.jpg'),
        'covers/data_analysis.jpg': () => import('../../assets/img/covers/data_analysis.jpg'),
        'covers/ml_intro.jpg': () => import('../../assets/img/covers/ml_intro.jpg'),
        'covers/python_web.jpg': () => import('../../assets/img/covers/python_web.jpg'),
        'covers/dataviz.jpg': () => import('../../assets/img/covers/dataviz.jpg'),
        'covers/ai_health.jpg': () => import('../../assets/img/covers/ai_health.jpg'),
        'covers/project_mgmt.jpg': () => import('../../assets/img/covers/project_mgmt.jpg'),
        'covers/med_stats.jpg': () => import('../../assets/img/covers/med_stats.jpg'),
        'img.jpg': () => import('../../assets/img/img.jpg')
      }
      
      // 同步返回路径，Vite会在构建时处理
      try {
        return `/src/assets/${imagePath}`
      } catch (error) {
        console.warn(`Image path error: ${imagePath}`, error)
        return '/src/assets/img/img.jpg'
      }
    }

    // 默认图片URL
    const defaultImageUrl = '/src/assets/img/img.jpg'

    // 删除假数据，完全依赖API

    // 材料数据库（用于搜索）- 从API数据动态构建
    const materialDatabase = computed(() => {
      return popularBooks.value.map(b => ({
        id: b.bookId,
        title: b.bookName,
        category: b.labelName || 'Uncategorized',
        description: `${b.bookName} - ${b.author}`,
        keywords: (b.bookName + ' ' + (b.labelName || '')).toLowerCase().split(/\s+/),
        bookmarks: b.numFavorite || 0,
        points: Math.floor((b.numFavorite || 0) / 10),
        image: getBookCover(b)
      }))
    })

    // 图片处理方法
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

    const highlightSearchTerm = (text, searchTerm) => {
      if (!searchTerm) return text
      const regex = new RegExp(`(${searchTerm})`, 'gi')
      return text.replace(regex, '<mark class="bg-yellow-200 px-1 rounded">$1</mark>')
    }

    const searchMaterials = (searchTerm) => {
      const searchWords = searchTerm.toLowerCase().split(/\s+/).filter(word => word.length > 0)
      const results = []

      materialDatabase.value.forEach(material => {
        let matchScore = 0
        let matchedFields = []

        // 检查标题匹配
        const titleWords = material.title.toLowerCase().split(/\s+/)
        searchWords.forEach(searchWord => {
          titleWords.forEach(titleWord => {
            if (titleWord.includes(searchWord) || searchWord.includes(titleWord)) {
              matchScore += 3 // 标题匹配权重最高
              matchedFields.push('title')
            }
          })
        })

        // 检查关键词匹配
        material.keywords.forEach(keyword => {
          searchWords.forEach(searchWord => {
            if (keyword.includes(searchWord) || searchWord.includes(keyword)) {
              matchScore += 2 // 关键词匹配权重中等
              matchedFields.push('keyword')
            }
          })
        })

        // 检查分类匹配
        if (material.category.toLowerCase().includes(searchTerm.toLowerCase())) {
          matchScore += 2
          matchedFields.push('category')
        }

        // 检查描述匹配
        if (material.description.toLowerCase().includes(searchTerm.toLowerCase())) {
          matchScore += 1
          matchedFields.push('description')
        }

        if (matchScore > 0) {
          results.push({
            ...material,
            matchScore,
            matchedFields: [...new Set(matchedFields)] // 去重
          })
        }
      })

      // 按匹配分数排序
      return results.sort((a, b) => b.matchScore - a.matchScore)
    }

    const performSearch = async () => {
      const searchTerm = searchQuery.value.trim()
      
      if (!searchTerm) {
        showSearchResults.value = false
        searchResults.value = []
        return
      }

      try {
        // 首先尝试调用后端 API 搜索
        const apiResults = await homeService.searchBooks(searchTerm)
        if (apiResults && Array.isArray(apiResults) && apiResults.length > 0) {
          searchResults.value = apiResults
          showSearchResults.value = true
          console.log('🔍 Search results from API:', apiResults.length)
          return
        }
      } catch (apiError) {
        console.warn('API search failed, falling back to local search:', apiError)
      }

      // API 失败时使用本地搜索
      const results = searchMaterials(searchTerm)
      searchResults.value = results
      showSearchResults.value = true
      console.log('🔍 Search results from local data:', results.length)
    }

    const clearSearch = () => {
      searchQuery.value = ''
      showSearchResults.value = false
      searchResults.value = []
    }

    const viewBookDetails = async (book) => {
      // 处理不同数据结构的兼容性
      const bookId = book.bookId || book.id
      const bookName = book.bookName || book.title
      const author = book.author || 'Unknown Author'
      
      console.log('📖 Viewing book details:', bookName)
      
      try {
        // 可选：调用后端 API 获取图书详细信息
        const bookDetail = await homeService.getBookDetail(bookId)
        console.log('📖 Book detail from API:', bookDetail)
        
        // 发送事件给父组件，包含详细信息
        emit('viewBookDetails', {
          bookId: bookId,
          bookName: bookName,
          author: author,
          ...book,
          ...bookDetail // 包含 API 返回的额外信息
        })
      } catch (error) {
        console.warn('Failed to get book detail from API, using basic info:', error)
        
        // API 失败时使用基本信息
        emit('viewBookDetails', {
          bookId: bookId,
          bookName: bookName,
          author: author,
          ...book
        })
      }
    }

    const handleKeyPress = (event) => {
      if (event.key === 'Enter') {
        performSearch()
      }
    }

    const showSearchSuggestions = () => {
      // 这里可以添加搜索建议功能
      console.log('显示搜索建议')
    }

    const loadPopularBooks = async () => {
      try {
        // 首先加载标签映射
        try {
          const labels = await homeService.getAllLabels()
          if (Array.isArray(labels)) {
            labels.forEach(label => {
              labelMap.value[label.labelId] = label.labelName
            })
            console.log('📋 Loaded labels:', Object.keys(labelMap.value).length)
          }
        } catch (labelError) {
          console.warn('Failed to load labels:', labelError)
        }

        // 调用后端 API 获取热门图书
        const apiData = await homeService.getPopularBooks()
        const books = Array.isArray(apiData) ? apiData : (apiData?.data || [])
        
        if (books.length > 0) {
          // 为每本书添加labelName
          popularBooks.value = books.slice(0, 8).map(book => ({
            ...book,
            labelName: labelMap.value[book.labelId] || `Label ${book.labelId}`
          }))
          console.log('📚 Loaded popular books from API:', books.length)
          
          // 预加载图片以提高性能
          popularBooks.value.forEach(book => {
            const img = new Image()
            img.src = getBookCover(book)
            img.onload = () => console.log(`✅ Image loaded: ${book.bookName}`)
            img.onerror = () => console.warn(`❌ Image failed: ${book.bookName}`)
          })
        } else {
          console.log('📚 No books available from API')
          popularBooks.value = []
        }
      } catch (error) {
        console.error('Failed to load popular books:', error)
        popularBooks.value = []
      }
    }

    // 生命周期
    onMounted(() => {
      loadPopularBooks()
      console.log('Home component mounted successfully')
    })

    return {
      // 响应式数据
      searchQuery,
      showSearchResults,
      searchResults,
      popularBooks,
      
      // 图片处理方法  
      getBookCover,
      handleImageError,
      getImageUrl,
      defaultImageUrl,
      
      // 搜索相关方法
      highlightSearchTerm,
      performSearch,
      clearSearch,
      handleKeyPress,
      showSearchSuggestions,
      
      // 导航方法
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

.resource-tag {
  background-color: #eef2ff;
  color: #4f46e5;
  font-size: 0.75rem;
  padding: 0.25rem 0.5rem;
  border-radius: 9999px;
}

.card h3 {
  white-space: nowrap;
  overflow: hidden;
  text-overflow: ellipsis;
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

.search-result-item {
  animation: fadeIn 0.3s ease-in-out;
}

@keyframes fadeIn {
  from {
    opacity: 0;
    transform: translateY(10px);
  }
  to {
    opacity: 1;
    transform: translateY(0);
  }
}

/* 搜索高亮样式 */
:deep(.bg-yellow-200) {
  background-color: #fef08a;
  padding: 0 4px;
  border-radius: 4px;
}
</style>
