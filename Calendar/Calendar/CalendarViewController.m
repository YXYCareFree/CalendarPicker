//
//  CalendarViewController.m
//  Calendar
//
//  Created by beyondSoft on 16/6/22.
//  Copyright © 2016年 beyondSoft. All rights reserved.
//

#import "CalendarViewController.h"
#import "CollectionViewCell.h"
#import "CalendarViewHeader.h"
#import "FlowLayout.h"

static NSString * const reuseCell = @"reuseCell";
static NSString * const reuseHeaderCell = @"reuseCell";

static const NSCalendarUnit kCalendarUnitYMD = NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay;
#define screenWidth [UIScreen mainScreen].bounds.size.width

@interface CalendarViewController ()<UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout>

@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;

@property (nonatomic, strong) NSCalendar * calendar;

@property (nonatomic) NSDate *firstDateMonth;

@property (nonatomic) NSDate *lastDateMonth;

@property (nonatomic, assign) NSUInteger daysPerWeek;

@property (nonatomic, strong) NSDateFormatter *headerDateFormatter;

@property (nonatomic, strong) NSDate *firstDate;

@property (nonatomic, strong) NSDate *lastDate;

@property (nonatomic, strong) NSIndexPath * startIndexPath;

@property (nonatomic, strong) NSIndexPath * endIndexPath;

@property (nonatomic, strong) NSDateFormatter * headerDate;
//选择的开始日期
@property (nonatomic, strong) NSString * startDay;
//选择的结束日期
@property (nonatomic, strong) NSString * endDay;

@end

@implementation CalendarViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    _daysPerWeek = 7;
    _endIndexPath = nil;
    _startIndexPath = nil;

    self.collectionView.backgroundColor = [UIColor whiteColor];
    //先注册cell和headerView再注册collectionView否则collectionView的内容无显示
    [self.collectionView registerClass:[CollectionViewCell class] forCellWithReuseIdentifier:reuseCell];
    [self.collectionView registerClass:[CalendarViewHeader class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:reuseHeaderCell];
    [self.collectionView registerNib:[UINib nibWithNibName:@"CollectionViewCell" bundle:[NSBundle mainBundle]] forCellWithReuseIdentifier:reuseCell];

    FlowLayout * flowLayout = [FlowLayout new];
    self.collectionView.collectionViewLayout = flowLayout;
    
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;

}
#pragma mark - UICollectionViewDataSource
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    return [self.calendar components:NSCalendarUnitMonth fromDate:self.firstDateMonth toDate:self.lastDateMonth options:0].month + 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{

    NSDate *firstOfMonth = [self firstOfMonthForSection:section];
    NSCalendarUnit weekCalendarUnit = [self weekCalendarUnitDependingOniOSVersion];
    NSRange rangeOfWeeks = [self.calendar rangeOfUnit:weekCalendarUnit inUnit:NSCalendarUnitMonth forDate:firstOfMonth];
    //We need the number of calendar weeks for the full months (it will maybe include previous month and next months cells)
    return (rangeOfWeeks.length * self.daysPerWeek);
}
#pragma mark - UICollectionViewDelegate
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{

    BOOL isToday = NO;

    CollectionViewCell * cell = [collectionView dequeueReusableCellWithReuseIdentifier:reuseCell forIndexPath:indexPath];

    NSDate *firstOfMonth = [self firstOfMonthForSection:indexPath.section];
    NSDate *cellDate = [self dateForCellAtIndexPath:indexPath];

    NSDateComponents *cellDateComponents = [self.calendar components:kCalendarUnitYMD fromDate:cellDate];
    NSDateComponents *firstOfMonthsComponents = [self.calendar components:kCalendarUnitYMD fromDate:firstOfMonth];

    isToday = [self isTodayDate:cellDate];
    if (isToday) {
        [cell setBackgroundColor:[UIColor redColor]];
    }

    if (cellDateComponents.month == firstOfMonthsComponents.month){

        [cell setDate:cellDate calendar:self.calendar];

    }else{
        [cell setDate:nil calendar:nil];
    }

    //解决cell的复用显示问题需要初始化普通的cell
    cell.userInteractionEnabled = YES;
    cell.backgroundColor = [UIColor whiteColor];
    //无日期的cell不让点击
    if ([cell.dateLabel.text isEqualToString:@""]) {
        cell.userInteractionEnabled = NO;
    }

    if (self.startIndexPath != indexPath && self.endIndexPath != indexPath) {
        cell.dayLabel.text = @"";
    }
    if ([indexPath compare:self.startIndexPath] == NSOrderedDescending && [indexPath compare:self.endIndexPath] == NSOrderedAscending) {

        //cell.userInteractionEnabled = NO;
        if (!cell.dateLabel.text.length) {

            cell.backgroundColor = [UIColor whiteColor];
        }else{

        cell.backgroundColor = [UIColor grayColor];
        }
    }
    if ([indexPath compare:self.startIndexPath] == NSOrderedSame) {
        cell.backgroundColor = [UIColor redColor];
        cell.dayLabel.text = @"开始时间";
    }
    if ([indexPath compare:self.endIndexPath] == NSOrderedSame) {
        cell.backgroundColor = [UIColor redColor];
        cell.dayLabel.text = @"结束时间";
    }

    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{

    CollectionViewCell * cell = (CollectionViewCell *)[collectionView cellForItemAtIndexPath:indexPath];

    if (self.startIndexPath && self.endIndexPath) {
        self.startIndexPath = nil;
        self.endIndexPath = nil;
        _startDay = nil;
        _endDay = nil;
    }

    if (self.startIndexPath) {

        //点击的日期大于开始日期
        if ([indexPath compare:self.startIndexPath] == NSOrderedDescending) {

            _endDay = cell.dateLabel.text;
            self.endIndexPath = indexPath;
            cell.dayLabel.text = @"结束时间";
            cell.backgroundColor = [UIColor redColor];
            [self.collectionView reloadData];
        }
        if ([indexPath compare:self.startIndexPath] == NSOrderedAscending) {

            _startDay = cell.dateLabel.text;
            cell.dateLabel.text = @"开始时间";
            cell.backgroundColor = [UIColor redColor];
            self.startIndexPath = indexPath;
            [self.collectionView reloadData];
        }

    }else{

        _startDay = cell.dateLabel.text;
        cell.dayLabel.text = @"开始时间";
        cell.backgroundColor = [UIColor redColor];
        self.startIndexPath = indexPath;
        [self.collectionView reloadData];
    }

    [self initSelectDay];
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath{

    if (kind == UICollectionElementKindSectionHeader) {
        CalendarViewHeader * headerView = [self.collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:reuseHeaderCell forIndexPath:indexPath];
        headerView.layer.shouldRasterize = YES;
        headerView.layer.rasterizationScale = [UIScreen mainScreen].scale;
        headerView.title.text = [self.headerDateFormatter stringFromDate:[self firstOfMonthForSection:indexPath.section]].uppercaseString;
        return headerView;
    }
    return nil;
}

#pragma mark - 赋值起止日期
- (void)initSelectDay{

    if (self.startIndexPath && self.endIndexPath) {

        NSString * startStr = [self.headerDateFormatter stringFromDate:[self firstOfMonthForSection:_startIndexPath.section]].uppercaseString;
        _startDay = [NSString stringWithFormat:@"%@ %@", _startDay, startStr];

        NSString * endStr = [self.headerDateFormatter stringFromDate:[self firstOfMonthForSection:_endIndexPath.section]].uppercaseString;
        _endDay = [NSString stringWithFormat:@"%@ %@", _endDay, endStr];
    }

    NSLog(@"startDay==%@, endDay==%@", _startDay, _endDay);
}

#pragma mark - CollectionViewFlowLayoutDelegate

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForFooterInSection:(NSInteger)section{
    return CGSizeMake(0, 0);
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section{
    return CGSizeMake(screenWidth, 40);
}
#pragma mark -Calendar calculations
- (BOOL)isTodayDate:(NSDate *)date
{
    return [self clampAndCompareDate:date withReferenceDate:[NSDate date]];
}

- (BOOL)clampAndCompareDate:(NSDate *)date withReferenceDate:(NSDate *)referenceDate
{
    NSDate *refDate = [self clampDate:referenceDate toComponents:kCalendarUnitYMD];
    NSDate *clampedDate = [self clampDate:date toComponents:kCalendarUnitYMD];

    return [refDate isEqualToDate:clampedDate];
}

- (NSDate *)clampDate:(NSDate *)date toComponents:(NSUInteger)unitFlags
{
    NSDateComponents *components = [self.calendar components:unitFlags fromDate:date];
    return [self.calendar dateFromComponents:components];
}

#pragma mark - Collection View / Calendar Methods

- (NSDate *)firstOfMonthForSection:(NSInteger)section
{
    NSDateComponents *offset = [NSDateComponents new];
    offset.month = section;

    return [self.calendar dateByAddingComponents:offset toDate:self.firstDateMonth options:0];
}

- (NSCalendarUnit)weekCalendarUnitDependingOniOSVersion {
    //isDateInToday is a new (awesome) method available on iOS8 only.
    if ([self.calendar respondsToSelector:@selector(isDateInToday:)]) {
        return NSCalendarUnitWeekOfMonth;
    } else {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
        return NSWeekCalendarUnit;
#pragma clang diagnostic pop
    }
}

- (NSDate *)dateForCellAtIndexPath:(NSIndexPath *)indexPath
{
    NSDate *firstOfMonth = [self firstOfMonthForSection:indexPath.section];

    NSUInteger weekday = [[self.calendar components: NSCalendarUnitWeekday fromDate: firstOfMonth] weekday];
    NSInteger startOffset = weekday - self.calendar.firstWeekday;
    startOffset += startOffset >= 0 ? 0 : self.daysPerWeek;

    NSDateComponents *dateComponents = [NSDateComponents new];
    dateComponents.day = indexPath.item - startOffset;

    return [self.calendar dateByAddingComponents:dateComponents toDate:firstOfMonth options:0];
}

#pragma mark -懒加载
- (NSDateFormatter *)headerDateFormatter;
{
    if (!_headerDateFormatter) {
        _headerDateFormatter = [[NSDateFormatter alloc] init];
        _headerDateFormatter.calendar = self.calendar;
        //设置时间格式为中文
        _headerDateFormatter.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"zh_CN"];
        _headerDateFormatter.dateFormat = [NSDateFormatter dateFormatFromTemplate:@"yyyy LLLL" options:0 locale:self.calendar.locale];
    }
    return _headerDateFormatter;
}

- (NSCalendar *)calendar{
    if (!_calendar) {
        [self setCalendar:[NSCalendar currentCalendar]];
    }
    return _calendar;
}

- (NSDate *)firstDateMonth
{
    if (_firstDateMonth) { return _firstDateMonth; }

    NSDateComponents *components = [self.calendar components:kCalendarUnitYMD fromDate:self.firstDate];
    components.day = 1;

    _firstDateMonth = [self.calendar dateFromComponents:components];

    return _firstDateMonth;
}

- (NSDate *)firstDate
{
    if (!_firstDate) {
        NSDateComponents *components = [self.calendar components:kCalendarUnitYMD fromDate:[NSDate date]];
        components.day = 1;
        _firstDate = [self.calendar dateFromComponents:components];
    }

    return _firstDate;
}

- (NSDate *)lastDate
{
    if (!_lastDate) {
        NSDateComponents *offsetComponents = [[NSDateComponents alloc] init];
        offsetComponents.year = 1;
        offsetComponents.day = -1;
        [self setLastDate:[self.calendar dateByAddingComponents:offsetComponents toDate:self.firstDateMonth options:0]];
    }

    return _lastDate;
}

- (NSDate *)lastDateMonth
{
    if (_lastDateMonth) { return _lastDateMonth; }

    NSDateComponents *components = [self.calendar components:kCalendarUnitYMD fromDate:self.lastDate];
    components.month++;
    components.day = 0;

    _lastDateMonth = [self.calendar dateFromComponents:components];

    return _lastDateMonth;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
