//
//  TwitterNotDefinedViewControllerViewController.h
//  UltimateIPhone
//
//  Created by Jim Geppert on 6/13/12.
//  Copyright (c) 2012 Summit Hill Software. All rights reserved.
//

#import <UIKit/UIKit.h>

@class TwitterNotDefinedViewControllerViewController;

@protocol TwitterAccountVerifyDelegate <NSObject>

-(void)accountVerified: (TwitterNotDefinedViewControllerViewController *) controller ;

@end


@interface TwitterNotDefinedViewControllerViewController : UIViewController

@property (nonatomic, weak) id <TwitterAccountVerifyDelegate> delegate;

@end
