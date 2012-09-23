//
//  LeaguevineLeague.h
//  UltimateIPhone
//
//  Created by james on 9/21/12.
//  Copyright (c) 2012 Summit Hill Software. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LeaguevineItem.h"

@interface LeaguevineLeague : LeaguevineItem

@property (nonatomic, strong) NSString* gender;

+(LeaguevineLeague*)fromJson:(NSDictionary*) dict;

@end
