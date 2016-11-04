
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
    
    

// Don't set line number in EarlGreyUtils.
// Must be invoked via the calling method inside the page object.


import EarlGrey

// Must use wrapper class to force pass by reference in block.
// inout params won't work. http://stackoverflow.com/a/28252105
public class Element {
  var text = ""
}

/*
 *  Example Usage:
 *
 *  let element = Element()
 *
 *  domainField.performAction(grey_replaceText("hello.there"))
 *             .performAction(grey_getText(element))
 *
 *  GREYAssertTrue(element.text != "", reason: "get text failed")
 */
func grey_getText(elementCopy: Element) -> GREYActionBlock {
  return GREYActionBlock.actionWithName("get text",
                                        constraints: grey_respondsToSelector(Selector("text")),
                                        performBlock: { element, errorOrNil -> Bool in
    // Fix error: ambiguous use of 'text'
    // http://stackoverflow.com/a/25620623
    elementCopy.text = String(element.text ?? "")
    return true
  })
}
