//
//  SubstitutionViewController.h
//  UltimateIPhone
//
//  Created by james on 11/2/12.
//  Copyright (c) 2012 Summit Hill Software. All rights reserved.
//

#import <UIKit/UIKit.h>
@class PlayerSubstitution;


@interface SubstitutionViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate, UIAlertViewDelegate>

@property (strong, nonatomic) NSArray *playersOnField;
@property (strong, nonatomic) PlayerSubstitution* playerSubstitution;
@property (strong, nonatomic) void (^completion)(PlayerSubstitution* substitution);

@end
