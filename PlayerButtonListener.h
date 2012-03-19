//
//  PlayerButtonListener.h
//  Ultimate
//
//  Created by james on 1/28/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol PlayerButtonListener <NSObject>

- (void) buttonClicked: (id)playerButton isOnField: (BOOL) isOnField;

@end
