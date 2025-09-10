-- Create users table if it doesn't exist
-- This mirrors auth.users for webhook validation
CREATE TABLE IF NOT EXISTS public.users (
    id UUID PRIMARY KEY,
    email TEXT NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Create device_tokens table
CREATE TABLE IF NOT EXISTS public.device_tokens (
    id SERIAL PRIMARY KEY,
    user_id UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
    token TEXT NOT NULL,
    device_name TEXT,
    device_model TEXT,
    os_version TEXT,
    app_version TEXT,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    last_used_at TIMESTAMP WITH TIME ZONE,
    UNIQUE(user_id, token)
);

-- Create indexes for performance
CREATE INDEX IF NOT EXISTS idx_device_tokens_user_id ON device_tokens(user_id);
CREATE INDEX IF NOT EXISTS idx_device_tokens_token ON device_tokens(token);
CREATE INDEX IF NOT EXISTS idx_device_tokens_is_active ON device_tokens(is_active);

-- Create updated_at trigger function
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ language 'plpgsql';

-- Apply updated_at triggers
DROP TRIGGER IF EXISTS update_users_updated_at ON public.users;
CREATE TRIGGER update_users_updated_at BEFORE UPDATE ON public.users
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

DROP TRIGGER IF EXISTS update_device_tokens_updated_at ON public.device_tokens;
CREATE TRIGGER update_device_tokens_updated_at BEFORE UPDATE ON public.device_tokens
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- Auto-sync auth users to public users
CREATE OR REPLACE FUNCTION public.sync_auth_users()
RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO public.users (id, email)
    VALUES (NEW.id, NEW.email)
    ON CONFLICT (id) DO UPDATE
    SET email = EXCLUDED.email,
        updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ language 'plpgsql' SECURITY DEFINER;

-- Create trigger to auto-sync new auth users
DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
CREATE TRIGGER on_auth_user_created
    AFTER INSERT OR UPDATE ON auth.users
    FOR EACH ROW EXECUTE FUNCTION public.sync_auth_users();

-- Sync existing auth users
INSERT INTO public.users (id, email)
SELECT id, email FROM auth.users
ON CONFLICT (id) DO UPDATE 
SET email = EXCLUDED.email;

-- Disable RLS on these tables (notification server needs access)
ALTER TABLE public.users DISABLE ROW LEVEL SECURITY;
ALTER TABLE public.device_tokens DISABLE ROW LEVEL SECURITY;

-- Grant permissions to service role
GRANT ALL ON public.users TO service_role;
GRANT ALL ON public.device_tokens TO service_role;
-- Grant sequence permission only if it exists
DO $$ 
BEGIN
    IF EXISTS (SELECT 1 FROM pg_sequences WHERE schemaname = 'public' AND sequencename = 'device_tokens_id_seq') THEN
        GRANT USAGE ON SEQUENCE public.device_tokens_id_seq TO service_role;
    END IF;
END $$;

-- Check if everything worked
SELECT 'Users table created with ' || COUNT(*) || ' users' as status FROM public.users
UNION ALL
SELECT 'Device tokens table created' as status;