# RBTreeManager #
RBTreeManager is a set of classes built to easily manage hierarchical data in iOS TableViews.  These classes were originally built because of a need to display threaded discussion posts (lots of them) in an iOS application.  Unfortunately TableViews want there data in a flat format (i.e. array) but we all like to have our data reference it's parents/children so we can easily navigate it.  So this was my solution.

To use the TreeMananger just copy the RBTreeManager.* and TreeNode.* files into your application somewhere.  Once you have the files you can create a new RBTreeManager object, set its delegate, and start populating it:

```objective-c
		_RBTreeManager = [[RBTreeManager alloc] init];
		[_RBTreeManager setDelegate:self];
		
		[_RBTreeManager beginUpdates];
		
		for (int i = 0; i < 3; i++)
		{
			NSString *parentKey = [self genRandStringLength:10];
			NSString *parent = parentKey;

			[_RBTreeManager addObject:parent forKey:parentKey withComparator:^(id lhs, id rhs) { 
				return [((NSString *)lhs) compare:rhs ];
			}];

			int randomChildren = 1 + random() %  2;

			for (int x = 0; x < randomChildren; x++)
			{
				NSString *childKey = [self genRandStringLength:10];
				NSString *child = childKey;

				[_RBTreeManager addObject:child forKey:childKey toParent:parentKey withComparator:^(id lhs, id rhs) { 
					return [((NSString *)lhs) compare:rhs ];
				}];
			}
		}
		
		[_RBTreeManager endUpdates];
```

Next you need to implement the RBTreeManager delegate methods:

```objective-c
		- (void)RBTreeManagerWillChangeContent:(RBTreeManager *)manager
		{
			[_tableView beginUpdates];
		}

		- (void)RBTreeManager:(RBTreeManager *)manager didChangeObject:(id)object atIndex:(int)index forChangeType:(RBTreeManagerChangeType)type newIndex:(int)newIndex
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

		- (void)RBTreeManagerDidChangeContent:(RBTreeManager *)manager
		{
			[_tableView endUpdates];
		}
```
		
And finally your TableView delegate and datasource methods:

```objective-c
		#pragma mark - TableView DataSource

		- (void)configureCell:(UITableViewCell *)cell forIndex:(int)index
		{
			cell.textLabel.text = (NSString *)[_RBTreeManager objectAtIndex:index];
		}

		- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
		{
			return [_RBTreeManager count];
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
			return [_RBTreeManager depthOfObjectAtIndex:indexPath.row];
		}
```

# API #
## RBTreeManager ##
### addObject:forKey: ###
Adds the supplied object to the root of the tree identified by the supplied key.

```objective-c
- (void)addObject:(id)object forKey:(id)key;
```

**Parameters**
*object*
	>The object to add

*key*
	>The key used to identify this object

**Discussion**
	>This is the main entry point for objects into the root of the tree.  Using this method will at the object at the end of the tree.  If not called between a beginUpdates and endUpdates block, will cause RBTreeManager to rebuild.

***************************************************************************************************************************************

### addObject:forKey:withComparator: ###
Adds the supplied object to the root of the tree identified by the supplied key, places the object based on the sort block supplied

```objective-c
- (void)addObject:(id)object forKey:(id)key withComparator:(NSComparisonResult (^)(id, id))sortBlock;
```

**Parameters**
*object*
	>The object to add

*key*
	>The key used to identify this object

*sortBlock*
	>Block that will be called to place this object into the correct order

**Discussion**
	>This is the main entry point for objects into the root of the tree when sorting of the objects is required.  If not called between a beginUpdates and endUpdates block, will cause RBTreeManager to rebuild.

***************************************************************************************************************************************

### addObject:forKey:toParent: ###
Adds the supplied object under the supplied parent identified by the supplied key

```objective-c
- (void)addObject:(id)object forKey:(id)key toParent:(id)parent;
```

**Parameters**
*object*
	>The object to add

*key*
	>The key used to identify this object

**Discussion**
	>This is the main entry point for objects into the root of the given parent.  Using this method will at the object at the end of the parents children.  If not called between a beginUpdates and endUpdates block, will cause RBTreeManager to rebuild.

***************************************************************************************************************************************

### addObject:forKey:toParent:withComparator: ###
Adds the supplied object to the parent identified by the supplied key, places the object based on the sort block supplied


```objective-c
- (void)addObject:(id)object forKey:(id)key toParent:(id)parent withComparator:(NSComparisonResult (^)(id, id))sortBlock;
```

**Parameters**
*object*
	>The object to add

*key*
	>The key used to identify this object

*sortBlock*
	>Block that will be called to place this object into the correct order

**Discussion**
	>This is the main entry point for objects into the parent when sorting of the objects is required.  If not called between a beginUpdates and endUpdates block, will cause RBTreeManager to rebuild.

***************************************************************************************************************************************

### removeObjectForKey: ###
Removed the object with the specified key from the tree

```objective-c
- (void)removeObjectForKey:(id)key;
```

**Parameters**
*key*
	>The key used to identify this object

**Discussion**
	> Removes the specified object.  If not called between a beginUpdates and endUpdates block, will cause RBTreeManager to rebuild.

***************************************************************************************************************************************

### objectAtIndex: ###
Returns the object at the given index

```objective-c
- (id)objectAtIndex:(int)index;
```

**Parameters**
*index*
	>Integer value corresponding to an index of the flattened tree.  Main use is to get the proper object for a UITableView.

**Return Value**
	>The object stored at the given index

**Discussion**
	>RBTreeManager flattens out a hierarcy of nodes for easy access and placement in a UITableView and this method allows us to get the proper node after flattening.

***************************************************************************************************************************************

### depthOfObjectAtIndex: ###
Returns the integer (0-based) depth of the object at the given index

```objective-c
- (int)depthOfObjectAtIndex:(int)index;
```

**Parameters**
*index*
	>Integer value corresponding to an index of the flattened tree.  Main use is to get the proper object for a UITableView.

**Return Value**
	>An integer representing the depth of the object at the given index

**Discussion**
	>Mainly used in the *tableView:indentationLevelForRowAtIndexPath:* UITableViewDelegate method for proper positioning

***************************************************************************************************************************************

### depthOfObjectForKey: ###
Returns the integer (0-based) depth of the object for the given key

```objective-c
- (int)depthOfObjectForKey:(id)key;
```

**Parameters**
*index*
	>Integer value corresponding to an index of the flattened tree.

**Return Value**
	>An integer representing the depth of the object for the given key

**Discussion**
	>A way of getting the depth of an object when all you have is the key

***************************************************************************************************************************************

### count ###
Returns the integer count of all objects stored in the RBTreeManager

```objective-c
- (int)count;
```

**Discussion**
	>Mainly used in the *tableView:numberOfRowsInSection:* UITableViewDatasource method so your table view knows how many rows it'll need to display

***************************************************************************************************************************************

### beginUpdates ###
Tells the RBTreeManager that you will be doing alot of updates so it shouldn't rebuild the flattend view

```objective-c
- (void)beginUpdates;
```

**Discussion**
	>Flattening out the tree is an expensive operation and so it shouldn't be done if you are doing alot of inserts at once

***************************************************************************************************************************************

### endUpdates ###
Tells the RBTreeManager that you've finished doing your bulk updates and that it's time to rebuild the flattend view

```objective-c
- (void)endUpdates;
```

**Discussion**
	>Flattening out the tree is an expensive operation and so it shouldn't be done if you are doing alot of inserts at once

		
# To Do #
* Add more tests showing other aspects of RBTreeManager
* Implement breadth first navigation so that different types trees can be displayed.