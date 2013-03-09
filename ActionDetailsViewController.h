//
//  ActionDetailsViewController.h
//  UltimateIPhone
//
//  Created by james on 3/3/13.
//  Copyright (c) 2013 Summit Hill Software. All rights reserved.
//

#import <UIKit/UIKit.h>
@class Event;

@interface ActionDetailsViewController : UIViewController

@property (strong, nonatomic) NSString* description;
@property (strong, nonatomic) void (^saveBlock)(Event* eventChosen);
@property (strong, nonatomic) void (^cancelBlock)();

-(void)setCandidateEvents:(NSArray *)candidateEvents initialChosen: (Event*) chosenEvent;

@end
