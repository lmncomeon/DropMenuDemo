//
//  MNDropView.m
//  JPullDownMenuDemo
//
//  Created by 栾美娜 on 2017/1/5.
//  Copyright © 2017年 jinxiansen. All rights reserved.
//

#import "MNDropView.h"
#import "UIView+CustomView.h"
#import "DropModel.h"

#define kscreenW [UIScreen mainScreen].bounds.size.width
#define kscreenH [UIScreen mainScreen].bounds.size.height

@interface MNDropView () <UITableViewDataSource, UITableViewDelegate, UIGestureRecognizerDelegate>

@property (nonatomic, strong) NSMutableArray *btnArray;
@property (nonatomic, strong) UIButton *selectedBtn;

@property (nonatomic, strong) UIView *maskView;
@property (nonatomic, strong) UITableView *tableView;

@property (nonatomic, strong) NSMutableArray *list;

@property (nonatomic, assign) CGFloat selfOriginalHeight;

@end

@implementation MNDropView

- (instancetype)initWithFrame:(CGRect)frame title:(NSArray *)title dataArray:(NSArray *)dataArray {
    self = [super initWithFrame:frame];
    if (self) {
        UIView *topView = [[UIView alloc] initWithFrame:(CGRect){CGPointZero, frame.size}];
        [self addSubview:topView];
        
        CGFloat padding = 1;
        CGFloat btnW    = (kscreenW - (title.count-1)*padding)/title.count;
        for (int i = 0; i < title.count; i++) {
            UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
            btn.frame = CGRectMake(i*(btnW+padding), 0, btnW, frame.size.height);
            btn.backgroundColor = [UIColor whiteColor];
            [btn setAttributedTitle:[self normalAttr:title[i]] forState:UIControlStateNormal];
            [btn setAttributedTitle:[self selectedAttr:title[i]] forState:UIControlStateSelected];
            btn.tag = 1000+i; // tag
            [btn addTarget:self action:@selector(btnAction:) forControlEvents:UIControlEventTouchUpInside];
            [topView addSubview:btn];
            [self.btnArray addObject:btn];
            
            UIView *line = [[UIView alloc] initWithFrame:CGRectMake(btnW*i, 6, 0.5f, frame.size.height-12)];
            line.backgroundColor = [UIColor grayColor];
            [topView addSubview:line];
        }
        
        [self tableView];
        
        _maskView.hidden = true;
        
        [self handleData:dataArray];
        
        _selfOriginalHeight = frame.size.height;
    }
    return self;
}

- (void)handleData:(NSArray *)dataArray {
    _list = [NSMutableArray arrayWithCapacity:5];
    for (NSArray *subArr in dataArray) {
        
        NSMutableArray *tmp = [NSMutableArray arrayWithCapacity:5];
        for (int i = 0; i < subArr.count; i++) {

            DropModel *model = [DropModel new];
            model.text = subArr[i];;
            if (i == 0) {
                model.show = true;
            } else {
                model.show = false;
            }
            [tmp addObject:model];
        }
        
        [_list addObject:tmp];
    }
}

- (UIView *)maskView {
    if (!_maskView) {
        _maskView = [[UIView alloc] initWithFrame:CGRectMake(0, self.frame.size.height, self.frame.size.width, [UIScreen mainScreen].bounds.size.height-self.frame.origin.y-self.frame.size.height)];
        _maskView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.3f];
        [self addSubview:_maskView];
        
        UITapGestureRecognizer *tapGR = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapAction)];
        tapGR.delegate = self;
        [_maskView addGestureRecognizer:tapGR];
        
    }
    return _maskView;
}

- (void)tapAction {
    UIButton *currentBtn = self.btnArray[_selectedBtn.tag-1000];
    currentBtn.selected  = false;
    _selectedBtn = nil;
    
    self.tableView.height = 0;
    self.maskView.hidden = true;
    self.height = self.selfOriginalHeight;
}

#pragma mark - UIGestureRecognizerDelegate
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    // 若为UITableViewCellContentView（即点击了tableViewCell），则不截获Touch事件
    if ([NSStringFromClass([touch.view class]) isEqualToString:@"UITableViewCellContentView"]) {
        return NO;
    }
    return  YES;
}

- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, 0)];
        _tableView.dataSource = self;
        _tableView.delegate = self;
        _tableView.rowHeight = 30;
        [self.maskView addSubview:_tableView];
    }
    return _tableView;
}

- (void)btnAction:(UIButton *)sender {
    if (sender == _selectedBtn) {
        sender.selected = false;
        _selectedBtn = nil;
        
    } else {
        sender.selected = true;
        _selectedBtn.selected = false;
        _selectedBtn = sender;
    }

    if (sender.selected) { // show
        _maskView.hidden = false;
        _maskView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.3f];
        NSArray *data = _list[sender.tag-1000];
        
        // 高度
        if (data.count < 5) {
            _tableView.height = data.count * _tableView.rowHeight;
        } else {
            _tableView.height = 5*_tableView.rowHeight;
        }
        
        // reload
        [_tableView reloadData];
        self.height = CGRectGetMaxY(self.subviews.lastObject.frame);
        
    } else { // hide
        _tableView.height = 0;
        _maskView.hidden = true;
        self.height = _selfOriginalHeight;
    }
    
}

#pragma mark - tableview datasource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (_selectedBtn) {

        return [_list[_selectedBtn.tag-1000] count];
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *const cellID = @"UITableViewCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID];
    }
    
    NSArray *data = _list[_selectedBtn.tag-1000];
    DropModel *model = data[indexPath.row];
    cell.textLabel.text = model.text;
    cell.accessoryType  = model.show ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
    
    return cell;
}

#pragma mark - tableview delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
 
    // 赋值
    NSArray *data = _list[_selectedBtn.tag-1000];
    DropModel *model = data[indexPath.row];
    
    UIButton *currentBtn = self.btnArray[_selectedBtn.tag-1000];
    currentBtn.selected = false;
    [currentBtn setAttributedTitle:[self normalAttr:model.text] forState:UIControlStateNormal];
    [currentBtn setAttributedTitle:[self selectedAttr:model.text] forState:UIControlStateSelected];
    _selectedBtn = nil;
    _tableView.height = 0;
    _maskView.hidden = true;
    
    // 对勾
    for (int i = 0; i < data.count; i++) {
        DropModel *model = data[i];
        
        if (i == indexPath.row) {
            model.show = true;
        } else {
            model.show = false;
        }
    }
 
    !_selectEvent ? : _selectEvent(model);
}

#pragma mark - other method
- (NSMutableAttributedString *)normalAttr:(NSString *)text {
    NSMutableAttributedString *attr = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@ ", text]];
    [attr addAttributes:@{NSForegroundColorAttributeName : [UIColor blackColor], NSFontAttributeName : [UIFont systemFontOfSize:12]} range:NSMakeRange(0, text.length)];
    
    // 创建图片图片附件
    NSTextAttachment *attach = [[NSTextAttachment alloc] init];
    attach.image = [UIImage imageNamed:@"JPullDown.bundle/jiantou_down"];
    attach.bounds = CGRectMake(0, 0, 6, 6);
    NSAttributedString *img = [NSAttributedString attributedStringWithAttachment:attach];
    
    [attr appendAttributedString:img];
    
    return attr;
}

- (NSMutableAttributedString *)selectedAttr:(NSString *)text {
    NSMutableAttributedString *attr = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@ ", text]];
    [attr addAttributes:@{NSForegroundColorAttributeName : [UIColor cyanColor], NSFontAttributeName : [UIFont systemFontOfSize:12]} range:NSMakeRange(0, text.length)];
    
    // 创建图片图片附件
    NSTextAttachment *attach = [[NSTextAttachment alloc] init];
    attach.image = [UIImage imageNamed:@"JPullDown.bundle/jiantou_up"];
    attach.bounds = CGRectMake(0, 0, 6, 6);
    NSAttributedString *img = [NSAttributedString attributedStringWithAttachment:attach];
    
    [attr appendAttributedString:img];
    
    return attr;
}

#pragma mark - lazy load
- (NSMutableArray *)btnArray {
    if (!_btnArray) {
        _btnArray = [NSMutableArray array];
    }
    return _btnArray;
}

@end
