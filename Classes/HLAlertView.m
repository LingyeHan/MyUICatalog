//
//  HLAlertView.m
//  MyUICHLAlog
//
//  Created by 玄叶 on 16/4/6.
//  Copyright © 2016年 Hanly. All rights reserved.
//

#import "HLAlertView.h"

static CGFloat duration = 0.4;

@interface ATButton : UIButton

@property HLActionType actionType;
@property (nonatomic, copy) HLActionBlock actionBlock;

@end

@implementation ATButton

@end

@interface HLAlertView ()

@property (nonatomic, strong) NSMutableArray *buttons;

@property (nonatomic, strong) UIWindow *previousWindow;
@property (nonatomic, strong) UIWindow *alertWindow;
@property (nonatomic, strong) UIView *backgroundView;
@property (nonatomic, strong) UIView *contentView;

@property (nonatomic, strong) UILabel *labelMessage;
@property (nonatomic, assign) HLActionType actionType;

@end

@implementation HLAlertView

- (instancetype)initWithMessage:(NSString *)message actionType:(HLActionType)actionType
{
    if (self = [super init]) {
        _buttons = [[NSMutableArray alloc] init];
        
        [self setupWindow];
        self.message = message;
        self.actionType = actionType;
    }
    return self;
}

- (id)setupWindow
{
    CGRect frame = [UIScreen mainScreen].bounds;
    _alertWindow = [[UIWindow alloc] initWithFrame:frame];
    _alertWindow.windowLevel = UIWindowLevelAlert;
    _alertWindow.backgroundColor = [UIColor clearColor];
    _alertWindow.rootViewController = self;
    
    CGSize size = CGSizeMake(150, 150);
    _contentView = [[UIView alloc] initWithFrame:CGRectMake((frame.size.width - size.width) / 2, (frame.size.height - size.height) / 2, size.width, size.height)];
    _contentView.alpha = 0.8;
    _contentView.backgroundColor = [UIColor darkGrayColor];
    _contentView.layer.cornerRadius = 75.0f;
    _contentView.layer.masksToBounds = YES;
    
    UIImageView *titleImageView = [[UIImageView alloc] initWithFrame:CGRectMake((size.width - 40)/2, 12, 38, 38)];
//    [titleImageView setImage:[UIImage imageNamed:@"SDK.bundle/icon0"]];
    [titleImageView setImage:[UIImage imageNamed:@"alert_cancel"]];
    titleImageView.layer.cornerRadius = 19;
    titleImageView.layer.masksToBounds = YES;
    titleImageView.layer.backgroundColor = [UIColor whiteColor].CGColor;
    //    titleImageView.layer.borderWidth = 2;
    titleImageView.contentMode = UIViewContentModeCenter;
    [_contentView addSubview:titleImageView];
    
    _labelMessage = [[UILabel alloc] init];
    _labelMessage.alpha = 0;
    _labelMessage.backgroundColor = [UIColor clearColor];
    _labelMessage.numberOfLines = 3;
    _labelMessage.textAlignment = NSTextAlignmentCenter;
    _labelMessage.textColor = [UIColor whiteColor];
    _labelMessage.font = [UIFont fontWithName:@"HelveticaNeue" size:12];
    _labelMessage.frame = CGRectMake(12, (size.height - 60)/2, size.width - 24, 60);
    [_contentView addSubview:_labelMessage];
    
    [self.view addSubview:_contentView];
    
    return self;
}

- (void)show
{
    [self showWithBlock:nil];
}

- (void)showWithBlock:(HLActionBlock)block
{
    // Save previous window
    self.previousWindow = [UIApplication sharedApplication].keyWindow;
    
    [self addButtonActionType:self.actionType actionBlock:block];
    
    [self.alertWindow makeKeyAndVisible];
    
    [self animateWithView:self.contentView
             fromPosition:self.initPosition toPosition:self.contentView.center
                fromValue:self.initFrame.size.width/self.contentView.frame.size.width toValue:1.0];
    [UIView animateWithDuration:duration animations:^{
        self.labelMessage.alpha = 1;
    } completion:^(BOOL finished) {
        
    }];
}

- (void)dismiss
{
    [self animateWithView:self.contentView
             fromPosition:self.contentView.center toPosition:self.initPosition
                fromValue:1.0 toValue:self.initFrame.size.width/self.contentView.frame.size.width];
    
    [UIView animateWithDuration:duration animations:^{
        self.labelMessage.alpha = 0;
    } completion:^(BOOL finished) {
        
    }];
    
    for (ATButton *button in _buttons) {
        button.actionBlock = nil;
    }
}

- (ATButton *)addButtonActionType:(HLActionType)actionType actionBlock:(HLActionBlock)actionBlock
{
    ATButton *button = nil;
    switch (actionType) {
        case HLActionConfirm:
        {
            [self addButtonActionType:HLActionCancel actionBlock:actionBlock];
            
            button = [self addButtonWithImageName:@"alert_confirm"];
            button.tag = 1;
            button.frame = CGRectOffset(button.frame, -round(button.frame.size.width/2) - 12, 0);
            ATButton *cancelButton = self.buttons[0];
            cancelButton.frame = CGRectOffset(cancelButton.frame, round(cancelButton.frame.size.width/2 + 12), 0);
            break;
        }
            
        default:
            button = [self addButtonWithImageName:@"alert_cancel"];
            button.tag = 0;
            CGRect frame = button.frame;
            frame.origin.x = (self.contentView.frame.size.width - frame.size.width) / 2;
            button.frame = frame;
            break;
    }
    
    button.actionBlock = actionBlock;
    [button addTarget:self action:@selector(buttonTapped:) forControlEvents:UIControlEventTouchUpInside];
    
    return button;
}

- (ATButton *)addButtonWithImageName:(NSString *)imageName
{
    ATButton *button = [ATButton buttonWithType:UIButtonTypeCustom];
    CGSize size = self.contentView.frame.size;
    CGFloat w = 32;
    button.frame = CGRectMake((size.width-w)/2, size.height-12-w, w, w);
    [button setImage:[UIImage imageNamed:imageName] forState:UIControlStateNormal];
    button.layer.masksToBounds = YES;
    
    [self.contentView addSubview:button];
    [self.buttons addObject:button];
    
    return button;
}

- (void)buttonTapped:(ATButton *)sender
{
    if (sender.actionBlock) {
        sender.actionBlock(sender.tag);
    }
    [self dismiss];
}

- (void)animateWithView:(UIView *)aView fromPosition:(CGPoint)fromPosition toPosition:(CGPoint)toPosition
              fromValue:(CGFloat)fromValue toValue:(CGFloat)toValue
{
    [aView.layer removeAllAnimations];
    
    CABasicAnimation *positionAnimation  = [CABasicAnimation animationWithKeyPath:@"position"];
    positionAnimation.duration = duration;
    positionAnimation.fromValue = [NSValue valueWithCGPoint:fromPosition];
    positionAnimation.toValue = [NSValue valueWithCGPoint:toPosition];
    
    CABasicAnimation *scaleAnimation = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
    scaleAnimation.fromValue = @(fromValue);
    scaleAnimation.toValue = @(toValue);
    scaleAnimation.duration = duration;
    scaleAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    
    CAAnimationGroup *animationGroup = [CAAnimationGroup animation];
    animationGroup.duration = duration;
    animationGroup.delegate = self;
    if (toValue < 1.0) {
        animationGroup.removedOnCompletion = NO;
        animationGroup.fillMode = kCAFillModeForwards;// 保持动画执行后的状态
        [animationGroup setValue:@"endAnimation" forKey:@"HLAlertViewGroupAnimation"];
        [animationGroup setAnimations:@[scaleAnimation, positionAnimation]];
    } else {
        [animationGroup setAnimations:@[positionAnimation, scaleAnimation]];
    }
    
    [aView.layer addAnimation:animationGroup forKey:@"groupAnimation"];
}

- (void)animationDidStop:(CAAnimation *)animation finished:(BOOL)finished
{
    if (finished) {
        NSString *animationName = [animation valueForKey:@"HLAlertViewGroupAnimation"];
        NSLog(@"animationDidStop: %@", animationName);
        if ([animationName isEqualToString:@"endAnimation"]) {
            [self.previousWindow makeKeyAndVisible];
            self.previousWindow = nil;
            
            [self.contentView removeFromSuperview];
            [self.backgroundView removeFromSuperview];
            [self.alertWindow setHidden:YES];
            self.alertWindow = nil;
        }
    }
}

- (void)setMessage:(NSString *)message
{
    _message = message;
    self.labelMessage.text = message;
}

- (void)setBackgroundColor:(UIColor *)backgroundColor
{
    _backgroundColor = backgroundColor;
    self.contentView.backgroundColor = backgroundColor;
}

- (void)setTextColor:(UIColor *)textColor
{
    _textColor = textColor;
    self.labelMessage.textColor = textColor;
}

@end
