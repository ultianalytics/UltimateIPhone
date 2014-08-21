//
//  EventPosition.h
//  UltimateIPhone
//
//  Created by Jim Geppert on 8/21/14.
//  Copyright (c) 2014 Summit Hill Software. All rights reserved.
//

#import <Foundation/Foundation.h>

/* 
 a position's orientation is simply a way of handling the user flipping the view while recording events,
 i.e., he/she goes to the other side of the field to record
 */
typedef enum {
  EventOrientationNormal = 0,
  EventOrientationInverse
} EventOrientation;

@interface EventPosition : NSObject

/*
    x and y are relative factors on the field.
    .0 to 1.0 = a position within the normal field
    negative values are in one endzone (or out of bounds)
    likewise, values > 1.0 are in the other endzone (or out of bounds)
 */
@property (nonatomic) float x;
@property (nonatomic) float y;
@property (nonatomic) EventOrientation orientation;

+(EventPosition*)fromDictionary:(NSDictionary*) dict;
-(NSDictionary*) asDictionary;

@end
