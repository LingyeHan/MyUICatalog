//
//  Created by 玄叶
//

#import "HLSegmentedControl.h"

#pragma mark - Constants

const NSUInteger kHLSegmentedControlFixedNum = 5;
const UIEdgeInsets kHLSegmentedControlSegmentTitleEdgeInsets = {7.0, 0, 0, 0};

@implementation HLSegmentItem

@end

@interface HLSegmentedControl ()

@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, assign, readonly) CGFloat segmentWidth;
@property (nonatomic, strong) CAShapeLayer *shapeLayer;
@property (nonatomic, strong) NSMutableArray *segmentViews;

@end

@implementation HLSegmentedControl
{
    NSInteger _lastSelectedSegmentIndex;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.opaque = YES;
        self.backgroundColor = [UIColor colorWithHex:0x2d3845];
        
        _lastSelectedSegmentIndex = UISegmentedControlNoSegment;
        _selectedSegmentIndex = UISegmentedControlNoSegment;
        _segmentViews = [[NSMutableArray alloc] init];
        
        _shapeLayer = [[CAShapeLayer alloc] init];
        [_shapeLayer setFillColor:[kHLColorRed CGColor]];
        [self.layer addSublayer:_shapeLayer];
        
        _scrollView = [[UIScrollView alloc] initWithFrame:frame];
        _scrollView.delegate = self;
        _scrollView.scrollsToTop = NO;
        _scrollView.pagingEnabled = NO;
        _scrollView.decelerationRate = UIScrollViewDecelerationRateFast;
        _scrollView.backgroundColor = UIColor.clearColor;
        _scrollView.showsHorizontalScrollIndicator = NO;
        _scrollView.showsVerticalScrollIndicator = NO;
        // 解决事件与Button冲突
        _scrollView.userInteractionEnabled = YES;
        _scrollView.exclusiveTouch = YES;

        [self addSubview:_scrollView];
        
        _segmentWidth = frame.size.width / kHLSegmentedControlFixedNum;
        
        for (int i = 0; i < 2; i++)
        {
            UIView *maskView = [[UIView alloc] initWithFrame:CGRectMake(i * ((self.frame.size.width - _segmentWidth)/2 + _segmentWidth), 0, (self.frame.size.width - _segmentWidth)/2, self.frame.size.height)];
            
            maskView.backgroundColor = [UIColor colorWithWhite:.2 alpha:.5];
            maskView.userInteractionEnabled = NO;
            [self addSubview:maskView];
        }
    }
    return self;
}

- (void)setItems:(NSArray *)items
{
    _items = [items copy];
    if (self.scrollView) {
        [self.scrollView removeAllSubviews];
        [self.segmentViews removeAllObjects];
    }
    
    __weak typeof(self)weakSelf = self;
    [_items enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        HLSegmentItem *segmentItem = (HLSegmentItem *)obj;
        
        [weakSelf insertSegmentWithTitle:segmentItem.title subTitle:segmentItem.subTitle animated:NO];
    }];
    [self drawArrow];

    _items = nil;
}

#pragma mark - Draw paths

- (void)drawArrow
{
    CGRect rect = self.frame;
    
    CGFloat rectWidth = _segmentWidth;
    CGFloat arrowHeight = 7.0f;
    CGFloat arrowWidth = 18.0f;
 
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathMoveToPoint(path, NULL, 0, 0);
    CGPathAddLineToPoint(path, NULL, rectWidth, 0);
    CGPathAddLineToPoint(path, NULL, rectWidth, rect.size.height);
    CGPathAddLineToPoint(path, NULL, (rectWidth/2+arrowWidth/2), rect.size.height);
    CGPathAddLineToPoint(path, NULL, rectWidth/2, rect.size.height+arrowHeight);
    CGPathAddLineToPoint(path, NULL, rectWidth/2-arrowWidth/2, rect.size.height);
    CGPathAddLineToPoint(path, NULL, 0, rect.size.height);
    CGPathAddLineToPoint(path, NULL, 0, 0);
    
    _shapeLayer.path = path;
    CGPathRelease(path);
    
    [_shapeLayer setFrame:CGRectMake(0, 0, rectWidth, rect.size.height)];
    [_shapeLayer setPosition:CGPointMake((rect.size.width)/2, _shapeLayer.position.y)];
}

- (void)handleSelect:(HLSegmentView *)sender
{
    NSUInteger index = [self.segmentViews indexOfObject:sender];
    if (index != NSNotFound && index != self.selectedSegmentIndex) {
        self.type = HLSegmentedControlTypeTapped;
        [self setSelectedSegmentIndex:index animated:YES];
    }
}

- (void)notifyForSegmentChangeToIndex:(NSInteger)index
{
    [self sendActionsForControlEvents:UIControlEventValueChanged];
    if (self.indexChangeBlock) {
        self.indexChangeBlock(index, self.type);
    }
}

#pragma mark - UIKit API

- (NSUInteger)numberOfSegments
{
    return self.segmentViews.count;
}

- (void)setSelectedSegmentIndex:(NSInteger)index
{
    [self setSelectedSegmentIndex:index animated:NO];
}

- (void)setSelectedSegmentIndex:(NSInteger)index animated:(BOOL)animated
{
    index = MAX(MIN(index, self.segmentViews.count - 1), 0);
    if (_selectedSegmentIndex != index) {
        _lastSelectedSegmentIndex = _selectedSegmentIndex;
        _selectedSegmentIndex = index;
        
        if (animated) {
            [UIView animateWithDuration:0.4 animations:^{
                [self layoutSegments];
            }];
        } else {
            [self setNeedsLayout];
        }
    }
}

# pragma mark - Private

- (void)insertSegmentWithTitle:(NSString *)title subTitle:(NSString *)subTitle animated:(BOOL)animated
{
    HLSegmentView *segmentView = HLSegmentView.new;
    [segmentView addTarget:self action:@selector(handleSelect:) forControlEvents:UIControlEventTouchUpInside];
    [segmentView setTitle:title forState:UIControlStateNormal];
    [segmentView setSubTitle:subTitle];
    
    [self.scrollView addSubview:segmentView];
    [self.segmentViews addObject:segmentView];
    
    if (animated) {
        [UIView animateWithDuration:0.4 animations:^{
             [self layoutSegments];
         }];
    } else {
        [self setNeedsLayout];
    }
}

- (void)layoutSubviews
{
    [self layoutSegments];
}

- (HLSegmentView *)segmentAtIndex:(NSUInteger)index
{
    NSParameterAssert(index < self.segmentViews.count);
    if (index < [self.segmentViews count])
    {
        return self.segmentViews[index];
    }
    else
    {
        return nil;
    }
}

- (void)layoutSegments
{
    CGFloat totalItemWidth = 0;
    
    for (HLSegmentView *item in self.segmentViews) {
        item.frame = CGRectMake(totalItemWidth, 0, _segmentWidth, CGRectGetHeight(self.frame));
        totalItemWidth += _segmentWidth;
    }
    
    CGSize contentSize = self.scrollView.contentSize;
    contentSize.width = totalItemWidth;
    contentSize.height = self.bounds.size.height;
    self.scrollView.contentSize = contentSize;
    UIEdgeInsets contentInset = _scrollView.contentInset;
    contentInset.left = _segmentWidth * 2;
    contentInset.right = contentInset.left;
    self.scrollView.contentInset = contentInset;
    
    // Scroll
    if (_selectedSegmentIndex != UISegmentedControlNoSegment) {
        [self notifyForSegmentChangeToIndex:_selectedSegmentIndex];//notify
        if (_lastSelectedSegmentIndex != UISegmentedControlNoSegment) {
            HLSegmentView *segmentView = [self segmentAtIndex:_lastSelectedSegmentIndex];
            
            segmentView.selected = NO;
            
            CABasicAnimation *anim = [CABasicAnimation animationWithKeyPath:@"transform"];
            anim.duration = .2;
            anim.fromValue = [NSValue valueWithCATransform3D:CATransform3DMakeScale(1.2, 1.2, 1)];
            anim.toValue = [NSValue valueWithCATransform3D:CATransform3DMakeScale(1.0, 1.0, 1)];
            anim.removedOnCompletion=NO;
            anim.fillMode=kCAFillModeForwards;
            
            [segmentView.titleLabel.layer addAnimation:anim forKey:nil];

        }
        
        HLSegmentView *segmentView = [self segmentAtIndex:_selectedSegmentIndex];
        
        segmentView.selected = NO;
        
        
        CAKeyframeAnimation *keyAnima = [CAKeyframeAnimation animation];
        keyAnima.keyPath = @"transform";
        
        NSValue *value0 = [NSValue valueWithCATransform3D:CATransform3DMakeScale(1.1, 1.1, 1)];
        NSValue *value1 = [NSValue valueWithCATransform3D:CATransform3DMakeScale(1.2, 1.2, 1)];
        NSValue *value2 = [NSValue valueWithCATransform3D:CATransform3DMakeScale(1.3, 1.3, 1)];
        NSValue *value3 = [NSValue valueWithCATransform3D:CATransform3DMakeScale(1.3, 1.3, 1)];
        NSValue *value4 = [NSValue valueWithCATransform3D:CATransform3DMakeScale(1.25, 1.25, 1)];
        NSValue *value5 = [NSValue valueWithCATransform3D:CATransform3DMakeScale(1.2, 1.2, 1)];
        keyAnima.values = @[value0, value1 ,value2 ,value3 ,value4 ,value5];
        keyAnima.removedOnCompletion = NO;
        keyAnima.fillMode = kCAFillModeForwards;
        keyAnima.duration = .4;
        [segmentView.titleLabel.layer addAnimation:keyAnima forKey:nil];

        CGPoint contentOffset = self.scrollView.contentOffset;
        contentOffset.x = -self.scrollView.contentInset.left + _segmentWidth * _selectedSegmentIndex;
        [self.scrollView setContentOffset:contentOffset animated:YES];
    }
}

- (void)dynamicScrollView:(CGFloat)xOffset
{
    CGPoint contentOffset = self.scrollView.contentOffset;
    contentOffset.x = -self.scrollView.contentInset.left + xOffset * 0.2;
    self.scrollView.contentOffset = contentOffset;
}

- (void)notifyAndAdjustsPosition:(UIScrollView *)scrollView
{
    self.scrollingBySelection = YES;
    self.type = HLSegmentedControlTypeScrolling;
    NSUInteger index = roundf((scrollView.contentInset.left + scrollView.contentOffset.x) / _segmentWidth);
    [self setSelectedSegmentIndex:index];
    
    // 还原Dragging不到下一个Segment位置
    if (index == self.selectedSegmentIndex) {
        CGPoint contentOffset = self.scrollView.contentOffset;
        contentOffset.x = -self.scrollView.contentInset.left + self.segmentWidth * index;
        [self.scrollView setContentOffset:contentOffset animated:YES];
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    if (!decelerate) {
        [self notifyAndAdjustsPosition:scrollView];
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    [self notifyAndAdjustsPosition:scrollView];
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView
{
    self.scrollingBySelection = NO;
}

@end

//////////////////////////////////////////////////////////////////////////////////////////////////////////////

@interface HLSegmentView ()

@property (nonatomic, strong) UILabel *subTitleLabel;

@end

@implementation HLSegmentView

+ (HLSegmentView *)new
{
    return [self.class buttonWithType:UIButtonTypeCustom];
}

- (id)initWithFrame:(CGRect)frame
{
    if ((self = [super initWithFrame:frame])) {
        [self setTitleColor:[UIColor colorWithWhite:1.000 alpha:1] forState:UIControlStateNormal];

        self.titleLabel.font = [UIFont fontWithName:kHLFontAvenirHeavy size:16];
        
        self.userInteractionEnabled = YES;
        self.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
        self.contentVerticalAlignment = UIControlContentVerticalAlignmentTop;
        self.titleEdgeInsets = kHLSegmentedControlSegmentTitleEdgeInsets; // Space between text and image
        self.contentEdgeInsets = UIEdgeInsetsMake(0, 4, 0, 4); // Enlarge touchable area
        
        self.subTitleLabel = [[UILabel alloc] init];
        self.subTitleLabel.backgroundColor = [UIColor clearColor];
        self.subTitleLabel.textAlignment = NSTextAlignmentCenter;
        self.subTitleLabel.textColor = [self titleColorForState:UIControlStateNormal];//NNDX 用initialize方法不起作用
        self.subTitleLabel.font = [UIFont boldSystemFontOfSize:11];;
        [self addSubview:self.subTitleLabel];
    }
    return self;
}

- (void)setSubTitle:(NSString *)subTitle
{
    self.subTitleLabel.text = subTitle;
    [self.subTitleLabel sizeToFit];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    self.subTitleLabel.frame = CGRectMake(0, self.titleLabel.frame.origin.y+self.titleLabel.frame.size.height-2, CGRectGetWidth(self.frame), CGRectGetHeight(self.subTitleLabel.frame));
}

@end
