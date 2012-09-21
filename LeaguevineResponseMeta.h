//
//  LeaguevineResponseMeta.h
//  UltimateIPhone
//
//  Created by james on 9/21/12.
//  Copyright (c) 2012 Summit Hill Software. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface LeaguevineResponseMeta : NSObject

@property (nonatomic)  int limit;
@property (nonatomic)  int offset;
@property (nonatomic)  int totalCount;
@property (nonatomic, strong)  NSString* nextUrl;
@property (nonatomic, strong)  NSString* previousUrl;

+(LeaguevineResponseMeta*)fromJson:(NSDictionary*) dict;

@end
