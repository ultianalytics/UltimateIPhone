//
//  SignonViewController.h
//  Ultimate
//
//  Created by Jim Geppert on 3/7/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol SignonViewControllerDelegate <NSObject>

-(void)dismissSignonController:(BOOL) isSignedOn;

@end


@interface SignonViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate> {
    @private
    NSArray* cells;
    UIAlertView* busyView;
}

@property (nonatomic, weak) id<SignonViewControllerDelegate> delegate;

@property (nonatomic, strong) IBOutlet UITableViewCell* useridCell;
@property (nonatomic, strong) IBOutlet UITableViewCell* passwordCell;
@property (strong, nonatomic) IBOutlet UILabel *instructionsLabel;
@property (nonatomic, strong) IBOutlet UITextField* useridField;
@property (nonatomic, strong) IBOutlet UITextField* passwordField;
@property (nonatomic, strong) IBOutlet UILabel* errorMessage;

-(IBAction) signonButtonClicked: (id) sender;
-(IBAction) cancelButtonClicked: (id) sender;

@end
