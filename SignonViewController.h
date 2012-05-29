//
//  SignonViewController.h
//  Ultimate
//
//  Created by Jim Geppert on 3/7/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SignonViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate> {
    @private
    NSArray* cells;
    UIAlertView* busyView;
}

@property (nonatomic) BOOL isSignedOn;

@property (nonatomic, strong) IBOutlet UITableViewCell* useridCell;
@property (nonatomic, strong) IBOutlet UITableViewCell* passwordCell;
@property (strong, nonatomic) IBOutlet UILabel *instructionsLabel;
@property (nonatomic, strong) IBOutlet UITextField* useridField;
@property (nonatomic, strong) IBOutlet UITextField* passwordField;
@property (nonatomic, strong) IBOutlet UILabel* errorMessage;

-(IBAction) signonButtonClicked: (id) sender;
-(IBAction) cancelButtonClicked: (id) sender;

-(void)startSignon;
-(void)startBusyDialog;
-(void)stopBusyDialog;

@end
