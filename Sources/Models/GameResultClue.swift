//
//  GameResultClue.swift
//  App
//
//  Created by Julius Abarra.
//

import Vapor
import MySQLProvider

final class GameResultClue: Model {
    
    let storage = Storage()
    
    var id: Node?
    var classId: Int
    var gameId: Int
    var clueId: Int
    var clueName: String
    var playerId: Int
    var playerName: String
    var numberOfAttempts: Int
    var points: Int
    var dateCreated: Date
    var dateUpdated: Date
    
    static let classIdKey = "classId"
    static let gameIdKey = "gameId"
    static let clueIdKey = "clueId"
    static let clueNameKey = "clueName"
    static let playerIdKey = "playerId"
    static let playerNameKey = "playerName"
    static let numberOfAttemptsKey = "numberOfAttempts"
    static let pointsKey = "points"
    static let dateCreatedKey = "dateCreated"
    static let dateUpdatedKey = "dateUpdated"

    init(classId: Int, gameId: Int, clueId: Int, clueName: String, playerId: Int, playerName: String, numberOfAttempts: Int, points: Int, dateCreated: Date, dateUpdated: Date) {
        self.id = nil
        self.classId = classId
        self.gameId = gameId
        self.clueId = clueId
        self.clueName = clueName
        self.playerId = playerId
        self.playerName = playerName
        self.numberOfAttempts = numberOfAttempts
        self.points = points
        self.dateCreated = dateCreated
        self.dateUpdated = dateUpdated
    }
    
    init(row: Row) throws {
        id = try row.get(GameResultClue.idKey)
        classId = try row.get(GameResultClue.classIdKey)
        gameId = try row.get(GameResultClue.gameIdKey)
        clueId = try row.get(GameResultClue.clueIdKey)
        clueName = try row.get(GameResultClue.clueNameKey)
        playerId = try row.get(GameResultClue.playerIdKey)
        playerName = try row.get(GameResultClue.playerNameKey)
        numberOfAttempts = try row.get(GameResultClue.numberOfAttemptsKey)
        points = try row.get(GameResultClue.pointsKey)
        dateCreated = try row.get(GameResultClue.dateCreatedKey)
        dateUpdated = try row.get(GameResultClue.dateUpdatedKey)
    }
    
    init(node: Node) throws {
        classId = try node.get(GameResultClue.classIdKey)
        gameId = try node.get(GameResultClue.gameIdKey)
        clueId = try node.get(GameResultClue.clueIdKey)
        clueName = try node.get(GameResultClue.clueNameKey)
        playerId = try node.get(GameResultClue.playerIdKey)
        playerName = try node.get(GameResultClue.playerNameKey)
        numberOfAttempts = try node.get(GameResultClue.numberOfAttemptsKey)
        points = try node.get(GameResultClue.pointsKey)
        dateCreated = Date()
        dateUpdated = Date()
    }
    
    init(json: JSON) throws {
        classId = try json.get(GameResultClue.classIdKey)
        gameId = try json.get(GameResultClue.gameIdKey)
        clueId = try json.get(GameResultClue.clueIdKey)
        clueName = try json.get(GameResultClue.clueNameKey)
        playerId = try json.get(GameResultClue.playerIdKey)
        playerName = try json.get(GameResultClue.playerNameKey)
        numberOfAttempts = try json.get(GameResultClue.numberOfAttemptsKey)
        points = try json.get(GameResultClue.pointsKey)
        dateCreated = Date()
        dateUpdated = Date()
    }
    
    func makeRow() throws -> Row {
        var row = Row()
        try row.set(GameResultClue.classIdKey, classId)
        try row.set(GameResultClue.gameIdKey, gameId)
        try row.set(GameResultClue.clueIdKey, clueId)
        try row.set(GameResultClue.clueNameKey, clueName)
        try row.set(GameResultClue.playerIdKey, playerId)
        try row.set(GameResultClue.playerNameKey, playerName)
        try row.set(GameResultClue.numberOfAttemptsKey, numberOfAttempts)
        try row.set(GameResultClue.pointsKey, points)
        try row.set(GameResultClue.dateCreatedKey, dateCreated)
        try row.set(GameResultClue.dateUpdatedKey, dateUpdated)
        
        return row
    }
}

extension GameResultClue: NodeRepresentable {
    func makeNode(in context: Context?) throws -> Node {
        var node = Node(context)
        try node.set(GameResultClue.idKey, id?.int)
        try node.set(GameResultClue.classIdKey, classId)
        try node.set(GameResultClue.gameIdKey, gameId)
        try node.set(GameResultClue.clueIdKey, clueId)
        try node.set(GameResultClue.clueNameKey, clueName)
        try node.set(GameResultClue.playerIdKey, playerId)
        try node.set(GameResultClue.playerNameKey, playerName)
        try node.set(GameResultClue.numberOfAttemptsKey, numberOfAttempts)
        try node.set(GameResultClue.pointsKey, points)
        try node.set(GameResultClue.dateCreatedKey, dateCreated)
        try node.set(GameResultClue.dateUpdatedKey, dateUpdated)
        
        return node
    }
}

extension GameResultClue: JSONRepresentable {
    func makeJSON() throws -> JSON {
        var json = JSON()
        try json.set(GameResultClue.idKey, id?.int)
        try json.set(GameResultClue.classIdKey, classId)
        try json.set(GameResultClue.gameIdKey, gameId)
        try json.set(GameResultClue.clueIdKey, clueId)
        try json.set(GameResultClue.clueNameKey, clueName)
        try json.set(GameResultClue.playerIdKey, playerId)
        try json.set(GameResultClue.playerNameKey, playerName)
        try json.set(GameResultClue.numberOfAttemptsKey, numberOfAttempts)
        try json.set(GameResultClue.pointsKey, points)
        try json.set(GameResultClue.dateCreatedKey, dateCreated)
        try json.set(GameResultClue.dateUpdatedKey, dateUpdated)
        
        return json
    }
}

extension GameResultClue: Preparation {
    static func prepare(_ database: Database) throws {
        try database.create(self) { builder in
            builder.id()
            builder.int(GameResultClue.classIdKey)
            builder.int(GameResultClue.gameIdKey)
            builder.int(GameResultClue.clueIdKey)
            builder.string(GameResultClue.clueNameKey)
            builder.int(GameResultClue.playerIdKey)
            builder.string(GameResultClue.playerNameKey)
            builder.int(GameResultClue.numberOfAttemptsKey)
            builder.int(GameResultClue.pointsKey)
            builder.date(GameResultClue.dateCreatedKey)
            builder.date(GameResultClue.dateUpdatedKey)
        }
    }
    
    static func revert(_ database: Database) throws {
        try database.delete(self)
    }
}
