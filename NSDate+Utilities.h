/*
 Erica Sadun, http://ericasadun.com
 iPhone Developer's Cookbook 3.x and beyond
 BSD License, Use at your own risk
 */

#import <Foundation/Foundation.h>

#define D_MINUTE	60
#define D_HOUR		3600
#define D_DAY		86400
#define D_WEEK		604800
#define D_YEAR		31556926

@interface NSDate (Utilities)

// Relative dates from the current date
+ (NSDate *) dateTomorrow;
+ (NSDate *) dateYesterday;
+ (NSDate *) dateWithDaysFromNow: (NSUInteger) days;
+ (NSDate *) dateWithDaysBeforeNow: (NSUInteger) days;
+ (NSDate *) dateWithHoursFromNow: (NSUInteger) dHours;
+ (NSDate *) dateWithHoursBeforeNow: (NSUInteger) dHours;
+ (NSDate *) dateWithMinutesFromNow: (NSUInteger) dMinutes;
+ (NSDate *) dateWithMinutesBeforeNow: (NSUInteger) dMinutes;
+ (NSDate *) dateWithMonthsFromNow:(NSUInteger) dMonths;
+ (NSDate *) dateWithMonthsBeforeNow:(NSUInteger) dMonths;


// Comparing dates
- (BOOL)isEqualIgnoringTimeToTargetDate:(NSDate *)targetDate targetCalendar:(NSCalendar *)targetCalendar thisCalendar:(NSCalendar *)thisCalendar;
- (BOOL) isEqualToDateIgnoringTime: (NSDate *) aDate;
-(BOOL)isEqualToDateIgnoringTimeUTC:(NSDate *)aDate;
- (BOOL) isToday;
- (BOOL) isTomorrow;
- (BOOL) isYesterday;
- (BOOL) isSameWeekAsDate: (NSDate *) aDate;
- (BOOL) isThisWeek;
- (BOOL) isNextWeek;
- (BOOL) isLastWeek;
- (BOOL) isSameYearAsDate: (NSDate *) aDate;
- (BOOL) isThisYear;
- (BOOL) isNextYear;
- (BOOL) isLastYear;
- (BOOL) isSameMonthAsDate:(NSDate *) aDate;
- (BOOL) isThisMonth;
- (BOOL) isNextMonth;
- (BOOL) isLastMonth;
- (BOOL) isEarlierThanDate: (NSDate *) aDate;
- (BOOL) isLaterThanDate: (NSDate *) aDate;

// Adjusting dates
- (NSDate *) dateByOffsettingDays:(NSInteger)dDays inCalendar:(NSCalendar *)calendar;
- (NSDate *) dateByAddingDays: (NSUInteger) dDays;
- (NSDate *) dateBySubtractingDays: (NSUInteger) dDays;
- (NSDate *) dateByOffsettingHours:(NSInteger)hours inCalendar:(NSCalendar*)calendar;
- (NSDate *) dateByAddingHours: (NSUInteger) dHours;
- (NSDate *) dateBySubtractingHours: (NSUInteger) dHours;
- (NSDate *) dateByOffsettingMinutes:(NSInteger)minutes inCalendar:(NSCalendar*)calendar;
- (NSDate *) dateByAddingMinutes: (NSUInteger) dMinutes;
- (NSDate *) dateBySubtractingMinutes: (NSUInteger) dMinutes;
- (NSDate *) dateAtStartOfDay;
- (NSDate *) dateByAddingMonths:(NSUInteger) dMonths;
- (NSDate *) dateBySubtractingMonths:(NSUInteger) dMonths;

// TRF Added to find the first date of the month
- (NSDate *) dateAtStartOfMonth;
- (NSDate *) dateAtStartOfNextMonth;
- (NSDate *) dateAtEndOfMonth;

// Retrieving intervals
- (NSInteger) minutesAfterDate: (NSDate *) aDate;
- (NSInteger) minutesBeforeDate: (NSDate *) aDate;
- (NSInteger) hoursAfterDate: (NSDate *) aDate;
- (NSInteger) hoursBeforeDate: (NSDate *) aDate;
- (NSInteger) daysAfterDate: (NSDate *) aDate;
- (NSInteger) daysBeforeDate: (NSDate *) aDate;
//dbs - NSDate is already a UTC value so there is no need for a separate method
//-(NSInteger)daysBeforeUTCDate:(NSDate*)aDate;

-(NSInteger)daysWithinEraToDate:(NSDate *)endDate inCalendar:(NSCalendar *)endCalendar thisCalendar:(NSCalendar *)startCalendar;

// Decomposing dates
@property (readonly) NSInteger nearestHour;
@property (readonly) NSInteger hour;
@property (readonly) NSInteger minute;
@property (readonly) NSInteger seconds;
@property (readonly) NSInteger day;
@property (readonly) NSInteger month;
@property (readonly) NSInteger week;
@property (readonly) NSInteger weekday;
@property (readonly) NSInteger nthWeekday; // e.g. 2nd Tuesday of the month == 2
@property (readonly) NSInteger year;
@end

@interface NSCalendar (Utilities)

+(NSCalendar*)utcCalendar;

@end
