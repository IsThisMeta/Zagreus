-- Zagreus Notification Service Schema for Supabase

-- Device tokens table
CREATE TABLE device_tokens (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    token TEXT NOT NULL UNIQUE,
    device_name TEXT,
    device_model TEXT,
    app_version TEXT,
    ios_version TEXT,
    bundle_id TEXT DEFAULT 'com.zebrralabs.zagreus',
    environment TEXT DEFAULT 'production', -- 'production' or 'development'
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    last_used TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    is_active BOOLEAN DEFAULT true
);

-- Index for faster lookups
CREATE INDEX idx_device_tokens_user_id ON device_tokens(user_id);
CREATE INDEX idx_device_tokens_token ON device_tokens(token);
CREATE INDEX idx_device_tokens_active ON device_tokens(is_active);

-- Notification settings per user
CREATE TABLE notification_settings (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    sound_enabled BOOLEAN DEFAULT true,
    interruption_level TEXT DEFAULT 'active', -- 'passive', 'active', 'time-sensitive', 'critical'
    
    -- Per-service settings
    radarr_enabled BOOLEAN DEFAULT true,
    sonarr_enabled BOOLEAN DEFAULT true,
    lidarr_enabled BOOLEAN DEFAULT true,
    overseerr_enabled BOOLEAN DEFAULT true,
    tautulli_enabled BOOLEAN DEFAULT true,
    
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    
    CONSTRAINT valid_interruption_level CHECK (interruption_level IN ('passive', 'active', 'time-sensitive', 'critical'))
);

-- One settings row per user
CREATE UNIQUE INDEX idx_notification_settings_user_id ON notification_settings(user_id);

-- Failed notifications for debugging/retry
CREATE TABLE failed_notifications (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    device_token_id UUID REFERENCES device_tokens(id) ON DELETE SET NULL,
    module TEXT NOT NULL,
    title TEXT,
    body TEXT,
    error_message TEXT,
    error_code TEXT,
    payload JSONB,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Webhook tokens for backwards compatibility (optional)
-- This allows using device-specific or user-specific webhook URLs
CREATE TABLE webhook_tokens (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    token TEXT NOT NULL UNIQUE DEFAULT encode(gen_random_bytes(32), 'hex'),
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    device_token_id UUID REFERENCES device_tokens(id) ON DELETE CASCADE,
    name TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    last_used TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    is_active BOOLEAN DEFAULT true
);

CREATE INDEX idx_webhook_tokens_token ON webhook_tokens(token);

-- Update trigger for updated_at
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ language 'plpgsql';

CREATE TRIGGER update_device_tokens_updated_at BEFORE UPDATE ON device_tokens
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_notification_settings_updated_at BEFORE UPDATE ON notification_settings
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- RLS Policies (Row Level Security)
ALTER TABLE device_tokens ENABLE ROW LEVEL SECURITY;
ALTER TABLE notification_settings ENABLE ROW LEVEL SECURITY;
ALTER TABLE failed_notifications ENABLE ROW LEVEL SECURITY;
ALTER TABLE webhook_tokens ENABLE ROW LEVEL SECURITY;

-- Users can only see/modify their own data
CREATE POLICY "Users can view own device tokens" ON device_tokens
    FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own device tokens" ON device_tokens
    FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own device tokens" ON device_tokens
    FOR UPDATE USING (auth.uid() = user_id);

CREATE POLICY "Users can delete own device tokens" ON device_tokens
    FOR DELETE USING (auth.uid() = user_id);

CREATE POLICY "Users can view own notification settings" ON notification_settings
    FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can manage own notification settings" ON notification_settings
    FOR ALL USING (auth.uid() = user_id);

CREATE POLICY "Users can view own failed notifications" ON failed_notifications
    FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can view own webhook tokens" ON webhook_tokens
    FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can manage own webhook tokens" ON webhook_tokens
    FOR ALL USING (auth.uid() = user_id);

-- Service role bypass (for your notification service)
CREATE POLICY "Service role bypass" ON device_tokens
    FOR ALL USING (auth.jwt()->>'role' = 'service_role');

CREATE POLICY "Service role bypass" ON notification_settings
    FOR ALL USING (auth.jwt()->>'role' = 'service_role');

CREATE POLICY "Service role bypass" ON failed_notifications
    FOR ALL USING (auth.jwt()->>'role' = 'service_role');

CREATE POLICY "Service role bypass" ON webhook_tokens
    FOR ALL USING (auth.jwt()->>'role' = 'service_role');