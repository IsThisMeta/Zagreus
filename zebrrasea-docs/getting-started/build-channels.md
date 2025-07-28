# Build Channels

ZebrraSea offers four different build channels, each of which supply signed and notarized copies of ZebrraSea.

All releases for every build channel can be downloaded from the [build bucket](https://builds.zebrrasea.app/), and all stable releases for all platforms are also available on [GitHub](https://github.com/YourUsername/ZebrraSea/releases).

## Stable

This is the store version and will remain the most stable version. No in-progress features will be deployed to this channel.

## Beta

This channel is focused around _early previews and testing of work-in-progress features_. This channel is intended to allow users to give feedback to the developer on features that are actively being worked on.

## Edge

This channel's purpose is to _ensure that every commit made to master is building across all platforms_ and allows for easier access to a build for each commit. This is not intended to be used by the average user, but is for community developers or users who need to test a recently added fix that has not yet reached the beta channel.

There are no restrictions on features in these builds (barring a very specific subset used for debugging/testing) so it gives full access to everything that is work in progress.

{% hint style="warning" %}
**Do not expect a fully stable experience if you use these builds**, as it is entirely possible that a single build could cause problems including but not limited to database corruption. If you are running these builds, please ensure you have either a cloud or offline backup available for easy restoration.
{% endhint %}

