//
//  YKLineEntity.h
//  YKLineChartView
//
//  Created by chenyk on 15/12/9.
//  Copyright © 2015年 chenyk. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
@interface YKLineEntity : NSObject
@property (nonatomic,assign)CGFloat open;
@property (nonatomic,assign)CGFloat high;
@property (nonatomic,assign)CGFloat low;
@property (nonatomic,assign)CGFloat close;
@property (nonatomic,assign)NSInteger index;
@property (nonatomic,strong)NSString * date;

@property (nonatomic,assign)CGFloat volume;
@property (nonatomic,assign)CGFloat ma5;
@property (nonatomic,assign)CGFloat ma10;
@property (nonatomic,assign)CGFloat ma20;

@end
