# WhoAmI Database Schema Documentation

## Overview
This document provides a comprehensive overview of the database schema for the WhoAmI application. The schema is implemented in Supabase (PostgreSQL) and includes user profiles, settings, courses, tests, chat functionality, and character systems.

## Custom Types (ENUMs)

### Status Types
- `test_status`: ['draft', 'published', 'archived']
- `quest_status`: ['active', 'completed', 'failed', 'abandoned']
- `content_status`: ['draft', 'published', 'archived']
- `dashboard_item_status`: ['active', 'completed', 'archived']

### Relationship and Notification Types
- `relationship_type`: ['friend', 'mentor', 'mentee', 'collaborator', 'guide']
- `notification_type`: ['achievement', 'quest', 'relationship', 'message', 'system']
- `dashboard_item_type`: ['course', 'test', 'achievement', 'notification']

## Tables

### User Management

#### user_profiles
- Primary key: `id` (UUID)
- Foreign key: `user_id` references `auth.users(id)`
- Fields:
  - `first_name` (TEXT)
  - `last_name` (TEXT)
  - `display_name` (TEXT)
  - `email` (TEXT, UNIQUE)
  - `bio` (TEXT)
  - `avatar_url` (TEXT)
  - `location` (TEXT)
  - `website` (TEXT)
  - `social_links` (JSONB)
  - `interests` (TEXT[])
  - Timestamps: `created_at`, `updated_at`

#### user_privacy_settings
- Primary key: `id` (UUID)
- Foreign key: `user_id` references `auth.users(id)`
- Fields:
  - `is_public` (BOOLEAN)
  - `show_email` (BOOLEAN)
  - `show_location` (BOOLEAN)
  - `show_activity` (BOOLEAN)
  - `show_stats` (BOOLEAN)
  - Timestamps: `created_at`, `updated_at`

#### user_device_settings
- Primary key: `id` (UUID)
- Foreign key: `user_id` references `auth.users(id)`
- Fields:
  - `notifications_enabled` (BOOLEAN)
  - `course_updates_enabled` (BOOLEAN)
  - `test_reminders_enabled` (BOOLEAN)
  - `weekly_summaries_enabled` (BOOLEAN)
  - `analytics_enabled` (BOOLEAN)
  - `tracking_authorized` (BOOLEAN)
  - `dark_mode_enabled` (BOOLEAN)
  - `haptics_enabled` (BOOLEAN)
  - `font_size` (INTEGER)
  - `sound_enabled` (BOOLEAN)
  - Timestamps: `created_at`, `updated_at`

#### user_stats
- Primary key: `id` (UUID)
- Foreign key: `user_id` references `auth.users(id)`
- Fields:
  - `courses_completed` (INTEGER)
  - `tests_completed` (INTEGER)
  - `average_score` (DOUBLE PRECISION)
  - `total_points` (INTEGER)
  - Timestamps: `created_at`, `updated_at`

### Dashboard

#### dashboard_items
- Primary key: `id` (UUID)
- Foreign key: `user_id` references `auth.users(id)`
- Fields:
  - `title` (TEXT)
  - `description` (TEXT)
  - `type` (dashboard_item_type)
  - `status` (dashboard_item_status)
  - `metadata` (JSONB)
  - Timestamps: `created_at`, `updated_at`

### Learning System

#### courses
- Primary key: `id` (UUID)
- Fields:
  - `title` (TEXT)
  - `description` (TEXT)
  - `difficulty` (TEXT)
  - `category` (TEXT)
  - `estimated_duration` (INTEGER)
  - Timestamps: `created_at`, `updated_at`

#### lessons
- Primary key: `id` (UUID)
- Foreign key: `course_id` references `courses(id)`
- Fields:
  - `title` (TEXT)
  - `description` (TEXT)
  - `content` (TEXT)
  - `duration` (INTEGER)
  - `order_number` (INTEGER)
  - Timestamps: `created_at`, `updated_at`

#### tests
- Primary key: `id` (UUID)
- Fields:
  - `title` (TEXT)
  - `short_description` (TEXT)
  - `test_category` (TEXT)
  - `duration_minutes` (INTEGER)
  - `is_active` (BOOLEAN)
  - Timestamps: `created_at`, `updated_at`

#### test_questions
- Primary key: `id` (UUID)
- Foreign key: `test_id` references `tests(id)`
- Fields:
  - `text` (TEXT)
  - `type` (TEXT)
  - `required` (BOOLEAN)
  - `options` (JSONB)
  - `order_number` (INTEGER)
  - Timestamps: `created_at`, `updated_at`

#### test_benefits
- Primary key: `id` (UUID)
- Foreign key: `test_id` references `tests(id)`
- Fields:
  - `title` (TEXT)
  - `description` (TEXT)
  - Timestamps: `created_at`, `updated_at`

### Chat System

#### chat_sessions
- Primary key: `id` (UUID)
- Foreign key: `user_id` references `auth.users(id)`
- Fields:
  - `title` (TEXT)
  - Timestamps: `created_at`, `updated_at`

#### chat_messages
- Primary key: `id` (UUID)
- Foreign keys:
  - `session_id` references `chat_sessions(id)`
  - `user_id` references `auth.users(id)`
- Fields:
  - `content` (TEXT)
  - `role` (TEXT)
  - Timestamps: `created_at`, `updated_at`

### Weekly Content

#### weekly_columns
- Primary key: `id` (UUID)
- Foreign key: `author_id` references `auth.users(id)`
- Fields:
  - `title` (TEXT)
  - `summary` (TEXT)
  - `content` (TEXT)
  - `featured_image_url` (TEXT)
  - `subtitle` (TEXT)
  - `author` (TEXT)
  - `short_description` (TEXT)
  - Timestamps: `created_at`, `updated_at`

#### weekly_questions
- Primary key: `id` (UUID)
- Foreign key: `column_id` references `weekly_columns(id)`
- Fields:
  - `question_text` (TEXT)
  - `order_number` (INTEGER)
  - Timestamps: `created_at`, `updated_at`

#### weekly_responses
- Primary key: `id` (UUID)
- Foreign keys:
  - `user_id` references `auth.users(id)`
  - `question_id` references `weekly_questions(id)`
- Fields:
  - `response` (TEXT)
  - Timestamps: `created_at`, `updated_at`

#### user_weekly_progress
- Primary key: `id` (UUID)
- Foreign keys:
  - `user_id` references `auth.users(id)`
  - `column_id` references `weekly_columns(id)`
  - `last_question_id` references `weekly_questions(id)`
- Fields:
  - `completed` (BOOLEAN)
  - Timestamps: `created_at`, `updated_at`

### Character System

#### character_profiles
- Primary key: `id` (UUID)
- Foreign key: `user_id` references `auth.users(id)`
- Fields:
  - `avatar_url` (TEXT)
  - `display_name` (TEXT)
  - `title` (TEXT)
  - `level` (INTEGER)
  - `experience_points` (INTEGER)
  - `character_class` (TEXT)
  - `personality_type` (TEXT)
  - `achievements` (JSONB)
  - `badges` (JSONB)
  - `stats` (JSONB)
  - Timestamps: `created_at`, `updated_at`

#### character_traits
- Primary key: `id` (UUID)
- Foreign key: `character_id` references `character_profiles(id)`
- Fields:
  - `category` (TEXT)
  - `name` (TEXT)
  - `value` (INTEGER)
  - `icon` (TEXT)
  - Timestamps: `created_at`, `updated_at`

#### character_journey
- Primary key: `id` (UUID)
- Foreign key: `character_id` references `character_profiles(id)`
- Fields:
  - `milestone_type` (TEXT)
  - `title` (TEXT)
  - `description` (TEXT)
  - `impact_score` (INTEGER)
  - `metadata` (JSONB)
  - Timestamp: `created_at`

#### character_relationships
- Primary key: `id` (UUID)
- Foreign keys:
  - `character_id` references `character_profiles(id)`
  - `related_character_id` references `character_profiles(id)`
- Fields:
  - `relationship_type` (relationship_type)
  - `strength` (INTEGER)
  - `started_at` (TIMESTAMP)
  - `metadata` (JSONB)
  - Timestamps: `created_at`, `updated_at`
  - Constraint: UNIQUE(character_id, related_character_id)

#### character_skills
- Primary key: `id` (UUID)
- Foreign key: `character_id` references `character_profiles(id)`
- Fields:
  - `name` (TEXT)
  - `category` (TEXT)
  - `level` (INTEGER)
  - `experience_points` (INTEGER)
  - `mastery_percentage` (FLOAT)
  - `icon` (TEXT)
  - Timestamps: `created_at`, `updated_at`

#### character_inventory
- Primary key: `id` (UUID)
- Foreign key: `character_id` references `character_profiles(id)`
- Fields:
  - `item_type` (TEXT)
  - `name` (TEXT)
  - `description` (TEXT)
  - `quantity` (INTEGER)
  - `metadata` (JSONB)
  - `acquired_at` (TIMESTAMP)
  - Timestamps: `created_at`, `updated_at`

#### character_quests
- Primary key: `id` (UUID)
- Foreign key: `character_id` references `character_profiles(id)`
- Fields:
  - `title` (TEXT)
  - `description` (TEXT)
  - `status` (quest_status)
  - `priority` (INTEGER)
  - `rewards` (JSONB)
  - `started_at` (TIMESTAMP)
  - `completed_at` (TIMESTAMP)
  - `deadline` (TIMESTAMP)
  - Timestamps: `created_at`, `updated_at`

## Row Level Security (RLS)

All tables have RLS enabled with the following default policies:

### user_profiles
- SELECT: Users can view their own profile
- UPDATE: Users can update their own profile
- INSERT: Users can insert their own profile

## Indexes

Performance indexes are created for:
- All foreign key columns
- Frequently queried columns
- Relationship lookups

## Triggers

### update_updated_at_column
- Automatically updates the `updated_at` timestamp when a record is modified
