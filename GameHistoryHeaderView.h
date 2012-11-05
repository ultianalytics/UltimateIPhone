//
//  GameHistoryHeaderView.h
//  UltimateIPhone
//
//  Created by james on 11/5/12.
//  Copyright (c) 2012 Summit Hill Software. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GameHistoryHeaderView : UIView

@property (strong, nonatomic) NSString* pointName;
@property (strong, nonatomic) NSArray* finalLine;
@property (strong, nonatomic) NSArray* playerSubstitutions;

@property (strong, nonatomic) IBOutlet UILabel *currentPointLabel;
@property (strong, nonatomic) IBOutlet UILabel *scoreLabel;
@property (strong, nonatomic) IBOutlet UILabel *pointLabel;
@property (strong, nonatomic) IBOutlet UILabel *pointWinnerLabel;

@end
