//
//  ViewController.m
//  ChangeInterfaceBuilderColor
//
//  Created by 灬C灬C灬 on 2018/8/29.
//  Copyright © 2018年 灬C灬C灬. All rights reserved.
//


#import "ViewController.h"
#import "CCColorModel.h"


typedef NS_ENUM(NSInteger, CCModifyType) {
    /* RGBA */
    CCModifyTypeRGBA        = 1 << 0,
    /* 颜色空间 */
    CCModifyTypeColorSpace  = 1 << 1,
};
@interface ViewController ()<NSTextDelegate, NSTableViewDelegate, NSTableViewDataSource>
@property (weak) IBOutlet NSTableView *tableView;
@property (weak) IBOutlet NSTextField *importPathTextField;
@property (unsafe_unretained) IBOutlet NSTextView *selectTextView;
@property (weak) IBOutlet NSTextField *countLabel;

@property (nonatomic ,strong) NSMutableArray<CCColorModel *> *matchColorModels;
@property (nonatomic ,strong) NSMutableDictionary<NSString *,CCColorModel *> *matchColorModelsFilePath;
@property (nonatomic ,strong) NSMutableArray<CCColorModel *> *selectColorModels;

@property (nonatomic, strong) CCColorModel *matchColorModel;
@property (nonatomic, strong) CCColorModel *modifyColorModel;
@property (nonatomic ,assign) CCModifyType modifyType;
@end


@implementation ViewController
#pragma mark - NSTextDelegate
- (void)controlTextDidChange:(NSNotification *)notification
{
    NSString *string = ((NSTextView *)notification.userInfo[@"NSFieldEditor"]).string;
    switch (((NSTextField *)notification.object).tag) {
        case 101:
            self.matchColorModel.red = string.integerValue;
            self.matchColorModel.redValue = string.floatValue / 255.f;
            break;
        case 102:
            self.matchColorModel.green = string.integerValue;
            self.matchColorModel.greenValue = string.floatValue / 255.f;
            break;
        case 103:
            self.matchColorModel.blue = string.integerValue;
            self.matchColorModel.blueValue = string.floatValue / 255.f;
            break;
        case 104:
            self.matchColorModel.alpha = string;
            break;
        case 105:
            self.matchColorModel.colorSpace = string;
            break;
        case 111:
            self.modifyColorModel.red = string.integerValue;
            self.modifyColorModel.redValue = string.floatValue / 255.f;
            break;
        case 112:
            self.modifyColorModel.green = string.integerValue;
            self.modifyColorModel.greenValue = string.floatValue / 255.f;
            break;
        case 113:
            self.modifyColorModel.blue = string.integerValue;
            self.modifyColorModel.blueValue = string.floatValue / 255.f;
            break;
        case 114:
            self.modifyColorModel.alpha = string;
            break;
        case 115:
            self.modifyColorModel.colorSpace = string;
            break;
    }
}


#pragma mark - Event Responses
- (IBAction)importPathAction:(NSButton *)button
{
    NSOpenPanel *openPanel = [NSOpenPanel openPanel];
    [openPanel setCanChooseFiles:YES];
    [openPanel setCanChooseDirectories:YES];
    
    NSWindow *window = [[NSApplication sharedApplication] keyWindow];
    [openPanel beginSheetModalForWindow:window completionHandler:^(NSModalResponse returnCode) {
        if (returnCode == 1) {
            NSURL *fileUrl = [[openPanel URLs] objectAtIndex:0];
            NSString *filePath = [[fileUrl.absoluteString componentsSeparatedByString:@"file://"] lastObject];
            NSLog(@"导入文件路径 = %@",filePath);
            self.importPathTextField.stringValue = filePath;
        }
    }];
}

- (IBAction)searchAction:(NSButton *)button
{
    if (!self.importPathTextField.stringValue.length) {
        NSLog(@"请选择路径");
        return;
    }
    
    CCColorModel *beforeModel = self.matchColorModel;
    // 有填 alpha 即默认改 RGBA
    if (self.matchColorModel.alpha.length) {
        self.modifyType = CCModifyTypeRGBA;
    }
    
    if (beforeModel.colorSpace.length) {
        if ([beforeModel.colorSpace isEqualToString:@"deviceRGB"] ||
            [beforeModel.colorSpace isEqualToString:@"calibratedRGB"] ||
            [beforeModel.colorSpace isEqualToString:@"displayP3"]) {
            self.modifyType = self.modifyType == CCModifyTypeRGBA ? (CCModifyTypeRGBA | CCModifyTypeColorSpace) : CCModifyTypeColorSpace;
        } else {
            NSAssert(nil, @"\ncolorSpace 只能从 deviceRGB、calibratedRGB、displayP3 替换成 sRGB");
        }
    }
    
    if (!(self.modifyType & CCModifyTypeRGBA) && !(self.modifyType & CCModifyTypeColorSpace)) {
        NSLog(@"无修改项目，填 RGBA、colorSpace 或二者都填");
        return;
    }
    
    
    // 寻找 xib、SB 文件
    [self.matchColorModels removeAllObjects];
    NSMutableArray<NSString *> *xibSBFilePaths = @[].mutableCopy;
    [self findXibOrStoryboardFile:self.importPathTextField.stringValue xibSBFilePaths:xibSBFilePaths];
    
    if (!xibSBFilePaths.count) {
        NSLog(@"error = 该路径下没有xib/storyboard文件");
    } else {
        NSLog(@"\n要匹配的色值：%@\n改为以下色值：%@\n修改类型：%ld",self.matchColorModel,self.modifyColorModel,self.modifyType);
        [self modifyFilePaths:xibSBFilePaths];
        self.countLabel.stringValue = [NSString stringWithFormat:@"%ld",self.matchColorModels.count];
        [self.tableView reloadData];
    }
}

- (IBAction)replaceAllAction:(NSButton *)button
{
    if (!self.matchColorModels.count) {
        return;
    }
    
    for (CCColorModel *model in self.matchColorModels) {
        [self updateXMLNodelWithNode:model.XMLElement modifyType:self.modifyType];
        for (NSInteger i = 0; i < self.matchColorModelsFilePath.allKeys.count; i++) {
            NSString *filePath = self.matchColorModelsFilePath.allKeys[i];
            if ([filePath isEqualToString:model.filePath]) {
                [self saveXMLFile:filePath xmlDoucment:self.matchColorModelsFilePath.allValues[i].XMLDocument];
            }
        }
    }
    [self.matchColorModels removeAllObjects];
    [self reloadData];
}

- (IBAction)replaceAction:(NSButton *)button
{
    if (!self.matchColorModelsFilePath.count) {
        return;
    }
    
    [self.selectColorModels enumerateObjectsUsingBlock:^(CCColorModel *model, NSUInteger index, BOOL * _Nonnull stop) {
        [self updateXMLNodelWithNode:model.XMLElement modifyType:self.modifyType];
        [self.matchColorModelsFilePath.allKeys enumerateObjectsUsingBlock:^(NSString *filePath, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([filePath isEqualToString:model.filePath]) {
                [self saveXMLFile:filePath xmlDoucment:self.matchColorModelsFilePath.allValues[idx].XMLDocument];
            }
        }];
        [self.matchColorModels removeObject:model];
    }];
    [self reloadData];
}

- (void)reloadData
{
    self.selectTextView.string = @"";
    self.countLabel.stringValue = self.tableView.selectedRowIndexes.count ? [NSString stringWithFormat:@"%ld of %ld",self.tableView.selectedRowIndexes.count,self.matchColorModels.count] : [NSString stringWithFormat:@"%ld",self.selectColorModels.count];
    [self.tableView reloadData];
}


#pragma mark - NSTableViewDelegate & NSTableViewDataSource
- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView
{
    return self.matchColorModels.count;
}

- (NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row
{
    CCColorModel *model = self.matchColorModels[row];
    NSTableCellView *cell;
    if (tableView.tableColumns[0] == tableColumn) {
        cell = [tableView makeViewWithIdentifier:@"SBCellID" owner:nil];
        cell.textField.stringValue = model.filePath.lastPathComponent;
    } else if (tableView.tableColumns[1] == tableColumn) {
        cell = [tableView makeViewWithIdentifier:@"ColorSpaceCellID" owner:nil];
        cell.textField.stringValue = model.colorSpace;
    } else if (tableView.tableColumns[2] == tableColumn) {
        cell = [tableView makeViewWithIdentifier:@"CustomSpaceCellID" owner:nil];
        cell.textField.stringValue = model.customColorSpace.length ? model.customColorSpace : @"null";
    } else if (tableView.tableColumns[3] == tableColumn) {
        cell = [tableView makeViewWithIdentifier:@"RGBACellID" owner:nil];
        cell.textField.stringValue = [NSString stringWithFormat:@"R:%ld G:%ld B:%ld A:%.2f",model.red, model.green, model.blue, model.alpha.floatValue];
    }
    return cell;
}

- (void)tableViewSelectionDidChange:(NSNotification *)notification
{
    NSIndexSet *indexSet = self.tableView.selectedRowIndexes;
    self.selectColorModels = [self.matchColorModels objectsAtIndexes:indexSet].copy;
    if (indexSet.count) {
        NSMutableAttributedString *attributeString = [[NSMutableAttributedString alloc] initWithString:self.selectColorModels[0].XMLDocument.description];
        [attributeString setAttributes:@{
                                         NSForegroundColorAttributeName : NSColor.redColor,
                                         NSFontAttributeName            : [NSFont systemFontOfSize:24.f]
                                         } range:[attributeString.string rangeOfString:self.matchColorModel.colorSpace]];
        [self.selectTextView.textStorage appendAttributedString:attributeString];
        self.countLabel.stringValue = [NSString stringWithFormat:@"%ld of %ld",self.selectColorModels.count,self.matchColorModels.count];
    } else {
        self.selectTextView.string = @"";
        self.countLabel.stringValue = [NSString stringWithFormat:@"%ld",self.matchColorModels.count];
    }
}


#pragma mark - 搜索匹配文件
/**
 搜索路径下所有的 XIB 或 SB 文件，并保持到 xibSBFilePath

 @param path            要查询的路径
 @param xibSBFilePath   保持到的数组
 */
- (void)findXibOrStoryboardFile:(NSString*)path xibSBFilePaths:(NSMutableArray *)xibSBFilePaths
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL isDir = NO;
    if ([fileManager fileExistsAtPath:path isDirectory:&isDir] && isDir) {
        NSArray *files = [fileManager contentsOfDirectoryAtPath:path error:nil];
        for (NSString *file in files) {
            [self findXibOrStoryboardFile:[path stringByAppendingPathComponent:file] xibSBFilePaths:xibSBFilePaths];
        }
    } else {
        if ([path containsString:@".xib"]) {
            [xibSBFilePaths addObject:path];
        } else if ([path containsString:@".storyboard"]) {
            [xibSBFilePaths addObject:path];
        }
    }
}

/**
 解析 XIB 或 SB 文件为 NSXML 相关

 @param filePaths 解析的文件数组
 */
- (void)modifyFilePaths:(NSMutableArray *)filePaths
{
    for (NSString *filePath in filePaths) {
        NSError *error = nil;
        NSData *xmlData = [NSData dataWithContentsOfFile:filePath];
        NSXMLDocument *document = [[NSXMLDocument alloc] initWithData:xmlData options:NSXMLNodePreserveWhitespace error:&error];
        NSXMLElement *rootElement = document.rootElement;
        [self parsedXMLDocument:document element:rootElement filePath:filePath];
        
        if (error) {
            NSLog(@"error = %@",error);
        }
    }
}

/**
 匹配 XML 文件

 @param document    父元素
 @param element     子元素
 @param filePath    路径
 */
- (void)parsedXMLDocument:(NSXMLDocument *)document element:(NSXMLElement *)element  filePath:(NSString *)filePath
{
    for (NSXMLElement *subElement in element.children) {
        if ([subElement.name isEqualToString:@"color"]) {
            CCColorModel *currentColor = [CCColorModel colorModelWithElement:subElement];
            currentColor.XMLDocument = document;
            currentColor.XMLElement = subElement;
            currentColor.filePath = filePath;
            if ((self.modifyType & CCModifyTypeRGBA) && (self.modifyType & CCModifyTypeColorSpace)) {
                // 更改色值 + 颜色空间
                if (fabsf((currentColor.redValue - self.matchColorModel.redValue)) < 0.003 &&
                    fabsf((currentColor.greenValue - self.matchColorModel.greenValue)) < 0.003 &&
                    fabsf((currentColor.blueValue - self.matchColorModel.blueValue)) < 0.003 &&
                    fabsf((currentColor.alpha.floatValue - self.matchColorModel.alpha.floatValue)) < 0.003 &&
                    ([currentColor.colorSpace isEqualToString:self.matchColorModel.colorSpace] ||
                    [currentColor.customColorSpace isEqualToString:self.matchColorModel.colorSpace])) {
                    // 修改元素
                    [self.matchColorModels addObject:currentColor];
                    [self.matchColorModelsFilePath setValue:currentColor forKey:filePath];
                }
            } else if (self.modifyType & CCModifyTypeRGBA) {
                // 只更改色值 、 差值在 0.003 内会被修改
                if (fabsf((currentColor.redValue - self.matchColorModel.redValue)) < 0.003 &&
                    fabsf((currentColor.greenValue - self.matchColorModel.greenValue)) < 0.003 &&
                    fabsf((currentColor.blueValue - self.matchColorModel.blueValue)) < 0.003 &&
                    fabsf((currentColor.alpha.floatValue - self.matchColorModel.alpha.floatValue)) < 0.003) {
                    // 修改元素
                    [self.matchColorModels addObject:currentColor];
                    [self.matchColorModelsFilePath setValue:currentColor forKey:filePath];
                }
            } else if (self.modifyType & CCModifyTypeColorSpace) {
                // 只更改颜色空间
                if ([currentColor.colorSpace isEqualToString:self.matchColorModel.colorSpace] ||
                    [currentColor.customColorSpace isEqualToString:self.matchColorModel.colorSpace]) {
                    // 修改元素
                    [self.matchColorModels addObject:currentColor];
                    [self.matchColorModelsFilePath setValue:currentColor forKey:filePath];
                }
            }
        }
        [self parsedXMLDocument:document element:subElement filePath:filePath];
    }
}


#pragma mark - 更新写入文件
/**
 更新元素值

 @param subElement 子元素
 @param modifyType 要修改的类型
 */
- (void)updateXMLNodelWithNode:(NSXMLElement *)subElement modifyType:(CCModifyType)modifyType
{
    NSString *beforeDescription = subElement.description.mutableCopy;
    NSArray *array = subElement.attributes;
    for (NSXMLNode *node in array) {
        if ([node.name isEqualToString:@"red"] && modifyType & CCModifyTypeRGBA) {
            node.stringValue = [NSString stringWithFormat:@"%f",self.modifyColorModel.redValue];
        } else if ([node.name isEqualToString:@"green"] && modifyType & CCModifyTypeRGBA) {
            node.stringValue = [NSString stringWithFormat:@"%f",self.modifyColorModel.greenValue];
        } else if ([node.name isEqualToString:@"blue"] && modifyType & CCModifyTypeRGBA) {
            node.stringValue = [NSString stringWithFormat:@"%f",self.modifyColorModel.blueValue];
        } else if ([node.name isEqualToString:@"alpha"] && modifyType & CCModifyTypeRGBA) {
            node.stringValue = self.modifyColorModel.alpha.length ? self.modifyColorModel.alpha : node.stringValue;
        } else if ([node.name isEqualToString:@"colorSpace"] && modifyType & CCModifyTypeColorSpace) {
            // deviceRGB calibratedRGB displayP3 -> sRGB
            node.stringValue = @"custom";
            [subElement addAttribute:[NSXMLNode attributeWithName:@"customColorSpace" stringValue:@"sRGB"]];
        }
    }
    NSLog(@"%@\n修改为\n%@",beforeDescription,subElement.description);
}

/**
 写入文件

 @param destPath        文件路径
 @param XMLDoucment     文件 XML
 */
- (void)saveXMLFile:(NSString *)filePath xmlDoucment:(NSXMLDocument *)XMLDoucment
{
    if (XMLDoucment == nil) {
        NSLog(@"路径为空");
    }
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
        if (![[NSFileManager defaultManager] createFileAtPath:filePath contents:nil attributes:nil]){
            NSLog(@"写入失败");
        }
    }
    
    NSData *XMLData = [XMLDoucment XMLDataWithOptions:NSXMLNodePrettyPrint];
    if (![XMLData writeToFile:filePath atomically:YES]) {
        NSLog(@"写入文件失败");
    }
}


#pragma mark - Getters And Setters
- (NSMutableArray<CCColorModel *> *)matchColorModels
{
    if (!_matchColorModels) {
        _matchColorModels = @[].mutableCopy;
    }
    return _matchColorModels;
}

- (NSMutableDictionary<NSString *,CCColorModel *> *)matchColorModelsFilePath
{
    if (!_matchColorModelsFilePath) {
        _matchColorModelsFilePath = @{}.mutableCopy;
    }
    return _matchColorModelsFilePath;
}

- (NSMutableArray<CCColorModel *> *)selectColorModels
{
    if (!_selectColorModels) {
        _selectColorModels = @[].copy;
    }
    return _selectColorModels;
}

- (CCColorModel *)matchColorModel
{
    if (!_matchColorModel) {
        _matchColorModel = [[CCColorModel alloc] init];
    }
    return _matchColorModel;
}

- (CCColorModel *)modifyColorModel
{
    if (!_modifyColorModel) {
        _modifyColorModel = [[CCColorModel alloc] init];
    }
    return _modifyColorModel;
}
@end
