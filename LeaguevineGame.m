//
//  LeaguevineGame.m
//  UltimateIPhone
//
//  Created by james on 9/26/12.
//  Copyright (c) 2012 Summit Hill Software. All rights reserved.
//

#import "LeaguevineGame.h"
#import "NSDictionary+JSON.h"

#define kLeaguevineGameStartTime @"start_date"

@implementation LeaguevineGame

+(LeaguevineGame*)fromJson:(NSDictionary*) dict {
    if (dict) {
        LeaguevineGame* game = [[LeaguevineGame alloc] init];
        [game populateFromJson:dict];
        return game;
    } else {
        return nil;
    }
}

-(void)populateFromJson:(NSDictionary*) dict {
    if (dict) {
        [super populateFromJson:dict];
        NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"yyyy-MM-ddEHH:mm:ssZ"];
        self.startTime = [dict dateForJsonProperty:kLeaguevineGameStartTime usingFormatter: dateFormatter defaultDate: nil];
    }
}

@end

