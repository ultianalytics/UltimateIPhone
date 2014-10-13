//
//  FieldDimensions.h
//  UltimateIPhone
//
//  Created by Jim Geppert on 10/13/14.
//  Copyright (c) 2014 Summit Hill Software. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum {
    FieldDimensionTypeUPA = 0,
    FieldDimensionTypeAUDL,
    FieldDimensionTypeMLU,
    FieldDimensionTypeWFDF,
    FieldDimensionTypeOther
} FieldDimensionType;

typedef enum {
    FieldUnitOfMeasureYards = 0,
    FieldUnitOfMeasureMeters
} FieldUnitOfMeasure;

@interface FieldDimensions : NSObject

@property (nonatomic) FieldDimensionType type;
@property (nonatomic) FieldUnitOfMeasure unitOfMeasure;
@property (nonatomic) float width;
@property (nonatomic) float centralZoneLength; // exclusive of endzone
@property (nonatomic) float endZoneLength;
@property (nonatomic) float brickMark;

-(void)initWithType: (FieldDimensionType) type;

@end
