#import <Cocoa/Cocoa.h>
#import <EventKit/EventKit.h>

@interface EventKitHelper : NSObject {
	
	EKEventStore		*sharedEventStore;
	
	NSMutableArray		*calendarIdsForEvents;
	NSMutableArray		*calendarIdsForReminders;		
	NSMutableArray		*sharedEventSources;
	
	NSMutableArray		*eventIdsForQuery;
	NSMutableArray		*reminderIdsForQuery;
	
	NSMutableArray		*attendeeNames;
	NSMutableArray		*attendeeJsons;
	NSMutableArray		*itemAlarms;	
	NSMutableArray		*itemRules;	
	
	NSNumber			*processIdentifier;
	
	NSCalendar			*gregorianCalendar;
	NSUInteger			dateComponentUnits;

}

- (id)initWithProcessIdentifier:(pid_t)pid;

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

#pragma mark -

@property(readonly) NSNumber *processIdentifier;

@end
