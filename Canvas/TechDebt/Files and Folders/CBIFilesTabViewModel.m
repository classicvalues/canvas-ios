
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
    
    

#import "CBIFilesTabViewModel.h"
#import "CBIFileViewModel.h"
#import "CBIFolderViewModel.h"
#import <CanvasKit/CanvasKit.h>
#import "Router.h"
#import "EXTScope.h"
#import "ReceivedFilesViewController.h"
@import CanvasKeymaster;

@import SoPretty;
@import CanvasKit;

@interface CBIFilesTabViewModel () <UIAlertViewDelegate, UIActionSheetDelegate>
@property (nonatomic, strong) CKIFolder *rootFolder;
@property (nonatomic, strong) UIBarButtonItem *addItem;
@property (nonatomic, strong) ToastManager *toastManager;
@property (nonatomic) BOOL canAddFilesOrFolders;
@end


@implementation CBIFilesTabViewModel

- (id)init
{
    self = [super init];
    if (self) {
        self.toastManager = [ToastManager new];
        NSSortDescriptor *caseInsensitiveCompare = [[NSSortDescriptor alloc] initWithKey:@"name" ascending:YES selector:@selector(localizedCaseInsensitiveCompare:)];
        self.collectionController = [MLVCCollectionController collectionControllerGroupingByBlock:nil groupTitleBlock:nil sortDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"index" ascending:YES], caseInsensitiveCompare]];
        self.viewControllerTitle = NSLocalizedString(@"Files", @"Title for the files screen");
        
        RAC(self, canAddFilesOrFolders) = [RACObserve(self, model.context) flattenMap:^id(id context) {
            
            if ([context isKindOfClass:[CKIGroup class]]) {
                return [RACSignal return:@(YES)];
            }
            
            if ([context isKindOfClass:[CKICourse class]]) {
                return [[TheKeymaster.currentClient refreshModel:(CKICourse *)context parameters:nil] map:^id(CKICourse *course) {
                    for (CKIEnrollment *enrollment in course.enrollments) {
                        if (enrollment.type == CKIEnrollmentTypeTeacher || enrollment.type == CKIEnrollmentTypeTA) {
                            return @(YES);
                        }
                    }
                    return @(NO);
                }];
            }

            return [RACSignal return:@(NO)];
        }];
    }
    return self;
}

- (void)viewController:(UIViewController *)viewController viewWillAppear:(BOOL)animated
{
    [[RACSignal combineLatest:@[RACObserve(self, rootFolder), RACObserve(self, canAddFilesOrFolders)] reduce:^id(CKIFolder *rootFolder, NSNumber *canAddFilesOrFolders) {
        
        return @(rootFolder != nil && canAddFilesOrFolders.boolValue);
    }] subscribeNext:^(NSNumber *canAddFilesOrFolders) {
        if (canAddFilesOrFolders.boolValue) {
            self.addItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addButtonTouched:)];
            viewController.navigationItem.rightBarButtonItem = self.addItem;
        } else {
            viewController.navigationItem.rightBarButtonItem = nil;
        }
    }];
}

- (void)addButtonTouched:(UIBarButtonItem *)item
{
    self.addItem.enabled = NO;
    UIActionSheet *addActionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:NSLocalizedString(@"Cancel","Cancel button title") destructiveButtonTitle:nil otherButtonTitles:NSLocalizedString(@"Add a folder", nil), NSLocalizedString(@"Upload a file", nil), nil];
    [addActionSheet showFromBarButtonItem:item animated:YES];
}

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    self.addItem.enabled = YES;
    if (buttonIndex == 0) {
        UIAlertView *createAlertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"New Folder", nil) message:NSLocalizedString(@"Choose a name for the new folder", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"Cancel", "Cancel button title") otherButtonTitles:NSLocalizedString(@"Create Folder", "cancel folder creation"), nil];
        createAlertView.alertViewStyle = UIAlertViewStylePlainTextInput;
        [createAlertView show];
    } else if (buttonIndex == 1) {
        ReceivedFilesViewController *filesController = [ReceivedFilesViewController new];
        @weakify(filesController);
        filesController.submitButtonTitle = NSLocalizedString(@"Upload", @"Button title for uploading a file");
        filesController.onSubmitBlock = ^(NSArray *urls) {
            @strongify(filesController);
            [filesController dismissViewControllerAnimated:YES completion:^{
                if (urls.count == 0) {
                    return;
                }
                
                NSMutableArray *signalsArray = [NSMutableArray array];
                
                [self.toastManager statusBarToastInfo:[NSString stringWithFormat:@"Uploading File%@...", urls.count > 1 ? @"s" : @""] completion:nil];
                [urls enumerateObjectsUsingBlock:^(NSURL *fileURL, NSUInteger idx, BOOL *stop) {
                    NSString *extension = [[fileURL absoluteString] pathExtension];
                    NSData *fileData = [NSData dataWithContentsOfURL:fileURL options:NSDataReadingMappedIfSafe error:NULL];
                    
                    RACSignal *uploadSignal = [[CKIClient currentClient] uploadFile:fileData ofType:extension withName:[fileURL lastPathComponent] inFolder:self.rootFolder];
                    [signalsArray addObject:uploadSignal];
                }];
                
                @weakify(self);
                [[RACSignal merge:signalsArray] subscribeNext:^(CKIFile *newFile) {
                    @strongify(self);
                    CBIFileViewModel *fileViewModel = [[CBIFileViewModel alloc] init];
                    fileViewModel.model = newFile;
                    fileViewModel.index = 1;
                    fileViewModel.tintColor = self.tintColor;
                    [self.collectionController insertObjects:@[fileViewModel]];
                } error:^(NSError *error) {
                    @strongify(self);
                    [self.toastManager dismissNotification];
                } completed:^{
                    @strongify(self);
                    [self.toastManager dismissNotification];
                }];
            }];
        };
        filesController.modalPresentationStyle = UIModalPresentationFormSheet;
        
        UIWindow *window = [UIApplication sharedApplication].windows[0];
        [window.rootViewController presentViewController:filesController animated:YES completion:nil];
    }
    
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if (buttonIndex != alertView.cancelButtonIndex) {
        CKIFolder *folder = [CKIFolder new];
        folder.name = [alertView textFieldAtIndex:0].text;
        [[[CKIClient currentClient] createFolder:folder InFolder:self.rootFolder] subscribeNext:^(CKIFolder *newFolder) {
            CBIFolderViewModel *folderViewModel = [[CBIFolderViewModel alloc] init];
            folderViewModel.model = newFolder;
            folderViewModel.index = 0;
            folderViewModel.tintColor = self.tintColor;
            [self.collectionController insertObjects:@[folderViewModel]];
        }];
    }
    
}

#pragma mark - syncing

- (RACSignal *)refreshViewModelsSignal
{
    RACSignal *folderSignal = [[[CKIClient currentClient] fetchRootFolderForContext:self.model.context] replay];

    @weakify(self);
    
    [folderSignal subscribeNext:^(CKIFolder *rootFolder) {
        @strongify(self);
        self.rootFolder = rootFolder;
    }];
    
    return [folderSignal flattenMap:^id(CKIFolder *folder) {
        RACSignal *filesSignal = [[[CKIClient currentClient] fetchFilesForFolder:folder] map:^(NSArray *files) {
            return [[files.rac_sequence map:^id(CKIFile *file) {
                @strongify(self);
                CBIFileViewModel *viewModel = [CBIFileViewModel new];
                viewModel.index = 1;
                viewModel.model = file;
                RAC(viewModel, tintColor) = RACObserve(self, tintColor);
                return viewModel;
            }] array];
        }];
        
        RACSignal *foldersSignal = [[[CKIClient currentClient] fetchFoldersForFolder:folder] map:^id(NSArray *folders) {
            return [[folders.rac_sequence map:^id(CKIFolder *folder) {
                @strongify(self);
                CBIFolderViewModel *viewModel = [CBIFolderViewModel new];
                viewModel.index = 0;
                viewModel.model = folder;
                RAC(viewModel, tintColor) = RACObserve(self, tintColor);
                return viewModel;
            }] array];
        }];
        
        RACSignal *foldersAndFiles = [RACSignal merge:@[filesSignal, foldersSignal]];

        return foldersAndFiles;
    }];
}

@end
