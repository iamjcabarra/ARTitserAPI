//
//  Treasure.swift
//  ARFollowAPIPackageDescription
//
//  Created by Julius Abarra.
//

import Vapor
import MySQLProvider

final class Treasure: Model {
    
    let storage = Storage()
    
    var id: Node?
    var name: String
    var treasureDescription: String
    var imageUrl: String
    var imageLocalName: String
    var model3dUrl: String
    var model3dLocalName: String
//    var claimingQuestion: String
//    var claimingAnswers: String
//    var encryptedClaimingAnswers: String
//    var isCaseSensitive: Int
//    var longitude: Double
//    var latitude: Double
//    var locationName: String
//    var points: Int
    var owner: Int
    var dateCreated: Date
    var dateUpdated: Date
    
    static let nameKey = "name"
    static let treasureDescriptionKey = "treasureDescription"
    static let imageUrlKey = "imageUrl"
    static let imageLocalNameKey = "imageLocalName"
    static let model3dUrlKey = "model3dUrl"
    static let model3dLocalNameKey = "model3dLocalName"
//    static let claimingQuestionKey = "claimingQuestion"
//    static let claimingAnswersKey = "claimingAnswers"
//    static let encryptedClaimingAnswersKey = "encryptedClaimingAnswers"
//    static let isCaseSensitiveKey = "isCaseSensitive"
//    static let longitudeKey = "longitude"
//    static let latitudeKey = "latitude"
//    static let locationNameKey = "locationName"
//    static let pointsKey = "points"
    static let ownerKey = "owner"
    static let dateCreatedKey = "dateCreated"
    static let dateUpdatedKey = "dateUpdated"
    
//    init(name: String, treasureDescription: String, imageUrl: String, imageLocalName: String, model3dUrl: String, model3dLocalName: String, claimingQuestion: String, claimingAnswers: String, encryptedClaimingAnswers: String, isCaseSensitive: Int, longitude: Double, latitude: Double, locationName: String, points: Int, owner: Int, dateCreated: Date, dateUpdated: Date) {
        init(name: String, treasureDescription: String, imageUrl: String, imageLocalName: String, model3dUrl: String, model3dLocalName: String, owner: Int, dateCreated: Date, dateUpdated: Date) {
        self.id = nil
        self.name = name
        self.treasureDescription = treasureDescription
        self.imageUrl = imageUrl
        self.imageLocalName = imageLocalName
        self.model3dUrl = model3dUrl
        self.model3dLocalName = model3dLocalName
//        self.claimingQuestion = claimingQuestion
//        self.claimingAnswers = claimingAnswers
//        self.encryptedClaimingAnswers = encryptedClaimingAnswers
//        self.isCaseSensitive = isCaseSensitive
//        self.longitude = longitude
//        self.latitude = latitude
//        self.locationName = locationName
//        self.points = points
        self.owner = owner
        self.dateCreated = dateCreated
        self.dateUpdated = dateUpdated
    }
    
    init(row: Row) throws {
        id = try row.get(Treasure.idKey)
        name = try row.get(Treasure.nameKey)
        treasureDescription = try row.get(Treasure.treasureDescriptionKey)
        imageUrl = try row.get(Treasure.imageUrlKey)
        imageLocalName = try row.get(Treasure.imageLocalNameKey)
        model3dUrl = try row.get(Treasure.model3dUrlKey)
        model3dLocalName = try row.get(Treasure.model3dLocalNameKey)
//        claimingQuestion = try row.get(Treasure.claimingQuestionKey)
//        claimingAnswers = try row.get(Treasure.claimingAnswersKey)
//        encryptedClaimingAnswers = try row.get(Treasure.encryptedClaimingAnswersKey)
//        isCaseSensitive = try row.get(Treasure.isCaseSensitiveKey)
//        longitude = try row.get(Treasure.longitudeKey)
//        latitude = try row.get(Treasure.latitudeKey)
//        locationName = try row.get(Treasure.locationNameKey)
//        points = try row.get(Treasure.pointsKey)
        owner = try row.get(Treasure.ownerKey)
        dateCreated = try row.get(Treasure.dateCreatedKey)
        dateUpdated = try row.get(Treasure.dateUpdatedKey)
    }
    
    init(node: Node) throws {
        name = try node.get(Treasure.nameKey)
        treasureDescription = try node.get(Treasure.treasureDescriptionKey)
        imageUrl = try node.get(Treasure.imageUrlKey)
        imageLocalName = try node.get(Treasure.imageLocalNameKey)
        model3dUrl = try node.get(Treasure.model3dUrlKey)
        model3dLocalName = try node.get(Treasure.model3dLocalNameKey)
//        claimingQuestion = try node.get(Treasure.claimingQuestionKey)
//        claimingAnswers = try node.get(Treasure.claimingAnswersKey)
//        encryptedClaimingAnswers = try node.get(Treasure.encryptedClaimingAnswersKey)
//        isCaseSensitive = try node.get(Treasure.isCaseSensitiveKey)
//        longitude = try node.get(Treasure.longitudeKey)
//        latitude = try node.get(Treasure.latitudeKey)
//        locationName = try node.get(Treasure.locationNameKey)
//        points = try node.get(Treasure.pointsKey)
        owner = try node.get(Treasure.ownerKey)
        dateCreated = Date()
        dateUpdated = Date()
    }
    
    init(json: JSON) throws {
        name = try json.get(Treasure.nameKey)
        treasureDescription = try json.get(Treasure.treasureDescriptionKey)
        imageUrl = try json.get(Treasure.imageUrlKey)
        imageLocalName = try json.get(Treasure.imageLocalNameKey)
        model3dUrl = try json.get(Treasure.model3dUrlKey)
        model3dLocalName = try json.get(Treasure.model3dLocalNameKey)
//        claimingQuestion = try json.get(Treasure.claimingQuestionKey)
//        claimingAnswers = try json.get(Treasure.claimingAnswersKey)
//        encryptedClaimingAnswers = try json.get(Treasure.encryptedClaimingAnswersKey)
//        isCaseSensitive = try json.get(Treasure.isCaseSensitiveKey)
//        longitude = try json.get(Treasure.longitudeKey)
//        latitude = try json.get(Treasure.latitudeKey)
//        locationName = try json.get(Treasure.locationNameKey)
//        points = try json.get(Treasure.pointsKey)
        owner = try json.get(Treasure.ownerKey)
        dateCreated = Date()
        dateUpdated = Date()
    }
    
    func makeRow() throws -> Row {
        var row = Row()
        try row.set(Treasure.nameKey, name)
        try row.set(Treasure.treasureDescriptionKey, treasureDescription)
        try row.set(Treasure.imageUrlKey, imageUrl)
        try row.set(Treasure.imageLocalNameKey, imageLocalName)
        try row.set(Treasure.model3dUrlKey, model3dUrl)
        try row.set(Treasure.model3dLocalNameKey, model3dLocalName)
//        try row.set(Treasure.claimingQuestionKey, claimingQuestion)
//        try row.set(Treasure.claimingAnswersKey, claimingAnswers)
//        try row.set(Treasure.encryptedClaimingAnswersKey, encryptedClaimingAnswers)
//        try row.set(Treasure.isCaseSensitiveKey, isCaseSensitive)
//        try row.set(Treasure.longitudeKey, longitude)
//        try row.set(Treasure.latitudeKey, latitude)
//        try row.set(Treasure.locationNameKey, locationName)
//        try row.set(Treasure.pointsKey, points)
        try row.set(Treasure.ownerKey, owner)
        try row.set(Treasure.dateCreatedKey, dateCreated)
        try row.set(Treasure.dateUpdatedKey, dateUpdated)
        
        return row
    }
}

extension Treasure: NodeRepresentable {
    func makeNode(in context: Context?) throws -> Node {
        var node = Node(context)
        try node.set(Treasure.idKey, id?.int)
        try node.set(Treasure.nameKey, name)
        try node.set(Treasure.treasureDescriptionKey, treasureDescription)
        try node.set(Treasure.imageUrlKey, imageUrl)
        try node.set(Treasure.imageLocalNameKey, imageLocalName)
        try node.set(Treasure.model3dUrlKey, model3dUrl)
        try node.set(Treasure.model3dLocalNameKey, model3dLocalName)
//        try node.set(Treasure.claimingQuestionKey, claimingQuestion)
//        try node.set(Treasure.claimingAnswersKey, claimingAnswers)
//        try node.set(Treasure.encryptedClaimingAnswersKey, encryptedClaimingAnswers)
//        try node.set(Treasure.isCaseSensitiveKey, isCaseSensitive)
//        try node.set(Treasure.longitudeKey, longitude)
//        try node.set(Treasure.latitudeKey, latitude)
//        try node.set(Treasure.locationNameKey, locationName)
//        try node.set(Treasure.pointsKey, points)
        try node.set(Treasure.ownerKey, owner)
        try node.set(Treasure.dateCreatedKey, dateCreated)
        try node.set(Treasure.dateUpdatedKey, dateUpdated)
        
        return node
    }
}

extension Treasure: JSONRepresentable {
    func makeJSON() throws -> JSON {
        var json = JSON()
        try json.set(Treasure.idKey, id?.int)
        try json.set(Treasure.nameKey, name)
        try json.set(Treasure.treasureDescriptionKey, treasureDescription)
        try json.set(Treasure.imageUrlKey, imageUrl)
        try json.set(Treasure.imageLocalNameKey, imageLocalName)
        try json.set(Treasure.model3dUrlKey, model3dUrl)
        try json.set(Treasure.model3dLocalNameKey, model3dLocalName)
//        try json.set(Treasure.claimingQuestionKey, claimingQuestion)
//        try json.set(Treasure.claimingAnswersKey, claimingAnswers)
//        try json.set(Treasure.encryptedClaimingAnswersKey, encryptedClaimingAnswers)
//        try json.set(Treasure.isCaseSensitiveKey, isCaseSensitive)
//        try json.set(Treasure.longitudeKey, longitude)
//        try json.set(Treasure.latitudeKey, latitude)
//        try json.set(Treasure.locationNameKey, locationName)
//        try json.set(Treasure.pointsKey, points)
        try json.set(Treasure.ownerKey, owner)
        try json.set(Treasure.dateCreatedKey, dateCreated)
        try json.set(Treasure.dateUpdatedKey, dateUpdated)
        
        return json
    }
}

extension Treasure: Preparation {
    static func prepare(_ database: Database) throws {
        try database.create(self) { builder in
            builder.id()
            builder.string(Treasure.nameKey)
            builder.string(Treasure.treasureDescriptionKey)
            builder.string(Treasure.imageUrlKey)
            builder.string(Treasure.imageLocalNameKey)
            builder.string(Treasure.model3dUrlKey)
            builder.string(Treasure.model3dLocalNameKey)
//            builder.string(Treasure.claimingQuestionKey)
//            builder.string(Treasure.claimingAnswersKey)
//            builder.string(Treasure.encryptedClaimingAnswersKey)
//            builder.int(Treasure.isCaseSensitiveKey)
//            builder.double(Treasure.longitudeKey)
//            builder.double(Treasure.latitudeKey)
//            builder.string(Treasure.locationNameKey)
//            builder.int(Treasure.pointsKey)
            builder.int(Treasure.ownerKey)
            builder.date(Treasure.dateCreatedKey)
            builder.date(Treasure.dateUpdatedKey)
        }
    }
    
    static func revert(_ database: Database) throws {
        try database.delete(self)
    }
}

///// One-to-Many Relationship
///// Retrieves all games assigned to the treasure
extension Treasure {
    var games: Children<Treasure, Game> { return children() }
}
