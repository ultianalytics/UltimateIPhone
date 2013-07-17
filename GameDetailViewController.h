//
//  GameDetailViewController.h
//  Ultimate
//
//  Created by Jim Geppert on 2/18/12.
//  Copyright (c) 2013 Summit Hill Software. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Game.h"
#import "UltimateViewController.h"

@interface GameDetailViewController : UltimateViewController <UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate, UIAlertViewDelegate> {

}

@property (nonatomic, strong) Game* game;



@end 
