-- Add unique constraint to device_tokens table
ALTER TABLE device_tokens 
DROP CONSTRAINT IF EXISTS device_tokens_user_token_unique;

ALTER TABLE device_tokens 
ADD CONSTRAINT device_tokens_user_token_unique UNIQUE (user_id, token);

-- Delete the old development token
DELETE FROM device_tokens 
WHERE token = '4c14a767432ceaf72d540778e5434517bba94944970ee292ce6364ce8d12427d';

-- Clear any Redis cache entries (this needs to be done separately)