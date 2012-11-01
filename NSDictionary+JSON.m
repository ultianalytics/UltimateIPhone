//
//  NSDictionary+JSON.m
//
//

#import "NSDictionary+JSON.h"

@implementation NSDictionary (JSON)

- (BOOL)hasJsonProperty:(NSString *)propertyName {
    return [self objectForJsonProperty:propertyName] != nil;
}

- (id)objectForJsonProperty:(NSString *)propertyName {
    return [self objectForJsonProperty:propertyName defaultValue:nil];
}

- (id)objectForJsonProperty:(NSString *)propertyName defaultValue: (id) defaultValue {
    id obj = [self objectForKey:propertyName];
    return obj == (id)[NSNull null] || obj == nil ? defaultValue : obj;
}

- (BOOL)boolForJsonProperty:(NSString *)propertyName defaultValue: (BOOL) defaultBool {
    id obj = [self objectForJsonProperty:propertyName];
    return obj == nil ? defaultBool : ((NSNumber*)obj).boolValue;
}

- (int)intForJsonProperty:(NSString *)propertyName defaultValue: (int) defaultInt {
    id obj = [self objectForJsonProperty:propertyName];
    return obj == nil ? defaultInt : ((NSNumber*)obj).intValue;
}

- (double)doubleForJsonProperty:(NSString *)propertyName defaultValue: (double) defaultDouble {
    id obj = [self objectForJsonProperty:propertyName];
    return obj == nil ? defaultDouble : ((NSNumber*)obj).doubleValue;
}

- (NSString *)stringForJsonProperty:(NSString *)propertyName {
    id obj = [self objectForJsonProperty:propertyName];
    return obj == nil ? nil : [obj isKindOfClass:[NSNumber class]] ? [NSString stringWithFormat:@"%d", ((NSNumber*)obj).intValue] : obj;
}

- (NSDate *)dateForJsonProperty:(NSString *)propertyName usingFormatter: (NSDateFormatter*) dateFormatter defaultDate: (NSDate*) defaultDate {
    NSString* dateAsString = [self stringForJsonProperty:propertyName];
    if (!dateAsString) {
        return defaultDate;
    }
    return [dateFormatter dateFromString:dateAsString];
}

@end
