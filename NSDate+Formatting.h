//
//  NSDate+Formatting.h
//  UltimateIPhone
//
//  Copyright (c) 2014 Summit Hill Software. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDate (Formatting)

+(NSDate*)dateFromUtcString:(NSString*)utcFormatted8601Timestamp;
+(NSDateFormatter*)dateFormatterISO8601;
+(NSDateFormatter*)dateFormatterISO8601utc;
-(NSString*)utcString;

@end
