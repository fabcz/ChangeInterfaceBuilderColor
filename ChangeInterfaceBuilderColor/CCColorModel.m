//
//  WDColorModel.m
//  ChangeInterfaceBuilderColor
//
//  Created by 灬C灬C灬 on 2018/8/29.
//  Copyright © 2018年 灬C灬C灬. All rights reserved.
//

#import "CCColorModel.h"


@implementation CCColorModel
#pragma mark - Public Methods
+ (CCColorModel *)colorModelWithElement:(NSXMLElement *)element
{
    CCColorModel *model = [[CCColorModel alloc] init];
    for (NSXMLNode *node in element.attributes) {
        if ([node.name isEqualToString:@"key"] ||
            [node.name isEqualToString:@"colorSpace"] ||
            [node.name isEqualToString:@"customColorSpace"] ||
            [node.name isEqualToString:@"alpha"]) {
            [model setValue:node.stringValue forKey:node.name];
        } else if ([node.name isEqualToString:@"red"]) {
            model.redValue = node.stringValue.floatValue;
            model.red = model.redValue * 255.f;
        } else if ([node.name isEqualToString:@"green"]) {
            model.greenValue = node.stringValue.floatValue;
            model.green = model.greenValue * 255.f;
        } else if ([node.name isEqualToString:@"blue"]) {
            model.blueValue = node.stringValue.floatValue;
            model.blue = model.blueValue * 255.f;
        }
    }
    return model;
}


#pragma mark - Private Methods
- (NSString *)description
{
    return [NSString stringWithFormat:@"\n key = %@\n red = %ld\n green = %ld\n blue = %ld\n alpha = %@\n colorSpace = %@\n customColorSpace = %@\n filePath = %@",_key ,_red, _green, _blue, _alpha, _colorSpace, _customColorSpace, _filePath];
}
@end
