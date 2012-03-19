//
//  IBView.m
//  Numbers
//
//  Created by james on 7/31/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "IBView.h"


@implementation IBView

-(void) loadViewsFromBundle {
	NSString *class_name = NSStringFromClass([self class]);
	UIView *mainSubView = [[[NSBundle mainBundle] loadNibNamed:class_name owner:self options:nil] lastObject];
	[self addSubview:mainSubView];
    self.backgroundColor = [UIColor clearColor];
    [self initUI];
}

-(id) initWithCoder:(NSCoder *)coder {
	self = [super initWithCoder:coder];
	if(self) {
		[self loadViewsFromBundle];
	}
	return self;
}

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
		[self loadViewsFromBundle];
        // Initialization code.
    }
    return self;
}

-(void)initUI {
        // subclasses can re-implement to do some init'ing
}

@end
