//
//  HLGridView.m
//  MyUICatalog
//
//  Created by 玄叶 on 16/4/15.
//  Copyright © 2016年 Hanly. All rights reserved.
//

#import "HLGridView.h"
#import "HLMargifierView.h"

#define kMargifierRadius    133
#define kMarkedCrossSize    10
#define kScaleFactor        20.0f
#define kGridNum            15

@interface HLGridMargifierView : HLMargifierView
{
    CGFloat gridGap;
}

@end

@implementation HLGridMargifierView

- (void)setTouchPoint:(CGPoint)pt
{
    CGFloat offset = gridGap / 2;
    _touchPoint = CGPointMake(pt.x-offset, pt.y-offset);
}

- (void)drawLayer:(CALayer *)layer inContext:(CGContextRef)ctx
{
    [super drawLayer:layer inContext:ctx];
    // CGContextSetShouldAntialias(ctx, NO);
    
    // 放大
    CGContextTranslateCTM(ctx, self.frame.size.width * 0.5, self.frame.size.height * 0.5);
    CGContextScaleCTM(ctx, kScaleFactor, kScaleFactor);
    CGContextTranslateCTM(ctx, -_touchPoint.x, -_touchPoint.y);
    [self.viewToMagnify.layer renderInContext:ctx];
    
    // 画网格
    CGContextSetStrokeColorWithColor(ctx, [UIColor lightGrayColor].CGColor);
    CGContextSetLineWidth(ctx, 0.5f / kScaleFactor);
    
    CGFloat radius = self.frame.size.width / 2;
    CGFloat xStart = _touchPoint.x - radius;
    CGFloat yStart = _touchPoint.y - radius;
    CGFloat offset = gridGap / 2;
    int gridCount = self.frame.size.width / gridGap - 1;
    // draw vertical lines
    for(int v = 1; v <= gridCount; v++) {
        CGFloat x = xStart + v * gridGap - offset;
        CGContextMoveToPoint(ctx, x, yStart);
        CGContextAddLineToPoint(ctx, x, yStart + self.frame.size.width);
    }
    // draw horizontal lines
    for(int h = 1; h <= gridCount; h++) {
        CGFloat y = yStart + h * gridGap - offset;
        CGContextMoveToPoint(ctx, xStart, y);
        CGContextAddLineToPoint(ctx, xStart + self.frame.size.width, y);
    }
    CGContextDrawPath(ctx, kCGPathStroke);
    
    // 画中心正方格
    CGContextSetStrokeColorWithColor(ctx, [UIColor blackColor].CGColor);
    CGContextSetLineWidth(ctx, 0.05);
    CGPathRef bpath = CGPathCreateWithRect(CGRectMake(_touchPoint.x-offset, _touchPoint.y-offset, gridGap, gridGap), NULL);
    CGContextAddPath(ctx, bpath);
    CGContextDrawPath(ctx, kCGPathStroke);
    
    // 白框
    CGContextSetStrokeColorWithColor(ctx, [UIColor whiteColor].CGColor);
    CGContextSetLineWidth(ctx, 0.05);
    CGPathRef wpath = CGPathCreateWithRect(CGRectMake(_touchPoint.x-offset-0.05, _touchPoint.y-offset-0.05, gridGap+0.1, gridGap+0.1), NULL);
    CGContextAddPath(ctx, wpath);
    CGContextDrawPath(ctx, kCGPathStroke);
}

@end

/////////

@implementation HLGridView
{
    NSMutableArray *_markPoints;
    
    HLGridMargifierView *_margifierView;
    UILabel *_xyLabel;
    UILabel *_xyMarkLabel;
    UILabel *_dvMarkLabel;//xy坐标差值
}

- (id)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        
        // 状态栏
        _markPoints = [[NSMutableArray alloc] init];
        
        _xyMarkLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 0, 100, 20)];
        _xyMarkLabel.numberOfLines = 1;
        _xyMarkLabel.font = [UIFont systemFontOfSize:12];
        _xyMarkLabel.textColor = [UIColor blackColor];
        //        _xyMarkLabel.text = @"x:0 y:0";
        
        _dvMarkLabel = [[UILabel alloc] initWithFrame:CGRectMake(100, 0, 100, 20)];
        _dvMarkLabel.numberOfLines = 1;
        _dvMarkLabel.font = [UIFont systemFontOfSize:12];
        _dvMarkLabel.textColor = [UIColor blackColor];
        _dvMarkLabel.text = @"Δx:0 Δy:0";
        
        // 放大镜
        self.backgroundColor = [UIColor clearColor];
        _margifierView = [[HLGridMargifierView alloc] init];
        _margifierView.viewToMagnify = [UIApplication sharedApplication].keyWindow;
        CGFloat wScreen = [UIScreen mainScreen].bounds.size.width;
        CGFloat h = CGRectGetHeight(_margifierView.frame);
        CGFloat w = CGRectGetWidth(_margifierView.frame);
        _margifierView.center = CGPointMake(wScreen - w/2, 20+h/2);
        
        //        _xyLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 40, 40)];
        //        _xyLabel.numberOfLines = 0;
        //        _xyLabel.font = [UIFont systemFontOfSize:8];
        //        _xyLabel.textColor = [UIColor darkGrayColor];
        
        [self addSubview:_margifierView];
        //        [self addSubview:_xyLabel];
        [self displayAtPoint:self.center];
        
        [self addSubviews];
    }
    return self;
}

- (void)addSubviews
{
    [self addSubview:_xyMarkLabel];
    [self addSubview:_dvMarkLabel];
    
    UIButton *markButton = [UIButton buttonWithType:UIButtonTypeSystem];
    markButton.frame = CGRectMake(self.frame.size.width - 60, 0, 50, 20);
    [markButton setTitle:@"标记" forState:UIControlStateNormal];
    [markButton addTarget:self action:@selector(markAction:) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton *clearButton = [UIButton buttonWithType:UIButtonTypeSystem];
    clearButton.frame = CGRectMake(markButton.frame.origin.x - 60, 0, 50, 20);
    [clearButton setTitle:@"清空" forState:UIControlStateNormal];
    [clearButton addTarget:self action:@selector(resetAction:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:markButton];
    [self addSubview:clearButton];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    [self displayAtPoint:[touch locationInView:self]];
}

- (void)displayAtPoint:(CGPoint)p
{
    if (p.y < _margifierView.frame.size.height + 20) {
        if (p.x < _margifierView.frame.size.width) {
            _margifierView.center = CGPointMake([UIScreen mainScreen].bounds.size.width - _margifierView.frame.size.width/2, _margifierView.center.y);
        } else if (p.x > [UIScreen mainScreen].bounds.size.width - _margifierView.frame.size.width) {
            _margifierView.center = CGPointMake(_margifierView.frame.size.width/2, _margifierView.center.y);
        }
    }
    _margifierView.touchPoint = p;
    [_margifierView.layer setNeedsDisplay];
    //    _xyLabel.center = CGPointMake(_margifierView.center.x + 18, _margifierView.center.y - 25);
    //    _xyLabel.text = [NSString stringWithFormat:@"x: %.0f\ny: %.0f", p.x, p.y];
    
    _xyMarkLabel.text = [NSString stringWithFormat:@"x:%.0f y:%.0f", _margifierView.touchPoint.x, _margifierView.touchPoint.y];
    [self setNeedsDisplay];
}

- (void)drawRect:(CGRect)rect
{
    [super drawRect:rect];
    UIBezierPath *path = [UIBezierPath bezierPath];
    path.lineWidth = 0.5;
    [[UIColor lightGrayColor] setStroke];
    
    [path addArcWithCenter:_margifierView.touchPoint radius:5 startAngle:0 endAngle:2*M_PI clockwise:YES];
    
    [path moveToPoint:CGPointMake(0, _margifierView.touchPoint.y)];
    [path addLineToPoint:CGPointMake(rect.size.width, _margifierView.touchPoint.y)];
    
    [path moveToPoint:CGPointMake(_margifierView.touchPoint.x, 0)];
    [path addLineToPoint:CGPointMake(_margifierView.touchPoint.x, rect.size.height)];
    
    [path stroke];
    
    // draw cross line
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGContextSetLineWidth(ctx, 0.5);
    CGFloat r, g, b, a;
    for (int i = 0; i < _markPoints.count; i++) {
        if (_markPoints.count <= 2 || (i == _markPoints.count - 2 && _markPoints.count % 2 == 0) || (i == _markPoints.count - 1)) {
            [[UIColor yellowColor] getRed:&r green:&g blue:&b alpha:&a];
        } else {
            [[UIColor lightGrayColor] getRed:&r green:&g blue:&b alpha:&a];
        }
        CGContextSetRGBStrokeColor(ctx, r, g, b, a);
        NSValue *value = _markPoints[i];
        [self drawCrossAtPoint:[value CGPointValue] inContext:ctx];
    }
}

- (void)resetAction:(UIButton *)sender
{
    _xyMarkLabel.text = [NSString stringWithFormat:@"x:%.0f y:%.0f", _margifierView.touchPoint.x, _margifierView.touchPoint.y];
    _dvMarkLabel.text = @"Δx:0 Δy:0";
    [_markPoints removeAllObjects];
    [self setNeedsDisplay];
}

- (void)markAction:(UIButton *)sender
{
    if (_markPoints.count > 0 && _markPoints.count % 2 > 0) {
        CGPoint pv = [((NSValue *)_markPoints.lastObject) CGPointValue];
        CGFloat dx = _margifierView.touchPoint.x - pv.x;
        CGFloat dy = _margifierView.touchPoint.y - pv.y;
        _dvMarkLabel.text = [NSString stringWithFormat:@"Δx:%.0f Δy:%.0f", dx, dy];
    } else {
        _xyMarkLabel.text = [NSString stringWithFormat:@"x:%.0f y:%.0f", _margifierView.touchPoint.x, _margifierView.touchPoint.y];
    }
    [_markPoints addObject:[NSValue valueWithCGPoint:CGPointMake(roundf(_margifierView.touchPoint.x), roundf(_margifierView.touchPoint.y))]];
    [self setNeedsDisplay];
}

- (void)drawCrossAtPoint:(CGPoint)point inContext:(CGContextRef)ctx
{
    CGContextMoveToPoint(ctx, point.x-kMarkedCrossSize, point.y);
    CGContextAddLineToPoint(ctx, point.x+kMarkedCrossSize, point.y);
    CGContextMoveToPoint(ctx, point.x, point.y-kMarkedCrossSize);
    CGContextAddLineToPoint(ctx, point.x, point.y+kMarkedCrossSize);
    CGContextDrawPath(ctx, kCGPathStroke);
}

//- (UIColor *)darkerColorForColor:(UIColor *)c
//{
//    CGFloat r, g, b, a;
//    if ([c getRed:&r green:&g blue:&b alpha:&a])
//        return [UIColor colorWithRed:MAX(r - 0.2, 0.0)
//                               green:MAX(g - 0.2, 0.0)
//                                blue:MAX(b - 0.2, 0.0)
//                               alpha:a];
//    return nil;
//}

@end
