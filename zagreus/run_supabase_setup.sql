-- Zagreus Supabase Setup
-- Run this in your Supabase SQL Editor

-- Device tokens table
CREATE TABLE IF NOT EXISTS device_tokens (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    token TEXT NOT NULL UNIQUE,
    device_name TEXT,
    device_model TEXT,
    app_version TEXT,
    ios_version TEXT,
    bundle_id TEXT DEFAULT 'com.zebrralabs.zagreus',
    environment TEXT DEFAULT 'production',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    last_used TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    is_active BOOLEAN DEFAULT true
);

-- Indexes
CREATE INDEX IF NOT EXISTS idx_device_tokens_user_id ON device_tokens(user_id);
CREATE INDEX IF NOT EXISTS idx_device_tokens_token ON device_tokens(token);

-- Backup metadata table (replaces Firestore collection)
CREATE TABLE IF NOT EXISTS backups (
    id TEXT PRIMARY KEY,
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    title TEXT NOT NULL,
    description TEXT,
    timestamp BIGINT NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_backups_user_id ON backups(user_id);

-- Update trigger
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ language 'plpgsql';

CREATE TRIGGER update_device_tokens_updated_at BEFORE UPDATE ON device_tokens
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- Enable RLS
ALTER TABLE device_tokens ENABLE ROW LEVEL SECURITY;
ALTER TABLE backups ENABLE ROW LEVEL SECURITY;

-- RLS Policies
CREATE POLICY "Users can manage own device tokens" ON device_tokens
    FOR ALL USING (auth.uid() = user_id);

CREATE POLICY "Users can view own backups" ON backups
    FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can create own backups" ON backups
    FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can delete own backups" ON backups
    FOR DELETE USING (auth.uid() = user_id);

-- Service role can do anything (for your notification service)
CREATE POLICY "Service role bypass tokens" ON device_tokens
    FOR ALL USING (auth.jwt()->>'role' = 'service_role');

CREATE POLICY "Service role bypass backups" ON backups
    FOR ALL USING (auth.jwt()->>'role' = 'service_role');

-- Create storage bucket for backups
INSERT INTO storage.buckets (id, name, public) 
VALUES ('backups', 'backups', false)
ON CONFLICT (id) DO NOTHING;

-- Storage policies
CREATE POLICY "Users can upload own backups" ON storage.objects
    FOR INSERT WITH CHECK (bucket_id = 'backups' AND (auth.uid())::text = (storage.foldername(name))[1]);

CREATE POLICY "Users can view own backups" ON storage.objects
    FOR SELECT USING (bucket_id = 'backups' AND (auth.uid())::text = (storage.foldername(name))[1]);

CREATE POLICY "Users can delete own backups" ON storage.objects
    FOR DELETE USING (bucket_id = 'backups' AND (auth.uid())::text = (storage.foldername(name))[1]);