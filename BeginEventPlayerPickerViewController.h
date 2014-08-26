//
//  BeginEventPlayerPickerViewController.h
//  UltimateIPhone
//
//  Created by Jim Geppert on 8/26/14.
//  Copyright (c) 2014 Summit Hill Software. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Player.h"

@interface BeginEventPlayerPickerViewController : UIViewController

@property (nonatomic, strong) NSArray* line;
@property (nonatomic, strong) NSString* instructions;
@property (strong, nonatomic) void (^doneRequestedBlock)(Player* player);

-(void)refresh;

@end
