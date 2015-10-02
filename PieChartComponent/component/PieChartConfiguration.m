//
//  PieChartConfiguration.m
//
//  Created by Vitor Venturin on 14/08/15.
//  Copyright (c) 2015 Vitor Venturin. All rights reserved.
//
//  http://github.com/vitorventurin

#import "PieChartConfiguration.h"
#import "UIColor+IMC.h"

@implementation PieChartConfiguration

+ (instancetype)defaultPieChartConfiguration {
    static dispatch_once_t once;
    static PieChartConfiguration* sharedInstance;
    dispatch_once(&once, ^{
        sharedInstance = [[self alloc] init];
        sharedInstance.componentColors = @[
                                           [UIColor fundoDeInvestimento],
                                           [UIColor investimentoImobiliario],
                                           [UIColor cdbRendaFixa],
                                           [UIColor previdenciaPrivada],
                                           [UIColor poupanca],
                                           [UIColor superPoupanca],
                                           [UIColor acoes],
                                           ];
        sharedInstance.animationDuration = 0.1;
    });
    return sharedInstance;
}

- (UIColor*)colorForItem:(PieChartItem*)pieChartItem {
    NSInteger indexOfItem = [self.items indexOfObject:pieChartItem];
    NSInteger indexOfColor = indexOfItem % self.componentColors.count;
    return self.componentColors[indexOfColor];
}

@end
