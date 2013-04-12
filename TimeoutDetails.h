//
//  TimeoutDetails.h
//  UltimateIPhone
//
//  Created by james on 4/11/13.
//  Copyright (c) 2013 Summit Hill Software. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TimeoutDetails : NSObject

@property (nonatomic) int quotaPerHalf;
@property (nonatomic) int quotaFloaters;
@property (nonatomic) int takenFirstHalf;
@property (nonatomic) int takenSecondHalf;

+(TimeoutDetails*)fromDictionary:(NSDictionary*) dict;
-(NSDictionary*) asDictionary;

@end
