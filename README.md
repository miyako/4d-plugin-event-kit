4d-plugin-event-kit
===================

A plugin to read and write calendars, events and reminders in 4D.

##Platform

| carbon | cocoa | win32 | win64 |
|:------:|:-----:|:---------:|:---------:|
|🆗|🚫|🚫|🚫|

Commands
---

```c
// --- EK Store
EK_STORE_Commit

// --- EK Source
EK_SOURCE_Get_type
EK_SOURCE_Get_title
EK_SOURCE_LIST
EK_SOURCE_Calendar_list

// --- EK Calendar
EK_CALENDAR_Get_rgb_color
EK_CALENDAR_Set_rgb_color
EK_CALENDAR_Remove
EK_CALENDAR_Save
EK_CALENDAR_Get_default
EK_CALENDAR_Get_type
EK_CALENDAR_LIST
EK_CALENDAR_Create
EK_CALENDAR_Get_title
EK_CALENDAR_Set_title
EK_CALENDAR_Get_source

// --- EK Object
EK_OBJECT_ROLLBACK
EK_OBJECT_RESET
EK_OBJECT_REFRESH
EK_OBJECT_Has_changes
EK_OBJECT_Is_new

// --- EK Item
EK_ITEM_Get_attendees
EK_ITEM_Get_calendar
EK_ITEM_Get_title
EK_ITEM_Set_title
EK_ITEM_Get_location
EK_ITEM_Set_location
EK_ITEM_Get_url
EK_ITEM_Set_url
EK_ITEM_Get_notes
EK_ITEM_Set_notes
EK_ITEM_Get_alarms
EK_ITEM_Set_alarms
EK_ITEM_Get_rules
EK_ITEM_Set_rules
EK_ITEM_Get_timezone
EK_ITEM_Set_timezone
EK_ITEM_Set_calendar
EK_ITEM_Get_attendee_names
EK_ITEM_Get_modification_date

// --- EK Reminder
EK_REMINDER_Create
EK_REMINDER_Set_start_date
EK_REMINDER_Get_start_date
EK_REMINDER_Set_due_date
EK_REMINDER_Get_due_date
EK_REMINDER_Set_completed_date
EK_REMINDER_Get_completed_date
EK_REMINDER_Remove
EK_REMINDER_Save

// --- EK Event
EK_EVENT_Create
EK_EVENT_Set_start_date
EK_EVENT_Get_start_date
EK_EVENT_Set_end_date
EK_EVENT_Get_end_date
EK_EVENT_Get_occurrence_date
EK_EVENT_Get_status
EK_EVENT_Get_all_day
EK_EVENT_Set_all_day
EK_EVENT_Get_organizer_name
EK_EVENT_Save
EK_EVENT_Remove

// --- EK Query
EK_QUERY_EVENT
EK_QUERY_COMPLETE_REMINDER
EK_QUERY_INCOMPLETE_REMINDER
```

Implementation of 10.8 SDK [Event Kit](https://developer.apple.com/library/ios/documentation/EventKit/Reference/EventKitFrameworkRef/_index.html) by Apple.

How to use
----------
Please consult the [wiki](https://github.com/miyako/4d-plugin-event-kit/wiki).

Platform
--------
Mac OS X 10.8 or later.

Remarks
-------
Using APIs introduced in 10.8 and deprecated in 10.9.
Using a Helper Application since EK only supports 64 bits.
The user must allow the Helper application to access the CalendarStore.
