//
//  WDColorModel.h
//  ChangeInterfaceBuilderColor
//
//  Created by 灬C灬C灬 on 2018/8/29.
//  Copyright © 2018年 灬C灬C灬. All rights reserved.
//


#import <Foundation/Foundation.h>


@interface CCColorModel : NSObject
@property (nonatomic, copy) NSString *key;
@property (nonatomic, copy) NSString *alpha;
@property (nonatomic, copy) NSString *colorSpace;
@property (nonatomic, copy) NSString *customColorSpace;

// 255
@property (nonatomic, assign) NSInteger red;
@property (nonatomic, assign) NSInteger green;
@property (nonatomic, assign) NSInteger blue;

// float 后 三位小数
@property (nonatomic, assign) float redValue;
@property (nonatomic, assign) float greenValue;
@property (nonatomic, assign) float blueValue;

// 暂存元素
@property (nonatomic ,strong) NSXMLElement *XMLElement;
@property (nonatomic ,strong) NSXMLDocument *XMLDocument;
@property (nonatomic ,copy) NSString *filePath;


+ (CCColorModel *)colorModelWithElement:(NSXMLElement *)element;
@end
