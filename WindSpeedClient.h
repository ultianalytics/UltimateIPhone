//
//  WindSpeedClient.h
//  UltimateIPhone
//
//  Created by Jim Geppert on 12/5/14.
//  Copyright (c) 2014 Summit Hill Software. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol WindSpeedClientDelegate <NSObject>

-(void)windSpeedUpdated;

@end

@interface WindSpeedClient : NSObject

+ (WindSpeedClient*)shared;

@property (nonatomic, readonly) float lastWindSpeedMph;
@property (nonatomic, weak) id<WindSpeedClientDelegate> delegate;

-(void)updateWindSpeed;
-(BOOL)hasWindSpeedBeenUpdatedRecently;

@end
