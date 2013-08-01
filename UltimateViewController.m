//
//  UltimateViewController.m
//  UltimateIPhone
//
//  Created by james on 7/12/13.
//  Copyright (c) 2013 Summit Hill Software. All rights reserved.
//

#import "UltimateViewController.h"
#import "ColorMaster.h"

@interface UltimateViewController()

@end

@implementation UltimateViewController

-(void)viewDidLoad {
    [super viewDidLoad];
    self.edgesForExtendedLayout = UIRectEdgeBottom;
    self.extendedLayoutIncludesOpaqueBars = NO;
    self.view.window.tintColor = [ColorMaster applicationTintColor];
    self.navigationController.navigationBar.tintColor = nil;
}

@end

