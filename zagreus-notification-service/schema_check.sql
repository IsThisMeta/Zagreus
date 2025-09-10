-- First, check if the table already exists
SELECT EXISTS (
    SELECT FROM information_schema.tables 
    WHERE table_schema = 'public' 
    AND table_name = 'notification_devices'
);

-- If you need to see the existing structure:
-- \d notification_devices

-- If you need to drop and recreate (BE CAREFUL - this will delete all data):
-- DROP TABLE IF EXISTS notification_devices CASCADE;

-- If the table doesn't exist, just run this part:
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

-- Create indexes only if they don't exist
CREATE INDEX IF NOT EXISTS idx_notification_devices_user_id ON notification_devices(user_id);
CREATE INDEX IF NOT EXISTS idx_notification_devices_token ON notification_devices(device_token);
CREATE INDEX IF NOT EXISTS idx_notification_devices_active ON notification_devices(is_active);

-- The trigger and function can be safely re-created
CREATE OR REPLACE FUNCTION update_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = TIMEZONE('utc', NOW());
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS update_notification_devices_updated_at ON notification_devices;
CREATE TRIGGER update_notification_devices_updated_at
    BEFORE UPDATE ON notification_devices
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at();