#include "functions_ekit.h"

EventKitHelper *sharedEventKitHelper = nil;
NSConnection *sharedEventKitHelperConnection = nil;

BOOL ConnectionToHelper()
{
	if(sharedEventKitHelper)
		return TRUE;
	
	sharedEventKitHelperConnection = [NSConnection connectionWithRegisteredName:HELPER_REGISTERED_NAME host:nil];
	
	if(sharedEventKitHelperConnection){
		NSLog(@"connected to %@", HELPER_REGISTERED_NAME);
		sharedEventKitHelper = [[sharedEventKitHelperConnection rootProxy]retain];
		if(sharedEventKitHelper){
			NSLog(@"proxied %@", HELPER_REGISTERED_NAME);
			[sharedEventKitHelper setProtocolForProxy:@protocol(EventKitHelperInterface)];	
			return TRUE;
		}
	}
	
	return FALSE;
}

BOOL TerminateHelper()
{
	if(ConnectionToHelper()){
		
		NSNumber *processIdentifier = [sharedEventKitHelper processIdentifier];
		
		NSRunningApplication *runningApplication = [NSRunningApplication runningApplicationWithProcessIdentifier:[processIdentifier intValue]];
		
		if(runningApplication){
			[runningApplication forceTerminate];
			NSLog(@"terminated %@", HELPER_REGISTERED_NAME);
			return TRUE;
		}
	}	
	
	return FALSE;
}

BOOL LaunchHelper()
{
	//need this (probably) for carbon/cocoa bridge
	NSApplicationLoad();
	
	NSBundle *mainBundle = [NSBundle bundleWithIdentifier:THIS_BUNDLE_ID];
	
	if(mainBundle){
		
		NSString *executablePath = [mainBundle executablePath];
		NSLog(@"executablePath is %@", executablePath);
		
		NSString *executableFolderPath = [executablePath stringByDeletingLastPathComponent];
		NSLog(@"executableFolderPath is %@", executableFolderPath);
		
		//need the .app extension in our case, probably because of non-standard location
		NSString *helperPath = [executableFolderPath stringByAppendingPathComponent:@"EventKitHelper.app"];
		NSLog(@"helperPath is %@", helperPath);
		
		NSWorkspace *sharedWorkspace = [NSWorkspace sharedWorkspace];
		
		if([sharedWorkspace launchApplication:helperPath]){
			NSLog(@"launched %@", HELPER_REGISTERED_NAME);
			return TRUE;
		}
	}
	
	return FALSE;
}

#pragma mark -

BOOL _setDate(NSDate *date, C_DATE &ParamDate, C_TIME &ParamTime)
{
	if(date){
		
		NSString *description = [date description];
		
		if([description length] == 25)
		{
			uint16_t year = [[description substringWithRange:NSMakeRange(0,4)]integerValue];
			uint16_t month = [[description substringWithRange:NSMakeRange(5,2)]integerValue];
			uint16_t day = [[description substringWithRange:NSMakeRange(8,2)]integerValue];
			
			unsigned char hour = [[description substringWithRange:NSMakeRange(11,2)]integerValue];
			unsigned char minute = [[description substringWithRange:NSMakeRange(14,2)]integerValue];
			unsigned char second = [[description substringWithRange:NSMakeRange(17,2)]integerValue];
			
			ParamDate.setYearMonthDay(year, month, day);
			ParamTime.setHourMinuteSecond(hour, minute, second);
			
			return TRUE;
		}
	}
	return FALSE;
}

NSDate *_copyDate(C_DATE &ParamDate, C_TIME &ParamTime)
{
	uint16_t year;
	uint16_t month;
	uint16_t day;
	
	unsigned char hour;
	unsigned char minute;
	unsigned char second;
	
	ParamDate.getYearMonthDay(&year, &month, &day);
	ParamTime.getHourMinuteSecond(&hour, &minute, &second);
	
	CFGregorianDate gregDate;
	gregDate.year = year;
	gregDate.month = month;
	gregDate.day = day;
	gregDate.hour = hour;
	gregDate.minute = minute;
	gregDate.second = second;
	
	return (NSDate *)CFDateCreate(kCFAllocatorDefault, CFGregorianDateGetAbsoluteTime(gregDate, (CFTimeZoneRef)[NSTimeZone localTimeZone]));
}

#pragma mark -
#pragma mark STORE
#pragma mark -

BOOL _STORE_Commit()
{
	if(ConnectionToHelper()){
		NSNumber *code = [sharedEventKitHelper commit];
		
		if([code intValue] == 0)
			return TRUE;
	}	
	
	return FALSE;	
}

void _setArray(NSArray *array, ARRAY_TEXT &ParamArray)
{	
	ParamArray.setSize(0);
	
	if(array){
		for(unsigned int i = 0; i < [array count]; ++i){
			
			ParamArray.appendUTF16String([array objectAtIndex:i]);
			
		}
	}		
}

NSArray * _copyArray(ARRAY_TEXT &ParamArray)
{	
	NSUInteger capacity = ParamArray.getSize();
	NSMutableArray *array = [[NSMutableArray alloc]initWithCapacity:capacity];
	
	if(array){
		for(unsigned int i = 0; i < ParamArray.getSize(); ++i){
			
			NSString *item = ParamArray.copyUTF16StringAtIndex(i);
			[array addObject:item];
			[item release];
			
		}
	}	
	return array;
}

#pragma mark -
#pragma mark SOURCE
#pragma mark -

void _SOURCE_LIST(ARRAY_TEXT &Param1)
{
	if(ConnectionToHelper()){
		
		NSArray *sources = [sharedEventKitHelper sources];
		
		if(sources){
			for(unsigned int i = 0; i < [sources count]; ++i){
				
				Param1.appendUTF16String([sources objectAtIndex:i]);
				
			}
		}
	}	
}

BOOL _SOURCE_Get_title(C_TEXT &Param1, C_TEXT &Param2)
{
	if(ConnectionToHelper()){
		NSString *identifier = Param1.copyUTF16String();
		Param2.setUTF16String([sharedEventKitHelper titleForSource:identifier]);
		[identifier release];
		return TRUE;
	}
	
	return FALSE;	
}

BOOL _SOURCE_Get_type(C_TEXT &Param1, C_LONGINT &Param2)
{
	if(ConnectionToHelper()){
		NSString *identifier = Param1.copyUTF16String();
		NSNumber *type = [sharedEventKitHelper typeForSource:identifier];
		[identifier release];
		
		if([type intValue] != -1){
			Param2.setIntValue([type intValue]);
			return TRUE;
		}
	}
	
	return FALSE;	
}

BOOL _SOURCE_Calendar_list(C_TEXT &Param1, ARRAY_TEXT &Param2, C_LONGINT &Param3)
{
	if(ConnectionToHelper()){
		
		NSString *identifier = Param1.copyUTF16String();
		NSArray *calendars = nil; 
		
		switch (Param3.getIntValue()){
			case 0://events
				calendars = [sharedEventKitHelper calendarsForEventsForSource:identifier];
				break;				
			case 1://reminders
				calendars = [sharedEventKitHelper calendarsForRemindersForSource:identifier];
				break;
			default:	
				break;
		}
		
		if (calendars){
			
			for(unsigned int i = 0; i < [calendars count]; ++i){
				
				Param2.appendUTF16String([calendars objectAtIndex:i]);
				
			}
			
			return TRUE;
		}

	}
	
	return FALSE;
}

#pragma mark -
#pragma mark CALENDAR
#pragma mark -

void _CALENDAR_Create(C_TEXT &Param1, C_LONGINT &Param2, C_TEXT &returnValue)
{
	if(ConnectionToHelper()){
		NSString *identifier = Param1.copyUTF16String();
		NSNumber *type = [NSNumber numberWithInt:Param2.getIntValue()];
		returnValue.setUTF16String([sharedEventKitHelper createCalendarForSource:identifier type:type]);
		[identifier release];
	}
}

BOOL _CALENDAR_Save(C_TEXT &Param1)
{
	if(ConnectionToHelper()){
		NSString *identifier = Param1.copyUTF16String();
		NSNumber *code = [sharedEventKitHelper saveCalendar:identifier];
		[identifier release];
		
		if([code intValue] == 0)
			return TRUE;
	}
	
	return FALSE;
}

BOOL _CALENDAR_Remove(C_TEXT &Param1)
{
	if(ConnectionToHelper()){
		NSString *identifier = Param1.copyUTF16String();
		NSNumber *code = [sharedEventKitHelper removeCalendar:identifier];
		[identifier release];
		
		if([code intValue] == 0)
			return TRUE;
	}
	
	return FALSE;
}

void _CALENDAR_LIST(ARRAY_TEXT &Param1, C_LONGINT &Param2)
{
	if(ConnectionToHelper()){
		
		NSArray *calendars = nil; 
		
		switch (Param2.getIntValue()){
			case 0://events
				calendars = [sharedEventKitHelper calendarsForEvents];
				break;				
			case 1://reminders
				calendars = [sharedEventKitHelper calendarsForReminders];
				break;
			default:	
				break;
		}
		
		if (calendars){
			
			for(unsigned int i = 0; i < [calendars count]; ++i){
				
				Param1.appendUTF16String([calendars objectAtIndex:i]);
				
			}
		}
	}
}

BOOL _CALENDAR_Get_default(C_LONGINT &Param1, C_TEXT &returnValue)
{
	if(ConnectionToHelper()){
		
		NSString *defaultCalendar; 
		
		switch (Param1.getIntValue()){
			case 0://events
				defaultCalendar = [sharedEventKitHelper defaultCalendarForNewEvents];
				returnValue.setUTF16String(defaultCalendar);
				return TRUE;
				break;				
			case 1://reminders
				defaultCalendar = [sharedEventKitHelper defaultCalendarForNewReminders];
				returnValue.setUTF16String(defaultCalendar);
				return TRUE;
				break;
				
			default:
				break;
		}
	}
	
	return FALSE;
}

BOOL _CALENDAR_Get_title(C_TEXT &Param1, C_TEXT &Param2)
{
	if(ConnectionToHelper()){
		NSString *identifier = Param1.copyUTF16String();
		Param2.setUTF16String([sharedEventKitHelper titleForCalendar:identifier]);
		[identifier release];
		return (BOOL)Param2.getUTF16Length();
	}
	
	return FALSE;	
}

BOOL _CALENDAR_Set_title(C_TEXT &Param1, C_TEXT &Param2)
{
	if(ConnectionToHelper()){
		NSString *identifier = Param1.copyUTF16String();
		NSString *title = Param2.copyUTF16String();		
		NSNumber *type = [sharedEventKitHelper setTitle:title forCalendar:identifier];
		[title release];		
		[identifier release];
		
		if([type intValue] == 0)
			return TRUE;
	}
	
	return FALSE;	
}

BOOL _CALENDAR_Get_type(C_TEXT &Param1, C_LONGINT &Param2)
{
	if(ConnectionToHelper()){
		NSString *identifier = Param1.copyUTF16String();
		NSNumber *type = [sharedEventKitHelper typeForCalendar:identifier];
		[identifier release];
		
		if([type intValue] != -1){
			Param2.setIntValue([type intValue]);
			return TRUE;
		}
	}
	
	return FALSE;	
}

BOOL _CALENDAR_Get_source(C_TEXT &Param1, C_TEXT &Param2)
{
	if(ConnectionToHelper()){
		NSString *identifier = Param1.copyUTF16String();
		Param2.setUTF16String([sharedEventKitHelper sourceForCalendar:identifier]);
		[identifier release];
		return (BOOL)Param2.getUTF16Length();
	}
	
	return FALSE;	
}

BOOL _CALENDAR_Get_rgb_color(C_TEXT &Param1, C_REAL &Param2, C_REAL &Param3, C_REAL &Param4)
{
	if(ConnectionToHelper()){
		NSString *identifier = Param1.copyUTF16String();
		NSColor *color = [sharedEventKitHelper rgbColorForCalendar:identifier];
		[identifier release];
		
		if(color)
		{
			CGFloat red, green, blue, alpha;
			[color getRed:&red green:&green blue:&blue alpha:&alpha];
			Param2.setDoubleValue(red);
			Param3.setDoubleValue(green);
			Param4.setDoubleValue(blue);
			return TRUE;
		}
		
	}
	
	return FALSE;		
}

BOOL _CALENDAR_Set_rgb_color(C_TEXT &Param1, C_REAL &Param2, C_REAL &Param3, C_REAL &Param4)
{
	if(ConnectionToHelper()){
		NSString *identifier = Param1.copyUTF16String();
		NSColor *color = [NSColor colorWithDeviceRed:Param2.getDoubleValue() green:Param3.getDoubleValue() blue:Param4.getDoubleValue() alpha:1];
		NSNumber *code = [sharedEventKitHelper setRgbColor:color forCalendar:identifier];
		[identifier release];
		
		if([code intValue] == 0)
			return TRUE;		
	}
	
	return FALSE;		
}

#pragma mark -
#pragma mark REMINDER
#pragma mark -

void _REMINDER_Create(C_TEXT &Param1, C_TEXT &returnValue)
{
	if(ConnectionToHelper()){
		NSString *identifier = Param1.copyUTF16String();
		returnValue.setUTF16String([sharedEventKitHelper newReminderForCalendar:identifier]);
		[identifier release];
	}
}


BOOL _REMINDER_Save(C_TEXT &Param1)
{
	if(ConnectionToHelper()){
		NSString *identifier = Param1.copyUTF16String();
		NSNumber *code = [sharedEventKitHelper saveReminder:identifier];
		[identifier release];
		
		if([code intValue] == 0)
			return TRUE;
	}
	
	return FALSE;
}

BOOL _REMINDER_Remove(C_TEXT &Param1)
{
	if(ConnectionToHelper()){
		NSString *identifier = Param1.copyUTF16String();
		NSNumber *code = [sharedEventKitHelper removeReminder:identifier];
		[identifier release];
		
		if([code intValue] == 0)
			return TRUE;
	}
	
	return FALSE;	
}

BOOL _REMINDER_Get_start_date(C_TEXT &Param1, C_DATE &Param2, C_TIME &Param3)
{
	if(ConnectionToHelper()){
		NSString *identifier = Param1.copyUTF16String();
		NSDate *date = [sharedEventKitHelper startDateForReminder:identifier];
		[identifier release];
		return _setDate(date, Param2, Param3);
	}	
	
	return FALSE;	
}

BOOL _REMINDER_Set_start_date(C_TEXT &Param1, C_DATE &Param2, C_TIME &Param3)
{
	if(ConnectionToHelper()){
		NSString *identifier = Param1.copyUTF16String();
		NSDate *date = _copyDate(Param2, Param3);
		NSNumber *code = [sharedEventKitHelper setStartDate:date forReminder:identifier];
		[date release];
		[identifier release];
		
		if([code intValue] == 0)
			return TRUE;
	}		
	
	return FALSE;	
}

BOOL _REMINDER_Get_due_date(C_TEXT &Param1, C_DATE &Param2, C_TIME &Param3)
{
	if(ConnectionToHelper()){
		NSString *identifier = Param1.copyUTF16String();
		NSDate *date = [sharedEventKitHelper dueDateForReminder:identifier];
		[identifier release];
		return _setDate(date, Param2, Param3);
	}	
	
	return FALSE;	
}

BOOL _REMINDER_Set_due_date(C_TEXT &Param1, C_DATE &Param2, C_TIME &Param3)
{
	if(ConnectionToHelper()){
		NSString *identifier = Param1.copyUTF16String();
		NSDate *date = _copyDate(Param2, Param3);
		NSNumber *code = [sharedEventKitHelper setDueDate:date forReminder:identifier];
		[date release];
		[identifier release];
		
		if([code intValue] == 0)
			return TRUE;
	}		
	
	return FALSE;	
}

BOOL _REMINDER_Get_completed_date(C_TEXT &Param1, C_DATE &Param2, C_TIME &Param3)
{
	if(ConnectionToHelper()){
		NSString *identifier = Param1.copyUTF16String();
		NSDate *date = [sharedEventKitHelper completedDateForReminder:identifier];
		[identifier release];
		return _setDate(date, Param2, Param3);
	}	
	
	return FALSE;	
}

BOOL _REMINDER_Set_completed_date(C_TEXT &Param1, C_DATE &Param2, C_TIME &Param3)
{
	if(ConnectionToHelper()){
		NSString *identifier = Param1.copyUTF16String();
		NSDate *date = _copyDate(Param2, Param3);
		NSNumber *code = [sharedEventKitHelper setCompletedDate:date forReminder:identifier];
		[date release];
		[identifier release];
		
		if([code intValue] == 0)
			return TRUE;
	}		
	
	return FALSE;	
}

#pragma mark -
#pragma mark EVENT
#pragma mark -

void _EVENT_Create(C_TEXT &Param1, C_TEXT &returnValue)
{
	if(ConnectionToHelper()){
		NSString *identifier = Param1.copyUTF16String();
		returnValue.setUTF16String([sharedEventKitHelper newEventForCalendar:identifier]);
		[identifier release];
	}
}

BOOL _EVENT_Save(C_TEXT &Param1)
{
	if(ConnectionToHelper()){
		NSString *identifier = Param1.copyUTF16String();
		NSNumber *code = [sharedEventKitHelper saveEvent:identifier];
		[identifier release];
		
		if([code intValue] == 0)
			return TRUE;
	}
	
	return FALSE;
}

BOOL _EVENT_Remove(C_TEXT &Param1)
{
	if(ConnectionToHelper()){
		NSString *identifier = Param1.copyUTF16String();
		NSNumber *code = [sharedEventKitHelper removeEvent:identifier];
		[identifier release];
		
		if([code intValue] == 0)
			return TRUE;
	}
	
	return FALSE;	
}

BOOL _EVENT_Get_start_date(C_TEXT &Param1, C_DATE &Param2, C_TIME &Param3)
{
	if(ConnectionToHelper()){
		NSString *identifier = Param1.copyUTF16String();
		NSDate *date = [sharedEventKitHelper startDateForEvent:identifier];
		[identifier release];
		return _setDate(date, Param2, Param3);
	}	
	
	return FALSE;	
}

BOOL _EVENT_Set_start_date(C_TEXT &Param1, C_DATE &Param2, C_TIME &Param3)
{
	if(ConnectionToHelper()){
		NSString *identifier = Param1.copyUTF16String();
		NSDate *date = _copyDate(Param2, Param3);
		NSNumber *code = [sharedEventKitHelper setStartDate:date forEvent:identifier];
		[date release];
		[identifier release];
		
		if([code intValue] == 0)
			return TRUE;
	}		
	
	return FALSE;	
}

BOOL _EVENT_Get_end_date(C_TEXT &Param1, C_DATE &Param2, C_TIME &Param3)
{
	if(ConnectionToHelper()){
		NSString *identifier = Param1.copyUTF16String();
		NSDate *date = [sharedEventKitHelper endDateForEvent:identifier];
		[identifier release];
		return _setDate(date, Param2, Param3);
	}	
	
	return FALSE;	
}

BOOL _EVENT_Set_end_date(C_TEXT &Param1, C_DATE &Param2, C_TIME &Param3)
{
	if(ConnectionToHelper()){
		NSString *identifier = Param1.copyUTF16String();
		NSDate *date = _copyDate(Param2, Param3);
		NSNumber *code = [sharedEventKitHelper setEndDate:date forEvent:identifier];
		[date release];
		[identifier release];
		
		if([code intValue] == 0)
			return TRUE;
	}		
	
	return FALSE;	
}

BOOL _EVENT_Get_occurrence_date(C_TEXT &Param1, C_DATE &Param2, C_TIME &Param3)
{
	if(ConnectionToHelper()){
		NSString *identifier = Param1.copyUTF16String();
		NSDate *date = [sharedEventKitHelper occurrenceDateForEvent:identifier];
		[identifier release];
		return _setDate(date, Param2, Param3);
	}	
	
	return FALSE;	
}

BOOL _EVENT_Get_status(C_TEXT &Param1, C_LONGINT &Param2)
{
	if(ConnectionToHelper()){
		NSString *identifier = Param1.copyUTF16String();
		NSNumber *status = [sharedEventKitHelper statusForEvent:identifier];
		[identifier release];
		
		if([status intValue] != -1){
			Param2.setIntValue([status intValue]);
			return TRUE;
		}
	}
	
	return FALSE;	
}

BOOL _EVENT_Get_all_day(C_TEXT &Param1, C_LONGINT &Param2)
{
	if(ConnectionToHelper()){
		NSString *identifier = Param1.copyUTF16String();
		NSNumber *allDay = [sharedEventKitHelper allDayForEvent:identifier];
		[identifier release];
		
		if([allDay intValue] != -1){
			Param2.setIntValue([allDay intValue]);
			return TRUE;
		}
	}
	
	return FALSE;	
}

BOOL _EVENT_Set_all_day(C_TEXT &Param1, C_LONGINT &Param2)
{
	if(ConnectionToHelper()){
		NSString *identifier = Param1.copyUTF16String();	
		NSNumber *code = [sharedEventKitHelper setAllDay:[NSNumber numberWithInt:Param2.getIntValue()] forEvent:identifier];		
		[identifier release];
		
		if([code intValue] == 0)
			return TRUE;
	}
	
	return FALSE;	
}

BOOL _EVENT_Get_organizer_name(C_TEXT &Param1, C_TEXT &Param2)
{
	if(ConnectionToHelper()){
		NSString *identifier = Param1.copyUTF16String();
		Param2.setUTF16String([sharedEventKitHelper organizerNameForEvent:identifier]);
		[identifier release];
		return (BOOL)Param2.getUTF16Length();
	}
	
	return FALSE;	
}

#pragma mark -
#pragma mark ITEM
#pragma mark -

BOOL _ITEM_Get_title(C_TEXT &Param1, C_TEXT &Param2)
{
	if(ConnectionToHelper()){
		NSString *identifier = Param1.copyUTF16String();
		Param2.setUTF16String([sharedEventKitHelper titleForItem:identifier]);
		[identifier release];
		return (BOOL)Param2.getUTF16Length();
	}
	
	return FALSE;	
}

BOOL _ITEM_Set_title(C_TEXT &Param1, C_TEXT &Param2)
{
	if(ConnectionToHelper()){
		NSString *identifier = Param1.copyUTF16String();
		NSString *title = Param2.copyUTF16String();		
		NSNumber *code = [sharedEventKitHelper setTitle:title forItem:identifier];
		[title release];		
		[identifier release];
		
		if([code intValue] == 0)
			return TRUE;
	}
	
	return FALSE;	
}

BOOL _ITEM_Get_calendar(C_TEXT &Param1, C_TEXT &Param2)
{
	if(ConnectionToHelper()){
		NSString *identifier = Param1.copyUTF16String();
		Param2.setUTF16String([sharedEventKitHelper calendarForItem:identifier]);
		[identifier release];
		return (BOOL)Param2.getUTF16Length();
	}
	
	return FALSE;	
}

BOOL _ITEM_Set_calendar(C_TEXT &Param1, C_TEXT &Param2)
{
	if(ConnectionToHelper()){
		NSString *identifier = Param1.copyUTF16String();
		NSString *calendar = Param2.copyUTF16String();		
		NSNumber *type = [sharedEventKitHelper setCalendar:calendar forItem:identifier];
		[calendar release];		
		[identifier release];
		
		if([type intValue] == 0)
			return TRUE;
	}
	
	return FALSE;		
}

BOOL _ITEM_Get_location(C_TEXT &Param1, C_TEXT &Param2)
{
	if(ConnectionToHelper()){
		NSString *identifier = Param1.copyUTF16String();
		Param2.setUTF16String([sharedEventKitHelper locationForItem:identifier]);
		[identifier release];
		return (BOOL)Param2.getUTF16Length();
	}
	
	return FALSE;	
}

BOOL _ITEM_Set_location(C_TEXT &Param1, C_TEXT &Param2)
{
	if(ConnectionToHelper()){
		NSString *identifier = Param1.copyUTF16String();
		NSString *location = Param2.copyUTF16String();		
		NSNumber *type = [sharedEventKitHelper setLocation:location forItem:identifier];
		[location release];		
		[identifier release];
		
		if([type intValue] == 0)
			return TRUE;
	}
	
	return FALSE;	
}

BOOL _ITEM_Get_url(C_TEXT &Param1, C_TEXT &Param2)
{
	if(ConnectionToHelper()){
		NSString *identifier = Param1.copyUTF16String();
		Param2.setUTF16String([sharedEventKitHelper urlForItem:identifier]);
		[identifier release];
		return (BOOL)Param2.getUTF16Length();
	}
	
	return FALSE;	
}

BOOL _ITEM_Set_url(C_TEXT &Param1, C_TEXT &Param2)
{
	if(ConnectionToHelper()){
		NSString *identifier = Param1.copyUTF16String();
		NSString *url = Param2.copyUTF16String();		
		NSNumber *type = [sharedEventKitHelper setUrl:url forItem:identifier];
		[url release];		
		[identifier release];
		
		if([type intValue] == 0)
			return TRUE;
	}
	
	return FALSE;		
}

BOOL _ITEM_Get_notes(C_TEXT &Param1, C_TEXT &Param2)
{
	if(ConnectionToHelper()){
		NSString *identifier = Param1.copyUTF16String();
		Param2.setUTF16String([sharedEventKitHelper notesForItem:identifier]);
		[identifier release];
		return (BOOL)Param2.getUTF16Length();
	}
	
	return FALSE;		
}

BOOL _ITEM_Set_notes(C_TEXT &Param1, C_TEXT &Param2)
{
	if(ConnectionToHelper()){
		NSString *identifier = Param1.copyUTF16String();
		NSString *notes = Param2.copyUTF16String();		
		NSNumber *type = [sharedEventKitHelper setNotes:notes forItem:identifier];
		[notes release];		
		[identifier release];
		
		if([type intValue] == 0)
			return TRUE;
	}
	
	return FALSE;	
}



BOOL _ITEM_Get_alarms(C_TEXT &Param1, ARRAY_TEXT &Param2)
{
	if(ConnectionToHelper()){
		NSString *identifier = Param1.copyUTF16String();	
		NSArray *alarms = [sharedEventKitHelper alarmsforItem:identifier];
		_setArray(alarms, Param2);	
		[identifier release];
		
		if(alarms)
			return TRUE;
	}
	
	return FALSE;		
}

BOOL _ITEM_Set_alarms(C_TEXT &Param1, ARRAY_TEXT &Param2)
{
	if(ConnectionToHelper()){
		NSString *identifier = Param1.copyUTF16String();
		NSArray *alarms = _copyArray(Param2);		
		NSNumber *type = [sharedEventKitHelper setAlarms:alarms forItem:identifier];
		[alarms release];		
		[identifier release];
		
		if([type intValue] == 0)
			return TRUE;
	}
	
	return FALSE;		
}

BOOL _ITEM_Get_rules(C_TEXT &Param1, ARRAY_TEXT &Param2)
{
	if(ConnectionToHelper()){
		NSString *identifier = Param1.copyUTF16String();	
		NSArray *rules = [sharedEventKitHelper rulesforItem:identifier];
		_setArray(rules, Param2);	
		[identifier release];
		
		if(rules)
			return TRUE;
	}
	
	return FALSE;	
}

BOOL _ITEM_Set_rules(C_TEXT &Param1, ARRAY_TEXT &Param2)
{
	if(ConnectionToHelper()){
		NSString *identifier = Param1.copyUTF16String();
		NSArray *rules = _copyArray(Param2);		
		NSNumber *type = [sharedEventKitHelper setRules:rules forItem:identifier];
		[rules release];		
		[identifier release];
		
		if([type intValue] == 0)
			return TRUE;
	}
	
	return FALSE;		
}

BOOL _ITEM_Get_timezone(C_TEXT &Param1, C_TEXT &Param2)
{
	if(ConnectionToHelper()){
		NSString *identifier = Param1.copyUTF16String();
		Param2.setUTF16String([sharedEventKitHelper timezoneForItem:identifier]);
		[identifier release];
		return (BOOL)Param2.getUTF16Length();
	}
	
	return FALSE;	
}

BOOL _ITEM_Set_timezone(C_TEXT &Param1, C_TEXT &Param2)
{
	if(ConnectionToHelper()){
		NSString *identifier = Param1.copyUTF16String();
		NSString *zone = Param2.copyUTF16String();		
		NSNumber *type = [sharedEventKitHelper setTimezone:zone forItem:identifier];
		[zone release];		
		[identifier release];
		
		if([type intValue] == 0)
			return TRUE;
	}
	
	return FALSE;	
}

BOOL _ITEM_Get_attendee_names(C_TEXT &Param1, ARRAY_TEXT &Param2)
{
	if(ConnectionToHelper()){
		NSString *identifier = Param1.copyUTF16String();	
		NSArray *names = [sharedEventKitHelper attendeeNamesforItem:identifier];
		_setArray(names, Param2);	
		[identifier release];
		
		if(names)
			return TRUE;
	}
	
	return FALSE;	
}

BOOL _ITEM_Get_modification_date(C_TEXT &Param1, C_DATE &Param2, C_TIME &Param3)
{
	if(ConnectionToHelper()){
		NSString *identifier = Param1.copyUTF16String();	
		NSDate *date = [sharedEventKitHelper modificationDateforItem:identifier];
		[identifier release];
		return _setDate(date, Param2, Param3);
	}
	
	return FALSE;	
}

BOOL _ITEM_Get_attendees(C_TEXT &Param1, ARRAY_TEXT &Param2)
{
	if(ConnectionToHelper()){
		NSString *identifier = Param1.copyUTF16String();	
		NSArray *attendees = [sharedEventKitHelper attendeesforItem:identifier];
		_setArray(attendees, Param2);	
		[identifier release];
		
		if(attendees)
			return TRUE;
	}
	
	return FALSE;	
}

#pragma mark -
#pragma mark OBJECT
#pragma mark -

void _OBJECT_ROLLBACK(C_TEXT &Param1)
{
	if(ConnectionToHelper()){
		NSString *identifier = Param1.copyUTF16String();
		[sharedEventKitHelper rollbackObject:identifier];
		[identifier release];
	}
}

void _OBJECT_RESET(C_TEXT &Param1)
{
	if(ConnectionToHelper()){
		NSString *identifier = Param1.copyUTF16String();
		[sharedEventKitHelper resetObject:identifier];
		[identifier release];
	}
}

void _OBJECT_REFRESH(C_TEXT &Param1)
{
	if(ConnectionToHelper()){
		NSString *identifier = Param1.copyUTF16String();
		[sharedEventKitHelper refreshObject:identifier];
		[identifier release];
	}
}

BOOL _OBJECT_Has_changes(C_TEXT &Param1, C_LONGINT &Param2)
{
	if(ConnectionToHelper()){
		NSString *identifier = Param1.copyUTF16String();
		NSNumber *code = [sharedEventKitHelper objectHasChanges:identifier];
		[identifier release];
		
		if([code intValue] == 0)
			return TRUE;
	}
	
	return FALSE;	
}

BOOL _OBJECT_Is_new(C_TEXT &Param1, C_LONGINT &Param2)
{
	if(ConnectionToHelper()){
		NSString *identifier = Param1.copyUTF16String();
		NSNumber *code = [sharedEventKitHelper objectIsNew:identifier];
		[identifier release];
		
		if([code intValue] == 0)
			return TRUE;
	}
	
	return FALSE;	
}

#pragma mark -
#pragma mark QUERY
#pragma mark -

void _QUERY_EVENT(C_DATE &Param1, C_TIME &Param2, C_DATE &Param3, C_TIME &Param4, ARRAY_TEXT &Param5, ARRAY_TEXT &Param6)
{
	if(ConnectionToHelper()){
		NSDate *startDate = _copyDate(Param1, Param2);
		NSDate *endDate = _copyDate(Param3, Param4);
		NSArray *calendars = _copyArray(Param5);		
		NSArray *reminders = [sharedEventKitHelper queryEventsForStartDate:startDate endDate:endDate calendars:calendars];
		_setArray(reminders, Param6);
		[calendars release];		
		[startDate release];
		[endDate release];		
	}
}

void _QUERY_COMPLETE_REMINDER(C_DATE &Param1, C_TIME &Param2, C_DATE &Param3, C_TIME &Param4, ARRAY_TEXT &Param5, ARRAY_TEXT &Param6)
{
	if(ConnectionToHelper()){
		NSDate *startDate = _copyDate(Param1, Param2);
		NSDate *endDate = _copyDate(Param3, Param4);
		NSArray *calendars = _copyArray(Param5);		
		NSArray *reminders = [sharedEventKitHelper queryCompleteRemindersForStartDate:startDate endDate:endDate calendars:calendars];
		_setArray(reminders, Param6);
		[calendars release];		
		[startDate release];
		[endDate release];		
	}
}

void _QUERY_INCOMPLETE_REMINDER(C_DATE &Param1, C_TIME &Param2, C_DATE &Param3, C_TIME &Param4, ARRAY_TEXT &Param5, ARRAY_TEXT &Param6)
{
	if(ConnectionToHelper()){
		NSDate *startDate = _copyDate(Param1, Param2);
		NSDate *endDate = _copyDate(Param3, Param4);
		NSArray *calendars = _copyArray(Param5);		
		NSArray *reminders = [sharedEventKitHelper queryIncompleteRemindersForStartDate:startDate endDate:endDate calendars:calendars];
		_setArray(reminders, Param6);
		[calendars release];		
		[startDate release];
		[endDate release];		
	}
}
