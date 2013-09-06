//
//  UPCAppDelegate.h
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

#import <Cocoa/Cocoa.h>
#import "UPCstatsWindowController.h"
#import "UPCCounter.h"
#import "UPCTableViewController.h"

static NSInteger interval;
@interface UPCAppDelegate : NSObject <NSApplicationDelegate>
{
    IBOutlet NSMenu *statusMenu;
    NSStatusItem * statusItem;
    UPCCounter *counter;
    UPCTableViewController *tableController;
    NSManagedObjectContext *context;
    BOOL lowPower;
}

@property (assign) IBOutlet NSWindow *window;


@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;

- (IBAction)saveAction:(id)sender;
- (IBAction)openStats:(NSButton *)sender;
- (IBAction)click:(NSButton *)sender;
- (IBAction)statusBarClick:(NSButton *)sender;
- (IBAction)updateTableClick:(NSButton *)sender;
- (IBAction)updateIntervalClick:(NSButton *)sender;
- (IBAction)lowPowerModeClick:(NSButton *)sender;

@property (weak) IBOutlet NSButton *setInitHideStateStatus;
@property (weak) IBOutlet NSButton *statusBarOutlet;
@property (weak) IBOutlet NSScrollView *tableView;
@property (weak) IBOutlet NSTextField *currentUptimeText;
@property (weak) IBOutlet NSTableView *tableViewOutlet;
@property (weak) IBOutlet NSTextField *updateIntervalFieldOutlet;
@property (weak) IBOutlet NSTextField *totalTimeFieldOutlet;
@property (weak) IBOutlet NSTextField *longestTimeFieldOutlet;
@property (weak) IBOutlet NSTextField *appStartCount;
@property (weak) IBOutlet NSButton *lowPowerOutlet;

- (void)setUpIconSettings;
- (void)startCounterThread;
- (void)counterLoop;
- (void)menuWillOpen:(NSMenu *)menu;
@end