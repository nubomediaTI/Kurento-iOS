//
//  NBMPeersFlowLayout.m
//  Copyright © 2016 Telecom Italia S.p.A. All rights reserved.
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

#import "NBMPeersFlowLayout.h"

@interface NBMPeersFlowLayout ()

@property (assign, nonatomic) BOOL isActvive;

// Containers for keeping track of changing items
@property (nonatomic, strong) NSMutableArray *insertedIndexPaths;
@property (nonatomic, strong) NSMutableArray *removedIndexPaths;
@property (nonatomic, strong) NSMutableArray *insertedSectionIndices;
@property (nonatomic, strong) NSMutableArray *removedSectionIndices;

// Caches for keeping current/previous attributes
@property (nonatomic, strong) NSMutableDictionary *currentCellAttributes;
@property (nonatomic, strong) NSMutableDictionary *currentSupplementaryAttributesByKind;
@property (nonatomic, strong) NSMutableDictionary *cachedCellAttributes;
@property (nonatomic, strong) NSMutableDictionary *cachedSupplementaryAttributesByKind;

@end

@implementation NBMPeersFlowLayout

- (CGSize)collectionViewContentSize {
    
    return self.collectionView.frame.size;
}

-(BOOL)shouldInvalidateLayoutForBoundsChange:(CGRect)newBounds{
    return YES;
}

- (void)prepareLayout {
    
    // Deep-copy attributes in current cache
    self.cachedCellAttributes = [[NSMutableDictionary alloc] initWithDictionary:self.currentCellAttributes copyItems:YES];
    self.cachedSupplementaryAttributesByKind = [NSMutableDictionary dictionary];
    [self.currentSupplementaryAttributesByKind enumerateKeysAndObjectsUsingBlock:^(NSString *kind, NSMutableDictionary * attribByPath, BOOL *stop) {
        NSMutableDictionary * cachedAttribByPath = [[NSMutableDictionary alloc] initWithDictionary:attribByPath copyItems:YES];
        [self.cachedSupplementaryAttributesByKind setObject:cachedAttribByPath forKey:kind];
    }];
    
    self.minimumInteritemSpacing = 2;
    self.minimumLineSpacing = 2;
}

- (void)invalidateLayout {
    
    [super invalidateLayout];
    self.isActvive = NO;
}

+ (NSUInteger )columnsWithWithNumberOfItems:(NSUInteger )numbers isPortrait:(BOOL)isPortrait{
    
    int countOfColumns = -1;
    
    if (isPortrait) {
        
        if (numbers <= 2 ){
            
            countOfColumns = 1;
        }
        else if (numbers <= 6) {
            
            countOfColumns = 2;
        }
        else {
            
            countOfColumns = 3;
        }
    }
    else {
        
        if (numbers == 1 ) {
            
            countOfColumns = 1;
            
        } else if (numbers <= 2 || numbers == 4) {
            
            countOfColumns = 2;
            
        } else if (numbers == 3 || numbers == 5) {
            
            countOfColumns = 3;
            
        } else {
            
            countOfColumns = 4;
        }
    }
    
    return countOfColumns;
}

+ (CGRect)frameForWithNumberOfItems:(NSUInteger)numberOfItems row:(NSUInteger)row contentSize:(CGSize)contentSize {
    
    BOOL isPortrait = contentSize.width < contentSize.height;
    NSUInteger columns = [NBMPeersFlowLayout columnsWithWithNumberOfItems:numberOfItems
                                                 isPortrait:isPortrait];
    NSUInteger border = 4;
    
    NSUInteger rows = ceil((float)numberOfItems / (float)columns);
    
    CGFloat h = (contentSize.height - ((rows + 1) * border)) / rows;
    CGFloat w = (contentSize.width - ((columns + 1) * border)) / columns ;
    
    NSUInteger line = row == 0 ? 0 : row / columns;
    NSUInteger _r = row % columns;
    
    NSUInteger xOffset = (w * _r)  ;
    NSUInteger yOffset = (line == 0 ? 0 : h * line ) ;
    
    NSUInteger xBorderOffset = border * (_r + 1) ;
    
    NSUInteger yBorderOffset = border * (line + 1);
    
    NSUInteger mod = numberOfItems % columns;
    
    NSUInteger centered = numberOfItems - mod;
    
    if (row >= centered) {
        
        CGFloat centerX = contentSize.width / 2;
        xBorderOffset = centerX - mod * w/2;
        
    }
    
    CGRect result = CGRectMake(xOffset + xBorderOffset , yOffset+ yBorderOffset, w , h);
    
    return result;
}

- (NSArray *)layoutAttributesForElementsInRect:(CGRect)rect {
    
    NSArray *attributes = [super layoutAttributesForElementsInRect:rect];
    
    NSInteger items = [self.collectionView.dataSource collectionView:self.collectionView
                                              numberOfItemsInSection:0];
    
    [attributes enumerateObjectsUsingBlock:^(UICollectionViewLayoutAttributes * attributes, NSUInteger idx, BOOL * stop) {

        CGRect frame  = [NBMPeersFlowLayout frameForWithNumberOfItems:items
                                                                   row:idx
                                                           contentSize:self.collectionView.frame.size];
        
        if (attributes.representedElementCategory == UICollectionElementCategoryCell)
        {
            attributes.frame = frame;
            [self.currentCellAttributes setObject:attributes
                                           forKey:attributes.indexPath];
        }
    }];
    
    return attributes;
}

- (void)finalizeCollectionViewUpdates
{
    [super finalizeCollectionViewUpdates];
    
    self.insertedIndexPaths     = nil;
    self.removedIndexPaths      = nil;
    self.insertedSectionIndices = nil;
    self.removedSectionIndices  = nil;
}

// center last row elements by collectionView center
- (void)centerLastRowElements:(NSArray *)attributes {
    
    CGFloat attributeWidth = ((UICollectionViewLayoutAttributes *)attributes[0]).frame.size.width;
    CGFloat centerX = self.collectionView.center.x;
    CGFloat offsetByX = centerX - attributes.count * attributeWidth/2; // shift by half sum of lowest row elements width
    
    for (NSUInteger i = attributes.count; i != 0; i--) { // from left to right
        // first element will be leftmost at display
        UICollectionViewLayoutAttributes *currentAttribute = attributes[attributes.count - i];
        
        currentAttribute.frame = CGRectMake(offsetByX,
                                            currentAttribute.frame.origin.y,
                                            currentAttribute.frame.size.width,
                                            currentAttribute.frame.size.height);
        
        offsetByX += attributeWidth;
    }
}

/// arrange elements in row by full width
- (void)arrangeLastRowElements:(NSArray *)attributes width:(CGFloat)width {
    
    for (UICollectionViewLayoutAttributes *attribute in attributes) {
        attribute.size = CGSizeMake(width/attributes.count, attribute.size.height);
    }
    
    [self centerLastRowElements:attributes];
    
}

@end