//
//  STLogTableItemView.m
//  xlogdecodetool
//
//  Created by 易博 on 2024/2/2.
//

#import "STLogTableItemView.h"
#include "decode_log_file.h"

typedef NS_ENUM(NSUInteger, STLogTableItemViewButtonType) {
    STLogTableItemViewButtonTypeDefault     = 1000,//未下载
    STLogTableItemViewButtonTypeDownload    = 2000,//已下载，未解密
    STLogTableItemViewButtonTypeDecode      = 3000//已解密
};

@interface STLogTableItemView()
@property (weak) IBOutlet NSTextField *logNameLabel;
@property (weak) IBOutlet NSButton *logDownBtn;
@property (weak) IBOutlet NSTextField *modifyDateLabel;
@property (weak) IBOutlet NSTextField *fileSizeLabel;

@property (nonatomic,strong) NSString *localFilePath;
@property (nonatomic,strong) NSString *localFileOutPath;
@property (nonatomic,strong) NSString *currentFileInfoEntity;
@end

@implementation STLogTableItemView

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    
    // Drawing code here.
}

- (void)updateTabelCellContentWithModel:(NSString *)entity {
    self.currentFileInfoEntity = entity;
    self.logNameLabel.stringValue = entity;
    self.modifyDateLabel.stringValue = @"";
    self.fileSizeLabel.stringValue = @"0 Byte";
    
    self.logDownBtn.tag = STLogTableItemViewButtonTypeDefault;
    if([entity hasPrefix:@"file://"]) {
        self.localFilePath = [entity stringByReplacingOccurrencesOfString:@"file://" withString:@""];
        //从其他目录读取的文件需要将解密目录重置，否则会存在访问权限问题
        NSArray *pathArr = [self.localFilePath componentsSeparatedByString:@"/"];
        self.localFileOutPath = [[self getDecodePath] stringByAppendingFormat:@"/%@.log",[pathArr lastObject]];
    }
    else {
        self.localFilePath = [[self getDecodePath] stringByAppendingFormat:@"/%@",[entity lastPathComponent]];
        self.localFileOutPath = [NSString stringWithFormat:@"%@.log",self.localFilePath];
    }
    [self checkFileIsExit];
}

- (NSString *)transModifyDateTime:(NSString *)originDate {
    //2024-05-08T08:53:04.000Z
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.SSSZ"];
    [dateFormatter setTimeZone:[NSTimeZone systemTimeZone]];
    NSDate *date = [dateFormatter dateFromString:originDate];
    
    NSDateFormatter *dateFormatterNew = [[NSDateFormatter alloc] init];
    //设定时间格式,这里可以设置成自己需要的格式
    [dateFormatterNew setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    //用[NSDate date]可以获取系统当前时间
    NSString *dateTimeStr = [dateFormatterNew stringFromDate:date];
    return dateTimeStr ? dateTimeStr : @"";
}

- (void)fastDecodeFile {
    [self logDownOptionClicked:self.logDownBtn];
}

//检查文件是否存在
- (void)checkFileIsExit {
    //解密前文件
    if ([[NSFileManager defaultManager] fileExistsAtPath:self.localFilePath]) {
        self.logDownBtn.tag = STLogTableItemViewButtonTypeDownload;
        [self.logDownBtn setTitle:@"解密"];
    }
    //解密后文件
    if ([[NSFileManager defaultManager] fileExistsAtPath:self.localFileOutPath]) {
        self.logDownBtn.tag = STLogTableItemViewButtonTypeDecode;
        [self.logDownBtn setTitle:@"打开"];
    }
}

- (NSString *)getDecodePath {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDownloadsDirectory, NSUserDomainMask, YES);
    NSString *path = [paths objectAtIndex:0];
    path = [path stringByAppendingPathComponent:@"xlogdecodetool"];
    BOOL isDir = YES;
    if (![[NSFileManager defaultManager] fileExistsAtPath:path isDirectory:&isDir]) {
        //文件夹不存在，创建文件夹
        NSError *err;
        BOOL success = [[NSFileManager defaultManager] createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:&err];
    }
    return path;
}

- (IBAction)logDownOptionClicked:(NSButton *)sender {
    //检测当前文件是不是存在，存在则直接打开文件夹
    switch (sender.tag) {
        case STLogTableItemViewButtonTypeDownload:
        {
            const char *inPath = [self.localFilePath cStringUsingEncoding:NSASCIIStringEncoding];
            const char *outPath = [self.localFileOutPath cStringUsingEncoding:NSASCIIStringEncoding];
            parseFile(inPath, outPath);
            [self checkFileIsExit];
            break;
        }
        case STLogTableItemViewButtonTypeDecode:
        {
            [[NSWorkspace sharedWorkspace] selectFile:self.localFileOutPath
                             inFileViewerRootedAtPath:@""];
            break;
        }
        case STLogTableItemViewButtonTypeDefault:
        default:
        {
            //
            break;
        }
    }
}

@end
