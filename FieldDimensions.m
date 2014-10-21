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

- (instancetype)init {
    self = [super init];
    if (self) {
        [self initializeDimensions];
    }
    return self;
}

+(instancetype)fieldWithType: (FieldDimensionType) type {
    FieldDimensions* fd = [[FieldDimensions alloc] init];
    fd.type = type;
    [fd initializeDimensions];
    return fd;
}

- (id)initWithCoder:(NSCoder *)decoder {
    if (self = [super init]) {
        self.type = [decoder decodeIntForKey:kFieldTypeKey];
        self.unitOfMeasure = [decoder decodeIntForKey:kFieldTypeUMKey];
        self.width = [decoder decodeFloatForKey:kFieldWidthKey];
        self.centralZoneLength = [decoder decodeFloatForKey:kFieldCentralZoneLengthKey];
        self.endZoneLength = [decoder decodeFloatForKey:kFieldEndZoneLengthKey];
        self.brickMarkDistance = [decoder decodeFloatForKey:kFieldBrickKey];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)encoder {
    [encoder encodeInt:self.type forKey:kFieldTypeKey];
    [encoder encodeInt:self.unitOfMeasure forKey:kFieldTypeUMKey];
    [encoder encodeFloat:self.width forKey:kFieldWidthKey];
    [encoder encodeFloat:self.centralZoneLength forKey:kFieldCentralZoneLengthKey];
    [encoder encodeFloat:self.endZoneLength forKey:kFieldEndZoneLengthKey];
    [encoder encodeFloat:self.brickMarkDistance forKey:kFieldBrickKey];
}

+(FieldDimensions*)fromDictionary:(NSDictionary*) dict {
    FieldDimensions* fd = [[FieldDimensions alloc] init];
    fd.type = [dict intForJsonProperty:kFieldTypeKey defaultValue:0];
    fd.unitOfMeasure = [dict intForJsonProperty:kFieldTypeUMKey defaultValue:0];
    fd.width = [dict floatForJsonProperty:kFieldWidthKey defaultValue:0];
    fd.centralZoneLength = [dict floatForJsonProperty:kFieldCentralZoneLengthKey defaultValue:0];
    fd.endZoneLength = [dict floatForJsonProperty:kFieldEndZoneLengthKey defaultValue:0];
    fd.brickMarkDistance = [dict floatForJsonProperty:kFieldBrickKey defaultValue:0];
    return fd;
}

-(NSDictionary*) asDictionary {
    NSMutableDictionary* dict = [[NSMutableDictionary alloc] init];
    [dict setValue: [NSNumber numberWithInt:self.type ] forKey:kFieldTypeKey];
    [dict setValue: [NSNumber numberWithInt:self.unitOfMeasure ] forKey:kFieldTypeUMKey];
    [dict setValue: [NSNumber numberWithFloat:self.width ] forKey:kFieldWidthKey];
    [dict setValue: [NSNumber numberWithFloat:self.centralZoneLength ] forKey:kFieldCentralZoneLengthKey];
    [dict setValue: [NSNumber numberWithFloat:self.endZoneLength ] forKey:kFieldEndZoneLengthKey];
    [dict setValue: [NSNumber numberWithFloat:self.brickMarkDistance ] forKey:kFieldBrickKey];
    return dict;
}

-(NSString*)name {
    switch (self.type) {
        case FieldDimensionTypeUPA: {
            return @"UPA Standard";
            break;
        }
        case FieldDimensionTypePRO: {
            return @"AUDL/MLU";
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
    NSString* width = (self.type == FieldDimensionTypePRO) ? @"53\u2153" : [NSString stringWithFormat:@"%d", (int)self.width];
    return [NSString stringWithFormat:@"%d%@ x %@%@ with %d%@ endzone", length, um, width, um, endzone, um];
}

-(NSString*)description {
    return self.type == FieldDimensionTypeOther ? [self dimensionsDescription] : self.name;
}

-(void)initializeDimensions {
    switch (self.type) {
        case FieldDimensionTypeUPA: {
            self.unitOfMeasure = FieldUnitOfMeasureYards;
            self.width = 40;
            self.centralZoneLength = 75;
            self.endZoneLength = 25;
            self.brickMarkDistance = 20;
            break;
        }
        case FieldDimensionTypePRO: {
            self.unitOfMeasure = FieldUnitOfMeasureYards;
            self.width = 53.33;
            self.centralZoneLength = 80;
            self.endZoneLength = 20;
            self.brickMarkDistance = 20;
            break;
        }
        case FieldDimensionTypeWFDF: {
            self.unitOfMeasure = FieldUnitOfMeasureMeters;
            self.width = 37;
            self.centralZoneLength = 64;
            self.endZoneLength = 18;
            self.brickMarkDistance = 18;
            break;
        }
        default: {
            self.unitOfMeasure = FieldUnitOfMeasureYards;
            self.width = 40;
            self.centralZoneLength = 75;
            self.endZoneLength = 25;
            self.brickMarkDistance = 20;
            break;
        }
    }
}

@end
