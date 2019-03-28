//
//  Course.swift
//  App
//
//  Created by Julius Abarra.
//

import Vapor
import MySQLProvider

final class Course: Model {
 
    let storage = Storage()
    
    var id: Node?
    var code: String
    var title: String
    var courseDescription: String
    var unit: Int
    var owner: Int
    var dateCreated: Date
    var dateUpdated: Date
    
    static let codeKey = "code"
    static let titleKey = "title"
    static let courseDescriptionKey = "courseDescription"
    static let unitKey = "unit"
    static let ownerKey = "owner"
    static let dateCreatedKey = "dateCreated"
    static let dateUpdatedKey = "dateUpdated"
    
    init(code: String, title: String, courseDescription: String, unit: Int,  owner: Int, dateCreated: Date, dateUpdated: Date) {
        self.id = nil
        self.code = code
        self.title = title
        self.courseDescription = courseDescription
        self.unit = unit
        self.owner = owner
        self.dateCreated = dateCreated
        self.dateUpdated = dateUpdated
    }
    
    init(row: Row) throws {
        id = try row.get(Course.idKey)
        code = try row.get(Course.codeKey)
        title = try row.get(Course.titleKey)
        courseDescription = try row.get(Course.courseDescriptionKey)
        unit = try row.get(Course.unitKey)
        owner = try row.get(Course.ownerKey)
        dateCreated = try row.get(Course.dateCreatedKey)
        dateUpdated = try row.get(Course.dateUpdatedKey)
    }
    
    init(node: Node) throws {
        code = try node.get(Course.codeKey)
        title = try node.get(Course.titleKey)
        courseDescription = try node.get(Course.courseDescriptionKey)
        unit = try node.get(Course.unitKey)
        owner = try node.get(Course.ownerKey)
        dateCreated = Date()
        dateUpdated = Date()
    }
    
    init(json: JSON) throws {
        code = try json.get(Course.codeKey)
        title = try json.get(Course.titleKey)
        courseDescription = try json.get(Course.courseDescriptionKey)
        unit = try json.get(Course.unitKey)
        owner = try json.get(Course.ownerKey)
        dateCreated = Date()
        dateUpdated = Date()
    }
    
    func makeRow() throws -> Row {
        var row = Row()
        try row.set(Course.codeKey, code)
        try row.set(Course.titleKey, title)
        try row.set(Course.courseDescriptionKey, courseDescription)
        try row.set(Course.unitKey, unit)
        try row.set(Course.ownerKey, owner)
        try row.set(Course.dateCreatedKey, dateCreated)
        try row.set(Course.dateUpdatedKey, dateUpdated)
        
        return row
    }
}

extension Course: NodeRepresentable {
    func makeNode(in context: Context?) throws -> Node {
        var node = Node(context)
        try node.set(Course.idKey, id?.int)
        try node.set(Course.codeKey, code)
        try node.set(Course.titleKey, title)
        try node.set(Course.courseDescriptionKey, courseDescription)
        try node.set(Course.unitKey, unit)
        try node.set(Course.ownerKey, owner)
        try node.set(Course.dateCreatedKey, dateCreated)
        try node.set(Course.dateUpdatedKey, dateUpdated)
        
        return node
    }
}

extension Course: JSONRepresentable {
    func makeJSON() throws -> JSON {
        var json = JSON()
        try json.set(Course.idKey, id?.int)
        try json.set(Course.codeKey, code)
        try json.set(Course.titleKey, title)
        try json.set(Course.courseDescriptionKey, courseDescription)
        try json.set(Course.unitKey, unit)
        try json.set(Course.ownerKey, owner)
        try json.set(Course.dateCreatedKey, dateCreated)
        try json.set(Course.dateUpdatedKey, dateUpdated)
        
        return json
    }
}

extension Course: Preparation {
    static func prepare(_ database: Database) throws {
        try database.create(self) { builder in
            builder.id()
            builder.string(Course.codeKey)
            builder.string(Course.titleKey)
            builder.string(Course.courseDescriptionKey)
            builder.int(Course.unitKey)
            builder.int(Course.ownerKey)
            builder.date(Course.dateCreatedKey)
            builder.date(Course.dateUpdatedKey)
        }
    }
    
    static func revert(_ database: Database) throws {
        try database.delete(self)
    }
}

///// One-to-Many Relationship
///// Retrieves all classes assigned to the course
extension Course {
    var classes: Children<Course, Class> { return children() }
}

