#import "EventKitHelperAppDelegate.h"

@implementation EventKitHelperAppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {

	NSConnection *defaultConnection = [[NSConnection new]autorelease];
	
	EventKitHelper *eventKitHelper = [[EventKitHelper alloc]initWithProcessIdentifier:[[NSRunningApplication currentApplication]processIdentifier]];
	
	[defaultConnection setRootObject:eventKitHelper];
	
	if ([defaultConnection registerName:@"eventKitHelper"])
	{
		NSLog(@"registered %@, pid is %@", @"eventKitHelper", eventKitHelper.processIdentifier);
	}	
		
	//need to do this in order to vend the object
	[[NSRunLoop currentRunLoop]run];
	
}

- (NSApplicationTerminateReply)applicationShouldTerminate:(NSApplication *)sender {

	return NSTerminateNow;
	
}

@end
