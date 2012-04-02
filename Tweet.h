//
//  Tweet.h
//  UltimateIPhone
//
//  Created by Jim Geppert on 3/29/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
@class ACAccount;

@interface Tweet : NSObject

@property (nonatomic, strong) NSString* message;
@property (nonatomic, strong) NSString* type;
@property (nonatomic, strong) NSString* undoMessage;

-(id) initMessage: (NSString*) aMessage type: (NSString*)type;
@end
