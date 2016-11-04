
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
import CoreData
import SoPersistent
import SoLazy

// ---------------------------------------------
// MARK: - Calendar Events collection for current user
// ---------------------------------------------
extension User {
    public static func collectionOfObservedUsers(session: Session) throws -> FetchedCollection<User> {
        let frc = User.fetchedResults(nil, sortDescriptors: ["sortableName".ascending], sectionNameKeypath: nil, inContext: try session.observeesManagedObjectContext())

        return try FetchedCollection<User>(frc: frc)
    }

    public static func observeesSyncProducer(session: Session) throws -> User.ModelPageSignalProducer {
        let remote = try User.getObserveeUsers(session)
        return User.syncSignalProducer(inContext: try session.observeesManagedObjectContext(), fetchRemote: remote)
    }

    public static func observeesRefresher(session: Session) throws -> Refresher {
        let sync = try User.observeesSyncProducer(session)
        let key = cacheKey(try session.observeesManagedObjectContext())
        return SignalProducerRefresher(refreshSignalProducer: sync, scope: session.refreshScope, cacheKey: key)
    }

    public typealias TableViewController = FetchedTableViewController<User>
}
