//
//  PieChartView.m
//
//  Created by Vitor Venturin on 14/08/15.
//  Copyright (c) 2015 Vitor Venturin. All rights reserved.
//
//  http://github.com/vitorventurin

#import "PieChartView.h"

typedef enum {
    AnimationStateDeselecting = 0,
    AnimationStateRotating,
    AnimationStateSelecting,
    AnimationStateNoAnimaton,
} AnimationState;

@interface PieChartView()

@property(nonatomic,weak) PieChartItem *lastSelectedItem;
@property(nonatomic,assign) CGFloat animationFrequency;
@property(nonatomic,assign) CGFloat selectedItemSize;
@property(nonatomic,assign) AnimationState animationState;

//Animation
@property(nonatomic,assign) CGFloat animationSizePercentage;
@property(nonatomic,assign) CGFloat animationResizing;
@property(nonatomic,assign) CGFloat animationAngleOffset;
@property(nonatomic,assign) CGFloat animationChangeAngle;
@property(nonatomic,assign) CGFloat animationSumAngle;

@end


@implementation PieChartView

//UITapGestureRecognizer* tapRecognizer;

#pragma mark - init
- (instancetype)initWithCoder:(NSCoder *)aDecoder{
    self = [super initWithCoder:aDecoder];
    if (self) {
        self.animationFrequency = 1.0/90.0;
        self.selectedItemSize = .15;
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}

- (void)layoutSubviews {
    [self setFrame:CGRectMake(10, 40, 120, 120)];
}

- (void)awakeFromNib{
    [super awakeFromNib];

//    tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(viewTapped:)];
//    [self addGestureRecognizer:tapRecognizer];

}

#pragma mark - Actions
-(void)viewTapped:(UITapGestureRecognizer *)gesture{
//    CGPoint point = [gesture locationInView:self];
//    
//    if ([self calculateDistanceFromCenter:point] <= 20) {
//        return;
//    }
//    
//    //Set the point into the right coordinates
//    point = CGPointMake(point.x-self.frame.size.width/2, (self.frame.size.height/2)-point.y);
//    CGFloat angle = [self radiansFromPoint:point];
//    PieChartItem *item = [self itemForAngleInRadians:angle];
//    self.configuration.selectedItem = item;
}

- (float) calculateDistanceFromCenter:(CGPoint)point {
    CGPoint center = CGPointMake(self.bounds.size.width/2, self.bounds.size.height/2);
    float dx = point.x - center.x;
    float dy = point.y - center.y;
    return sqrt(dx*dx + dy*dy);
}

#pragma mark - Setup
- (void)selectionWasChanged {
    //Make Deselection
    NSTimeInterval delay = 0;
    [self performSelector:@selector(prepareForDeselectAnimation) withObject:nil afterDelay:delay];
    
    //Make Rotation
    delay = self.configuration.animationDuration/3.0;
    
    [self performSelector:@selector(prepareForRotationAnimation) withObject:nil afterDelay:delay];
}

- (void)setSelectedItem:(PieChartItem *)selectedItem {
    if (selectedItem != self.lastSelectedItem) {
        _selectedItem = selectedItem;
        [self selectionWasChanged];
        [self reloadData];
    }
}

- (void)setConfiguration:(PieChartConfiguration *)configuration {
    if (configuration != _configuration) {
        _configuration = configuration;
        self.lastSelectedItem = self.selectedItem;
    }
}

- (void)reloadData {
    self.animationState = AnimationStateNoAnimaton;
    [self setNeedsDisplay];
}

#pragma mark - Animation
- (void)animationDeselection{
    [self drawItemsWithSelectedPercentageSize:self.animationSizePercentage > 0?self.animationSizePercentage:0 angleOffset:0];
    if (self.animationSizePercentage>0) {
        self.animationSizePercentage -= self.animationResizing;
        [self performSelector:@selector(setNeedsDisplay) withObject:nil afterDelay:self.animationFrequency];
    }
}

- (void)prepareForDeselectAnimation{
    self.animationResizing = self.selectedItemSize * self.animationFrequency / (self.configuration.animationDuration/3);
    self.animationSizePercentage = self.selectedItemSize;
    self.animationState = AnimationStateDeselecting;
    [self setNeedsDisplay];
}

- (void)animationRotation{
    [self drawItemsWithSelectedPercentageSize:0 angleOffset:self.animationAngleOffset];
    self.animationSumAngle += self.animationChangeAngle;
    if (fabs(self.animationSumAngle) <= fabs([self totalAngleOffset])) {
        self.animationAngleOffset += self.animationChangeAngle;
        [self performSelector:@selector(setNeedsDisplay) withObject:nil afterDelay:self.animationFrequency];
    }else{
        //Update last selected item and make Selection
        [self performSelector:@selector(prepareForSelectAnimation) withObject:nil afterDelay:self.animationFrequency];
    }
}

-(void)prepareForRotationAnimation{
    self.animationState = AnimationStateRotating;
    self.animationSumAngle = 0;
    self.animationAngleOffset = 0;
    self.animationChangeAngle = [self totalAngleOffset] * self.animationFrequency / (self.configuration.animationDuration/3);
    self.animationState = AnimationStateRotating;
    [self setNeedsDisplay];
}

- (void)animationSelection{
    [self drawItemsWithSelectedPercentageSize:self.animationSizePercentage < self.selectedItemSize
     ?self.animationSizePercentage:self.selectedItemSize angleOffset:0];
    if (self.animationSizePercentage<self.selectedItemSize) {
        self.animationSizePercentage += self.animationResizing;
        [self performSelector:@selector(setNeedsDisplay) withObject:nil afterDelay:self.animationFrequency];
    }
}

- (void)prepareForSelectAnimation{
    [self setLastSelectedItem: self.selectedItem];

    self.animationResizing = self.selectedItemSize * self.animationFrequency / (self.configuration.animationDuration/3);
    self.animationSizePercentage = 0;
    self.animationState = AnimationStateSelecting;
    [self setNeedsDisplay];
}

#pragma mark - Drawing
- (void)drawItemsWithSelectedPercentageSize:(CGFloat)selectedPercentage angleOffset:(CGFloat)angleOffset{
    //Big circle
    if (self.lastSelectedItem == nil) {
        self.lastSelectedItem = [self.configuration.items objectAtIndex:0];
    }
    NSUInteger selectedItemIndex = [self.configuration.items indexOfObject:self.lastSelectedItem];
    NSArray *sortedArray = [self.configuration.items subarrayWithRange:NSMakeRange(selectedItemIndex, self.configuration.items.count-selectedItemIndex)];
    sortedArray = [sortedArray arrayByAddingObjectsFromArray:[self.configuration.items subarrayWithRange:NSMakeRange(0, selectedItemIndex)]];
    
    CGFloat lastAngle = angleOffset - (M_PI + [self percentToRadians:self.lastSelectedItem.percentage])/2;
    for (NSUInteger index = 0; index < sortedArray.count; index++) {
        PieChartItem* item = sortedArray[index];
        
        //Colors settings
        CGContextRef context = UIGraphicsGetCurrentContext();
        CGContextSetLineWidth(context,0);
        CGContextSetLineJoin(context, kCGLineJoinRound);
        CGContextSetFillColorWithColor(context,[[self.configuration colorForItem:item] CGColor]);
        
        //Begin Context
        CGContextBeginPath(context);
        
        //Angle settings
        CGFloat radious = self.frame.size.width*.85/2;
        if ([self.lastSelectedItem isEqual:item]) {
            radious += radious * selectedPercentage;
        }
        
        CGFloat toAngle = lastAngle + item.percentage*2*M_PI;
        
        CGContextAddArc(context, self.frame.size.width/2,self.frame.size.height/2,radious,lastAngle,toAngle,NO);
        CGContextAddLineToPoint(context, self.frame.size.width/2,self.frame.size.height/2);
        CGContextClosePath(context);
        CGContextDrawPath(context,kCGPathFillStroke);
        lastAngle = toAngle;
    }
    
    //Small circle
    for (NSUInteger index = 0; index < sortedArray.count; index++) {
        PieChartItem* item = sortedArray[index];
        
        //Colors settings
        CGContextRef context = UIGraphicsGetCurrentContext();
        CGContextSetLineWidth(context,0);
        CGContextSetLineJoin(context, kCGLineJoinRound);
        CGContextSetFillColorWithColor(context,[[UIColor clearColor] CGColor]);
        
        //Begin Context
        CGContextBeginPath(context);
        
        //Angle settings
        CGFloat radious = self.frame.size.width*.52/2;
        if ([self.lastSelectedItem isEqual:item]) {
            radious += radious * selectedPercentage/2;
        }
        
        
        CGFloat toAngle = lastAngle + item.percentage*2*M_PI;
        
        CGContextAddArc(context, self.frame.size.width/2,self.frame.size.height/2,radious,lastAngle,toAngle,NO);
        CGContextAddLineToPoint(context, self.frame.size.width/2,self.frame.size.height/2);
        CGContextClosePath(context);
        CGContextDrawPath(context,kCGPathFillStroke);
        lastAngle = toAngle;
    }
    
    //White small circle
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetLineWidth(context,0);
    CGContextSetLineJoin(context, kCGLineJoinRound);
    CGContextSetFillColorWithColor(context,[[UIColor whiteColor] CGColor]);
    
    CGFloat radious = self.frame.size.width/2;
    radious = radious * 0.4;
    CGContextAddArc(context, self.frame.size.width/2,self.frame.size.height/2,radious,0,2*M_PI,NO);
    CGContextClosePath(context);
    CGContextDrawPath(context,kCGPathFillStroke);
}

- (void)drawRect:(CGRect)rect {
    switch (self.animationState) {
        case AnimationStateNoAnimaton:{
            [self drawItemsWithSelectedPercentageSize:self.selectedItemSize angleOffset:0];
        }
            break;
        case  AnimationStateDeselecting:{
            [self animationDeselection];
        }
            break;
        case  AnimationStateSelecting:{
            [self animationSelection];
        }
            break;
        case  AnimationStateRotating:{
            [self animationRotation];
        }
            break;
        default:
            break;
    }
}

#pragma mark - Angles calcs 
//We can make a math class with this
- (CGFloat)radiansFromPoint:(CGPoint)point{
    CGFloat radian;
    if (point.y >= 0) {
        radian = atan2f(point.y, point.x);
    }else{
        radian =  atan2f(point.y, point.x)+2*M_PI;
    }
    
    //Clockwise change
    radian = 2*M_PI-radian;
    return radian;
}

- (CGFloat)percentToRadians:(CGFloat)percent{
    return percent*2*M_PI;
}
- (CGFloat)percentToDegrees:(CGFloat)percent{
    return percent*360;
}
- (CGFloat)radiansToDegrees:(CGFloat)radians{
    return radians*180/M_PI;
}

- (CGFloat)degreesToRadians:(CGFloat)degrees{
    return degrees*M_PI/180;
}

- (CGFloat)totalAngleOffset{
    //Chequear lasitem vs configuration.item
    NSUInteger selectedItemIndex = [self.configuration.items indexOfObject:self.lastSelectedItem];
    NSArray *sortedArray = [self.configuration.items subarrayWithRange:NSMakeRange(selectedItemIndex, self.configuration.items.count-selectedItemIndex)];
    sortedArray = [sortedArray arrayByAddingObjectsFromArray:[self.configuration.items subarrayWithRange:NSMakeRange(0, selectedItemIndex)]];
    
    CGFloat totalAngle = 0;
    for (NSUInteger index = 0; index < sortedArray.count; index++) {
        PieChartItem* item = sortedArray[index];
        if ([item isEqual:self.lastSelectedItem] || [item isEqual:self.selectedItem]) {
            totalAngle += [self percentToDegrees:item.percentage/2];
            if ([item isEqual:self.selectedItem]) {
                break;
            }
        }else{
            totalAngle += [self percentToDegrees:item.percentage];
        }
    }
    if (totalAngle > 180) {
        totalAngle -= 360;
    }
    return -[self degreesToRadians:totalAngle];
}

//Parameters must be in radians
- (BOOL)angle:(CGFloat )angle isInRangeFrom:(CGFloat)from to:(CGFloat)to{
    
    CGFloat angleNormalized = angle > 0 ? angle: angle + 2*M_PI;
    CGFloat fromNormalized = from > 0 ? from: from + 2*M_PI;
    CGFloat toNormalized = to > 0 ? to: to + 2*M_PI;
    //One cycle completed
    if(toNormalized < fromNormalized){
        if (angleNormalized < toNormalized) {
            angleNormalized += 2*M_PI;
        }
        toNormalized += 2*M_PI;
    }
    return fromNormalized <= angleNormalized && toNormalized >= angleNormalized;
}

- (PieChartItem *)itemForAngleInRadians:(CGFloat)radians{
    CGFloat radiansWithOffset = radians;// - (M_PI + [self percentToRadians:self.lastSelectedItem.percentage])/2;
    
    NSUInteger selectedItemIndex = [self.configuration.items indexOfObject:self.lastSelectedItem];
    NSArray *sortedArray = [self.configuration.items subarrayWithRange:NSMakeRange(selectedItemIndex, self.configuration.items.count-selectedItemIndex)];
    sortedArray = [sortedArray arrayByAddingObjectsFromArray:[self.configuration.items subarrayWithRange:NSMakeRange(0, selectedItemIndex)]];
    
    CGFloat fromAngle = - (M_PI + [self percentToRadians:self.lastSelectedItem.percentage])/2;;
    for (NSUInteger index = 0; index < sortedArray.count; index++) {
        PieChartItem* item = sortedArray[index];
        CGFloat toAngle = fromAngle + [self percentToRadians:item.percentage];
        
        if ([self angle:radiansWithOffset isInRangeFrom:fromAngle to:toAngle]) {
            return item;
        }
        fromAngle = toAngle;
    }
    return nil;
}

@end
