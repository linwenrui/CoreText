//
//  ViewController.m
//  CoreText图文混排
//
//  Created by XH-LWR on 2018/2/27.
//  Copyright © 2018年 XH-LWR. All rights reserved.
//
// CoreText 实现图文混排其实就是在富文本中 插入一个空白的图片占位符 的富文本字符串, 通过 代理设置相关的图片尺寸信息, 根据从富文本得到frame 计算图片绘制的frame再绘制图片 这么一个过程

/**
 coreText 起初是为OSX设计的, 而OSX的坐标原点是左下角, y轴正方向朝上, iOS中坐标原点是左上角, y轴正方向向下.
 若不进行坐标转换, 则文字从下开始, 还是倒着的.
 */

#import "ViewController.h"
#import "PicAndTextViewController.h"
#import "TouchViewController.h"

@interface ViewController () <UITableViewDelegate, UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *dataSource;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.dataSource = [[NSMutableArray alloc] initWithObjects:@"CoreText-图文混排", @"点击事件", nil];
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"cell"];
    self.tableView.tableFooterView = [UIView new];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return self.dataSource.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    cell.textLabel.text = self.dataSource[indexPath.row];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.row == 0) {
        
        [self.navigationController pushViewController:[[PicAndTextViewController alloc] init] animated:YES];
    } else if (indexPath.row == 1) {
        
        [self.navigationController pushViewController:[[TouchViewController alloc] init] animated:YES];
    }
}


@end
