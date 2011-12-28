# TreeManager #
TreeManager is a set of classes built to easily manage hierarchical data in iOS TableViews.  These classes were originally built because of a need to display threaded discussion posts (lots of them) in an iOS application.  Unfortunately TableViews want there data in a flat format (i.e. array) but we all like to have our data reference it's parents/children so we can easily navigate it.  So this was my solution.

To use the TreeMananger just copy the TreeManager.* and TreeNode.* files into your application somewhere.  Once you have the files you can create a new TreeManager object, set its delegate, and start populating it:

		_treeManager = [[TreeManager alloc] init];
		[_treeManager setDelegate:self];
		
		[_treeManager beginUpdates];
		
		for (int i = 0; i < 3; i++)
		{
			NSString *parentKey = [self genRandStringLength:10];
			NSString *parent = parentKey;

			[_treeManager addObject:parent forKey:parentKey withComparator:^(id lhs, id rhs) { 
				return [((NSString *)lhs) compare:rhs ];
			}];

			int randomChildren = 1 + random() %  2;

			for (int x = 0; x < randomChildren; x++)
			{
				NSString *childKey = [self genRandStringLength:10];
				NSString *child = childKey;

				[_treeManager addObject:child forKey:childKey toParent:parentKey withComparator:^(id lhs, id rhs) { 
					return [((NSString *)lhs) compare:rhs ];
				}];
			}
		}
		
		[_treeManager endUpdates];
		
Next you need to implement the TreeManager delegate methods:

		- (void)treeManagerWillChangeContent:(TreeManager *)manager
		{
			[_tableView beginUpdates];
		}

		- (void)treeManager:(TreeManager *)manager didChangeObject:(id)object atIndex:(int)index forChangeType:(TreeManagerChangeType)type newIndex:(int)newIndex
		{
			NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:0];
			NSIndexPath *newIndexPath = [NSIndexPath indexPathForRow:newIndex inSection:0];

			switch (type) {
				case TreeManagerChangeTypeInsert:
					[_tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationTop];
					break;

				case TreeManagerChangeTypeDelete:
					[_tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationTop];
					break;

				case TreeManagerChangeTypeMove:
					[_tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationTop];
					[_tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationTop];
					break;

				default:
					break;
			}
		}

		- (void)treeManagerDidChangeContent:(TreeManager *)manager
		{
			[_tableView endUpdates];
		}
		
And finally your TableView delegate and datasource methods:

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
		