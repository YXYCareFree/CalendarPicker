//
//  CalendarViewHeader.m
//  Calendar
//
//  Created by beyondSoft on 16/6/22.
//  Copyright © 2016年 beyondSoft. All rights reserved.
//

#import "CalendarViewHeader.h"

@implementation CalendarViewHeader

- (void)awakeFromNib {
    // Initialization code


}

- (id)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {

        _title = [[UILabel alloc] init];
        _title.font = [UIFont systemFontOfSize:15];
        _title.textColor = [UIColor grayColor];
        _title.text = @"6月 2016";
        _title.textAlignment = NSTextAlignmentCenter;
        [self addSubview:_title];
        [_title setTranslatesAutoresizingMaskIntoConstraints:NO];
    }
    return self;
}

@end
