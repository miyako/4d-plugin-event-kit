4d-plugin-event-kit
===================

![obsolete-word-black-frame-word-obsolete-word-black-frame-d-rendering-123942590](https://user-images.githubusercontent.com/1725068/78463940-29122280-771e-11ea-8be8-a7830725403e.jpg)

A plugin to read and write calendars, events and reminders in 4D.

### Platform

| carbon | cocoa | win32 | win64 |
|:------:|:-----:|:---------:|:---------:|
||<img src="https://cloud.githubusercontent.com/assets/1725068/22371562/1b091f0a-e4db-11e6-8458-8653954a7cce.png" width="24" height="24" />|||

### Version

<img width="32" height="32" src="https://user-images.githubusercontent.com/1725068/73986501-15964580-4981-11ea-9ac1-73c5cee50aae.png"> <img src="https://user-images.githubusercontent.com/1725068/73987971-db2ea780-4984-11ea-8ada-e25fb9c3cf4e.png" width="32" height="32" />

### Prerequisites

Due to enhanced security requirements from Apple, the app (not the plugin) must be signed with [Calendars](https://developer.apple.com/documentation/bundleresources/entitlements/com_apple_security_personal-information_calendars?language=objc) and [Hardened Runtime](https://developer.apple.com/documentation/bundleresources/entitlements?language=objc) entitlements. The [NSCalendarsUsageDescription](https://developer.apple.com/documentation/bundleresources/information_property_list/nscalendarsusagedescription?language=objc) property list key must also be present.

**Note**: 4D.app itself is signed, but without the above property list entitlements. In order to use the plugin with 4D (interpreted or compiled) you must sign 4D.app with your own Apple Developer certificate.

The command ``EK Request permisson`` returns a status object object with an ``errorMessage`` property when ``success`` is ``false``.

```
$status:=EK Request permisson (EK Calendar Event)
$status:=EK Request permisson (EK Calendar Reminder)
```

#### Remarks

Unimplemented commands:

* EK_ITEM_Set_alarms
* EK_ITEM_Set_rules

Commands that return arrays are thread unsafe.

[manifest.json](https://github.com/miyako/4d-plugin-event-kit/blob/master/event-kit/manifest.json)
