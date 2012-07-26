//
//  ViewController.h
//  MultiViewControllerTest
//
//  Created by Jim Geppert on 5/4/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ViewController : UIViewController {
}

// 2 view panes on window
@property (nonatomic, strong) IBOutlet UIView *rightView;
@property (nonatomic, strong) IBOutlet UIView *leftView;

@end
