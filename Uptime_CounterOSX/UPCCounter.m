//
//  UPCCounter.m
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

#import "UPCCounter.h"

@implementation UPCCounter

-(id) init{
    return self;
}

-(id)initWithContext:(NSManagedObjectContext *)recvContext
{
    self = [super init];
    if (self) {
        days = [[NSNumber alloc] initWithLong:0];
        hours = [[NSNumber alloc] initWithLong:0];
        minutes = [[NSNumber alloc] initWithLong:0];
        seconds = [[NSNumber alloc] initWithLong:0];
        startDate = [[NSDate alloc] init];
        context = recvContext;
        runtimeEntity = [NSEntityDescription  insertNewObjectForEntityForName:@"History" inManagedObjectContext:context];
        [runtimeEntity setValue:startDate forKey:@"start"];
    }
    return self;
}

- (NSNumber *) getTimeDifferenceCustom:(NSDate *)beginDate end:(NSDate *)endDate{
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSUInteger unitFlags = NSSecondCalendarUnit;
    NSDateComponents *components = [gregorian components:unitFlags fromDate:beginDate toDate:endDate options:0];
    return [[NSNumber alloc] initWithLong:[components second]];
}

- (NSNumber *) convertToSeconds{
    return [[NSNumber alloc] initWithLong:[days longValue]*24*60*60+[hours longValue]*60*60+[minutes longValue]*60+[seconds longValue]];
}

- (NSNumber *) returnAppStartCount{
    NSArray *raw = [self getRawTableArray];
    return [[NSNumber alloc] initWithInteger:[raw count]];
}

- (void) countUp{
    if([seconds longValue] == 59)
    {
        seconds = [[NSNumber alloc] initWithLong:0];
        if([minutes longValue] == 59)
        {
            minutes = [[NSNumber alloc] initWithLong:0];
            if([hours longValue] == 23)
            {
                hours = [[NSNumber alloc] initWithLong:0];
                days = [[NSNumber alloc] initWithLong:[days longValue]+1];
            }else
            {
                hours = [[NSNumber alloc] initWithLong:[hours longValue]+1];
            }
        }else
        {
            minutes = [[NSNumber alloc] initWithLong:[minutes longValue]+1];
        }
    }else
    {
        seconds = [[NSNumber alloc] initWithLong:[seconds longValue]+1];
    }
}

- (NSArray *) getRawTableArray{
    NSError *error;
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"History" inManagedObjectContext:context];
    NSSortDescriptor *sd = [NSSortDescriptor sortDescriptorWithKey:@"start"
                                                         ascending:NO];
    [fetchRequest setEntity:entity];
    [fetchRequest setSortDescriptors:[NSArray arrayWithObject:sd]];
    return [context executeFetchRequest:fetchRequest error:&error];
}

- (NSMutableArray *) getCompleteTableArray{
    return [[self getRawTableArray] mutableCopy];
}

- (NSString *)returnTotalTimeString{
    return [self returnCustomTimerString:total];
}

- (NSString *) returnLongestTimeString{
    NSMutableArray *tmp = [[NSMutableArray alloc] init];
    NSArray *raw = [self getRawTableArray];
    total = 0;
    for(int i=0 ; i<[raw count]; i++)
    {
        NSNumber *res = [[raw objectAtIndex:i] valueForKey:@"seconds"];
        total = total + [res longValue];
        [tmp addObject:res];
    }
    NSArray *sorted = [tmp sortedArrayUsingFunction:sort context:NULL];
    NSNumber *max = [sorted objectAtIndex:[sorted count] - 1];
    return [self returnCustomTimerString:[max longValue]];
    
}

static NSInteger sort(NSNumber *n1, NSNumber *n2, void *context) {
    if([n1 longValue] < [n2 longValue])
        return NSOrderedAscending;
    else if([n1 longValue] > [n2 longValue])
        return NSOrderedDescending;
    else
        return NSOrderedSame;
}

- (void) update{
    currentDate = [[NSDate alloc] init];
    [self countUp];
}

- (void) currentDataUpdate{
    currentDate = [[NSDate alloc] init];
}

- (void) save{
    [runtimeEntity setValue:currentDate forKey:@"end"];
    NSNumber *diff = [self convertToSeconds];
    NSString *resString = [self returnCustomTimerString:[diff longValue]];
    [runtimeEntity setValue:resString forKey:@"time"];
    [runtimeEntity setValue:diff forKey:@"seconds"];
}

- (NSString *) returnTimerString{
    NSMutableString *builder = [[NSMutableString alloc] init];
    [builder appendFormat:@"%@ d  ",days];
    if([hours longValue] < 10){
        [builder appendFormat:@"0%@ : ",hours];
    } else { [builder appendFormat:@"%@ : ", hours]; }
    if([minutes longValue] < 10){
        [builder appendFormat:@"0%@ : ",minutes];
    } else { [builder appendFormat:@"%@ : ", minutes]; }
    if([seconds longValue] < 10){
        [builder appendFormat:@"0%@",seconds];
    } else { [builder appendFormat:@"%@", seconds]; }
    return builder;
}

- (NSString *) returnCustomTimerString:(long)time{
    long m = time/60;
    NSNumber *cSec = [[NSNumber alloc] initWithLong:(time-(m*60))];
    long h = m/60;
    NSNumber *cMin = [[NSNumber alloc] initWithLong:(m-(h*60))];
    long d = h/24;
    NSNumber *cHr = [[NSNumber alloc] initWithLong:(h-(d*24))];
    NSNumber *cDs = [[NSNumber alloc] initWithLong:d];
    
    NSMutableString *builder = [[NSMutableString alloc] init];
    [builder appendFormat:@"%@ d  ",cDs];
    if([cHr longValue] < 10){
        [builder appendFormat:@"0%@ : ",cHr];
    } else { [builder appendFormat:@"%@ : ", cHr]; }
    if([cMin longValue] < 10){
        [builder appendFormat:@"0%@ : ",cMin];
    } else { [builder appendFormat:@"%@ : ", cMin]; }
    if([cSec longValue] < 10){
        [builder appendFormat:@"0%@",cSec];
    } else { [builder appendFormat:@"%@", cSec]; }
    return builder;
}
@end