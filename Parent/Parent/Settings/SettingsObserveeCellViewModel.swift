
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
    
    

import Foundation

import SoPersistent
import EnrollmentKit
import Airwolf

struct SettingsObserveeCellViewModel: TableViewCellViewModel {
    let name: String
    let studentID: String
    let avatarURL: NSURL?
    let highlightColor: UIColor

    init(student: Student, highlightColor: UIColor) {
        name = student.sortableName
        avatarURL = student.avatarURL
        studentID = student.id
        self.highlightColor = highlightColor
    }

    static func tableViewDidLoad(tableView: UITableView) {
        tableView.estimatedRowHeight = 64
        tableView.registerNib(UINib(nibName: "SettingsObserveeCell", bundle: NSBundle(forClass: SettingsObserveeCell.self)), forCellReuseIdentifier: "SettingsObserveeCell")
    }

    func cellForTableView(tableView: UITableView, indexPath: NSIndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCellWithIdentifier("SettingsObserveeCell", forIndexPath: indexPath) as? SettingsObserveeCell else {
            fatalError("Incorrect cell type found. Expected: SettingsObserveeCell")
        }

        cell.highlightColor = highlightColor
        cell.nameLabel?.text = name

        if let avatarURL = avatarURL {
            cell.avatarImageView?.kf_setImageWithURL(avatarURL, placeholderImage: DefaultAvatarCoordinator.defaultAvatarForStudentID(studentID))
        }

        return cell
    }

}