# 图片上传 500 错误快速修复

## 问题诊断

从你的错误信息看：
- ✅ 后端正在运行（端口 8080）
- ❌ 上传接口返回 500 错误
- ❌ 后端日志中没有 "📤 Received upload request" 输出
- ✅ 数据库插入成功（但 avatar 为 null）

**结论**：后端代码没有重新编译，运行的是旧代码！

## 立即修复步骤

### 步骤 1: 停止后端

在 IntelliJ IDEA 中：
- 点击控制台的 🔴 Stop 按钮停止当前后端

### 步骤 2: 重新编译

在 IntelliJ IDEA 中：
1. 点击菜单 `Build` → `Rebuild Project`
2. 等待编译完成
3. 查看是否有编译错误

或者使用命令行：
```bash
cd library-reservation-system
mvn clean compile
```

### 步骤 3: 重新启动

在 IntelliJ IDEA 中：
- 找到 `LibraryReservationSystemApplication.java`
- 右键 → `Run 'LibraryReservationSystemApplication'`

### 步骤 4: 测试上传

1. 刷新浏览器页面
2. 点击 "+New" 添加书籍
3. 选择图片
4. 点击 "Save"
5. **立即查看后端控制台**，应该看到：
   ```
   📤 Received upload request - File: cave.jpg, Size: ...
   🔍 Current working directory: ...
   🔍 Testing path: ...
   📂 Using webapp path: ...
   ✅ Cover uploaded successfully: /img/covers/...
   ```

## 如果仍然失败

### 查看详细错误

1. 打开浏览器开发者工具（F12）
2. 点击 Network 标签
3. 找到失败的 `cover` 请求
4. 点击它
5. 查看 "Response" 标签，看看后端返回的具体错误信息

### 手动测试

打开浏览器，直接访问：
```
POST http://localhost:8080/api/books/cover
```

使用 Postman 或其他工具测试上传。

## 文件位置确认

确保以下目录存在：
```
library-reservation-system/
  src/
    main/
      webapp/
        resource/
          img/
            covers/
```

如果不存在，手动创建：
```bash
mkdir -p library-reservation-system/src/main/webapp/resource/img/covers
```

## 替代方案（临时）

如果上传仍然有问题，可以暂时手动添加图片路径：

1. 将图片复制到 `library-reservation-system/src/main/webapp/resource/img/covers/`
2. 在创建书籍时，avatar 字段留空
3. 手动在数据库中将 avatar 更新为 `/img/covers/文件名.jpg`

## 需要帮助？

请提供：
1. IntelliJ IDEA 中的编译输出
2. 后端重新启动后的完整日志
3. 浏览器 Network 标签中 `/api/books/cover` 请求的完整 Response

