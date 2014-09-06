//
//  CalloutView.m
//
//  Created by Jim Geppert on 6/18/12.
//  Copyright (c) 2012 Summit Hill Software. All rights reserved.
//

#import "CalloutView.h"
#import "ColorMaster.h"
#import <QuartzCore/QuartzCore.h>

#define radians(x) ((x) * M_PI/180 )

#define kTextViewContentSizeTopInset 2.f
#define kTextViewContentSizeBottomInset 2.f
#define kPaddingHorizontal 2.f
#define kPaddingVertical 2.f
#define kBorderWidth 4.f
#define kRoundedCornerRadius 4.f  
#define kConnectorLineBaseWidthDefault 60.f
#define kShadowOffset 4.f

@interface CalloutView()

@property (nonatomic, strong) NSString *text;
@property (nonatomic) CGFloat widthConstraint;
@property (nonatomic) int degreesFromNorth;
@property (nonatomic) CGPoint anchor;
@property (nonatomic) int connectorLength;
@property (nonatomic) int connectorLineBaseWidth;

@end

@implementation CalloutView
@synthesize textLabel, text, widthConstraint, degreesFromNorth, anchor, connectorLength, connectorLineBaseWidth, borderColor, useShadow, fontOverride,calloutColor;

- (id)initWithFrame:(CGRect)frame text:(NSString *) textToDisplay anchor: (CGPoint) anchorPoint width: (CGFloat) width degrees: (int) degreesFromAnchor connectorLength: (int) length {
    self = [super initWithFrame:frame];
    if (self) {
        self.text = textToDisplay;
        self.anchor = anchorPoint;
        self.widthConstraint = width;
        self.degreesFromNorth = degreesFromAnchor < 0 ? 360 - ((degreesFromAnchor * -1) % 360) : degreesFromAnchor;
        self.connectorLength = length;
        self.calloutColor = [ColorMaster applicationTintColor];
        self.borderColor = [ColorMaster applicationTintColor];
        self.useShadow = YES;
        self.connectorLineBaseWidth = kConnectorLineBaseWidthDefault;
        
        self.opaque = NO;
        
    }
    return self;
}

-(void)layoutSubviews {
    [super layoutSubviews];
    // add text view
    [self addTextView];
    // position text view
    [self positionTextView];
}

-(CGSize)addTextView {
    if (self.textLabel == nil) {
        self.textLabel = [[UILabel alloc] init];
        self.textLabel.backgroundColor = self.calloutColor;
        self.textLabel.textColor = [UIColor whiteColor];
        if (fontOverride) {
            self.textLabel.font = fontOverride;
        }
        self.textLabel.text = self.text;
    } else {
        if (![self.textLabel.text length]) {
            self.textLabel.text = self.text;
        }
    }
    self.textLabel.numberOfLines = 0;
    self.textLabel.lineBreakMode = NSLineBreakByWordWrapping;    
    // setup constraints and then find size
    CGFloat textLabelHorizontalInset = kPaddingHorizontal + kBorderWidth;
    CGFloat textLabelWidth = self.widthConstraint - (textLabelHorizontalInset * 2);
    CGFloat textLabelHeight = [self preferredLabelHeightForWidth:textLabelWidth];
    textLabelHeight = textLabelHeight + kTextViewContentSizeBottomInset + kTextViewContentSizeTopInset;
    self.textLabel.frame = CGRectMake(0,0, textLabelWidth, textLabelHeight);
    self.textLabel.frame = CGRectIntegral(self.textLabel.frame);
    [self addSubview:self.textLabel];
    [self calcConnectorLineBaseWidth];
    return CGSizeMake(textLabelWidth, textLabelHeight);
}

-(CGFloat)preferredLabelHeightForWidth: (CGFloat)preferredWidth {
    CGSize maxSize = CGSizeMake(preferredWidth, FLT_MAX);
    CGFloat preferredHeight = [self.textLabel.attributedText boundingRectWithSize:maxSize options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading context:nil].size.height;
    return ceilf(preferredHeight);
}

-(void)positionTextView {
    CGPoint midPoint = [self calcPointOnCirle:self.anchor radius:self.connectorLength degrees:self.degreesFromNorth];
    self.textLabel.center = midPoint;
    self.textLabel.frame = CGRectIntegral(self.textLabel.frame);
}

-(CGPoint)calcPointOnCirle: (CGPoint) centerPoint radius: (float) radius degrees: (float) degrees {
    CGFloat radians = radians(degrees + 270);  // need to add 90 degrees for this calc
    return CGPointMake(centerPoint.x + round(radius * cos(radians)), centerPoint.y + round(radius * sin(radians)));
}

-(void)calcConnectorLineBaseWidth {
    CGSize textLabelSize = self.textLabel.bounds.size;
    self.connectorLineBaseWidth = MIN(self.connectorLineBaseWidth, MIN(textLabelSize.width, textLabelSize.height));
}

- (void)drawRect:(CGRect)rect {
    CGFloat verticalInset = kPaddingVertical  + kBorderWidth / 2;
    CGFloat horizontalInset = kPaddingHorizontal  + kBorderWidth / 2;
    CGRect bubbleRect = CGRectInset(self.textLabel.frame, -1 * horizontalInset, -1 * verticalInset);
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSaveGState(context);
    CGContextSetFillColorWithColor(context, self.textLabel ? self.textLabel.backgroundColor.CGColor : self.calloutColor.CGColor);
    CGContextSetStrokeColorWithColor(context, borderColor.CGColor);
    CGContextSetLineWidth(context, kBorderWidth);
    CGContextSetLineJoin(context, kCGLineJoinRound);
    CGContextSetShouldAntialias(context, true);
    if (useShadow) {
        CGContextSetShadow(context, CGSizeMake(kShadowOffset, kShadowOffset),5.0f); 
    }
    
    [self drawPath:context bubbleRect:bubbleRect];
    CGContextStrokePath(context);

    [self drawPath:context bubbleRect:bubbleRect];
    CGContextFillPath(context);
    
    CGContextRestoreGState(context);
}

- (void)drawPath:(CGContextRef) context bubbleRect: (CGRect) bubbleRect  {
    // draw the text bubble with rounded corners
    CGFloat radius = 5.0f;
    CGContextMoveToPoint(context, CGRectGetMinX(bubbleRect) + radius, CGRectGetMinY(bubbleRect));
    CGContextAddArc(context, CGRectGetMaxX(bubbleRect) - radius, CGRectGetMinY(bubbleRect) + radius, radius, 3 * M_PI / 2, 0, 0);
    CGContextAddArc(context, CGRectGetMaxX(bubbleRect) - radius, CGRectGetMaxY(bubbleRect) - radius, radius, 0, M_PI / 2, 0);
    CGContextAddArc(context, CGRectGetMinX(bubbleRect) + radius, CGRectGetMaxY(bubbleRect) - radius, radius, M_PI / 2, M_PI, 0);
    CGContextAddArc(context, CGRectGetMinX(bubbleRect) + radius, CGRectGetMinY(bubbleRect) + radius, radius, M_PI, 3 * M_PI / 2, 0);
    CGContextClosePath(context);
    
    // draw the pointer
    CGPoint bubbleCenter = self.textLabel.center;
    CGPoint p1 = CGPointMake(-1 * self.connectorLineBaseWidth / 2 ,0);
    CGPoint p2 = CGPointMake(0, -1 * (connectorLength - kBorderWidth)); // shorten to accomodate for the border affect on the point
    CGPoint p3 = CGPointMake(self.connectorLineBaseWidth / 2 , 0);

    CGContextSaveGState(context);
    
    CGContextTranslateCTM(context, bubbleCenter.x, bubbleCenter.y);
    CGFloat pointerAngle = degreesFromNorth - 180; // pointing BACK to the anchor
    CGContextRotateCTM(context, radians(pointerAngle)); // rotate the pointer when drawn
    CGContextMoveToPoint(context, p1.x, p1.y);
    CGContextAddLineToPoint(context, p2.x, p2.y);
    CGContextAddLineToPoint(context, p3.x, p3.y);
    
    CGContextRestoreGState(context);
}

-(void)slide: (BOOL) slideOut animated: (BOOL) animated {
    CATransform3D beginTransform = self.layer.transform;
    
    CATransform3D endTransform = CATransform3DIdentity;
    if (slideOut) {
        CGPoint offsceenOrigin = [self offscreenPoint];
        endTransform = CATransform3DTranslate(endTransform, offsceenOrigin.x, offsceenOrigin.y, 0.0); 
    } else {
        endTransform = CATransform3DTranslate(endTransform, 0.0, 0.0, 0.0);
    }
    
    // change the layer, without implicit animation
    [CATransaction setDisableActions:YES]; // don't really have to do this line because it is the view's layer
    self.layer.transform = endTransform;
    
    if (animated) {
        // construct the explicit animation
        CABasicAnimation* anim = [CABasicAnimation animationWithKeyPath:@"transform"];
        anim.duration = 0.8;
        CAMediaTimingFunction* clunk = [CAMediaTimingFunction functionWithControlPoints:.9 :.1 :.7 :.9];
        anim.timingFunction = clunk;
        anim.fromValue = [NSValue valueWithCATransform3D:beginTransform];
        anim.toValue = [NSValue valueWithCATransform3D:endTransform];
        
        // ask for the explicit animation
        [self.layer addAnimation:anim forKey:nil];
    }     
}

-(CGPoint)offscreenPoint {
    // slide from left or right?
    BOOL slideFromRight = (self.degreesFromNorth % 360) < 180;
    CGFloat offScreenOriginX = slideFromRight ? 
        -1 * (CGRectGetMinX(self.frame) + CGRectGetWidth(self.bounds)) :
        (CGRectGetMinX(self.frame) + CGRectGetWidth(self.bounds));
    return CGPointMake(offScreenOriginX, 0.0); 
}

@end
