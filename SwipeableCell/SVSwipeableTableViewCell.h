//
//  SVSwipeableTableViewCell.h
//  SwipeableCell
//
//  Created by Sébastien Villar on 26/03/13.
//  Copyright (c) 2013 Sébastien Villar. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SVSwipeableTableViewCell : UITableViewCell
@property (assign, readwrite) BOOL withShadowAnimation;
@property (weak, readwrite) id delegate;

- (void)addLeftActionWithView:(UIView*)view;
- (void)addRightActionWithView:(UIView*)view;
- (void)removeLeftAction;
- (void)removeRightAction;

@end
