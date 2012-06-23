//
//  CalloutView.h
//
//  Created by Jim Geppert on 6/18/12.
//  Copyright (c) 2012 Summit Hill Software. All rights reserved.
//

#import <UIKit/UIKit.h>

#define CGPointTop(rect) CGPointMake(CGRectGetMidX(rect), CGRectGetMinY(rect))
#define CGPointBottom(rect) CGPointMake(CGRectGetMidX(rect), CGRectGetMaxY(rect))
#define CGPointRight(rect) CGPointMake(CGRectGetMaxX(rect), CGRectGetMidY(rect))
#define CGPointLeft(rect) CGPointMake(CGRectGetMinX(rect), CGRectGetMinY(rect))

#define CGPointMid(rect) CGPointMake(CGRectGetMidX(rect), CGRectGetMidY(rect))

#define CGPointTopRight(rect) CGPointMake(CGRectGetMaxX(rect), CGRectGetMinY(rect))
#define CGPointTopLeft(rect) CGPointMake(CGRectGetMinX(rect), CGRectGetMinY(rect))
#define CGPointBottomRight(rect) CGPointMake(CGRectGetMaxX(rect), CGRectGetMaxY(rect))
#define CGPointBottomLeft(rect) CGPointMake(CGRectGetMinX(rect), CGRectGetMaxY(rect))

/*

 This view provides a visual "callout" useful for providing instructions to 
 a user on particular screen component.  It is implenented as a popup with text.
 The popup sizes itself to fit the text provided (although width must be specified).
 
 The caller can set the underlying UITextView if they want more control over styling.  If this
 property is set AND it has text then it will override any (if any) text provided on the init method. The frame
 set on the UITextView is overridden.
 
*/

@interface CalloutView : UIView

@property (nonatomic, strong) UIColor *borderColor;
@property (nonatomic, strong) UITextView *textView;
@property (nonatomic) BOOL useShadow;
@property (nonatomic, strong) UIFont *fontOverride;


// init the callout.  The frame is generarlly the bounds of the view that contains the view with the anchor point.  Position at degrees (0-360) relative to the anchor at length from the anchor (length is calculated from the middle of the callout to the connector). 
- (id)initWithFrame:(CGRect)frame text:(NSString *) textToDisplay anchor: (CGPoint) anchorPoint width: (CGFloat) width degrees: (int) degreesFromAnchor connectorLength: (int) length;

@end
