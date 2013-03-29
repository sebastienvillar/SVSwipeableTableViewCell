//
//  SVBubbleView.h
//  SwipeableCell
//
//  Created by Sébastien Villar on 26/03/13.
//  Copyright (c) 2013 Sébastien Villar. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SVBubbleView : UIView
@property (strong, readwrite) UIColor* innerColor;
@property (strong, readwrite) UIColor* outerColor;

//Private
@property (assign, readwrite) float innerRadius;
@property (assign, readwrite) float outerRadius;
@end
