-- Add the missing unique constraint on device_tokens table
ALTER TABLE device_tokens 
ADD CONSTRAINT device_tokens_user_id_token_unique 
UNIQUE (user_id, token);

-- Verify the constraint was added
SELECT conname, contype 
FROM pg_constraint 
WHERE conrelid = 'device_tokens'::regclass;