# Overseerr

## Preparation

* Read through the main [Notifications](./) page
* Copy your device-based or user-based webhook URL from ZebrraSea

## Setup the Webhook

In Overseerr's web GUI, head to Settings -> Notifications -> ZebrraSea. Ensure that the agent is enabled, then follow each section below to setup the webhook:

{% tabs %}
{% tab title="Webhook URL" %}
Paste the full device-based or user-based URL that was copied from ZebrraSea.

Overseerr currently only supports 1 ZebrraSea notification agent, which means you can only setup a single user-based or device-based notification.
{% endtab %}

{% tab title="Profile Name" %}
The profile name field should be an **exact match** to the profile that this module instance was added to within ZebrraSea. Capitalization and punctuation _does_ matter.

{% hint style="warning" %}
This step is only required if you are _**not**_ using the default ZebrraSea profile (`default`). ZebrraSea will assume the default profile when none is supplied.

Correctly setting up this field is critically important to get full deep-linking support.
{% endhint %}
{% endtab %}

{% tab title="Notification Types" %}
Select which events should trigger a push notification. The following triggers are supported:

|             Trigger            | Supported? |
| :----------------------------: | :--------: |
|    Request Pending Approval    |      ✅     |
| Request Automatically Approved |      ✅     |
|        Request Approved        |      ✅     |
|        Request Declined        |      ✅     |
|        Request Available       |      ✅     |
|    Request Processing Failed   |      ✅     |
|         Issue Reported         |      ✅     |
|          Issue Comment         |      ✅     |
|         Issue Resolved         |      ✅     |
|         Issue Reopened         |      ✅     |
{% endtab %}
{% endtabs %}

Once setup, close ZebrraSea and run the webhook test in Overseerr. You should receive a new notification letting you know that ZebrraSea is ready to receive Overseerr notifications!

## Example

An example Overseerr webhook can be seen below:

* This is a user-based notification webhook, meaning it will be sent to all devices that are linked to the user ID `1234567890`.
* The webhook is associated with the profile named `My Profile`.

![](<../../.gitbook/assets/overseerr\_notification\_sample\_v2 (1).png>)
