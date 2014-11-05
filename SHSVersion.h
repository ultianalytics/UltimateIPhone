//
//  SHSVersion.h
//  UltimateIPhone
//
//  Created by Jim Geppert on 11/3/14.
//  Copyright (c) 2014 Summit Hill Software. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SHSVersion : NSObject

@property (readonly) NSString* currentAppVersion;
@property (readonly) NSString* currentAppBuild;

+ (SHSVersion *)sharedInstance;

@end
