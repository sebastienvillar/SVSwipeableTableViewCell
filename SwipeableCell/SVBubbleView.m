//
//  SVBubbleView.m
//  SwipeableCell
//
//  Created by Sébastien Villar on 26/03/13.
//  Copyright (c) 2013 Sébastien Villar. All rights reserved.
//

#import "SVBubbleView.h"

#define kDefaultInnerColor [UIColor colorWithRed:0.9098 green:0.9098 blue:0.9098 alpha:1.0000]
#define kDefaultOuterColor [UIColor colorWithRed:0.5725 green:0.5686 blue:0.5686 alpha:1.0000]

@interface SVBubbleView ()
@end

@implementation SVBubbleView

//Public
@synthesize innerColor = _innerColor,
			outerColor = _outerColor;

//Private
@synthesize innerRadius = _innerRadius,
			outerRadius = _outerRadius,
			activated = _activated;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _innerColor = kDefaultInnerColor;
		_outerColor = kDefaultOuterColor;
		_innerRadius = 0;
		_outerRadius = 9;
		self.backgroundColor = [UIColor clearColor];
		[self addObserver:self forKeyPath:@"innerRadius" options:NSKeyValueObservingOptionOld context:nil];
		[self addObserver:self forKeyPath:@"outerRadius" options:NSKeyValueObservingOptionOld context:nil];
    }
    return self;
}

- (void)drawRect:(CGRect)rect {
	CGContextRef context = UIGraphicsGetCurrentContext();
	CGSize size = self.bounds.size;
	CGRect outerCircleBounds = CGRectMake(size.width/2 - self.outerRadius, size.height/2 - self.outerRadius, self.outerRadius * 2, self.outerRadius * 2);
	CGRect innerCircleBounds = CGRectMake(size.width/2 - self.innerRadius, size.height/2 - self.innerRadius, self.innerRadius * 2, self.innerRadius * 2);
	
	[self.outerColor set];
	CGContextFillEllipseInRect(context, outerCircleBounds);
	
	[self.innerColor set];
	CGContextFillEllipseInRect(context, innerCircleBounds);
	
	if (self.activated) {
		float centerRadius = 1.5;
		CGRect centerCircleBounds = CGRectMake(size.width/2 - centerRadius, size.height/2 - centerRadius, centerRadius * 2, centerRadius * 2);
		
		[self.outerColor set];
		CGContextFillEllipseInRect(context, centerCircleBounds);
	}
}

- (void)setInnerRadius:(float)innerRadius {
	_innerRadius = innerRadius;
	if (innerRadius > self.outerRadius - 3) {
		_innerRadius = self.outerRadius - 3;
	}
}

- (float)innerRadius {
	return _innerRadius;
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {	
	float oldValue;
	[[change objectForKey:NSKeyValueChangeOldKey] getValue:&oldValue];
	
	if ([keyPath isEqualToString:@"innerRadius"]) {
		if (oldValue != self.innerRadius) {
			[self setNeedsDisplay];
		}
	}
	if ([keyPath isEqualToString:@"innerRadius"]) {
		if (oldValue != self.outerRadius) {
			[self setNeedsDisplay];
		}
	}
}

- (void)dealloc {
	[self removeObserver:self forKeyPath:@"innerRadius"];
	[self removeObserver:self forKeyPath:@"outerRadius"];
}

@end
