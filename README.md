4d-plugin-event-kit
===================

A plugin to read and write calendars, events and reminders in 4D.

### Platform

| carbon | cocoa | win32 | win64 |
|:------:|:-----:|:---------:|:---------:|
||<img src="https://cloud.githubusercontent.com/assets/1725068/22371562/1b091f0a-e4db-11e6-8458-8653954a7cce.png" width="24" height="24" />|||

Mac OS X 10.8 or later.

Implementation of 10.8 SDK [Event Kit](https://developer.apple.com/library/ios/documentation/EventKit/Reference/EventKitFrameworkRef/_index.html) by Apple.

### How to use

Please consult the [wiki](https://github.com/miyako/4d-plugin-event-kit/wiki).

## Notes

This is the 64-bit branch.

## Remarks

Using APIs introduced in 10.8 and deprecated in 10.9.
~~Using a Helper Application since EK only supports 64 bits.~~
~~The user must allow the Helper application to access the CalendarStore.~~

Instead of using a bridge helper app, the plugin calls the API directly.  

4D must be granted access to Calendar and/or Reminder. The system will ask for your permission the first time the plugin is used. If 4D is already in the list and denied access, it will not ask again. You must enable it in System Preferences. Alternatively, you could clear the list with the command [tccutil](https://developer.apple.com/legacy/library/documentation/Darwin/Reference/ManPages/man1/tccutil.1.html).

```sh
tccutil reset Calendar
tccutil reset Reminders
```

<img width="668" alt="registered" src="https://user-images.githubusercontent.com/1725068/27019374-0011ac8c-4f73-11e7-8a3f-0c2b4ec71714.png">

<img width="420" alt="request" src="https://user-images.githubusercontent.com/1725068/27019377-04a9fbf0-4f73-11e7-8172-ea356d111fd6.png">

Apps are identified by thier UTI, so the name (4D 32-bit in the example above can be misleading).

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

```
eventId:=EK EVENT Create (calendarId)
```

Parameter|Type|Description
------------|------------|----
calendarId  | TEXT|
eventId     | TEXT|

```
success:=EK EVENT Get all day (eventId; isAllDay)
```

Parameter|Type|Description
------------|------------|----
eventId     | TEXT|
isAllDay      | LONGINT|
success      | LONGINT|

```
success:=EK EVENT Get end date (eventId; endDate; endTime)
```

Parameter|Type|Description
------------|------------|----
eventId     | TEXT|
endDate       | DATE|
endTime        | TIME|
success      | LONGINT|

```
success:=EK EVENT Get occurrence date (eventId; occurrenceDate; occurrenceTime)
```

Parameter|Type|Description
------------|------------|----
eventId     | TEXT|
occurrenceDate        | DATE|
occurrenceTime         | TIME|
success      | LONGINT|

This property is read-only.

```
success:=EK EVENT Get organizer name (eventId; organizerName)
```

Parameter|Type|Description
------------|------------|----
eventId     | TEXT|
organizerName         | TEXT|
success      | LONGINT|

This property is read-only.

```
success:=EK EVENT Get start date (eventId; startDate; startTime)
```

Parameter|Type|Description
------------|------------|----
eventId     | TEXT|
startDate          | DATE|
startTime           | TIME|
success      | LONGINT|

This property is read-only.

```
success:=EK EVENT Get status (eventId; status)
```

Parameter|Type|Description
------------|------------|----
eventId     | TEXT|
status            | LONGINT|``EK Status Type``
success      | LONGINT|

This property is read-only.

```
success:=EK EVENT Remove (eventId)
```

Parameter|Type|Description
------------|------------|----
eventId     | TEXT|
success      | LONGINT|

```
success:=EK EVENT Save (eventId)
```

Parameter|Type|Description
------------|------------|----
eventId     | TEXT|
success      | LONGINT|

```
success:=EK EVENT Set all day (eventId; isAllDay)
```

Parameter|Type|Description
------------|------------|----
eventId     | TEXT|
isAllDay       | LONGINT|
success      | LONGINT|

```
success:=EK EVENT Set end date (eventId; endDate; endTime)
```

Parameter|Type|Description
------------|------------|----
eventId     | TEXT|
endDate        | DATE|
endTime         | TIME|
success      | LONGINT|

```
success:=EK EVENT Set start date (eventId; startDate; startTime)
```

Parameter|Type|Description
------------|------------|----
eventId     | TEXT|
startDate         | DATE|
startTime          | TIME|
success      | LONGINT|

```
EK QUERY COMPLETE REMINDER (startDate; startTime; endDate; endTime; calendarIds; reminderIds)
```

Parameter|Type|Description
------------|------------|----
startDate         | DATE|
startTime          | TIME|
endDate        | DATE|
endTime         | TIME|
calendarIds       |ARRAY TEXT|
reminderIds        |ARRAY TEXT|

```
EK QUERY EVENT (startDate; startTime; endDate; endTime; calendarIds; eventIds)
```

Parameter|Type|Description
------------|------------|----
startDate         | DATE|
startTime          | TIME|
endDate        | DATE|
endTime         | TIME|
calendarIds       |ARRAY TEXT|
eventIds         |ARRAY TEXT|

```
EK QUERY INCOMPLETE REMINDER (startDate; startTime; endDate; endTime; calendarIds; reminderIds)
```

Parameter|Type|Description
------------|------------|----
startDate         | DATE|
startTime          | TIME|
endDate        | DATE|
endTime         | TIME|
calendarIds       |ARRAY TEXT|
reminderIds          |ARRAY TEXT|

### EK Calendar Type

```
EK Calendar Event (0)
EK Calendar Reminder (1)
```

### EK Status Type

```
EK Status None (0)
EK Status Confirmed (1)
EK Status Tentative (2)
EK Status Canceled (3)
```

### EK Source Type

```
EK Source Local (0)
EK Source Exchange (1)
EK Source CalDAV or iCloud (2)
EK Source MobileMe (3)
EK Source Subscribed (4)
EK Source Birthdays (5)
```
