//
//  DimensionView.h
//  InstrumentsTest
//
//  Created by Jim Geppert on 10/16/14.
//  Copyright (c) 2014 Summit Hill Software. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum {
    DimensionViewOrientationHorizontal = 0,
    DimensionViewOrientationVertical
} DimensionViewOrientation;

@interface DimensionView : UIView

@property (nonatomic) DimensionViewOrientation orientation;
@property (nonatomic, strong) UIColor* lineColor;
@property (nonatomic, strong) NSString* distanceDescription;
@property (nonatomic) BOOL includeEndMarks;

-(void)setTapHandler:(id) handler selector:(SEL) handlerSelector;

@end
