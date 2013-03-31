//
//  UniqueTimestampGenerator.h
//  UltimateIPhone
//
//  Created by james on 3/30/13.
//  Copyright (c) 2013 Summit Hill Software. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UniqueTimestampGenerator : NSObject

+ (UniqueTimestampGenerator*)sharedGenerator;

-(NSTimeInterval)uniqueTimeIntervalSinceReferenceDateSeconds;

@end
