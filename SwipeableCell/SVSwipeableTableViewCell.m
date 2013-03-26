//
//  SVSwipeableTableViewCell.m
//  SwipeableCell
//
//  Created by Sébastien Villar on 26/03/13.
//  Copyright (c) 2013 Sébastien Villar. All rights reserved.
//

#import "SVSwipeableTableViewCell.h"
#import "SVBackgroundCell.h"

#import <QuartzCore/QuartzCore.h>

#define kSwipeEndAnimationOffset 10
#define kSwipeEndAnimationDuration 0.3

@interface SVSwipeableTableViewCell ()
@property (assign, readwrite, getter = sv_isSwiping) BOOL sv_swiping;
@end

@implementation SVSwipeableTableViewCell
@synthesize leftBackgroundCellView = _leftBackgroundCellView,
			rightBackgroundCellView = _rightBackgroundCellView,
			sv_swiping = sv_swiping,
			withShadowAnimation = _withShadowAnimation;

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
		CGRect shadowRect = CGRectInset(contentLayer.frame, 0, 0);
		contentLayer.shadowPath = CGPathCreateWithRect(shadowRect, NULL);
		sv_swiping = NO;
		_withShadowAnimation = NO;
    }
    return self;
}

/////////////////////////////////////////////////////////////////////////////
// Public
/////////////////////////////////////////////////////////////////////////////

- (void)addLeftAction {
	if (!self.leftBackgroundCellView) {
		self.leftBackgroundCellView = [[SVBackgroundCell alloc] initWithFrame:self.bounds];
	}
	if (!self.leftBackgroundCellView.superview) {
		[self insertSubview:self.leftBackgroundCellView belowSubview:self.contentView];
	}
	self.leftBackgroundCellView.hidden = NO;
}

- (void)removeLeftAction {
	if (self.leftBackgroundCellView) {
		[self.leftBackgroundCellView removeFromSuperview];
		self.leftBackgroundCellView = nil;
	}
}

- (void)addRightAction {
	if (!self.rightBackgroundCellView) {
		self.rightBackgroundCellView = [[SVBackgroundCell alloc] initWithFrame:self.bounds];
	}
	if (!self.rightBackgroundCellView.superview) {
		UIView* view = self.contentView;
		if (self.leftBackgroundCellView) 
			view = self.leftBackgroundCellView;
		
		[self insertSubview:self.rightBackgroundCellView belowSubview:view];
	}
	self.rightBackgroundCellView.hidden = NO;
}

- (void)removeRightAction {
	if (self.rightBackgroundCellView) {
		[self.rightBackgroundCellView removeFromSuperview];
		self.rightBackgroundCellView = nil;
	}
}

#pragma mark - Overwritten

- (void)insertSubview:(UIView *)view atIndex:(NSInteger)index {
	[super insertSubview:view atIndex:index];
	[self sv_sendViewsToBack];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
	[super setSelected:selected animated:animated];
	[self sv_sendViewsToBack];
}

- (void)setSelected:(BOOL)selected {
	[super setSelected:selected];
	[self sv_sendViewsToBack];
}

/////////////////////////////////////////////////////////////////////////////
// Private
/////////////////////////////////////////////////////////////////////////////

- (void)sv_sendViewsToBack {
	if (self.leftBackgroundCellView) {
		[self sendSubviewToBack:self.leftBackgroundCellView];
	}
	if (self.rightBackgroundCellView) {
		[self sendSubviewToBack:self.rightBackgroundCellView];
	}
}

- (UIView*)sv_shownBackgroundCellViewWithDestinationPoint:(CGPoint)destinationPoint {
	if (destinationPoint.x > 0)
		return self.leftBackgroundCellView;
	else if (destinationPoint.x < 0)
		return self.rightBackgroundCellView;
	return nil;
}

#pragma mark - UIGestureRecognizer

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
	if ([gestureRecognizer isKindOfClass:[UIPanGestureRecognizer class]]) {
		UIPanGestureRecognizer* panGestureRecognizer = (UIPanGestureRecognizer*)gestureRecognizer;
		CGPoint destinationPoint = [panGestureRecognizer translationInView:self];
		return [self sv_shownBackgroundCellViewWithDestinationPoint:destinationPoint] != nil;
	}
	return NO;
}

- (void)sv_swipe:(UIPanGestureRecognizer*)gestureRecognizer {
	if (gestureRecognizer.state == UIGestureRecognizerStateBegan) {
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
		
		[contentLayer addAnimation:translationAnimation forKey:@"position"];
		CGPathRelease(path);
		
		contentFrame.origin.x = 0;
		contentLayer.frame = contentFrame;
		contentLayer.shadowOpacity = 0.0;
	}
	
	else {
		CGPoint destinationPoint = [gestureRecognizer translationInView:self];
		UIView* shownBackgroundCell = [self sv_shownBackgroundCellViewWithDestinationPoint:destinationPoint];
		if (shownBackgroundCell) {
			if (shownBackgroundCell == self.leftBackgroundCellView) {
				self.leftBackgroundCellView.hidden = NO;
			}
			else {
				self.leftBackgroundCellView.hidden = YES;
			}
			CGRect contentViewFrame = self.contentView.frame;
			contentViewFrame.origin.x = destinationPoint.x;
			self.contentView.frame = contentViewFrame;
		}
	}
}


#pragma mark - CAAnimation delegate


@end
