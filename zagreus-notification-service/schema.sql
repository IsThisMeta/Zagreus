-- Create notification_devices table
CREATE TABLE IF NOT EXISTS notification_devices (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    user_id TEXT NOT NULL,
    device_token TEXT NOT NULL,
    device_type TEXT NOT NULL DEFAULT 'ios',
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc', NOW()),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc', NOW()),
    last_seen_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc', NOW()),
    UNIQUE(user_id, device_token)
);

-- Create indexes for better performance
CREATE INDEX IF NOT EXISTS idx_notification_devices_user_id ON notification_devices(user_id);
CREATE INDEX IF NOT EXISTS idx_notification_devices_token ON notification_devices(device_token);
CREATE INDEX IF NOT EXISTS idx_notification_devices_active ON notification_devices(is_active);

-- Create updated_at trigger
CREATE OR REPLACE FUNCTION update_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = TIMEZONE('utc', NOW());
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER update_notification_devices_updated_at
    BEFORE UPDATE ON notification_devices
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at();

-- Create RLS policies (if you want to enable Row Level Security)
ALTER TABLE notification_devices ENABLE ROW LEVEL SECURITY;

-- Allow users to manage their own devices
CREATE POLICY "Users can view own devices" ON notification_devices
    FOR SELECT USING (auth.uid()::text = user_id);

CREATE POLICY "Users can insert own devices" ON notification_devices
    FOR INSERT WITH CHECK (auth.uid()::text = user_id);

CREATE POLICY "Users can update own devices" ON notification_devices
    FOR UPDATE USING (auth.uid()::text = user_id);

CREATE POLICY "Users can delete own devices" ON notification_devices
    FOR DELETE USING (auth.uid()::text = user_id);