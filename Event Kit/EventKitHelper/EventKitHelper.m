#import "EventKitHelper.h"


@implementation EventKitHelper

@synthesize processIdentifier;

#pragma mark -

- (id)initWithProcessIdentifier:(pid_t)pid
{
	if(!(self = [super init]))return self;

	sharedEventStore = [[EKEventStore alloc]initWithAccessToEntityTypes:EKEntityMaskEvent|EKEntityMaskReminder];
	
	calendarIdsForEvents = [[NSMutableArray alloc]init];
	calendarIdsForReminders = [[NSMutableArray alloc]init];	
	
	attendeeNames = [[NSMutableArray alloc]init]; 
	attendeeJsons = [[NSMutableArray alloc]init]; 
	itemAlarms = [[NSMutableArray alloc]init]; 
	itemRules = [[NSMutableArray alloc]init]; 	
	
	sharedEventSources = [[NSMutableArray alloc]init];	
	
	eventIdsForQuery = [[NSMutableArray alloc]init];	
	reminderIdsForQuery = [[NSMutableArray alloc]init];
	
	gregorianCalendar = [[NSCalendar alloc]initWithCalendarIdentifier:NSGregorianCalendar];
	
	processIdentifier = [NSNumber numberWithInt:(int)pid];
	
	dateComponentUnits = NSYearCalendarUnit|
		NSMonthCalendarUnit|
		NSDayCalendarUnit|
		NSHourCalendarUnit|
		NSMinuteCalendarUnit|
		NSSecondCalendarUnit|
		NSCalendarCalendarUnit|
		NSTimeZoneCalendarUnit;
	
	return self;
}

- (void)dealloc
{
	[sharedEventStore release];
	
	[calendarIdsForEvents release];
	[calendarIdsForReminders release];	
	
	[sharedEventSources release];
	
	[attendeeNames release];	
	[attendeeJsons release];
	[itemAlarms release];
	[itemRules release];
	
	[eventIdsForQuery release];
	[reminderIdsForQuery release];
	
	[gregorianCalendar release];
	
	[super dealloc];
}

- (NSString *)storeIdentifier{
	return sharedEventStore.eventStoreIdentifier;
}

#pragma mark -
#pragma mark STORE
#pragma mark -

- (NSNumber *)commit
{
	NSError *error;
	
	BOOL success = [sharedEventStore commit:&error];
	
	if(!success){
		NSLog(@"commit failed: %@", [error description]);
	}else{
		return [NSNumber numberWithInt:0];	
	}
	
	return [NSNumber numberWithInt:-1];		
}

#pragma mark -

- (BOOL)_saveCalendar:(EKCalendar *)calendar
{
	NSError *error;
	BOOL success = [sharedEventStore saveCalendar:calendar commit:NO error:&error];
	if(!success){
		NSLog(@"calendar save failed: %@", [error description]);	
		return FALSE;
	}else{
		return TRUE;		
	}
}

- (BOOL)_removeCalendar:(EKCalendar *)calendar
{
	NSError *error;
	BOOL success = [sharedEventStore removeCalendar:calendar commit:NO error:&error];
	if(!success){
		NSLog(@"calendar remove failed: %@", [error description]);	
		return FALSE;
	}else{
		return TRUE;		
	}
}

- (BOOL)_saveEvent:(EKEvent *)event
{
	NSError *error;
	BOOL success = [sharedEventStore saveEvent:event span:EKSpanThisEvent commit:NO error:&error];
	if(!success){
		NSLog(@"event save failed: %@", [error description]);	
		return FALSE;
	}else{
		return TRUE;		
	}
}

- (BOOL)_removeEvent:(EKEvent *)event
{
	NSError *error;
	BOOL success = [sharedEventStore removeEvent:event span:EKSpanThisEvent commit:NO error:&error];
	
	if(!success){
		NSLog(@"event remove failed: %@", [error description]);	
		return FALSE;
	}else{
		return TRUE;		
	}
}

- (BOOL)_saveReminder:(EKReminder *)reminder
{
	NSError *error;
	BOOL success = [sharedEventStore saveReminder:reminder commit:NO error:&error];
	
	if(!success){
		NSLog(@"reminder save failed: %@", [error description]);	
		return FALSE;
	}else{
		return TRUE;		
	}
}

- (BOOL)_removeReminder:(EKReminder *)reminder
{
	NSError *error;
	BOOL success = [sharedEventStore removeReminder:reminder commit:NO error:&error];
	
	if(!success){
		NSLog(@"reminder remove failed: %@", [error description]);	
		return FALSE;
	}else{
		return TRUE;		
	}
}

- (BOOL)_saveItem:(EKCalendarItem *)item
{
    if(item)
    {
        if([item isKindOfClass:[EKEvent class]])
            if([self _saveEvent:(EKEvent *)item])
                return TRUE;
        
        if([item isKindOfClass:[EKReminder class]])
            if([self _saveReminder:(EKReminder *)item])
                return TRUE;    
    }
    return FALSE;
}

- (NSArray *)_createCalendarFromIdentifiers:(NSArray *)identifiers
{
	
	NSMutableArray *calendars = [[NSMutableArray alloc]init];
	
	if(identifiers)
	{
		for(unsigned int i = 0; i < [identifiers count]; ++i){
			
			NSString *identifier = [identifiers objectAtIndex:i];
			
			if(identifier)
			{
				EKCalendar *calendar = [sharedEventStore calendarWithIdentifier:identifier];
				
				if(!calendar){
					NSLog(@"'%@' is not a calendar", identifier);
				}else{
					[calendars addObject:calendar];
				}
			}
		}
	}
	
	return calendars;
}

- (NSPredicate *)_eventPredicateForCalendars:(NSArray *)calendars startDate:(NSDate *)startDate endDate:(NSDate *)endDate
{	
	if(![calendars count])
	{	
		return [sharedEventStore predicateForEventsWithStartDate:startDate endDate:endDate calendars:nil];
	}else{
		return [sharedEventStore predicateForEventsWithStartDate:startDate endDate:endDate calendars:calendars];	
	}	
}

- (NSPredicate *)_completeReminderPredicateForCalendars:(NSArray *)calendars startDate:(NSDate *)startDate endDate:(NSDate *)endDate
{	
	if(![calendars count])
	{	
		return [sharedEventStore predicateForIncompleteRemindersWithDueDateStarting:startDate ending:endDate calendars:nil];
	}else{
		return [sharedEventStore predicateForIncompleteRemindersWithDueDateStarting:startDate ending:endDate calendars:calendars];	
	}	
}

- (NSPredicate *)_incompleteReminderPredicateForCalendars:(NSArray *)calendars startDate:(NSDate *)startDate endDate:(NSDate *)endDate
{	
	if(![calendars count])
	{	
		return [sharedEventStore predicateForIncompleteRemindersWithDueDateStarting:startDate ending:endDate calendars:nil];
	}else{
		return [sharedEventStore predicateForIncompleteRemindersWithDueDateStarting:startDate ending:endDate calendars:calendars];	
	}
}

#pragma mark -
#pragma mark SOURCE
#pragma mark -

- (NSArray *)sources
{
	NSArray *sources = [sharedEventStore sources];

	[sharedEventSources removeAllObjects];	
	[sharedEventSources addObject:@""];
	
	for(unsigned int i = 0; i < [sources count]; ++i){
		
		EKSource *source = [sources objectAtIndex:i];
		[sharedEventSources addObject:source.sourceIdentifier];
		
	}
	
	return sharedEventSources;
}

- (NSString *)titleForSource:(NSString *)identifier
{
	EKSource *source = [sharedEventStore sourceWithIdentifier:identifier];
	
	if(source){
		return source.title; 
	}else{
		NSLog(@"'%@' is not a source", identifier);
	}
	
	return @"";
}

- (NSNumber *)typeForSource:(NSString *)identifier
{
	EKSource *source = [sharedEventStore sourceWithIdentifier:identifier];
	
	if(source){
		return [NSNumber numberWithInt:source.sourceType]; 
	}else{
		NSLog(@"'%@' is not a source", identifier);
	}	
	
	return [NSNumber numberWithInt:-1];
}

- (NSArray *)calendarsForEventsForSource:(NSString *)identifier
{
	EKSource *source = [sharedEventStore sourceWithIdentifier:identifier];
	
	[calendarIdsForEvents removeAllObjects];	
	[calendarIdsForEvents addObject:@""];	
	
	if(!source){
		NSLog(@"'%@' is not a source", identifier);
	}else{
		
		NSArray *calendars = [[source calendarsForEntityType:EKEntityTypeEvent]allObjects];
		
		for(unsigned int i = 0; i < [calendars count]; ++i){
			
			EKCalendar *calendar = [calendars objectAtIndex:i];
			[calendarIdsForEvents addObject:calendar.calendarIdentifier];
			
		}		
		
	}
	
	return calendarIdsForEvents;		
}

- (NSArray *)calendarsForRemindersForSource:(NSString *)identifier
{
	EKSource *source = [sharedEventStore sourceWithIdentifier:identifier];
	
	[calendarIdsForReminders removeAllObjects];	
	[calendarIdsForReminders addObject:@""];	
	
	if(!source){
		NSLog(@"'%@' is not a source", identifier);
	}else{
		
		NSArray *calendars = [[source calendarsForEntityType:EKEntityTypeReminder]allObjects];
		
		for(unsigned int i = 0; i < [calendars count]; ++i){
			
			EKCalendar *calendar = [calendars objectAtIndex:i];
			[calendarIdsForReminders addObject:calendar.calendarIdentifier];
			
		}
		
	}
	
	return calendarIdsForReminders;	
}

#pragma mark -
#pragma mark CALENDAR
#pragma mark -

- (NSString *)createCalendarForSource:(NSString *)identifier type:(NSNumber *)type
{
	EKSource *source = [sharedEventStore sourceWithIdentifier:identifier];
	
	if(!source){
		NSLog(@"'%@' is not a source", identifier);
	}else{
		
		EKCalendar *calendar = [EKCalendar calendarForEntityType:(EKEntityType)[type intValue] eventStore:sharedEventStore];
		
		if(!calendar){
			NSLog(@"failed to create calendar of type %@", type);
		}else{
			calendar.source = source;
			if([self _saveCalendar:calendar])
				return calendar.calendarIdentifier;
		}
	}
	
	return @"";	
}

- (NSNumber *)saveCalendar:(NSString *)identifier
{
	EKCalendar *calendar = [sharedEventStore calendarWithIdentifier:identifier];
	
	if(!calendar){
		NSLog(@"'%@' is not a calendar", identifier);
	}else{
		if([self _saveCalendar:calendar])
			return [NSNumber numberWithInt:0];
	}
	
	return [NSNumber numberWithInt:-1];	
}

- (NSNumber *)removeCalendar:(NSString *)identifier
{
	EKCalendar *calendar = [sharedEventStore calendarWithIdentifier:identifier];
	
	if(!calendar){
		NSLog(@"'%@' is not a calendar", identifier);
	}else{
		if([self _removeCalendar:calendar])
			return [NSNumber numberWithInt:0];
	}
	
	return [NSNumber numberWithInt:-1];		
}

- (NSArray *)calendarsForEvents{
	
	NSArray *calendars = [sharedEventStore calendarsForEntityType:EKEntityTypeEvent];
	
	[calendarIdsForEvents removeAllObjects];
	[calendarIdsForEvents addObject:@""];
	
	for(unsigned int i = 0; i < [calendars count]; ++i){
		
		EKCalendar *calendar = [calendars objectAtIndex:i];
		[calendarIdsForEvents addObject:calendar.calendarIdentifier];
		
	}
	
	return calendarIdsForEvents;
}

- (NSArray *)calendarsForReminders{
	
	NSArray *calendars = [sharedEventStore calendarsForEntityType:EKEntityTypeReminder];
	
	[calendarIdsForReminders removeAllObjects];	
	[calendarIdsForReminders addObject:@""];
	
	for(unsigned int i = 0; i < [calendars count]; ++i){
		
		EKCalendar *calendar = [calendars objectAtIndex:i];
		[calendarIdsForReminders addObject:calendar.calendarIdentifier];
		
	}
	
	return calendarIdsForReminders;
}

- (NSString *)defaultCalendarForNewEvents{
	return sharedEventStore.defaultCalendarForNewEvents.calendarIdentifier;
}

- (NSString *)defaultCalendarForNewReminders{
	return sharedEventStore.defaultCalendarForNewReminders.calendarIdentifier;
}

- (NSString *)titleForCalendar:(NSString *)identifier
{
	EKCalendar *calendar = [sharedEventStore calendarWithIdentifier:identifier];
	
	if(!calendar){
		NSLog(@"'%@' is not a calendar", identifier);		
	}else{
		return calendar.title; 
	}	
	
	return @"";
}

- (NSNumber *)setTitle:(NSString *)title forCalendar:(NSString *)identifier
{
	EKCalendar *calendar = [sharedEventStore calendarWithIdentifier:identifier];
	
	if(!calendar){
		NSLog(@"'%@' is not a calendar", identifier);		
	}else{
		calendar.title = title;
        if([self _saveCalendar:calendar])
            return [NSNumber numberWithInt:0];
	}	
	
	return [NSNumber numberWithInt:-1];
}

- (NSNumber *)typeForCalendar:(NSString *)identifier
{
	EKCalendar *calendar = [sharedEventStore calendarWithIdentifier:identifier];
	
	if(!calendar){
		NSLog(@"'%@' is not a calendar", identifier);
	}else{
		return [NSNumber numberWithInt:calendar.type]; 		
	}	
	
	return [NSNumber numberWithInt:-1];
}

- (NSString *)sourceForCalendar:(NSString *)identifier
{
	EKCalendar *calendar = [sharedEventStore calendarWithIdentifier:identifier];
	
	if(!calendar){
		NSLog(@"'%@' is not a calendar", identifier);
	}else{
		return [calendar.source sourceIdentifier];
	}
	
	return	@"";
}

- (NSColor *)rgbColorForCalendar:(NSString *)identifier
{
	EKCalendar *calendar = [sharedEventStore calendarWithIdentifier:identifier];
	
	if(!calendar){
		NSLog(@"'%@' is not a calendar", identifier);
	}else{
		return calendar.color;
	}
	
	return	nil;
}
- (NSNumber *)setRgbColor:(NSColor *)color forCalendar:(NSString *)identifier
{
	EKCalendar *calendar = [sharedEventStore calendarWithIdentifier:identifier];
	
	if(!calendar){
		NSLog(@"'%@' is not a calendar", identifier);
	}else{
		calendar.color = color;
        if([self _saveCalendar:calendar])
            return [NSNumber numberWithInt:0];
	}
	
	return [NSNumber numberWithInt:-1];
}

#pragma mark -
#pragma mark REMINDER
#pragma mark -

- (NSString *)newReminderForCalendar:(NSString *)identifier
{
	EKCalendar *calendar = [sharedEventStore calendarWithIdentifier:identifier];
	
	if(!calendar){
		calendar = sharedEventStore.defaultCalendarForNewReminders;
	}
	
	if(!calendar){	
		NSLog(@"'%@' is not a calendar", identifier);
	}else{
		EKReminder *reminder = [EKReminder reminderWithEventStore:sharedEventStore];
		reminder.calendar = calendar;
		        
		if([self _saveReminder:reminder])
			return [reminder calendarItemIdentifier];
	}
	
	return @"";	
}

- (NSNumber *)saveReminder:(NSString *)identifier
{
	EKCalendarItem *item = [sharedEventStore calendarItemWithIdentifier:identifier];
    
	if(!item){
		NSLog(@"'%@' does not exist", identifier);
	}else{			        
        if([self _saveItem:item])
            return [NSNumber numberWithInt:0];
	}
	
	return [NSNumber numberWithInt:-1];	
}

- (NSNumber *)removeReminder:(NSString *)identifier
{
	id item = [sharedEventStore calendarItemWithIdentifier:identifier];
	
	if(!item){
		NSLog(@"'%@' does not exist", identifier);
	}else{
		if([item isKindOfClass:[EKReminder class]]){
			
			EKReminder *reminder = item;
			
			if([self _removeReminder:reminder])
				return [NSNumber numberWithInt:0];
			
		}else{
			NSLog(@"'%@' is not a reminder", identifier);
		}
	}
	
	return [NSNumber numberWithInt:-1];		
}

- (NSDate *)startDateForReminder:(NSString *)identifier
{
	id item = [sharedEventStore calendarItemWithIdentifier:identifier];
	
	if(!item){
		NSLog(@"'%@' does not exist", identifier);
	}else{
		if([item isKindOfClass:[EKReminder class]]){
			
			EKReminder *reminder = item;
			return [gregorianCalendar dateFromComponents:reminder.startDateComponents];

		}else{
			NSLog(@"'%@' is not a reminder", identifier);
		}
	}
	
	return nil;
}

- (NSNumber *)setStartDate:(NSDate *)date forReminder:(NSString *)identifier
{
	id item = [sharedEventStore calendarItemWithIdentifier:identifier];
	
	if(!item){
		NSLog(@"'%@' does not exist", identifier);
	}else{
		if([item isKindOfClass:[EKReminder class]]){
			
			EKReminder *reminder = item;
			reminder.startDateComponents = [gregorianCalendar components:dateComponentUnits fromDate:date];
			
            if([self _saveItem:item])
                return [NSNumber numberWithInt:0];
			
		}else{
			NSLog(@"'%@' is not a reminder", identifier);
		}
	}
	
	return [NSNumber numberWithInt:-1];	
}

- (NSDate *)dueDateForReminder:(NSString *)identifier;
{
	id item = [sharedEventStore calendarItemWithIdentifier:identifier];
	
	if(!item){
		NSLog(@"'%@' does not exist", identifier);
	}else{
		if([item isKindOfClass:[EKReminder class]]){
			
			EKReminder *reminder = item;
			return [gregorianCalendar dateFromComponents:reminder.dueDateComponents];

		}else{
			NSLog(@"'%@' is not a reminder", identifier);
		}
	}
	
	return nil;
}

- (NSNumber *)setDueDate:(NSDate *)date forReminder:(NSString *)identifier
{
	id item = [sharedEventStore calendarItemWithIdentifier:identifier];
	
	if(!item){
		NSLog(@"'%@' does not exist", identifier);
	}else{
		if([item isKindOfClass:[EKReminder class]]){
			
			EKReminder *reminder = item;
			reminder.dueDateComponents = [gregorianCalendar components:dateComponentUnits fromDate:date];
			
            if([self _saveItem:item])
                return [NSNumber numberWithInt:0];
			
		}else{
			NSLog(@"'%@' is not a reminder", identifier);
		}
	}
	
	return [NSNumber numberWithInt:-1];			
}

- (NSDate *)completedDateForReminder:(NSString *)identifier
{
	id item = [sharedEventStore calendarItemWithIdentifier:identifier];
	
	if(!item){
		NSLog(@"'%@' does not exist", identifier);
	}else{
		if([item isKindOfClass:[EKReminder class]]){
			
			EKReminder *reminder = item;
			
			return reminder.completionDate;
			
		}else{
			NSLog(@"'%@' is not a reminder", identifier);
		}
	}
	
	return nil;
}

- (NSNumber *)setCompletedDate:(NSDate *)date forReminder:(NSString *)identifier
{
	id item = [sharedEventStore calendarItemWithIdentifier:identifier];
	
	if(!item){
		NSLog(@"'%@' does not exist", identifier);
	}else{
		if([item isKindOfClass:[EKReminder class]]){
			
			EKReminder *reminder = item;

			reminder.completionDate = date;
            
            if([self _saveItem:item])
                return [NSNumber numberWithInt:0];
			
		}else{
			NSLog(@"'%@' is not a reminder", identifier);
		}
	}
	
	return [NSNumber numberWithInt:-1];		
}

#pragma mark -
#pragma mark EVENT
#pragma mark -

- (NSString *)newEventForCalendar:(NSString *)identifier
{
	EKCalendar *calendar = [sharedEventStore calendarWithIdentifier:identifier];
	
	if(!calendar){
		calendar = sharedEventStore.defaultCalendarForNewEvents;
	}
	
	if(!calendar){
		NSLog(@"'%@' is not a calendar", identifier);
	}else{
		EKEvent *event = [EKEvent eventWithEventStore:sharedEventStore];
		event.calendar = calendar;
        
        //mandatory properties to perform save
        event.startDate = [NSDate date];
        event.endDate = [NSDate date];
        
        if([self _saveEvent:event])
            return [event calendarItemIdentifier];
	}		
	
	return @"";		
}

- (NSNumber *)saveEvent:(NSString *)identifier
{
    EKCalendarItem *item = [sharedEventStore calendarItemWithIdentifier:identifier];
    
	if(!item){
		NSLog(@"'%@' does not exist", identifier);
	}else{

		if([self _saveItem:item])
            return [NSNumber numberWithInt:0];
	}
	
	return [NSNumber numberWithInt:-1];
}

- (NSNumber *)removeEvent:(NSString *)identifier
{
	id item = [sharedEventStore calendarItemWithIdentifier:identifier];
	
	if(!item){
		NSLog(@"'%@' does not exist", identifier);
	}else{
		if([item isKindOfClass:[EKEvent class]]){
			
			EKEvent *event = item;
			
			if([self _removeEvent:event])
				return [NSNumber numberWithInt:0];
			
		}else{
			NSLog(@"'%@' is not an event", identifier);
		}
	}
	
	return [NSNumber numberWithInt:-1];		
}

- (NSDate *)startDateForEvent:(NSString *)identifier
{
	id item = [sharedEventStore calendarItemWithIdentifier:identifier];
	
	if(!item){
		NSLog(@"'%@' does not exist", identifier);
	}else{
		if([item isKindOfClass:[EKEvent class]]){
			
			EKEvent *event = item;
            
			return event.startDate;
			
		}else{
			NSLog(@"'%@' is not an event", identifier);
		}
	}
	
	return nil;
}

- (NSNumber *)setStartDate:(NSDate *)date forEvent:(NSString *)identifier
{
	id item = [sharedEventStore calendarItemWithIdentifier:identifier];
	
	if(!item){
		NSLog(@"'%@' does not exist", identifier);
	}else{
		if([item isKindOfClass:[EKEvent class]]){
			
			EKEvent *event = item;
            
			event.startDate = date;
            
            if([self _saveItem:item])
                return [NSNumber numberWithInt:0];
			
		}else{
			NSLog(@"'%@' is not an event", identifier);
		}
	}
	
	return [NSNumber numberWithInt:-1];	
}

- (NSDate *)endDateForEvent:(NSString *)identifier
{
	id item = [sharedEventStore calendarItemWithIdentifier:identifier];
	
	if(!item){
		NSLog(@"'%@' does not exist", identifier);
	}else{
		if([item isKindOfClass:[EKEvent class]]){
			
			EKEvent *event = item;
            
			return event.endDate;
			
		}else{
			NSLog(@"'%@' is not an event", identifier);
		}
	}
	
	return nil;
}

- (NSNumber *)setEndDate:(NSDate *)date forEvent:(NSString *)identifier
{
	id item = [sharedEventStore calendarItemWithIdentifier:identifier];
	
	if(!item){
		NSLog(@"'%@' does not exist", identifier);
	}else{
		if([item isKindOfClass:[EKEvent class]]){
			
			EKEvent *event = item;
            
			event.endDate = date;
            
            if([self _saveItem:item])
                return [NSNumber numberWithInt:0];
			
		}else{
			NSLog(@"'%@' is not an event", identifier);
		}
	}
	
	return [NSNumber numberWithInt:-1];	
}

- (NSDate *)occurrenceDateForEvent:(NSString *)identifier
{
	id item = [sharedEventStore calendarItemWithIdentifier:identifier];
	
	if(!item){
		NSLog(@"'%@' does not exist", identifier);
	}else{
		if([item isKindOfClass:[EKEvent class]]){
			
			EKEvent *event = item;
            
			return event.occurrenceDate;
			
		}else{
			NSLog(@"'%@' is not an event", identifier);
		}
	}
	
	return nil;
}

- (NSNumber *)statusForEvent:(NSString *)identifier
{
	id item = [sharedEventStore calendarItemWithIdentifier:identifier];
	
	if(!item){
		NSLog(@"'%@' does not exist", identifier);
	}else{
		if([item isKindOfClass:[EKEvent class]]){
			
			EKEvent *event = item;

			return [NSNumber numberWithInt:event.status];
			
		}else{
			NSLog(@"'%@' is not an event", identifier);
		}
	}
	
	return [NSNumber numberWithInt:-1];	
}

- (NSNumber *)allDayForEvent:(NSString *)identifier
{
	id item = [sharedEventStore calendarItemWithIdentifier:identifier];
	
	if(!item){
		NSLog(@"'%@' does not exist", identifier);
	}else{
		if([item isKindOfClass:[EKEvent class]]){
			
			EKEvent *event = item;
			
			return [NSNumber numberWithInt:event.allDay];
			
		}else{
			NSLog(@"'%@' is not an event", identifier);
		}
	}
	
	return [NSNumber numberWithInt:-1];	
}

- (NSNumber *)setAllDay:(NSNumber *)allDay forEvent:(NSString *)identifier
{
	id item = [sharedEventStore calendarItemWithIdentifier:identifier];
	
	if(!item){
		NSLog(@"'%@' does not exist", identifier);
	}else{
		if([item isKindOfClass:[EKEvent class]]){
			
			EKEvent *event = item;
            
			event.allDay = [allDay intValue];
            
            if([self _saveItem:item])
                return [NSNumber numberWithInt:0];
			
		}else{
			NSLog(@"'%@' is not an event", identifier);
		}
	}
	
	return [NSNumber numberWithInt:-1];	
}

- (NSString *)organizerNameForEvent:(NSString *)identifier
{
	id item = [sharedEventStore calendarItemWithIdentifier:identifier];
	
	if(!item){
		NSLog(@"'%@' does not exist", identifier);
	}else{
		if([item isKindOfClass:[EKEvent class]]){
			
			EKEvent *event = item;
			
			if(event.organizer)
				return event.organizer.name;
			
		}else{
			NSLog(@"'%@' is not an event", identifier);
		}
	}
	
	return @"";
}

#pragma mark -
#pragma mark ITEM
#pragma mark -

- (NSString *)titleForItem:(NSString *)identifier
{
	EKCalendarItem *item = [sharedEventStore calendarItemWithIdentifier:identifier];
	
	if(!item){
		NSLog(@"'%@' is not a calendar item", identifier);
	}else{
		return item.title; 
	}	
	
	return @"";
}

- (NSNumber *)setTitle:(NSString *)title forItem:(NSString *)identifier
{
	EKCalendarItem *item = [sharedEventStore calendarItemWithIdentifier:identifier];
	
	if(!item){
		NSLog(@"'%@' is not a calendar item", identifier);
	}else{
        
		item.title = title;
        
        if([self _saveItem:item])
            return [NSNumber numberWithInt:0];
	}
	
	return [NSNumber numberWithInt:-1];	
}

- (NSString *)calendarForItem:(NSString *)identifier
{
	EKCalendarItem *item = [sharedEventStore calendarItemWithIdentifier:identifier];
	
	if(!item){
		NSLog(@"'%@' is not a calendar item", identifier);
	}else{
		return item.calendar.calendarIdentifier;
	}
	
	return @"";		
}

- (NSNumber *)setCalendar:(NSString *)calendar forItem:(NSString *)identifier
{
	EKCalendarItem *item = [sharedEventStore calendarItemWithIdentifier:identifier];
	
	if(!item){
		NSLog(@"'%@' is not a calendar item", identifier);
	}else{
		EKCalendar *itemCalendar = [sharedEventStore calendarWithIdentifier:calendar];
		
		if(!itemCalendar){
			NSLog(@"'%@' is not a calendar", calendar);
		}else{
			item.calendar = itemCalendar;
            
            if([self _saveItem:item])
                return [NSNumber numberWithInt:0];
		}
	}
	
	return [NSNumber numberWithInt:-1];	
}

- (NSString *)locationForItem:(NSString *)identifier
{
	EKCalendarItem *item = [sharedEventStore calendarItemWithIdentifier:identifier];
	
	if(!item){
		NSLog(@"'%@' is not a calendar item", identifier);
	}else{
		return item.location;
	}
	
	return @"";	
}

- (NSNumber *)setLocation:(NSString *)location forItem:(NSString *)identifier
{
	EKCalendarItem *item = [sharedEventStore calendarItemWithIdentifier:identifier];
	
	if(!item){
		NSLog(@"'%@' is not a calendar item", identifier);
	}else{
		item.location = location;
        
        if([self _saveItem:item])
            return [NSNumber numberWithInt:0];
	}
	
	return [NSNumber numberWithInt:-1];		
}

- (NSString *)urlForItem:(NSString *)identifier
{
	EKCalendarItem *item = [sharedEventStore calendarItemWithIdentifier:identifier];
	
	if(!item){
		NSLog(@"'%@' is not a calendar item", identifier);
	}else{
		return [item.URL absoluteString];
	}
	
	return @"";	
}

- (NSNumber *)setUrl:(NSString *)url forItem:(NSString *)identifier
{
	EKCalendarItem *item = [sharedEventStore calendarItemWithIdentifier:identifier];
	
	if(!item){
		NSLog(@"'%@' is not a calendar item", identifier);
	}else{
		NSURL *URL = [NSURL URLWithString:url];
		if(URL){
			item.URL = URL;	
            
            if([self _saveItem:item])
                return [NSNumber numberWithInt:0];	
		}
	}
	
	return [NSNumber numberWithInt:-1];	
}

- (NSString *)notesForItem:(NSString *)identifier
{
	EKCalendarItem *item = [sharedEventStore calendarItemWithIdentifier:identifier];
	
	if(!item){
		NSLog(@"'%@' is not a calendar item", identifier);
	}else{
		return item.notes;
	}
	
	return @"";	
}

- (NSNumber *)setNotes:(NSString *)notes forItem:(NSString *)identifier
{
	EKCalendarItem *item = [sharedEventStore calendarItemWithIdentifier:identifier];
	
	if(!item){
		NSLog(@"'%@' is not a calendar item", identifier);
	}else{
		item.notes = notes;
        
        if([self _saveItem:item])
            return [NSNumber numberWithInt:0];
	}
	
	return [NSNumber numberWithInt:-1];	
}

- (NSArray *)alarmsforItem:(NSString *)identifier
{
	[itemAlarms removeAllObjects];	
	[itemAlarms addObject:@""];
	
	EKCalendarItem *item = [sharedEventStore calendarItemWithIdentifier:identifier];
	
	if(!item){
		NSLog(@"'%@' is not a calendar item", identifier);
	}else{
		NSArray *alarms = item.attendees;
		for (EKAlarm *alarm in alarms){
			
			NSNumber *type = [NSNumber numberWithInt:alarm.type];
			
			id soundName;
			if(alarm.soundName){
				soundName = alarm.soundName;
			}else{
				soundName = [NSNull null];
			}
			
			id emailAddress;
			if(alarm.emailAddress){
				emailAddress = alarm.emailAddress;		
			}else{
				emailAddress = [NSNull null];
			}
			
			id url;
			if(alarm.url){
				url = [alarm.url absoluteString];		
			}else{
				url = [NSNull null];
			}
			
			id relativeOffset;
			if(alarm.relativeOffset){
				relativeOffset = [NSNumber numberWithInt:alarm.relativeOffset];
			}else{
				relativeOffset = [NSNull null];
			}
			
			id absoluteDate;
			if(alarm.absoluteDate){
				absoluteDate = [alarm.absoluteDate description];
			}else{
				absoluteDate = [NSNull null];
			}
			
			id proximity;
			if(alarm.proximity){
				proximity = [NSNumber numberWithInt:alarm.proximity];
			}else{
				proximity = [NSNull null];
			}			
			
			id structuredLocation;
			if(alarm.structuredLocation){
				structuredLocation = [NSDictionary dictionaryWithObjects:
									  
									  [NSArray arrayWithObjects:
									   alarm.structuredLocation.title, 
									   [NSNumber numberWithDouble:alarm.structuredLocation.radius], 
									   [NSNumber numberWithDouble:alarm.structuredLocation.geoLocation.coordinate.latitude], 
									   [NSNumber numberWithDouble:alarm.structuredLocation.geoLocation.coordinate.longitude],
									   [NSNumber numberWithDouble:alarm.structuredLocation.geoLocation.altitude],
									   nil]
																 forKeys:
									  
									  [NSArray arrayWithObjects:
									   @"title", 
									   @"radius", 
									   @"latitude", 
									   @"longitude", 
									   @"altitude", 
									   nil]];

			}else{
				structuredLocation = [NSNull null];
			}

			NSDictionary *alarmJson = [NSDictionary dictionaryWithObjects:
									   
																	[NSArray arrayWithObjects:
																	type, 
																	soundName, 
																	emailAddress, 
																	url, 
																	relativeOffset, 
																	absoluteDate,  
																	proximity,
																	structuredLocation,
																	nil]
									   
																  forKeys:
									   
																	[NSArray arrayWithObjects:
																	@"type", 
																	@"soundName", 
																	@"emailAddress", 
																	@"url", 
																	@"relativeOffset", 
																	@"absoluteDate", 
																	@"proximity",  
																	@"structuredLocation",
																	nil]];
			NSError *error;							  
			NSData *jsonData = [NSJSONSerialization dataWithJSONObject:alarmJson options:0 error:&error];
			
			if(jsonData){
				const char *bytes = [jsonData bytes];
				if(bytes){
					[itemAlarms addObject:[NSString stringWithUTF8String:bytes]];
				}
			}
		}
	}	
	
	return itemAlarms;	
}


- (NSNumber *)setAlarms:(NSArray *)alarms forItem:(NSString *)identifier
{
	return [NSNumber numberWithInt:-1];
}

- (NSArray *)rulesforItem:(NSString *)identifier
{
	[itemRules removeAllObjects];	
	[itemRules addObject:@""];
	
	EKCalendarItem *item = [sharedEventStore calendarItemWithIdentifier:identifier];
	
	if(!item){
		NSLog(@"'%@' is not a calendar item", identifier);
	}else{
		NSArray *rules = item.recurrenceRules;	
		for (EKRecurrenceRule *rule in rules){
		
			NSNumber *frequency = [NSNumber numberWithInt:rule.frequency];
			NSNumber *interval = [NSNumber numberWithInt:rule.interval];
			NSNumber *firstDayOfTheWeek = [NSNumber numberWithInt:rule.firstDayOfTheWeek];
			
			id recurrenceEnd;
			if(rule.recurrenceEnd){
				recurrenceEnd = [NSDictionary dictionaryWithObjects:
									  
									  [NSArray arrayWithObjects:
									   [rule.recurrenceEnd.endDate description], 
									   [NSNumber numberWithInt:rule.recurrenceEnd.occurrenceCount], 
									   nil]
															forKeys:
									  
									  [NSArray arrayWithObjects:
									   @"endDate", 
									   @"occurrenceCount", 
									   nil]];
				
			}else{
				recurrenceEnd = [NSNull null];
			}
			
			id daysOfTheWeek;
			if(rule.daysOfTheWeek){
				
				daysOfTheWeek = [NSMutableArray array];
				
				for (EKRecurrenceDayOfWeek *dow in rule.daysOfTheWeek){
					
					NSDictionary *recurrence = [NSDictionary dictionaryWithObjects:
												
												[NSArray arrayWithObjects:
												 [NSNumber numberWithInt:dow.dayOfTheWeek], 
												 [NSNumber numberWithInt:dow.weekNumber], 
												 nil]
																		   forKeys:
					
												[NSArray arrayWithObjects:
												 @"dayOfTheWeek", 
												 @"weekNumber", 
												 nil]];
					
					[daysOfTheWeek addObject:recurrence];
												
				}

			}else{
				daysOfTheWeek = [NSNull null];
			}
			
			id daysOfTheMonth;
			if(rule.daysOfTheMonth){
				daysOfTheMonth = rule.daysOfTheMonth;
			}else{
				daysOfTheMonth = [NSNull null];
			}			
			
			id daysOfTheYear;
			if(rule.daysOfTheYear){
				daysOfTheYear = rule.daysOfTheYear;
			}else{
				daysOfTheYear = [NSNull null];
			}			
			
			id weeksOfTheYear;
			if(rule.weeksOfTheYear){
				weeksOfTheYear = rule.weeksOfTheYear;
			}else{
				weeksOfTheYear = [NSNull null];
			}	
			
			id monthsOfTheYear;
			if(rule.monthsOfTheYear){
				monthsOfTheYear = rule.monthsOfTheYear;
			}else{
				monthsOfTheYear = [NSNull null];
			}				

			id setPositions;
			if(rule.setPositions){
				setPositions = rule.setPositions;
			}else{
				setPositions = [NSNull null];
			}	
			
			NSDictionary *alarmJson = [NSDictionary dictionaryWithObjects:
									   
									   [NSArray arrayWithObjects:
										frequency, 
										interval, 
										firstDayOfTheWeek, 
										daysOfTheWeek, 
										daysOfTheMonth, 
										daysOfTheYear,
										weeksOfTheYear,
										monthsOfTheYear,
										setPositions,
										nil]
									   
																  forKeys:
									   
									   [NSArray arrayWithObjects:
										@"frequency", 
										@"interval", 
										@"firstDayOfTheWeek", 
										@"daysOfTheWeek", 
										@"daysOfTheMonth", 
										@"daysOfTheYear",
										@"weeksOfTheYear",
										@"monthsOfTheYear",
										@"setPositions",
										nil]];
			NSError *error;							  
			NSData *jsonData = [NSJSONSerialization dataWithJSONObject:alarmJson options:0 error:&error];
			
			if(jsonData){
				const char *bytes = [jsonData bytes];
				if(bytes){
					[itemAlarms addObject:[NSString stringWithUTF8String:bytes]];
				}
			}			
		}
	}
	
	return itemRules;		
}

- (NSNumber *)setRules:(NSArray *)rules forItem:(NSString *)identifier
{
	return [NSNumber numberWithInt:-1];
}

- (NSString *)timezoneForItem:(NSString *)identifier
{
	EKCalendarItem *item = [sharedEventStore calendarItemWithIdentifier:identifier];
	
	if(!item){
		NSLog(@"'%@' is not a calendar item", identifier);
	}else{
		NSTimeZone *tz = item.timeZone;
		if(tz){
			return [tz abbreviation];
		}
	}
	
	return @"";	
}

- (NSNumber *)setTimezone:(NSString *)zone forItem:(NSString *)identifier
{
	EKCalendarItem *item = [sharedEventStore calendarItemWithIdentifier:identifier];
	
	if(!item){
		NSLog(@"'%@' is not a calendar item", identifier);
	}else{
		NSTimeZone *tz = [NSTimeZone timeZoneWithAbbreviation:zone];
		if(tz){
			item.timeZone = tz;
            
            if([self _saveItem:item])
                return [NSNumber numberWithInt:0];
		}		
	}
	
	return [NSNumber numberWithInt:-1];	
}

- (NSArray *)attendeeNamesforItem:(NSString *)identifier
{
	[attendeeNames removeAllObjects];	
	[attendeeNames addObject:@""];
	
	EKCalendarItem *item = [sharedEventStore calendarItemWithIdentifier:identifier];
	
	if(!item){
		NSLog(@"'%@' is not a calendar item", identifier);
	}else{
		NSArray *attendees = item.attendees;
		for (EKParticipant *attendee in attendees){
			[attendeeNames addObject:attendee.name];
		}
	}		
	
	return attendeeNames;
}

- (NSDate *)modificationDateforItem:(NSString *)identifier
{
	EKCalendarItem *item = [sharedEventStore calendarItemWithIdentifier:identifier];
	
	if(!item){
		NSLog(@"'%@' is not a calendar item", identifier);
	}else{
		return item.lastModifiedDate;
	}	

	return nil;
}

- (NSArray *)attendeesforItem:(NSString *)identifier
{
	[attendeeJsons removeAllObjects];	
	[attendeeJsons addObject:@""];
	
	EKCalendarItem *item = [sharedEventStore calendarItemWithIdentifier:identifier];
	
	if(!item){
		NSLog(@"'%@' is not a calendar item", identifier);
	}else{
		NSArray *attendees = item.attendees;
		for (EKParticipant *attendee in attendees){
			
			NSString *name = attendee.name;
			
			NSNumber *participantRole = [NSNumber numberWithInt:attendee.participantRole];
			
			NSNumber *participantStatus = [NSNumber numberWithInt:attendee.participantStatus];
			
			id url;
			if(attendee.URL){
				url = [attendee.URL absoluteString];
			}else{
				url = [NSNull null];
			}
			
			NSDictionary *attendeeJson = [NSDictionary dictionaryWithObjects:
										  
										  [NSArray arrayWithObjects:
										   name, 
										   participantRole, 
										   participantStatus, 
										   url, 
										   nil]
																	 forKeys:
										  
										  [NSArray arrayWithObjects:
										   @"name", 
										   @"participantRole", 
										   @"participantStatus", 
										   @"url", 
										   nil]];
			NSError *error;							  
			NSData *jsonData = [NSJSONSerialization dataWithJSONObject:attendeeJson options:0 error:&error];
			
			if(jsonData){
				const char *bytes = [jsonData bytes];
				if(bytes){
					[attendeeJsons addObject:[NSString stringWithUTF8String:bytes]];
				}
			}
		}
	}		
	
	return attendeeJsons;
}

#pragma mark -
#pragma mark OBJECT
#pragma mark -

-(oneway void)rollbackObject:(NSString *)identifier
{
	EKSource *source = [sharedEventStore sourceWithIdentifier:identifier];
	
	if(source){
		[source rollback];
		NSLog(@"rolled back source '%@'", identifier);
	}else{
		EKCalendar *calendar = [sharedEventStore calendarWithIdentifier:identifier];
		if(calendar){
			[calendar rollback];
			NSLog(@"rolled back calendar '%@'", identifier);
		}else{
			EKCalendarItem *item = [sharedEventStore calendarItemWithIdentifier:identifier];
			if(item){
				[item rollback];
				NSLog(@"rolled back item '%@'", identifier);
			}else{
				NSLog(@"'%@' is not a valid object to roll back", identifier);
			}			
		}			
	}
}
-(oneway void)resetObject:(NSString *)identifier
{
	EKSource *source = [sharedEventStore sourceWithIdentifier:identifier];
	
	if(source){
		[source reset];
		NSLog(@"resetted source '%@'", identifier);
	}else{
		EKCalendar *calendar = [sharedEventStore calendarWithIdentifier:identifier];
		if(calendar){
			[calendar reset];
			NSLog(@"resetted calendar '%@'", identifier);
		}else{
			EKCalendarItem *item = [sharedEventStore calendarItemWithIdentifier:identifier];
			if(item){
				[item reset];
				NSLog(@"resetted item '%@'", identifier);
			}else{
				[sharedEventStore reset];
				NSLog(@"resetted store");
			}	
		}		
	}
}
-(oneway void)refreshObject:(NSString *)identifier
{
	EKSource *source = [sharedEventStore sourceWithIdentifier:identifier];
	
	if(source){
		[source refresh];
		NSLog(@"refreshed source '%@'", identifier);
	}else{
		EKCalendar *calendar = [sharedEventStore calendarWithIdentifier:identifier];
		if(calendar){
			[calendar refresh];
			NSLog(@"refreshed calendar '%@'", identifier);
		}else{
			EKCalendarItem *item = [sharedEventStore calendarItemWithIdentifier:identifier];
			if(item){
				[item refresh];
				NSLog(@"refreshed item '%@'", identifier);
			}else{
				[sharedEventStore refreshSourcesIfNecessary];
				NSLog(@"refreshed store");
			}
		}
	}
}
-(NSNumber *)objectHasChanges:(NSString *)identifier
{
	EKSource *source = [sharedEventStore sourceWithIdentifier:identifier];
	
	if(source){
		return [NSNumber numberWithInt:[source hasChanges]];
	}else{
		EKCalendar *calendar = [sharedEventStore calendarWithIdentifier:identifier];
		if(calendar){
			return [NSNumber numberWithInt:[calendar hasChanges]];
		}else{
			EKCalendarItem *item = [sharedEventStore calendarItemWithIdentifier:identifier];
			if(item){
				return [NSNumber numberWithInt:[item hasChanges]];
			}else{
				NSLog(@"'%@' is not a valid object to report changes", identifier);
			}			
		}			
	}
	
	return [NSNumber numberWithInt:-1];		
}

-(NSNumber *)objectIsNew:(NSString *)identifier
{
	EKSource *source = [sharedEventStore sourceWithIdentifier:identifier];
	
	if(source){
		return [NSNumber numberWithInt:[source isNew]];
	}else{
		EKCalendar *calendar = [sharedEventStore calendarWithIdentifier:identifier];
		if(calendar){
			return [NSNumber numberWithInt:[calendar isNew]];
		}else{
			EKCalendarItem *item = [sharedEventStore calendarItemWithIdentifier:identifier];
			if(item){
				return [NSNumber numberWithInt:[item isNew]];
			}else{
				NSLog(@"'%@' is not a valid object to report if new", identifier);
			}			
		}			
	}
	
	return [NSNumber numberWithInt:-1];		
}

#pragma mark -
#pragma mark QUERY
#pragma mark -

- (NSArray *)queryEventsForStartDate:(NSDate *)startDate endDate:(NSDate *)endDate calendars:(NSArray *)identifiers
{
	[eventIdsForQuery removeAllObjects];	
	[eventIdsForQuery addObject:@""];
	
	NSArray *calendars = [self _createCalendarFromIdentifiers:identifiers];
	NSPredicate *predicate = [self _eventPredicateForCalendars:calendars startDate:startDate endDate:endDate];
	NSArray *events = [sharedEventStore eventsMatchingPredicate:predicate];
	
	for(unsigned int i = 0; i < [events count]; ++i){
		
		EKEvent *event = [events objectAtIndex:i];
		[eventIdsForQuery addObject:[event eventIdentifier]];
		
	}

	[calendars release];
	
	return eventIdsForQuery;
}

- (NSArray *)queryCompleteRemindersForStartDate:(NSDate *)startDate endDate:(NSDate *)endDate calendars:(NSArray *)identifiers
{
	dispatch_semaphore_t sema = dispatch_semaphore_create(0);
	
	[reminderIdsForQuery removeAllObjects];	
	[reminderIdsForQuery addObject:@""];	
	
	NSArray *calendars = [self _createCalendarFromIdentifiers:identifiers];
	NSPredicate *predicate = [self _completeReminderPredicateForCalendars:calendars startDate:startDate endDate:endDate];
	
	[sharedEventStore fetchRemindersMatchingPredicate:predicate completion:^(NSArray *reminders){
		
		for (EKReminder *reminder in reminders){
			[reminderIdsForQuery addObject:reminder.calendarItemIdentifier];
		}
		
		dispatch_semaphore_signal(sema);
		
	}];
	
	dispatch_semaphore_wait(sema, DISPATCH_TIME_FOREVER);
	
	[calendars release];
	
	return reminderIdsForQuery;	
}

- (NSArray *)queryIncompleteRemindersForStartDate:(NSDate *)startDate endDate:(NSDate *)endDate calendars:(NSArray *)identifiers
{
	dispatch_semaphore_t sema = dispatch_semaphore_create(0);
	
	[reminderIdsForQuery removeAllObjects];	
	[reminderIdsForQuery addObject:@""];	
	
	NSArray *calendars = [self _createCalendarFromIdentifiers:identifiers];
	NSPredicate *predicate = [self _incompleteReminderPredicateForCalendars:calendars startDate:startDate endDate:endDate];
		
	[sharedEventStore fetchRemindersMatchingPredicate:predicate completion:^(NSArray *reminders){
		
		for (EKReminder *reminder in reminders){
			[reminderIdsForQuery addObject:reminder.calendarItemIdentifier];
		}
		
		dispatch_semaphore_signal(sema);
		
	}];
	
	dispatch_semaphore_wait(sema, DISPATCH_TIME_FOREVER);
	
	[calendars release];
	
	return reminderIdsForQuery;
}

@end
