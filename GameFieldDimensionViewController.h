//
//  GameFieldDimensionViewController.h
//  UltimateIPhone
//
//  Created by Jim Geppert on 10/19/14.
//  Copyright (c) 2014 Summit Hill Software. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FieldDimensionsView.h"

@protocol GameFieldDimensionViewControllerDelegate <NSObject>

-(void)fieldDimensionControllerRequestsClose;

@end

@interface GameFieldDimensionViewController : UIViewController

@property (nonatomic) FieldDimensions* fieldDimensions;
@property (nonatomic) DimensionType dimensionType;
@property (nonatomic, weak) id<GameFieldDimensionViewControllerDelegate> delegate;

@end
