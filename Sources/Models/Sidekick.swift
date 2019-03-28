//
//  Sidekick.swift
//  ARTitserPI
//
//  Created by Julius Abarra.
//

import Vapor
import MySQLProvider

final class Sidekick: Model {
    
    let storage = Storage()
    
    var id: Node?
    var type: Int
    var name: String
    var level: Int
    var points: Int
    var ownedBy: Int
    var dateCreated: Date
    var dateUpdated: Date
    
    static let typeKey = "type"
    static let nameKey = "name"
    static let levelKey = "level"
    static let pointsKey = "points"
    static let ownedByKey = "ownedBy"
    static let dateCreatedKey = "dateCreated"
    static let dateUpdatedKey = "dateUpdated"
    
    init(type: Int, name: String, level: Int, points: Int, ownedBy: Int, dateCreated: Date, dateUpdated: Date) {
        self.id = nil
        self.type = type
        self.name = name
        self.level = level
        self.points = points
        self.ownedBy = ownedBy
        self.dateCreated = dateCreated
        self.dateUpdated = dateUpdated
    }
    
    init(row: Row) throws {
        id = try row.get(Sidekick.idKey)
        type = try row.get(Sidekick.typeKey)
        name = try row.get(Sidekick.nameKey)
        level = try row.get(Sidekick.levelKey)
        points = try row.get(Sidekick.pointsKey)
        ownedBy = try row.get(Sidekick.ownedByKey)
        dateCreated = try row.get(Sidekick.dateCreatedKey)
        dateUpdated = try row.get(Sidekick.dateUpdatedKey)
    }
    
    init(node: Node) throws {
        type = try node.get(Sidekick.typeKey)
        name = try node.get(Sidekick.nameKey)
        level = try node.get(Sidekick.levelKey)
        points = try node.get(Sidekick.pointsKey)
        ownedBy = try node.get(Sidekick.ownedByKey)
        dateCreated = Date()
        dateUpdated = Date()
    }
    
    init(json: JSON) throws {
        type = try json.get(Sidekick.typeKey)
        name = try json.get(Sidekick.nameKey)
        level = try json.get(Sidekick.levelKey)
        points = try json.get(Sidekick.pointsKey)
        ownedBy = try json.get(Sidekick.ownedByKey)
        dateCreated = Date()
        dateUpdated = Date()
    }
    
    func makeRow() throws -> Row {
        var row = Row()
        try row.set(Sidekick.typeKey, type)
        try row.set(Sidekick.nameKey, name)
        try row.set(Sidekick.levelKey, level)
        try row.set(Sidekick.pointsKey, points)
        try row.set(Sidekick.ownedByKey, ownedBy)
        try row.set(Sidekick.dateCreatedKey, dateCreated)
        try row.set(Sidekick.dateUpdatedKey, dateUpdated)

        return row
    }
}

extension Sidekick: NodeRepresentable {
    func makeNode(in context: Context?) throws -> Node {
        var node = Node(context)
        try node.set(Sidekick.idKey, id?.int)
        try node.set(Sidekick.typeKey, type)
        try node.set(Sidekick.nameKey, name)
        try node.set(Sidekick.levelKey, level)
        try node.set(Sidekick.pointsKey, points)
        try node.set(Sidekick.ownedByKey, ownedBy)
        try node.set(Sidekick.dateCreatedKey, dateCreated)
        try node.set(Sidekick.dateUpdatedKey, dateUpdated)
        
        return node
    }
}

extension Sidekick: JSONRepresentable {
    func makeJSON() throws -> JSON {
        var json = JSON()
        try json.set(Sidekick.idKey, id?.int)
        try json.set(Sidekick.typeKey, type)
        try json.set(Sidekick.nameKey, name)
        try json.set(Sidekick.levelKey, level)
        try json.set(Sidekick.pointsKey, points)
        try json.set(Sidekick.ownedByKey, ownedBy)
        try json.set(Sidekick.dateCreatedKey, dateCreated)
        try json.set(Sidekick.dateUpdatedKey, dateUpdated)
        
        return json
    }
}

extension Sidekick: Preparation {
    static func prepare(_ database: Database) throws {
        try database.create(self) { builder in
            builder.id()
            builder.int(Sidekick.typeKey)
            builder.string(Sidekick.nameKey)
            builder.int(Sidekick.levelKey)
            builder.int(Sidekick.pointsKey)
            builder.int(Sidekick.ownedByKey)
            builder.date(Sidekick.dateCreatedKey)
            builder.date(Sidekick.dateUpdatedKey)
        }
    }
    
    static func revert(_ database: Database) throws {
        try database.delete(self)
    }
}
