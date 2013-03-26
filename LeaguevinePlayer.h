//
//  LeaguevinePlayer.h
//  UltimateIPhone
//
//  Created by james on 3/26/13.
//  Copyright (c) 2013 Summit Hill Software. All rights reserved.
//

#import "LeaguevineItem.h"

@interface LeaguevinePlayer : NSObject

@property (nonatomic) int playerId;
@property (nonatomic, strong) NSString* firstName;
@property (nonatomic, strong) NSString* lastName;
@property (nonatomic, strong) NSString* nickname;
@property (nonatomic) int number;

+(LeaguevinePlayer*)fromJson:(NSDictionary*) dict;

@end
