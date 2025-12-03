/*
 Navicat Premium Data Transfer

 Source Server         : Wx
 Source Server Type    : MySQL
 Source Server Version : 80042 (8.0.42)
 Source Host           : localhost:3306
 Source Schema         : library_reservation_system

 Target Server Type    : MySQL
 Target Server Version : 80042 (8.0.42)
 File Encoding         : 65001

 Date: 27/10/2025 18:48:15
*/

SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;

-- ----------------------------
-- Table structure for administrator
-- ----------------------------
DROP TABLE IF EXISTS `administrator`;
CREATE TABLE `administrator`  (
  `administrator_id` int NOT NULL AUTO_INCREMENT,
  `email` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL,
  `password` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL,
  `login_log` text CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL,
  PRIMARY KEY (`administrator_id`) USING BTREE,
  UNIQUE INDEX `email`(`email` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 4 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of administrator
-- ----------------------------
INSERT INTO `administrator` VALUES (1, '577302221@qq.com', 'admin123hash', '2025-09-10 08:00 login successful');
INSERT INTO `administrator` VALUES (2, 'mintwang214@gmail.com', 'secure456hash', '2025-09-11 09:15 login failed');
INSERT INTO `administrator` VALUES (3, 'lhy2000001@163.com', 'admin789hash', '2025-09-12 10:30 login successful');

-- ----------------------------
-- Table structure for book
-- ----------------------------
DROP TABLE IF EXISTS `book`;
CREATE TABLE `book`  (
  `book_id` int NOT NULL AUTO_INCREMENT,
  `book_name` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
  `quantity` int NOT NULL DEFAULT 0,
  `author` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
  `description` text CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL,
  `num_favorite` int NOT NULL DEFAULT 0,
  `num_reservation` int NOT NULL DEFAULT 0,
  `label_id` int NOT NULL,
  `avatar` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL,
  PRIMARY KEY (`book_id`) USING BTREE,
  INDEX `label_id`(`label_id` ASC) USING BTREE,
  CONSTRAINT `book_ibfk_1` FOREIGN KEY (`label_id`) REFERENCES `label` (`label_id`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE = InnoDB AUTO_INCREMENT = 18 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of book
-- ----------------------------
INSERT INTO `book` VALUES (1, 'Getting Started with Python', 10, 'Xiaoming Wang', 'Beginner-friendly Python guide', 5, 3, 1, '/img/covers/python1.jpg');
INSERT INTO `book` VALUES (2, 'Advanced Python Techniques', 8, 'Liam Chen', 'Deep dive into Python internals', 2, 1, 1, '/img/covers/python2.jpg');
INSERT INTO `book` VALUES (3, 'AI in Modern Healthcare', 5, 'Chander Bhanu', 'How AI transforms medical systems', 4, 2, 2, '/img/covers/ai_health.jpg');
INSERT INTO `book` VALUES (4, 'Introduction to Engineering Drawing', 12, 'Emily Zhang', 'Basic principles of technical drawing', 1, 0, 4, '/img/covers/eng_drawing.jpg');
INSERT INTO `book` VALUES (5, 'Practical Data Analysis', 7, 'Olivia Smith', 'Hands-on data analysis with Python', 3, 2, 5, '/img/covers/data_analysis.jpg');
INSERT INTO `book` VALUES (6, 'Machine Learning Fundamentals', 6, 'James Liu', 'Core ML concepts and algorithms', 6, 4, 2, '/img/covers/ml_intro.jpg');
INSERT INTO `book` VALUES (7, 'Medical Imaging Explained', 4, 'Sophia Lee', 'Techniques in medical image processing', 2, 1, 3, '/img/covers/med_image.jpg');
INSERT INTO `book` VALUES (8, 'Python Projects in Action', 9, 'Xiaoming Wang', 'Real-world Python applications', 5, 3, 1, '/img/covers/python_project.jpg');
INSERT INTO `book` VALUES (9, 'AI Ethics and Law', 3, 'Daniel Wu', 'Legal and ethical issues in AI', 1, 0, 2, '/img/covers/ai_law.jpg');
INSERT INTO `book` VALUES (10, 'Materials Science Basics', 11, 'Grace Chen', 'Introduction to engineering materials', 2, 1, 4, '/img/covers/materials.jpg');
INSERT INTO `book` VALUES (11, 'Data Visualization Mastery', 6, 'Olivia Smith', 'Storytelling with charts and graphs', 3, 2, 5, '/img/covers/dataviz.jpg');
INSERT INTO `book` VALUES (12, 'Python for Web Development', 7, 'Xiaoming Wang', 'Building web apps with Python', 4, 2, 1, '/img/covers/python_web.jpg');
INSERT INTO `book` VALUES (13, 'Optimizing AI Models', 5, 'Chander Bhanu', 'Improving performance of AI systems', 2, 1, 2, '/img/covers/ai_opt.jpg');
INSERT INTO `book` VALUES (14, 'Medical Statistics Essentials', 4, 'Sophia Lee', 'Statistical methods in clinical research', 1, 0, 3, '/img/covers/med_stats.jpg');
INSERT INTO `book` VALUES (15, 'Project Management for Engineers', 10, 'Emily Zhang', 'Tools and workflows for engineering teams', 3, 2, 4, '/img/covers/project_mgmt.jpg');
INSERT INTO `book` VALUES (17, '测试图书名称', 5, '测试作者', '这是一本测试图书的描述', 0, 0, 1, '/img/covers/test_book.jpg');

-- ----------------------------
-- Table structure for comment
-- ----------------------------
DROP TABLE IF EXISTS `comment`;
CREATE TABLE `comment`  (
  `comment_id` int NOT NULL AUTO_INCREMENT,
  `book_id` int NOT NULL,
  `content` text CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
  `create_date` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `author_id` int NOT NULL,
  `author_type` tinyint NOT NULL,
  `status` tinyint NOT NULL,
  PRIMARY KEY (`comment_id`) USING BTREE,
  INDEX `book_id`(`book_id` ASC) USING BTREE,
  CONSTRAINT `comment_ibfk_1` FOREIGN KEY (`book_id`) REFERENCES `book` (`book_id`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE = InnoDB AUTO_INCREMENT = 36 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of comment
-- ----------------------------
INSERT INTO `comment` VALUES (1, 1, 'Excellent introduction to Python!', '2025-09-15 13:23:01', 1, 0, 1);
INSERT INTO `comment` VALUES (2, 3, 'Very insightful and well-written.', '2025-09-15 13:23:01', 2, 0, 1);
INSERT INTO `comment` VALUES (3, 5, 'Clear explanations and practical examples.', '2025-09-15 13:23:01', 3, 0, 1);
INSERT INTO `comment` VALUES (4, 2, 'Could use more real-world projects.', '2025-09-15 13:23:01', 4, 0, 0);
INSERT INTO `comment` VALUES (5, 4, 'Pending admin review.', '2025-09-15 13:23:01', 1, 1, 0);
INSERT INTO `comment` VALUES (6, 1, 'Really helped me understand Python basics.', '2025-09-16 09:12:01', 2, 0, 1);
INSERT INTO `comment` VALUES (7, 2, 'Some examples were too short, but overall good.', '2025-09-16 10:21:05', 3, 0, 1);
INSERT INTO `comment` VALUES (8, 3, 'Very professional explanation of AI in healthcare.', '2025-09-16 11:00:33', 4, 0, 1);
INSERT INTO `comment` VALUES (9, 4, 'Simple and easy to follow.', '2025-09-16 11:05:47', 5, 0, 1);
INSERT INTO `comment` VALUES (10, 5, 'Loved the data visualization part.', '2025-09-16 12:11:15', 1, 0, 1);
INSERT INTO `comment` VALUES (11, 6, 'Clear explanation of ML algorithms.', '2025-09-17 09:00:00', 2, 0, 1);
INSERT INTO `comment` VALUES (12, 7, 'Useful for medical image beginners.', '2025-09-17 09:05:11', 3, 0, 1);
INSERT INTO `comment` VALUES (13, 8, 'Projects are inspiring and practical.', '2025-09-17 09:15:44', 4, 0, 1);
INSERT INTO `comment` VALUES (14, 9, 'Thought-provoking content on AI ethics.', '2025-09-17 09:23:02', 5, 0, 1);
INSERT INTO `comment` VALUES (15, 10, 'Good introduction to materials science.', '2025-09-17 09:30:55', 1, 0, 1);
INSERT INTO `comment` VALUES (16, 11, 'The charts and storytelling examples are brilliant.', '2025-09-17 10:00:23', 2, 0, 1);
INSERT INTO `comment` VALUES (17, 12, 'Very detailed guide for building web apps.', '2025-09-17 11:01:45', 3, 0, 1);
INSERT INTO `comment` VALUES (18, 13, 'Excellent explanation of model optimization.', '2025-09-17 12:09:14', 4, 0, 1);
INSERT INTO `comment` VALUES (19, 14, 'Statistical explanations are very clear.', '2025-09-17 12:11:34', 5, 0, 1);
INSERT INTO `comment` VALUES (20, 15, 'Good book for engineering students.', '2025-09-17 13:01:19', 1, 0, 1);
INSERT INTO `comment` VALUES (21, 1, 'I like the structure of each chapter.', '2025-09-18 08:12:00', 2, 0, 1);
INSERT INTO `comment` VALUES (22, 2, 'Too theoretical in some parts.', '2025-09-18 09:11:10', 3, 0, 0);
INSERT INTO `comment` VALUES (23, 3, 'Loved the case studies on AI hospitals.', '2025-09-18 10:30:40', 4, 0, 1);
INSERT INTO `comment` VALUES (24, 4, 'Wish it had more diagrams.', '2025-09-18 11:15:27', 5, 0, 1);
INSERT INTO `comment` VALUES (25, 5, 'The exercises are well-designed.', '2025-09-18 11:40:10', 1, 0, 1);
INSERT INTO `comment` VALUES (26, 6, 'Covers ML fundamentals well.', '2025-09-18 12:21:30', 2, 0, 1);
INSERT INTO `comment` VALUES (27, 7, 'This helped me with my thesis.', '2025-09-18 12:40:50', 3, 0, 1);
INSERT INTO `comment` VALUES (28, 8, 'Projects section was great.', '2025-09-18 13:01:22', 4, 0, 1);
INSERT INTO `comment` VALUES (29, 9, 'Explains laws in easy language.', '2025-09-18 13:12:35', 5, 0, 1);
INSERT INTO `comment` VALUES (30, 10, 'Loved the material classification charts.', '2025-09-18 13:30:11', 1, 0, 1);
INSERT INTO `comment` VALUES (31, 11, 'Helps me design better dashboards.', '2025-09-18 14:00:55', 2, 0, 1);
INSERT INTO `comment` VALUES (32, 12, 'Clean examples of Flask and Django.', '2025-09-18 14:15:43', 3, 0, 1);
INSERT INTO `comment` VALUES (33, 13, 'A bit hard to follow for beginners.', '2025-09-18 15:10:00', 4, 0, 0);
INSERT INTO `comment` VALUES (34, 14, 'Very useful for research.', '2025-09-18 16:00:25', 5, 0, 1);
INSERT INTO `comment` VALUES (35, 15, 'Project templates are valuable.', '2025-09-18 16:20:10', 1, 0, 1);

-- ----------------------------
-- Table structure for favorite
-- ----------------------------
DROP TABLE IF EXISTS `favorite`;
CREATE TABLE `favorite`  (
  `book_id` int NOT NULL,
  `user_id` int NOT NULL,
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`book_id`, `user_id`) USING BTREE,
  INDEX `user_id`(`user_id` ASC) USING BTREE,
  CONSTRAINT `favorite_ibfk_1` FOREIGN KEY (`book_id`) REFERENCES `book` (`book_id`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT `favorite_ibfk_2` FOREIGN KEY (`user_id`) REFERENCES `user` (`user_id`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of favorite
-- ----------------------------
INSERT INTO `favorite` VALUES (1, 1, '2025-09-15 13:23:01');
INSERT INTO `favorite` VALUES (2, 4, '2025-09-15 13:23:01');
INSERT INTO `favorite` VALUES (3, 2, '2025-09-15 13:23:01');
INSERT INTO `favorite` VALUES (4, 5, '2025-09-15 13:23:01');
INSERT INTO `favorite` VALUES (5, 3, '2025-09-15 13:23:01');
INSERT INTO `favorite` VALUES (6, 2, '2025-09-20 10:00:00');
INSERT INTO `favorite` VALUES (7, 3, '2025-09-20 10:10:00');
INSERT INTO `favorite` VALUES (8, 4, '2025-09-20 10:20:00');
INSERT INTO `favorite` VALUES (9, 5, '2025-09-20 10:30:00');
INSERT INTO `favorite` VALUES (10, 1, '2025-09-20 10:40:00');

-- ----------------------------
-- Table structure for label
-- ----------------------------
DROP TABLE IF EXISTS `label`;
CREATE TABLE `label`  (
  `label_id` int NOT NULL AUTO_INCREMENT,
  `label_name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
  `create_date` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`label_id`) USING BTREE,
  UNIQUE INDEX `label_name`(`label_name` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 7 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of label
-- ----------------------------
INSERT INTO `label` VALUES (1, 'Python Programming', '2025-09-15 13:23:01');
INSERT INTO `label` VALUES (2, 'Artificial Intelligence', '2025-09-15 13:23:01');
INSERT INTO `label` VALUES (3, 'Healthcare', '2025-09-15 13:23:01');
INSERT INTO `label` VALUES (4, 'Engineering', '2025-09-15 13:23:01');
INSERT INTO `label` VALUES (5, 'Data Science', '2025-09-15 13:23:01');

-- ----------------------------
-- Table structure for reservation
-- ----------------------------
DROP TABLE IF EXISTS `reservation`;
CREATE TABLE `reservation`  (
  `reservation_id` int NOT NULL AUTO_INCREMENT,
  `create_date` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `status` tinyint NOT NULL,
  `user_id` int NOT NULL,
  `book_id` int NOT NULL,
  `take_date` date NULL DEFAULT NULL,
  `return_date` date NULL DEFAULT NULL,
  PRIMARY KEY (`reservation_id`) USING BTREE,
  INDEX `user_id`(`user_id` ASC) USING BTREE,
  INDEX `book_id`(`book_id` ASC) USING BTREE,
  CONSTRAINT `reservation_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `user` (`user_id`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT `reservation_ibfk_2` FOREIGN KEY (`book_id`) REFERENCES `book` (`book_id`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE = InnoDB AUTO_INCREMENT = 11 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of reservation
-- ----------------------------
INSERT INTO `reservation` VALUES (1, '2025-09-15 13:23:01', 0, 1, 1, NULL, NULL);
INSERT INTO `reservation` VALUES (2, '2025-09-15 13:23:01', 1, 2, 3, '2025-09-10', NULL);
INSERT INTO `reservation` VALUES (3, '2025-09-15 13:23:01', 2, 3, 5, '2025-09-08', '2025-09-14');
INSERT INTO `reservation` VALUES (4, '2025-09-15 13:23:01', 3, 4, 6, '2025-09-01', '2025-09-10');
INSERT INTO `reservation` VALUES (5, '2025-09-15 13:23:01', 1, 5, 2, '2025-09-12', NULL);
INSERT INTO `reservation` VALUES (6, '2025-09-20 08:00:00', 0, 1, 3, NULL, NULL);
INSERT INTO `reservation` VALUES (7, '2025-09-20 09:00:00', 1, 2, 6, '2025-09-18', NULL);
INSERT INTO `reservation` VALUES (8, '2025-09-20 10:00:00', 2, 3, 7, '2025-09-15', '2025-09-20');
INSERT INTO `reservation` VALUES (9, '2025-09-20 11:00:00', 3, 4, 8, '2025-09-10', '2025-09-17');
INSERT INTO `reservation` VALUES (10, '2025-09-20 12:00:00', 1, 5, 9, '2025-09-19', NULL);

-- ----------------------------
-- Table structure for user
-- ----------------------------
DROP TABLE IF EXISTS `user`;
CREATE TABLE `user`  (
  `user_id` int NOT NULL AUTO_INCREMENT,
  `nickname` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
  `telephone` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
  `email` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
  `password` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
  `is_active` bit(1) NOT NULL DEFAULT b'1',
  PRIMARY KEY (`user_id`) USING BTREE,
  UNIQUE INDEX `telephone`(`telephone` ASC) USING BTREE,
  UNIQUE INDEX `email`(`email` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 7 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of user
-- ----------------------------
INSERT INTO `user` VALUES (1, 'Alice', '0412345678', 'alice@example.com', 'pass123hash', b'1');
INSERT INTO `user` VALUES (2, 'Bob', '0423456789', 'bob@example.com', 'pass456hash', b'1');
INSERT INTO `user` VALUES (3, 'Charlie', '0434567890', 'charlie@example.com', 'pass789hash', b'1');
INSERT INTO `user` VALUES (4, 'Diana', '0445678901', 'diana@example.com', 'passabc123hash', b'1');
INSERT INTO `user` VALUES (5, 'Ethan', '0456789012', 'ethan@example.com', 'passxyz456hash', b'1');
INSERT INTO `user` VALUES (6, 'NewUser', '0411222333', 'liuzheng020623@outlook.com', '$2a$12$g9V2eBrG3UYHE2TFTZCwHOIY4k.IEfjGx.yvDNycncUjPYMNwFVmS', b'1');

SET FOREIGN_KEY_CHECKS = 1;
