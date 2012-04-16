//
//  Wind.h
//  Ultimate
//
//  Created by Jim Geppert on 2/18/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Wind : NSObject

@property (nonatomic) int mph;
@property (nonatomic) int directionDegrees;
@property (nonatomic) BOOL isFirstPullLeftToRight;

+(Wind*)fromDictionary:(NSDictionary*) dict;

-(BOOL)isSpecified;
-(NSDictionary*) asDictionary;

@end
