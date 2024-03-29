//
//  SVSwipeDelegate.h
//  SwipeableCell
//
//  Created by Sébastien Villar on 29/03/13.
//  Copyright (c) 2013 Sébastien Villar. All rights reserved.
//

typedef enum {
	SVSwipeRightToLeft = 0,
	SVSwipeLeftToRight = 1
} SVSwipeDirection;

typedef enum {
	SVSwipeLeftAction = 0,
	SVSwipeRightAction = 1
} SVSwipeAction;

#import <Foundation/Foundation.h>
@class SVSwipeableTableViewCell;

@protocol SVSwipeDelegate <NSObject>
@optional
- (BOOL)cell:(SVSwipeableTableViewCell*)cell didSwipeWithDirection:(SVSwipeDirection)direction offset:(float)offset;
- (void)cell:(SVSwipeableTableViewCell*)cell didTriggerAction:(SVSwipeAction)action;
- (void)cellDidFinishTriggerAnimation:(SVSwipeableTableViewCell*)cell;
@end
