<template>
  <div class="h-full bg-gray-50 overflow-y-auto" style="font-family: 'Noto Sans SC', sans-serif; background-color: #f7f9fc;">
    <div class="container mx-auto px-4 py-6">
      <div class="flex flex-col lg:flex-row gap-6">
        <!-- 左侧内容区域 -->
        <div class="flex-1">
          <!-- 资料主要信息 -->
          <div class="bg-white rounded-lg shadow-sm p-6 mb-6">
            <div class="flex flex-col md:flex-row md:items-start gap-6">
              <!-- 资料封面 -->
              <div class="w-full md:w-48 flex-shrink-0">
                <div class="relative aspect-[3/4] bg-indigo-50 rounded-lg overflow-hidden flex items-center justify-center">
                  <img
                    :src="getBookCover(bookInfo)"
                    :alt="bookInfo.bookName"
                    class="w-full h-full object-cover"
                    @error="handleImageError"
                  />
                  <div v-if="!bookInfo.avatar" class="absolute inset-0 flex items-center justify-center">
                    <iconify-icon icon="solar:book-bold-duotone" width="64" height="64" class="text-indigo-600/70"></iconify-icon>
                  </div>
                </div>
              </div>

              <!-- 资料信息 -->
              <div class="flex-1">
                <div class="flex flex-col md:flex-row md:items-start md:justify-between gap-4">
                  <div>
                    <h1 class="text-2xl font-bold text-gray-900 mb-2">{{ bookInfo.bookName || 'Loading...' }}</h1>
                    <div class="flex items-center text-sm text-gray-600 mb-3">
                      <span class="flex items-center mr-4">
                        <iconify-icon icon="solar:user-outline" width="16" height="16" class="mr-1"></iconify-icon>
                        Author: <span class="ml-1">{{ bookInfo.author || 'Unknown' }}</span>
                      </span>
                    </div>
                  </div>

                  <div class="flex items-center space-x-2">
                    <button
                      @click="toggleFavorite"
                      :disabled="isProcessing"
                      :class="[
                        'flex items-center px-3 py-2 rounded-md transition-all',
                        isFavorited
                          ? 'bg-yellow-100 hover:bg-yellow-200 text-yellow-700'
                          : 'bg-gray-100 hover:bg-gray-200 text-gray-700',
                        { 'opacity-50 cursor-not-allowed': isProcessing }
                      ]"
                    >
                      <iconify-icon
                        :icon="isProcessing ? 'solar:refresh-outline' : (isFavorited ? 'solar:bookmark-bold' : 'solar:bookmark-outline')"
                        width="18"
                        height="18"
                        class="mr-1"
                        :class="{ 'animate-spin': isProcessing }"
                      ></iconify-icon>
                      <span class="text-sm">{{ isFavorited ? 'Favorited' : 'Favorite' }}</span>
                    </button>
                  </div>
                </div>

                <div class="border-t border-gray-100 my-4" style="margin-top: 1px;"></div>

                <h3 class="text-sm font-medium text-gray-500 mb-1">Description</h3>
                <div class="text-gray-700" style="font-size: 14px;">{{ bookInfo.description || '-' }}</div>

                <div class="mt-4 flex flex-col sm:flex-row sm:items-center gap-3" style="margin-top: 20px;">
                  <button
                    @click="handleReserve"
                    :disabled="isReserving"
                    :class="[
                      'flex items-center justify-center py-2.5 px-5 rounded-md w-full sm:w-auto transition-all duration-300 disabled:opacity-50 disabled:cursor-not-allowed',
                      isSubscribed
                        ? 'bg-green-600 hover:bg-green-700 text-white border-2 border-green-600'
                        : 'btn-primary text-white'
                    ]"
                  >
                    <iconify-icon
                      :icon="isReserving ? 'solar:refresh-outline' : (isSubscribed ? 'solar:check-circle-bold' : 'solar:download-outline')"
                      width="18"
                      height="18"
                      class="mr-2"
                      :class="{ 'animate-spin': isReserving }"
                    ></iconify-icon>
                    <span>
                      {{ isReserving ? 'Processing...' : (isSubscribed ? 'Subscribed' : 'Subscribe') }}
                    </span>
                  </button>
                </div>
              </div>
            </div>
          </div>

          <!-- 标签页导航 -->
          <div class="bg-white rounded-lg shadow-sm mb-6">
            <div class="border-b border-gray-200">
              <nav class="flex overflow-x-auto">
                <button
                  class="tab-button active"
                  @click="activeTab = 'reviews'"
                >
                  Comments
                </button>
              </nav>
            </div>

            <!-- 评价标签页 -->
            <div v-if="activeTab === 'reviews'" class="tab-content active p-6">
              <div class="flex flex-col md:flex-row md:items-start md:justify-between gap-6 mb-8">
                <div>
                  <h2 class="text-xl font-bold text-gray-900 mb-2">User Reviews</h2>
                  <div class="flex items-center">
                    <span class="text-sm text-gray-600">{{ reviews.length }} reviews in total</span>
                  </div>
                </div>

                <div class="w-full md:w-auto">
                  <button
                    @click="showReviewForm = !showReviewForm"
                    class="btn-primary flex items-center justify-center py-2.5 px-5 rounded-md text-white w-full"
                  >
                    <iconify-icon icon="solar:pen-bold" width="18" height="18" class="mr-2"></iconify-icon>
                    <span>{{ showReviewForm ? 'Cancel' : 'Review' }}</span>
                  </button>
                </div>
              </div>

              <!-- 写评价表单 -->
              <div v-if="showReviewForm" class="bg-gray-50 rounded-lg p-6 mb-8">
                <h3 class="text-lg font-medium text-gray-900 mb-4">Leave your review</h3>
                <form @submit.prevent="submitReview">
                  <div class="mb-4">
                    <textarea
                      v-model="newReview.content"
                      rows="4"
                      class="input-field w-full px-3 py-2 rounded-md"
                      placeholder="Share your thoughts on this book..."
                      required
                    ></textarea>
                  </div>
                  <div class="flex justify-end space-x-3">
                    <button
                      type="button"
                      @click="cancelReview"
                      class="px-4 py-2 border border-gray-300 rounded-md text-gray-700 bg-white hover:bg-gray-50"
                    >
                      Cancel
                    </button>
                    <button
                      type="submit"
                      :disabled="isSubmittingReview || !newReview.content.trim()"
                      class="btn-primary px-4 py-2 rounded-md text-white disabled:opacity-50 disabled:cursor-not-allowed"
                    >
                      {{ isSubmittingReview ? 'Submitting...' : 'Submit' }}
                    </button>
                  </div>
                </form>
              </div>

              <!-- 评价列表 -->
              <div class="space-y-6">
                <!-- 无评论状态 -->
                <div v-if="reviews.length === 0" class="text-center py-12">
                  <iconify-icon icon="solar:chat-round-outline" width="64" height="64" class="text-gray-400 mx-auto mb-4"></iconify-icon>
                  <h3 class="text-lg font-medium text-gray-900 mb-2">No reviews yet</h3>
                  <p class="text-gray-500 mb-4">Be the first to share your thoughts about this book</p>
                  <button
                    @click="showReviewForm = true"
                    class="bg-indigo-600 text-white px-4 py-2 rounded-lg hover:bg-indigo-700 transition"
                  >
                    Write Review
                  </button>
                </div>

                <!-- 评论列表 -->
                <div
                  v-else
                  v-for="review in reviews"
                  :key="review.id"
                  class="review-card bg-white p-5 rounded-lg shadow-sm"
                >
                  <div class="flex items-start justify-between mb-3">
                    <div class="flex items-start">
                      <div class="w-10 h-10 rounded-full bg-blue-100 flex items-center justify-center flex-shrink-0 mr-3">
                        <span class="font-medium text-blue-700">{{ review.initial || (review.user && review.user[0]) || '?' }}</span>
                      </div>
                      <div>
                        <div class="flex items-center">
                          <h4 class="font-medium text-gray-900 mr-2">{{ review.user }}</h4>
                        </div>
                        <div class="flex items-center">
                          <span class="text-xs text-gray-500">{{ review.date }}</span>
                        </div>
                      </div>
                    </div>
                  </div>
                  <p class="text-gray-700 mb-3">{{ review.content }}</p>
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>

    <!-- 底部内边距 -->
    <div style="width: 100%; height: 20px; background-color: #f7f9fc;"></div>
  </div>
</template>

<script>
import { ref, reactive, computed, onMounted } from 'vue'

// API 服务类
class BookDetailsService {
  constructor() {
    // 不要把 /api 写在 BASE 里，BASE 只放域名端口
    this.API_BASE = import.meta.env.VITE_API_BASE || 'http://localhost:8080'
  }

  // 确保所有 path 都有 /api 前缀
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

    // 组装请求头：强制带 X-USER-ID（从 localStorage 或 props 里取不到就直接抛错，避免"静默失败"）
    const headers = { Accept: 'application/json' }
    if (body != null) headers['Content-Type'] = 'application/json'

// 登录成功后本地会有 userSession.userId；没有就不加头，让接口自己判定是否需要登录
    const session = JSON.parse(localStorage.getItem('userSession') || '{}')
    const uid = session?.userId
    if (uid != null) headers['X-USER-ID'] = String(uid)

// 调试
    console.log('[Favorite][request]', method, url.toString(), headers)

    const res = await fetch(url.toString(), {
      method,
      headers,
      // 注意：不要随便加 credentials: "include"，与后端 Cookie 会话无关时会触发 CORS 复杂预检
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

  // 详情/评论/收藏/订阅接口全部统一到 /api
  getBookDetail(bookId) {
    return this.request(`/books/${bookId}`)
  }
  getReviews(bookId) {
    return this.request(`/comments/book/${bookId}`)
  }
  addReview(bookId, data) {
    return this.request(`/comments/book/${bookId}`, { method: 'POST', body: data })
  }

  // 收藏
  // addFavorite(bookId) {
  //   return this.request(`/favorites/toggle`, { method: 'POST', body: { bookId } })
  // }
  addFavorite(bookId)  { return this.request(`/books/${bookId}/favorite`, { method: 'POST' }) }

  removeFavorite(bookId) {
    return this.request(`/favorites/${bookId}`, { method: 'DELETE' })
  }
  checkFavorite(bookId) {
    return this.request(`/favorites/${bookId}/check`)
  }

  // 订阅（之前你这里走的是 /books 而不是 /api/books，顺手一起改）
  addReservation(bookId) { return this.request('/reservations', { method: 'POST', body: { bookId } }) }
  removeReservation(bookId) { return this.request('/reservations/cancel', { method: 'POST', body: { bookId } }) }
  checkReservation(bookId) {
    return this.request(`/reservations/${bookId}/check`)
  }

  // 新增：借阅（预约）书籍接口
  reserveBook(userId, bookId) {
    return this.request('/reservations/reserve', { 
      method: 'POST', 
      body: { userId, bookId } 
    })
  }

  // 新增：取消预约接口
  cancelReservation(userId, reservationId) {
    return this.request('/reservations/cancel', { 
      method: 'POST', 
      body: { userId, reservationId } 
    })
  }

  // 新增：还书接口
  returnBook(userId, reservationId) {
    return this.request('/reservations/return', { 
      method: 'POST', 
      body: { userId, reservationId } 
    })
  }
}


export default {
  name: 'BookDetails',
  props: {
    bookId: {
      type: [String, Number],
      default: 1
    },
    user: {
      type: Object,
      default: () => ({})
    }
  },
  emits: ['favoriteAdded', 'subscribed', 'unsubscribed', 'reviewAdded'],
  setup(props, { emit }) {
    // 初始化 API 服务
    const bookDetailsService = new BookDetailsService()
    // 响应式数据
    const isLoading = ref(false)
    const isProcessing = ref(false)
    const isSubscribing = ref(false)
    const isSubscribed = ref(false)
    const isSubmittingReview = ref(false)
    const isFavorited = ref(false)
    const activeTab = ref('reviews')
    const showReviewForm = ref(false)

    // 新增：借阅相关状态
    const isReserving = ref(false)

    //是否收藏状态检测
    const initFavoriteStatus = async () => {
      try {
        const res = await bookDetailsService.checkFavorite(props.bookId)
        isFavorited.value = !!res?.favorited
      } catch (e) {
        console.warn('initFavoriteStatus failed:', e)
      }
    }
    onMounted(() => {
      loadBookInfo()
      loadReviews()
      initFavoriteStatus() // ← 别漏
    })


    // 书籍信息
    const bookInfo = reactive({
      bookId: props.bookId || 1,
      bookName: '',
      author: '',
      description: '',
      numFavorite: 0,
      numReservation: 0,
      labelId: 1,
      avatar: ''
    })

    // 评论数据
    const reviews = ref([])
    const newReview = reactive({
      content: ''
    })

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
    const currentUserName = computed(() => props.user?.name || 'User')

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

    const loadBookInfo = async () => {
      isLoading.value = true

      try {
        // 先清空 bookInfo，避免旧数据残留
        Object.assign(bookInfo, {
          bookId: props.bookId || 1,
          bookName: '',
          author: '',
          description: '',
          numFavorite: 0,
          numReservation: 0,
          labelId: 1,
          avatar: ''
        })

        // 调用后端 API 获取图书详情
        try {
          const bookData = await bookDetailsService.getBookDetail(props.bookId)
          if (bookData) {
            Object.assign(bookInfo, bookData)
            console.log('📖 Book info loaded from API:', bookData.bookName)
          } else {
            console.log('📖 No book data from API')
          }
        } catch (apiError) {
          console.warn('Failed to load book info from API:', apiError)
        }

        console.log('📖 Book info loaded:', bookInfo.bookName)

      } catch (error) {
        console.error('Failed to load book info:', error)
      } finally {
        isLoading.value = false
      }
    }


    const loadReviews = async () => {
      try {
        // 先清空评论列表
        reviews.value = []
        
        const reviewList = await bookDetailsService.getReviews(props.bookId)
        if (Array.isArray(reviewList)) {
          reviews.value = reviewList.map(r => ({
            id: r.commentId,
            user: r.authorName || `User #${r.authorId}`,  // 显示用户名或用户ID
            date: r.createDate?.split('T')[0], // 提取日期部分
            content: r.content,
            initial: (r.authorName || 'U')[0]?.toUpperCase() || 'U'  // 用户名首字母
          }))
        }
      } catch (err) {
        console.error('❌ Failed to load reviews:', err)
      }
    }

    const toggleFavorite = async () => {

      // 新增：未登录直接提示
      const session = JSON.parse(localStorage.getItem('userSession') || '{}')
      if (!session?.userId) {
        alert('Please login as a user to use Favorite')
        return
      }

      isProcessing.value = true
      try {
        if (isFavorited.value) {
          await bookDetailsService.removeFavorite(props.bookId)
          isFavorited.value = false
          console.log('✅ Unfavorited book:', props.bookId)
        } else {
          await bookDetailsService.addFavorite(props.bookId)
          isFavorited.value = true  // 直接设置为true，因为操作成功后应该显示已收藏
          console.log('✅ Favorited book:', props.bookId)
        }
      } catch (error) {
        console.error('Favorite operation failed:', error)
        alert(error?.message || 'Favorite operation failed.')
      } finally {
        isProcessing.value = false
      }
    }


    const subscribeToBook = async () => {
      isSubscribing.value = true

      try {
        // 调用后端 API 添加订阅
        try {
          await bookDetailsService.addReservation(props.bookId)
          console.log('📚 Subscribed to book via API')
        } catch (apiError) {
          console.warn('Failed to subscribe via API, but continuing:', apiError)
        }

        // 订阅成功，更新状态
        isSubscribed.value = true

        alert('Subscribed successfully!')
        console.log('📚 Subscribed to book:', bookInfo.bookName)

        emit('subscribed', {
          bookId: props.bookId,
          bookName: bookInfo.bookName
        })

      } catch (error) {
        console.error('Subscribe failed:', error)
        alert('Subscription failed, please try again')
      } finally {
        isSubscribing.value = false
      }
    }

    const unsubscribeFromBook = async () => {
      if (!confirm(`Are you sure you want to unsubscribe from "${bookInfo.bookName}"?`)) {
        return
      }

      isSubscribing.value = true

      try {
        // 调用后端 API 删除订阅
        try {
          await bookDetailsService.removeReservation(props.bookId)
          console.log('❌ Unsubscribed from book via API')
        } catch (apiError) {
          console.warn('Failed to unsubscribe via API, but continuing:', apiError)
        }

        // 取消订阅成功，更新状态
        isSubscribed.value = false

        alert('Unsubscribed successfully!')
        console.log('❌ Unsubscribed from book:', bookInfo.bookName)

        emit('unsubscribed', {
          bookId: props.bookId,
          bookName: bookInfo.bookName
        })

      } catch (error) {
        console.error('Unsubscribe failed:', error)
        alert('取消订阅失败，请重试')
      } finally {
        isSubscribing.value = false
      }
    }

    const submitReview = async () => {
      if (!newReview.content.trim()) {
        alert('Please enter your review content.')
        return
      }

      const session = JSON.parse(localStorage.getItem('userSession') || '{}')
      const userId = session?.userId
      if (!userId) {
        alert('Please login first to submit a review.')
        return
      }

      isSubmittingReview.value = true

      try {
        // 创建新评论对象
        const review = {
          id: Date.now(),
          user: currentUserName.value,
          initial: currentUserName.value[0]?.toUpperCase() || 'U',
          date: new Date().toISOString().slice(0, 10),
          content: newReview.content.trim()
        }

        // 调用后端 API 添加评论
        try {
          const response = await bookDetailsService.addReview(props.bookId, {
            content: review.content,
            authorId: userId,
            authorType: 0
          })
          console.log('💬 Review submitted via API:', response)

          // 重置表单
          newReview.content = ''
          showReviewForm.value = false

          // 重新加载评论列表
          await loadReviews()

          // 等待DOM更新完成后再显示弹窗
          await new Promise(resolve => setTimeout(resolve, 100))

          alert('Review submitted successfully!')
        } catch (apiError) {
          console.warn('Failed to submit review via API, using local addition:', apiError)
          // API 失败时本地添加
          reviews.value.unshift(review)
          // 重置表单
          newReview.content = ''
          showReviewForm.value = false
        }

        console.log('💬 Review submitted:', review.content)

        emit('reviewAdded', {
          bookId: props.bookId,
          review: review
        })

      } catch (error) {
        console.error('Submit review failed:', error)
        alert('Submission failed, please try again')
      } finally {
        isSubmittingReview.value = false
      }
    }

    const cancelReview = () => {
      newReview.content = ''
      showReviewForm.value = false
    }

    // 新增：借阅相关函数（保持UI为订阅模式，但实际调用借阅接口）
    const handleReserve = async () => {
      const session = JSON.parse(localStorage.getItem('userSession') || '{}')
      const userId = session?.userId
      
      if (!userId) {
        alert('Please login as a user first')
        return
      }

      isReserving.value = true
      try {
        const response = await bookDetailsService.reserveBook(userId, props.bookId)
        console.log('📚 Subscribe/Reserve successful:', response)
        alert(response?.message || 'Subscribed successfully!')
        
        // 更新订阅状态
        isSubscribed.value = true
        
        emit('subscribed', {
          bookId: props.bookId,
          bookName: bookInfo.bookName
        })
      } catch (error) {
        console.error('Subscribe/Reserve failed:', error)
        alert(error?.message || 'Subscription failed, please try again')
      } finally {
        isReserving.value = false
      }
    }

    // 生命周期
    onMounted(() => {
      loadBookInfo()
      loadReviews()
      initFavoriteStatus()
      console.log('📚 BookDetails component mounted for book ID:', props.bookId)
    })

    // 返回响应式数据和方法
    return {
      // 响应式数据
      isLoading,
      isProcessing,
      isSubscribing,
      isSubscribed,
      isSubmittingReview,
      isFavorited,
      activeTab,
      showReviewForm,
      bookInfo,
      reviews,
      newReview,

      // 新增：借阅相关状态
      isReserving,

      // 计算属性
      currentUserName,

      // 方法
      getBookCover,
      handleImageError,
      toggleFavorite,
      subscribeToBook,
      unsubscribeFromBook,
      submitReview,
      cancelReview,

      // 新增：借阅相关方法
      handleReserve
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

.tag {
  display: inline-flex;
  align-items: center;
  padding: 0.25rem 0.75rem;
  border-radius: 9999px;
  font-size: 0.75rem;
  font-weight: 500;
  background-color: #eef2ff;
  color: #4f46e5;
  margin-right: 0.5rem;
  margin-bottom: 0.5rem;
}

.tab-button {
  position: relative;
  padding: 0.75rem 1.25rem;
  font-weight: 500;
  color: #6b7280;
  transition: all 0.2s ease;
}

.tab-button.active {
  color: #4f46e5;
}

.tab-button.active::after {
  content: '';
  position: absolute;
  bottom: 0;
  left: 0;
  width: 100%;
  height: 2px;
  background-color: #4f46e5;
}

.tab-content {
  display: none;
}

.tab-content.active {
  display: block;
}

.review-card {
  transition: all 0.3s ease;
}

.review-card:hover {
  transform: translateY(-2px);
  box-shadow: 0 10px 15px -3px rgba(0, 0, 0, 0.1), 0 4px 6px -2px rgba(0, 0, 0, 0.05);
}

.related-item {
  transition: all 0.3s ease;
}

.related-item:hover {
  transform: translateY(-2px);
  box-shadow: 0 10px 15px -3px rgba(0, 0, 0, 0.1), 0 4px 6px -2px rgba(0, 0, 0, 0.05);
}

.star-rating {
  display: inline-flex;
}

.star-rating iconify-icon {
  color: #f59e0b;
}

.toc-link {
  display: block;
  padding: 0.5rem 0;
  color: #4b5563;
  transition: all 0.2s ease;
  border-left: 2px solid transparent;
  padding-left: 1rem;
}

.toc-link:hover {
  color: #4f46e5;
  background-color: #f3f4f6;
}

.toc-link.active {
  color: #4f46e5;
  border-left-color: #4f46e5;
  background-color: #eef2ff;
}

.resource-preview {
  max-height: 500px;
  overflow-y: auto;
  border: 1px solid #e5e7eb;
  border-radius: 0.5rem;
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

/* 收藏按钮特殊效果 */
.favorite-button {
  transition: all 0.3s ease;
}

.favorite-button:hover {
  transform: scale(1.05);
}

/* 评论卡片特殊效果 */
.review-card {
  animation: fadeInUp 0.5s ease-out;
}

@keyframes fadeInUp {
  from {
    opacity: 0;
    transform: translateY(20px);
  }
  to {
    opacity: 1;
    transform: translateY(0);
  }
}
</style>
