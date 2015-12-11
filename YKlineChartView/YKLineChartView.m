//
//  YKLineChartView.m
//  YKLineChartView
//
//  Created by chenyk on 15/12/9.
//  Copyright © 2015年 chenyk. All rights reserved.
//

#import "YKLineChartView.h"
#import "YKLineDataSet.h"
#import "YKLineEntity.h"
@interface YKLineChartView()
@property (nonatomic,strong)YKLineDataSet * dataSet;
;




@property (nonatomic,assign)NSInteger countOfshowCandle;

@property (nonatomic,assign)NSInteger  startDrawIndex;

@property (nonatomic,strong)UIPanGestureRecognizer * panGesture;
@property (nonatomic,strong)UIPinchGestureRecognizer * pinGesture;
@property (nonatomic,strong)UILongPressGestureRecognizer * longPressGesture;
@property (nonatomic,strong)UITapGestureRecognizer * tapGesture;

@property (nonatomic,assign)CGFloat lastPinScale;

@property (nonatomic,assign)CGPoint lastPanPoint;



//@property (nonatomic,assign)BOOL isFirstDraw;
@end
@implementation YKLineChartView

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self commonInit];
        
    }
    return self;
}


- (void)commonInit {
    
    [super commonInit];
    self.candleCoordsScale = 0.f;
    
    [self addGestureRecognizer:self.panGesture];
    [self addGestureRecognizer:self.pinGesture];
    [self addGestureRecognizer:self.longPressGesture];
    [self addGestureRecognizer:self.tapGesture];
}
- (NSInteger)countOfshowCandle{
    return self.contentWidth/(self.candleWidth);
}
- (void)setStartDrawIndex:(NSInteger)startDrawIndex
{
    if (startDrawIndex < 0) {
        startDrawIndex = 0;
    }
    if (startDrawIndex + self.countOfshowCandle > self.dataSet.data.count) {
        _startDrawIndex = 0;
    }
    _startDrawIndex = startDrawIndex;
}

-(void)setupData:(YKLineDataSet *)dataSet
{
    self.dataSet = dataSet;
    [self notifyDataSetChanged];
    
}
- (void)setCurrentDataMaxAndMin
{
//    if (!self.isFirstDraw) {
//        self.isFirstDraw = YES;
//    }
    
    if (self.dataSet.data.count > 0) {
        self.maxPrice = CGFLOAT_MIN;
        self.minPrice = CGFLOAT_MAX;
        self.maxVolume = CGFLOAT_MIN;
        
        NSInteger idx = self.startDrawIndex;
        for (NSInteger i = idx; i < self.dataSet.data.count; i++) {
            YKLineEntity  * entity = [self.dataSet.data objectAtIndex:i];
            self.minPrice = self.minPrice < entity.low ? self.minPrice : entity.low;
            self.maxPrice = self.maxPrice > entity.high ? self.maxPrice : entity.high;
            self.maxVolume = self.maxVolume >entity.volume ? self.maxVolume : entity.volume;
            
            self.minPrice = self.minPrice < entity.ma5 ? self.minPrice:entity.ma5;
            self.minPrice = self.minPrice < entity.ma10 ? self.minPrice:entity.ma10;
            self.minPrice = self.minPrice < entity.ma20 ? self.minPrice:entity.ma20;
            
            self.maxPrice = self.maxPrice > entity.ma5 ? self.maxPrice : entity.ma5;
            self.maxPrice = self.maxPrice > entity.ma10 ? self.maxPrice : entity.ma10;
            self.maxPrice = self.maxPrice > entity.ma20 ? self.maxPrice : entity.ma20;


        }
        
    }
}

- (void)drawRect:(CGRect)rect
{
    [super drawRect:rect];

    [self setCurrentDataMaxAndMin];

    CGContextRef optionalContext = UIGraphicsGetCurrentContext();
    
    
    
    [self drawGridBackground:optionalContext rect:rect];
    
    [self drawLabelPrice:optionalContext];

    [self drawCandle:optionalContext];


}
- (void)drawGridBackground:(CGContextRef)context rect:(CGRect)rect
{
    [super drawGridBackground:context rect:rect];
    
}




- (void)drawAvgMarker:(CGContextRef)context
                 idex:(NSInteger)idex
{
    YKLineEntity  * entity;
    if (0 == idex) {
        entity = [self.dataSet.data lastObject];
    }else{
        entity = self.dataSet.data[idex];
    }
    
    
    NSDictionary * drawAttributes = self.highlightAttributedDic ?:self.defaultAttributedDic;
    
    CGFloat radius = 8.0;
    CGFloat space = 4.0;
    CGPoint startP = CGPointMake(self.contentLeft, self.contentTop);
    
    CGContextSetFillColorWithColor(context, self.dataSet.avgMA5Color.CGColor);
    CGContextFillEllipseInRect(context, CGRectMake(startP.x+(radius/2.0), startP.y+(radius/2.0), radius, radius));
    
    startP.x += (radius+space);
    NSString * ma5Str = [NSString stringWithFormat:@"MA5:%.2f",entity.ma5];
    NSMutableAttributedString * ma5StrAtt = [[NSMutableAttributedString alloc]initWithString:ma5Str attributes:drawAttributes];
    CGSize ma5StrAttSize = [ma5StrAtt size];
    [self drawLabel:context attributesText:ma5StrAtt rect:CGRectMake(startP.x, startP.y+radius/3.0, ma5StrAttSize.width, ma5StrAttSize.height)];
    startP.x += (ma5StrAttSize.width + space);
    
    CGContextSetFillColorWithColor(context, self.dataSet.avgMA10Color.CGColor);
    CGContextFillEllipseInRect(context, CGRectMake(startP.x+(radius/2.0), startP.y+(radius/2.0), radius, radius));
    startP.x += (radius+space);
    

    NSString * ma10Str = [NSString stringWithFormat:@"MA10:%.2f",entity.ma10];
    NSMutableAttributedString * ma10StrAtt = [[NSMutableAttributedString alloc]initWithString:ma10Str attributes:drawAttributes];
    CGSize ma10StrAttSize = [ma10StrAtt size];
    [self drawLabel:context attributesText:ma10StrAtt rect:CGRectMake(startP.x, startP.y+radius/3.0, ma10StrAttSize.width, ma10StrAttSize.height)];
    startP.x += (ma5StrAttSize.width + space);
    
    
    CGContextSetFillColorWithColor(context, self.dataSet.avgMA20Color.CGColor);
    CGContextFillEllipseInRect(context, CGRectMake(startP.x+(radius/2.0), startP.y+(radius/2.0), radius, radius));
    
    startP.x += (radius+space);
    NSString * ma20Str = [NSString stringWithFormat:@"MA20:%.2f",entity.ma20];
    NSMutableAttributedString * ma20StrAtt = [[NSMutableAttributedString alloc]initWithString:ma20Str attributes:drawAttributes];
    CGSize ma20StrAttSize = [ma20StrAtt size];
    [self drawLabel:context attributesText:ma20StrAtt rect:CGRectMake(startP.x, startP.y+radius/3.0, ma20StrAttSize.width, ma20StrAttSize.height)];
    
}
- (void)drawCandle:(CGContextRef)context
{
    CGContextSaveGState(context);

    NSInteger idex = self.startDrawIndex;
    self.candleCoordsScale = (self.uperChartHeightScale * self.contentHeight)/(self.maxPrice-self.minPrice);
    self.volumeCoordsScale = (self.contentHeight - (self.uperChartHeightScale * self.contentHeight)-self.xAxisHeitht)/(self.maxVolume - 0);
    for (NSInteger i = idex ; i< self.dataSet.data.count; i ++) {
        
        YKLineEntity  * entity  = [self.dataSet.data objectAtIndex:i];
        
        CGFloat open = ((self.maxPrice - entity.open) * self.candleCoordsScale) + self.contentTop;
        CGFloat close = ((self.maxPrice - entity.close) * self.candleCoordsScale) + self.contentTop;
        CGFloat high = ((self.maxPrice - entity.high) * self.candleCoordsScale) + self.contentTop;
        CGFloat low = ((self.maxPrice - entity.low) * self.candleCoordsScale) + self.contentTop;
        CGFloat left = (self.candleWidth * (i - idex) + self.contentLeft) + self.candleWidth / 6.0;
        
        CGFloat candleWidth = self.candleWidth - self.candleWidth / 6.0;
        CGFloat startX = left + candleWidth/2.0 ;
        
        UIColor * color = self.dataSet.candleRiseColor;
        if (open < close) {
            color = self.dataSet.candleFallColor;
            
            [self drawRect:context rect:CGRectMake(left, open, candleWidth, close-open) color:color];
            [self drawline:context startPoint:CGPointMake(startX, high) stopPoint:CGPointMake(startX, low) color:color lineWidth:self.dataSet.candleTopBottmLineWidth];
        }
        else if (open == close) {
            if (i > 1) {
                YKLineEntity * lastEntity = [self.dataSet.data objectAtIndex:i-1];
                if (lastEntity.close > entity.close) {
                    color = self.dataSet.candleFallColor;
                }
            }
            [self drawRect:context rect:CGRectMake(left, open, candleWidth, 1.5) color:color];
            [self drawline:context startPoint:CGPointMake(startX, high) stopPoint:CGPointMake(startX, low) color:color lineWidth:self.dataSet.candleTopBottmLineWidth];
        } else {
            color = self.dataSet.candleRiseColor;
            [self drawRect:context rect:CGRectMake(left, close, candleWidth, open-close) color:color];
            [self drawline:context startPoint:CGPointMake(startX, high) stopPoint:CGPointMake(startX, low) color:color lineWidth:self.dataSet.candleTopBottmLineWidth];
        }
        
       
        
        if (i > 0){
            YKLineEntity * lastEntity = [self.dataSet.data objectAtIndex:i -1];
            CGFloat lastX = startX - self.candleWidth;
            
            CGFloat lastY5 = (self.maxPrice - lastEntity.ma5)*self.candleCoordsScale + self.contentTop;
            CGFloat  y5 = (self.maxPrice - entity.ma5)*self.candleCoordsScale  + self.contentTop;
            [self drawline:context startPoint:CGPointMake(lastX, lastY5) stopPoint:CGPointMake(startX, y5) color:self.dataSet.avgMA5Color lineWidth:self.dataSet.avgLineWidth];
            
            CGFloat lastY10 = (self.maxPrice - lastEntity.ma10)*self.candleCoordsScale  + self.contentTop;
            CGFloat  y10 = (self.maxPrice - entity.ma10)*self.candleCoordsScale  + self.contentTop;
            [self drawline:context startPoint:CGPointMake(lastX, lastY10) stopPoint:CGPointMake(startX, y10) color:self.dataSet.avgMA10Color lineWidth:self.dataSet.avgLineWidth];
            
            CGFloat lastY20 = (self.maxPrice - lastEntity.ma20)*self.candleCoordsScale  + self.contentTop;
            CGFloat  y20 = (self.maxPrice - entity.ma20)*self.candleCoordsScale  + self.contentTop;
            [self drawline:context startPoint:CGPointMake(lastX, lastY20) stopPoint:CGPointMake(startX, y20) color:self.dataSet.avgMA20Color lineWidth:self.dataSet.avgLineWidth];
        }
        
        //成交量
        CGFloat volume = ((entity.volume - 0) * self.volumeCoordsScale);
        [self drawRect:context rect:CGRectMake(left, self.contentBottom - volume , candleWidth, volume) color:color];
        
        //十字线
        if (self.highlightLineCurrentEnabled) {
            if (i == self.highlightLineCurrentIndex) {
                
                YKLineEntity * entity;
                if (i < self.dataSet.data.count) {
                    entity = [self.dataSet.data objectAtIndex:i];
                }
                
                
                [self drawHighlighted:context point:CGPointMake(startX, close)idex:idex value:entity color:self.dataSet.highlightLineColor lineWidth:self.dataSet.highlightLineWidth];
                [self drawAvgMarker:context idex:i];
                if ([self.delegate respondsToSelector:@selector(chartValueSelected:entry:entryIndex:) ]) {
                    [self.delegate chartValueSelected:self entry:entity entryIndex:i];
                }
            }
        }
        
        
    }
    
    if (!self.highlightLineCurrentEnabled) {
        [self drawAvgMarker:context idex:0];
    }
    CGContextRestoreGState(context);
}


- (UIPanGestureRecognizer *)panGesture
{
    if (!_panGesture) {
        _panGesture = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(handlePanGestureAction:)];
    }
    return _panGesture;
}
- (void)handlePanGestureAction:(UIPanGestureRecognizer *)recognizer
{
    
    self.highlightLineCurrentEnabled = NO;
    CGPoint point = [recognizer translationInView:self];
    
    CGFloat offset = point.x - self.lastPanPoint.x;
    NSLog(@"平移,%lf",offset);
    if (recognizer.state == UIGestureRecognizerStateBegan) {
        
    }
    if (recognizer.state == UIGestureRecognizerStateChanged) {
        if (point.x > 0) {
            self.startDrawIndex -= offset/self.candleWidth;
        }else{
            if (self.startDrawIndex + self.countOfshowCandle + (-offset)/self.candleWidth > self.dataSet.data.count) {
                return;
            }
            self.startDrawIndex += (-offset)/self.candleWidth;
        }
        [self setNeedsDisplay];
    }
    self.lastPanPoint = point;
}

- (UIPinchGestureRecognizer *)pinGesture
{
    if (!_pinGesture) {
        _pinGesture = [[UIPinchGestureRecognizer alloc]initWithTarget:self action:@selector(handlePinGestureAction:)];
        }
    return _pinGesture;
}
- (void)handlePinGestureAction:(UIPinchGestureRecognizer *)recognizer
{
    self.highlightLineCurrentEnabled = NO;

    recognizer.scale= recognizer.scale-self.lastPinScale + 1;
    
    ;
    self.candleWidth = recognizer.scale * self.candleWidth;
    
    if(self.candleWidth > self.candleMaxWidth){
        self.candleWidth = self.candleMaxWidth;
    }
    if(self.candleWidth < self.candleMinWidth){
        self.candleWidth = self.candleMinWidth;
    }
    [self setNeedsDisplay];
    self.startDrawIndex = self.dataSet.data.count - self.countOfshowCandle;
    self.lastPinScale = recognizer.scale;
}

- (UILongPressGestureRecognizer *)longPressGesture
{
    if (!_longPressGesture) {
        _longPressGesture = [[UILongPressGestureRecognizer alloc]initWithTarget:self action:@selector(handleLongPressGestureAction:)];
        _longPressGesture.minimumPressDuration = 0.5;
    }
    return _longPressGesture;
}
- (void)handleLongPressGestureAction:(UIPanGestureRecognizer *)recognizer
{
    
    if (recognizer.state == UIGestureRecognizerStateBegan) {
        CGPoint  point = [recognizer locationInView:self];
        
        if (point.x > self.contentLeft && point.x < self.contentRight && point.y >self.contentTop && point.y<self.contentBottom) {
            self.highlightLineCurrentEnabled = YES;
            [self getHighlightByTouchPoint:point];
        }
    }
    if (recognizer.state == UIGestureRecognizerStateEnded) {
        
    }
    if (recognizer.state == UIGestureRecognizerStateChanged) {
        
        CGPoint  point = [recognizer locationInView:self];
        
        if (point.x > self.contentLeft && point.x < self.contentRight && point.y >self.contentTop && point.y<self.contentBottom) {
            self.highlightLineCurrentEnabled = YES;
            [self getHighlightByTouchPoint:point];
        }
    }
}

- (void)getHighlightByTouchPoint:(CGPoint) point
{
   
    self.highlightLineCurrentIndex = self.startDrawIndex + (NSInteger)((point.x - self.contentLeft)/self.candleWidth);
    [self setNeedsDisplay];
}

- (UITapGestureRecognizer *)tapGesture
{
    if (!_tapGesture) {
        _tapGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(handleTapGestureAction:)];
    }
    return _tapGesture;
}
- (void)handleTapGestureAction:(UITapGestureRecognizer *)recognizer
{
    if (self.highlightLineCurrentEnabled) {
        self.highlightLineCurrentEnabled = NO;
    }
    [self setNeedsDisplay];
}


- (void)notifyDataSetChanged
{
    [super notifyDataSetChanged];
    [self setNeedsDisplay];
    self.startDrawIndex = self.dataSet.data.count - self.countOfshowCandle;
}
- (void)notifyDeviceOrientationChanged
{
    [super notifyDeviceOrientationChanged];
    self.startDrawIndex = self.dataSet.data.count - self.countOfshowCandle;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end