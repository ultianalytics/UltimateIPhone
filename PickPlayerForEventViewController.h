//
//  PickPlayerForEventViewController.h
//  UltimateIPhone
//
//  Created by Jim Geppert on 8/28/14.
//  Copyright (c) 2014 Summit Hill Software. All rights reserved.
//

#import <UIKit/UIKit.h>
@class Player;

@interface PickPlayerForEventViewController : UIViewController

@property (nonatomic, strong) NSArray* line;
@property (nonatomic, strong) NSString* instructions;
@property (strong, nonatomic) void (^doneRequestedBlock)(Player* player);
@property (nonatomic) BOOL allowCancel;

-(void)refresh;

@end
