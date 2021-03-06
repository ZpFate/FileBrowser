//
//  TFPDFBrowserView.h
//  FileBrowser
//
//  Created by Twisted Fate on 2020/10/19.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface TFPDFBrowserView : UIView

- (instancetype)initWithFilePath:(NSString *)filePath;

- (void)lastPage;

- (void)nextPage;

@end

NS_ASSUME_NONNULL_END
