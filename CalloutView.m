//
//  CalloutView.m
//
//  Created by Jim Geppert on 6/18/12.
//  Copyright (c) 2012 Summit Hill Software. All rights reserved.
//

#import "CalloutView.h"

#define radians(x) ((x) * M_PI/180 )

#define kPaddingHorizontal 0.f
#define kPaddingVertical 2.f
#define kBorderWidth 4.f
#define kRoundedCornerRadius 4.f  
#define kConnectorLineBaseWidthDefault 30.f
#define kShadowOffset 4.f

@interface CalloutView()

@property (nonatomic, strong) NSString *text;
@property (nonatomic) CGFloat widthConstraint;
@property (nonatomic) CGFloat degreesFromNorth;
@property (nonatomic) CGPoint anchor;
@property (nonatomic) int connectorLength;
@property (nonatomic) int connectorLineBaseWidth;

@end

@implementation CalloutView
@synthesize textView, text, widthConstraint, degreesFromNorth, anchor, connectorLength, connectorLineBaseWidth, borderColor, useShadow;

- (id)initWithFrame:(CGRect)frame text:(NSString *) textToDisplay anchor: (CGPoint) anchorPoint width: (CGFloat) width degrees: (int) degreesFromAnchor connectorLength: (int) length {
    self = [super initWithFrame:frame];
    if (self) {
        self.text = textToDisplay;
        self.anchor = anchorPoint;
        self.widthConstraint = width;
        self.degreesFromNorth = degreesFromAnchor;
        self.connectorLength = length;
        self.borderColor = [UIColor blackColor];
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
    if (self.textView == nil) {
        self.textView = [[UITextView alloc] init];
        self.textView.backgroundColor = [UIColor whiteColor];
        self.textView.text = self.text;
    } else {
        if (![self.textView.text length]) {
            self.textView.text = self.text;
        }
    }
    self.textView.editable = NO;
    // set constraints and then find size
    CGFloat textViewHorizontalInset = kPaddingHorizontal + kBorderWidth;
    CGFloat textViewWidth = self.widthConstraint - (textViewHorizontalInset * 2);
    self.textView.frame = CGRectMake(0,0, textViewWidth, 10);
    CGFloat textViewHeight = self.textView.contentSize.height;
    CGSize textViewSize = CGSizeMake(textViewWidth, textViewHeight);
    self.textView.frame = CGRectMake(0,0, textViewSize.width, textViewSize.height);
    [self addSubview:self.textView];
    [self calcConnectorLineBaseWidth];
    return textViewSize;
}

-(void)positionTextView {
    CGPoint midPoint = [self calcPointOnCirle:self.anchor radius:self.connectorLength degrees:self.degreesFromNorth];
    self.textView.center = midPoint;
}

-(CGPoint)calcPointOnCirle: (CGPoint) centerPoint radius: (float) radius degrees: (float) degrees {
    CGFloat radians = radians(degrees + 270);  // need to add 90 degrees for this calc
    return CGPointMake(centerPoint.x + round(radius * cos(radians)), centerPoint.y + round(radius * sin(radians)));
}

-(void)calcConnectorLineBaseWidth {
    CGSize textViewSize = self.textView.bounds.size;
    self.connectorLineBaseWidth = MIN(self.connectorLineBaseWidth, MIN(textViewSize.width, textViewSize.height));
}

- (void)drawRect:(CGRect)rect {
    CGFloat verticalInset = kPaddingVertical  + kBorderWidth / 2;
    CGFloat horizontalInset = kPaddingHorizontal  + kBorderWidth / 2;
    CGRect bubbleRect = CGRectInset(self.textView.frame, -1 * horizontalInset, -1 * verticalInset);
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSaveGState(context);
    CGContextSetFillColorWithColor(context, self.textView ? self.textView.backgroundColor.CGColor : [UIColor whiteColor].CGColor);
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
    CGPoint bubbleCenter = self.textView.center;
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

@end
