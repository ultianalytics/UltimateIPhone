//
//  NSDate+Formatting.m
//  UltimateIPhone
//
//  Copyright (c) 2014 Summit Hill Software. All rights reserved.
//

#import "NSDate+Formatting.h"

#define ISO8601DateFormat @"yyyy-MM-dd'T'HH:mm:ssZZZZZ"

@implementation NSDate (Formatting)


+(NSDate*)dateFromUtcString:(NSString*)utcFormatted8601Timestamp {
    return [[self dateFormatterISO8601utc] dateFromString:utcFormatted8601Timestamp];
}

+(NSDateFormatter*)dateFormatterISO8601 {
    NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:ISO8601DateFormat];
    return dateFormatter;
}

+(NSDateFormatter*)dateFormatterISO8601utc {
    NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
    NSTimeZone *timeZone = [NSTimeZone timeZoneForSecondsFromGMT:0];
    [dateFormatter setTimeZone:timeZone];
    [dateFormatter setDateFormat:ISO8601DateFormat];
    return dateFormatter;
}

-(NSString*)utcString {
    return [[[self class] dateFormatterISO8601utc] stringFromDate:self];
}


@end
