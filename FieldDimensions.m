//
//  FieldDimensions.m
//  UltimateIPhone
//
//  Created by Jim Geppert on 10/13/14.
//  Copyright (c) 2014 Summit Hill Software. All rights reserved.
//

#import "FieldDimensions.h"

@implementation FieldDimensions

-(void)initWithType: (FieldDimensionType) type {
    switch (type) {
        case FieldDimensionTypeUPA: {
            self.type = FieldDimensionTypeUPA;
            self.unitOfMeasure = FieldUnitOfMeasureYards;
            self.width = 40;
            self.centralZoneLength = 75;
            self.endZoneLength = 25;
            self.brickMark = 20;
            break;
        }
        case FieldDimensionTypeAUDL: {
            self.type = FieldDimensionTypeAUDL;
            self.unitOfMeasure = FieldUnitOfMeasureYards;
            self.width = 53.33;
            self.centralZoneLength = 80;
            self.endZoneLength = 20;
            self.brickMark = 20;
            break;
        }
        case FieldDimensionTypeMLU: {
            self.type = FieldDimensionTypeMLU;
            self.unitOfMeasure = FieldUnitOfMeasureYards;
            self.width = 53.33;
            self.centralZoneLength = 80;
            self.endZoneLength = 20;
            self.brickMark = 20;
            break;
        }
        case FieldDimensionTypeWFDF: {
            self.type = FieldDimensionTypeMLU;
            self.unitOfMeasure = FieldUnitOfMeasureMeters;
            self.width = 37;
            self.centralZoneLength = 64;
            self.endZoneLength = 18;
            self.brickMark = 18;
            break;
        }
        default: {
            self.type = FieldDimensionTypeUPA;
            self.unitOfMeasure = FieldUnitOfMeasureYards;
            self.width = 40;
            self.centralZoneLength = 75;
            self.endZoneLength = 25;
            self.brickMark = 20;
            break;
        }
    }
}

-(NSString*)name {
    switch (self.type) {
        case FieldDimensionTypeUPA: {
            return @"UPA Standard";
            break;
        }
        case FieldDimensionTypeAUDL: {
            return @"AUDL";
            break;
        }
        case FieldDimensionTypeMLU: {
            return @"MLU";
            break;
        }
        case FieldDimensionTypeWFDF: {
            return @"WFDF Standard";
            break;
        }
        default: {
            return @"Other";
            break;
        }
    }
}

-(NSString*)dimensionsDescription {
    NSString* um = self.unitOfMeasure == FieldUnitOfMeasureMeters ? @"m" : @"y";
    int length = (int)self.centralZoneLength;
    int endzone = (int)self.endZoneLength;
    NSString* width = (self.type == FieldDimensionTypeMLU || self.type == FieldDimensionTypeAUDL) ? @"53\u2153" : [NSString stringWithFormat:@"%d", (int)self.width];
    return [NSString stringWithFormat:@"%d%@ x %@%@ with %d%@ endzone", length, um, width, um, endzone, um];
}

@end
