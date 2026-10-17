-- V7: Phase boundaries + POI (Points of Interest)
-- Run this in Supabase SQL Editor

-- Phase boundaries: store polygon coordinates as JSON array of [lat, lon]
-- Example: [[34.21,62.20],[34.22,62.21],[34.23,62.20],[34.21,62.20]]
ALTER TABLE phases ADD COLUMN IF NOT EXISTS boundary jsonb DEFAULT '[]'::jsonb;

-- Points of Interest table
CREATE TABLE IF NOT EXISTS pois (
  id bigserial PRIMARY KEY,
  name text NOT NULL,
  name_en text DEFAULT '',
  lat double precision NOT NULL,
  lon double precision NOT NULL,
  icon text DEFAULT 'location_on',
  category text DEFAULT 'general',
  is_active boolean DEFAULT true,
  sort_order integer DEFAULT 0,
  created_at timestamptz DEFAULT now()
);

-- Enable RLS on pois
ALTER TABLE pois ENABLE ROW LEVEL SECURITY;

-- Public read for pois
CREATE POLICY "Public can read pois" ON pois
  FOR SELECT USING (true);

-- Authenticated write for pois
CREATE POLICY "Authenticated can insert pois" ON pois
  FOR INSERT WITH CHECK (auth.role() = 'authenticated');

CREATE POLICY "Authenticated can update pois" ON pois
  FOR UPDATE USING (auth.role() = 'authenticated');

CREATE POLICY "Authenticated can delete pois" ON pois
  FOR DELETE USING (auth.role() = 'authenticated');
