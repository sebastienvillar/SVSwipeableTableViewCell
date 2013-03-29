//
//  SVCellBackground.h
//  SwipeableCell
//
//  Created by Sébastien Villar on 26/03/13.
//  Copyright (c) 2013 Sébastien Villar. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SVBubbleView.h"

@interface SVBackgroundCell : UIView
@property (strong, readonly) UILabel* title;
@property (strong, readonly) SVBubbleView* bubble;
@end
