//
//  HLMargifierView.m
//  MyUICatalog
//
//  Created by 玄叶 on 16/4/15.
//  Copyright © 2016年 Hanly. All rights reserved.
//

#import "HLMargifierView.h"

#define kMargifierRadius    80

@implementation HLMargifierView

- (id)initWithFrame:(CGRect)frame
{
    return [self initWithFrame:frame radius:kMargifierRadius];
}

- (id)initWithFrame:(CGRect)frame radius:(int)radius
{
    if ((self = [super initWithFrame:CGRectMake(0, 0, radius, radius)])) {
        self.layer.contentsScale = 2;
        self.layer.cornerRadius = radius / 2;
        self.layer.masksToBounds = YES;
        self.layer.borderWidth = 0.5;
        self.layer.borderColor = [[UIColor lightGrayColor] CGColor];
        
        self.backgroundColor = [UIColor clearColor];
    }
    
    return self;
}

- (void)setTouchPoint:(CGPoint)pt
{
    _touchPoint = pt;
    
    // 自适应放大镜中心点，默认为右上角显示
    CGFloat hScreen = [UIScreen mainScreen].bounds.size.height;
    CGFloat wScreen = [UIScreen mainScreen].bounds.size.width;
    CGFloat h = CGRectGetHeight(self.frame);
    CGFloat w = CGRectGetWidth(self.frame);
    CGFloat px = pt.x + ((pt.x + w) > wScreen ? -1.0 : 1.0) * (w / 2);
    CGFloat py = pt.y + (pt.y >= h || (pt.y + h) > hScreen ? -1.0 : 1.0) * (h / 2);
    
    self.center = CGPointMake(px, py);
}

- (void)drawLayer:(CALayer *)layer inContext:(CGContextRef)ctx
{
    [super drawLayer:layer inContext:ctx];
    
    // 放大
    CGContextTranslateCTM(ctx, self.frame.size.width * 0.5, self.frame.size.height * 0.5);
    CGContextScaleCTM(ctx, 2, 2);
    CGContextTranslateCTM(ctx, -_touchPoint.x, -_touchPoint.y);
    [self.viewToMagnify.layer renderInContext:ctx];
    
    // 画小圆圈
    CGFloat r,g,b,a;
    [[UIColor darkGrayColor] getRed:&r green:&g blue:&b alpha:&a];
    CGContextSetRGBStrokeColor(ctx, r, g, b, a);
    CGContextSetShouldAntialias(ctx, YES);
    CGContextSetLineWidth(ctx, 0.5);
    CGContextAddArc(ctx, _touchPoint.x, _touchPoint.y, 1.0, 0, 2*M_PI, 0);
    CGContextDrawPath(ctx, kCGPathStroke);
    
    // 画十字架
    //    CGContextSetShouldAntialias(ctx, YES);
    //    CGContextSetLineWidth(ctx, 0.5);
    //    CGContextMoveToPoint(ctx, _touchPoint.x-CGRectGetWidth(self.frame)/4, _touchPoint.y);
    //    CGContextAddLineToPoint(ctx, _touchPoint.x+CGRectGetWidth(self.frame)/4, _touchPoint.y);
    //    CGContextMoveToPoint(ctx, _touchPoint.x, _touchPoint.y-CGRectGetHeight(self.frame)/4);
    //    CGContextAddLineToPoint(ctx, _touchPoint.x, _touchPoint.y+CGRectGetHeight(self.frame)/4);
    //    CGContextDrawPath(ctx, kCGPathStroke);
}

@end
