4d-plugin-event-kit
===================

A plugin to read and write calendars, events and reminders in 4D.

### Platform

| carbon | cocoa | win32 | win64 |
|:------:|:-----:|:---------:|:---------:|
|<img src="https://cloud.githubusercontent.com/assets/1725068/22371562/1b091f0a-e4db-11e6-8458-8653954a7cce.png" width="24" height="24" />||||

Mac OS X 10.8 or later.

Implementation of 10.8 SDK [Event Kit](https://developer.apple.com/library/ios/documentation/EventKit/Reference/EventKitFrameworkRef/_index.html) by Apple.

### How to use

Please consult the [wiki](https://github.com/miyako/4d-plugin-event-kit/wiki).

## Remarks

Using APIs introduced in 10.8 and deprecated in 10.9.
Using a Helper Application since EK only supports 64 bits.
The user must allow the Helper application to access the CalendarStore.

### Syntax

```
success:=EK STORE Commit
```

Parameter|Type|Description
------------|------------|----
success |LONGINT|

Commits changes to the Calendar database. Changes made to a calendar, event or reminder are not stored in the database until you actually commit them.

```
success:=EK SOURCE Calendar list (sourceId; calendarIds; calendaType)
```

Parameter|Type|Description
------------|------------|----
sourceId  |TEXT|
calendarIds   |ARRAY TEXT|
calendaType   |LONGINT|``EK Calendar Type``
success |LONGINT|

Specify whether you want the list for event calendars or reminder calendars.

```
success:=EK SOURCE Get title (sourceId; title)
```

Parameter|Type|Description
------------|------------|----
sourceId  |TEXT|
success |LONGINT|

```
success:=EK SOURCE Get type (sourceId; sourceType)
```

Parameter|Type|Description
------------|------------|----
sourceId  |TEXT|
success |LONGINT|

```
EK SOURCE LIST (sourceIds)
```

Parameter|Type|Description
------------|------------|----
sourceIds  |ARRAY TEXT|

```
calendarId:=EK CALENDAR Create (source; calendarType)
```

Parameter|Type|Description
------------|------------|----
source   |TEXT|
calendarType  |LONGINT|``EK Calendar Type``
calendarId   |TEXT|

```
success:=EK CALENDAR Get default (calendaType; calendarId)
```

Parameter|Type|Description
------------|------------|----
calendarType  |LONGINT|``EK Calendar Type``
success |LONGINT|
