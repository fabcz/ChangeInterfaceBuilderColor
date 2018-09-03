//
//  ViewController.m
//  changeColor
//
//  Created by 灬C灬C灬 on 2018/8/29.
//  Copyright © 2018年 灬C灬C灬. All rights reserved.
//

#import "ViewController.h"
#import "xibx.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    xibx *x = [NSBundle.mainBundle loadNibNamed:NSStringFromClass([xibx class]) owner:self options:nil].firstObject;
    x.backgroundColor = UIColor.lightGrayColor;
    [self.view addSubview:x];
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
