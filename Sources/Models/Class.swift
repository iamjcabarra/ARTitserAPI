//
//  Class.swift
//  ARFollowAPIPackageDescription
//
//  Created by Julius Abarra.
//

import Vapor
import MySQLProvider

final class Class: Model {
   
    let storage = Storage()
    
    var id: Node?
    var code: String
    var aClassDescription: String
    var schedule: String
    var venue: String
    var courseId: Identifier
    var creatorId: Identifier
    var owner: Int
    var dateCreated: Date
    var dateUpdated: Date
    
    static let codeKey = "code"
    static let aClassDescriptionKey = "aClassDescription"
    static let scheduleKey = "schedule"
    static let venueKey = "venue"
    static let courseIdKey = "courseId"
    static let creatorIdKey = "creatorId"
    static let ownerKey = "owner"
    static let dateCreatedKey = "dateCreated"
    static let dateUpdatedKey = "dateUpdated"
    
    init(code: String, aClassDescription: String, schedule: String, venue: String, courseId: Identifier, creatorId: Identifier, owner: Int, dateCreated: Date, dateUpdated: Date) {
        self.id = nil
        self.code = code
        self.aClassDescription = aClassDescription
        self.schedule = schedule
        self.venue = venue
        self.courseId = courseId
        self.creatorId = creatorId
        self.owner = owner
        self.dateCreated = dateCreated
        self.dateUpdated = dateUpdated
    }
    
    init(row: Row) throws {
        id = try row.get(Class.idKey)
        code = try row.get(Class.codeKey)
        aClassDescription = try row.get(Class.aClassDescriptionKey)
        schedule = try row.get(Class.scheduleKey)
        venue = try row.get(Class.venueKey)
        courseId = try row.get(Class.courseIdKey)
        creatorId = try row.get(Class.creatorIdKey)
        owner = try row.get(Class.ownerKey)
        dateCreated = try row.get(Class.dateCreatedKey)
        dateUpdated = try row.get(Class.dateUpdatedKey)
    }
    
    init(node: Node) throws {
        code = try node.get(Class.codeKey)
        aClassDescription = try node.get(Class.aClassDescriptionKey)
        schedule = try node.get(Class.scheduleKey)
        venue = try node.get(Class.venueKey)
        courseId = try node.get(Class.courseIdKey)
        creatorId = try node.get(Class.creatorIdKey)
        owner = try node.get(Class.ownerKey)
        dateCreated = Date()
        dateUpdated = Date()
    }
    
    init(json: JSON) throws {
        code = try json.get(Class.codeKey)
        aClassDescription = try json.get(Class.aClassDescriptionKey)
        schedule = try json.get(Class.scheduleKey)
        venue = try json.get(Class.venueKey)
        courseId = try json.get(Class.courseIdKey)
        creatorId = try json.get(Class.creatorIdKey)
        owner = try json.get(Class.ownerKey)
        dateCreated = Date()
        dateUpdated = Date()
    }
    
    func makeRow() throws -> Row {
        var row = Row()
        try row.set(Class.codeKey, code)
        try row.set(Class.aClassDescriptionKey, aClassDescription)
        try row.set(Class.scheduleKey, schedule)
        try row.set(Class.venueKey, venue)
        try row.set(Class.courseIdKey, courseId)
        try row.set(Class.creatorIdKey, creatorId)
        try row.set(Class.ownerKey, owner)
        try row.set(Class.dateCreatedKey, dateCreated)
        try row.set(Class.dateUpdatedKey, dateUpdated)
        
        return row
    }
}

extension Class: NodeRepresentable {
    func makeNode(in context: Context?) throws -> Node {
        var node = Node(context)
        try node.set(Class.idKey, id?.int)
        try node.set(Class.codeKey, code)
        try node.set(Class.aClassDescriptionKey, aClassDescription)
        try node.set(Class.scheduleKey, schedule)
        try node.set(Class.venueKey, venue)
        try node.set(Class.courseIdKey, courseId)
        try node.set(Class.creatorIdKey, creatorId)
        try node.set(Class.ownerKey, owner)
        try node.set(Class.dateCreatedKey, dateCreated)
        try node.set(Class.dateUpdatedKey, dateUpdated)
        
        return node
    }
}

extension Class: JSONRepresentable {
    func makeJSON() throws -> JSON {
        var json = JSON()
        try json.set(Class.idKey, id?.int)
        try json.set(Class.codeKey, code)
        try json.set(Class.aClassDescriptionKey, aClassDescription)
        try json.set(Class.scheduleKey, schedule)
        try json.set(Class.venueKey, venue)
        try json.set(Class.courseIdKey, courseId)
        try json.set(Class.creatorIdKey, creatorId)
        try json.set(Class.ownerKey, owner)
        try json.set(Class.dateCreatedKey, dateCreated)
        try json.set(Class.dateUpdatedKey, dateUpdated)
        
        return json
    }
}

extension Class: Preparation {
    static func prepare(_ database: Database) throws {
        try database.create(self) { builder in
            builder.id()
            builder.string(Class.codeKey)
            builder.string(Class.aClassDescriptionKey)
            builder.string(Class.scheduleKey)
            builder.string(Class.venueKey)
            builder.int(Class.ownerKey)
            builder.date(Class.dateCreatedKey)
            builder.date(Class.dateUpdatedKey)
            
            // Foreign keys
            builder.parent(User.self, optional: false, unique: false, foreignIdKey: "creatorId")
            builder.parent(Course.self, optional: false, unique: false, foreignIdKey: "courseId")
        }
    }
    
    static func revert(_ database: Database) throws {
        try database.delete(self)
    }
}

///// One-to-Many Relationship
///// Retrieves creator assigned to the class
extension Class {
    var creator: Parent<Class, User> { return parent(id: creatorId) }
}

///// One-to-Many Relationship
///// Retrieves course assigned to the class
extension Class {
    var course: Parent<Class, Course> { return parent(id: courseId) }
}

///// Many-to-Many Relationship
///// Retrieves players assigned to the class
extension Class {
    var players: Siblings<Class, User, Pivot<Class, User>> { return siblings() }
}
