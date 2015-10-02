//
//  ViewController.h
//
//  Created by Vitor Venturin on 14/08/15.
//  Copyright (c) 2015 Vitor Venturin. All rights reserved.
//
//  http://github.com/vitorventurin

#import <UIKit/UIKit.h>
#import "PieChartConfiguration.h"
#import "PieChartView.h"
#import "PieChartItem.h"
#import "CollectionViewCell.h"

static NSString *CellIdentifier = @"PieChartItemId";
@interface ViewController : UIViewController <UICollectionViewDataSource, UICollectionViewDelegate>

@end

