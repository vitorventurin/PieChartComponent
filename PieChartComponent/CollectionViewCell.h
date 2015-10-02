//
//  CollectionViewCell.h
//
//  Created by Vitor Venturin on 14/08/15.
//  Copyright (c) 2015 Vitor Venturin. All rights reserved.
//
//  http://github.com/vitorventurin

#import <UIKit/UIKit.h>

@interface CollectionViewCell : UICollectionViewCell

@property (strong, nonatomic) IBOutlet UILabel *amountLabel;
@property (nonatomic, weak) IBOutlet UILabel* titleInfoLabel;
@property (nonatomic, weak) IBOutlet UILabel* percentageLabel;

@end
