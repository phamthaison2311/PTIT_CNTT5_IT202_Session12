CREATE database BaiThucHanh_SS12;
USE BaiThucHanh_SS12;

CREATE TABLE Users (
    user_id INT AUTO_INCREMENT PRIMARY KEY,
    username VARCHAR(50) UNIQUE NOT NULL,
    password VARCHAR(255) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE Posts (
    post_id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    content TEXT NOT NULL,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_posts_user
        FOREIGN KEY (user_id)
        REFERENCES Users(user_id)
        ON DELETE CASCADE
);

CREATE TABLE Comments (
    comment_id INT AUTO_INCREMENT PRIMARY KEY,
    post_id INT NOT NULL,
    user_id INT NOT NULL,
    content TEXT NOT NULL,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_comments_post
        FOREIGN KEY (post_id)
        REFERENCES Posts(post_id)
        ON DELETE CASCADE,
    CONSTRAINT fk_comments_user
        FOREIGN KEY (user_id)
        REFERENCES Users(user_id)
        ON DELETE CASCADE
);

CREATE TABLE Friends (
    user_id INT NOT NULL,
    friend_id INT NOT NULL,
    status VARCHAR(20),
    CONSTRAINT fk_friends_user
        FOREIGN KEY (user_id)
        REFERENCES Users(user_id)
        ON DELETE CASCADE,
    CONSTRAINT fk_friends_friend
        FOREIGN KEY (friend_id)
        REFERENCES Users(user_id)
        ON DELETE CASCADE,
    CONSTRAINT chk_status
        CHECK (status IN ('pending', 'accepted')),
    PRIMARY KEY (user_id, friend_id)
);

CREATE TABLE Likes (
    user_id INT NOT NULL,
    post_id INT NOT NULL,
    CONSTRAINT fk_likes_user
        FOREIGN KEY (user_id)
        REFERENCES Users(user_id)
        ON DELETE CASCADE,
    CONSTRAINT fk_likes_post
        FOREIGN KEY (post_id)
        REFERENCES Posts(post_id)
        ON DELETE CASCADE,
    PRIMARY KEY (user_id, post_id)
);


INSERT INTO Users (username, password, email, created_at) VALUES
('minh',  '123456', 'minh@gmail.com',  '2026-01-01 08:00:00'),
('nam',   '123456', 'nam@gmail.com',   '2026-01-02 09:15:00'),
('linh',  '123456', 'linh@gmail.com',  '2026-01-03 10:30:00'),
('huy',   '123456', 'huy@gmail.com',   '2026-01-04 11:45:00'),
('trang', '123456', 'trang@gmail.com', '2026-01-05 13:00:00');


INSERT INTO Posts (user_id, content, created_at) VALUES
(1, 'Xin chào mọi người! Mình là Minh 😄', '2026-01-06 08:10:00'),
(2, 'Hôm nay học SQL VIEW và INDEX.',      '2026-01-06 09:20:00'),
(3, 'Mọi người có tài liệu MySQL hay không?', '2026-01-06 10:05:00'),
(4, 'Cuối tuần đi cafe không?',            '2026-01-06 19:30:00'),
(1, 'Mình vừa làm xong mini project Social Network!', '2026-01-07 07:55:00'),
(5, 'Chia sẻ tip học tiếng Trung nè~',     '2026-01-07 20:40:00');


INSERT INTO Comments (post_id, user_id, content, created_at) VALUES
(1, 2, 'Chào Minh nha!',                 '2026-01-06 08:20:00'),
(1, 3, 'Welcome 😄',                     '2026-01-06 08:25:00'),
(2, 1, 'VIEW/INDEX quan trọng lắm!',     '2026-01-06 09:30:00'),
(3, 4, 'Tớ có vài link, lát gửi nhé.',   '2026-01-06 10:20:00'),
(4, 5, 'Đi chứ, mấy giờ?',               '2026-01-06 19:40:00'),
(5, 2, 'Đỉnh quá! Cho xem demo với.',    '2026-01-07 08:10:00'),
(6, 1, 'Hay đó, share thêm từ vựng đi!', '2026-01-07 20:55:00');


INSERT INTO Friends (user_id, friend_id, status) VALUES
(1, 2, 'accepted'),  
(2, 3, 'accepted'), 
(1, 3, 'pending'),   
(4, 1, 'accepted'),  
(5, 1, 'pending'),  
(5, 4, 'accepted'); 


INSERT INTO Likes (user_id, post_id) VALUES
(2, 1),
(3, 1),
(4, 1),
(1, 2),
(3, 2),
(5, 2),
(1, 3),
(2, 5),
(3, 5),
(4, 6),
(1, 6);

-- Bài 1
INSERT INTO Users (username, password, email)
VALUES ('son', '123456', 'son@gmail.com');

SELECT * FROM Users;

-- Bài 2
CREATE OR REPLACE VIEW vw_public_users AS
SELECT u.user_id, u.username, u.created_at
FROM Users u; 

SELECT * FROM vw_public_users;

-- Bài 3
CREATE INDEX idx_username ON Users(username);

-- Bài 4
DROP PROCEDURE IF EXISTS sp_create_post;
DELIMITER $$

CREATE PROCEDURE sp_create_post(
    IN p_user_id INT,
    IN p_content TEXT
)
BEGIN
    IF NOT EXISTS (SELECT 1 FROM Users WHERE user_id = p_user_id) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'User khong ton tai, khong the dang bai.';
    ELSE
        INSERT INTO Posts(user_id, content)
        VALUES (p_user_id, p_content);
    END IF;
END $$

DELIMITER ;

CALL sp_create_post(1, 'Bài viết mới của Minh!');

-- Bài 5
CREATE OR REPLACE VIEW vw_recent_posts AS
SELECT
    p.post_id,
    p.user_id,
    u.username,
    p.content,
    p.created_at
FROM Posts p
JOIN Users u ON u.user_id = p.user_id
WHERE p.created_at >= NOW() - INTERVAL 7 DAY
ORDER BY p.created_at DESC;

SELECT * FROM vw_recent_posts;

-- Bài 6
CREATE INDEX idx_posts_user_id ON Posts(user_id);
CREATE INDEX idx_posts_user_created ON Posts(user_id, created_at);

SELECT *
FROM Posts
WHERE user_id = 1
ORDER BY created_at DESC;

-- Bài 7
DROP PROCEDURE IF EXISTS sp_count_posts;
DELIMITER $$

CREATE PROCEDURE sp_count_posts(
    IN p_user_id INT,
    OUT p_total INT
)
BEGIN
    SELECT COUNT(*) INTO p_total
    FROM Posts
    WHERE user_id = p_user_id;
END $$

DELIMITER ;

SET @total = 0;
CALL sp_count_posts(1, @total);
SELECT @total AS total_posts;

-- Bài 8
CREATE OR REPLACE VIEW vw_active_users AS
SELECT u.user_id, u.username, u.created_at
FROM Users u
WHERE EXISTS (SELECT 1 FROM Posts p WHERE p.user_id = u.user_id)
   OR EXISTS (SELECT 1 FROM Comments c WHERE c.user_id = u.user_id)
WITH CHECK OPTION;

SELECT * FROM vw_active_users;

-- Bài 9
DROP PROCEDURE IF EXISTS sp_add_friend;
DELIMITER $$

CREATE PROCEDURE sp_add_friend(
    IN p_user_id INT,
    IN p_friend_id INT
)
BEGIN
    IF p_user_id = p_friend_id THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Khong duoc ket ban voi chinh minh.';
    ELSEIF NOT EXISTS (SELECT 1 FROM Users WHERE user_id = p_user_id)
        OR NOT EXISTS (SELECT 1 FROM Users WHERE user_id = p_friend_id) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'User hoac Friend khong ton tai.';
    ELSEIF EXISTS (SELECT 1 FROM Friends WHERE user_id = p_user_id AND friend_id = p_friend_id) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Da gui loi moi truoc do.';
    ELSE
        INSERT INTO Friends(user_id, friend_id, status)
        VALUES (p_user_id, p_friend_id, 'pending');
    END IF;
END $$

DELIMITER ;

CALL sp_add_friend(1, 2);



