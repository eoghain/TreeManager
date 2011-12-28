//
//  TreeManager.h
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

#import <Foundation/Foundation.h>

@class RBTreeManager;

typedef enum {
	RBTreeManagerChangeTypeInsert = 0,
	RBTreeManagerChangeTypeDelete = 1,
	RBTreeManagerChangeTypeMove = 2
} RBTreeManagerChangeType;

@protocol RBTreeManagerDelegate <NSObject>

- (void)treeManagerWillChangeContent:(RBTreeManager *)manager;
- (void)treeManager:(RBTreeManager *)manager didChangeObject:(id)object atIndex:(int)index forChangeType:(RBTreeManagerChangeType)type newIndex:(int)newIndex;
- (void)treeManagerDidChangeContent:(RBTreeManager *)manager;

@end

@class RBTreeNode;

@interface RBTreeManager : NSObject {
    NSMutableDictionary	*_objectToNode;
	NSArray				*_orderedNodes;
	RBTreeNode			*_rootNode;
	BOOL				_updating;
	int					_inserts;
	int					_deletes;
}

@property (nonatomic, assign) id<RBTreeManagerDelegate> delegate;

- (void)addObject:(id)object forKey:(id)key;
- (void)addObject:(id)object forKey:(id)key withComparator:(NSComparisonResult (^)(id, id))sortBlock;
- (void)addObject:(id)object forKey:(id)key toParent:(id)parent;
- (void)addObject:(id)object forKey:(id)key toParent:(id)parent withComparator:(NSComparisonResult (^)(id, id))sortBlock;

- (void)removeObjectForKey:(id)key;

- (id)objectAtIndex:(int)index;
- (int)depthOfObjectAtIndex:(int)index;
- (int)depthOfObjectForKey:(id)key;
- (int)count;

- (void)beginUpdates;
- (void)endUpdates;

@end
