//
//  Clue.swift
//  ARTitserPI
//
//  Created by Julius Abarra.
//

import Vapor
import MySQLProvider

final class Clue: Model {

    let storage = Storage()
    
    var id: Node?
    var type: Int
    var riddle: String
//    var longitude: Double
//    var latitude: Double
//    var locationName: String
    var points: Int
    var pointsOnAttempts: String
//    var clue: String
    var owner: Int
    var dateCreated: Date
    var dateUpdated: Date
    
    static let typeKey = "type"
    static let riddleKey = "riddle"
//    static let longitudeKey = "longitude"
//    static let latitudeKey = "latitude"
//    static let locationNameKey = "locationName"
    static let pointsKey = "points"
    static let pointsOnAttemptsKey = "pointsOnAttempts"
//    static let clueKey = "clue"
    static let ownerKey = "owner"
    static let dateCreatedKey = "dateCreated"
    static let dateUpdatedKey = "dateUpdated"
    
//    init(type: Int, riddle: String, longitude: Double, latitude: Double, locationName: String, points: Int, pointsOnAttempts: String, clue: String, owner: Int, dateCreated: Date, dateUpdated: Date) {
     init(type: Int, riddle: String, points: Int, pointsOnAttempts: String, owner: Int, dateCreated: Date, dateUpdated: Date) {
        self.type = type
        self.id = nil
        self.riddle = riddle
//        self.longitude = longitude
//        self.latitude = latitude
//        self.locationName = locationName
        self.points = points
        self.pointsOnAttempts = pointsOnAttempts
//        self.clue = clue
        self.owner = owner
        self.dateCreated = dateCreated
        self.dateUpdated = dateUpdated
    }
    
    init(row: Row) throws {
        id = try row.get(Clue.idKey)
        type = try row.get(Clue.typeKey)
        riddle = try row.get(Clue.riddleKey)
//        longitude = try row.get(Clue.longitudeKey)
//        latitude = try row.get(Clue.latitudeKey)
//        locationName = try row.get(Clue.locationNameKey)
        points = try row.get(Clue.pointsKey)
        pointsOnAttempts = try row.get(Clue.pointsOnAttemptsKey)
//        clue = try row.get(Clue.clueKey)
        owner = try row.get(Clue.ownerKey)
        dateCreated = try row.get(Clue.dateCreatedKey)
        dateUpdated = try row.get(Clue.dateUpdatedKey)
    }
    
    init(node: Node) throws {
        type = try node.get(Clue.typeKey)
        riddle = try node.get(Clue.riddleKey)
//        longitude = try node.get(Clue.longitudeKey)
//        latitude = try node.get(Clue.latitudeKey)
//        locationName = try node.get(Clue.locationNameKey)
        points = try node.get(Clue.pointsKey)
        pointsOnAttempts = try node.get(Clue.pointsOnAttemptsKey)
//        clue = try node.get(Clue.clueKey)
        owner = try node.get(Clue.ownerKey)
        dateCreated = Date()
        dateUpdated = Date()
    }
    
    init(json: JSON) throws {
        type = try json.get(Clue.typeKey)
        riddle = try json.get(Clue.riddleKey)
//        longitude = try json.get(Clue.longitudeKey)
//        latitude = try json.get(Clue.latitudeKey)
//        locationName = try json.get(Clue.locationNameKey)
        points = try json.get(Clue.pointsKey)
        pointsOnAttempts = try json.get(Clue.pointsOnAttemptsKey)
//        clue = try json.get(Clue.clueKey)
        owner = try json.get(Clue.ownerKey)
        dateCreated = Date()
        dateUpdated = Date()
    }
    
    func makeRow() throws -> Row {
        var row = Row()
        try row.set(Clue.typeKey, type)
        try row.set(Clue.riddleKey, riddle)
//        try row.set(Clue.longitudeKey, longitude)
//        try row.set(Clue.latitudeKey, latitude)
//        try row.set(Clue.locationNameKey, locationName)
        try row.set(Clue.pointsKey, points)
        try row.set(Clue.pointsOnAttemptsKey, pointsOnAttempts)
//        try row.set(Clue.clueKey, clue)
        try row.set(Clue.ownerKey, owner)
        try row.set(Clue.dateCreatedKey, dateCreated)
        try row.set(Clue.dateUpdatedKey, dateUpdated)
        
        return row
    }
    
}

extension Clue: NodeRepresentable {
    func makeNode(in context: Context?) throws -> Node {
        var node = Node(context)
        try node.set(Clue.idKey, id?.int)
        try node.set(Clue.typeKey, type)
        try node.set(Clue.riddleKey, riddle)
//        try node.set(Clue.longitudeKey, longitude)
//        try node.set(Clue.latitudeKey, latitude)
//        try node.set(Clue.locationNameKey, locationName)
        try node.set(Clue.pointsKey, points)
        try node.set(Clue.pointsOnAttemptsKey, pointsOnAttempts)
//        try node.set(Clue.clueKey, clue)
        try node.set(Clue.ownerKey, owner)
        try node.set(Clue.dateCreatedKey, dateCreated)
        try node.set(Clue.dateUpdatedKey, dateUpdated)
        
        return node
    }
}

extension Clue: JSONRepresentable {
    func makeJSON() throws -> JSON {
        var json = JSON()
        try json.set(Clue.idKey, id?.int)
        try json.set(Clue.typeKey, type)
        try json.set(Clue.riddleKey, riddle)
//        try json.set(Clue.longitudeKey, longitude)
//        try json.set(Clue.latitudeKey, latitude)
//        try json.set(Clue.locationNameKey, locationName)
        try json.set(Clue.pointsKey, points)
        try json.set(Clue.pointsOnAttemptsKey, pointsOnAttempts)
//        try json.set(Clue.clueKey, clue)
        try json.set(Clue.ownerKey, owner)
        try json.set(Clue.dateCreatedKey, dateCreated)
        try json.set(Clue.dateUpdatedKey, dateUpdated)
        
        return json
    }
}

extension Clue: Preparation {
    static func prepare(_ database: Database) throws {
        try database.create(self) { builder in
            builder.id()
            builder.int(Clue.typeKey)
            builder.string(Clue.riddleKey)
//            builder.double(Clue.longitudeKey)
//            builder.double(Clue.latitudeKey)
//            builder.string(Clue.locationNameKey)
            builder.int(Clue.pointsKey)
            builder.string(Clue.pointsOnAttemptsKey)
//            builder.string(Clue.clueKey)
            builder.int(Clue.ownerKey)
            builder.date(Clue.dateCreatedKey)
            builder.date(Clue.dateUpdatedKey)
        }
    }
    
    static func revert(_ database: Database) throws {
        try database.delete(self)
    }
}

///// One-to-Many Relationship
///// Retrieves all choices assigned to the clue
extension Clue {
    var choices: Children<Clue, Choice> { return children() }
}

