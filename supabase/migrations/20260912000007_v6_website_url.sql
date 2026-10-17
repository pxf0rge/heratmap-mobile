-- V6: Add website_url to factories
-- Run this in Supabase SQL Editor

ALTER TABLE factories ADD COLUMN IF NOT EXISTS website_url text DEFAULT '';
