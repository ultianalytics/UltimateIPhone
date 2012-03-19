//
//  SignonViewDelegate.h
//  Ultimate
//
//  Created by Jim Geppert on 3/10/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol SignonViewDelegate <NSObject>

-(void) userSignedOn;
-(void) userCancelledSignedOn;

@end
