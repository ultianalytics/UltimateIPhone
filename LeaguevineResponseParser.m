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
#import "LeaguevineLeague.h"
#import "LeaguevineSeason.h"
#import "LeaguevineTeam.h"

#define kLeaguevineResponseMeta @"meta"
#define kLeaguevineResponseObjects @"objects"

@implementation LeaguevineResponseParser

#pragma mark Public methods

-(BOOL)hasMeta: (NSDictionary*) responseDict {
    return [responseDict hasJsonProperty:kLeaguevineResponseMeta];
}

-(LeaguevineResponseMeta*)parseMeta: (NSDictionary*) responseDict {
    return [LeaguevineResponseMeta fromJson: [responseDict objectForJsonProperty:kLeaguevineResponseMeta]];
}

-(NSMutableArray*)parseResults: (NSDictionary*) responseDict type: (LeaguevineResultType) type {
    switch(type) {
        case LeaguevineResultTypeLeagues:
            return [self parseResponseObjects: responseDict parse:(id)^(NSDictionary* objectDict){
                return [LeaguevineLeague fromJson:objectDict];
            }];
        case LeaguevineResultTypeSeasons:
            return [self parseResponseObjects: responseDict parse:(id)^(NSDictionary* objectDict){
                return [LeaguevineSeason fromJson:objectDict];
            }];
        case LeaguevineResultTypeTeams:
            return [self parseResponseObjects: responseDict parse:(id)^(NSDictionary* objectDict){
                return [LeaguevineTeam fromJson:objectDict];
            }];
        default:
            return [NSMutableArray array];
    }
}

#pragma mark Helper methods

-(NSMutableArray*)parseResponseObjects: (NSDictionary*) responseDict parse: (id(^)(NSDictionary* objectDict)) parseBlock {
    NSArray* jsonArray = [responseDict objectForKey:kLeaguevineResponseObjects];
    if (!jsonArray) {
        return [NSArray array];
    }
    NSMutableArray* objects = [[NSMutableArray alloc] init];
    for (NSDictionary* objectDict in jsonArray) {
        id obj = parseBlock(objectDict);
        if (obj) {
            [objects addObject:obj];
        }
    }
    return objects;
}

@end
