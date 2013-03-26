//
//  SVCellBackground.m
//  SwipeableCell
//
//  Created by Sébastien Villar on 26/03/13.
//  Copyright (c) 2013 Sébastien Villar. All rights reserved.
//

#import "SVCellBackground.h"

#define kDefaultBackgroundColor [UIColor colorWithRed:0.9098 green:0.9098 blue:0.9098 alpha:1.0000]

@implementation SVCellBackground
@synthesize title = _title;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
		self.backgroundColor = kDefaultBackgroundColor;
		_title = [[UILabel alloc] init];
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
