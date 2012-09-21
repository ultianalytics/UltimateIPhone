//
//  LeaguevineResponseParser.m
//  UltimateIPhone
//
//  Created by james on 9/21/12.
//  Copyright (c) 2012 Summit Hill Software. All rights reserved.
//

#import "LeaguevineResponseParser.h"
#import "NSDictionary+JSON.h"
#import "LeaguevineResponseMeta.h"

#define kLeaguevineResponseMeta @"meta"

@implementation LeaguevineResponseParser

-(BOOL)hasMeta: (NSDictionary*) responseDict {
    return [responseDict hasJsonProperty:kLeaguevineResponseMeta];
}

-(LeaguevineResponseMeta*)parseMeta: (NSDictionary*) responseDict {
    return [LeaguevineResponseMeta fromJson: [responseDict objectForJsonProperty:kLeaguevineResponseMeta]];
}

-(NSArray*)parseLeagues: (NSDictionary*) responseDict {
    return nil;
}

@end
