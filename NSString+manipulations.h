//
//  NSString+manipulations.h
//  UltimateIPhone
//
//  Created by Jim Geppert on 5/29/12.
//  Copyright (c) 2012 Summit Hill Software. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (manipulations)

-(NSString*)trim;
-(BOOL)isNotEmpty;
-(NSDictionary*)toQueryStringParamaters;
-(NSString*)urlEncoded;
-(NSData*)asData;
-(BOOL)contains: (NSString*) anotherString;
+(NSString*)stringWithData: (NSData*)data;
+(NSString*)stringWithGuid;
-(BOOL)writeToTempDirectoryFile: (NSString*)fileName;
+(NSString*)readFromTempDirectoryFile: (NSString*)fileName;
+(BOOL)deleteFromTempDirectoryFile: (NSString*)fileName;

@end
