//
//  FieldDimensionsView.m
//  InstrumentsTest
//
//  Created by Jim Geppert on 10/17/14.
//  Copyright (c) 2014 Summit Hill Software. All rights reserved.
//

#import "FieldDimensionsView.h"
#import "DimensionView.h"
#import "UIView+Convenience.h"

#define kDimensionViewHeight 40.0f
#define kDimensionViewWidth 40.0f
#define kBrickMarkRadius 3.0f

@interface FieldDimensionsView ()

@property (nonatomic, strong) DimensionView* endZoneDimensionView;
@property (nonatomic, strong) DimensionView* centralZoneDimensionView;
@property (nonatomic, strong) DimensionView* widthDimensionView;
@property (nonatomic, strong) DimensionView* brickMarkDimensionView;
@property (nonatomic) CGRect fieldRect;
@property (nonatomic) CGRect endzone0Rect;
@property (nonatomic) CGRect endzone100Rect;
@property (nonatomic) CGRect brickMark0Rect;
@property (nonatomic) CGRect brickMark100Rect;

@end

@implementation FieldDimensionsView

- (instancetype)init {
    self = [super init];
    if (self) {
        [self commonInit];
    }
    return self;
}

-(void)awakeFromNib {
    [self commonInit];
}

-(void)commonInit {
    [self initializeDimensionViews];
}

-(void)initializeDimensionViews {
    self.endZoneDimensionView = [self createDimensionView];
    self.centralZoneDimensionView = [self createDimensionView];
    self.centralZoneDimensionView.includeEndMarks = YES;
    self.widthDimensionView = [self createDimensionView];
    self.widthDimensionView.orientation = DimensionViewOrientationVertical;
    self.brickMarkDimensionView = [self createDimensionView];
}

-(DimensionView*)createDimensionView {
    DimensionView* dimView = [[DimensionView alloc] init];
    dimView.lineColor = self.lineColor;
    [self addSubview:dimView];
    return dimView;
}

-(void)populateDimensionViews {
    if (self.fieldDimensions) {
        self.endZoneDimensionView.distanceDescription = [self dimensionDescription:self.fieldDimensions.endZoneLength];
        self.centralZoneDimensionView.distanceDescription = [self dimensionDescription:self.fieldDimensions.centralZoneLength];
        self.widthDimensionView.distanceDescription = [self dimensionDescription:self.fieldDimensions.width];
        self.brickMarkDimensionView.distanceDescription = [self dimensionDescription:self.fieldDimensions.brickMarkDistance];
    }
}

-(NSString*)dimensionDescription: (int) dim {
    return [NSString stringWithFormat:@"%d%@", dim, self.fieldDimensions.unitOfMeasure == FieldUnitOfMeasureMeters ? @"m" : @"y"];
}

-(void)layoutSubviews {
    if (self.fieldDimensions) {
        [self calculateFieldCoordinates];
        [self layoutDimensionViews];
        [self setNeedsDisplay];
    }
}

-(void)calculateFieldCoordinates {
    CGFloat totalFieldLength = (self.fieldDimensions.endZoneLength * 2.0f) + self.fieldDimensions.centralZoneLength;
    CGFloat maxViewHeight = self.boundsHeight - kDimensionViewHeight;
    CGFloat maxViewWidth = self.boundsWidth;
    CGFloat scale = MIN(maxViewWidth / totalFieldLength, maxViewHeight / self.fieldDimensions.width);
    
    CGFloat totalFieldViewWidth = totalFieldLength * scale;
    CGFloat totalFieldViewHeight = self.fieldDimensions.width * scale;
    CGFloat totalFieldViewX = totalFieldViewWidth < self.boundsWidth ? MAX(0,(self.boundsWidth - totalFieldViewWidth) / 2.0f) : 0;
    self.fieldRect = CGRectIntegral(CGRectMake(totalFieldViewX, 0, totalFieldViewWidth, totalFieldViewHeight));

    CGFloat endZoneViewWidth = floorf(self.fieldDimensions.endZoneLength * scale);
    self.endzone0Rect = CGRectMake(totalFieldViewX, 0, endZoneViewWidth, self.fieldRect.size.height);
    self.endzone100Rect = CGRectMake(totalFieldViewX + totalFieldViewWidth - endZoneViewWidth, 0, endZoneViewWidth, self.fieldRect.size.height);
    
    CGFloat brickMarkToEndzone = self.fieldDimensions.brickMarkDistance * scale;
    self.brickMark0Rect = CGRectMake(CGRectGetMaxX(self.endzone0Rect) + brickMarkToEndzone - kBrickMarkRadius, CGRectGetMidY(self.fieldRect) - kBrickMarkRadius, kBrickMarkRadius * 2, kBrickMarkRadius * 2);
    self.brickMark100Rect = CGRectMake(CGRectGetMinX(self.endzone100Rect) - brickMarkToEndzone - kBrickMarkRadius, CGRectGetMidY(self.fieldRect) - kBrickMarkRadius, kBrickMarkRadius * 2, kBrickMarkRadius * 2);
}

-(void)layoutDimensionViews {
    CGFloat x = CGRectGetMidX(self.endzone0Rect) - (kDimensionViewWidth / 2.0f);
    self.widthDimensionView.frame = CGRectMake(x, 0, kDimensionViewWidth, self.endzone0Rect.size.height);
    
    CGFloat midFieldDimViewsY = CGRectGetMidY(self.endzone100Rect) - (kDimensionViewHeight / 2.0f);
    self.endZoneDimensionView.frame = CGRectIntegral(CGRectMake(self.endzone100Rect.origin.x, midFieldDimViewsY, self.endzone100Rect.size.width, kDimensionViewHeight));
    
    x = CGRectGetMaxX(self.endzone0Rect);
    self.centralZoneDimensionView.frame = CGRectMake(x, CGRectGetMaxY(self.fieldRect), self.endzone100Rect.origin.x - x, kDimensionViewHeight);

    self.brickMarkDimensionView.frame = CGRectMake(CGRectGetMaxX(self.endzone0Rect), midFieldDimViewsY, self.brickMark0Rect.origin.x - x, kDimensionViewHeight);
}

- (void)drawRect:(CGRect)drawingRect {
    [super drawRect:drawingRect];
    
    if (!self.fieldDimensions) {
        return;
    }
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSaveGState(context);
    CGFloat lineWidth = 2;
    CGContextSetStrokeColorWithColor(context, self.lineColor.CGColor);
    CGContextSetLineWidth(context, lineWidth);
    CGContextSetLineCap(context, kCGLineCapSquare);
    
    // draw endzone 0
    CGFloat x = CGRectGetMaxX(self.endzone0Rect);
    CGContextMoveToPoint(context, x, self.endzone0Rect.origin.y);
    CGContextAddLineToPoint(context, x, CGRectGetMaxY(self.endzone0Rect)  - lineWidth);
    CGContextStrokePath(context);
    
    // draw endzone 100
    x = self.endzone100Rect.origin.x;
    CGContextMoveToPoint(context, x, self.endzone100Rect.origin.y);
    CGContextAddLineToPoint(context, x, CGRectGetMaxY(self.endzone100Rect) - lineWidth);
    CGContextStrokePath(context);
    
    // draw the total field boundaries
    CGFloat borderLineInset = lineWidth - 1;  // stay inside the bounds
    CGRect rect = self.fieldRect;
    CGContextMoveToPoint(context, rect.origin.x + borderLineInset, rect.origin.y + borderLineInset);
    CGContextAddLineToPoint(context, rect.origin.x  + borderLineInset, rect.size.height - borderLineInset);
    CGContextAddLineToPoint(context, rect.origin.x + rect.size.width - borderLineInset, rect.size.height - borderLineInset);
    CGContextAddLineToPoint(context, rect.origin.x + rect.size.width - borderLineInset, rect.origin.y  + borderLineInset);
    CGContextAddLineToPoint(context, rect.origin.x + borderLineInset, rect.origin.y  + borderLineInset);
    CGContextStrokePath(context);
    
    // draw the endzone 0 & 100 brickmark
    CGContextSetFillColorWithColor(context, self.lineColor.CGColor);
    CGContextAddEllipseInRect(context, self.brickMark0Rect);
    CGContextFillPath(context);
    CGContextAddEllipseInRect(context, self.brickMark100Rect);
    CGContextFillPath(context);
    
    CGContextRestoreGState(context);
}

-(void)setFieldDimensions:(FieldDimensions *)fieldDimensions {
    _fieldDimensions = fieldDimensions;
    [self populateDimensionViews];
    [self setNeedsLayout];
}

@end