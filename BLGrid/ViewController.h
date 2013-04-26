//
//  ViewController.h
//  MultiViewControllerTest
//
//  Created by Jim Geppert on 7/26/12.
//

#import <UIKit/UIKit.h>

@interface ViewController : UIViewController {
}

// 2 view panes on window
@property (nonatomic, strong) IBOutlet UIView *rightView;
@property (nonatomic, strong) IBOutlet UIView *leftView;
@property (nonatomic, strong) IBOutlet UIView *toolbarView;

@end
