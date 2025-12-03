# ChatGPT 集成说明

## 概述

在你的图书馆预约系统中已经成功集成了 ChatGPT 对话框功能。用户现在可以通过右下角的浮动按钮与 AI 助手聊天。

## 功能特点

✅ **浮动对话框** - 右下角的圆形按钮，点击即可打开聊天窗口  
✅ **美观的 UI** - 现代化的渐变设计和流畅的动画效果  
✅ **实时响应** - AI 助手会即时回复你的问题  
✅ **上下文记忆** - 保持对话的上下文，提供连贯的回答  
✅ **书籍推荐** - 🤖 **智能书籍推荐功能** - AI 会从你的数据库中推荐真实存在的热门书籍！  

## 文件位置

### 前端文件
- `frontend/my-vue-app/src/components/user/ChatGptDialog.vue` - ChatGPT 对话框组件
- `frontend/my-vue-app/src/components/user/Home.vue` - 已集成 ChatGptDialog 组件

### 后端文件
- `library-reservation-system/src/main/java/.../controller/ChatController.java` - ChatGPT API 控制器
- `library-reservation-system/src/main/java/.../service/ChatService.java` - ChatGPT 服务层

## 使用方法

### 当前状态（Mock 模式）

目前系统使用**模拟响应**模式，不需要 API key 即可使用。系统会根据用户的消息智能回复：

- 关于"book"的询问 → 推荐热门书籍
- 关于"reserve"的询问 → 解释如何预约
- 问候语 → 友好地回复
- 帮助请求 → 提供使用指南

### 启用真实的 ChatGPT API（可选）

如果你想使用真实的 OpenAI ChatGPT API：

1. **获取 OpenAI API Key**
   - 访问 https://platform.openai.com/
   - 注册账户并获取 API key

2. **配置 API Key**
   
   编辑 `library-reservation-system/src/main/resources/application.properties`：
   
   ```properties
   # 取消注释并填入你的 API key
   openai.api.key=sk-your-actual-api-key-here
   openai.api.url=https://api.openai.com/v1/chat/completions
   ```

3. **更新 ChatService.java**
   
   取消注释真实的 API 调用代码（目前代码中有 mock 响应作为备选）

4. **重新编译并运行后端**
   
   ```bash
   cd library-reservation-system
   mvn clean install
   mvn spring-boot:run
   ```

## 如何测试

1. **启动后端服务器**
   ```bash
   cd library-reservation-system
   mvn spring-boot:run
   ```

2. **启动前端开发服务器**
   ```bash
   cd frontend/my-vue-app
   npm run dev
   ```

3. **打开浏览器**
   - 访问 http://localhost:5173 (Vite 默认端口)
   - 登录后进入首页
   - 查看右下角的圆形按钮
   - 点击按钮打开 AI 对话框

4. **测试智能书籍推荐功能** ⭐
   
   **通用推荐**（最受欢迎的书籍）：
   - "推荐一些书"
   - "Recommend some books"
   - "有什么好书"
   
   **按类别推荐**（支持关键词匹配）：
   - "推荐一些科技书籍" / "Recommend some technology books"
   - "推荐一些教育书籍" / "Recommend some education books"
   - "推荐一些工程书籍" / "Recommend some engineering books"
   - 任何数据库中的类别关键词都会匹配！
   
   AI 会：
   - 智能识别类别关键词
   - 从该类别中按受欢迎度推荐书籍
   - 如果没有该类别的书，会友好地建议其他选择

5. **测试其他功能**
   
   - "Hello" - 友好的问候
   - "Help" - 获取帮助信息  
   - "How do I reserve a book?" - 学习如何预约书籍
   - "Search books" - 了解如何搜索书籍

## 🤖 书籍推荐功能详解

### 工作原理

当用户请求书籍推荐时（使用相关关键词），系统会：

1. **检测推荐意图** - AI 识别以下关键词触发书籍推荐：
   - 中文：推荐、推荐一些、推荐一些书、好书、有什么书
   - 英文：recommend、recommend books、recommend some、what books、suggest books

2. **智能类别识别** 🎯 - 系统会检查用户消息中是否包含类别关键词：
   - 自动从数据库中获取所有类别（label_name）
   - 匹配用户消息中包含的类别名称
   - 如果匹配到类别，优先推荐该类别的书籍
   - 如果没有类别，推荐最受欢迎的通用书籍

3. **查询数据库** - 从 `book` 表中获取数据：
   - 如果指定了类别：按类别筛选后按收藏数排序
   - 如果未指定类别：按收藏数（`num_favorite`）排序
   - 获取最受欢迎的书籍
   - 限制返回前 5 本

4. **友好的格式化输出** - 返回格式化的推荐列表，使用 emoji 增强可读性：
   ```
   📚 Here are some great book recommendations from our collection:
   
   1. **Book Name**
      Author: Author Name
      Status: ✅ Available / ⏳ Currently Reserved
      About: Description...
      ⭐ Loved by X readers
   ```

4. **显示书籍状态** - 根据 `quantity` 字段显示可用性：
   - `quantity > 0`: ✅ Available（可借）
   - `quantity = 0`: ⏳ Currently Reserved（已预订）

### 示例对话

**示例 1：通用推荐**
```
用户: 推荐一些书

AI: 🌟 Here are some popular books I'd recommend:

🥇 1. **Machine Learning Fundamentals**
   👤 Author: Zheng Liu
   📊 Status: ✅ Available Now
   📝 About: Comprehensive introduction to machine learning concepts and practical applications...
   ⭐⭐⭐ Loved by 45 readers!

🥈 2. **Advanced Python Techniques**
   👤 Author: John Smith
   📊 Status: ✅ Available Now
   📝 About: Advanced programming techniques in Python for experienced developers...
   ⭐⭐ Loved by 38 readers!

💡 Tip: Click any book to see details and reserve it!
🎯 Want a different category? Try saying '推荐一些[类别]书籍'
```

**示例 2：按类别推荐**
```
用户: 推荐一些科技书籍

AI: 🌟 Here are some great '科技' books I found:

🥇 1. **AI and Machine Learning**
   👤 Author: Tech Expert
   📊 Status: ✅ Available Now
   📝 About: Deep dive into artificial intelligence and machine learning...
   ⭐⭐⭐ Loved by 52 readers!

🥈 2. **Data Science Fundamentals**
   👤 Author: Data Guru
   📊 Status: ⏳ Reserved
   📝 About: Complete guide to data science...
   ⭐⭐ Loved by 31 readers!

💡 Tip: Click any book to see details and reserve it!
🎯 Want a different category? Try saying '推荐一些[类别]书籍'
```

**示例 3：友好的引导**
```
用户: Hello

AI: 👋 Hi there! I'm your friendly library AI assistant!

I can help you with:
✨ Book recommendations (try '推荐一些书' or 'recommend books')
🎯 Category-specific books (try '推荐一些科技书籍' or 'recommend science books')
📖 Learn about book reservations
🔍 Search for specific titles
❓ General questions about our library

What can I do for you today? 😊
```

### 定制推荐逻辑

你可以修改 `ChatService.java` 中的推荐逻辑：

```java
// 当前：按收藏数推荐
List<Book> popularBooks = bookRepository.findMostPopularBooks();

// 可选：按预约数推荐
// List<Book> popularBooks = bookRepository.findMostReservedBooks();

// 可选：按标签推荐特定类别
// List<Book> books = bookRepository.findByLabelId(labelId);
```

## API 端点

ChatGPT 功能使用以下 API 端点：

- **POST** `/api/chat` - 发送消息并获取 AI 回复

请求体：
```json
{
  "message": "你的消息内容"
}
```

响应：
```json
{
  "message": "AI 的回复内容"
}
```

## 自定义配置

### 修改提示词

编辑 `ChatService.java` 中的 `systemMessage` 来定制 AI 的行为：

```java
systemMessage.put("content", "你是图书馆系统的助手。用中文回复用户的问题...");
```

### 修改对话框样式

编辑 `ChatGptDialog.vue` 来修改：
- 对话框大小（宽高）
- 颜色主题（渐变色）
- 按钮位置
- 动画效果

### 添加更多功能

可以扩展的功能：
- 语音输入
- 表情选择
- 对话历史记录
- 多语言支持
- 快捷回复按钮

## 注意事项

⚠️ **API 费用**：使用真实的 OpenAI API 会产生费用，请查看 OpenAI 定价页面  
⚠️ **安全性**：不要将 API key 提交到公共代码仓库  
⚠️ **速率限制**：OpenAI API 有速率限制，生产环境建议添加缓存机制  

## 故障排除

### 对话框不出现
- 检查浏览器控制台是否有错误
- 确保已正确导入 `ChatGptDialog` 组件

### 消息发送失败
- 检查后端服务器是否运行
- 查看后端日志中的错误信息
- 确认 API 端点配置正确

### Mock 响应不工作
- 检查 `ChatService.java` 中的 `getMockResponse` 方法
- 确保后端服务正常运行

## 贡献

如果你有改进建议或发现了 bug，欢迎：
1. 提交 Issue
2. 提交 Pull Request
3. 联系开发团队

---

**开发团队**: Group 5  
**日期**: 2025-01-15  
**版本**: 1.0.0

