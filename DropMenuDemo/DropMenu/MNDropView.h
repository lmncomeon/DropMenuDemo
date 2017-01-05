//
//  MNDropView.h
//  JPullDownMenuDemo
//
//  Created by 栾美娜 on 2017/1/5.
//  Copyright © 2017年 jinxiansen. All rights reserved.
//

#import <UIKit/UIKit.h>
@class DropModel;

@interface MNDropView : UIView

- (instancetype)initWithFrame:(CGRect)frame title:(NSArray *)title dataArray:(NSArray *)dataArray;

@property (nonatomic, copy) void (^selectEvent)(DropModel *);

@end
