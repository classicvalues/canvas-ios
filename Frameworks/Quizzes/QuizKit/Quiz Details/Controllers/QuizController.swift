
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

import TooLegit
import Result

class QuizController {
    let service: QuizService
    
    private (set) var quiz: Quiz?
    
    var quizUpdated: QuizResult->() = {_ in } {
        didSet {
            if let quiz = self.quiz {
                quizUpdated(Result(value: Page(content: quiz)))
            }
        }
    }
    
    init(service: QuizService, quiz: Quiz? = nil) {
        self.service = service
        self.quiz = quiz
    }
    
    func refreshQuiz() {
        service.getQuiz { quizResult in
            if let quiz = quizResult.value?.content {
                self.quiz = quiz
            }
            self.quizUpdated(quizResult)
        }
    }
    
    func urlForViewingResultsForAttempt(attempt: Int) -> NSURL? {
        var url: NSURL? = nil
        switch quiz!.hideResults {
        case .Never:
            url = resultURLForAttempt(attempt)
        case .Always:
            url = nil
        case .UntilAfterLastAttempt:
            switch quiz!.attemptLimit {
            case .Count(let attemptLimit):
                if attempt >= attemptLimit {
                    url = resultURLForAttempt(attempt)
                } else {
                    url = nil
                }
            case .Unlimited:
                break
            }
        }
        return url
    }
    
    private func resultURLForAttempt(attempt: Int) -> NSURL? {
        // URLByAppendingPathComponent encoded the version query param wrong so...
        let url = NSURL(string: service.baseURL.absoluteString! + "/" + service.context.htmlPath + "/quizzes/\(service.quizID)/history?attempt=\(attempt)")
        return url
    }
}


