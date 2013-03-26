//
//  SVSwipeableTableViewCell.h
//  SwipeableCell
//
//  Created by Sébastien Villar on 26/03/13.
//  Copyright (c) 2013 Sébastien Villar. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SVSwipeableTableViewCell : UITableViewCell
@property (strong, readwrite) UIView* leftCellBackgroundView;
@property (strong, readwrite) UIView* rightCellBackgroundView;

- (void)addLeftAction;
- (void)addRightAction;
- (void)removeLeftAction;
- (void)removeRightAction;

@end
