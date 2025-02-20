//
// This file is part of Canvas.
// Copyright (C) 2019-present  Instructure, Inc.
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU Affero General Public License as
// published by the Free Software Foundation, either version 3 of the
// License, or (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU Affero General Public License for more details.
//
// You should have received a copy of the GNU Affero General Public License
// along with this program.  If not, see <https://www.gnu.org/licenses/>.
//

import XCTest
@testable import Core

class EmptyViewControllerTests: CoreTestCase {
    var controller = EmptyViewController()

    func testEmptyView() {
        let nav = UINavigationController(rootViewController: controller)
        nav.view.layoutIfNeeded()
        nav.viewWillAppear(false)

        XCTAssertEqual(nav.navigationBar.barTintColor!.hexString, Brand.shared.navBackground.hexString)

        XCTAssertEqual(controller.view.subviews.count, 1)
        XCTAssert(controller.view.subviews.first is UIImageView)
    }
}
