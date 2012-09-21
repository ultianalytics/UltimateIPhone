//
//  LeaguevineResponseParser.h
//  UltimateIPhone
//
//  Created by james on 9/21/12.
//  Copyright (c) 2012 Summit Hill Software. All rights reserved.
//

#import <Foundation/Foundation.h>
@class LeaguevineResponseMeta;



@interface LeaguevineResponseParser : NSObject

-(BOOL)hasMeta: (NSDictionary*) responseDict;
-(LeaguevineResponseMeta*)parseMeta: (NSDictionary*) responseDict;
-(NSArray*)parseLeagues: (NSDictionary*) responseDict;

@end
