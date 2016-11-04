
//
// Copyright (C) 2016-present Instructure, Inc.
//   
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, version 3 of the License.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this program.  If not, see <http://www.gnu.org/licenses/>.
//
    
    

#import "CBISyllabusDetailViewController.h"
#import <CanvasKit/CanvasKit.h>
#import <CanvasKit1/CanvasKit1.h>
#import "UIViewController+AnalyticsTracking.h"
#import "WebBrowserViewController.h"
#import "UIWebView+SafeAPIURL.h"
#import "CBISplitViewController.h"
#import "Router.h"
@import CanvasKeymaster;
#import "CBILog.h"
@import Crashlytics;

@interface CBISyllabusDetailViewController () <UIWebViewDelegate>
@property (nonatomic, strong) UIWebView *webView;
@end

@implementation CBISyllabusDetailViewController

@synthesize course = _course;

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if (self.viewModel) {
        [[[CKIClient currentClient] courseWithUpdatedPermissionsSignalForCourse:self.viewModel.model] subscribeNext:^(CKICourse *course) {
            CKCourse *model = [CKCourse new];
            self.course = [model initWithInfo:[course JSONDictionary]];
        }];
    }
}

- (void)viewDidLoad
{
    
    [super viewDidLoad];
    CLS_LOG(@"Loaded Syllabus Detail View");
    
    self.webView = [[UIWebView alloc] init];
    self.webView.delegate = self;
    [self.view addSubview:self.webView];
    
    [self.webView setTranslatesAutoresizingMaskIntoConstraints:NO];
    UIView *innerView = self.webView;
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[innerView]|" options:0 metrics:NULL views:NSDictionaryOfVariableBindings(innerView)]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[innerView]|" options:0 metrics:NULL views:NSDictionaryOfVariableBindings(innerView)]];
    [self.view layoutIfNeeded];

    [self updateWebView];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self.webView setFrame:self.view.frame];
    self.edgesForExtendedLayout = UIRectEdgeNone;
}


- (void)dealloc
{
    self.webView.delegate = nil;
}

- (void)updateWebView
{
    if (self.course){
        NSString *pathToTemplateFile = [[NSBundle bundleForClass:[self class]] pathForResource:@"SyllabusDetails" ofType:@"html"];
        NSURL *baseURL = [NSURL fileURLWithPath:[pathToTemplateFile stringByDeletingLastPathComponent] isDirectory:YES];
        NSError *error = nil;
        NSString *htmlTemplate = [NSString stringWithContentsOfFile:pathToTemplateFile encoding:NSUTF8StringEncoding error:&error];
        
        NSString *scrubbedHTML = [htmlTemplate stringByReplacingOccurrencesOfString:@"{$TITLE$}" withString:self.course.name ?: @""];
        scrubbedHTML = [scrubbedHTML stringByReplacingOccurrencesOfString:@"{$COURSE_CODE$}" withString:self.course.courseCode ?: @""];
        scrubbedHTML = [scrubbedHTML stringByReplacingOccurrencesOfString:@"{$CONTENT$}" withString:self.course.syllabusBody ?: @""];
        
        self.webView.dataDetectorTypes = UIDataDetectorTypeAll;
        [self.webView loadHTMLString:scrubbedHTML baseURL:baseURL];
    }
}

- (void)setCourse:(CKCourse *)course
{
    _course = course;
    [self updateWebView];
}

#pragma mark - UIWebViewDelegate

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    if (navigationType == UIWebViewNavigationTypeOther) {
        return YES;
    }

    [[Router sharedRouter] routeFromController:self toURL:request.URL];
    return NO;
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    [webView replaceHREFsWithAPISafeURLs];
    
    [webView.scrollView scrollRectToVisible:CGRectMake(0, 0, 1, 1) animated:NO];
}

@end
