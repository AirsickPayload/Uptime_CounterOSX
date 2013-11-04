//
//  UPCTableViewController.m
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

#import "UPCTableViewController.h"

@implementation UPCTableViewController

-(id) init{
    self = [super init];
    if (self) {
        list = [[NSMutableArray alloc] init];
        [tableView setDataSource:self];
    }
    return self;
}

-(id) initWithContext:(NSManagedObjectContext *)recvContext{
    self = [super init];
    if (self) {
        list = [[NSMutableArray alloc] init];
        [tableView setDataSource:self];
        context = recvContext;
    }
    return self;
}

- (void)updateList:(NSMutableArray *) updatedList{
    list = updatedList;
    return;
}

- (NSInteger) numberOfRowsInTableView:(NSTableView *)tableView{
    return [list count];
}

- (id)tableView:(NSTableView *)tableView objectValueForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row{
    NSString *identifier =  [tableColumn identifier];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setTimeZone:[NSTimeZone systemTimeZone]];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSString *formatted;
    if( ![identifier  isEqual: @"time"])
    {
        formatted = [[NSString alloc] initWithFormat:@"%@", [dateFormatter stringFromDate:[[list objectAtIndex:row] valueForKey:identifier]]];
    }
    else
    {
        formatted = [[NSString alloc] initWithFormat:@"%@", [[list objectAtIndex:row] valueForKey:identifier]];
    }
    return formatted;
}
@end