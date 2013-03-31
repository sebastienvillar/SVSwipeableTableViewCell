//
//  SVSwipeableTableViewCell.h
//  SwipeableCell
//
//  Created by Sébastien Villar on 26/03/13.
//  Copyright (c) 2013 Sébastien Villar. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SVSwipeableTableViewCell : UITableViewCell
@property (strong, readonly) UIView* leftActionView;
@property (strong, readonly) UIView* rightActionView;
@property (assign, readwrite) BOOL withShadowAnimation;
@property (weak, readwrite) id delegate;

- (void)addLeftActionWithView:(UIView*)view;
- (void)addRightActionWithView:(UIView*)view;
- (void)removeLeftAction;
- (void)removeRightAction;

@end
