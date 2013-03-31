//
//  SVActionDelegate.m
//  SwipeableCell
//
//  Created by Sébastien Villar on 29/03/13.
//  Copyright (c) 2013 Sébastien Villar. All rights reserved.
//

#import "SVActionDelegate.h"

#define kTriggerDistance 25
#define kTitleWidth 135

@interface SVActionDelegate ()
@property (assign, readwrite) float beginLeftTriggerOffset;
@property (assign, readwrite) float beginRightTriggerOffset;
@property (assign, readwrite) float leftTriggerOffset;
@property (assign, readwrite) float rightTriggerOffset;
@end

@implementation SVActionDelegate
@synthesize leftActionView = _leftActionView,
			rightActionView = _rightActionView;

- (SVActionView*)leftActionView {
	return _leftActionView;
}

- (void)setLeftActionView:(SVActionView *)leftActionView {
	if (_leftActionView) {
		[_leftActionView removeObserver:self forKeyPath:@"title.text"];
		[_leftActionView removeObserver:self forKeyPath:@"title.attributedText"];
		[_leftActionView removeObserver:self forKeyPath:@"title.font"];
	}
	_leftActionView = leftActionView;
	SVActionView* view = self.leftActionView;
	view.title.frame = CGRectMake(10, 0, kTitleWidth, view.frame.size.height);
	CGSize textSize = [view.title.text sizeWithFont:view.title.font];
	if (textSize.width > view.title.frame.size.width) {
		textSize.width = view.title.frame.size.width;
	}
	float outerDiameter = view.bubble.outerRadius * 2;
	view.bubble.frame = CGRectMake(textSize.width + 18, view.frame.size.height / 2 - outerDiameter / 2, outerDiameter, outerDiameter);
	self.beginLeftTriggerOffset = view.bubble.frame.origin.x + view.bubble.frame.size.width + 5;
	self.leftTriggerOffset = self.beginLeftTriggerOffset + kTriggerDistance;
	[view addObserver:self forKeyPath:@"title.text" options:NSKeyValueObservingOptionNew context:nil];
	[view addObserver:self forKeyPath:@"title.attributedText" options:NSKeyValueObservingOptionNew context:nil];
	[view addObserver:self forKeyPath:@"title.font" options:NSKeyValueObservingOptionNew context:nil];
}

- (SVActionView*)rightActionView {
	return _rightActionView;
}

- (void)setRightActionView:(SVActionView *)rightActionView {
	if (_rightActionView) {
		[_rightActionView removeObserver:self forKeyPath:@"title.text"];
		[_rightActionView removeObserver:self forKeyPath:@"title.attributedText"];
		[_rightActionView removeObserver:self forKeyPath:@"title.font"];
	}
	_rightActionView = rightActionView;
	SVActionView* view = self.rightActionView;
	view.title.frame = CGRectMake(view.frame.size.width - kTitleWidth - 10, 0, kTitleWidth, view.frame.size.height);
	view.title.textAlignment = NSTextAlignmentRight;
	CGSize textSize = [view.title.text sizeWithFont:view.title.font];
	if (textSize.width > view.title.frame.size.width) {
		textSize.width = view.title.frame.size.width;
	}
	float outerDiameter = view.bubble.outerRadius * 2;
	view.bubble.frame = CGRectMake(view.frame.size.width - textSize.width - 18 - outerDiameter, view.frame.size.height / 2 - outerDiameter/2, outerDiameter, outerDiameter);
	self.beginRightTriggerOffset = view.bubble.frame.origin.x - 5;
	self.rightTriggerOffset = self.beginRightTriggerOffset - kTriggerDistance;
	_rightActionView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
	[view addObserver:self forKeyPath:@"title.text" options:NSKeyValueObservingOptionNew context:nil];
	[view addObserver:self forKeyPath:@"title.attributedText" options:NSKeyValueObservingOptionNew context:nil];
	[view addObserver:self forKeyPath:@"title.font" options:NSKeyValueObservingOptionNew context:nil];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {	
	if ([keyPath hasPrefix:@"title"]) {
		if (object == self.leftActionView) {
			SVActionView* view = self.leftActionView;
			UILabel* label = view.title;
			CGSize textSize = [label.text sizeWithFont:label.font];
			if (textSize.width > label.frame.size.width) {
				textSize.width = label.frame.size.width;
			}
			float outerRadius = view.bubble.outerRadius;
			view.bubble.frame = CGRectMake(textSize.width + 18, view.frame.size.height / 2 - outerRadius, outerRadius*2, outerRadius*2);
			self.beginLeftTriggerOffset = view.bubble.frame.origin.x + view.bubble.frame.size.width + 5;
			self.leftTriggerOffset = self.beginLeftTriggerOffset + kTriggerDistance;
		}
		else {
			SVActionView* view = self.rightActionView;
			UILabel* label = view.title;
			label.frame = CGRectMake(view.frame.size.width - 125 - 10, 0, 125, view.frame.size.height);
			CGSize textSize = [label.text sizeWithFont:label.font];
			if (textSize.width > label.frame.size.width) {
				textSize.width = label.frame.size.width;
			}
			float outerRadius = view.bubble.outerRadius;
			view.bubble.frame = CGRectMake(view.frame.size.width - textSize.width - 18 - outerRadius*2, view.frame.size.height / 2 - outerRadius, outerRadius*2, outerRadius*2);
			self.beginRightTriggerOffset = view.bubble.frame.origin.x - 5;
			self.rightTriggerOffset = self.beginRightTriggerOffset - kTriggerDistance;
		}
	}
}

- (BOOL)cell:(SVSwipeableTableViewCell *)cell didSwipeWithDirection:(SVSwipeDirection)direction offset:(float)offset {
	float ratio;
	SVActionView* view;
	BOOL returnValue = NO;
	if (direction == SVSwipeLeftToRight) {
		ratio = (offset - self.beginLeftTriggerOffset) / (self.leftTriggerOffset - self.beginLeftTriggerOffset);
		view = self.leftActionView;
	}
	
	else {
		ratio = (self.beginRightTriggerOffset - (self.rightActionView.frame.size.width - offset)) / (self.beginRightTriggerOffset - self.rightTriggerOffset);
		view = self.rightActionView;
	}
	
	if (ratio < 0)
		ratio = 0;
	
	if (ratio >= 1) {
		view.bubble.activated = YES;
		returnValue = YES;
	}
	
	else
		view.bubble.activated = NO;
	view.bubble.innerRadius = ratio * view.bubble.outerRadius;

	return returnValue;
}

- (void)cellDidFinishTriggerAnimation:(SVSwipeableTableViewCell *)cell {
	self.leftActionView.bubble.innerRadius = 0;
	self.rightActionView.bubble.innerRadius = 0;
}

- (void)dealloc {
	if (self.leftActionView) {
		[_leftActionView removeObserver:self forKeyPath:@"title.text"];
		[_leftActionView removeObserver:self forKeyPath:@"title.attributedText"];
		[_leftActionView removeObserver:self forKeyPath:@"title.font"];
	}
	if (self.rightActionView) {
		[_rightActionView removeObserver:self forKeyPath:@"title.text"];
		[_rightActionView removeObserver:self forKeyPath:@"title.attributedText"];
		[_rightActionView removeObserver:self forKeyPath:@"title.font"];
	}
}

@end
