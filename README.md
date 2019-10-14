4d-plugin-event-kit
===================

A plugin to read and write calendars, events and reminders in 4D.

### Platform

| carbon | cocoa | win32 | win64 |
|:------:|:-----:|:---------:|:---------:|
| |<img src="https://cloud.githubusercontent.com/assets/1725068/22371562/1b091f0a-e4db-11e6-8458-8653954a7cce.png" width="24" height="24" /> | |

### Version

<img src="https://user-images.githubusercontent.com/1725068/41266195-ddf767b2-6e30-11e8-9d6b-2adf6a9f57a5.png" width="32" height="32" />

### Prerequisites

Due to enhanced security requirements from Apple, the app (not the plugin) must be signed with [Calendars](https://developer.apple.com/documentation/bundleresources/entitlements/com_apple_security_personal-information_calendars?language=objc) and [Hardened Runtime](https://developer.apple.com/documentation/bundleresources/entitlements?language=objc) entitlements. The [NSCalendarsUsageDescription](https://developer.apple.com/documentation/bundleresources/information_property_list/nscalendarsusagedescription?language=objc) property list key must also be present.

**Note**: 4D.app itself is signed, but without the above property list entitlements. In order to use the plugin with 4D (interpreted or compiled) you must sign 4D.app with your own Apple Developer certificate.

The command ``EK Request permisson`` returns a status object object with an ``errorMessage`` property when ``success`` is ``false``.

```
$status:=EK Request permisson (EK Calendar Event)
$status:=EK Request permisson (EK Calendar Reminder)
```
