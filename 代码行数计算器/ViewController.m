//
//  ViewController.m
//  代码行数计算器
//
//  Created by admin on 15/1/12.
//  Copyright (c) 2015年 zwk. All rights reserved.
//

#import "ViewController.h"

@interface ViewController(){
    NSString *_path ;
}
@property (strong) IBOutlet NSTextField *inputTextField;
- (IBAction)choseBtnAction:(id)sender;
@property (strong) IBOutlet NSButton *startBtn;
- (IBAction)startAction:(id)sender;
@property (strong) IBOutlet NSTextField *resultLabel;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    // Do any additional setup after loading the view.
}

- (void)setStartBtnStatusWith:(int)status{
    if(0 == status){ //普通
        self.startBtn.enabled = YES;
        [self.startBtn setTitle:@"计算结果"];
    }else if(1 == status){ // 计算中
         self.startBtn.enabled = NO;
         [self.startBtn setTitle:@"计算中..."];
    }
}

- (void)setRepresentedObject:(id)representedObject {
    [super setRepresentedObject:representedObject];
}

- (IBAction)choseBtnAction:(id)sender {
    //显示 文件对话窗口test
    NSOpenPanel *open = [NSOpenPanel openPanel];
    [open setAllowsMultipleSelection:NO];
    [open setCanChooseFiles:NO];
    [open setCanChooseDirectories:YES];
    
    [open beginWithCompletionHandler:^(NSInteger result) {
        if (result == NSOKButton){
            NSURL *url = [open URL];
            NSString *urlPath  = [url absoluteString];
            
            
            NSRange range = [urlPath rangeOfString:@"file://"];
            
            NSString *path = [urlPath substringFromIndex:range.length]; //  所选文件
            NSLog(@"url = %@",path);
            [self.inputTextField setTitleWithMnemonic:path];//设置textField内容
            _path = path;
        }
    }];
}
- (IBAction)startAction:(id)sender {
    [self setStartBtnStatusWith:1];
    NSUInteger *count = countLine(_path);
     [self.resultLabel setTitleWithMnemonic:[NSString stringWithFormat:@"共有:%d 行代码",count]];//设置textField内容
     [self setStartBtnStatusWith:0];
}

NSUInteger countLine(NSString * path)
{
    NSFileManager * manager = [NSFileManager defaultManager];
    
    
    //判断是否为文件夹，默认为NO
    BOOL dir = NO;
    
    //判断地址是否合法，不合法返回0
    BOOL exist = [manager fileExistsAtPath:path isDirectory:&dir];
    
    if (!exist) {
        return 0;
    }
    
    //如果是文件夹，则遍历里面所有文件
    if (dir)
    {
        NSArray * filepath = [manager contentsOfDirectoryAtPath:path error:nil];
        
        int count = 0;
        
        for (NSString * fileName in filepath) {
            
            //把文件名后接在path，获取子文件详细路径
            NSString * fullFilePath = [NSString stringWithFormat:@"%@/%@",path,fileName];
            
            count += countLine(fullFilePath);
        }
        
        return count;
    }
    //如果是文件，则计算文件里面的行数
    else
    {
        //判断是否为.m .c .h文件，若不是则返回0
        NSString *extension = [[path pathExtension] lowercaseString];
        
        if (![extension isEqualToString:@"m"]&&![extension isEqualToString:@"h"]&&![extension isEqualToString:@"c"])
        {
            return 0;
        }
        else
        {
            //1.读取文件中所有字符串
            NSString * content = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
            
            //2.用\n分割文件行数
            NSArray * totalLineCount = [content componentsSeparatedByString:@"\n"];
            
            NSArray * commentLineCount = [content componentsSeparatedByString:@"//"];
            
            NSInteger lineCount = totalLineCount.count - commentLineCount.count;
            
            //3.打印所有计算了的文件
            NSLog(@"%@ - %ld",path,lineCount);
            
            return lineCount;
        }
        
    }
    
}
@end
