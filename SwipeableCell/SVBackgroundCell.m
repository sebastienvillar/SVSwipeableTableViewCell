//
//  SVCellBackground.m
//  SwipeableCell
//
//  Created by Sébastien Villar on 26/03/13.
//  Copyright (c) 2013 Sébastien Villar. All rights reserved.
//

#import "SVBackgroundCell.h"

#define kDefaultBackgroundColor [UIColor colorWithRed:0.9098 green:0.9098 blue:0.9098 alpha:1.0000]
#define kDefaultTitleTextColor [UIColor colorWithRed:0.5725 green:0.5686 blue:0.5686 alpha:1.0000]
#define kMinimumFontSize 12

@implementation SVBackgroundCell
@synthesize title = _title,
			bubble = _bubble;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
		self.backgroundColor = kDefaultBackgroundColor;
		_title = [[UILabel alloc] init];
		_title.adjustsFontSizeToFitWidth = YES;
		_title.font = [UIFont boldSystemFontOfSize:20];
		_title.backgroundColor = [UIColor clearColor];
		_title.minimumScaleFactor = kMinimumFontSize/_title.font.pointSize;
		_title.textColor = kDefaultTitleTextColor;
		_title.shadowColor = [UIColor whiteColor];
		_title.shadowOffset = CGSizeMake(0, 1);
		_bubble = [[SVBubbleView alloc] init];
		[self addSubview:_title];
		[self addSubview:_bubble];
    }
    return self;
}


- (void)drawRect:(CGRect)rect
{
	CGContextRef context = UIGraphicsGetCurrentContext();
	
	CGRect innerRect = self.bounds;
	CGMutablePathRef innerPath = CGPathCreateMutable();
	CGPathAddRect(innerPath, NULL, innerRect);
	CGPathCloseSubpath(innerPath);

	CGMutablePathRef outerPath = CGPathCreateMutable();
	CGPathAddRect(outerPath, NULL, CGRectInset(self.bounds, 0, -5));
	CGPathAddPath(outerPath, NULL, innerPath);
	CGPathCloseSubpath(outerPath);
	
	CGContextAddPath(context, innerPath);
	CGContextClip(context);
		
	CGContextSaveGState(context);
	UIColor* shadowColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.5];
	CGContextSetShadowWithColor(context, CGSizeMake(0.0, 0.0), 3.0, shadowColor.CGColor);
	CGContextAddPath(context, outerPath);
	CGContextEOFillPath(context);
	CGContextRestoreGState(context);
	
	CGPathRelease(innerPath);
	CGPathRelease(outerPath);
}


@end
