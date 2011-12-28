//
//  RBTreeNode.m
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

#import "RBTreeNode.h"


@implementation RBTreeNode 

@synthesize object = _object;
@synthesize depth = _depth;
@synthesize parent = _parent;
@synthesize children = _children;

- (id)initWithObject:(id)object andDepth:(int)depth;
{
	self = [super init];
    if (self) 
	{
		self.object = object;
		self.depth = depth;
        self.children = [NSMutableArray array];
    }
    return self;
}

- (id)initWithObject:(id)object
{
	return [self initWithObject:object andDepth:0];
}

- (id)init
{
	return [self initWithObject:nil andDepth:-1];
}

- (void)dealloc
{
	_parent = nil;
    [_object release], _object = nil;
    [_children release], _children = nil;
    [super dealloc];
}

- (void)removeChild:(RBTreeNode *)node
{
	[_children removeObject:node];
}

- (NSArray *)flattenNodes 
{
    NSMutableArray *allNodes = [[[NSMutableArray alloc] initWithCapacity:[self.children count]] autorelease];
	
	if (self.depth > -1) // Don't include root element
	{
		[allNodes addObject:self];
	}
	
    for (RBTreeNode *child in self.children) {
        [allNodes addObjectsFromArray:[child flattenNodes]];
    }
	
    return allNodes;
}

@end
