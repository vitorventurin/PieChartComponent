//
//  ViewController.m
//
//  Created by Vitor Venturin on 14/08/15.
//  Copyright (c) 2015 Vitor Venturin. All rights reserved.
//
//  http://github.com/vitorventurin

#import "ViewController.h"

@interface ViewController ()

@property (weak, nonatomic) IBOutlet PieChartView *pieChartView;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (weak, nonatomic) IBOutlet UIPageControl *pageControl;
@property (nonatomic, strong) PieChartConfiguration* pieChartConfiguration;

@end

@implementation ViewController

BOOL hasInfiniteScroll;
NSMutableArray* infiniteArray;
int lastIndexOfPage;

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        hasInfiniteScroll = YES;
        lastIndexOfPage = -1;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupViews];
}

-(void)setupViews{
    self.collectionView.delegate = self;
    
    
    [self.collectionView registerNib:[UINib nibWithNibName:@"CollectionViewCell" bundle:nil] forCellWithReuseIdentifier:CellIdentifier];
    
    PieChartConfiguration* configuration = [PieChartConfiguration defaultPieChartConfiguration];
    configuration.items = [NSMutableArray arrayWithArray:[PieChartItem mock]];
    self.pieChartConfiguration = configuration;
    
    self.pieChartView.selectedItem = [configuration.items objectAtIndex:0];
    [self.pieChartView setConfiguration:self.pieChartConfiguration];
    
    CGAffineTransform scale = CGAffineTransformMakeRotation(M_PI * 90 / 180);
    self.pieChartView.transform = scale;
    
    self.pageControl.numberOfPages = self.pieChartConfiguration.items.count;
    self.pageControl.currentPage = 0;
    
    UIColor *actualColor = [self.pieChartConfiguration colorForItem:self.pieChartView.selectedItem];
    [self.pageControl setCurrentPageIndicatorTintColor:actualColor];
    
    if (hasInfiniteScroll) {
        infiniteArray = [NSMutableArray arrayWithArray:self.pieChartConfiguration.items];
        PieChartItem* firstItem = self.pieChartConfiguration.items.firstObject;
        PieChartItem* lastItem = self.pieChartConfiguration.items.lastObject;
        
        [infiniteArray insertObject:lastItem atIndex:0];
        [infiniteArray addObject:firstItem];
        
        // scroll to the 2nd page, which is showing the first item.
        [self.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:1 inSection:0] atScrollPosition:UICollectionViewScrollPositionLeft animated:YES];
        
        self.pageControl.numberOfPages = self.pieChartConfiguration.items.count;
        self.pageControl.currentPage = 0;
    }
}

#pragma mark - UICollectionView

- (CGSize)collectionView:(UICollectionView *)collectionView
                  layout:(UICollectionViewLayout *)collectionViewLayout
  sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return CGSizeMake(184, 80);
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    if (hasInfiniteScroll) {
        return infiniteArray.count;
    } else {
        return self.pieChartConfiguration.items.count;
    }
}

-(UICollectionViewCell *)collectionView:(UICollectionView*)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    CollectionViewCell *cell = (CollectionViewCell *)[collectionView dequeueReusableCellWithReuseIdentifier:CellIdentifier forIndexPath:indexPath];
    
    PieChartItem* selectedItem;
    if (hasInfiniteScroll) {
        selectedItem = [infiniteArray objectAtIndex:[indexPath row]];
    } else {
        selectedItem = [self.pieChartConfiguration.items objectAtIndex:[indexPath row]];
    }
    
    //    self.pieChartView.selectedItem = selectedItem;
    
    cell.titleInfoLabel.text = selectedItem.itemTitle;
    cell.amountLabel.text = [NSString stringWithFormat:@"%d%@", selectedItem.amount, @",00"];
    [cell.amountLabel setAdjustsFontSizeToFitWidth:YES];
    cell.percentageLabel.text = [NSString stringWithFormat:@"%.2f%@", selectedItem.percentage*100, @"%"];
    
    UIColor *actualColor = [self.pieChartConfiguration colorForItem:selectedItem];
    [cell.titleInfoLabel setTextColor:actualColor];
    
    return cell;
}

- (void) scrollViewDidScroll:(UIScrollView *)scrollView {
    UIColor *actualColor;
    static CGFloat lastContentOffsetX = FLT_MIN;
    
    if (FLT_MIN == lastContentOffsetX) {
        lastContentOffsetX = scrollView.contentOffset.x;
        return;
    }
    
    CGFloat currentOffsetX = scrollView.contentOffset.x;
    CGFloat currentOffsetY = scrollView.contentOffset.y;
    
    CGFloat pageWidth = scrollView.frame.size.width;
    int indexOfPage = currentOffsetX / pageWidth;
    
    if (hasInfiniteScroll) {
        CGFloat offset = pageWidth * self.pieChartConfiguration.items.count;
        
        // the first page(showing the last item) is visible and user is still scrolling to the left
        if (currentOffsetX < pageWidth && lastContentOffsetX > currentOffsetX) {
            //            lastContentOffsetX = pageWidth * (self.pieChartConfiguration.items.count+1);
            lastContentOffsetX = currentOffsetX + offset;
        }
        // the last page (showing the first item) is visible and the user is still scrolling to the right
        else if (currentOffsetX > offset && lastContentOffsetX < currentOffsetX) {
            lastContentOffsetX = currentOffsetX - offset;
        } else {
            lastContentOffsetX = currentOffsetX;
            self.pageControl.currentPage = indexOfPage-1;
        }
        scrollView.contentOffset = (CGPoint){lastContentOffsetX, currentOffsetY};
        
        actualColor = [self.pieChartConfiguration colorForItem:[infiniteArray objectAtIndex:indexOfPage]];
        [self.pageControl setCurrentPageIndicatorTintColor:actualColor];
        
    } else {
        actualColor = [self.pieChartConfiguration colorForItem:[self.pieChartConfiguration.items objectAtIndex:indexOfPage]];
        [self.pageControl setCurrentPageIndicatorTintColor:actualColor];
        self.pageControl.currentPage = indexOfPage;
    }
}

-(void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    lastIndexOfPage = scrollView.contentOffset.x / scrollView.frame.size.width;
}

-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    int actualIndexOfPage = scrollView.contentOffset.x / scrollView.frame.size.width;
    [self.pieChartView setConfiguration:self.pieChartConfiguration];
    if (lastIndexOfPage != actualIndexOfPage) {
        //        NSLog(@"page changed");
        PieChartItem* selectedItem;
        if (hasInfiniteScroll) {
            selectedItem = [infiniteArray objectAtIndex:actualIndexOfPage];
        } else {
            selectedItem = [self.pieChartConfiguration.items objectAtIndex:actualIndexOfPage];
        }
        self.pieChartView.selectedItem = selectedItem;
    } else {
        // paged to same page
    }
}


@end
