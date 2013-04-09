IN CONSTRUCTION

SVSwipeableTableViewCell
===============

This class provides makes it easy to add the swipe feature to a UITableViewCell.
SVSwipeableCell is just a subclass of UITableViewCell and you can subclass it as you would do with a UITableViewCell to provide custom content.

Usage
-----

### Adding an action view ####
    SVActionView* leftView = [[SVActionView alloc] initWithFrame:cell.bounds];
    [cell addLeftActionWithView:leftView];

SVActionView is included with the project as an out of the box action view. 
Trigger anchors and animations are managed for you.
You can customize the view as explained below.

### Removing an action view ###
    [cell removeLeftAction];
    
### Responding to trigger events ###

Just implement the SVSwipeDelegate protocol and implement this method

    - (void)cell:(SVSwipeableTableViewCell*)cell didTriggerAction:(SVSwipeAction)action;

Customization
------------------------

Here are the properties that can be used to customize your cell

#####SVSwipeableTableViewCell#####
    @property (assign, readwrite) BOOL withShadowAnimation;

#####SVActionView#####
    @property (strong, readonly) UILabel* title;
    @property (strong, readonly) SVBubbleView* bubble;

#####SVBubbleView#####
    @property (strong, readwrite) UIColor* innerColor;
    @property (strong, readwrite) UIColor* outerColor;
    
Furthermore, you can add any view as an action view and customize the content as you will.
Just make sure to give the view the same frame as the cell and provide one view per action.
To decide when the action should be triggered and to manage your own animation, this method, part of the delegate protocol must be implemented
Just return YES if you want the action to be triggered if the user releases his finger.

    - (BOOL)cell:(SVSwipeableTableViewCell*)cell didSwipeWithDirection:(SVSwipeDirection)direction offset:(float)offset;
