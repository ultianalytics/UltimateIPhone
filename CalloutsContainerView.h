//
//  CalloutsContainerView.h
//  UltimateIPhone
//
//  Created by Jim Geppert on 6/23/12.
//  Copyright (c) 2012 Summit Hill Software. All rights reserved.
//

#import <UIKit/UIKit.h>
@class CalloutView;

@interface CalloutsContainerView : UIView

-(CalloutView*)addCallout:(NSString *) textToDisplay anchor: (CGPoint) anchorPoint width: (CGFloat) width degrees: (int) degreesFromAnchor connectorLength: (int) length;
-(CalloutView*)addCallout:(NSString *) textToDisplay anchor: (CGPoint) anchorPoint width: (CGFloat) width degrees: (int) degreesFromAnchor connectorLength: (int) length font: (UIFont *) font;
-(CalloutView*)addNavControllerHelpAvailableCallout;
-(void)slide: (BOOL) slideOut animated: (BOOL) animated;

@end
