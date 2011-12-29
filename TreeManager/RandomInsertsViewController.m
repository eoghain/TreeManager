//
//  RandomInsertsViewController.m
//  TreeManager
//
//  Created by Rob Booth on 12/28/11.
//
//  Copyright (c) 2001 Rob Booth
//
//  Permission is hereby granted, free of charge, 
//  to any person obtaining a copy of this software 
//  and associated documentation files (the "Software"), 
//  to deal in the Software without restriction, including 
//  without limitation the rights to use, copy, modify, 
//  merge, publish, distribute, sublicense, and/or sell 
//  copies of the Software, and to permit persons to whom 
//  the Software is furnished to do so, subject to the 
//  following conditions:
//
//  The above copyright notice and this permission notice 
//  shall be included in all copies or substantial portions 
//  of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY 
//  KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE 
//  WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR 
//  PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS 
//  OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR 
//  OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR 
//  OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE 
//  SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
//

#import "RandomInsertsViewController.h"
#import "RootViewController.h"

@interface RandomInsertsViewController ()
@property (nonatomic, retain) UIPopoverController *popoverController;
@end

@implementation RandomInsertsViewController

@synthesize toolbar=_toolbar;
@synthesize popoverController=_myPopoverController;
@synthesize treeManager=_treeManager;
@synthesize tableView=_tableView;
@synthesize maxRootNodes=_maxRootNodes;
@synthesize maxChildNodes=_maxChildNodes;
@synthesize maxDepth=_maxDepth;

static int INDENTATION_WIDTH = 25;

static NSString *letters = @"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789";

#pragma mark - Helpers
- (NSString *)genRandStringLength:(int)len 
{	
    NSMutableString *randomString = [NSMutableString stringWithCapacity: len];
	
    for (int i=0; i<len; i++)
	{
		[randomString appendFormat:@"%c", [letters characterAtIndex: rand()%[letters length]]];
	}
	
	return randomString;
}

- (void)insertNodeTreeUnderParent:(NSObject *)parent forDepth:(int)depth
{
	// Generate Random Node
	NSString *node = [NSString stringWithFormat:@"(%d) %@", depth, [self genRandStringLength:10]];
	
	if (parent == nil)
	{
		[_treeManager addObject:node forKey:node];
	}
	else
	{
		[_treeManager addObject:node forKey:node toParent:(NSString *)parent];
	}
	
	if (depth < [self.maxDepth.text intValue]) 
	{
		depth++;
		int randomChildren = 1 + random() %  [self.maxChildNodes.text intValue];
		
		NSLog(@"[%@ %@] Adding:%d children at depth:%d", [self class], NSStringFromSelector(_cmd), randomChildren, depth);
		for (int x = 0; x < randomChildren; x++)
		{
			[self insertNodeTreeUnderParent:node forDepth:depth];
		}
	}
	
}

#pragma mark - IBActions
- (IBAction)insertTest:(id)sender
{
	[self.view endEditing:YES];
	
	CFTimeInterval startTime = CFAbsoluteTimeGetCurrent(); 
	int randomParent = 1 + random() % [self.maxRootNodes.text intValue];
	
	NSLog(@"[%@ %@] Adding:%d parents", [self class], NSStringFromSelector(_cmd), randomParent);
	[_treeManager beginUpdates];
	for (int i = 0; i < randomParent; i++)
	{
		[self insertNodeTreeUnderParent:nil forDepth:0];
	}
	[_treeManager endUpdates];
	
	CFTimeInterval difference = CFAbsoluteTimeGetCurrent() - startTime;
	NSLog(@"[%@ %@] Building Tree Took:%f", [self class], NSStringFromSelector(_cmd), difference);
}

#pragma mark - RBTreeManager Delegate

- (void)treeManagerWillChangeContent:(RBTreeManager *)manager
{
	[_tableView beginUpdates];
}

- (void)treeManager:(RBTreeManager *)manager didChangeObject:(id)object atIndex:(int)index forChangeType:(RBTreeManagerChangeType)type newIndex:(int)newIndex
{
	NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:0];
	NSIndexPath *newIndexPath = [NSIndexPath indexPathForRow:newIndex inSection:0];
	
	switch (type) {
		case RBTreeManagerChangeTypeInsert:
			[_tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationTop];
			break;
			
		case RBTreeManagerChangeTypeDelete:
			[_tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationTop];
			break;
			
		case RBTreeManagerChangeTypeMove:
			[_tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationTop];
			[_tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationTop];
			break;
			
		default:
			break;
	}
}

- (void)treeManagerDidChangeContent:(RBTreeManager *)manager
{
	[_tableView endUpdates];
}

#pragma mark - TableView DataSource

- (void)configureCell:(UITableViewCell *)cell forIndex:(int)index
{
	cell.textLabel.text = (NSString *)[_treeManager objectAtIndex:index];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	return [_treeManager count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath 
{
    static NSString *cellIdentifier = @"NodeCell";
	
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) 
	{
        cell = [[[UITableViewCell alloc] initWithFrame:CGRectZero reuseIdentifier:cellIdentifier] autorelease];
		cell.indentationWidth = INDENTATION_WIDTH;
		cell.autoresizesSubviews = YES;
		cell.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    }
	
	[self configureCell:cell forIndex:indexPath.row];
	
    return cell;
}

#pragma mark - TableView Delegate


- (NSInteger)tableView:(UITableView *)tableView indentationLevelForRowAtIndexPath:(NSIndexPath *)indexPath
{
	return [_treeManager depthOfObjectAtIndex:indexPath.row];
}

#pragma mark - View Lifecycle

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
	self.treeManager = [[RBTreeManager alloc] init];
	[self.treeManager setDelegate:self];
	[self.tableView reloadData];
	self.title = @"Random Inserts";
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
	[super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return YES;
}

/*
 // Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
 - (void)viewDidLoad
 {
 [super viewDidLoad];
 }
 */

- (void)viewDidUnload
{
	[super viewDidUnload];
	
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
	self.popoverController = nil;
}

#pragma mark - TextView Delegate

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    static NSCharacterSet *charSet = nil;
    if(!charSet) {
        charSet = [[[NSCharacterSet characterSetWithCharactersInString:@"0123456789"] invertedSet] retain];
    }
    NSRange location = [string rangeOfCharacterFromSet:charSet];
    return (location.location == NSNotFound);
}

#pragma mark - Managing the popover

- (void)showRootPopoverButtonItem:(UIBarButtonItem *)barButtonItem {
    
    // Add the popover button to the toolbar.
    NSMutableArray *itemsArray = [_toolbar.items mutableCopy];
    [itemsArray insertObject:barButtonItem atIndex:0];
    [_toolbar setItems:itemsArray animated:NO];
    [itemsArray release];
}


- (void)invalidateRootPopoverButtonItem:(UIBarButtonItem *)barButtonItem {
    
    // Remove the popover button from the toolbar.
    NSMutableArray *itemsArray = [_toolbar.items mutableCopy];
    [itemsArray removeObject:barButtonItem];
    [_toolbar setItems:itemsArray animated:NO];
    [itemsArray release];
}


#pragma mark - Memory management

- (void)didReceiveMemoryWarning
{
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (void)dealloc
{
	[_myPopoverController release];
	[_toolbar release];
	[_treeManager release];
	[_tableView release];
	[_maxRootNodes release];
	[_maxChildNodes release];
	[_maxDepth release];
    [super dealloc];
}

@end
