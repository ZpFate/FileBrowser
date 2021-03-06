//
//  ViewController.m
//  FileBrowser
//
//  Created by Twisted Fate on 2020/9/24.
//

#import "ViewController.h"
#import <WebKit/WebKit.h>
#import <AFNetworking/AFNetworking.h>
#import <QuickLook/QuickLook.h>

#import "TFPDFBrowserVC.h"

@interface ViewController ()<WKUIDelegate,WKNavigationDelegate, QLPreviewControllerDelegate, QLPreviewControllerDataSource>

@property (nonatomic, strong) WKWebView *wkWebView;

@property (nonatomic, strong) QLPreviewController *previewController;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
//    [self setupViews];
    [self loadLocalPDFFile];
    [self downloadFile];
}

- (void)setupViews {
    
    UIBarButtonItem *barItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(previewAction)];
    self.navigationItem.rightBarButtonItem = barItem;
    
    [self.view addSubview:self.wkWebView];
}

- (void)previewAction {
    
    NSString *pdfPath = [[NSBundle mainBundle] pathForResource:@"test" ofType:@"pdf"];

    TFPDFBrowserVC *browserVC = [[TFPDFBrowserVC alloc] initWithFilePath:pdfPath];
    
    UINavigationController *naVC = [[UINavigationController alloc] initWithRootViewController:browserVC];
    naVC.modalPresentationStyle = UIModalPresentationFullScreen;
    
    [self presentViewController:naVC animated:YES completion:nil];
    
}

#pragma mark -- 加载本地PDF文件

- (void)loadLocalPDFFile {
    
    NSString *pdfPath = [[NSBundle mainBundle] pathForResource:@"test" ofType:@"pdf"];
    NSURL *fileUrl = [NSURL fileURLWithPath:pdfPath];
    [self.wkWebView loadFileURL:fileUrl allowingReadAccessToURL:fileUrl];
}

#pragma mark -- PDF乱码加载二进制文件

- (void)loadPDFData {
    NSString *pdfPath = [[NSBundle mainBundle] pathForResource:@"test" ofType:@"pdf"];
    NSData *pdfData = [[NSData alloc] initWithContentsOfFile:pdfPath];
    [self.wkWebView loadData:pdfData MIMEType:@"application/pdf" characterEncodingName:@"GBK" baseURL:[NSURL URLWithString:pdfPath]];
}

#pragma mark -- 加载网络PDF文件

- (void)downloadFile {
    
    NSString *urlString = @"https://raw.githubusercontent.com/ZpFate/FileBrowser/master/FileBrowser/test.pdf";
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:urlString]];
    NSURLSessionDownloadTask *task = [[AFHTTPSessionManager manager] downloadTaskWithRequest:request progress:^(NSProgress * _Nonnull downloadProgress) {
        NSLog(@"downloadProgress == %@", downloadProgress);
    } destination:^NSURL * _Nonnull(NSURL * _Nonnull targetPath, NSURLResponse * _Nonnull response) {
        
        NSString *fullPath = [[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:response.suggestedFilename];
        return [NSURL fileURLWithPath:fullPath];
    } completionHandler:^(NSURLResponse * _Nonnull response, NSURL * _Nullable filePath, NSError * _Nullable error) {
        
        NSString *path = filePath.path;
        
        TFPDFBrowserVC *browserVC = [[TFPDFBrowserVC alloc] initWithFilePath:path];
        
        UINavigationController *naVC = [[UINavigationController alloc] initWithRootViewController:browserVC];
        naVC.modalPresentationStyle = UIModalPresentationFullScreen;
        
        [self presentViewController:naVC animated:YES completion:nil];
        
        NSLog(@"error = %@", error);
    }];
    
    [task resume];
}

#pragma mark -- Delegate

- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler {
//    NSString *_webUrlStr = navigationAction.request.URL.absoluteString;
//    NSString *lastName =[[_webUrlStr lastPathComponent] lowercaseString];
    
//    if ([lastName containsString:@".pdf"])
//    {
//        NSData *data = [NSData dataWithContentsOfURL:navigationAction.request.URL];
//        [self.wkWebView loadData:data MIMEType:@"application/pdf" characterEncodingName:@"GBK" baseURL:[NSURL URLWithString:_webUrlStr]];
//    }
    decisionHandler(WKNavigationActionPolicyAllow);
}

- (NSInteger)numberOfPreviewItemsInPreviewController:(QLPreviewController *)controller {
    return 1;
}

- (id<QLPreviewItem>)previewController:(QLPreviewController *)controller previewItemAtIndex:(NSInteger)index {
    NSString *pdfPath = [[NSBundle mainBundle] pathForResource:@"test" ofType:@"pdf"];
    return [NSURL fileURLWithPath:pdfPath];
}



#pragma mark -- Getter

- (QLPreviewController *)previewController {
    if (!_previewController) {
        _previewController = [[QLPreviewController alloc] init];
        _previewController.delegate = self;
        _previewController.dataSource = self;
    }
    return _previewController;
}

- (WKWebView *)wkWebView {
    if (!_wkWebView) {
        WKUserContentController *userContentController = WKUserContentController.alloc.init;
        WKWebViewConfiguration *configuration = WKWebViewConfiguration.alloc.init;
        configuration.userContentController = userContentController;
        _wkWebView = [WKWebView.alloc initWithFrame:self.view.bounds configuration:configuration];
        _wkWebView.UIDelegate = self;
        _wkWebView.navigationDelegate = self;
    }
    return _wkWebView;
}


@end
