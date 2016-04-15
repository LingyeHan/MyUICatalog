//
//  HLCoordinateView.m
//  MyUICatalog
//
//  Created by 玄叶 on 16/4/6.
//  Copyright © 2016年 Hanly. All rights reserved.
//

#import "HLCoordinateView.h"
#import "HLMargifierView.h"

@implementation HLCoordinateView
{
    HLMargifierView *_margifierView;
    UILabel *_xyLabel;
}

- (id)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor clearColor];
        
        _margifierView = [[HLMargifierView alloc] init];
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
