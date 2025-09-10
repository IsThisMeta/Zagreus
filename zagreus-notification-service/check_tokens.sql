-- Check what tokens are currently active
SELECT 
    token,
    is_active,
    environment,
    created_at,
    updated_at,
    last_used
FROM device_tokens 
WHERE user_id = 'e4cdb381-0f04-4fbf-b932-50f496394845'
ORDER BY last_used DESC;