//
//  LeaguevineGame.h
//  UltimateIPhone
//
//  Created by james on 9/26/12.
//  Copyright (c) 2012 Summit Hill Software. All rights reserved.
//

#import "LeaguevineItem.h"

@interface LeaguevineGame : LeaguevineItem

@property (nonatomic, strong) NSDate* startTime;

+(LeaguevineGame*)fromJson:(NSDictionary*) dict;

@end

