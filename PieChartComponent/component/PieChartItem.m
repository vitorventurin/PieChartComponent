//
//  PieChartInformation.m
//
//  Created by Vitor Venturin on 14/08/15.
//  Copyright (c) 2015 Vitor Venturin. All rights reserved.
//
//  http://github.com/vitorventurin

#import "PieChartItem.h"

@implementation PieChartItem

+ (NSArray*)mock {
    return @[
             [self itemWithTitle:@"investment fund" amount:1000 percentage:0.1],
             [self itemWithTitle:@"real estate investment" amount:1000 percentage:0.1],
             [self itemWithTitle:@"fixed income" amount:1000 percentage:0.1],
             [self itemWithTitle:@"private pension" amount:1000 percentage:0.1],
             [self itemWithTitle:@"savings" amount:1000 percentage:0.1],
             [self itemWithTitle:@"super savings" amount:3000 percentage:0.3],
             [self itemWithTitle:@"actions" amount:2000 percentage:0.2],
             ];
}

+ (instancetype)itemWithTitle:(NSString*)title amount:(NSInteger)amount percentage:(CGFloat)percentage {
    PieChartItem* item = [[PieChartItem alloc] init];
    item.itemTitle = title;
    item.amount = amount;
    item.percentage = percentage;
    return item;
}

@end
