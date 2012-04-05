//
//  TeamPlayersViewController.h
//  UltimateIPhone
//
//  Created by Jim Geppert on 4/5/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TeamPlayersViewController : UIViewController <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) IBOutlet UITableView* playersTableView;

-(void)goToAddItem;

@end


