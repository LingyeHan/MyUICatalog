//
//  HLCoordinateView.m
//  MyUICatalog
//
//  Created by 玄叶 on 16/4/6.
//  Copyright © 2016年 Hanly. All rights reserved.
//

#import "HLCoordinateView.h"

#define kMargifierRadius    80

@interface MargifierView : UIView

@property (nonatomic, strong) UIView  *viewToMagnify;
@property (nonatomic, assign) CGPoint touchPoint;

@end

@implementation MargifierView

- (id)initWithFrame:(CGRect)frame
{
    return [self initWithFrame:frame radius:kMargifierRadius];
}

- (id)initWithFrame:(CGRect)frame radius:(int)radius
{
    if ((self = [super initWithFrame:CGRectMake(0, 0, radius, radius)])) {
        self.layer.cornerRadius = radius / 2;
        self.layer.masksToBounds = YES;
        self.layer.borderWidth = 0.5;
        self.layer.borderColor = [[UIColor lightGrayColor] CGColor];
        
        self.backgroundColor = [UIColor clearColor];
    }
    
    return self;
}

- (void)setTouchPoint:(CGPoint)pt {
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

/////////

@implementation HLCoordinateView
{
    MargifierView *_margifierView;
    UILabel *_xyLabel;
}

- (id)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor clearColor];
        
        _margifierView = [[MargifierView alloc] init];
        _margifierView.viewToMagnify = [UIApplication sharedApplication].keyWindow;
        
        _xyLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 40, 40)];
        _xyLabel.numberOfLines = 0;
        _xyLabel.font = [UIFont systemFontOfSize:8];
        _xyLabel.textColor = [UIColor darkGrayColor];
        
        [self addSubview:_margifierView];
        [self addSubview:_xyLabel];
        [self displayAtPoint:self.center];
        
        [self addObserver:self forKeyPath:@"parentView.hidden" options:NSKeyValueObservingOptionNew context:nil];
    }
    return self;
}

- (void)dealloc
{
    [self removeObserver:self forKeyPath:@"parentView.hidden"];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    [self displayAtPoint:[touch locationInView:self]];
}

- (void)displayAtPoint:(CGPoint)p
{
    _margifierView.touchPoint = p;
    [_margifierView.layer setNeedsDisplay];
    _xyLabel.center = CGPointMake(_margifierView.center.x + 18, _margifierView.center.y - 25);
    _xyLabel.text = [NSString stringWithFormat:@"x: %.0f\ny: %.0f", p.x, p.y];
    [self setNeedsDisplay];
}

- (void)drawRect:(CGRect)rect
{
    [super drawRect:rect];
    UIBezierPath *path = [UIBezierPath bezierPath];
    path.lineWidth = 1;
    [[UIColor lightGrayColor] setStroke];
    
    [path addArcWithCenter:_margifierView.touchPoint radius:5 startAngle:0 endAngle:2*M_PI clockwise:YES];
    
    [path moveToPoint:CGPointMake(0, _margifierView.touchPoint.y)];
    [path addLineToPoint:CGPointMake(rect.size.width, _margifierView.touchPoint.y)];
    
    [path moveToPoint:CGPointMake(_margifierView.touchPoint.x, 0)];
    [path addLineToPoint:CGPointMake(_margifierView.touchPoint.x, rect.size.height)];
    
    [path stroke];
}

@end
