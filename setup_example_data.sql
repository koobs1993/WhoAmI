-- Sample Course: "Understanding Your Personality Type"
INSERT INTO courses (id, title, description, difficulty, category, estimated_duration, created_at, updated_at)
VALUES (
    '67c93901-1c24-4b56-a14f-636f518d42c8',
    'Understanding Your Personality Type',
    'Discover the fundamentals of personality psychology and learn how different personality traits influence behavior, relationships, and personal growth.',
    'Beginner',
    'Psychology',
    120, -- 120 minutes
    NOW(),
    NOW()
);

-- Course Lessons
INSERT INTO lessons (id, course_id, title, description, content, duration, order_number, created_at, updated_at)
VALUES
    (
        '8f7b5a1c-9e4d-4b2f-8e3d-6c5f4a3b2d1e',
        '67c93901-1c24-4b56-a14f-636f518d42c8',
        'Introduction to Personality Types',
        'Learn the basics of personality psychology and different personality frameworks.',
        'In this lesson, we will explore the fundamental concepts of personality psychology and how different frameworks have evolved to understand human personality. Topics include:

1. What is personality?
2. Historical perspectives on personality
3. Modern personality frameworks
4. The importance of self-awareness',
        30, -- 30 minutes
        1,
        NOW(),
        NOW()
    ),
    (
        'a1b2c3d4-e5f6-4a5b-8c7d-9e0f1a2b3c4d',
        '67c93901-1c24-4b56-a14f-636f518d42c8',
        'The Big Five Personality Traits',
        'Understand the five major dimensions of personality: Openness, Conscientiousness, Extraversion, Agreeableness, and Neuroticism.',
        'This lesson covers the Big Five personality traits, also known as the OCEAN model:

1. Openness to Experience
2. Conscientiousness
3. Extraversion
4. Agreeableness
5. Neuroticism (Emotional Stability)

We will explore how these traits influence behavior and personal development.',
        45, -- 45 minutes
        2,
        NOW(),
        NOW()
    ),
    (
        'b2c3d4e5-f6a7-5b6c-9d0e-1f2a3b4c5d6e',
        '67c93901-1c24-4b56-a14f-636f518d42c8',
        'Applying Personality Insights',
        'Learn how to apply personality insights in daily life, relationships, and personal growth.',
        'In this final lesson, we will discuss practical applications of personality insights:

1. Understanding your strengths and challenges
2. Improving relationships through personality awareness
3. Personal development strategies
4. Setting personality-aligned goals',
        45, -- 45 minutes
        3,
        NOW(),
        NOW()
    );

INSERT INTO test_questions (id, test_id, text, type, required, options, order_number, created_at, updated_at)
VALUES
    (
        'e8f9a512-3e46-4d78-b36f-858f730e64ea',  -- Corrected UUID
        'd78d9401-2d35-4c67-b25f-747f629e53d9',  -- Ensure this is a valid UUID
        'How do you typically recharge your energy?',
        'multiple_choice',
        true,
        '[
            {"value": "a", "text": "Spending time alone with my thoughts"},
            {"value": "b", "text": "Being around other people and socializing"},
            {"value": "c", "text": "A mix of both, depending on the situation"},
            {"value": "d", "text": "Engaging in physical activities"}
        ]'::jsonb,
        1,
        NOW(),
        NOW()
    ),
    (
        'f9a0b623-4f57-4e89-b47f-969f841f75fb',  -- Corrected UUID
        'd78d9401-2d35-4c67-b25f-747f629e53d9',  -- Ensure this is a valid UUID
        'When making important decisions, do you tend to:',
        'multiple_choice',
        true,
        '[
            {"value": "a", "text": "Rely on logic and objective analysis"},
            {"value": "b", "text": "Trust your feelings and intuition"},
            {"value": "c", "text": "Consider both facts and feelings equally"},
            {"value": "d", "text": "Seek advice from others"}
        ]'::jsonb,
        2,
        NOW(),
        NOW()
    ),
    (
        'e0b1c734-5f68-4f90-b58f-070f952f86fc',  -- Corrected UUID
        'd78d9401-2d35-4c67-b25f-747f629e53d9',  -- Ensure this is a valid UUID
        'Describe a situation where you demonstrated leadership or took initiative.',
        'text',
        true,
        null,
        3,
        NOW(),
        NOW()
    );

-- Test Benefits
INSERT INTO test_benefits (id, test_id, title, description, created_at, updated_at)
VALUES
    (
        'h1c2d845-6f79-4fa1-b69f-181f063f97fd',
        'd78d9401-2d35-5c67-b25f-747f629e53d9',
        'Self-Awareness',
        'Gain deeper insights into your personality traits and behavioral patterns.',
        NOW(),
        NOW()
    ),
    (
        'i2d3e956-7f80-4fb2-b70f-292f174f08fe',
        'd78d9401-2d35-5c67-b25f-747f629e53d9',
        'Personal Growth',
        'Identify areas for personal development and strategies for improvement.',
        NOW(),
        NOW()
    ),
    (
        'j3e4f067-8f91-4fc3-b81f-303f285f19ff',
        'd78d9401-2d35-5c67-b25f-747f629e53d9',
        'Better Relationships',
        'Understand how your personality type influences your interactions with others.',
        NOW(),
        NOW()
    );
