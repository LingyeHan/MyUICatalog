//
//  HLMargifierView.h
//  MyUICatalog
//
//  Created by 玄叶 on 16/4/15.
//  Copyright © 2016年 Hanly. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HLMargifierView : UIView
{
    CGPoint _touchPoint;
}

@property (nonatomic, strong) UIView  *viewToMagnify;
@property (nonatomic, assign) CGPoint touchPoint;

@end
