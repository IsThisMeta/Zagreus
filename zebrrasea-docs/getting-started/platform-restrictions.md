# Platform Restrictions

Below showcases which modules or features may not be supported on each platform.

{% hint style="info" %}
Work will continuously be done to try to achieve 100% feature parity between all platforms when possible!
{% endhint %}

## Module Support

If a module is not listed, you can assume that every platform has full support for said module!

### NZBGet

| Platform | Supported? |
| :------: | :--------: |
|  Android |      ✅     |
|    iOS   |      ✅     |
|   Linux  |      ✅     |
|   macOS  |      ✅     |
|  Windows |      ✅     |
|    Web   |      ❌     |

### Overseerr

| Platform | Supported? |
| :------: | :--------: |
|  Android |      ✅     |
|    iOS   |      ✅     |
|   Linux  |      ✅     |
|   macOS  |      ✅     |
|  Windows |      ✅     |
|    Web   |      ❌     |

### Tautulli

| Platform | Supported? |
| :------: | :--------: |
|  Android |      ✅     |
|    iOS   |      ✅     |
|   Linux  |      ✅     |
|   macOS  |      ✅     |
|  Windows |      ✅     |
|    Web   |      ❌     |

### Wake on LAN

| Platform | Supported? |
| :------: | :--------: |
|  Android |      ✅     |
|    iOS   |      ✅     |
|   Linux  |      ✅     |
|   macOS  |      ✅     |
|  Windows |      ✅     |
|    Web   |      ❌     |

## Feature Support

If a feature is not listed, you can assume that every platform has full support for said feature!

### ZebrraSea Cloud Account

|      Platform     | Supported? |
| :---------------: | :--------: |
|      Android      |      ✅     |
|        iOS        |      ✅     |
|       Linux       |      ❌     |
|       macOS       |      ✅     |
|      Windows      |      ❌     |
|    Web (Hosted)   |      ✅     |
| Web (Self-Hosted) |      ❌     |

### Push Notifications

|      Platform     | Supported? |
| :---------------: | :--------: |
|      Android      |      ✅     |
|        iOS        |      ✅     |
|       Linux       |      ❌     |
|       macOS       |      ✅     |
|      Windows      |      ❌     |
|    Web (Hosted)   |      ✅     |
| Web (Self-Hosted) |      ❌     |

## Web-Specific Restrictions

### **HTTPS Requirement**

ZebrraSea's web instances are hosted on [Netlify](https://www.netlify.com/) and use [Let's Encrypt](https://letsencrypt.org/) TLS certificates to ensure that an encrypted connection is utilized when loading the ZebrraSea web application package.

One limitation this incurs is that most modern web browsers no longer support [mixed content](https://developer.mozilla.org/en-US/docs/Web/Security/Mixed\_content), so it is required when using these browsers to utilize a reverse proxy (or something similar) to expose a secure (`HTTPS`) connection to your instances even when hosted on the same machine.

{% hint style="warning" %}
**All network communication occurs directly between your web browser and host machine**, but this is a limitation put forward by the web browsers.
{% endhint %}

### Wake on LAN Support

Wake on LAN support will **never** be supported when using ZebrraSea on the web, because the Wake on LAN protocol relies on the [User Datagram Protocol (UDP)](https://en.wikipedia.org/wiki/User\_Datagram\_Protocol). UDP connections are not supported in the web browser because of underlying security constraints, and so it will not be possible to utilize wake on LAN now or at any point in the future when using ZebrraSea on the web.
