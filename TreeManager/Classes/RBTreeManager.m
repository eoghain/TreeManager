//
//  TreeManager.m
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

#import "RBTreeManager.h"
#import "RBTreeNode.h"


@implementation RBTreeManager

@synthesize delegate = _delegate;

- (id)init 
{
    self = [super init];
    if (self) 
	{
        _objectToNode	= [[NSMutableDictionary dictionary] retain];
		_orderedNodes	= [[NSArray array] retain];
		_rootNode		= [[RBTreeNode alloc] init];
		_updating		= NO;
		_inserts		= 0;
		_deletes		= 0;
    }
    return self;
}

- (void)dealloc 
{
    _delegate = nil;
    [_objectToNode release], _objectToNode = nil;
    [_orderedNodes release], _orderedNodes = nil;
	[_rootNode release], _rootNode = nil;
    [super dealloc];
}

#pragma mark - Private

- (void)orderNodes
{
	if (_delegate && [_delegate respondsToSelector:@selector(treeManagerWillChangeContent:)])
	{
		[_delegate treeManagerWillChangeContent:self];
	}
	
	NSArray *newOrder = [[_rootNode flattenNodes] retain];
	
	// Report Changes
	if (_delegate && 
		[_delegate respondsToSelector:@selector(treeManager:didChangeObject:atIndex:forChangeType:newIndex:)])
	{
		for (RBTreeNode *node in newOrder)
		{
			int newIndex = [newOrder indexOfObject:node];
			if (![_orderedNodes containsObject:node])
			{
				[_delegate treeManager:self 
					   didChangeObject:node.object 
							   atIndex:newIndex 
						 forChangeType:RBTreeManagerChangeTypeInsert 
							  newIndex:newIndex];
				continue;
			}
			
			if ([_orderedNodes indexOfObject:node] != [newOrder indexOfObject:node])
			{
				[_delegate treeManager:self 
					   didChangeObject:node.object 
							   atIndex:[_orderedNodes indexOfObject:node] 
						 forChangeType:RBTreeManagerChangeTypeMove 
							  newIndex:newIndex];
			}
		}
		
		for (RBTreeNode *node in _orderedNodes)
		{
			if (![newOrder containsObject:node])
			{
				int index = [_orderedNodes indexOfObject:node];
				[_delegate treeManager:self 
					   didChangeObject:node.object 
							   atIndex:index 
						 forChangeType:RBTreeManagerChangeTypeDelete 
							  newIndex:index];
			}
		}
	}
	
	// Replace old order with new order
	[_orderedNodes release];
	_orderedNodes = newOrder;
	
	_inserts = 0;
	_deletes = 0;
	
	if (_delegate && [_delegate respondsToSelector:@selector(treeManagerDidChangeContent:)])
	{
		[_delegate treeManagerDidChangeContent:self];
	}
}

- (RBTreeNode *)addObject:(id)object forKey:(id)key toNode:(RBTreeNode *)parentNode withComparator:(NSComparisonResult (^)(id, id))sortBlock
{
	RBTreeNode *node = [[RBTreeNode alloc] initWithObject:object andDepth:parentNode.depth + 1];
	
	if (sortBlock != nil)
	{
		bool inserted = NO;
		for (RBTreeNode *child in parentNode.children) 
		{
			if (sortBlock(object, child.object) == NSOrderedAscending)
			{
				inserted = YES;
				int index = [parentNode.children indexOfObject:child];
				[parentNode.children insertObject:node atIndex:index];
				break;
			}
		}
		
		if (!inserted)
		{
			[parentNode.children addObject:node];
		}
	}
	else
	{
		[parentNode.children addObject:node];
	}
	
	[node setParent:parentNode];
	[_objectToNode setObject:node forKey:key];
	
	if (!_updating)
	{
		[self orderNodes];
	}
	else
	{
		_inserts++;
	}
	
	return [node autorelease];
}

#pragma mark - Public

- (void)addObject:(id)object forKey:(id)key toParent:(id)parent
{
	RBTreeNode *parentNode = [_objectToNode objectForKey:parent];
	[self addObject:object forKey:key toNode:parentNode withComparator:nil];
}

- (void)addObject:(id)object forKey:(id)key toParent:(id)parent withComparator:(NSComparisonResult (^)(id, id))sortBlock
{
	RBTreeNode *parentNode = [_objectToNode objectForKey:parent];
	[self addObject:object forKey:key toNode:parentNode withComparator:sortBlock];
}

- (void)addObject:(id)object forKey:(id)key
{
	[self addObject:object forKey:key toNode:_rootNode withComparator:nil];
}

- (void)addObject:(id)object forKey:(id)key withComparator:(NSComparisonResult (^)(id, id))sortBlock
{
	[self addObject:object forKey:key toNode:_rootNode withComparator:sortBlock];
}

- (void)removeObjectForKey:(id)key
{
	RBTreeNode *node = [_objectToNode objectForKey:key];
	
	[node.parent removeChild:node];
	[_objectToNode removeObjectForKey:key];
	
	if (!_updating)
	{
		[self orderNodes];
	}
	else
	{
		_deletes++;
	}
}

- (id)objectAtIndex:(int)index
{
	RBTreeNode *node = [_orderedNodes objectAtIndex:index];
	return node.object;
}

- (int)depthOfObjectAtIndex:(int)index
{
	RBTreeNode *node = [_orderedNodes objectAtIndex:index];
	return node.depth;
}

- (int)depthOfObjectForKey:(id)key
{
	RBTreeNode *node = [_objectToNode objectForKey:key];
	return node.depth;
}

- (int)depthOfObject:(id)object
{
	RBTreeNode *node = [_objectToNode objectForKey:object];
	return node.depth;
}

- (int)count 
{
	return [_objectToNode count];
}

- (void)beginUpdates
{
	_updating = YES;
}

- (void)endUpdates
{
	// Don't do the expensive operation if nothing has changed
	if (_inserts > 0 || _deletes > 0)
	{
		[self orderNodes];
	}
	
	_updating = NO;
}

@end
