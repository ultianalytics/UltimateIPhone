//
//  LeaguevineResponseMeta.m
//  UltimateIPhone
//
//  Created by james on 9/21/12.
//  Copyright (c) 2012 Summit Hill Software. All rights reserved.
//

#import "LeaguevineResponseMeta.h"
#import "NSDictionary+JSON.h"
#import "NSString+manipulations.h"

@implementation LeaguevineResponseMeta

#define LeaguevineResponseMetaLimit @"limit"
#define LeaguevineResponseMetaNext @"next"
#define LeaguevineResponseMetaOffset @"offset"
#define LeaguevineResponseMetaPrevious @"previous"
#define LeaguevineResponseMetaTotalCount @"total_count"

+(LeaguevineResponseMeta*)fromJson:(NSDictionary*) dict {
    if (dict) {
        LeaguevineResponseMeta* meta = [[LeaguevineResponseMeta alloc] init];
        meta.limit = [dict intForJsonProperty:LeaguevineResponseMetaLimit defaultValue:0];
        meta.offset = [dict intForJsonProperty:LeaguevineResponseMetaOffset defaultValue:0];
        meta.totalCount = [dict intForJsonProperty:LeaguevineResponseMetaTotalCount defaultValue:0];
        meta.nextUrl = [dict stringForJsonProperty:LeaguevineResponseMetaNext];
        meta.previousUrl = [dict stringForJsonProperty:LeaguevineResponseMetaPrevious];
        return meta;
    } else {
        return nil;
    }
}

-(BOOL)hasMoreResults {
    return [self.nextUrl isNotEmpty];
}

@end
