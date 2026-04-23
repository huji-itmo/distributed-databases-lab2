CREATE TABLE news_articles (
    id SERIAL PRIMARY KEY,
    title VARCHAR(255),
    content TEXT
) TABLESPACE ts_osz72;

CREATE TABLE user_logs (
    id SERIAL PRIMARY KEY,
    action VARCHAR(100),
    created_at TIMESTAMP DEFAULT NOW()
) TABLESPACE ts_osz72;

INSERT INTO news_articles (title, content) VALUES
('Заголовок 1', 'Текст новости 1'),
('Заголовок 2', 'Текст новости 2');

INSERT INTO user_logs (action) VALUES
('Login'),
('Create Article'),
('Logout');
