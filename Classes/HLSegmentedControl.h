//
//  Created by 玄叶 on 14/11/24.
//

//#define HLSegmentedControlDebug 1

typedef NS_ENUM(NSInteger, HLSegmentedControlType)//打点用
{
    HLSegmentedControlTypeTapped = 0,
    HLSegmentedControlTypeScrolling = 1,
    HLSegmentedControlTypeScrollingLeft = 2,//相关联的左右滑动
    HLSegmentedControlTypeScrollingUp= 3,//相关联的上下滑动
};

typedef void(^HLIndexChangeBlock)(NSInteger index, HLSegmentedControlType controlType);

@interface HLSegmentItem : NSObject

@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *subTitle;

@end

@interface HLSegmentedControl : UIControl <UIScrollViewDelegate>

@property (nonatomic, assign, getter=isScrollingBySelection) BOOL scrollingBySelection;
@property (nonatomic, assign) NSInteger selectedSegmentIndex;
@property (nonatomic, readonly) NSUInteger numberOfSegments;
@property (nonatomic, copy) HLIndexChangeBlock indexChangeBlock;
@property (nonatomic, assign) HLSegmentedControlType type;
@property (nonatomic, copy) NSArray *items;

- (void)setSelectedSegmentIndex:(NSInteger)index animated:(BOOL)animated;

- (void)dynamicScrollView:(CGFloat)xOffset;

@end

@interface HLSegmentView : UIButton

@property (nonatomic, strong) NSString *subTitle;

@end
