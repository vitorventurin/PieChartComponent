//
//  PieChartConfiguration.h
//
//  Created by Vitor Venturin on 14/08/15.
//  Copyright (c) 2015 Vitor Venturin. All rights reserved.
//
//  http://github.com/vitorventurin

#import <UIKit/UIKit.h>
#import "PieChartItem.h"

@class PieChartConfiguration;

@interface PieChartConfiguration : NSObject

@property (nonatomic, strong) NSArray* componentColors;
@property (nonatomic, strong) NSMutableArray* items;
@property (nonatomic, assign) CGFloat animationDuration;
+(instancetype)defaultPieChartConfiguration;
-(UIColor*)colorForItem:(PieChartItem*)pieChartItem;

@end
