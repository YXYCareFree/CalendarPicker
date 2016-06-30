//
//  CollectionViewCell.h
//  Calendar
//
//  Created by beyondSoft on 16/6/22.
//  Copyright © 2016年 beyondSoft. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CollectionViewCell : UICollectionViewCell
@property (weak, nonatomic) IBOutlet UILabel *dayLabel;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;

- (void)setDate:(NSDate*)date calendar:(NSCalendar*)calendar;
@end
