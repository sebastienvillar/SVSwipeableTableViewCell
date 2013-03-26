//
//  SVSwipeableTableViewCell.m
//  SwipeableCell
//
//  Created by Sébastien Villar on 26/03/13.
//  Copyright (c) 2013 Sébastien Villar. All rights reserved.
//

#import "SVSwipeableTableViewCell.h"
#import "SVCellBackground.h"

@implementation SVSwipeableTableViewCell
@synthesize leftCellBackground = _leftCellBackground,
			rightCellBackground = _rightCellBackground;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
		self.backgroundColor = [UIColor clearColor];
    }
    return self;
}

#pragma mark - Public methods

- (void)addLeftAction {
	if (!self.leftCellBackground) {
		self.leftCellBackground = [[SVCellBackground alloc] initWithFrame:self.bounds];
	}
	if (!self.leftCellBackground.superview) {
		[self insertSubview:self.leftCellBackground belowSubview:self.contentView];
	}
	self.leftCellBackground.hidden = NO;
	self.leftCellBackground.backgroundColor = [UIColor redColor];
}

- (void)removeLeftAction {
	if (self.leftCellBackground) {
		[self.leftCellBackground removeFromSuperview];
		self.leftCellBackground = nil;
	}
}

- (void)addRightAction {
	if (!self.rightCellBackground) {
		self.rightCellBackground = [[SVCellBackground alloc] initWithFrame:self.bounds];
	}
	if (!self.rightCellBackground.superview) {
		UIView* view = self.contentView;
		if (self.leftCellBackground) 
			view = self.leftCellBackground;
		
		[self insertSubview:self.rightCellBackground belowSubview:view];
	}
	self.rightCellBackground.hidden = NO;
	self.rightCellBackground.backgroundColor = [UIColor greenColor];
}

- (void)removeRightAction {
	if (self.rightCellBackground) {
		[self.rightCellBackground removeFromSuperview];
		self.rightCellBackground = nil;
	}
}


#pragma mark - Overwritten methods

- (void)insertSubview:(UIView *)view atIndex:(NSInteger)index {
	[super insertSubview:view atIndex:index];
	if (self.leftCellBackground) {
		[self sendSubviewToBack:self.leftCellBackground];
	}
	if (self.rightCellBackground) {
		[self sendSubviewToBack:self.rightCellBackground];
	}
}

@end
