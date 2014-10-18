//
//  FieldDimensions.m
//  UltimateIPhone
//
//  Created by Jim Geppert on 10/13/14.
//  Copyright (c) 2014 Summit Hill Software. All rights reserved.
//

#import "FieldDimensions.h"
#import "NSDictionary+JSON.h"

#define kFieldTypeKey               @"type"
#define kFieldTypeUMKey             @"um"
#define kFieldWidthKey              @"width"
#define kFieldCentralZoneLengthKey  @"centralZoneLength"
#define kFieldEndZoneLengthKey      @"endzone"
#define kFieldBrickKey              @"brick"

@implementation FieldDimensions

+(instancetype)fieldWithType: (FieldDimensionType) type {
    
    FieldDimensions* fd = [[FieldDimensions alloc] init];

    switch (type) {
        case FieldDimensionTypeUPA: {
            fd.type = FieldDimensionTypeUPA;
            fd.unitOfMeasure = FieldUnitOfMeasureYards;
            fd.width = 40;
            fd.centralZoneLength = 75;
            fd.endZoneLength = 25;
            fd.brickMarkDistance = 20;
            break;
        }
        case FieldDimensionTypeAUDL: {
            fd.type = FieldDimensionTypeAUDL;
            fd.unitOfMeasure = FieldUnitOfMeasureYards;
            fd.width = 53.33;
            fd.centralZoneLength = 80;
            fd.endZoneLength = 20;
            fd.brickMarkDistance = 20;
            break;
        }
        case FieldDimensionTypeMLU: {
            fd.type = FieldDimensionTypeMLU;
            fd.unitOfMeasure = FieldUnitOfMeasureYards;
            fd.width = 53.33;
            fd.centralZoneLength = 80;
            fd.endZoneLength = 20;
            fd.brickMarkDistance = 20;
            break;
        }
        case FieldDimensionTypeWFDF: {
            fd.type = FieldDimensionTypeMLU;
            fd.unitOfMeasure = FieldUnitOfMeasureMeters;
            fd.width = 37;
            fd.centralZoneLength = 64;
            fd.endZoneLength = 18;
            fd.brickMarkDistance = 18;
            break;
        }
        default: {
            fd.type = FieldDimensionTypeUPA;
            fd.unitOfMeasure = FieldUnitOfMeasureYards;
            fd.width = 40;
            fd.centralZoneLength = 75;
            fd.endZoneLength = 25;
            fd.brickMarkDistance = 20;
            break;
        }
    }
    return fd;
}

- (id)initWithCoder:(NSCoder *)decoder {
    if (self = [super init]) {
        self.type = [decoder decodeIntForKey:kFieldTypeKey];
        self.unitOfMeasure = [decoder decodeIntForKey:kFieldTypeUMKey];
        self.width = [decoder decodeIntForKey:kFieldWidthKey];
        self.centralZoneLength = [decoder decodeIntForKey:kFieldCentralZoneLengthKey];
        self.endZoneLength = [decoder decodeIntForKey:kFieldEndZoneLengthKey];
        self.brickMarkDistance = [decoder decodeIntForKey:kFieldBrickKey];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)encoder {
    [encoder encodeInt:self.type forKey:kFieldTypeKey];
    [encoder encodeInt:self.unitOfMeasure forKey:kFieldTypeUMKey];
    [encoder encodeInt:self.width forKey:kFieldWidthKey];
    [encoder encodeInt:self.centralZoneLength forKey:kFieldCentralZoneLengthKey];
    [encoder encodeInt:self.endZoneLength forKey:kFieldEndZoneLengthKey];
    [encoder encodeInt:self.brickMarkDistance forKey:kFieldBrickKey];
}

+(FieldDimensions*)fromDictionary:(NSDictionary*) dict {
    FieldDimensions* fd = [[FieldDimensions alloc] init];
    fd.type = [dict intForJsonProperty:kFieldTypeKey defaultValue:0];
    fd.unitOfMeasure = [dict intForJsonProperty:kFieldTypeUMKey defaultValue:0];
    fd.width = [dict intForJsonProperty:kFieldWidthKey defaultValue:0];
    fd.centralZoneLength = [dict intForJsonProperty:kFieldCentralZoneLengthKey defaultValue:0];
    fd.endZoneLength = [dict intForJsonProperty:kFieldEndZoneLengthKey defaultValue:0];
    fd.brickMarkDistance = [dict intForJsonProperty:kFieldBrickKey defaultValue:0];
    return fd;
}

-(NSDictionary*) asDictionary {
    NSMutableDictionary* dict = [[NSMutableDictionary alloc] init];
    [dict setValue: [NSNumber numberWithInt:self.type ] forKey:kFieldTypeKey];
    [dict setValue: [NSNumber numberWithInt:self.unitOfMeasure ] forKey:kFieldTypeUMKey];
    [dict setValue: [NSNumber numberWithInt:self.width ] forKey:kFieldWidthKey];
    [dict setValue: [NSNumber numberWithInt:self.centralZoneLength ] forKey:kFieldCentralZoneLengthKey];
    [dict setValue: [NSNumber numberWithInt:self.endZoneLength ] forKey:kFieldEndZoneLengthKey];
    [dict setValue: [NSNumber numberWithInt:self.brickMarkDistance ] forKey:kFieldBrickKey];
    return dict;
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

-(NSString*)description {
    return self.type == FieldDimensionTypeOther ? [self dimensionsDescription] : self.name;
}

@end
