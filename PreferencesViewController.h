//
//  PreferencesViewController.h
//  Ultimate
//
//  Created by Jim Geppert on 2/17/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
@class GTMOAuthAuthentication;

@interface PreferencesViewController : UIViewController <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) IBOutlet UITableView* preferencesTableView;

-(void)populateViewFromModel;

@end
