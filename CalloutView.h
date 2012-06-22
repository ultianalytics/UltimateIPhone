//
//  CalloutView.h
//
//  Created by Jim Geppert on 6/18/12.
//  Copyright (c) 2012 Summit Hill Software. All rights reserved.
//

#import <UIKit/UIKit.h>

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

// init the callout.  Position at degrees (0-360) relative to the anchor at length from the anchor (length is calculated from the middle of the callout to the connector). 
- (id)initWithFrame:(CGRect)frame text:(NSString *) textToDisplay anchor: (CGPoint) anchorPoint width: (CGFloat) width degrees: (int) degreesFromAnchor connectorLength: (int) length;

@end
