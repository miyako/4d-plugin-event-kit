#include "4DPluginAPI.h"

#define HELPER_REGISTERED_NAME @"eventKitHelper"
#define THIS_BUNDLE_ID @"com.4D.4DPlugin.miyako.EventKit"

@protocol EventKitHelperInterface

#pragma mark -
#pragma mark STORE
#pragma mark -

- (NSNumber *)commit;
- (NSString *)storeIdentifier;//not used

#pragma mark -
#pragma mark SOURCE
#pragma mark -

- (NSArray *)sources;
- (NSString *)titleForSource:(NSString *)identifier;
- (NSNumber *)typeForSource:(NSString *)identifier;
- (NSArray *)calendarsForEventsForSource:(NSString *)identifier;
- (NSArray *)calendarsForRemindersForSource:(NSString *)identifier;

#pragma mark -
#pragma mark CALENDAR
#pragma mark -

- (NSString *)createCalendarForSource:(NSString *)identifier type:(NSNumber *)type;
- (NSNumber *)saveCalendar:(NSString *)identifier;
- (NSNumber *)removeCalendar:(NSString *)identifier;
- (NSArray *)calendarsForEvents;
- (NSArray *)calendarsForReminders;
- (NSString *)titleForCalendar:(NSString *)identifier;
- (NSNumber *)setTitle:(NSString *)title forCalendar:(NSString *)identifier;
- (NSNumber *)typeForCalendar:(NSString *)identifier;
- (NSString *)defaultCalendarForNewEvents;
- (NSString *)defaultCalendarForNewReminders;
- (NSString *)sourceForCalendar:(NSString *)identifier;
- (NSColor *)rgbColorForCalendar:(NSString *)identifier;
- (NSNumber *)setRgbColor:(NSColor *)color forCalendar:(NSString *)identifier;

#pragma mark -
#pragma mark REMINDER
#pragma mark -

- (NSString *)newReminderForCalendar:(NSString *)identifier;
- (NSNumber *)saveReminder:(NSString *)identifier;
- (NSNumber *)removeReminder:(NSString *)identifier;
- (NSDate *)startDateForReminder:(NSString *)identifier;
- (NSNumber *)setStartDate:(NSDate *)date forReminder:(NSString *)identifier;
- (NSDate *)dueDateForReminder:(NSString *)identifier;
- (NSNumber *)setDueDate:(NSDate *)date forReminder:(NSString *)identifier;
- (NSDate *)completedDateForReminder:(NSString *)identifier;
- (NSNumber *)setCompletedDate:(NSDate *)date forReminder:(NSString *)identifier;

#pragma mark -
#pragma mark EVENT
#pragma mark -

- (NSString *)newEventForCalendar:(NSString *)identifier;
- (NSNumber *)saveEvent:(NSString *)identifier;
- (NSNumber *)removeEvent:(NSString *)identifier;
- (NSDate *)startDateForEvent:(NSString *)identifier;
- (NSNumber *)setStartDate:(NSDate *)date forEvent:(NSString *)identifier;
- (NSDate *)endDateForEvent:(NSString *)identifier;
- (NSNumber *)setEndDate:(NSDate *)date forEvent:(NSString *)identifier;
- (NSDate *)occurrenceDateForEvent:(NSString *)identifier;
- (NSNumber *)statusForEvent:(NSString *)identifier;
- (NSNumber *)allDayForEvent:(NSString *)identifier;
- (NSNumber *)setAllDay:(NSNumber *)allDay forEvent:(NSString *)identifier;
- (NSString *)organizerNameForEvent:(NSString *)identifier;

#pragma mark -
#pragma mark ITEM
#pragma mark -

- (NSString *)titleForItem:(NSString *)identifier;
- (NSNumber *)setTitle:(NSString *)title forItem:(NSString *)identifier;
- (NSString *)calendarForItem:(NSString *)identifier;
- (NSNumber *)setCalendar:(NSString *)calendar forItem:(NSString *)identifier;
- (NSString *)locationForItem:(NSString *)identifier;
- (NSNumber *)setLocation:(NSString *)location forItem:(NSString *)identifier;
- (NSString *)urlForItem:(NSString *)identifier;
- (NSNumber *)setUrl:(NSString *)url forItem:(NSString *)identifier;
- (NSString *)notesForItem:(NSString *)identifier;
- (NSNumber *)setNotes:(NSString *)notes forItem:(NSString *)identifier;
- (NSArray *)alarmsforItem:(NSString *)identifier;
- (NSNumber *)setAlarms:(NSArray *)alarms forItem:(NSString *)identifier;
- (NSArray *)rulesforItem:(NSString *)identifier;
- (NSNumber *)setRules:(NSArray *)rules forItem:(NSString *)identifier;
- (NSString *)timezoneForItem:(NSString *)identifier;
- (NSNumber *)setTimezone:(NSString *)zone forItem:(NSString *)identifier;
- (NSArray *)attendeeNamesforItem:(NSString *)identifier;
- (NSDate *)modificationDateforItem:(NSString *)identifier;
- (NSArray *)attendeesforItem:(NSString *)identifier;

#pragma mark -
#pragma mark OBJECT
#pragma mark -

-(oneway void)rollbackObject:(NSString *)identifier;
-(oneway void)resetObject:(NSString *)identifier;
-(oneway void)refreshObject:(NSString *)identifier;
-(NSNumber *)objectHasChanges:(NSString *)identifier;
-(NSNumber *)objectIsNew:(NSString *)identifier;

#pragma mark -
#pragma mark QUERY
#pragma mark -

- (NSArray *)queryEventsForStartDate:(NSDate *)startDate endDate:(NSDate *)endDate calendars:(NSArray *)identifiers;
- (NSArray *)queryCompleteRemindersForStartDate:(NSDate *)startDate endDate:(NSDate *)endDate calendars:(NSArray *)identifiers;
- (NSArray *)queryIncompleteRemindersForStartDate:(NSDate *)startDate endDate:(NSDate *)endDate calendars:(NSArray *)identifiers;

@end

@interface EventKitHelper : NSDistantObject <EventKitHelperInterface> {

}

@property(readonly) NSNumber *processIdentifier;

@end

//typedef NSDistantObject *EventKitHelper;

BOOL ConnectionToHelper();
BOOL LaunchHelper();
BOOL TerminateHelper();

#pragma mark -
#pragma mark STORE
#pragma mark -

BOOL _STORE_Commit();

#pragma mark -
#pragma mark SOURCE
#pragma mark -

void _SOURCE_LIST(ARRAY_TEXT &Param1);
BOOL _SOURCE_Get_title(C_TEXT &Param1, C_TEXT &Param2);
BOOL _SOURCE_Get_type(C_TEXT &Param1, C_LONGINT &Param2);
BOOL _SOURCE_Calendar_list(C_TEXT &Param1, ARRAY_TEXT &Param2, C_LONGINT &Param3);

#pragma mark -
#pragma mark CALENDAR
#pragma mark -

void _CALENDAR_Create(C_TEXT &Param1, C_LONGINT &Param2, C_TEXT &returnValue);
BOOL _CALENDAR_Save(C_TEXT &Param1);
BOOL _CALENDAR_Remove(C_TEXT &Param1);
void _CALENDAR_LIST(ARRAY_TEXT &Param1, C_LONGINT &Param2);
BOOL _CALENDAR_Get_default(C_LONGINT &Param1, C_TEXT &returnValue);
BOOL _CALENDAR_Get_title(C_TEXT &Param1, C_TEXT &Param2);
BOOL _CALENDAR_Set_title(C_TEXT &Param1, C_TEXT &Param2);
BOOL _CALENDAR_Get_type(C_TEXT &Param1, C_LONGINT &Param2);
BOOL _CALENDAR_Get_source(C_TEXT &Param1, C_TEXT &Param2);
BOOL _CALENDAR_Get_rgb_color(C_TEXT &Param1, C_REAL &Param2, C_REAL &Param3, C_REAL &Param4);
BOOL _CALENDAR_Set_rgb_color(C_TEXT &Param1, C_REAL &Param2, C_REAL &Param3, C_REAL &Param4);

#pragma mark -
#pragma mark REMINDER
#pragma mark -

void _REMINDER_Create(C_TEXT &Param1, C_TEXT &returnValue);
BOOL _REMINDER_Save(C_TEXT &Param1);
BOOL _REMINDER_Remove(C_TEXT &Param1);
BOOL _REMINDER_Get_start_date(C_TEXT &Param1, C_DATE &Param2, C_TIME &Param3);
BOOL _REMINDER_Set_start_date(C_TEXT &Param1, C_DATE &Param2, C_TIME &Param3);
BOOL _REMINDER_Get_due_date(C_TEXT &Param1, C_DATE &Param2, C_TIME &Param3);
BOOL _REMINDER_Set_due_date(C_TEXT &Param1, C_DATE &Param2, C_TIME &Param3);
BOOL _REMINDER_Get_completed_date(C_TEXT &Param1, C_DATE &Param2, C_TIME &Param3);
BOOL _REMINDER_Set_completed_date(C_TEXT &Param1, C_DATE &Param2, C_TIME &Param3);

#pragma mark -
#pragma mark EVENT
#pragma mark -

void _EVENT_Create(C_TEXT &Param1, C_TEXT &returnValue);
BOOL _EVENT_Save(C_TEXT &Param1);
BOOL _EVENT_Remove(C_TEXT &Param1);
BOOL _EVENT_Get_start_date(C_TEXT &Param1, C_DATE &Param2, C_TIME &Param3);
BOOL _EVENT_Set_start_date(C_TEXT &Param1, C_DATE &Param2, C_TIME &Param3);
BOOL _EVENT_Get_end_date(C_TEXT &Param1, C_DATE &Param2, C_TIME &Param3);
BOOL _EVENT_Set_end_date(C_TEXT &Param1, C_DATE &Param2, C_TIME &Param3);
BOOL _EVENT_Get_occurrence_date(C_TEXT &Param1, C_DATE &Param2, C_TIME &Param3);
BOOL _EVENT_Get_status(C_TEXT &Param1, C_LONGINT &Param2);
BOOL _EVENT_Get_all_day(C_TEXT &Param1, C_LONGINT &Param2);
BOOL _EVENT_Set_all_day(C_TEXT &Param1, C_LONGINT &Param2);
BOOL _EVENT_Get_organizer_name(C_TEXT &Param1, C_TEXT &Param2);

#pragma mark -
#pragma mark ITEM
#pragma mark -

BOOL _ITEM_Get_title(C_TEXT &Param1, C_TEXT &Param2);
BOOL _ITEM_Set_title(C_TEXT &Param1, C_TEXT &Param2);
BOOL _ITEM_Get_calendar(C_TEXT &Param1, C_TEXT &Param2);
BOOL _ITEM_Set_calendar(C_TEXT &Param1, C_TEXT &Param2);
BOOL _ITEM_Get_location(C_TEXT &Param1, C_TEXT &Param2);
BOOL _ITEM_Set_location(C_TEXT &Param1, C_TEXT &Param2);
BOOL _ITEM_Get_url(C_TEXT &Param1, C_TEXT &Param2);
BOOL _ITEM_Set_url(C_TEXT &Param1, C_TEXT &Param2);
BOOL _ITEM_Get_notes(C_TEXT &Param1, C_TEXT &Param2);
BOOL _ITEM_Set_notes(C_TEXT &Param1, C_TEXT &Param2);
BOOL _ITEM_Get_alarms(C_TEXT &Param1, ARRAY_TEXT &Param2);
BOOL _ITEM_Set_alarms(C_TEXT &Param1, ARRAY_TEXT &Param2);
BOOL _ITEM_Get_rules(C_TEXT &Param1, ARRAY_TEXT &Param2);
BOOL _ITEM_Set_rules(C_TEXT &Param1, ARRAY_TEXT &Param2);
BOOL _ITEM_Get_timezone(C_TEXT &Param1, C_TEXT &Param2);
BOOL _ITEM_Set_timezone(C_TEXT &Param1, C_TEXT &Param2);
BOOL _ITEM_Get_attendee_names(C_TEXT &Param1, ARRAY_TEXT &Param2);
BOOL _ITEM_Get_modification_date(C_TEXT &Param1, C_DATE &Param2, C_TIME &Param3);
BOOL _ITEM_Get_attendees(C_TEXT &Param1, ARRAY_TEXT &Param2);

#pragma mark -
#pragma mark OBJECT
#pragma mark -

void _OBJECT_ROLLBACK(C_TEXT &Param1);
void _OBJECT_RESET(C_TEXT &Param1);
void _OBJECT_REFRESH(C_TEXT &Param1);
BOOL _OBJECT_Has_changes(C_TEXT &Param1, C_LONGINT &Param2);
BOOL _OBJECT_Is_new(C_TEXT &Param1, C_LONGINT &Param2);

#pragma mark -
#pragma mark QUERY
#pragma mark -

void _QUERY_EVENT(C_DATE &Param1, C_TIME &Param2, C_DATE &Param3, C_TIME &Param4, ARRAY_TEXT &Param5, ARRAY_TEXT &Param6);
void _QUERY_COMPLETE_REMINDER(C_DATE &Param1, C_TIME &Param2, C_DATE &Param3, C_TIME &Param4, ARRAY_TEXT &Param5, ARRAY_TEXT &Param6);
void _QUERY_INCOMPLETE_REMINDER(C_DATE &Param1, C_TIME &Param2, C_DATE &Param3, C_TIME &Param4, ARRAY_TEXT &Param5, ARRAY_TEXT &Param6);
