//
//  SHSVersion.m
//  UltimateIPhone
//
//  Created by Jim Geppert on 11/3/14.
//  Copyright (c) 2014 Summit Hill Software. All rights reserved.
//

#import "SHSVersion.h"

@interface SHSVersion ()

@property (nonatomic, strong) NSString* currentAppVersion;
@property (nonatomic, strong) NSString* currentAppVersionMajor;
@property (nonatomic, strong) NSString* currentAppBuild;

@end

@implementation SHSVersion

static SHSVersion *sharedShsVersion = nil;

+ (SHSVersion *)sharedInstance {
    if (nil != sharedShsVersion) {
        return sharedShsVersion;
    }
    
    static dispatch_once_t pred;
    dispatch_once(&pred, ^{
        sharedShsVersion = [[SHSVersion alloc] init];
    });
    
    return sharedShsVersion;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        self.currentAppVersion = [[NSBundle mainBundle] objectForInfoDictionaryKey: @"CFBundleShortVersionString"];
        self.currentAppBuild = [[NSBundle mainBundle] objectForInfoDictionaryKey: (NSString *)kCFBundleVersionKey];
    }
    return self;
}

@end
