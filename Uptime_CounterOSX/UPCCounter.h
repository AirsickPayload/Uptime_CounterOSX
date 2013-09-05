//
//  UPCCounter.h
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

#import <Foundation/Foundation.h>

static NSUInteger total;

@interface UPCCounter : NSObject{
    NSNumber *days, *hours, *minutes, *seconds;
    NSDate *startDate;
    NSDate *currentDate;
    NSManagedObject *runtimeEntity;
    NSManagedObjectContext *context;
}

- (id)initWithContext:(NSManagedObjectContext *) recvContext;
- (void)update;
- (void)save;
- (void)countUp;
- (NSArray *)getRawTableArray;
- (NSMutableArray *)getCompleteTableArray;
- (NSString *)returnTimerString;
- (NSString *)returnCustomTimerString:(long) time;
- (NSString *)returnLongestTimeString;
- (NSString *)returnTotalTimeString;
- (NSNumber *)getTimeDifferenceCustom:(NSDate *) beginDate end:(NSDate *) endDate;
- (NSNumber *)convertToSeconds;
- (NSNumber *)returnAppStartCount;
@end