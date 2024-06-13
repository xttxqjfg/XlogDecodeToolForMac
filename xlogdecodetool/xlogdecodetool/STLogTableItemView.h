//
//  STLogTableItemView.h
//  xlogdecodetool
//
//  Created by 易博 on 2024/2/2.
//

#import <Cocoa/Cocoa.h>

NS_ASSUME_NONNULL_BEGIN

@interface STLogTableItemView : NSView

- (void)updateTabelCellContentWithModel:(NSString *)entity;

- (void)fastDecodeFile;

@end

NS_ASSUME_NONNULL_END
