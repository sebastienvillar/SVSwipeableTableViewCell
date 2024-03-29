//
//  SVSwipeableTableViewCell.m
//  SwipeableCell
//
//  Created by Sébastien Villar on 26/03/13.
//  Copyright (c) 2013 Sébastien Villar. All rights reserved.
//

#import "SVSwipeableTableViewCell.h"
#import "SVActionView.h"
#import "SVBubbleView.h"
#import "SVActionDelegate.h"

#import <QuartzCore/QuartzCore.h>

#define kSwipeEndAnimationOffset 10
#define kSwipeEndAnimationDuration 0.4

@interface SVSwipeableTableViewCell ()
@property (strong, readwrite) UIView* leftActionView;
@property (strong, readwrite) UIView* rightActionView;
@property (assign, readwrite, getter = sv_isSwiping) BOOL sv_swiping;
@property (assign, readwrite, getter = sv_isAnimating) BOOL sv_animating;
@property (strong, readwrite) SVActionDelegate* sv_delegate;
@property (assign, readwrite) BOOL sv_trigger;
@end

@implementation SVSwipeableTableViewCell

//Public
@synthesize withShadowAnimation = _withShadowAnimation;

//Private
@synthesize leftActionView = _leftActionView,
			rightActionView = _rightActionView,
			sv_swiping = _sv_swiping,
			sv_animating = _sv_animating,
			sv_delegate = _sv_delegate,
			sv_trigger = _sv_trigger;

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
		CALayer* contentLayer = self.contentView.layer;
		contentLayer.shadowColor = [UIColor blackColor].CGColor;
		contentLayer.shadowOpacity = 0.0;
		contentLayer.shadowRadius = 3.0;
		contentLayer.shadowOffset = CGSizeMake(0, 0);
		CGRect shadowRect = CGRectInset(contentLayer.bounds, 0, 0);
		contentLayer.shadowPath = CGPathCreateWithRect(shadowRect, NULL);
		[self addObserver:self forKeyPath:@"frame" options:NSKeyValueObservingOptionNew context:nil];
		_sv_swiping = NO;
		_withShadowAnimation = NO;
		_sv_animating = NO;
		_sv_delegate = [[SVActionDelegate alloc] init];
		_sv_trigger = NO;
    }
    return self;
}

/////////////////////////////////////////////////////////////////////////////
// Public
/////////////////////////////////////////////////////////////////////////////

- (void)addLeftActionWithView:(UIView *)view {
	if (self.leftActionView) {
		[self.leftActionView removeFromSuperview];
	}
	self.leftActionView = view;
	[self insertSubview:self.leftActionView belowSubview:self.contentView];
	if ([self.leftActionView isKindOfClass:SVActionView.class]) {
		self.sv_delegate.leftActionView = (SVActionView*)self.leftActionView;
	}
}

- (void)removeLeftAction {
	if (self.leftActionView) {
		[self.leftActionView removeFromSuperview];
		if ([self.leftActionView isKindOfClass:SVActionView.class]) {
			self.sv_delegate.leftActionView = nil;
		}
		self.leftActionView = nil;
	}
}

- (void)addRightActionWithView:(UIView *)view {
	if (self.rightActionView) {
		[self.rightActionView removeFromSuperview];
	}
	self.rightActionView = view;
	[self insertSubview:self.rightActionView belowSubview:self.contentView];
	if ([self.rightActionView isKindOfClass:SVActionView.class]) {
		self.sv_delegate.rightActionView = (SVActionView*)self.rightActionView;
	}
}

- (void)removeRightAction {
	if (self.rightActionView) {
		[self.rightActionView removeFromSuperview];
		if ([self.rightActionView isKindOfClass:SVActionView.class]) {
			self.sv_delegate.rightActionView = nil;
		}
		self.rightActionView = nil;
	}
}

#pragma mark - Overwritten

- (void)insertSubview:(UIView *)view atIndex:(NSInteger)index {
	[super insertSubview:view atIndex:index];
	[self sv_sendViewsToBack];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
	/*if (!self.sv_isAnimating) {
		[super setSelected:selected animated:animated];
		[self sv_sendViewsToBack];
	}*/
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
	if (object == self && [keyPath isEqualToString:@"frame"]) {
		CGRect shadowRect = CGRectInset(self.contentView.layer.frame, 0, 0);
		self.contentView.layer.shadowPath = CGPathCreateWithRect(shadowRect, NULL);
	}
}

- (void)dealloc {
	[self removeObserver:self forKeyPath:@"frame"];
}

/////////////////////////////////////////////////////////////////////////////
// Private
/////////////////////////////////////////////////////////////////////////////

- (SVActionDelegate*)sv_delegate {
	if (!_sv_delegate) {
		_sv_delegate = [[SVActionDelegate alloc] init];
	}
	return _sv_delegate;
}

- (void)setSv_delegate:(SVActionDelegate *)sv_delegate {
	_sv_delegate = sv_delegate;
}

- (void)sv_sendViewsToBack {
	if (self.leftActionView) {
		[self sendSubviewToBack:self.leftActionView];
	}
	if (self.rightActionView) {
		[self sendSubviewToBack:self.rightActionView];
	}
}

- (UIView*)sv_shownBackgroundCellViewAtDestinationPoint:(CGPoint)destinationPoint {
	if (destinationPoint.x > 0)
		return self.leftActionView;
	else if (destinationPoint.x < 0)
		return self.rightActionView;
	return nil;
}

#pragma mark - UIGestureRecognizer

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
	if ([gestureRecognizer isKindOfClass:[UIPanGestureRecognizer class]]) {
		if (self.sv_isAnimating) {
			return NO;
		}
		UIPanGestureRecognizer* panGestureRecognizer = (UIPanGestureRecognizer*)gestureRecognizer;
		CGPoint destinationPoint = [panGestureRecognizer translationInView:self];
		return [self sv_shownBackgroundCellViewAtDestinationPoint:destinationPoint] != nil;
	}
	return NO;
}

- (void)sv_swipe:(UIPanGestureRecognizer*)gestureRecognizer {
	if (gestureRecognizer.state == UIGestureRecognizerStateBegan) {
		if (self.selected) {
			[self setSelected:NO animated:NO];
		}
		self.sv_trigger = NO;
		self.selectedBackgroundView.alpha = 1.0;
		if (self.withShadowAnimation) {
			self.clipsToBounds = NO;
			[self.superview bringSubviewToFront:self];
			CABasicAnimation* shadowOpacityAnimation = [CABasicAnimation animationWithKeyPath:@"shadowOpacity"];
			shadowOpacityAnimation.fromValue = [NSNumber numberWithFloat:0.0];
			shadowOpacityAnimation.toValue = [NSNumber numberWithFloat:0.5];
			shadowOpacityAnimation.duration = 0.1;
			[self.contentView.layer addAnimation:shadowOpacityAnimation forKey:@"shadowOpacity"];
			self.contentView.layer.shadowOpacity = 0.5;
		}
		else {
			self.contentView.layer.shadowOpacity = 0.5;
			self.clipsToBounds = YES;
		}
	}
	
	else if (gestureRecognizer.state == UIGestureRecognizerStateEnded) {
		self.sv_animating = YES;
		CALayer* contentLayer = self.contentView.layer;
		CGRect contentFrame = contentLayer.frame;
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
		
		if (self.withShadowAnimation) {
			CABasicAnimation* shadowOpacityAnimation = [CABasicAnimation animationWithKeyPath:@"shadowOpacity"];
			shadowOpacityAnimation.fromValue = [NSNumber numberWithFloat:0.5];
			shadowOpacityAnimation.toValue = [NSNumber numberWithFloat:0.0];
			shadowOpacityAnimation.duration = kSwipeEndAnimationDuration;
			[contentLayer addAnimation:shadowOpacityAnimation forKey:@"shadowOpacity"];
		}
		
		translationAnimation.delegate = self;
		[translationAnimation setValue:@"position" forKey:@"name"];
		UIView* shownView = [self sv_shownBackgroundCellViewAtDestinationPoint:contentFrame.origin];
		[translationAnimation setValue:shownView forKey:@"view"];
		[contentLayer addAnimation:translationAnimation forKey:@"position"];
		CGPathRelease(path);
		
		if (self.sv_trigger) {
			UIView* view = [self sv_shownBackgroundCellViewAtDestinationPoint:contentFrame.origin];
			if (view == self.leftActionView) {
				if (self.delegate && [self.delegate respondsToSelector:@selector(cell:didTriggerAction:)]) {
					[self.delegate cell:self didTriggerAction:SVSwipeLeftAction];
				}
			}
			else {
				if (self.delegate && [self.delegate respondsToSelector:@selector(cell:didTriggerAction:)]) {
					[self.delegate cell:self didTriggerAction:SVSwipeRightAction];
				}
			}
		}
		
		contentFrame.origin.x = 0;
		contentLayer.frame = contentFrame;
		contentLayer.shadowOpacity = 0.0;
		}
	
	else {
		CGPoint destinationPoint = [gestureRecognizer translationInView:self];
		UIView* shownView = [self sv_shownBackgroundCellViewAtDestinationPoint:destinationPoint];
		if (shownView) {
			CGRect contentViewFrame = self.contentView.frame;
			contentViewFrame.origin.x = destinationPoint.x;
			self.contentView.frame = contentViewFrame;
			SVSwipeDirection swipeDirection;

			if (shownView == self.leftActionView) {
				self.leftActionView.hidden = NO;
				self.rightActionView.hidden = YES;
				swipeDirection = SVSwipeLeftToRight;
			}
			else {
				self.leftActionView.hidden = YES;
				self.rightActionView.hidden = NO;
				swipeDirection = SVSwipeRightToLeft;
			}
			
			if ([shownView isKindOfClass:SVActionView.class]) {
				self.sv_trigger = [self.sv_delegate cell:self didSwipeWithDirection:swipeDirection offset:fabsf(contentViewFrame.origin.x)];
			}
			
			else if (self.delegate && [self.delegate respondsToSelector:@selector(cell:didSwipeWithDirection:offset:)]) {
				self.sv_trigger = [self.delegate cell:self didSwipeWithDirection:swipeDirection offset:fabsf(contentViewFrame.origin.x)];
			}
		}
	}
}


#pragma mark - CAAnimation delegate

- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag {
	if (flag) {
		if ([[anim valueForKey:@"name"] isEqual:@"position"]) {
			self.sv_animating = NO;
			if ([[anim valueForKey:@"view"] isKindOfClass:SVActionView.class]) {
				[self.sv_delegate cellDidFinishTriggerAnimation:self];
			}
			else if (self.delegate && [self.delegate respondsToSelector:@selector(cellDidFinishTriggerAnimation:)]) {
				[self.delegate cellDidFinishTriggerAnimation:self];
			}
		}
	}
}

@end
