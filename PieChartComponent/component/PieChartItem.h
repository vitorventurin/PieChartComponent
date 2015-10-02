//
//  PieChartInformation.h
//
//  Created by Vitor Venturin on 14/08/15.
//  Copyright (c) 2015 Vitor Venturin. All rights reserved.
//
//  http://github.com/vitorventurin

#import <UIKit/UIKit.h>

@interface PieChartItem : NSObject

@property (nonatomic, copy) NSString *itemTitle;
@property (nonatomic) NSInteger amount;
@property (nonatomic) CGFloat percentage;

+(NSArray*)mock;
+(instancetype)itemWithTitle:(NSString*)title amount:(NSInteger)amount percentage:(CGFloat)percentage;

@end
