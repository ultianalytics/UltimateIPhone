//
//  GameDetailViewController.h
//  Ultimate
//
//  Created by Jim Geppert on 2/18/12.
//  Copyright (c) 2012 Summit Hill Software. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Game.h"

@interface GameDetailViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate, UIAlertViewDelegate> {

}

@property (nonatomic, strong) Game* game;



@end 
