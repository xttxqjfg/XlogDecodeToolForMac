//
//  ViewController.m
//  xlogdecodetool
//
//  Created by 易博 on 2024/6/13.
//

#import "ViewController.h"
#import "CustomTableRowView.h"
#import "STLogTableItemView.h"

@interface ViewController()<NSTableViewDelegate,NSTableViewDataSource>

@property (weak) IBOutlet NSTableView *logListTable;

@property (nonatomic,strong) NSMutableArray<NSString *> *searchResultList;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    // Do any additional setup after loading the view.
    self.logListTable.delegate = self;
    self.logListTable.dataSource = self;
}

- (IBAction)localFileDecodeBtn:(NSButton *)sender {
    NSOpenPanel *openPanel = [NSOpenPanel openPanel];
    [openPanel setCanChooseDirectories:NO];//是否可以选择文件夹
    [openPanel setCanChooseFiles:YES];//是否可以选择文件
    [openPanel setAllowsMultipleSelection:YES];//是否可以多选
    BOOL okButtonPressed = ([openPanel runModal] == NSModalResponseOK);
    //[openPanel runModal]此时线程会停在这里等待选择
    //NO表示用户取消 YES表示用户做出选择
    if(okButtonPressed) {
        NSLog(@"选择的文件列表：%@",openPanel.URLs);
        [self.searchResultList removeAllObjects];
        for (NSURL *fileUrl in openPanel.URLs) {
            if ([[fileUrl pathExtension] isEqualToString:@"xlog"]) {
                [self.searchResultList addObject:fileUrl.absoluteString];
            }
        }
        [self.logListTable reloadData];
    }
}


- (IBAction)fastDecodeBtn:(NSButton *)sender {
    if(0 == self.searchResultList.count) {
        return;
    }
    
    [self.logListTable enumerateAvailableRowViewsUsingBlock:^(__kindof NSTableRowView * _Nonnull rowView, NSInteger row) {
        STLogTableItemView *itemView = (STLogTableItemView *)[rowView viewAtColumn:0];
        if (itemView) {
            [itemView fastDecodeFile];
        }
    }];
}

#pragma mark -- NSTableViewDelegate,NSTableViewDataSource --
//返回行数
-(NSInteger)numberOfRowsInTableView:(NSTableView *)tableView{
    return self.searchResultList.count;
}

-(CGFloat)tableView:(NSTableView *)tableView heightOfRow:(NSInteger)row{
    return 80;
}

- (NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {
    STLogTableItemView *contentView = [tableView makeViewWithIdentifier:tableColumn.identifier owner:self];
    if (!contentView) {
        NSArray *views = nil;
        [[NSBundle mainBundle] loadNibNamed:@"STLogTableItemView" owner:nil topLevelObjects:&views];
        for (NSView *view in views) {
            if ([view isKindOfClass:[STLogTableItemView class]]) {
                contentView = (STLogTableItemView *)view;
                break;
            }
        }
    }
    [contentView updateTabelCellContentWithModel:[self.searchResultList objectAtIndex:row]];
    return contentView;
}

//自定义 row view
- (NSTableRowView *)tableView:(NSTableView *)tableView rowViewForRow:(NSInteger)row {
    CustomTableRowView *rowView = [tableView makeViewWithIdentifier:@"rowView" owner:self];
    if (rowView == nil) {
        rowView = [[CustomTableRowView alloc] init];
        rowView.identifier = @"rowView";
    }
    return rowView;
}

#pragma mark -- get --
- (NSMutableArray *)searchResultList {
    if (!_searchResultList) {
        _searchResultList = [[NSMutableArray alloc]init];
    }
    return _searchResultList;
}

@end
