//
//  HSCompletionOperation.swift
//  HolisticSolutionSDK
//
//  Created by Stas Kochkin on 30.06.2020.
//  Copyright © 2020 com.appodeal. All rights reserved.
//

import Foundation


internal protocol HSErrorProvider {
    var error: HSError? { get }
}

internal class HSCompletionOperation: HSAsynchronousOperation {
    typealias Completion = (NSError?) -> Void
    
    private let completion: Completion?
    
    init(_ completion: Completion?) {
        self.completion = completion
        super.init()
    }
    
    override func main() {
        super.main()
        let errors = dependencies
            .compactMap { $0 as? HSErrorProvider }
            .compactMap { $0.error }
        DispatchQueue.main.async { [weak self] in
            self?.completion?(errors.first.map { $0.nserror })
            self?.finish()
        }
    }
}
