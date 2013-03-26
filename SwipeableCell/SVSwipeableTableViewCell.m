//
//  SVSwipeableTableViewCell.m
//  SwipeableCell
//
//  Created by Sébastien Villar on 26/03/13.
//  Copyright (c) 2013 Sébastien Villar. All rights reserved.
//

#import "SVSwipeableTableViewCell.h"
#import "SVCellBackground.h"

#import <QuartzCore/QuartzCore.h>

#define kSwipeEndAnimationOffset 10
#define kSwipeEndAnimationDuration 0.5

@interface SVSwipeableTableViewCell ()
@property (assign, readwrite) UIView* sv_shownCellBackgroundView;
@property (assign, readwrite, getter = sv_isSwiping) BOOL sv_swiping;
@end

@implementation SVSwipeableTableViewCell
@synthesize leftCellBackgroundView = _leftCellBackgroundView,
			rightCellBackgroundView = _rightCellBackgroundView,
			sv_swiping = sv_swiping;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
		UIPanGestureRecognizer* gestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(sv_swipe:)];
		gestureRecognizer.minimumNumberOfTouches = 1;
		gestureRecognizer.maximumNumberOfTouches = 1;
		gestureRecognizer.cancelsTouchesInView = YES;
		gestureRecognizer.delaysTouchesBegan = YES;
		gestureRecognizer.delaysTouchesEnded = YES;
		gestureRecognizer.delegate = self;
		[self.contentView addGestureRecognizer:gestureRecognizer];
		self.contentView.backgroundColor = [UIColor whiteColor];
		sv_swiping = NO;
    }
    return self;
}

/////////////////////////////////////////////////////////////////////////////
// Public
/////////////////////////////////////////////////////////////////////////////

- (void)addLeftAction {
	if (!self.leftCellBackgroundView) {
		self.leftCellBackgroundView = [[SVCellBackground alloc] initWithFrame:self.bounds];
	}
	if (!self.leftCellBackgroundView.superview) {
		[self insertSubview:self.leftCellBackgroundView belowSubview:self.contentView];
	}
	self.leftCellBackgroundView.hidden = NO;
	self.leftCellBackgroundView.backgroundColor = [UIColor redColor];
}

- (void)removeLeftAction {
	if (self.leftCellBackgroundView) {
		[self.leftCellBackgroundView removeFromSuperview];
		self.leftCellBackgroundView = nil;
	}
}

- (void)addRightAction {
	if (!self.rightCellBackgroundView) {
		self.rightCellBackgroundView = [[SVCellBackground alloc] initWithFrame:self.bounds];
	}
	if (!self.rightCellBackgroundView.superview) {
		UIView* view = self.contentView;
		if (self.leftCellBackgroundView) 
			view = self.leftCellBackgroundView;
		
		[self insertSubview:self.rightCellBackgroundView belowSubview:view];
	}
	self.rightCellBackgroundView.hidden = NO;
	self.rightCellBackgroundView.backgroundColor = [UIColor greenColor];
}

- (void)removeRightAction {
	if (self.rightCellBackgroundView) {
		[self.rightCellBackgroundView removeFromSuperview];
		self.rightCellBackgroundView = nil;
	}
}

#pragma mark - Overwritten

- (void)insertSubview:(UIView *)view atIndex:(NSInteger)index {
	[super insertSubview:view atIndex:index];
	if (self.leftCellBackgroundView) {
		[self sendSubviewToBack:self.leftCellBackgroundView];
	}
	if (self.rightCellBackgroundView) {
		[self sendSubviewToBack:self.rightCellBackgroundView];
	}
}

/////////////////////////////////////////////////////////////////////////////
// Private
/////////////////////////////////////////////////////////////////////////////

#pragma mark - UIGestureRecognizer

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
	if ([gestureRecognizer isKindOfClass:[UIPanGestureRecognizer class]]) {
		return self.leftCellBackgroundView || self.rightCellBackgroundView;
	}
	return NO;
}

- (void)sv_swipe:(UIPanGestureRecognizer*)gestureRecognizer {
	if (gestureRecognizer.state == UIGestureRecognizerStateBegan) {
	}
	
	else if (gestureRecognizer.state == UIGestureRecognizerStateEnded) {
		if (self.sv_swiping) {
			CGRect contentFrame = self.contentView.frame;
			float contentYPosition = contentFrame.origin.y + contentFrame.size.height/2;
			CAKeyframeAnimation* translationAnimation = [CAKeyframeAnimation animationWithKeyPath:@"position"];
			CGMutablePathRef path = CGPathCreateMutable();
			CGPathMoveToPoint(path, NULL, contentFrame.origin.x + contentFrame.size.width/2, contentYPosition);
			if (contentFrame.origin.x > 0)
				CGPathAddLineToPoint(path, NULL, contentFrame.size.width/2 - kSwipeEndAnimationOffset, contentYPosition);
			else
				CGPathAddLineToPoint(path, NULL, contentFrame.size.width/2 + kSwipeEndAnimationOffset, contentYPosition);
			
			CGPathAddLineToPoint(path, NULL, contentFrame.size.width/2, contentYPosition);
			translationAnimation.path = path;
			translationAnimation.duration = kSwipeEndAnimationDuration;
			
			[self.contentView.layer addAnimation:translationAnimation forKey:@"position"];
			CGPathRelease(path);
			
			contentFrame.origin.x = 0;
			self.contentView.frame = contentFrame;
		}
	}
	
	else {
		CGPoint translationPoint = [gestureRecognizer translationInView:self];
		UIView* shownCellBackgroundView = translationPoint.x > 0 ? self.leftCellBackgroundView : self.rightCellBackgroundView;
		self.sv_swiping = shownCellBackgroundView != nil;
		
		if (self.sv_swiping) {
			if (shownCellBackgroundView == self.leftCellBackgroundView) {
				self.leftCellBackgroundView.hidden = NO;
			}
			else {
				self.leftCellBackgroundView.hidden = YES;
			}
			CGRect contentViewFrame = self.contentView.frame;
			contentViewFrame.origin.x = translationPoint.x;
			self.contentView.frame = contentViewFrame;
		}
	}
}

#pragma mark - CAAnimation delegate


@end
