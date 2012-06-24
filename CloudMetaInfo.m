//
//  CloudMetaInfo.m
//  UltimateIPhone
//
//  Created by Jim Geppert on 6/24/12.
//  Copyright (c) 2012 Summit Hill Software. All rights reserved.
//

#import "CloudMetaInfo.h"

#define kIsAppVersionAcceptableKey @"appVersionAcceptable"
#define kMessageToUserKey @"messageToUser"

@implementation CloudMetaInfo
@synthesize isAppVersionAcceptable,messageToUser;

+(CloudMetaInfo*)fromDictionary:(NSDictionary*) dict {
    CloudMetaInfo* metaInfo = [[CloudMetaInfo alloc] init];
    NSNumber *isVersionAcceptable = [dict valueForKey:kIsAppVersionAcceptableKey];
    metaInfo.isAppVersionAcceptable = [isVersionAcceptable boolValue];  
    metaInfo.messageToUser = [dict valueForKey:kMessageToUserKey];
    return metaInfo;
}

@end
