//
//  GameResultTreasure.swift
//  App
//
//  Created by Julius Abarra.
//

import Vapor
import MySQLProvider

final class GameResultTreasure: Model {
    
    let storage = Storage()
    
    var id: Node?
    var classId: Int
    var gameId: Int
    var treasureId: Int
    var treasureName: String
    var playerId: Int
    var playerName: String
    var numberOfAttempts: Int
    var points: Int
    var dateCreated: Date
    var dateUpdated: Date
    
    static let classIdKey = "classId"
    static let gameIdKey = "gameId"
    static let treasureIdKey = "treasureId"
    static let treasureNameKey = "treasureName"
    static let playerIdKey = "playerId"
    static let playerNameKey = "playerName"
    static let numberOfAttemptsKey = "numberOfAttempts"
    static let pointsKey = "points"
    static let dateCreatedKey = "dateCreated"
    static let dateUpdatedKey = "dateUpdated"
    
    init(classId: Int, gameId: Int, treasureId: Int, treasureName: String, playerId: Int, playerName: String, numberOfAttempts: Int, points: Int, dateCreated: Date, dateUpdated: Date) {
        self.id = nil
        self.classId = classId
        self.gameId = gameId
        self.treasureId = treasureId
        self.treasureName = treasureName
        self.playerId = playerId
        self.playerName = playerName
        self.numberOfAttempts = numberOfAttempts
        self.points = points
        self.dateCreated = dateCreated
        self.dateUpdated = dateUpdated
    }
    
    init(row: Row) throws {
        id = try row.get(GameResultTreasure.idKey)
        classId = try row.get(GameResultTreasure.classIdKey)
        gameId = try row.get(GameResultTreasure.gameIdKey)
        treasureId = try row.get(GameResultTreasure.treasureIdKey)
        treasureName = try row.get(GameResultTreasure.treasureNameKey)
        playerId = try row.get(GameResultTreasure.playerIdKey)
        playerName = try row.get(GameResultTreasure.playerNameKey)
        numberOfAttempts = try row.get(GameResultTreasure.numberOfAttemptsKey)
        points = try row.get(GameResultTreasure.pointsKey)
        dateCreated = try row.get(GameResultTreasure.dateCreatedKey)
        dateUpdated = try row.get(GameResultTreasure.dateUpdatedKey)
    }
    
    init(node: Node) throws {
        classId = try node.get(GameResultTreasure.classIdKey)
        gameId = try node.get(GameResultTreasure.gameIdKey)
        treasureId = try node.get(GameResultTreasure.treasureIdKey)
        treasureName = try node.get(GameResultTreasure.treasureNameKey)
        playerId = try node.get(GameResultTreasure.playerIdKey)
        playerName = try node.get(GameResultTreasure.playerNameKey)
        numberOfAttempts = try node.get(GameResultTreasure.numberOfAttemptsKey)
        points = try node.get(GameResultTreasure.pointsKey)
        dateCreated = Date()
        dateUpdated = Date()
    }
    
    init(json: JSON) throws {
        classId = try json.get(GameResultTreasure.classIdKey)
        gameId = try json.get(GameResultTreasure.gameIdKey)
        treasureId = try json.get(GameResultTreasure.treasureIdKey)
        treasureName = try json.get(GameResultTreasure.treasureNameKey)
        playerId = try json.get(GameResultTreasure.playerIdKey)
        playerName = try json.get(GameResultTreasure.playerNameKey)
        numberOfAttempts = try json.get(GameResultTreasure.numberOfAttemptsKey)
        points = try json.get(GameResultTreasure.pointsKey)
        dateCreated = Date()
        dateUpdated = Date()
    }
    
    func makeRow() throws -> Row {
        var row = Row()
        try row.set(GameResultTreasure.classIdKey, classId)
        try row.set(GameResultTreasure.gameIdKey, gameId)
        try row.set(GameResultTreasure.treasureIdKey, treasureId)
        try row.set(GameResultTreasure.treasureNameKey, treasureName)
        try row.set(GameResultTreasure.playerIdKey, playerId)
        try row.set(GameResultTreasure.playerNameKey, playerName)
        try row.set(GameResultTreasure.numberOfAttemptsKey, numberOfAttempts)
        try row.set(GameResultTreasure.pointsKey, points)
        try row.set(GameResultTreasure.dateCreatedKey, dateCreated)
        try row.set(GameResultTreasure.dateUpdatedKey, dateUpdated)
        
        return row
    }
}

extension GameResultTreasure: NodeRepresentable {
    func makeNode(in context: Context?) throws -> Node {
        var node = Node(context)
        try node.set(GameResultTreasure.idKey, id?.int)
        try node.set(GameResultTreasure.classIdKey, classId)
        try node.set(GameResultTreasure.gameIdKey, gameId)
        try node.set(GameResultTreasure.treasureIdKey, treasureId)
        try node.set(GameResultTreasure.treasureNameKey, treasureName)
        try node.set(GameResultTreasure.playerIdKey, playerId)
        try node.set(GameResultTreasure.playerNameKey, playerName)
        try node.set(GameResultTreasure.numberOfAttemptsKey, numberOfAttempts)
        try node.set(GameResultTreasure.pointsKey, points)
        try node.set(GameResultTreasure.dateCreatedKey, dateCreated)
        try node.set(GameResultTreasure.dateUpdatedKey, dateUpdated)
        
        return node
    }
}

extension GameResultTreasure: JSONRepresentable {
    func makeJSON() throws -> JSON {
        var json = JSON()
        try json.set(GameResultTreasure.idKey, id?.int)
        try json.set(GameResultTreasure.classIdKey, classId)
        try json.set(GameResultTreasure.gameIdKey, gameId)
        try json.set(GameResultTreasure.treasureIdKey, treasureId)
        try json.set(GameResultTreasure.treasureNameKey, treasureName)
        try json.set(GameResultTreasure.playerIdKey, playerId)
        try json.set(GameResultTreasure.playerNameKey, playerName)
        try json.set(GameResultTreasure.numberOfAttemptsKey, numberOfAttempts)
        try json.set(GameResultTreasure.pointsKey, points)
        try json.set(GameResultTreasure.dateCreatedKey, dateCreated)
        try json.set(GameResultTreasure.dateUpdatedKey, dateUpdated)
        
        return json
    }
}

extension GameResultTreasure: Preparation {
    static func prepare(_ database: Database) throws {
        try database.create(self) { builder in
            builder.id()
            builder.int(GameResultTreasure.classIdKey)
            builder.int(GameResultTreasure.gameIdKey)
            builder.int(GameResultTreasure.treasureIdKey)
            builder.string(GameResultTreasure.treasureNameKey)
            builder.int(GameResultTreasure.playerIdKey)
            builder.string(GameResultTreasure.playerNameKey)
            builder.int(GameResultTreasure.numberOfAttemptsKey)
            builder.int(GameResultTreasure.pointsKey)
            builder.date(GameResultTreasure.dateCreatedKey)
            builder.date(GameResultTreasure.dateUpdatedKey)
        }
    }
    
    static func revert(_ database: Database) throws {
        try database.delete(self)
    }
}
