//
//  User.swift
//  App
//
//  Created by Julius Abarra.
//

import Vapor
import MySQLProvider

final class User: Model {
    
    let storage = Storage()
    
    var id: Node?
    var lastName: String
    var firstName: String
    var middleName: String
    var gender: Int
    var birthdate: String
    var address: String
    var mobile: String
    var email: String
    var type: Int
    var username: String
    var encryptedUsername: String
    var password: String
    var encryptedPassword: String
    var imageUrl: String
    var owner: Int
    var dateCreated: Date
    var dateUpdated: Date
    var isForApproval: String
    
    static let lastNameKey = "lastName"
    static let middleNameKey = "middleName"
    static let firstNameKey = "firstName"
    static let genderKey = "gender"
    static let birthdateKey = "birthdate"
    static let addressKey = "address"
    static let mobileKey = "mobile"
    static let emailKey = "email"
    static let typeKey = "type"
    static let usernameKey = "username"
    static let encryptedUsernameKey = "encryptedUsername"
    static let passwordKey = "password"
    static let encryptedPasswordKey = "encryptedPassword"
    static let imageUrlKey = "imageUrl"
    static let ownerKey = "owner"
    static let dateCreatedKey = "dateCreated"
    static let dateUpdatedKey = "dateUpdated"
    static let isForApprovalKey = "isForApproval"
    
    init(code: String, lastName: String, firstName: String, middleName: String, gender: Int, birthdate: String, address: String, mobile: String, email: String, type: Int, username: String, encryptedUsername: String, password: String, encryptedPassword: String, imageUrl: String, owner: Int, dateCreated: Date, dateUpdated: Date, isForApproval: String) {
        self.id = nil
        self.lastName = lastName
        self.firstName = firstName
        self.middleName = middleName
        self.gender = gender
        self.birthdate = birthdate
        self.address = address
        self.mobile = mobile
        self.email = email
        self.type = type
        self.username = username
        self.encryptedUsername = encryptedUsername
        self.password = password
        self.encryptedPassword = encryptedPassword
        self.imageUrl = imageUrl
        self.owner = owner
        self.dateCreated = dateCreated
        self.dateUpdated = dateUpdated
        self.isForApproval = isForApproval
    }
    
    init(row: Row) throws {
        id = try row.get(User.idKey)
        lastName = try row.get(User.lastNameKey)
        firstName = try row.get(User.firstNameKey)
        middleName = try row.get(User.middleNameKey)
        gender = try row.get(User.genderKey)
        birthdate = try row.get(User.birthdateKey)
        address = try row.get(User.addressKey)
        mobile = try row.get(User.mobileKey)
        email = try row.get(User.emailKey)
        type = try row.get(User.typeKey)
        username = try row.get(User.usernameKey)
        encryptedUsername = try row.get(User.encryptedUsernameKey)
        password = try row.get(User.passwordKey)
        encryptedPassword = try row.get(User.encryptedPasswordKey)
        imageUrl = try row.get(User.imageUrlKey)
        owner = try row.get(User.ownerKey)
        dateCreated = try row.get(User.dateCreatedKey)
        dateUpdated = try row.get(User.dateUpdatedKey)
        isForApproval = try row.get(User.isForApprovalKey)
    }
    
    init(node: Node) throws {
        lastName = try node.get(User.lastNameKey)
        firstName = try node.get(User.firstNameKey)
        middleName = try node.get(User.middleNameKey)
        gender = try node.get(User.genderKey)
        birthdate = try node.get(User.birthdateKey)
        address = try node.get(User.addressKey)
        mobile = try node.get(User.mobileKey)
        email = try node.get(User.emailKey)
        type = try node.get(User.typeKey)
        username = try node.get(User.usernameKey)
        encryptedUsername = try node.get(User.encryptedUsernameKey)
        password = try node.get(User.passwordKey)
        encryptedPassword = try node.get(User.encryptedPasswordKey)
        imageUrl = try node.get(User.imageUrlKey)
        owner = try node.get(User.ownerKey)
        dateCreated = Date()
        dateUpdated = Date()
        isForApproval = try node.get(User.isForApprovalKey)
    }
    
    init(json: JSON) throws {
        lastName = try json.get(User.lastNameKey)
        firstName = try json.get(User.firstNameKey)
        middleName = try json.get(User.middleNameKey)
        gender = try json.get(User.genderKey)
        birthdate = try json.get(User.birthdateKey)
        address = try json.get(User.addressKey)
        mobile = try json.get(User.mobileKey)
        email = try json.get(User.emailKey)
        type = try json.get(User.typeKey)
        username = try json.get(User.usernameKey)
        encryptedUsername = try json.get(User.encryptedUsernameKey)
        password = try json.get(User.passwordKey)
        encryptedPassword = try json.get(User.encryptedPasswordKey)
        imageUrl = try json.get(User.imageUrlKey)
        owner = try json.get(User.ownerKey)
        dateCreated = Date()
        dateUpdated = Date()
        isForApproval = try json.get(User.isForApprovalKey)
    }
    
    func makeRow() throws -> Row {
        var row = Row()
        try row.set(User.lastNameKey, lastName)
        try row.set(User.firstNameKey, firstName)
        try row.set(User.middleNameKey, middleName)
        try row.set(User.genderKey, gender)
        try row.set(User.birthdateKey, birthdate)
        try row.set(User.addressKey, address)
        try row.set(User.mobileKey, mobile)
        try row.set(User.emailKey, email)
        try row.set(User.typeKey, type)
        try row.set(User.usernameKey, username)
        try row.set(User.encryptedUsernameKey, encryptedUsername)
        try row.set(User.passwordKey, password)
        try row.set(User.encryptedPasswordKey, encryptedPassword)
        try row.set(User.imageUrlKey, imageUrl)
        try row.set(User.ownerKey, owner)
        try row.set(User.dateCreatedKey, dateCreated)
        try row.set(User.dateUpdatedKey, dateUpdated)
        try row.set(User.isForApprovalKey, isForApproval)
        
        return row
    }
}

extension User: NodeRepresentable {
    func makeNode(in context: Context?) throws -> Node {
        var node = Node(context)
        try node.set(User.idKey, id?.int)
        try node.set(User.lastNameKey, lastName)
        try node.set(User.firstNameKey, firstName)
        try node.set(User.middleNameKey, middleName)
        try node.set(User.genderKey, gender)
        try node.set(User.birthdateKey, birthdate)
        try node.set(User.addressKey, address)
        try node.set(User.mobileKey, mobile)
        try node.set(User.emailKey, email)
        try node.set(User.typeKey, type)
        try node.set(User.usernameKey, username)
        try node.set(User.encryptedUsernameKey, encryptedUsername)
        try node.set(User.passwordKey, password)
        try node.set(User.encryptedPasswordKey, encryptedPassword)
        try node.set(User.imageUrlKey, imageUrl)
        try node.set(User.ownerKey, owner)
        try node.set(User.dateCreatedKey, dateCreated)
        try node.set(User.dateUpdatedKey, dateUpdated)
        try node.set(User.isForApprovalKey, isForApproval)
        return node
    }
}

extension User: JSONRepresentable {
    func makeJSON() throws -> JSON {
        var json = JSON()
        try json.set(User.idKey, id?.int)
        try json.set(User.lastNameKey, lastName)
        try json.set(User.firstNameKey, firstName)
        try json.set(User.middleNameKey, middleName)
        try json.set(User.genderKey, gender)
        try json.set(User.birthdateKey, birthdate)
        try json.set(User.addressKey, address)
        try json.set(User.mobileKey, mobile)
        try json.set(User.emailKey, email)
        try json.set(User.typeKey, type)
        try json.set(User.usernameKey, username)
        try json.set(User.encryptedUsernameKey, encryptedUsername)
        try json.set(User.passwordKey, password)
        try json.set(User.encryptedPasswordKey, encryptedPassword)
        try json.set(User.imageUrlKey, imageUrl)
        try json.set(User.ownerKey, owner)
        try json.set(User.dateCreatedKey, dateCreated)
        try json.set(User.dateUpdatedKey, dateUpdated)
        try json.set(User.isForApprovalKey, isForApproval)
        
        return json
    }
}

extension User: Preparation {
    static func prepare(_ database: Database) throws {
        try database.create(self) { builder in
            builder.id()
            builder.string(User.lastNameKey)
            builder.string(User.firstNameKey)
            builder.string(User.middleNameKey)
            builder.int(User.genderKey)
            builder.string(User.birthdateKey)
            builder.string(User.addressKey)
            builder.string(User.mobileKey)
            builder.string(User.emailKey)
            builder.int(User.typeKey)
            builder.string(User.usernameKey)
            builder.string(User.encryptedUsernameKey)
            builder.string(User.passwordKey)
            builder.string(User.encryptedPasswordKey)
            builder.string(User.imageUrlKey)
            builder.int(User.ownerKey)
            builder.date(User.dateCreatedKey)
            builder.date(User.dateUpdatedKey)
            builder.string(User.isForApprovalKey)
        }
    }
    
    static func revert(_ database: Database) throws {
        try database.delete(self)
    }
}

///// Many-to-Many Relationship
///// Retrieves all classes assigned to the creator or player
extension User {
    var classes: Siblings<User, Class, Pivot<User, Class>> {
        return siblings()
    }
}

