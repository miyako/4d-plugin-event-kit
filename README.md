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

## Syntax

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

Specify whether you want to create an event calendar or a reminder calendar.

```
success:=EK CALENDAR Get default (calendaType; calendarId)
```

Parameter|Type|Description
------------|------------|----
calendarType  |LONGINT|``EK Calendar Type``
success |LONGINT|

Specify whether you want the defalut id for event calendar or reminder calendar.


```
success:=EK CALENDAR Get rgb color (calendarId; red; green; blue)
```

Parameter|Type|Description
------------|------------|----
calendarId   |TEXT|
red    |REAL|
green    |REAL|
blue    |REAL|
success |LONGINT|

```
success:=EK CALENDAR Get source (calendarId; sourceId)
```

Parameter|Type|Description
------------|------------|----
calendarId   |TEXT|
sourceId    |TEXT|
success    |LONGINT|

The source can't be changed for an existing calendar.

```
success:=EK CALENDAR Get title (calendarId; title)
```

Parameter|Type|Description
------------|------------|----
calendarId   |TEXT|
title     |TEXT|
success    |LONGINT|

```
success:=EK CALENDAR Get type (calendarId; calendarSourceType)
```

Parameter|Type|Description
------------|------------|----
calendarId   |TEXT|
calendarSourceType      |LONGINT|``EK Source Type``
success    |LONGINT|


```
EK CALENDAR LIST (calendarIds; calendaType)
```

Parameter|Type|Description
------------|------------|----
calendarIds    |ARRAY TEXT|
calendaType       |LONGINT|``EK Calendar Type``

Specify whether you want the list for event calendars or reminder calendars.

```
success:=EK CALENDAR Remove (calendarId)
```

Parameter|Type|Description
------------|------------|----
calendarId     | TEXT|
success        |LONGINT|

```
success:=EK CALENDAR Save (calendarId)
```

Parameter|Type|Description
------------|------------|----
calendarId     | TEXT|
success        |LONGINT|

To validate any changes you need to commit them to the store, not just save or create. Uncommitted objects are not returned by search.

```
success:=EK CALENDAR Set rgb color (calendarId; red; green; blue)
```

Parameter|Type|Description
------------|------------|----
calendarId     | TEXT|
success        |LONGINT|

```
success:=EK CALENDAR Set title (calendarId; title)
```

Parameter|Type|Description
------------|------------|----
calendarId     | TEXT|
title      | TEXT|
success        |LONGINT|

```
success:=EK OBJECT Has changes (objectId; hasChanges)
```

Parameter|Type|Description
------------|------------|----
objectId      | TEXT|
hasChanges       | LONGINT|
success        |LONGINT|

Methods applies to source, calendar, event or reminder.

```
success:=EK OBJECT Is new (objectId; isNew)
```

Parameter|Type|Description
------------|------------|----
objectId      | TEXT|
isNew        | LONGINT|
success        |LONGINT|

Method applies to source, calendar, event or reminder.

```
EK OBJECT REFRESH (objectId)
```

Parameter|Type|Description
------------|------------|----
objectId      | TEXT|

Method applies to store (default), source, calendar, event or reminder.

```
EK OBJECT RESET (objectId)
```

Parameter|Type|Description
------------|------------|----
objectId      | TEXT|

Method applies to source, calendar, event or reminder.

```
EK OBJECT ROLLBACK (objectId)
```

Parameter|Type|Description
------------|------------|----
objectId      | TEXT|

Method applies to source, calendar, event or reminder.

```
success:=EK ITEM Get alarms (itemId; alarmJsons)
```

Parameter|Type|Description
------------|------------|----
itemId       | TEXT|
alarmJsons        |ARRAY TEXT|
success        | LONGINT|

Method applies to event or reminder.

```
success:=EK ITEM Get attendee names (itemId; attendeeNames)
```

Parameter|Type|Description
------------|------------|----
itemId       | TEXT|
attendeeNames         |ARRAY TEXT|
success        | LONGINT|

Method applies to event or reminder.

```
success:=EK ITEM Get attendees (itemId; attendeeJsons)
```

Parameter|Type|Description
------------|------------|----
itemId       | TEXT|
attendeeNames         |ARRAY TEXT|
success        | LONGINT|

Method applies to event or reminder.

```
success:=EK ITEM Get calendar (itemId; calendarId)
```

Parameter|Type|Description
------------|------------|----
itemId       | TEXT|
calendarId          | TEXT|
success        | LONGINT|

Method applies to event or reminder.

```
success:=EK ITEM Get location (itemId; location)
```

Parameter|Type|Description
------------|------------|----
itemId       | TEXT|
location           | TEXT|
success        | LONGINT|

Method applies to event or reminder.

```
success:=EK ITEM Get modification date (itemId; modificationDate; modificationTime)
```

Parameter|Type|Description
------------|------------|----
itemId       | TEXT|
modificationDate            | DATE|
modificationTime             | TIME|
success        | LONGINT|

Method applies to event or reminder.

```
success:=EK ITEM Get notes (itemId; notes)
```

Parameter|Type|Description
------------|------------|----
itemId       | TEXT|
notes             | TEXT|
success        | LONGINT|

Method applies to event or reminder.

```
success:=EK ITEM Get rules (itemId; ruleJsons)
```

Parameter|Type|Description
------------|------------|----
itemId       | TEXT|
ruleJsons              |ARRAY TEXT|
success        | LONGINT|

Method applies to event or reminder.

```
success:=EK ITEM Get timezone (itemId; timezone)
```

Parameter|Type|Description
------------|------------|----
itemId       | TEXT|
timezone               | TEXT|
success        | LONGINT|

Method applies to event or reminder.

```
success:=EK ITEM Get title (itemId; title)
```

Parameter|Type|Description
------------|------------|----
itemId       | TEXT|
title                | TEXT|
success        | LONGINT|

Method applies to event or reminder.

```
success:=EK ITEM Get url (itemId; url)
```

Parameter|Type|Description
------------|------------|----
itemId       | TEXT|
url                 | TEXT|
success        | LONGINT|

Method applies to event or reminder.

```
success:=EK ITEM Set alarms (itemId; alarmJsons)
```

Parameter|Type|Description
------------|------------|----
itemId       | TEXT|
alarmJsons                  |ARRAY TEXT|
success        | LONGINT|

Method applies to event or reminder.

```
success:=EK ITEM Set calendar (itemId; calendarId)
```

Parameter|Type|Description
------------|------------|----
itemId       | TEXT|
calendarId                   | TEXT|
success        | LONGINT|

Method applies to event or reminder.

```
success:=EK ITEM Set location (itemId; location)
```

Parameter|Type|Description
------------|------------|----
itemId       | TEXT|
location                    | TEXT|
success        | LONGINT|

Method applies to event or reminder.

```
success:=EK ITEM Set notes (itemId; notes)
```

Parameter|Type|Description
------------|------------|----
itemId       | TEXT|
notes                     | TEXT|
success        | LONGINT|

Method applies to event or reminder.

```
success:=EK ITEM Set rules (itemId; ruleJsons)
```

Parameter|Type|Description
------------|------------|----
itemId       | TEXT|
ruleJsons                      |ARRAY TEXT|
success        | LONGINT|

Method applies to event or reminder.

```
success:=EK ITEM Set timezone (itemId; timezone)
```

Parameter|Type|Description
------------|------------|----
itemId       | TEXT|
timezone                       | TEXT|
success        | LONGINT|

Method applies to event or reminder.

```
success:=EK ITEM Set title (itemId; title)
```

Parameter|Type|Description
------------|------------|----
itemId       | TEXT|
title                        | TEXT|
success        | LONGINT|

Method applies to event or reminder.

```
success:=EK ITEM Set url (itemId; url)
```

Parameter|Type|Description
------------|------------|----
itemId       | TEXT|
url                         | TEXT|
success        | LONGINT|

Method applies to event or reminder.

```
reminderId:=EK REMINDER Create (calendarId)
```

Parameter|Type|Description
------------|------------|----
calendarId| TEXT|
reminderId| TEXT|

```
success:=EK REMINDER Get completed date (reminderId; completedDate; completedTime)
```

Parameter|Type|Description
------------|------------|----
reminderId | TEXT|
completedDate | DATE|
completedTime  | TIME|
success   | LONGINT|

```
success:=EK REMINDER Get due date (reminderId; dueDate; dueTime)
```

Parameter|Type|Description
------------|------------|----
reminderId | TEXT|
dueDate  | DATE|
dueTime   | TIME|
success   | LONGINT|

```
success:=EK REMINDER Get start date (reminderId; startDate; startTime)
```

Parameter|Type|Description
------------|------------|----
reminderId | TEXT|
startDate   | DATE|
startTime    | TIME|
success   | LONGINT|

```
success:=EK REMINDER Remove (reminderId)
```

Parameter|Type|Description
------------|------------|----
reminderId | TEXT|
success   | LONGINT|

```
success:=EK REMINDER Save (reminderId)
```

Parameter|Type|Description
------------|------------|----
reminderId | TEXT|
success   | LONGINT|

```
success:=EK REMINDER Set completed date (reminderId; completedDate; completedTime)
```

Parameter|Type|Description
------------|------------|----
reminderId | TEXT|
completedDate  | DATE|
completedTime   | TIME|
success   | LONGINT|

```
success:=EK REMINDER Set due date (reminderId; dueDate; dueTime)
```

Parameter|Type|Description
------------|------------|----
reminderId | TEXT|
dueDate   | DATE|
dueTime    | TIME|
success   | LONGINT|

```
success:=EK REMINDER Set start date (reminderId; startDate; startTime)
```

Parameter|Type|Description
------------|------------|----
reminderId | TEXT|
startDate    | DATE|
startTime     | TIME|
success   | LONGINT|
