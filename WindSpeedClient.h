//
//  WindSpeedClient.h
//  UltimateIPhone
//
//  Created by Jim Geppert on 12/5/14.
//  Copyright (c) 2014 Summit Hill Software. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WindSpeedClient : NSObject

+ (WindSpeedClient*)shared;

@property (nonatomic, strong, readonly) NSDate* windLastUpdatedTimestamp;
@property (nonatomic, readonly) float lastWindSpeedMph;

-(void)updateWindSpeed;

@end
