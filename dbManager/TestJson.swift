//
//  TestJson.swift
//  dbManager
//
//  Created by guest on 7/24/16.
//  Copyright © 2016 guest. All rights reserved.
//

import Foundation

struct TestJson: Glossy {
    
    // 1
    let username: [String]?
    let id:Int?
    
    init?(json: JSON) {
        self.id = "ID" <~~ json
        self.username = "userName" <~~ json
    }
    // 2
    func toJSON() -> JSON? {
        return jsonify([
            "userName" ~~> self.username,"ID" ~~> self.id
            ])
    }
    
}