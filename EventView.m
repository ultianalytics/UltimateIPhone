//
//  PlayerView.m
//  Ultimate
//
//  Created by james on 12/24/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "EventView.h"
#import "AnonymousPlayer.h"
#import "ImageMaster.h"

@implementation EventView
@synthesize event,eventDescriptionLabel,eventImage;

-(void)initUI {
    [self updateEvent:nil];
}

-(void) updateEvent: (Event*) anEvent {
    if (anEvent == nil) {
        self.hidden = YES;
    } else {
        self.event = anEvent;
        self.eventImage.image = [ImageMaster getImageForEvent:event];
        self.eventDescriptionLabel.text = [NSString stringWithFormat:@" %@",[event getDescription]];
        self.hidden = NO;
    }
}

@end
