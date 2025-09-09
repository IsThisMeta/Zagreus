# Push Notifications Setup Guide

## Prerequisites
1. Apple Developer Account
2. Zagreus app bundle ID: `app.zagreus`
3. Access to your notification server

## Step 1: Create APNs Auth Key

1. Go to [Apple Developer Portal](https://developer.apple.com/account)
2. Navigate to **Certificates, Identifiers & Profiles** → **Keys**
3. Click **+** to create a new key
4. Name it "Zagreus Push Notifications"
5. Check **Apple Push Notifications service (APNs)**
6. Click **Continue** then **Register**
7. Download the `.p8` file (⚠️ You can only download once!)
8. Note your:
   - **Key ID**: Shown on the page (e.g., `ABC123DEFG`)
   - **Team ID**: Found in Membership page (e.g., `1234567890`)

## Step 2: Configure Zagreus App

1. Copy `lib/config/supabase_config.dart.example` to `lib/config/supabase_config.dart`
2. Fill in your APNS details:
   ```dart
   static const String apnsKeyId = 'YOUR_KEY_ID';
   static const String apnsTeamId = 'YOUR_TEAM_ID';
   static const String apnsBundleId = 'app.zagreus';
   ```

## Step 3: Upload .p8 Key to Notification Server

Your notification server at `zagreus-notifications.fly.dev` needs the `.p8` file to send notifications.

### Option A: Environment Variable (Recommended)
Set the p8 key content as an environment variable on your server:
```bash
fly secrets set APNS_KEY="$(cat AuthKey_XXXXXXXXXX.p8)"
```

### Option B: Direct Upload
Upload the .p8 file to your server's secure storage.

## Step 4: Test Notifications

1. Open Zagreus app
2. Go to **Settings** → **Notifications**
3. Enable **In-App Notifications**
4. Tap **Test Push Notifications**
5. You should see your device token and receive a test notification

## Troubleshooting

### No Device Token
- Ensure notifications are enabled in iOS Settings
- Check that `aps-environment` is in your entitlements file
- Verify your provisioning profile includes push notifications

### Token Registration Failed
- Check your notification server is running
- Verify the server URL in `supabase/messaging.dart`
- Check server logs for registration errors

### No Notifications Received
- Verify your .p8 key is valid and not expired
- Ensure Key ID and Team ID match your .p8 file
- Check that bundle ID matches your app
- For development, ensure using sandbox APNS endpoint

## Production Checklist

- [ ] Update `aps-environment` to `production` in Runner.entitlements
- [ ] Use production APNS endpoint on server
- [ ] Test with TestFlight build
- [ ] Monitor notification delivery rates