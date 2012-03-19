//
//  GameViewSwitcherController.h
//  Ultimate
//
//  Created by james on 12/26/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GameViewSwitcherController : UIViewController {
    
}
@property (nonatomic, strong) UIViewController* currentViewController;

-(void)switchActiveContoller: (Class) controllerClass;
-(void)switchActiveControllerAnimated: (Class) controllerClass transition: (UIViewAnimationTransition) transition;

@end
