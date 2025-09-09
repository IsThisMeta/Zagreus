# Webhook Implementation Summary

## Overview
Successfully implemented automatic webhook injection for both Radarr and Sonarr in the Zagreus app, following the pattern used by Ruddarr (MIT licensed).

## What Was Implemented

### 1. Radarr Webhook Support
- **API Layer**: Created notification models and command handlers
  - `/lib/api/radarr/models/notification/notification.dart` - Notification model with webhook factory
  - `/lib/api/radarr/commands/notification.dart` - CRUD operations for notifications
- **Webhook Manager**: `/lib/modules/radarr/core/webhook_manager.dart`
  - Automatically creates/updates webhooks named "Zagreus"
  - Uses Supabase user ID in webhook URL for user-specific routing
  - Supports testing webhook connectivity
- **State Integration**: Modified RadarrState to sync webhooks on profile load
- **UI**: Added "Test Webhook" option to Radarr "More" menu

### 2. Sonarr Webhook Support
- **API Layer**: Created notification support for Sonarr API
  - `/lib/api/sonarr/models/notification/notification.dart` - Notification model
  - `/lib/api/sonarr/controllers/notification.dart` - Controller for notification operations
- **Webhook Manager**: `/lib/modules/sonarr/core/webhook_manager.dart`
  - Same functionality as Radarr webhook manager
  - Automatically manages Sonarr webhooks
- **State Integration**: Modified SonarrState to sync webhooks on profile load
- **UI**: Added "Test Webhook" option to Sonarr "More" menu

### 3. Settings UI
- Updated `/lib/modules/settings/routes/notifications/route.dart`
- Added webhook status section showing:
  - Automatic webhook injection status
  - Information about how webhooks work
  - Detailed explanation in a bottom sheet

## How It Works

1. **Automatic Creation**: When a user configures a Radarr/Sonarr profile, Zagreus automatically creates a webhook in that instance
2. **User-Specific URLs**: Each webhook URL includes the Supabase user ID:
   - Radarr: `https://zagreus-notifications.fly.dev/v1/radarr/user/{userID}`
   - Sonarr: `https://zagreus-notifications.fly.dev/v1/sonarr/user/{userID}`
3. **Event Types**: Webhooks are configured to receive all major events:
   - Downloads, grabs, upgrades, renames
   - Media added/deleted events
   - Health issues and manual interaction required
4. **Testing**: Users can test webhooks from the "More" menu in each module

## Key Features
- Zero configuration required from users
- Automatic webhook updates when profiles change
- Secure user-specific webhook URLs
- Easy testing functionality
- Clear status information in settings

## Technical Details
- Follows existing Zagreus patterns for API integration
- Uses JSON serialization for API models
- Integrates with existing state management
- Maintains backward compatibility

## Future Enhancements
- Add ability to disable/enable specific event types
- Support for webhook signatures/authentication
- Webhook history/logs viewing
- Support for other *arr services (Lidarr, Readarr, etc.)