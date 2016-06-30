//
//  FlowLayout.m
//  Calendar
//
//  Created by beyondSoft on 16/6/27.
//  Copyright © 2016年 beyondSoft. All rights reserved.
//

#import "FlowLayout.h"
#define screenWidth [UIScreen mainScreen].bounds.size.width
@implementation FlowLayout

- (instancetype)init{
    self = [super init];
    if (self) {

        self.itemSize = CGSizeMake((screenWidth ) / 7, 53);
        self.minimumInteritemSpacing = 0;

        self.minimumLineSpacing = 0;
        self.sectionInset = UIEdgeInsetsMake(0, 0, 0, 0);
    }
    return self;
}


- (NSArray<UICollectionViewLayoutAttributes *> *)layoutAttributesForElementsInRect:(CGRect)rect{

    NSMutableArray * attributes = [[super layoutAttributesForElementsInRect:rect] mutableCopy];
    //为了解决出现竖线间隔线
    //从第二个循环到最后一个
    for (NSUInteger i = 1; i < [attributes count]; i++) {
       //当前attribute
        UICollectionViewLayoutAttributes * currentAttr = attributes[i];
        //前一个attribute
        UICollectionViewLayoutAttributes * prevAttrX = attributes[i - 1];
       //设置的最大间距
        NSInteger maxSpacing = 0;
        //前一个cell的最右边的x值
        NSInteger originX = CGRectGetMaxX(prevAttrX.frame);
       //如果前一个cell的最右边+我们想要的间距+当前cell的width依然在contentSize中，我们改变当前cell的原点位置
        //不加这个判断的后果是，UICollectionView只显示一行，原因是下面所有cell的X值被加到第一行最后一个元素的后面
        if (originX + maxSpacing + currentAttr.frame.size.width < self.collectionViewContentSize.width) {
            CGRect frame = currentAttr.frame;
            frame.origin.x = originX + maxSpacing;
            currentAttr.frame = frame;
        }
    }
    return attributes;
}

@end
