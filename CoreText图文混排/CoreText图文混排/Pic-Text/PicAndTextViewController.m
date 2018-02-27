//
//  PicAndTextViewController.m
//  CoreText图文混排
//
//  Created by XH-LWR on 2018/2/27.
//  Copyright © 2018年 XH-LWR. All rights reserved.
//

#import "PicAndTextViewController.h"
#import "PicView.h"

@interface PicAndTextViewController ()

@end

@implementation PicAndTextViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    PicView *picV = [[PicView alloc] initWithFrame:CGRectMake(10, 100, 200, 200)];
    [self.view addSubview:picV];
    self.view.backgroundColor = [UIColor whiteColor];
}


@end
