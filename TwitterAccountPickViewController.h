//
//  TwitterAccountPickViewController.h
//  UltimateIPhone
//
//  Created by Jim Geppert on 3/28/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TwitterAccountPickViewController : UIViewController <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) IBOutlet UITableView* acctNamesTableView;
@property (nonatomic, strong) NSArray* accountNames;

@end
