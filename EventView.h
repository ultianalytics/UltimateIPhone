//
//  PlayerView.h
//  Ultimate
//
//  Created by james on 12/24/11.
//  Copyright (c) 2012 Summit Hill Software. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "IBView.h"
@class Event;

@interface EventView : IBView {
}
@property (nonatomic, strong) Event* event;
@property (nonatomic, strong) IBOutlet UILabel* eventDescriptionLabel;
@property (nonatomic, strong) IBOutlet UIImageView* eventImage;

-(void) updateEvent: (Event*) event;

@end
