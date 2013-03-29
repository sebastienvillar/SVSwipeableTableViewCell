//
//  SVActionDelegate.h
//  SwipeableCell
//
//  Created by Sébastien Villar on 29/03/13.
//  Copyright (c) 2013 Sébastien Villar. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SVSwipeDelegate.h"
#import "SVActionView.h"

@interface SVActionDelegate : NSObject <SVSwipeDelegate>
@property (strong, readwrite) SVActionView* leftActionView;
@property (strong, readwrite) SVActionView* rightActionView;
@end
