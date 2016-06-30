//
//  CollectionViewCell.m
//  Calendar
//
//  Created by beyondSoft on 16/6/22.
//  Copyright © 2016年 beyondSoft. All rights reserved.
//

#import "CollectionViewCell.h"

@implementation CollectionViewCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setDate:(NSDate*)date calendar:(NSCalendar*)calendar{
    NSString* day = @"";
    NSString* accessibilityDay = @"";
    if (date && calendar) {
       // _date = date;
        day = [CollectionViewCell formatDate:date withCalendar:calendar];
        accessibilityDay = [CollectionViewCell formatAccessibilityDate:date withCalendar:calendar];
    }
   
    self.dateLabel.text = day;
    self.dateLabel.accessibilityLabel = accessibilityDay;
}

+ (NSString *)formatDate:(NSDate *)date withCalendar:(NSCalendar *)calendar
{
    NSDateFormatter *dateFormatter = [self dateFormatter];
    return [CollectionViewCell stringFromDate:date withDateFormatter:dateFormatter withCalendar:calendar];
}

+ (NSDateFormatter *)dateFormatter {
    static NSDateFormatter *dateFormatter;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        dateFormatter = [[NSDateFormatter alloc] init];
        dateFormatter.dateFormat = @"d";
    });
    return dateFormatter;
}

+ (NSString *)stringFromDate:(NSDate *)date withDateFormatter:(NSDateFormatter *)dateFormatter withCalendar:(NSCalendar *)calendar {
    //Test if the calendar is different than the current dateFormatter calendar property
    if (![dateFormatter.calendar isEqual:calendar]) {
        dateFormatter.calendar = calendar;
    }
    return [dateFormatter stringFromDate:date];
}

+ (NSString *)formatAccessibilityDate:(NSDate *)date withCalendar:(NSCalendar *)calendar
{
    NSDateFormatter *dateFormatter = [self accessibilityDateFormatter];
    return [CollectionViewCell stringFromDate:date withDateFormatter:dateFormatter withCalendar:calendar];
}

+ (NSDateFormatter *)accessibilityDateFormatter {
    static NSDateFormatter *dateFormatter;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateStyle:NSDateFormatterLongStyle];
        [dateFormatter setTimeStyle:NSDateFormatterNoStyle];

    });
    return dateFormatter;
}

@end
