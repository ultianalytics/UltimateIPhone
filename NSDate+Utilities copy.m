/*
 Erica Sadun, http://ericasadun.com
 iPhone Developer's Cookbook 3.x and beyond
 BSD License, Use at your own risk
 */

/*
 #import <humor.h> : Not planning to implement: dateByAskingBoyOut and dateByGettingBabysitter
 ----
 General Thanks: sstreza, Scott Lawrence, Kevin Ballard, NoOneButMe, Avi`, August Joki. Emanuele Vulcano, jcromartiej
*/

#import "NSDate-Utilities.h"

#define DATE_COMPONENTS (NSYearCalendarUnit| NSMonthCalendarUnit | NSDayCalendarUnit | NSWeekCalendarUnit |  NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit | NSWeekdayCalendarUnit | NSWeekdayOrdinalCalendarUnit)
#define CURRENT_CALENDAR [NSCalendar currentCalendar]


@implementation NSDate (Utilities)

@dynamic nearestHour;
@dynamic hour;
@dynamic minute;
@dynamic seconds;
@dynamic day;
@dynamic month;
@dynamic week;
@dynamic weekday;
@dynamic nthWeekday; // e.g. 2nd Tuesday of the month == 2
@dynamic year;


#pragma mark Relative Dates

+ (NSDate *) dateWithDaysFromNow: (NSUInteger) days
{
	NSDate *now = [NSDate date];
	return [now dateByAddingDays:days];
}

+ (NSDate *) dateWithDaysBeforeNow: (NSUInteger) days
{
	NSDate *now = [NSDate date];
	return [now dateBySubtractingDays:days];
}



+ (NSDate *) dateTomorrow
{
	return [NSDate dateWithDaysFromNow:1];
}

+ (NSDate *) dateYesterday
{
	return [NSDate dateWithDaysBeforeNow:1];
}

+ (NSDate *) dateWithHoursFromNow: (NSUInteger) dHours
{
	NSTimeInterval aTimeInterval = [[NSDate date] timeIntervalSinceReferenceDate] + D_HOUR * dHours;
	NSDate *newDate = [NSDate dateWithTimeIntervalSinceReferenceDate:aTimeInterval];
	return newDate;
}

+ (NSDate *) dateWithHoursBeforeNow: (NSUInteger) dHours
{
	NSTimeInterval aTimeInterval = [[NSDate date] timeIntervalSinceReferenceDate] - D_HOUR * dHours;
	NSDate *newDate = [NSDate dateWithTimeIntervalSinceReferenceDate:aTimeInterval];
	return newDate;
}

+ (NSDate *) dateWithMinutesFromNow: (NSUInteger) dMinutes
{
	NSTimeInterval aTimeInterval = [[NSDate date] timeIntervalSinceReferenceDate] + D_MINUTE * dMinutes;
	NSDate *newDate = [NSDate dateWithTimeIntervalSinceReferenceDate:aTimeInterval];
	return newDate;
}

+ (NSDate *) dateWithMinutesBeforeNow: (NSUInteger) dMinutes
{
	NSTimeInterval aTimeInterval = [[NSDate date] timeIntervalSinceReferenceDate] - D_MINUTE * dMinutes;
	NSDate *newDate = [NSDate dateWithTimeIntervalSinceReferenceDate:aTimeInterval];
	return newDate;
}

+ (NSDate *) dateWithMonthsFromNow:(NSUInteger) dMonths {
	
	return [[NSDate date] dateByAddingMonths:dMonths];
}

+ (NSDate *) dateWithMonthsBeforeNow:(NSUInteger) dMonths {
	
	return [[NSDate date] dateBySubtractingMonths:dMonths];
}

#pragma mark Comparing Dates

- (BOOL)isEqualIgnoringTimeToTargetDate:(NSDate *)targetDate targetCalendar:(NSCalendar *)targetCalendar thisCalendar:(NSCalendar *)thisCalendar
{
	NSDateComponents *components1 = [thisCalendar components:DATE_COMPONENTS fromDate:self];
	NSDateComponents *components2 = [targetCalendar components:DATE_COMPONENTS fromDate:targetDate];
	return (([components1 year] == [components2 year]) &&
			([components1 month] == [components2 month]) &&
			([components1 day] == [components2 day]));
}

- (BOOL) isEqualToDateIgnoringTime: (NSDate *) aDate
{
	return [self isEqualIgnoringTimeToTargetDate:aDate targetCalendar:CURRENT_CALENDAR thisCalendar:CURRENT_CALENDAR];
}

-(BOOL)isEqualToDateIgnoringTimeUTC:(NSDate *)aDate 
{
	return [self isEqualIgnoringTimeToTargetDate:aDate targetCalendar:[NSCalendar utcCalendar] thisCalendar:[NSCalendar utcCalendar]];
}

- (BOOL) isToday
{
	return [self isEqualToDateIgnoringTime:[NSDate date]];
}

- (BOOL) isTomorrow
{
	return [self isEqualToDateIgnoringTime:[NSDate dateTomorrow]];
}

- (BOOL) isYesterday
{
	return [self isEqualToDateIgnoringTime:[NSDate dateYesterday]];
}

// This hard codes the assumption that a week is 7 days
- (BOOL) isSameWeekAsDate: (NSDate *) aDate
{
	NSDateComponents *components1 = [CURRENT_CALENDAR components:DATE_COMPONENTS fromDate:self];
	NSDateComponents *components2 = [CURRENT_CALENDAR components:DATE_COMPONENTS fromDate:aDate];

	// Must be same week. 12/31 and 1/1 will both be week "1" if they are in the same week
	if ([components1 week] != [components2 week]) return NO;

	// Must have a time interval under 1 week. Thanks @aclark
	return (abs([self timeIntervalSinceDate:aDate]) < D_WEEK);
}

- (BOOL) isThisWeek
{
	return [self isSameWeekAsDate:[NSDate date]];
}

- (BOOL) isNextWeek
{
	NSTimeInterval aTimeInterval = [[NSDate date] timeIntervalSinceReferenceDate] + D_WEEK;
	NSDate *newDate = [NSDate dateWithTimeIntervalSinceReferenceDate:aTimeInterval];
	return [self isSameYearAsDate:newDate];
}

- (BOOL) isLastWeek
{
	NSTimeInterval aTimeInterval = [[NSDate date] timeIntervalSinceReferenceDate] - D_WEEK;
	NSDate *newDate = [NSDate dateWithTimeIntervalSinceReferenceDate:aTimeInterval];
	return [self isSameYearAsDate:newDate];
}

- (BOOL) isSameYearAsDate: (NSDate *) aDate
{
	NSDateComponents *components1 = [CURRENT_CALENDAR components:NSYearCalendarUnit fromDate:self];
	NSDateComponents *components2 = [CURRENT_CALENDAR components:NSYearCalendarUnit fromDate:aDate];
	return ([components1 year] == [components2 year]);
}

- (BOOL) isThisYear
{
	return [self isSameYearAsDate:[NSDate date]];
}

- (BOOL) isNextYear
{
	NSDateComponents *components1 = [CURRENT_CALENDAR components:NSYearCalendarUnit fromDate:self];
	NSDateComponents *components2 = [CURRENT_CALENDAR components:NSYearCalendarUnit fromDate:[NSDate date]];

	return ([components1 year] == ([components2 year] + 1));
}

- (BOOL) isLastYear
{
	NSDateComponents *components1 = [CURRENT_CALENDAR components:NSYearCalendarUnit fromDate:self];
	NSDateComponents *components2 = [CURRENT_CALENDAR components:NSYearCalendarUnit fromDate:[NSDate date]];

	return ([components1 year] == ([components2 year] - 1));
}

- (BOOL) isSameMonthAsDate:(NSDate *) aDate {

	NSDateComponents *components1 = [CURRENT_CALENDAR components:NSMonthCalendarUnit fromDate:self];
	NSDateComponents *components2 = [CURRENT_CALENDAR components:NSMonthCalendarUnit fromDate:aDate];
	return ([components1 month] == [components2 month]) && [self isSameYearAsDate:aDate];
}

- (BOOL) isThisMonth {

	return [self isSameMonthAsDate:[NSDate date]];
}

- (BOOL) isNextMonth {
	NSDateComponents *components1 = [CURRENT_CALENDAR components:NSMonthCalendarUnit fromDate:self];
	NSDateComponents *components2 = [CURRENT_CALENDAR components:NSMonthCalendarUnit fromDate:[NSDate date]];
	
	return ([components1 month] == ([components2 month] + 1));
}
- (BOOL) isLastMonth {
	NSDateComponents *components1 = [CURRENT_CALENDAR components:NSMonthCalendarUnit fromDate:self];
	NSDateComponents *components2 = [CURRENT_CALENDAR components:NSMonthCalendarUnit fromDate:[NSDate date]];
	
	return ([components1 month] == ([components2 month] - 1));
}

- (BOOL) isEarlierThanDate: (NSDate *) aDate
{
	// short circuit if dates are equal
	if ([self isEqualToDate:aDate]) {
		return NO;
	}
	
	return ([self earlierDate:aDate] == self);
}

- (BOOL) isLaterThanDate: (NSDate *) aDate
{
	// short circuit if dates are equal
	if ([self isEqualToDate:aDate]) {
		return NO;
	}
	return ([self laterDate:aDate] == self);
}


#pragma mark Adjusting Dates

- (NSDate *)dateByOffsettingDays:(NSInteger)dDays inCalendar:(NSCalendar *)calendar
{
	NSDateComponents *offsetComponents = [[NSDateComponents alloc] init];
	[offsetComponents setDay:dDays];
	NSDate *result = [calendar dateByAddingComponents:offsetComponents
											toDate:self options:0];
	return result;
}

- (NSDate *) dateByAddingDays: (NSUInteger) dDays
{
	return [self dateByOffsettingDays:dDays inCalendar:[NSCalendar currentCalendar]];
}

- (NSDate *) dateBySubtractingDays: (NSUInteger) dDays
{
	return [self dateByOffsettingDays:(-1 * dDays) inCalendar:[NSCalendar currentCalendar]];
}

- (NSDate *) dateByOffsettingHours:(NSInteger)hours inCalendar:(NSCalendar*)calendar
{
	NSDateComponents *offsetComponents = [[NSDateComponents alloc] init];
	[offsetComponents setHour:hours];
	NSDate *result = [calendar dateByAddingComponents:offsetComponents
                                               toDate:self options:0];
	return result;
}

- (NSDate *) dateByAddingHours: (NSUInteger) dHours
{
    return [self dateByOffsettingHours:dHours inCalendar:[NSCalendar currentCalendar]];
}

- (NSDate *) dateBySubtractingHours: (NSUInteger) dHours
{
	return [self dateByOffsettingHours:(dHours * -1) inCalendar:[NSCalendar currentCalendar]];
}

- (NSDate *) dateByOffsettingMinutes:(NSInteger)minutes inCalendar:(NSCalendar*)calendar
{
	NSDateComponents *offsetComponents = [[NSDateComponents alloc] init];
	[offsetComponents setMinute:minutes];
	NSDate *result = [calendar dateByAddingComponents:offsetComponents
                                               toDate:self options:0];
	return result;
}

- (NSDate *) dateByAddingMinutes: (NSUInteger) dMinutes
{
	return [self dateByOffsettingMinutes:dMinutes inCalendar:[NSCalendar currentCalendar]];
}

- (NSDate *) dateBySubtractingMinutes: (NSUInteger) dMinutes
{
	return [self dateByOffsettingMinutes:(dMinutes * -1) inCalendar:[NSCalendar currentCalendar]];
}

- (NSDate *) dateAtStartOfDay
{
	NSDateComponents *components = [CURRENT_CALENDAR components:DATE_COMPONENTS fromDate:self];
	[components setHour:0];
	[components setMinute:0];
	[components setSecond:0];
	return [CURRENT_CALENDAR dateFromComponents:components];
}

// TRF Added to find the first date of the month at midnight
- (NSDate *) dateAtStartOfMonth {
	NSDateComponents *components = [CURRENT_CALENDAR components:(NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit) fromDate:self];
	[components setDay:1];
	[components setHour:0];
	[components setMinute:0];
	[components setSecond:0];
	return [CURRENT_CALENDAR dateFromComponents:components];
}

- (NSDate *) dateAtStartOfNextMonth {
	NSDate *beginningOfMonth = [self dateAtStartOfMonth];

	NSDateComponents *comps = [[NSDateComponents alloc] init];
	[comps setDay:0];
	[comps setMonth:1];
	[comps setYear:0];

	return [CURRENT_CALENDAR dateByAddingComponents:comps toDate:beginningOfMonth options:0];
}

// last day of month at 11:59:59
- (NSDate *) dateAtEndOfMonth {

	NSDate *beginningOfNextMonth = [self dateAtStartOfNextMonth];

	NSDateComponents *comps = [[NSDateComponents alloc] init];
	[comps setDay:0];
	[comps setMonth:0];
	[comps setYear:0];
	[comps setHour:0];
	[comps setMinute:0];
	[comps setSecond:-1];

	return [CURRENT_CALENDAR dateByAddingComponents:comps toDate:beginningOfNextMonth options:0];
}

- (NSDate *) dateByAddingMonths:(NSUInteger) dMonths {
	NSDateComponents *comps = [[NSDateComponents alloc] init];
	[comps setDay:0];
	[comps setMonth:dMonths];
	[comps setYear:0];
	
	return [CURRENT_CALENDAR dateByAddingComponents:comps toDate:self options:0];
}

- (NSDate *) dateBySubtractingMonths:(NSUInteger) dMonths {
	NSDateComponents *comps = [[NSDateComponents alloc] init];
	[comps setDay:0];
	[comps setMonth:-1*dMonths];
	[comps setYear:0];
	
	return [CURRENT_CALENDAR dateByAddingComponents:comps toDate:self options:0];
}

- (NSDateComponents *) componentsWithOffsetFromDate: (NSDate *) aDate
{
	NSDateComponents *dTime = [CURRENT_CALENDAR components:DATE_COMPONENTS fromDate:aDate toDate:self options:0];
	return dTime;
}

#pragma mark Retrieving Intervals

- (NSInteger) minutesAfterDate: (NSDate *) aDate
{
	NSTimeInterval ti = [self timeIntervalSinceDate:aDate];
	return (NSInteger) (ti / D_MINUTE);
}

- (NSInteger) minutesBeforeDate: (NSDate *) aDate
{
	NSTimeInterval ti = [aDate timeIntervalSinceDate:self];
	return (NSInteger) (ti / D_MINUTE);
}

- (NSInteger) hoursAfterDate: (NSDate *) aDate
{
	NSTimeInterval ti = [self timeIntervalSinceDate:aDate];
	return (NSInteger) (ti / D_HOUR);
}

- (NSInteger) hoursBeforeDate: (NSDate *) aDate
{
	NSTimeInterval ti = [aDate timeIntervalSinceDate:self];
	return (NSInteger) (ti / D_HOUR);
}

- (NSInteger) daysAfterDate: (NSDate *) aDate
{
	NSTimeInterval ti = [self timeIntervalSinceDate:aDate];
	return (NSInteger) (ti / D_DAY);
}

- (NSInteger) daysBeforeDate: (NSDate *) aDate
{
	NSTimeInterval ti = [aDate timeIntervalSinceDate:self];
	return (NSInteger) (ti / D_DAY);
}

//dbs - NSDate is already a UTC date so there is no need for this
//      method.
//-(NSInteger)daysBeforeUTCDate:(NSDate*)aDate {
//#warning No implementation!
//    return 0;
//}

- (NSInteger)daysWithinEraToDate:(NSDate *)endDate inCalendar:(NSCalendar *)endCalendar thisCalendar:(NSCalendar *)startCalendar
{
	NSInteger startDay=[startCalendar ordinalityOfUnit:NSDayCalendarUnit
									   inUnit: NSEraCalendarUnit forDate:self];
	NSInteger endDay=[endCalendar ordinalityOfUnit:NSDayCalendarUnit
									 inUnit: NSEraCalendarUnit forDate:endDate];
	return endDay-startDay;
}

#pragma mark Decomposing Dates

- (NSInteger) nearestHour
{
	NSTimeInterval aTimeInterval = [[NSDate date] timeIntervalSinceReferenceDate] + D_MINUTE * 30;
	NSDate *newDate = [NSDate dateWithTimeIntervalSinceReferenceDate:aTimeInterval];
	NSDateComponents *components = [CURRENT_CALENDAR components:NSHourCalendarUnit fromDate:newDate];
	return [components hour];
}

- (NSInteger) hour
{
	NSDateComponents *components = [CURRENT_CALENDAR components:DATE_COMPONENTS fromDate:self];
	return [components hour];
}

- (NSInteger) minute
{
	NSDateComponents *components = [CURRENT_CALENDAR components:DATE_COMPONENTS fromDate:self];
	return [components minute];
}

- (NSInteger) seconds
{
	NSDateComponents *components = [CURRENT_CALENDAR components:DATE_COMPONENTS fromDate:self];
	return [components second];
}

- (NSInteger) day
{
	NSDateComponents *components = [CURRENT_CALENDAR components:DATE_COMPONENTS fromDate:self];
	return [components day];
}

- (NSInteger) month
{
	NSDateComponents *components = [CURRENT_CALENDAR components:DATE_COMPONENTS fromDate:self];
	return [components month];
}

- (NSInteger) week
{
	NSDateComponents *components = [CURRENT_CALENDAR components:DATE_COMPONENTS fromDate:self];
	return [components week];
}

- (NSInteger) weekday
{
	NSDateComponents *components = [CURRENT_CALENDAR components:DATE_COMPONENTS fromDate:self];
	return [components weekday];
}

- (NSInteger) nthWeekday // e.g. 2nd Tuesday of the month is 2
{
	NSDateComponents *components = [CURRENT_CALENDAR components:DATE_COMPONENTS fromDate:self];
	return [components weekdayOrdinal];
}
- (NSInteger) year
{
	NSDateComponents *components = [CURRENT_CALENDAR components:DATE_COMPONENTS fromDate:self];
	return [components year];
}

@end

@implementation NSCalendar (Utilities)

+(NSCalendar*)utcCalendar {
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    [calendar setTimeZone:[NSTimeZone timeZoneWithName:@"UTC"]];
    return calendar;
}
@end
