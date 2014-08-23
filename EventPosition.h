//
//  EventPosition.h
//  UltimateIPhone
//
//  Created by Jim Geppert on 8/21/14.
//  Copyright (c) 2014 Summit Hill Software. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum {
    EventPositionAreaField = 0,
    EventPositionArea0Endzone,
    EventPositionArea100Endzone
} EventPositionArea;

@interface EventPosition : NSObject

/*
    x and y are relative factors on the field.
 */
@property (nonatomic) float x;
@property (nonatomic) float y;
@property (nonatomic) BOOL inverted; //  a position's "inverted" is simply a way of handling the user flipping the view while recording events, i.e., he/she goes to the other side of the field to record
@property (nonatomic) EventPositionArea area;

+(EventPosition*)positionInArea: (EventPositionArea) area x: (CGFloat)x y: (CGFloat)y inverted: (BOOL)isInverted;
+(EventPosition*)fromDictionary:(NSDictionary*) dict;
-(NSDictionary*) asDictionary;

@end
