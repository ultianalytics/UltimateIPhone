//
//  NSDictionary+JSON.h
//

#import <Foundation/Foundation.h>

@interface NSDictionary (JSON)

-(BOOL)hasJsonProperty:(NSString *)propertyName;
-(id)objectForJsonProperty:(NSString *)propertyName;
-(id)objectForJsonProperty:(NSString *)propertyName defaultValue: (id) defaultValue;
-(BOOL)boolForJsonProperty:(NSString *)propertyName defaultValue: (BOOL) defaultBool;
-(int)intForJsonProperty:(NSString *)propertyName defaultValue: (int) defaultInt;
-(NSString*)stringForJsonProperty:(NSString *)propertyName;
-(NSDate *)dateForJsonProperty:(NSString *)propertyName usingFormatter: (NSDateFormatter*) dateFormatter defaultDate: (NSDate*) defaultDate;

@end
