
//
// Copyright (C) 2016-present Instructure, Inc.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//
    
    

import UIKit
import TooLegit
import SoPersistent
import CoreData
import ReactiveCocoa

extension File {
    public static func observer(session: Session, backgroundSessionID: String) throws -> ManagedObjectObserver<FileUpload> {
        let pred = NSPredicate(format: "%K == %@", "backgroundSessionID", backgroundSessionID)
        let context = try session.filesManagedObjectContext()
        return try ManagedObjectObserver<FileUpload>(predicate: pred, inContext: context)
    }
    
    static func collectionCacheKey(context: NSManagedObjectContext, contextID: ContextID, folderID: String?) -> String {
        return cacheKey(context, [contextID.canvasContextID, folderID].flatMap { $0 })
    }
    
    public class DetailViewController: UIViewController {
        private let session: Session
        private let file: File
        
        required public init?(coder aDecoder: NSCoder) {
            fatalError()
        }
        
        public init(session: Session, file: File) {
            self.file = file
            self.session = session
            super.init(nibName: nil, bundle: nil)
       }
        
        override public func viewDidLoad() {
            super.viewDidLoad()

            let webView: UIWebView = UIWebView()
            webView.scalesPageToFit = true
            let request: NSURLRequest = NSURLRequest(URL: self.file.url)
            webView.loadRequest(request)
            webView.backgroundColor = UIColor.whiteColor()
            self.view = webView
            self.automaticallyAdjustsScrollViewInsets = false
            self.edgesForExtendedLayout = UIRectEdge.None
        }
    }
}
