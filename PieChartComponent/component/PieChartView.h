//
//  PieChartView.h
//
//  Created by Vitor Venturin on 14/08/15.
//  Copyright (c) 2015 Vitor Venturin. All rights reserved.
//
//  http://github.com/vitorventurin

#import <UIKit/UIKit.h>
#import "PieChartConfiguration.h"

@interface PieChartView : UIView

@property (nonatomic, strong) PieChartConfiguration* configuration;
@property(nonatomic,strong) PieChartItem* selectedItem;

@end
