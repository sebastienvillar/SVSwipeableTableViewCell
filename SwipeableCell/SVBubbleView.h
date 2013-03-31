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
@property (nonatomic, assign, readwrite) float innerRadius;
@property (assign, readonly) float outerRadius;
@property (assign, readwrite, getter = isActivated) BOOL activated;
@end
