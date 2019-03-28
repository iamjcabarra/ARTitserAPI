//
//  GameDeployment.swift
//  ARTitserPI
//
//  Created by Julius Abarra.
//

import Vapor
import MySQLProvider

final class GameDeployment: Model {
    
    let storage = Storage()
    
    var id: Node?
    var classId: Int
    var gameId: Int
    var deployedBy: Int
    var dateDeployed: Date
    
    static let classIdKey = "classId"
    static let gameIdKey = "gameId"
    static let deployedByKey = "deployedBy"
    static let dateDeployedKey = "dateDeployed"
    
    init(classId: Int, gameId: Int, deployedBy: Int, dateDeployed: Date) {
        self.id = nil
        self.classId = classId
        self.gameId = gameId
        self.deployedBy = deployedBy
        self.dateDeployed = dateDeployed
    }
    
    init(row: Row) throws {
        id = try row.get(GameDeployment.idKey)
        classId = try row.get(GameDeployment.classIdKey)
        gameId = try row.get(GameDeployment.gameIdKey)
        deployedBy = try row.get(GameDeployment.deployedByKey)
        dateDeployed = try row.get(GameDeployment.dateDeployedKey)
    }
    
    init(node: Node) throws {
        classId = try node.get(GameDeployment.classIdKey)
        gameId = try node.get(GameDeployment.gameIdKey)
        deployedBy = try node.get(GameDeployment.deployedByKey)
        dateDeployed = try node.get(GameDeployment.dateDeployedKey)
    }
    
    init(json: JSON) throws {
        classId = try json.get(GameDeployment.classIdKey)
        gameId = try json.get(GameDeployment.gameIdKey)
        deployedBy = try json.get(GameDeployment.deployedByKey)
        dateDeployed = try json.get(GameDeployment.dateDeployedKey)
    }
    
    func makeRow() throws -> Row {
        var row = Row()
        try row.set(GameDeployment.classIdKey, classId)
        try row.set(GameDeployment.gameIdKey, gameId)
        try row.set(GameDeployment.deployedByKey, deployedBy)
        try row.set(GameDeployment.dateDeployedKey, dateDeployed)

        return row
    }
}

extension GameDeployment: NodeRepresentable {
    func makeNode(in context: Context?) throws -> Node {
        var node = Node(context)
        try node.set(GameDeployment.idKey, id?.int)
        try node.set(GameDeployment.classIdKey, classId)
        try node.set(GameDeployment.gameIdKey, gameId)
        try node.set(GameDeployment.deployedByKey, deployedBy)
        try node.set(GameDeployment.dateDeployedKey, dateDeployed)
        
        return node
    }
}

extension GameDeployment: JSONRepresentable {
    func makeJSON() throws -> JSON {
        var json = JSON()
        try json.set(GameDeployment.idKey, id?.int)
        try json.set(GameDeployment.classIdKey, classId)
        try json.set(GameDeployment.gameIdKey, gameId)
        try json.set(GameDeployment.deployedByKey, deployedBy)
        try json.set(GameDeployment.dateDeployedKey, dateDeployed)
        
        return json
    }
}

extension GameDeployment: Preparation {
    static func prepare(_ database: Database) throws {
        try database.create(self) { builder in
            builder.id()
            builder.int(GameDeployment.classIdKey)
            builder.int(GameDeployment.gameIdKey)
            builder.int(GameDeployment.deployedByKey)
            builder.date(GameDeployment.dateDeployedKey)
        }
    }
    
    static func revert(_ database: Database) throws {
        try database.delete(self)
    }
}
