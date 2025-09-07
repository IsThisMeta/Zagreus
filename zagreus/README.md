# Zagreus

Zagreus is a self-hosted media software controller. This is a fork of LunaSea.

## Changes from LunaSea

- Uses Supabase instead of Firebase for authentication
- iOS notifications use APNS directly
- Updated theme colors (#5AD2BE for light mode, #236969 for dark mode)
- Notification service runs separately for webhook handling

## Supported Services

Zagreus currently supports:

- [Lidarr](https://github.com/lidarr/lidarr) - Music collection manager
- [Radarr](https://github.com/radarr/radarr) - Movie collection manager
- [Sonarr](https://github.com/sonarr/sonarr) - TV series collection manager
- [NZBGet](https://github.com/nzbget/nzbget) - Usenet downloader
- [SABnzbd](https://github.com/sabnzbd/sabnzbd) - Usenet downloader
- [Newznab Indexer Searching](https://newznab.readthedocs.io/en/latest/misc/api/)
- [NZBHydra2](https://github.com/theotherp/nzbhydra2) - Usenet meta search
- [Tautulli](https://github.com/Tautulli/Tautulli) - Plex analytics and monitoring
- [Wake on LAN](https://en.wikipedia.org/wiki/Wake-on-LAN) - Remote system wake

## Features

- Webhook-based push notifications
- Multiple instance profiles
- Configuration backup and restore
- AMOLED black theme
- iOS support (other platforms coming soon)

> Please note that Zagreus is purely a remote control application, it does not offer any functionality without software installed on a server/computer.

## Installation

Coming soon to app stores. For now, build from source:

```bash
flutter pub get
flutter run
```

## Notification Server

Zagreus uses a separate notification service for handling push notifications. See the [notification service repository](../zagreus-notification-service) for deployment instructions.

## License

This project is licensed under the GNU General Public License v3.0 - see the [LICENSE](LICENSE) file for details.

## Copyright

Copyright (C) 2025 Zebrra Labs LLC

This program is a fork of LunaSea, originally created by Jagandeep Brar.

This program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.

## Contact

- [Email](mailto:hello@zagreus.app)
- [Website](https://www.zagreus.app)
