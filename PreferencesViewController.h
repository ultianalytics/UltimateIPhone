//
//  PreferencesViewController.h
//  Ultimate
//
//  Created by Jim Geppert on 2/17/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PreferencesViewController : UIViewController <UITableViewDelegate, UITableViewDataSource> {
    @private
    NSArray* preferencesCells;
}

@property (nonatomic, strong) IBOutlet UITableView* preferencesTableView;

-(void)populateViewFromModel;

@end
