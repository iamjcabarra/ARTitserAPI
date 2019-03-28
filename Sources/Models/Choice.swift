//
//  Choice.swift
//  App
//
//  Created by Julius Abarra.
//

import Vapor
import MySQLProvider

final class Choice: Model {
    
    let storage = Storage()
    
    var id: Node?
    var clueId: Identifier
    var choiceStatement: String
    var isCorrect: Int
    var answer: String
    var encryptedAnswer: String
    var isCaseSensitive: Int
    var dateCreated: Date
    var dateUpdated: Date
    
    static let clueIdKey = "clueId"
    static let choiceStatementKey = "choiceStatement"
    static let isCorrectKey = "isCorrect"
    static let answerKey = "answer"
    static let encryptedAnswerKey = "encryptedAnswer"
    static let isCaseSensitiveKey = "isCaseSensitive"
    static let dateCreatedKey = "dateCreated"
    static let dateUpdatedKey = "dateUpdated"
    
    init(clueId: Identifier, choiceStatement: String, isCorrect: Int, answer: String, encryptedAnswer: String, isCaseSensitive: Int, dateCreated: Date, dateUpdated: Date) throws {
        self.id = nil
        self.clueId = clueId
        self.choiceStatement = choiceStatement
        self.isCorrect = isCorrect
        self.answer = answer
        self.encryptedAnswer = encryptedAnswer
        self.isCaseSensitive = isCaseSensitive
        self.dateCreated = dateCreated
        self.dateUpdated = dateUpdated
    }
    
    init(row: Row) throws {
        id = try row.get(Choice.idKey)
        clueId = try row.get(Choice.clueIdKey)
        choiceStatement = try row.get(Choice.choiceStatementKey)
        isCorrect = try row.get(Choice.isCorrectKey)
        answer = try row.get(Choice.answerKey)
        encryptedAnswer = try row.get(Choice.encryptedAnswerKey)
        isCaseSensitive = try row.get(Choice.isCaseSensitiveKey)
        dateCreated = try row.get(Choice.dateCreatedKey)
        dateUpdated = try row.get(Choice.dateUpdatedKey)
    }
    
    init(node: Node) throws {
        clueId = try node.get(Choice.clueIdKey)
        choiceStatement = try node.get(Choice.choiceStatementKey)
        isCorrect = try node.get(Choice.isCorrectKey)
        answer = try node.get(Choice.answerKey)
        encryptedAnswer = try node.get(Choice.encryptedAnswerKey)
        isCaseSensitive = try node.get(Choice.isCaseSensitiveKey)
        dateCreated = Date()
        dateUpdated = Date()
    }
    
    init(json: JSON) throws {
        clueId = try json.get(Choice.clueIdKey)
        choiceStatement = try json.get(Choice.choiceStatementKey)
        isCorrect = try json.get(Choice.isCorrectKey)
        answer = try json.get(Choice.answerKey)
        encryptedAnswer = try json.get(Choice.encryptedAnswerKey)
        isCaseSensitive = try json.get(Choice.isCaseSensitiveKey)
        dateCreated = Date()
        dateUpdated = Date()
    }
    
    func makeRow() throws -> Row {
        var row = Row()
        try row.set(Choice.clueIdKey, clueId)
        try row.set(Choice.choiceStatementKey, choiceStatement)
        try row.set(Choice.isCorrectKey, isCorrect)
        try row.set(Choice.answerKey, answer)
        try row.set(Choice.encryptedAnswerKey, encryptedAnswer)
        try row.set(Choice.isCaseSensitiveKey, isCaseSensitive)
        try row.set(Choice.dateCreatedKey, dateCreated)
        try row.set(Choice.dateUpdatedKey, dateUpdated)

        return row
    }
    
}

extension Choice: NodeRepresentable {
    func makeNode(in context: Context?) throws -> Node {
        var node = Node(context)
        try node.set(Choice.idKey, id?.int)
        try node.set(Choice.clueIdKey, clueId)
        try node.set(Choice.choiceStatementKey, choiceStatement)
        try node.set(Choice.isCorrectKey, isCorrect)
        try node.set(Choice.answerKey, answer)
        try node.set(Choice.encryptedAnswerKey, encryptedAnswer)
        try node.set(Choice.isCaseSensitiveKey, isCaseSensitive)
        try node.set(Choice.dateCreatedKey, dateCreated)
        try node.set(Choice.dateUpdatedKey, dateUpdated)
        
        return node
    }
}

extension Choice: JSONRepresentable {
    func makeJSON() throws -> JSON {
        var json = JSON()
        try json.set(Choice.idKey, id?.int)
        try json.set(Choice.clueIdKey, clueId)
        try json.set(Choice.choiceStatementKey, choiceStatement)
        try json.set(Choice.isCorrectKey, isCorrect)
        try json.set(Choice.answerKey, answer)
        try json.set(Choice.encryptedAnswerKey, encryptedAnswer)
        try json.set(Choice.isCaseSensitiveKey, isCaseSensitive)
        try json.set(Choice.dateCreatedKey, dateCreated)
        try json.set(Choice.dateUpdatedKey, dateUpdated)
        
        return json
    }
}

extension Choice: Preparation {
    static func prepare(_ database: Database) throws {
        try database.create(self) { builder in
            builder.id()
            builder.string(Choice.choiceStatementKey)
            builder.int(Choice.isCorrectKey)
            builder.string(Choice.answerKey)
            builder.string(Choice.encryptedAnswerKey)
            builder.int(Choice.isCaseSensitiveKey)
            builder.date(Choice.dateCreatedKey)
            builder.date(Choice.dateUpdatedKey)
            builder.parent(Clue.self, optional: false, unique: false, foreignIdKey: "clueId")
        }
    }
    
    static func revert(_ database: Database) throws {
        try database.delete(self)
    }
}

///// One-to-Many Relationship
///// Retrieves clue assigned to the choice
extension Choice {
    var clue: Parent<Choice, Clue> { return parent(id: clueId) }
}
