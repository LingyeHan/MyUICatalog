//
//  HLAlertView.h
//  MyUICHLAlog
//
//  Created by 玄叶 on 16/4/6.
//  Copyright © 2016年 Hanly. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, HLActionType)
{
    HLActionConfirm,
    HLActionCancel
};

typedef void (^HLActionBlock)(NSInteger buttonIndex);

@interface HLAlertView : UIViewController

@property (nonatomic, assign) CGPoint   initPosition;
@property (nonatomic, assign) CGRect    initFrame;
@property (nonatomic, copy) NSString    *message;
@property (nonatomic, copy) UIColor     *backgroundColor;
@property (nonatomic, copy) UIColor     *textColor;

- (instancetype)initWithMessage:(NSString *)message actionType:(HLActionType)actionType;

- (void)show;

- (void)showWithBlock:(HLActionBlock)block;

@end
