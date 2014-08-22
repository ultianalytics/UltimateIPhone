//
//  GameFieldViewController.m
//  UltimateIPhone
//
//  Created by Jim Geppert on 8/22/14.
//  Copyright (c) 2014 Summit Hill Software. All rights reserved.
//

#import "GameFieldViewController.h"
#import "GameFieldView.h"

@interface GameFieldViewController ()

@property (nonatomic, strong) IBOutlet GameFieldView* fieldView;

@end

@implementation GameFieldViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
//    UIView* testView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 100, 100)];
//    testView.backgroundColor = [UIColor redColor];
//    [self.fieldView addSubview:testView];
//    UIView* testView2 = [[UIView alloc] initWithFrame:CGRectMake(-50, -50, 100, 100)];
//    testView2.backgroundColor = [UIColor blueColor];
//    [self.fieldView addSubview:testView2];
//    [self.view setNeedsDisplay];
}



@end
