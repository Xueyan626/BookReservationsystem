<template>
  <div class="h-full bg-gray-50 overflow-y-auto" style="font-family: 'Noto Sans SC', sans-serif; background-color: #f7f9fc;">
    <main class="p-4 lg:p-6">
      <div class="container mx-auto">
        <!-- 搜索区域 -->
        <div class="mb-6">
          <div class="bg-white rounded-lg p-4 shadow-sm">
            <h2 class="text-lg font-medium text-gray-800 mb-4">Browse Materials</h2>
            <div class="relative">
              <input 
                type="text" 
                v-model="searchQuery"
                @input="performSearch"
                @keypress="handleKeyPress"
                placeholder="Search for material name or keyword..." 
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
        <div v-if="showSearchResults && searchResults.length > 0" class="mb-6">
          <div class="col-span-full p-4 bg-blue-50 rounded-lg">
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
        
        <!-- 分类材料展示 -->
        <div class="mb-8">
          <div class="flex justify-between items-center mb-6">
            <h2 class="text-2xl font-bold text-gray-800">
              {{ showSearchResults ? 'Search Results' : `${categoryName} Materials` }}
            </h2>
            <div v-if="!showSearchResults && categoryMaterials.length > 0" class="text-sm text-gray-500">
              {{ categoryMaterials.length }} materials found
            </div>
          </div>

          <!-- 加载状态 -->
          <div v-if="isLoading" class="text-center py-12">
            <iconify-icon icon="solar:refresh-outline" width="48" height="48" class="text-indigo-600 mx-auto mb-4 animate-spin"></iconify-icon>
            <p class="text-gray-500">Loading materials...</p>
          </div>

          <!-- 空状态 -->
          <div v-else-if="!showSearchResults && categoryMaterials.length === 0" class="text-center py-12">
            <iconify-icon icon="solar:folder-open-outline" width="64" height="64" class="text-gray-400 mx-auto mb-4"></iconify-icon>
            <h3 class="text-lg font-medium text-gray-900 mb-2">No materials found</h3>
            <p class="text-gray-500">There are currently no materials in the {{ categoryName }} category.</p>
          </div>

          <!-- 材料网格 -->
          <div 
            v-else
            class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 xl:grid-cols-4 gap-6"
          >
            <!-- 搜索结果 -->
            <template v-if="showSearchResults">
              <div 
                v-for="material in searchResults" 
                :key="material.id"
                @click="viewBookDetails(material)"
                class="card p-4 search-result-item cursor-pointer"
                :data-score="material.matchScore"
              >
                <div class="relative">
                  <img 
                    :src="material.image" 
                    :alt="material.title"
                    class="w-full h-40 object-cover rounded-lg mb-3"
                    @error="handleImageError"
                  />
                </div>
                <h3 class="font-medium text-gray-800 mb-1" v-html="highlightSearchTerm(material.title, searchQuery)"></h3>
                <p class="text-gray-500 text-sm mb-2" style="margin-top: 5px;">Author: {{ material.author || 'Unknown' }}</p>
                <div class="flex items-center justify-between" style="margin-top: 10px;">
                  <span class="resource-tag" v-html="highlightSearchTerm(material.category, searchQuery)"></span>
                  <div class="flex items-center">
                    <iconify-icon icon="solar:bookmark-outline" class="text-gray-400 mr-1" width="14" height="14"></iconify-icon>
                    <span class="text-sm text-gray-500">{{ material.bookmarks }}</span>
                  </div>
                </div>
              </div>
            </template>

            <!-- 分类材料 -->
            <template v-else>
              <div 
                v-for="book in categoryMaterials" 
                :key="book.bookId"
                @click="viewBookDetails(book)"
                class="card p-4 cursor-pointer"
              >
                <div class="relative">
                  <img 
                    :src="getBookCover(book)" 
                    :alt="book.bookName"
                    class="w-full h-40 object-cover rounded-lg mb-3"
                    @error="handleImageError"
                  />
                </div>
                <h3 class="font-medium text-gray-800 mb-1">{{ book.bookName }}</h3>
                <p class="text-gray-500 text-sm mb-2" style="margin-top: 5px;">Author: {{ book.author || 'Unknown' }}</p>
                <div class="flex items-center justify-between" style="margin-top: 10px;">
                  <span class="resource-tag">{{ book.labelName || 'General' }}</span>
                  <div class="flex items-center space-x-3">
                    <div class="flex items-center">
                      <iconify-icon icon="solar:bookmark-outline" class="text-gray-400 mr-1" width="14" height="14"></iconify-icon>
                      <span class="text-sm text-gray-500">{{ book.numFavorite || 0 }}</span>
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
  </div>
</template>

<script>
import { ref, reactive, computed, onMounted, watch } from 'vue'

// API 服务类
class CategoryService {
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

  // 获取分类列表
  async getCategories() {
    return this.request('/api/labels')
  }

  // 获取分类下的图书
  async getBooksByCategory(category) {
    return this.request('/api/books/search-by-label', { params: { q: category } })
  }

  // 搜索图书
  async searchBooks(query, params = {}) {
    return this.request('/api/books/search', {
      params: { keyword: query, ...params }
    })
  }

  // 获取图书详情
  async getBookDetail(bookId) {
    return this.request(`/api/books/${bookId}`)
  }

  // 获取热门图书
  async getPopularBooks() {
    return this.request('/api/books/popular')
  }
}

export default {
  name: 'Category',
  props: {
    categoryName: {
      type: String,
      default: 'Engineering'
    },
    user: {
      type: Object,
      default: () => ({})
    }
  },
  emits: ['viewBookDetails'],
  setup(props, { emit }) {
    // 初始化 API 服务
    const categoryService = new CategoryService()
    // 响应式数据
    const isLoading = ref(false)
    const searchQuery = ref('')
    const showSearchResults = ref(false)
    const searchResults = ref([])
    const categoryMaterials = ref([])
    const labelMap = ref({})  // 存储labelId -> labelName的映射

    // 图片路径处理
    const getImageUrl = (imagePath) => {
      // 图片映射表，确保Vite能正确处理这些资源
      const imageMap = {
        'covers/eng_drawing.jpg': () => import('../../assets/img/covers/eng_drawing.jpg'),
        'covers/materials.jpg': () => import('../../assets/img/covers/materials.jpg'),
        'covers/project_mgmt.jpg': () => import('../../assets/img/covers/project_mgmt.jpg'),
        'covers/data_analysis.jpg': () => import('../../assets/img/covers/data_analysis.jpg'),
        'covers/python1.jpg': () => import('../../assets/img/covers/python1.jpg'),
        'covers/python2.jpg': () => import('../../assets/img/covers/python2.jpg'),
        'covers/med_stats.jpg': () => import('../../assets/img/covers/med_stats.jpg'),
        'covers/dataviz.jpg': () => import('../../assets/img/covers/dataviz.jpg'),
        'covers/python_web.jpg': () => import('../../assets/img/covers/python_web.jpg'),
        'covers/med_image.jpg': () => import('../../assets/img/covers/med_image.jpg'),
        'covers/ai_opt.jpg': () => import('../../assets/img/covers/ai_opt.jpg'),
        'covers/ai_health.jpg': () => import('../../assets/img/covers/ai_health.jpg'),
        'covers/ai_law.jpg': () => import('../../assets/img/covers/ai_law.jpg'),
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

    const defaultImageUrl = '/src/assets/img/img.jpg'

    // 搜索材料数据库 - 基于API获取的数据
    const materialDatabase = computed(() => {
      const allMaterials = []
      // 使用categoryMaterials中的数据，这些数据来自API
      categoryMaterials.value.forEach(book => {
        allMaterials.push({
          id: book.bookId,
          title: book.bookName,
          category: book.labelName,
          description: book.bookName,
          keywords: (book.bookName + ' ' + book.labelName + ' ' + (book.author || '')).toLowerCase().split(/\s+/),
          bookmarks: book.numFavorite || 0,
          points: Math.floor((book.numFavorite || 0) / 10),
          image: getBookCover(book),
          bookId: book.bookId,
          bookName: book.bookName,
          author: book.author
        })
      })
      return allMaterials
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

    const loadCategoryMaterials = async (category) => {
      isLoading.value = true

      try {
        // 首先加载标签映射
        try {
          const labels = await categoryService.getCategories()
          if (Array.isArray(labels)) {
            labels.forEach(label => {
              labelMap.value[label.labelId] = label.labelName
            })
            console.log('📋 Loaded labels:', Object.keys(labelMap.value).length)
          }
        } catch (labelError) {
          console.warn('Failed to load labels:', labelError)
        }

        console.log(`📚 Loading materials for category: ${category}`)

        // 只使用后端API获取数据
        try {
          const apiMaterials = await categoryService.getBooksByCategory(category)
          console.log(`📚 API response for ${category}:`, apiMaterials)
          console.log(`📚 First book from API:`, apiMaterials && apiMaterials[0])
          console.log(`📚 Label map:`, labelMap.value)

        if (Array.isArray(apiMaterials) && apiMaterials.length > 0) {
          // 为每本书获取完整信息
          const booksWithDetails = await Promise.all(
            apiMaterials.map(async (book) => {
              try {
                // 获取每本书的详细信息
                const bookDetail = await categoryService.getBookDetail(book.bookId)
                return {
                  ...book,
                  ...bookDetail,
                  labelName: labelMap.value[bookDetail?.labelId || book.labelId] || labelMap.value[book.labelId] || category,
                  author: bookDetail?.author || book.author || 'Unknown'
                }
              } catch (error) {
                console.warn(`Failed to get details for book ${book.bookId}:`, error)
                return {
                  ...book,
                  labelName: labelMap.value[book.labelId] || category,
                  author: book.author || 'Unknown'
                }
              }
            })
          )
          
          categoryMaterials.value = booksWithDetails
          console.log(`📚 ✅ Loaded ${apiMaterials.length} materials from API for ${category}`)
          console.log('📚 Sample book data:', categoryMaterials.value[0])
          } else {
            console.log(`📚 ⚠️ No materials found for ${category}`)
            categoryMaterials.value = []
          }
        } catch (apiError) {
          console.error(`📚 ❌ Failed to load materials from API for ${category}:`, apiError)
          categoryMaterials.value = []
        }

      } catch (error) {
        console.error('Failed to load category materials:', error)
        categoryMaterials.value = []
      } finally {
        isLoading.value = false
      }
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

    const highlightSearchTerm = (text, searchTerm) => {
      if (!searchTerm || !text) return text
      
      const searchWords = searchTerm.toLowerCase().split(/\s+/).filter(word => word.length > 0)
      let highlightedText = text
      
      searchWords.forEach(searchWord => {
        const regex = new RegExp(`(${searchWord})`, 'gi')
        highlightedText = highlightedText.replace(regex, '<mark class="bg-yellow-200 px-1 rounded">$1</mark>')
      })
      
      return highlightedText
    }

    const performSearch = async () => {
      const searchTerm = searchQuery.value.trim()
      
      if (!searchTerm) {
        showSearchResults.value = false
        searchResults.value = []
        return
      }

      try {
        // 确保标签映射已加载
        if (Object.keys(labelMap.value).length === 0) {
          try {
            const labels = await categoryService.getCategories()
            if (Array.isArray(labels)) {
              labels.forEach(label => {
                labelMap.value[label.labelId] = label.labelName
              })
              console.log('📋 Loaded labels for search:', Object.keys(labelMap.value).length)
            }
          } catch (labelError) {
            console.warn('Failed to load labels:', labelError)
          }
        }

        // 只使用后端 API 搜索
        const apiResults = await categoryService.searchBooks(searchTerm, { category: props.categoryName })
        if (apiResults && Array.isArray(apiResults) && apiResults.length > 0) {
          // 处理搜索结果，确保包含author字段和labelName
          searchResults.value = apiResults.map(book => ({
            ...book,
            id: book.bookId,
            bookId: book.bookId,
            title: book.bookName,
            bookName: book.bookName,
            author: book.author || 'Unknown',
            category: labelMap.value[book.labelId] || `Label ${book.labelId}`,
            labelName: labelMap.value[book.labelId] || `Label ${book.labelId}`,
            bookmarks: book.numFavorite || 0,
            image: getBookCover(book)
          }))
          showSearchResults.value = true
          console.log('🔍 Search results from API:', apiResults.length)
        } else {
          console.log('🔍 No search results found')
          searchResults.value = []
          showSearchResults.value = true
        }
      } catch (apiError) {
        console.error('API search failed:', apiError)
        searchResults.value = []
        showSearchResults.value = true
      }
    }

    const clearSearch = () => {
      searchQuery.value = ''
      searchResults.value = []
      showSearchResults.value = false
      console.log('🔄 Search cleared')
    }

    const handleKeyPress = (event) => {
      if (event.key === 'Enter') {
        performSearch()
      }
    }

    const viewBookDetails = async (book) => {
      // 处理不同数据结构的兼容性
      const bookId = book.bookId || book.id
      const bookName = book.bookName || book.title
      const author = book.author || 'Unknown Author'
      
      console.log('📖 Viewing book details:', bookName)
      
      try {
        // 可选：调用后端 API 获取图书详细信息
        const bookDetail = await categoryService.getBookDetail(bookId)
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

    // 监听分类变化
    watch(() => props.categoryName, (newCategory, oldCategory) => {
      if (newCategory !== oldCategory) {
        console.log('🔄 Category changed from', oldCategory, 'to', newCategory)
        clearSearch() // 清除搜索状态
        loadCategoryMaterials(newCategory)
      }
    })

    // 生命周期
    onMounted(() => {
      loadCategoryMaterials(props.categoryName)
      console.log('📂 Category component mounted:', props.categoryName)
    })


    // 返回响应式数据和方法
    return {
      // 响应式数据
      isLoading,
      searchQuery,
      showSearchResults,
      searchResults,
      categoryMaterials,
      
      // 计算属性
      materialDatabase,
      
      // 方法
      getBookCover,
      handleImageError,
      getImageUrl,
      defaultImageUrl,
      searchMaterials,
      highlightSearchTerm,
      performSearch,
      clearSearch,
      handleKeyPress,
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
  width: 160px;
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

/* 材料卡片样式 */
.line-clamp-2 {
  display: -webkit-box;
  -webkit-line-clamp: 2;
  line-clamp: 2;
  -webkit-box-orient: vertical;
  overflow: hidden;
}

.card {
  background: white;
  border-radius: 12px;
  box-shadow: 0 2px 4px rgba(0, 0, 0, 0.1);
  transition: all 0.3s ease;
  border: 1px solid rgba(0, 0, 0, 0.05);
}

.card:hover {
  transform: translateY(-2px);
  box-shadow: 0 8px 25px rgba(0, 0, 0, 0.15);
}

.search-result-item {
  position: relative;
}

.search-result-item::after {
  content: attr(data-score);
  position: absolute;
  top: 8px;
  right: 8px;
  background-color: rgba(79, 70, 229, 0.1);
  color: #4f46e5;
  padding: 2px 6px;
  border-radius: 12px;
  font-size: 10px;
  font-weight: 600;
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

/* 搜索高亮样式 */
:deep(mark) {
  background-color: #fef3c7;
  padding: 0 2px;
  border-radius: 2px;
  font-weight: 600;
}

/* 响应式优化 */
@media (max-width: 768px) {
  .card h3 {
    white-space: normal;
    line-height: 1.3;
  }
  
  .search-result-item::after {
    display: none;
  }
}
</style>
