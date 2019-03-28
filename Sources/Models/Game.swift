//
//  Game.swift
//  ARTitserPI
//
//  Created by Julius Abarra.
//

import Vapor
import MySQLProvider

final class Game: Model {
    
    let storage = Storage()
    
    var id: Node?
    var name: String
    var discussion: String
    var treasureId: Identifier
    var totalPoints: Int
    var isTimeBound: Int
    var minutes: Int
    var isNoExpiration: Int
    var start: String
    var end: String
    var isSecure: Int
    var securityCode: String
    var encryptedSecurityCode: String
    var startingClueId: Int
    var startingClueName: String
    var owner: Int
    var dateCreated: Date
    var dateUpdated: Date
    
    static let nameKey = "name"
    static let discussionKey = "discussion"
    static let treasureIdKey = "treasureId"
    static let totalPointsKey = "totalPoints"
    static let isTimeBoundKey = "isTimeBound"
    static let minutesKey = "minutes"
    static let isNoExpirationKey = "isNoExpiration"
    static let startKey = "start"
    static let endKey = "end"
    static let isSecureKey = "isSecure"
    static let securityCodeKey = "securityCode"
    static let encryptedSecurityCodeKey = "encryptedSecurityCode"
    static let startingClueIdKey = "startingClueId"
    static let startingClueNameKey = "startingClueName"
    static let ownerKey = "owner"
    static let dateCreatedKey = "dateCreated"
    static let dateUpdatedKey = "dateUpdated"
    
    init(name: String, discussion: String, treasureId: Identifier, totalPoints: Int, isTimeBound: Int, minutes: Int, isNoExpiration: Int, start: String, end: String, isSecure: Int, securityCode: String, encryptedSecurityCode: String, startingClueId: Int, startingClueName: String, owner: Int, dateCreated: Date, dateUpdated: Date) {
        self.id = nil
        self.name = name
        self.discussion = discussion
        self.treasureId = treasureId
        self.totalPoints = totalPoints
        self.isTimeBound = isTimeBound
        self.minutes = minutes
        self.isNoExpiration = isNoExpiration
        self.start = start
        self.end = end
        self.isSecure = isSecure
        self.securityCode = securityCode
        self.encryptedSecurityCode = encryptedSecurityCode
        self.startingClueId = startingClueId
        self.startingClueName = startingClueName
        self.owner = owner
        self.dateCreated = dateCreated
        self.dateUpdated = dateUpdated
    }
    
    init(row: Row) throws {
        id = try row.get(Game.idKey)
        name = try row.get(Game.nameKey)
        discussion = try row.get(Game.discussionKey)
        treasureId = try row.get(Game.treasureIdKey)
        totalPoints = try row.get(Game.totalPointsKey)
        isTimeBound = try row.get(Game.isTimeBoundKey)
        minutes = try row.get(Game.minutesKey)
        isNoExpiration = try row.get(Game.isNoExpirationKey)
        start = try row.get(Game.startKey)
        end = try row.get(Game.endKey)
        isSecure = try row.get(Game.isSecureKey)
        securityCode = try row.get(Game.securityCodeKey)
        encryptedSecurityCode = try row.get(Game.encryptedSecurityCodeKey)
        startingClueId = try row.get(Game.startingClueIdKey)
        startingClueName = try row.get(Game.startingClueNameKey)
        owner = try row.get(Game.ownerKey)
        dateCreated = try row.get(Game.dateCreatedKey)
        dateUpdated = try row.get(Game.dateUpdatedKey)
    }
    
    init(node: Node) throws {
        name = try node.get(Game.nameKey)
        discussion = try node.get(Game.discussionKey)
        treasureId = try node.get(Game.treasureIdKey)
        totalPoints = try node.get(Game.totalPointsKey)
        isTimeBound = try node.get(Game.isTimeBoundKey)
        minutes = try node.get(Game.minutesKey)
        isNoExpiration = try node.get(Game.isNoExpirationKey)
        start = try node.get(Game.startKey)
        end = try node.get(Game.endKey)
        isSecure = try node.get(Game.isSecureKey)
        securityCode = try node.get(Game.securityCodeKey)
        encryptedSecurityCode = try node.get(Game.encryptedSecurityCodeKey)
        startingClueId = try node.get(Game.startingClueIdKey)
        startingClueName = try node.get(Game.startingClueNameKey)
        owner = try node.get(Game.ownerKey)
        dateCreated = Date()
        dateUpdated = Date()
    }
    
    init(json: JSON) throws {
        name = try json.get(Game.nameKey)
        discussion = try json.get(Game.discussionKey)
        treasureId = try json.get(Game.treasureIdKey)
        totalPoints = try json.get(Game.totalPointsKey)
        isTimeBound = try json.get(Game.isTimeBoundKey)
        minutes = try json.get(Game.minutesKey)
        isNoExpiration = try json.get(Game.isNoExpirationKey)
        start = try json.get(Game.startKey)
        end = try json.get(Game.endKey)
        isSecure = try json.get(Game.isSecureKey)
        securityCode = try json.get(Game.securityCodeKey)
        encryptedSecurityCode = try json.get(Game.encryptedSecurityCodeKey)
        startingClueId = try json.get(Game.startingClueIdKey)
        startingClueName = try json.get(Game.startingClueNameKey)
        owner = try json.get(Game.ownerKey)
        dateCreated = Date()
        dateUpdated = Date()
    }
    
    func makeRow() throws -> Row {
        var row = Row()
        try row.set(Game.nameKey, name)
        try row.set(Game.discussionKey, discussion)
        try row.set(Game.treasureIdKey, treasureId)
        try row.set(Game.totalPointsKey, totalPoints)
        try row.set(Game.isTimeBoundKey, isTimeBound)
        try row.set(Game.minutesKey, minutes)
        try row.set(Game.isNoExpirationKey, isNoExpiration)
        try row.set(Game.startKey, start)
        try row.set(Game.endKey, end)
        try row.set(Game.isSecureKey, isSecure)
        try row.set(Game.securityCodeKey, securityCode)
        try row.set(Game.encryptedSecurityCodeKey, encryptedSecurityCode)
        try row.set(Game.startingClueIdKey, startingClueId)
        try row.set(Game.startingClueNameKey, startingClueName)
        try row.set(Game.ownerKey, owner)
        try row.set(Game.dateCreatedKey, dateCreated)
        try row.set(Game.dateUpdatedKey, dateUpdated)
        
        return row
    }
}

extension Game: NodeRepresentable {
    func makeNode(in context: Context?) throws -> Node {
        var node = Node(context)
        try node.set(Game.idKey, id?.int)
        try node.set(Game.nameKey, name)
        try node.set(Game.discussionKey, discussion)
        try node.set(Game.treasureIdKey, treasureId)
        try node.set(Game.totalPointsKey, totalPoints)
        try node.set(Game.isTimeBoundKey, isTimeBound)
        try node.set(Game.minutesKey, minutes)
        try node.set(Game.isNoExpirationKey, isNoExpiration)
        try node.set(Game.startKey, start)
        try node.set(Game.endKey, end)
        try node.set(Game.isSecureKey, isSecure)
        try node.set(Game.securityCodeKey, securityCode)
        try node.set(Game.encryptedSecurityCodeKey, encryptedSecurityCode)
        try node.set(Game.startingClueIdKey, startingClueId)
        try node.set(Game.startingClueNameKey, startingClueName)
        try node.set(Game.ownerKey, owner)
        try node.set(Game.dateCreatedKey, dateCreated)
        try node.set(Game.dateUpdatedKey, dateUpdated)
        
        return node
    }
}

extension Game: JSONRepresentable {
    func makeJSON() throws -> JSON {
        var json = JSON()
        try json.set(Game.idKey, id?.int)
        try json.set(Game.nameKey, name)
        try json.set(Game.discussionKey, discussion)
        try json.set(Game.treasureIdKey, treasureId)
        try json.set(Game.totalPointsKey, totalPoints)
        try json.set(Game.isTimeBoundKey, isTimeBound)
        try json.set(Game.minutesKey, minutes)
        try json.set(Game.isNoExpirationKey, isNoExpiration)
        try json.set(Game.startKey, start)
        try json.set(Game.endKey, end)
        try json.set(Game.isSecureKey, isSecure)
        try json.set(Game.securityCodeKey, securityCode)
        try json.set(Game.encryptedSecurityCodeKey, encryptedSecurityCode)
        try json.set(Game.startingClueIdKey, startingClueId)
        try json.set(Game.startingClueNameKey, startingClueName)
        try json.set(Game.ownerKey, owner)
        try json.set(Game.dateCreatedKey, dateCreated)
        try json.set(Game.dateUpdatedKey, dateUpdated)
        
        return json
    }
}

extension Game: Preparation {
    static func prepare(_ database: Database) throws {
        try database.create(self) { builder in
            builder.id()
            builder.string(Game.nameKey)
            builder.string(Game.discussionKey)
            builder.int(Game.totalPointsKey)
            builder.int(Game.isTimeBoundKey)
            builder.int(Game.minutesKey)
            builder.int(Game.isNoExpirationKey)
            builder.string(Game.startKey)
            builder.string(Game.endKey)
            builder.int(Game.isSecureKey)
            builder.string(Game.securityCodeKey)
            builder.string(Game.encryptedSecurityCodeKey)
            builder.int(Game.startingClueIdKey)
            builder.string(Game.startingClueNameKey)
            builder.int(Game.ownerKey)
            builder.date(Game.dateCreatedKey)
            builder.date(Game.dateUpdatedKey)
            
            // Foreign key
            builder.parent(Treasure.self, optional: false, unique: false, foreignIdKey: "treasureId")
        }
    }
    
    static func revert(_ database: Database) throws {
        try database.delete(self)
    }
}

///// One-to-Many Relationship
///// Retrieves treasure assigned to the game
extension Game {
    var treasure: Parent<Game, Treasure> { return parent(id: treasureId) }
}

///// Many-to-Many Relationship
///// Retrieves clues assigned to the game
extension Game {
    var clues: Siblings<Game, Clue, Pivot<Game, Clue>> { return siblings() }
}
