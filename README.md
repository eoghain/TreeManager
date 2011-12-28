# RBTreeManager #
RBTreeManager is a set of classes built to easily manage hierarchical data in iOS TableViews.  These classes were originally built because of a need to display threaded discussion posts (lots of them) in an iOS application.  Unfortunately TableViews want there data in a flat format (i.e. array) but we all like to have our data reference it's parents/children so we can easily navigate it.  So this was my solution.

To use the TreeMananger just copy the RBTreeManager.* and TreeNode.* files into your application somewhere.  Once you have the files you can create a new RBTreeManager object, set its delegate, and start populating it:

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
		
Next you need to implement the RBTreeManager delegate methods:

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
		
And finally your TableView delegate and datasource methods:

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
		
# To Do #
* Add more tests showing other aspects of RBTreeManager
* Implement breadth first navigation so that different types tree's can be displayed.