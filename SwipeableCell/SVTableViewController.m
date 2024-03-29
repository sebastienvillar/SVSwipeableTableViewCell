//
//  SVTableViewController.m
//  SwipeableCell
//
//  Created by Sébastien Villar on 26/03/13.
//  Copyright (c) 2013 Sébastien Villar. All rights reserved.
//

#import "SVTableViewController.h"
#import "SVSwipeableTableViewCell.h"
#import "SVActionView.h"

@interface SVTableViewController ()
@property (strong, readonly) NSMutableArray* data;

@end

@implementation SVTableViewController
@synthesize data = _data;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
		_data = [[NSMutableArray alloc] init];
		for (int i = 0; i < 15; i++) {
			[_data addObject:[NSString stringWithFormat:@"Row %d", i]];
		}
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	[self.tableView registerClass:[SVSwipeableTableViewCell class] forCellReuseIdentifier:@"Cell"];
	self.tableView.canCancelContentTouches = NO;
	self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	return self.data.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    SVSwipeableTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    cell.textLabel.text = [self.data objectAtIndex:indexPath.row];
	cell.textLabel.backgroundColor = [UIColor clearColor];
	cell.delegate = self;
	SVActionView* leftView = [[SVActionView alloc] initWithFrame:cell.bounds];
	SVActionView* rightView = [[SVActionView alloc] initWithFrame:cell.bounds];
	[cell addLeftActionWithView:leftView];
	[cell addRightActionWithView:rightView];
	cell.withShadowAnimation = YES;
    return cell;
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

#pragma mark - Table view delegate

- (CGFloat)tableView:(UITableView*)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	return 60;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here. Create and push another view controller.
    /*
     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     */
}

- (BOOL)cell:(SVSwipeableTableViewCell *)cell didSwipeWithDirection:(SVSwipeDirection)direction offset:(float)offset {
	if (offset > 100) {
		return YES;
	}
	return NO;
}

- (void)cell:(SVSwipeableTableViewCell *)cell didTriggerAction:(SVSwipeAction)action {
	if (action == SVSwipeLeftAction) {
		cell.leftActionView.backgroundColor = [UIColor redColor];
		cell.withShadowAnimation = NO;
	}
	else {
		cell.leftActionView.backgroundColor = [UIColor yellowColor];
		cell.withShadowAnimation = YES;
	}
}

- (void)cellDidFinishTriggerAnimation:(UITableViewCell *)cell {
	NSLog(@"did finish animation");
}

@end
