//
//  Activity.swift
//  App
//
//  Created by Julius Abarra.
//

import Vapor
import MySQLProvider

final class Activity: Model {
    
    let storage = Storage()
    
    var id: Node?
    var userId: Int
    var module: String
    var activity: String
    var date: Date
    
    static let userIdKey = "userId"
    static let userTypeKey = "userType"
    static let userKey = "user"
    static let moduleKey = "module"
    static let activityKey = "activity"
    static let dateKey = "date"
    
    init(userId: Int, module: String, activity: String, date: Date) {
        self.id = nil
        self.userId = userId
        self.module = module
        self.activity = activity
        self.date = date
    }
    
    init(row: Row) throws {
        id = try row.get(Activity.idKey)
        userId = try row.get(Activity.userIdKey)
        module = try row.get(Activity.moduleKey)
        activity = try row.get(Activity.activityKey)
        date = try row.get(Activity.dateKey)
    }
    
    init(node: Node) throws {
        userId = try node.get(Activity.userIdKey)
        module = try node.get(Activity.moduleKey)
        activity = try node.get(Activity.activityKey)
        date = Date()
    }
    
    init(json: JSON) throws {
        userId = try json.get(Activity.userIdKey)
        module = try json.get(Activity.moduleKey)
        activity = try json.get(Activity.activityKey)
        date = Date()
    }
    
    func makeRow() throws -> Row {
        var row = Row()
        try row.set(Activity.userIdKey, userId)
        try row.set(Activity.moduleKey, module)
        try row.set(Activity.activityKey, activity)
        try row.set(Activity.dateKey, date)
        
        return row
    }
}

extension Activity: NodeRepresentable {
    func makeNode(in context: Context?) throws -> Node {
        var node = Node(context)
        try node.set(Activity.idKey, id?.int)
        try node.set(Activity.userIdKey, userId)
        try node.set(Activity.moduleKey, module)
        try node.set(Activity.activityKey, activity)
        try node.set(Activity.dateKey, date)
        
        return node
    }
}

extension Activity: JSONRepresentable {
    func makeJSON() throws -> JSON {
        var json = JSON()
        try json.set(Activity.idKey, id?.int)
        try json.set(Activity.userIdKey, userId)
        try json.set(Activity.moduleKey, module)
        try json.set(Activity.activityKey, activity)
        try json.set(Activity.dateKey, date)
        
        return json
    }
}

extension Activity: Preparation {
    static func prepare(_ database: Database) throws {
        try database.create(self) { builder in
            builder.id()
            builder.int(Activity.userIdKey)
            builder.string(Activity.moduleKey)
            builder.string(Activity.activityKey)
            builder.date(Activity.dateKey)
        }
    }
    
    static func revert(_ database: Database) throws {
        try database.delete(self)
    }
}
