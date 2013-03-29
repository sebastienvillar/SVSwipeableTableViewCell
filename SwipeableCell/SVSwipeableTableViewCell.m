//
//  SVSwipeableTableViewCell.m
//  SwipeableCell
//
//  Created by Sébastien Villar on 26/03/13.
//  Copyright (c) 2013 Sébastien Villar. All rights reserved.
//

#import "SVSwipeableTableViewCell.h"
#import "SVBackgroundCell.h"
#import "SVBubbleView.h"

#import <QuartzCore/QuartzCore.h>

#define kSwipeEndAnimationOffset 10
#define kSwipeEndAnimationDuration 0.4
#define kTriggerDistance 25

@interface SVSwipeableTableViewCell ()
@property (assign, readwrite, getter = sv_isSwiping) BOOL sv_swiping;
@property (assign, readwrite, getter = sv_isAnimating) BOOL sv_animating;
@property (assign, readwrite) CGPoint sv_beginLeftTriggerPoint;
@property (assign, readwrite) CGPoint sv_beginRightTriggerPoint;
@property (assign, readwrite) CGPoint sv_leftTriggerPoint;
@property (assign, readwrite) CGPoint sv_rightTriggerPoint;
@end

@implementation SVSwipeableTableViewCell
@synthesize leftBackgroundCellView = _leftBackgroundCellView,
			rightBackgroundCellView = _rightBackgroundCellView,
			sv_swiping = _sv_swiping,
			sv_animating = _sv_animating,
			withShadowAnimation = _withShadowAnimation,
			sv_beginLeftTriggerPoint = _sv_beginLeftTriggerPoint,
			sv_beginRightTriggerPoint = sv_beginRightTriggerPoint,
			sv_leftTriggerPoint = _sv_leftTriggerPoint,
			sv_rightTriggerPoint = _sv_rightTriggerPoint;

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
		[self addObserver:self forKeyPath:@"frame" options:NSKeyValueObservingOptionNew context:nil];
		_sv_swiping = NO;
		_withShadowAnimation = NO;
		_sv_animating = NO;
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
	SVBackgroundCell* view = (SVBackgroundCell*)self.leftBackgroundCellView;
	[view addObserver:self forKeyPath:@"title.text" options:NSKeyValueObservingOptionNew context:nil];
	[view addObserver:self forKeyPath:@"title.attributedText" options:NSKeyValueObservingOptionNew context:nil];
	[view addObserver:self forKeyPath:@"title.font" options:NSKeyValueObservingOptionNew context:nil];
	view.title.text = @"Action";
	view.title.frame = CGRectMake(10, 0, 125, view.frame.size.height);
}

- (void)removeLeftAction {
	if (self.leftBackgroundCellView) {
		[self.leftBackgroundCellView removeFromSuperview];
		[self.leftBackgroundCellView removeObserver:self forKeyPath:@"title.text"];
		[self.leftBackgroundCellView removeObserver:self forKeyPath:@"title.attributedText"];
		[self.leftBackgroundCellView removeObserver:self forKeyPath:@"title.font"];
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
	SVBackgroundCell* view = (SVBackgroundCell*)self.rightBackgroundCellView;
	[view addObserver:self forKeyPath:@"title.text" options:NSKeyValueObservingOptionNew context:nil];
	[view addObserver:self forKeyPath:@"title.attributedText" options:NSKeyValueObservingOptionNew context:nil];
	[view addObserver:self forKeyPath:@"title.font" options:NSKeyValueObservingOptionNew context:nil];
	view.title.text = @"Action";
	view.title.frame = CGRectMake(view.frame.size.width - 125 - 10, 0, 125, view.frame.size.height);
}

- (void)removeRightAction {
	if (self.rightBackgroundCellView) {
		[self.rightBackgroundCellView removeFromSuperview];
		[self.rightBackgroundCellView removeObserver:self forKeyPath:@"title.text"];
		[self.rightBackgroundCellView removeObserver:self forKeyPath:@"title.attributedText"];
		[self.rightBackgroundCellView removeObserver:self forKeyPath:@"title.font"];
		self.rightBackgroundCellView = nil;
	}
}

#pragma mark - Overwritten

- (void)insertSubview:(UIView *)view atIndex:(NSInteger)index {
	[super insertSubview:view atIndex:index];
	[self sv_sendViewsToBack];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
	if (!self.sv_isAnimating) {
		[super setSelected:selected animated:animated];
		[self sv_sendViewsToBack];
	}
}

- (void)setSelected:(BOOL)selected {
	if (!self.sv_isAnimating) {
		[super setSelected:selected];
		[self sv_sendViewsToBack];
	}
}

/////////////////////////////////////////////////////////////////////////////
// Private
/////////////////////////////////////////////////////////////////////////////

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
	if ([keyPath isEqualToString:@"frame"]) {
		CGRect shadowRect = CGRectInset(self.contentView.layer.frame, 0, 0);
		self.contentView.layer.shadowPath = CGPathCreateWithRect(shadowRect, NULL);
	}
	else if ([keyPath hasPrefix:@"title"]) {
		if (object == self.leftBackgroundCellView) {
			SVBackgroundCell* view = (SVBackgroundCell*)self.leftBackgroundCellView;
			UILabel* label = view.title;
			label.frame = CGRectMake(10, 0, 125, view.frame.size.height);
			CGSize textSize = [label.text sizeWithFont:label.font];
			if (textSize.width > label.frame.size.width) {
				textSize.width = label.frame.size.width;
			}
			float outerRadius = view.bubble.outerRadius;
			view.bubble.frame = CGRectMake(textSize.width + 18, view.frame.size.height / 2 - outerRadius, outerRadius*2, outerRadius*2);
			self.sv_beginLeftTriggerPoint = CGPointMake(view.bubble.frame.origin.x + view.bubble.frame.size.width + 5, 0);
			self.sv_leftTriggerPoint = CGPointMake(self.sv_beginLeftTriggerPoint.x + kTriggerDistance, self.sv_beginLeftTriggerPoint.y);
		}
		else {
			SVBackgroundCell* view = (SVBackgroundCell*)self.rightBackgroundCellView;
			UILabel* label = view.title;
			label.textAlignment = NSTextAlignmentRight;
			label.frame = CGRectMake(view.frame.size.width - 125 - 10, 0, 125, view.frame.size.height);
			CGSize textSize = [label.text sizeWithFont:label.font];
			if (textSize.width > label.frame.size.width) {
				textSize.width = label.frame.size.width;
			}
			float outerRadius = view.bubble.outerRadius;
			view.bubble.frame = CGRectMake(view.frame.size.width - textSize.width - 18 - outerRadius*2, view.frame.size.height / 2 - outerRadius, outerRadius*2, outerRadius*2);
			self.sv_beginRightTriggerPoint = CGPointMake(view.bubble.frame.origin.x - 5, 0);
			self.sv_rightTriggerPoint = CGPointMake(self.sv_beginRightTriggerPoint.x - kTriggerDistance, self.sv_beginRightTriggerPoint.y);
		}
	}	
}

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
		if (self.sv_isAnimating) {
			return NO;
		}
		UIPanGestureRecognizer* panGestureRecognizer = (UIPanGestureRecognizer*)gestureRecognizer;
		CGPoint destinationPoint = [panGestureRecognizer translationInView:self];
		return [self sv_shownBackgroundCellViewWithDestinationPoint:destinationPoint] != nil;
	}
	return NO;
}

- (void)sv_swipe:(UIPanGestureRecognizer*)gestureRecognizer {
	if (gestureRecognizer.state == UIGestureRecognizerStateBegan) {
		if (self.selected) {
			[self setSelected:NO animated:NO];
		}
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
		[contentLayer addAnimation:translationAnimation forKey:@"position"];
		CGPathRelease(path);
		
		SVBackgroundCell* view = (SVBackgroundCell*)[self sv_shownBackgroundCellViewWithDestinationPoint:contentFrame.origin];
		if (view == self.leftBackgroundCellView) {
			if (contentFrame.origin.x > self.sv_leftTriggerPoint.x) {
				NSLog(@"trigger left");
			}
		}
		else {
			if ((contentFrame.origin.x + contentFrame.size.width) < self.sv_rightTriggerPoint.x) {
				NSLog(@"trigger right");
			}
		}
		
		contentFrame.origin.x = 0;
		contentLayer.frame = contentFrame;
		contentLayer.shadowOpacity = 0.0;
		}
	
	else {
		CGPoint destinationPoint = [gestureRecognizer translationInView:self];
		UIView* shownBackgroundCell = [self sv_shownBackgroundCellViewWithDestinationPoint:destinationPoint];
		if (shownBackgroundCell) {
			CGRect contentViewFrame = self.contentView.frame;
			contentViewFrame.origin.x = destinationPoint.x;
			self.contentView.frame = contentViewFrame;

			if (shownBackgroundCell == self.leftBackgroundCellView) {
				self.leftBackgroundCellView.hidden = NO;
				SVBackgroundCell* view = (SVBackgroundCell*)self.leftBackgroundCellView;
				if (contentViewFrame.origin.x > self.sv_beginLeftTriggerPoint.x) {
					float ratio = (contentViewFrame.origin.x - self.sv_beginLeftTriggerPoint.x) / (self.sv_leftTriggerPoint.x - self.sv_beginLeftTriggerPoint.x);
					view.bubble.innerRadius = ratio * view.bubble.outerRadius;
				}
				else
					view.bubble.innerRadius = 0;

			}
			else {
				self.leftBackgroundCellView.hidden = YES;
				SVBackgroundCell* view = (SVBackgroundCell*)self.rightBackgroundCellView;
				if (contentViewFrame.origin.x + contentViewFrame.size.width < self.sv_beginRightTriggerPoint.x) {
					float ratio = (self.sv_beginRightTriggerPoint.x - (contentViewFrame.origin.x + contentViewFrame.size.width)) / (self.sv_beginRightTriggerPoint.x - self.sv_rightTriggerPoint.x);
					view.bubble.innerRadius = ratio * view.bubble.outerRadius;
				}
				else
					view.bubble.innerRadius = 0;
			}
		}
	}
}


#pragma mark - CAAnimation delegate

- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag {
	if (flag) {
		if ([[anim valueForKey:@"name"] isEqual:@"position"]) {
			self.sv_animating = NO;
			((SVBackgroundCell*)self.leftBackgroundCellView).bubble.innerRadius = 0;
			((SVBackgroundCell*)self.rightBackgroundCellView).bubble.innerRadius = 0;
		}
	}
}
@end
