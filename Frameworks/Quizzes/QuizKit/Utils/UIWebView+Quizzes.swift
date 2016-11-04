
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
    
    

import Foundation

extension UIWebView {
    func scalePageToFit() {
        let docWidth = Int(self.stringByEvaluatingJavaScriptFromString("$(document).width()") ?? String(UIScreen.mainScreen().bounds.size.width))
        
        if docWidth == nil || docWidth == 0 {
            return
        }
        
        let scale = self.bounds.size.width / CGFloat(docWidth!)
        
        // fix scale
        stringByEvaluatingJavaScriptFromString(String(format:
            "metaElement = document.querySelector('meta[name=viewport]');" +
            "if (metaElement == null) { metaElement = document.createElement('meta'); }" +
            "metaElement.name = \"viewport\";" +
            "metaElement.content = \"minimum-scale=%.2f, initial-scale=%.2f, maximum-scale=1.0, user-scalable=yes\";" +
            "var head = document.getElementsByTagName('head')[0];" +
            "head.appendChild(metaElement);", scale, scale))
    }
}