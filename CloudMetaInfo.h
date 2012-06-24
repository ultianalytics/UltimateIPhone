//
//  CloudMetaInfo.h
//  UltimateIPhone
//
//  Created by Jim Geppert on 6/24/12.
//  Copyright (c) 2012 Summit Hill Software. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CloudMetaInfo : NSObject

@property (nonatomic) BOOL isAppVersionAcceptable;
@property (nonatomic) NSString *messageToUser;

+(CloudMetaInfo*)fromDictionary:(NSDictionary*) dict;

@end
