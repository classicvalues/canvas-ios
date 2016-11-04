
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
    
    

import CoreData
import MediaKit
import FileKit

public final class Submission: SubmissionEvent {
    @NSManaged internal (set) public var id: String
    @NSManaged internal (set) public var assignmentID: String
    @NSManaged internal (set) public var userID: String
    @NSManaged internal (set) public var courseID: String?
    @NSManaged internal (set) public var attempt: Int32
    
    @NSManaged internal (set) public var late: Bool
    @NSManaged internal (set) public var excused: Bool
    
    @NSManaged internal (set) public var dateGraded: NSDate?
    @NSManaged internal (set) public var score: Double
    @NSManaged internal (set) public var grade: String?
    
    @NSManaged internal (set) public var rawSubmissionType: String

    // submission values plz to use `Kind`
    @NSManaged internal (set) public var submittedText: String?
    @NSManaged internal (set) public var submittedURL: NSURL?
    @NSManaged internal (set) public var submittedMediaID: String?
    @NSManaged internal (set) public var submittedMedia: MediaComment?
    @NSManaged var submittedFiles: Set<SubmissionFile>
    @NSManaged internal (set) public var assessments: Set<RubricAssessment>
}

// MARK: Type of submission

extension Submission {
    enum Kind {
        case None
        
        case DiscussionTopic
        case Quiz
        case ExternalTool
        
        case OnPaper
        case Text(String)
        case URL(NSURL)
        case Files([File])
        case Media(MediaComment)
    }
    
    var kind: Kind {
        switch rawSubmissionType {
        case "discussion_topic":
            return .DiscussionTopic
        case "online_quiz":
            return .Quiz
        case "on_paper":
            return .OnPaper
        case "none":
            return .None
        case "external_tool":
            return .ExternalTool
        case "online_text_entry":
            return submittedText.map(Kind.Text) ?? .None
        case "online_url":
            return submittedURL.map(Kind.URL) ?? .None
        case "online_upload":
            return .Files(Array(submittedFiles.map { $0.file }))
        case "media_recording":
            return submittedMedia.map(Kind.Media) ?? .None
        default:
            return .None
        }
    }
}

// MARK: SoPersistent

import SoPersistent
import Marshal
import SoLazy

extension Submission: SynchronizedModel {
    public static func uniquePredicateForObject(json: JSONObject) throws -> NSPredicate {
        let id: String = try json.stringID("id") ?? ""
        let attempt: Int = (try json <| "attempt") ?? 0
        
        return NSPredicate(format: "%K == %@ && %K == %@", "id", id, "attempt", NSNumber(integer: attempt))
    }
    
    public func updateValues(json: JSONObject, inContext context: NSManagedObjectContext) throws {
        //We fail and smother the alert here because of the RubricViewController which has to fetch a submission
        // and assignment and concats the results. The API returns a submission object with nil values even if no submission
        // exists. --nlambson June 6, 2016
        do { id                     = try json.stringID("id") } catch { return }
        assignmentID            = try json.stringID("assignment_id")
        userID                  = try json.stringID("user_id")
        courseID                = try json.stringID("course_id")
        attempt                 = try json <| "attempt" ?? 0
        late                    = try json <| "late" ?? false
        excused                 = try json <| "excused" ?? false
        
        dateGraded              = try json <| "graded_at"
        score                   = try json <| "score" ?? 0.0
        grade                   = try json <| "grade"

        if let rubricAssessmentsJSON: JSONObject = try json <| "rubric_assessment" {
            for (_, assessment) in rubricAssessmentsJSON.enumerate() {
                if var assessmentJSON: JSONObject = assessment.1 as? JSONObject {
                    let assessmentID = assessment.0
                    assessmentJSON["id"] = assessmentID
                    assessmentJSON["submissionID"] = self.id
                    
                    if let rubricAssessment: RubricAssessment = try context.findOne(withPredicate: try RubricAssessment.uniquePredicateForObject(assessmentJSON)) {
                        try rubricAssessment.updateValues(assessmentID, submission: self, json: assessmentJSON, inContext: context)
                    } else {
                        let rubricAssessment = RubricAssessment(inContext: context)
                        try rubricAssessment.updateValues(assessmentID, submission: self, json: assessmentJSON, inContext: context)
                        
                        assessments.insert(rubricAssessment)
                    }
                }
            }
        }
        
        let foundAssignment: Assignment? = try context.findOne(withValue: assignmentID, forKey: "id")
        assignment = foundAssignment
        assignment?.rubric?.currentSubmission = self
    }
    
    // API parameters
    public static var parameters: [String: AnyObject] { return ["include": ["rubric_assessment", "visibility", "submission_comments", "submission_history"]] }
}
