//
//  UPCAppDelegate.m
//  Uptime_CounterOSX
//
//  Copyright (c) 2013 Alan Matuszczak.
//  Contact: al4n00@gmail.com
//This program is free software: you can redistribute it and/or modify
//it under the terms of the GNU General Public License as published by
//the Free Software Foundation, either version 3 of the License, or
//(at your option) any later version.
//
//This program is distributed in the hope that it will be useful,
//but WITHOUT ANY WARRANTY; without even the implied warranty of
//MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//GNU General Public License for more details.
//
//You should have received a copy of the GNU General Public License
//along with this program.  If not, see <http://www.gnu.org/licenses/>.
//

#import "UPCAppDelegate.h"

@implementation UPCAppDelegate

@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize managedObjectContext = _managedObjectContext;

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    context = [self managedObjectContext];
    [self setUpIconSettings];
    tableController = [[UPCTableViewController alloc] initWithContext:context];
    counter = [[UPCCounter alloc] initWithContext:context];
    [self startCounterThread];
    [[self window] setLevel: NSNormalWindowLevel];
    [[self appStartCount] setStringValue:[[NSString alloc] initWithFormat:@"Times launched: %@", [counter returnAppStartCount]]];
    lowPower = NO;
    [[self lowPowerOutlet] setState:NSOffState];
    [counter update];
    [counter save];
    [[self currentUptimeText] setStringValue:[counter returnTimerString]];
    [[NSProcessInfo processInfo] disableAutomaticTermination:@"AppNap Prevention"];
    [[NSProcessInfo processInfo] disableSuddenTermination];
}

- (void) startCounterThread{
    NSTimer *timer = [NSTimer scheduledTimerWithTimeInterval:1.0
                      
                                                      target:self selector:@selector(counterLoop)
                      
                                                    userInfo:nil repeats:YES];
}

- (void)counterLoop{
    NSInteger time = 0;

        if(lowPower){[counter countUp];}
        else
        {
            [counter update];
            [[self currentUptimeText] setStringValue:[counter returnTimerString]];
            if(time == interval)
            {
                [counter save];
                [tableController updateList:[counter getCompleteTableArray]];
                [[self tableViewOutlet] reloadData];
                [[self longestTimeFieldOutlet] setStringValue:[[NSString alloc] initWithFormat:@"Longest: %@", [counter returnLongestTimeString]]];
                [[self totalTimeFieldOutlet] setStringValue:[[NSString alloc] initWithFormat:@"Total: %@", [counter returnTotalTimeString]]];
                time = 0;
            }
            else { time = time + 1; }
        }
}

- (IBAction)updateIntervalClick:(NSButton *)sender {
    NSString *tmpval = [[self updateIntervalFieldOutlet] stringValue];
    [[NSUserDefaults standardUserDefaults] setInteger:[tmpval integerValue]*60 forKey:@"updateInterval"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    interval = [tmpval integerValue]*60;
}

- (IBAction)lowPowerModeClick:(NSButton *)sender {
    if(lowPower)
    {
        lowPower = NO; [counter currentDataUpdate];
        [[self currentUptimeText] setStringValue:[counter returnTimerString]];
        [counter save];
        [tableController updateList:[counter getCompleteTableArray]];
        [[self tableViewOutlet] reloadData];
        [[self longestTimeFieldOutlet] setStringValue:[[NSString alloc] initWithFormat:@"Longest: %@", [counter returnLongestTimeString]]];
        [[self totalTimeFieldOutlet] setStringValue:[[NSString alloc] initWithFormat:@"Total: %@", [counter returnTotalTimeString]]];
    } else { lowPower = YES;}
    if(lowPower) { [[self lowPowerOutlet] setState:NSOnState];} else { [[self lowPowerOutlet] setState:NSOffState];}
}

- (void)setUpIconSettings
{
    if([[NSUserDefaults standardUserDefaults] objectForKey:@"iconInDock"] == nil && [[NSUserDefaults standardUserDefaults] objectForKey:@"iconInStatus"] == nil && [[NSUserDefaults standardUserDefaults] objectForKey:@"updateInterval"] == nil)
    {
        NSArray *objects = [[NSArray alloc] initWithObjects:[NSNumber numberWithBool:YES],[NSNumber numberWithBool:NO], [NSNumber numberWithInteger:3600],nil];
        NSArray *keys = [[NSArray alloc] initWithObjects:@"iconInDock", @"iconInStatus", @"updateInterval", nil];
        
        NSDictionary *appDefaults = [NSDictionary dictionaryWithObjects:objects forKeys:keys];
        [[NSUserDefaults standardUserDefaults] registerDefaults:appDefaults];
        [[NSUserDefaults standardUserDefaults] synchronize];
        [[self setInitHideStateStatus] setState:NSOnState];
        [[self statusBarOutlet] setState:NSOffState];
        interval = 3600;
        [[self updateIntervalFieldOutlet] setStringValue:[[NSString alloc] initWithFormat:@"%ld",(interval/60)]];
    }
    else
    {
        if([[NSUserDefaults standardUserDefaults] boolForKey:@"iconInDock"] == YES) { [[self setInitHideStateStatus] setState:NSOnState]; ProcessSerialNumber psn = { 0, kCurrentProcess };
            TransformProcessType(&psn, kProcessTransformToForegroundApplication); }
        else { [[self setInitHideStateStatus] setState:NSOffState]; ProcessSerialNumber psn = { 0, kCurrentProcess };
            TransformProcessType(&psn, kProcessTransformToUIElementApplication); }
        
        if([[NSUserDefaults standardUserDefaults] boolForKey:@"iconInStatus"] == YES)
        {
            [[self statusBarOutlet] setState:NSOnState];
            statusItem = [[NSStatusBar systemStatusBar] statusItemWithLength:NSVariableStatusItemLength];
            [statusItem setMenu:statusMenu];
            [statusItem setTitle:@"C"];
            [statusItem setHighlightMode:YES];
        }
        else
        {
            [[self statusBarOutlet] setState:NSOffState];
        }
        
        interval = [[NSUserDefaults standardUserDefaults] integerForKey:@"updateInterval"];
        [[self updateIntervalFieldOutlet] setStringValue:[[NSString alloc] initWithFormat:@"%ld", interval/60]];
    }
}

// Returns the directory the application uses to store the Core Data store file. This code uses a directory named "Alan-Matuszczak.Uptime_CounterOSX" in the user's Application Support directory.
- (NSURL *)applicationFilesDirectory
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSURL *appSupportURL = [[fileManager URLsForDirectory:NSApplicationSupportDirectory inDomains:NSUserDomainMask] lastObject];
    return [appSupportURL URLByAppendingPathComponent:@"Uptime_CounterOSX"];
}

// Creates if necessary and returns the managed object model for the application.
- (NSManagedObjectModel *)managedObjectModel
{
    if (_managedObjectModel) {
        return _managedObjectModel;
    }
	
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"Uptime_CounterOSX" withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}

// Returns the persistent store coordinator for the application. This implementation creates and return a coordinator, having added the store for the application to it. (The directory for the store is created, if necessary.)
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    if (_persistentStoreCoordinator) {
        return _persistentStoreCoordinator;
    }
    
    NSManagedObjectModel *mom = [self managedObjectModel];
    if (!mom) {
        NSLog(@"%@:%@ No model to generate a store from", [self class], NSStringFromSelector(_cmd));
        return nil;
    }
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSURL *applicationFilesDirectory = [self applicationFilesDirectory];
    NSError *error = nil;
    
    NSDictionary *properties = [applicationFilesDirectory resourceValuesForKeys:@[NSURLIsDirectoryKey] error:&error];
    
    if (!properties) {
        BOOL ok = NO;
        if ([error code] == NSFileReadNoSuchFileError) {
            ok = [fileManager createDirectoryAtPath:[applicationFilesDirectory path] withIntermediateDirectories:YES attributes:nil error:&error];
        }
        if (!ok) {
            [[NSApplication sharedApplication] presentError:error];
            return nil;
        }
    } else {
        if (![properties[NSURLIsDirectoryKey] boolValue]) {
            // Customize and localize this error.
            NSString *failureDescription = [NSString stringWithFormat:@"Expected a folder to store application data, found a file (%@).", [applicationFilesDirectory path]];
            
            NSMutableDictionary *dict = [NSMutableDictionary dictionary];
            [dict setValue:failureDescription forKey:NSLocalizedDescriptionKey];
            error = [NSError errorWithDomain:@"YOUR_ERROR_DOMAIN" code:101 userInfo:dict];
            
            [[NSApplication sharedApplication] presentError:error];
            return nil;
        }
    }
    
    NSURL *url = [applicationFilesDirectory URLByAppendingPathComponent:@"Uptime_CounterOSX.storedata"];
    NSPersistentStoreCoordinator *coordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:mom];
    if (![coordinator addPersistentStoreWithType:NSXMLStoreType configuration:nil URL:url options:nil error:&error]) {
        [[NSApplication sharedApplication] presentError:error];
        return nil;
    }
    _persistentStoreCoordinator = coordinator;
    
    return _persistentStoreCoordinator;
}

// Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.) 
- (NSManagedObjectContext *)managedObjectContext
{
    if (_managedObjectContext) {
        return _managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (!coordinator) {
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        [dict setValue:@"Failed to initialize the store" forKey:NSLocalizedDescriptionKey];
        [dict setValue:@"There was an error building up the data file." forKey:NSLocalizedFailureReasonErrorKey];
        NSError *error = [NSError errorWithDomain:@"YOUR_ERROR_DOMAIN" code:9999 userInfo:dict];
        [[NSApplication sharedApplication] presentError:error];
        return nil;
    }
    _managedObjectContext = [[NSManagedObjectContext alloc] init];
    [_managedObjectContext setPersistentStoreCoordinator:coordinator];

    return _managedObjectContext;
}

// Returns the NSUndoManager for the application. In this case, the manager returned is that of the managed object context for the application.
- (NSUndoManager *)windowWillReturnUndoManager:(NSWindow *)window
{
    return [[self managedObjectContext] undoManager];
}

// Performs the save action for the application, which is to send the save: message to the application's managed object context. Any encountered errors are presented to the user.
- (IBAction)saveAction:(id)sender
{
    NSError *error = nil;
    
    if (![[self managedObjectContext] commitEditing]) {
        NSLog(@"%@:%@ unable to commit editing before saving", [self class], NSStringFromSelector(_cmd));
    }
    
    if (![[self managedObjectContext] save:&error]) {
        [[NSApplication sharedApplication] presentError:error];
    }
}

- (IBAction)openStats:(NSButton *)sender {
}

- (IBAction)click:(NSButton *)sender {
    if([sender state] == NSOnState){
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"iconInDock"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    else
    {
        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"iconInDock"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}

- (NSApplicationTerminateReply)applicationShouldTerminate:(NSApplication *)sender
{
    // Save changes in the application's managed object context before the application terminates.
    
    if (!_managedObjectContext) {
        return NSTerminateNow;
    }
    
    if (![[self managedObjectContext] commitEditing]) {
        NSLog(@"%@:%@ unable to commit editing to terminate", [self class], NSStringFromSelector(_cmd));
        return NSTerminateCancel;
    }
    
    if (![[self managedObjectContext] hasChanges]) {
        return NSTerminateNow;
    }
    
    NSError *error = nil;
    if (![[self managedObjectContext] save:&error]) {

        // Customize this code block to include application-specific recovery steps.              
        BOOL result = [sender presentError:error];
        if (result) {
            return NSTerminateCancel;
        }

        NSString *question = NSLocalizedString(@"Could not save changes while quitting. Quit anyway?", @"Quit without saves error question message");
        NSString *info = NSLocalizedString(@"Quitting now will lose any changes you have made since the last successful save", @"Quit without saves error question info");
        NSString *quitButton = NSLocalizedString(@"Quit anyway", @"Quit anyway button title");
        NSString *cancelButton = NSLocalizedString(@"Cancel", @"Cancel button title");
        NSAlert *alert = [[NSAlert alloc] init];
        [alert setMessageText:question];
        [alert setInformativeText:info];
        [alert addButtonWithTitle:quitButton];
        [alert addButtonWithTitle:cancelButton];

        NSInteger answer = [alert runModal];
        
        if (answer == NSAlertAlternateReturn) {
            return NSTerminateCancel;
        }
    }

    return NSTerminateNow;
}

- (BOOL)applicationShouldHandleReopen:(NSApplication *)theApplication hasVisibleWindows:(BOOL)flag
{
    if ( flag ) {
        [self.window orderFront:self];
    }
    else {
        [self.window makeKeyAndOrderFront:self];
    }
    
    return YES;
}

-(void)menuWillOpen:(NSMenu *)menu
{
    [self.window orderFront:self];
    [self.window makeKeyAndOrderFront:self];

}

- (IBAction)statusBarClick:(NSButton *)sender {
    if([sender state] == NSOnState){
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"iconInStatus"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    else
    {
        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"iconInStatus"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}

- (IBAction)updateTableClick:(NSButton *)sender {
    [counter save];
    [tableController updateList:[counter getCompleteTableArray]];
    [[self tableViewOutlet] reloadData];
    [[self longestTimeFieldOutlet] setStringValue:[[NSString alloc] initWithFormat:@"Longest: %@", [counter returnLongestTimeString]]];
    [[self totalTimeFieldOutlet] setStringValue:[[NSString alloc] initWithFormat:@"Total: %@", [counter returnTotalTimeString]]];
}
@end