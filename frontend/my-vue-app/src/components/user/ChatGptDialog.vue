<template>
  <div>
    <!-- 浮动按钮 -->
    <button
      @click="toggleDialog"
      class="fixed bottom-6 right-6 z-50 bg-indigo-600 text-white rounded-full shadow-lg hover:shadow-xl hover:bg-indigo-700 transition-all duration-300 w-14 h-14 flex items-center justify-center group"
      title="Chat with AI"
    >
      <iconify-icon 
        icon="solar:chat-round-dots-bold" 
        width="24" 
        height="24"
        class="group-hover:scale-110 transition-transform"
      ></iconify-icon>
    </button>

    <!-- 对话框遮罩 -->
    <Transition name="fade">
      <div
        v-if="isOpen"
        @click="closeDialog"
        class="fixed inset-0 bg-black bg-opacity-50 z-40"
      ></div>
    </Transition>

    <!-- 对话框 -->
    <Transition name="slide-up">
      <div
        v-if="isOpen"
        class="fixed bottom-6 right-6 w-[400px] h-[600px] bg-white rounded-lg shadow-2xl flex flex-col z-50 overflow-hidden"
      >
        <!-- 对话框头部 -->
        <div class="bg-gradient-to-r from-indigo-600 to-purple-600 text-white p-4 flex justify-between items-center">
          <div class="flex items-center gap-2">
            <iconify-icon icon="solar:chat-round-dots-bold" width="24" height="24"></iconify-icon>
            <h3 class="font-semibold">AI Assistant</h3>
          </div>
          <button
            @click="closeDialog"
            class="text-white hover:bg-white/20 rounded-full p-1 transition"
          >
            <iconify-icon icon="solar:close-circle-bold" width="24" height="24"></iconify-icon>
          </button>
        </div>

        <!-- 消息列表 -->
        <div
          ref="messagesContainer"
          class="flex-1 overflow-y-auto p-4 space-y-4"
          style="scroll-behavior: smooth;"
        >
          <!-- 欢迎消息 -->
          <div v-if="messages.length === 0" class="text-center text-gray-500 py-8">
            <iconify-icon icon="solar:chat-round-dots-bold" width="48" height="48" class="mx-auto mb-4 text-indigo-400"></iconify-icon>
            <p class="text-sm">Hello! I'm your AI assistant. How can I help you today?</p>
          </div>

          <!-- 消息项 -->
          <div
            v-for="(message, index) in messages"
            :key="index"
            :class="[
              'flex',
              message.role === 'user' ? 'justify-end' : 'justify-start'
            ]"
          >
            <div
              :class="[
                'max-w-[80%] rounded-lg px-4 py-2',
                message.role === 'user'
                  ? 'bg-indigo-600 text-white'
                  : 'bg-gray-100 text-gray-800'
              ]"
            >
              <!-- AI 标识 -->
              <div v-if="message.role === 'assistant'" class="flex items-center gap-2 mb-1">
                <iconify-icon icon="solar:robot-bold" width="16" height="16" class="text-indigo-600"></iconify-icon>
                <span class="text-xs font-medium text-indigo-600">AI Assistant</span>
              </div>
              <div v-else class="flex items-center gap-2 mb-1">
                <iconify-icon icon="solar:user-bold" width="16" height="16" class="text-white"></iconify-icon>
                <span class="text-xs font-medium text-white">You</span>
              </div>

              <!-- 消息内容 -->
              <div class="text-sm whitespace-pre-wrap break-words">{{ message.content }}</div>
              
              <!-- 加载动画 -->
              <div v-if="message.role === 'assistant' && message.loading" class="flex gap-1 mt-2">
                <div class="w-2 h-2 bg-indigo-600 rounded-full animate-bounce" style="animation-delay: 0s"></div>
                <div class="w-2 h-2 bg-indigo-600 rounded-full animate-bounce" style="animation-delay: 0.2s"></div>
                <div class="w-2 h-2 bg-indigo-600 rounded-full animate-bounce" style="animation-delay: 0.4s"></div>
              </div>
            </div>
          </div>
        </div>

        <!-- 输入框 -->
        <div class="border-t border-gray-200 p-4">
          <div class="flex gap-2">
            <input
              v-model="inputMessage"
              @keypress.enter="sendMessage"
              type="text"
              placeholder="Type your message..."
              class="flex-1 px-4 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-indigo-500"
              :disabled="isLoading"
            />
            <button
              @click="sendMessage"
              :disabled="!inputMessage.trim() || isLoading"
              class="bg-indigo-600 text-white px-4 py-2 rounded-lg hover:bg-indigo-700 transition disabled:opacity-50 disabled:cursor-not-allowed flex items-center justify-center"
            >
              <iconify-icon
                :icon="isLoading ? 'solar:refresh-outline' : 'solar:plain-2-bold'"
                width="20"
                height="20"
                :class="{ 'animate-spin': isLoading }"
              ></iconify-icon>
            </button>
          </div>
        </div>
      </div>
    </Transition>
  </div>
</template>

<script>
import { ref, nextTick } from 'vue'

// ChatGPT API 服务
class ChatGPTService {
  constructor() {
    this.API_BASE = import.meta.env.VITE_API_BASE || 'http://localhost:8080'
  }

  async chat(message, conversationHistory = []) {
    const url = `${this.API_BASE}/api/chat`
    
    const response = await fetch(url, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
      },
      body: JSON.stringify({
        message: message,
        history: conversationHistory.slice(-10) // 只发送最近10条消息作为上下文
      })
    })

    if (!response.ok) {
      const errorText = await response.text()
      throw new Error(`HTTP ${response.status}: ${errorText}`)
    }

    return await response.json()
  }
}

export default {
  name: 'ChatGptDialog',
  setup() {
    const chatService = new ChatGPTService()
    const isOpen = ref(false)
    const messages = ref([])
    const inputMessage = ref('')
    const isLoading = ref(false)
    const messagesContainer = ref(null)

    const toggleDialog = () => {
      isOpen.value = !isOpen.value
    }

    const closeDialog = () => {
      isOpen.value = false
    }

    const scrollToBottom = async () => {
      await nextTick()
      if (messagesContainer.value) {
        messagesContainer.value.scrollTop = messagesContainer.value.scrollHeight
      }
    }

    const sendMessage = async () => {
      if (!inputMessage.value.trim() || isLoading.value) return

      const userMessage = {
        role: 'user',
        content: inputMessage.value.trim()
      }

      messages.value.push(userMessage)
      const currentInput = inputMessage.value.trim()
      inputMessage.value = ''
      isLoading.value = true

      // 添加加载中的 AI 回复
      const loadingMessage = {
        role: 'assistant',
        content: '',
        loading: true
      }
      messages.value.push(loadingMessage)
      await scrollToBottom()

      try {
        // 准备对话历史
        const conversationHistory = messages.value
          .filter(m => !m.loading)
          .map(m => ({
            role: m.role,
            content: m.content
          }))

        // 调用 ChatGPT API
        const response = await chatService.chat(currentInput, conversationHistory)

        // 移除加载中的消息
        messages.value.pop()

        // 添加实际的 AI 回复
        messages.value.push({
          role: 'assistant',
          content: response.message || response.text || 'Sorry, I encountered an error.',
          loading: false
        })

      } catch (error) {
        console.error('Chat error:', error)
        
        // 移除加载中的消息
        messages.value.pop()

        // 添加错误消息
        messages.value.push({
          role: 'assistant',
          content: `Sorry, I encountered an error: ${error.message}. Please try again later.`,
          loading: false
        })
      } finally {
        isLoading.value = false
        await scrollToBottom()
      }
    }

    return {
      isOpen,
      messages,
      inputMessage,
      isLoading,
      messagesContainer,
      toggleDialog,
      closeDialog,
      sendMessage
    }
  }
}
</script>

<style scoped>
.fade-enter-active,
.fade-leave-active {
  transition: opacity 0.3s ease;
}

.fade-enter-from,
.fade-leave-to {
  opacity: 0;
}

.slide-up-enter-active,
.slide-up-leave-active {
  transition: all 0.3s ease;
}

.slide-up-enter-from {
  transform: translateY(20px) scale(0.95);
  opacity: 0;
}

.slide-up-leave-to {
  transform: translateY(20px) scale(0.95);
  opacity: 0;
}

@keyframes bounce {
  0%,
  100% {
    transform: translateY(0);
  }
  50% {
    transform: translateY(-10px);
  }
}

.animate-bounce {
  animation: bounce 0.5s infinite;
}

/* 自定义滚动条 */
.overflow-y-auto::-webkit-scrollbar {
  width: 6px;
}

.overflow-y-auto::-webkit-scrollbar-track {
  background: #f1f1f1;
  border-radius: 10px;
}

.overflow-y-auto::-webkit-scrollbar-thumb {
  background: #888;
  border-radius: 10px;
}

.overflow-y-auto::-webkit-scrollbar-thumb:hover {
  background: #555;
}
</style>
