//
//  SVSwipeableTableViewCell.h
//  SwipeableCell
//
//  Created by Sébastien Villar on 26/03/13.
//  Copyright (c) 2013 Sébastien Villar. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SVSwipeableTableViewCell : UITableViewCell
@property (strong, readwrite) UIView* leftBackgroundCellView;
@property (strong, readwrite) UIView* rightBackgroundCellView;
@property (assign, readwrite) BOOL withShadowAnimation;

- (void)addLeftAction;
- (void)addRightAction;
- (void)removeLeftAction;
- (void)removeRightAction;

@end
