//
//  LeaguevineLeague.h
//  UltimateIPhone
//
//  Created by james on 9/21/12.
//  Copyright (c) 2012 Summit Hill Software. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LeaguevineLeague : NSObject

@property (nonatomic) int leagueId;
@property (nonatomic, strong) NSString* name;
@property (nonatomic, strong) NSString* gender;

+(LeaguevineLeague*)fromJson:(NSDictionary*) dict;

@end
