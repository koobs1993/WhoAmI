-- Sample data for WhoAmI database
-- Execute this in Supabase SQL editor

-- Courses
INSERT INTO courses (id, title, description, image_url, difficulty, category, estimated_duration, created_at, updated_at)
VALUES 
  ('11111111-1111-1111-1111-111111111111', 'Understanding Yourself', 'Learn about personality types and self-discovery', 'https://example.com/course1.jpg', 'intermediate', 'Psychology', 120, NOW(), NOW()),
  ('22222222-2222-2222-2222-222222222222', 'Emotional Intelligence', 'Master your emotions and understand others better', 'https://example.com/course2.jpg', 'beginner', 'Psychology', 90, NOW(), NOW());

-- Course Sections
INSERT INTO course_sections (id, course_id, title, description, order_num, created_at, updated_at)
VALUES 
  ('33333333-3333-3333-3333-333333333333', '11111111-1111-1111-1111-111111111111', 'Fundamentals', 'Core concepts of personality psychology', 1, NOW(), NOW()),
  ('44444444-4444-4444-4444-444444444444', '11111111-1111-1111-1111-111111111111', 'Advanced Topics', 'Deep dive into personality analysis', 2, NOW(), NOW());

-- Lessons
INSERT INTO lessons (id, course_id, title, description, content, duration, order_num, created_at, updated_at)
VALUES 
  ('55555555-5555-5555-5555-555555555555', '11111111-1111-1111-1111-111111111111', 'Introduction to Personality Types', 'Learn about different personality frameworks', 'Lesson content here...', 30, 1, NOW(), NOW()),
  ('66666666-6666-6666-6666-666666666666', '11111111-1111-1111-1111-111111111111', 'Self-Discovery Exercises', 'Practical exercises for self-understanding', 'Lesson content here...', 45, 2, NOW(), NOW());

-- Psych Tests
INSERT INTO psych_tests (id, title, short_description, category, image_url, duration_minutes, is_active, created_at, updated_at)
VALUES 
  ('77777777-7777-7777-7777-777777777777', 'Personality Assessment', 'Discover your personality type through this comprehensive assessment', 'personality', 'https://example.com/test1.jpg', 30, true, NOW(), NOW()),
  ('88888888-8888-8888-8888-888888888888', 'Intelligence Test', 'Measure your cognitive abilities and problem-solving skills', 'intelligence', 'https://example.com/test2.jpg', 45, true, NOW(), NOW());

-- Test Benefits
INSERT INTO test_benefits (id, test_id, description, created_at, updated_at)
VALUES 
  ('99999999-9999-9999-9999-999999999999', '77777777-7777-7777-7777-777777777777', 'Understand your personality traits better', NOW(), NOW()),
  ('aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa', '77777777-7777-7777-7777-777777777777', 'Improve your relationships', NOW(), NOW());

-- Weekly Columns
INSERT INTO weekly_columns (id, title, summary, content, author_id, featured_image_url, subtitle, author, short_description, created_at, updated_at)
VALUES 
  ('bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb', 'Understanding Your Inner Self', 'A deep dive into self-reflection', 'Full content here...', NULL, 'https://example.com/column1.jpg', 'Weekly Wisdom', 'Dr. Smith', 'Learn about self-reflection techniques', NOW(), NOW()),
  ('cccccccc-cccc-cccc-cccc-cccccccccccc', 'Building Better Relationships', 'Tips for improving relationships', 'Full content here...', NULL, 'https://example.com/column2.jpg', 'Relationship Series', 'Dr. Johnson', 'Practical relationship advice', NOW(), NOW());

-- Weekly Questions
INSERT INTO weekly_questions (id, column_id, question_text, order_num, created_at, updated_at)
VALUES 
  ('dddddddd-dddd-dddd-dddd-dddddddddddd', 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb', 'What did you learn about yourself this week?', 1, NOW(), NOW()),
  ('eeeeeeee-eeee-eeee-eeee-eeeeeeeeeeee', 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb', 'How have you applied this knowledge in your daily life?', 2, NOW(), NOW());

-- Characters
INSERT INTO characters (id, name, description, bio, image_url, created_at, updated_at)
VALUES 
  (1, 'The Achiever', 'A goal-oriented and ambitious character', 'Detailed biography of the achiever...', 'https://example.com/char1.jpg', NOW(), NOW()),
  (2, 'The Mediator', 'A peaceful and empathetic character', 'Detailed biography of the mediator...', 'https://example.com/char2.jpg', NOW(), NOW());

-- Character Problems
INSERT INTO character_problems (id, title, description, icon_url, problem_id, is_active, created_at, updated_at)
VALUES 
  (1, 'Perfectionism', 'Dealing with perfectionist tendencies', 'https://example.com/icon1.jpg', 1, true, NOW(), NOW()),
  (2, 'Conflict Avoidance', 'Learning to handle conflicts effectively', 'https://example.com/icon2.jpg', 2, true, NOW(), NOW());

-- Character Problem Relations
INSERT INTO character_problem_relations (character_id, problem_id)
VALUES 
  (1, '77777777-7777-7777-7777-777777777777'),
  (2, '88888888-8888-8888-8888-888888888888');
