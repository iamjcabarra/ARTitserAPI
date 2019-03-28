import Vapor
import MySQLProvider
import Foundation

final class Routes: RouteCollection {
    
    private var status: Int = 0
    private var message: String = ""
    private var data: Any? = nil
    private var sidekickLevelDivisor = 200
    
    func build(_ builder: RouteBuilder) throws {
        
        //////////////////////
        /// STATISTICS
        //////////////////////
        
        /// GA Dashboard
        /// Provide number of users, courses and classes stored in the database
        builder.get("retrieve", "statistics", "administrator", "dashboard", "primary", ":id") { request in
            guard let id = request.parameters["id"]?.int else { throw Abort.badRequest }
            let users = try User.makeQuery().and { andGroup in
                try andGroup.filter("id", .notEquals, id)
                try andGroup.filter("isForApproval", .notEquals, "1")
                }.all()
            let courses = try Course.makeQuery().all()
            let classes = try Class.makeQuery().all()
            return try JSON(node: ["status": 0, "message": "success", "data": ["users": users.count, "courses": courses.count, "classes": classes.count]])
        }
        
        /// GC Dashboard
        /// Provide number of clues, treasures and games stored in the database
        builder.get("retrieve", "statistics", "creator", "dashboard", "primary", ":id") { request in
            guard let id = request.parameters["id"]?.int else { throw Abort.badRequest }
            let clues = try Clue.makeQuery().filter("owner", .equals, id).all()
            let treasures = try Treasure.makeQuery().filter("owner", .equals, id).all()
            let games = try Game.makeQuery().filter("owner", .equals, id).all()
            return try JSON(node: ["status": 0, "message": "success", "data": ["clues": clues.count, "treasures": treasures.count, "games": games.count]])
        }
        
        //////////////////////
        /// USERS
        //////////////////////
        
        /// LOG IN
        /// Authenticate user with his username and password
        builder.post("login", "user") { request in
            let rfKeys = ["username", "password"]
            let values = self.formDataFieldValues(fromRequest: request, withRequiredFieldKeys: rfKeys, andNonEmptyFieldKeys: nil)
            
            if values != nil {
                let un = self.string(values!["username"])
                let pw = self.string(values!["password"])
                
                let user = try User.makeQuery().and { andGroup in
                    try andGroup.filter("encryptedUsername", un)
                    try andGroup.filter("encryptedPassword", pw)
                    try andGroup.filter("isForApproval", "0")
                    }.all().last
                
                if user != nil {
                    self.status = 0
                    self.message = "Welcome back, \(user!.firstName)!"
                    self.data = ["user": user]
                    
                    try self.logActivity("Logged in to the system", inModule: "User Authentication", byUserWithId: user?.id?.int ?? 0)
                }
                else {
                    self.status = 1
                    self.message = "The username or password that you have entered is incorrect."
                    self.data = nil
                }
            }
            else {
                self.status = 1
                self.message = "Sent wrong data!"
                self.data = nil
            }
            
            return try JSON(node: ["status": self.status, "message": self.message, "data": self.data == nil ? "" : self.data!])
        }
        
        /// LOG OUT
        /// Just log user's activity as he logs out from the system
        builder.get("logout", "user", ":id") { request in
            guard let id = request.parameters["id"]?.int else { throw Abort.badRequest }
            let user = try User.makeQuery().filter("id", .equals, id).all().last
            try self.logActivity("Logged out from the system", inModule: "User", byUserWithId: id)
            return try JSON(node: ["status": 0, "message": "success", "data": ["user": user]])
        }
        
        /// CREATE
        /// A new user
        builder.post("create", "user", "requestor", ":requestorId") { request in
            let rfKeys = ["lastName", "firstName", "middleName", "gender", "birthdate", "address", "mobile", "email", "type", "username", "encryptedUsername", "password", "encryptedPassword", "owner", "isForApproval"]
            let neKeys = ["lastName", "firstName", "gender", "type", "username", "encryptedUsername", "password", "encryptedPassword", "owner", "isForApproval"]
            var values = self.formDataFieldValues(fromRequest: request, withRequiredFieldKeys: rfKeys, andNonEmptyFieldKeys: neKeys)
            let fileSaved = self.saveFile(fromRequest: request, fileKey: "imageUrl")
            
            // Check if username already exists. If it exists,
            // disallow saving of a new user; otherwise, allow
            // it.
            if values != nil {
                let username = self.string(values!["username"])
                let encryptedUsername = self.string(values!["encryptedUsername"])
                let users = try User.makeQuery().filter("encryptedUsername", .equals, encryptedUsername).all()
                let isForApproval = self.string(values!["isForApproval"])
            
                if users.count > 0 {
                    self.status = 1
                    self.message = "User with username \"\(username)\" already exists!"
                    self.data = nil
                }
                else {
                    values!["imageUrl"] = fileSaved.1
                    let user = try User(node: values!.makeNode(in: Node.defaultContext))
                    try user.save()
                    
                    self.status = 0
                    self.message = isForApproval != "1" ?  "A new user has been successfully created." : "You successfully registered. Please wait for the administrator to approve your registration."
                    self.data = ["user": user]
                    
                    try self.logActivity("\(isForApproval != "1" ? "Created a new user" : "Registered user") with id \"\(user.id?.int ?? 0)\"", inModule: "User", byRequest: request)
                }
            }
            else {
                self.status = 1
                self.message = "Sent wrong data!"
                self.data = nil
            }
            
            return try JSON(node: ["status": self.status, "message": self.message, "data": self.data == nil ? "" : self.data!])
        }
        
        /// RETRIEVE
        /// Users for user with id
        builder.get("retrieve", "users", "user", ":id", "requestor", ":requestorId") { request in
            guard let id = request.parameters["id"]?.int else { throw Abort.badRequest }
            let users = try User.makeQuery().filter("owner", .equals, id).all()
            try self.logActivity("Retrieved users created by user with id \"\(id)\"", inModule: "User", byRequest: request)
            return try JSON(node: ["status": 0, "message": "success", "data": ["users": users]])
        }
        
        /// All users
        builder.get("retrieve", "users", "requestor", ":requestorId") { request in
            let users = try User.makeQuery().all()
            try self.logActivity("Retrieved all users", inModule: "User", byRequest: request)
            return try JSON(node: ["status": 0, "message": "success", "data": ["users": users]])
        }
        
        /// UPDATE
        /// Update user details for user with id
        builder.post("update", "user", ":id", "requestor", ":requestorId") { request in
            guard let id = request.parameters["id"]?.int else { throw Abort.badRequest }
            guard let user = try User.makeQuery().find(id) else { throw Abort.notFound }
            
            let rfKeys = ["lastName", "firstName", "middleName", "gender", "birthdate", "address", "mobile", "email", "type", "username", "encryptedUsername", "password", "encryptedPassword", "owner", "isForApproval"]
            let neKeys = ["lastName", "firstName", "gender", "type", "username", "encryptedUsername", "password", "encryptedPassword"]
            var values = self.formDataFieldValues(fromRequest: request, withRequiredFieldKeys: rfKeys, andNonEmptyFieldKeys: neKeys)
            let fileSaved = self.saveFile(fromRequest: request, fileKey: "imageUrl")
            
            // Check if username already exists. If it exists,
            // disallow saving of a new user; otherwise, allow
            // it.
            if values != nil {
                let username = self.string(values!["username"])
                let encryptedUsername = self.string(values!["encryptedUsername"])
                let users = try User.makeQuery().filter("encryptedUsername", .equals, encryptedUsername).all()
                
                if users.count > 1 {
                    self.status = 1
                    self.message = "User with username \(username) already exists!"
                    self.data = nil
                }
                else {
                    values!["imageUrl"] = fileSaved.1
                    let newUser = try User(node: values!.makeNode(in: Node.defaultContext))
                    if user.imageUrl != "" { self.removeFile(fromEndUrl: user.imageUrl) }
                    
                    user.lastName = newUser.lastName
                    user.firstName = newUser.firstName
                    user.middleName = newUser.middleName
                    user.gender = newUser.gender
                    user.birthdate = newUser.birthdate
                    user.address = newUser.address
                    user.mobile = newUser.mobile
                    user.email = newUser.email
                    user.type = newUser.type
                    user.username = newUser.username
                    user.encryptedUsername = newUser.encryptedUsername
                    user.password = newUser.password
                    user.encryptedPassword = newUser.encryptedPassword
                    user.imageUrl = newUser.imageUrl
                    user.isForApproval = newUser.isForApproval
                    user.dateUpdated = Date()
                    try user.save()
                    
                    self.status = 0
                    self.message = "User has been successfully updated."
                    self.data = ["user": user]
                    
                    try self.logActivity("Updated user with id \"\(id)\"", inModule: "User", byRequest: request)
                }
            }
            else {
                self.status = 1
                self.message = "Sent wrong data!"
                self.data = nil
            }
            
            return try JSON(node: ["status": self.status, "message": self.message, "data": self.data == nil ? "" : self.data!])
        }
        
        /// DELETE
        /// User by user id
        builder.post("delete", "user", ":id", "requestor", ":requestorId") { request in
            guard let id = request.parameters["id"]?.int else { throw Abort.badRequest }
            guard let user = try User.makeQuery().find(id) else { throw Abort.notFound }
            if user.imageUrl != "" { self.removeFile(fromEndUrl: user.imageUrl) }
            try user.delete()
            
            let middleName = user.middleName
            let fullName = middleName == "" ? "\(user.firstName) \(user.lastName)" : "\(user.firstName) \(middleName) \(user.lastName)"
            
            self.status = 0
            self.message = "\(fullName) has been successfully deleted."
            self.data = ["user": user]
            
            try self.logActivity("Deleted user with id \"\(id)\"", inModule: "User", byRequest: request)
            
            return try JSON(node: ["status": self.status, "message": self.message, "data": self.data == nil ? "" : self.data!])
        }
        
        /// APPROVE
        /// Update user details for user with id
        builder.post("approve", "user", ":id", "requestor", ":requestorId") { request in
            guard let id = request.parameters["id"]?.int else { throw Abort.badRequest }
            guard let user = try User.makeQuery().find(id) else { throw Abort.notFound }
            
            let rfKeys = ["isForApproval"]
            let neKeys = ["isForApproval"]
            let values = self.formDataFieldValues(fromRequest: request, withRequiredFieldKeys: rfKeys, andNonEmptyFieldKeys: neKeys)
            
            if values != nil {
                user.isForApproval = self.string(values!["isForApproval"])
                try user.save()
                
                self.status = 0
                self.message = "User has been successfully approved."
                self.data = ["user": user]
                
                try self.logActivity("Approved user with id \"\(id)\"", inModule: "User", byRequest: request)
            }
            else {
                self.status = 1
                self.message = "Sent wrong data!"
                self.data = nil
            }
            
            return try JSON(node: ["status": self.status, "message": self.message, "data": self.data == nil ? "" : self.data!])
        }
        
        //////////////////////
        /// COURSES
        //////////////////////
        
        /// CREATE
        /// A new course
        builder.post("create", "course", "requestor", ":requestorId") { request in
            let rfKeys = ["code", "title", "courseDescription", "unit", "owner"]
            let neKeys = ["code", "title", "courseDescription", "unit", "owner"]
            let values = self.formDataFieldValues(fromRequest: request, withRequiredFieldKeys: rfKeys, andNonEmptyFieldKeys: neKeys)
            
            // Check if course code already exists. If it exists,
            // disallow saving of a new course; otherwise, allow
            // it.
            if values != nil {
                let code = self.string(values!["code"])
                let courses = try Course.makeQuery().filter("code", .equals, code).all()
                
                if courses.count > 0 {
                    self.status = 1
                    self.message = "Course with code \"\(code)\" already exists!"
                    self.data = nil
                }
                else {
                    let course = try Course(node: values!.makeNode(in: Node.defaultContext))
                    try course.save()
                    
                    self.status = 0
                    self.message = "A new course has been successfully created."
                    self.data = ["course": course]
                    
                    try self.logActivity("Created course with code \"\(code)\"", inModule: "Course", byRequest: request)
                }
            }
            else {
                self.status = 1
                self.message = "Sent wrong data!"
                self.data = nil
            }

            return try JSON(node: ["status": self.status, "message": self.message, "data": self.data == nil ? "" : self.data!])
        }
        
        /// RETRIEVE
        /// Courses for user with id
        builder.get("retrieve", "courses", "user", ":id", "requestor", ":requestorId") { request in
            guard let id = request.parameters["id"]?.int else { throw Abort.badRequest }
            let courses = try Course.makeQuery().filter("owner", .equals, id).all()
            try self.logActivity("Retrieved courses created by user with id \"\(id)\"", inModule: "Course", byRequest: request)
            return try JSON(node: ["status": 0, "message": "success", "data": ["courses": courses]])
        }
        
        /// All courses
        builder.get("retrieve", "courses", "requestor", ":requestorId") { request in
            let courses = try Course.makeQuery().all()
            try self.logActivity("Retrieved all courses", inModule: "Course", byRequest: request)
            return try JSON(node: ["status": 0, "message": "success", "data": ["courses": courses]])
        }
        
        /// UPDATE
        /// Update course details for course with id
        builder.post("update", "course", ":id", "requestor", ":requestorId") { request in
            guard let id = request.parameters["id"]?.int else { throw Abort.badRequest }
            guard let course = try Course.makeQuery().find(id) else { throw Abort.notFound }
            
            let rfKeys = ["code", "title", "courseDescription", "unit", "owner"]
            let neKeys = ["code", "title", "courseDescription", "unit"]
            let values = self.formDataFieldValues(fromRequest: request, withRequiredFieldKeys: rfKeys, andNonEmptyFieldKeys: neKeys)
            
            // Check if course code already exists. If it exists,
            // disallow updating of a new course; otherwise,
            // allow it.
            if values != nil {
                let code = self.string(values!["code"])
                let courses = try Course.makeQuery().filter("code", .equals, code).all()
                
                if courses.count > 1 {
                    self.status = 1
                    self.message = "Course with code \"\(code)\" already exists!"
                    self.data = nil
                }
                else {
                    let newCourse = try Course(node: values!.makeNode(in: Node.defaultContext))
                    course.code = newCourse.code
                    course.title = newCourse.title
                    course.courseDescription = newCourse.courseDescription
                    course.unit = newCourse.unit
                    course.dateUpdated = Date()
                    try course.save()
                    
                    self.status = 0
                    self.message = "Course with code \"\(code)\" has been successfully updated."
                    self.data = ["course": course]
                    
                    try self.logActivity("Updated course with code \"\(code)\"", inModule: "Course", byRequest: request)
                }
            }
            else {
                self.status = 1
                self.message = "Sent wrong data!"
                self.data = nil
            }
            
            return try JSON(node: ["status": self.status, "message": self.message, "data": self.data == nil ? "" : self.data!])
        }
        
        /// DELETE
        /// Course by course id
        builder.post("delete", "course", ":id", "requestor", ":requestorId") { request in
            guard let id = request.parameters["id"]?.int else { throw Abort.badRequest }
            guard let course = try Course.makeQuery().find(id) else { throw Abort.notFound }
            try course.delete()
            
            self.status = 0
            self.message = "Course with code \"\(course.code)\" has been successfully deleted."
            self.data = ["course": course]
            
            try self.logActivity("Deleted course with code \"\(course.code)\"", inModule: "Course", byRequest: request)
            
            return try JSON(node: ["status": self.status, "message": self.message, "data": self.data == nil ? "" : self.data!])
        }
        
        //////////////////////
        /// CLASSES
        //////////////////////
        
        /// CREATE
        /// A new class
        builder.post("create", "class", "requestor", ":requestorId") { request in
            let rfKeys = ["code", "aClassDescription", "schedule", "venue", "courseId", "creatorId", "playerIds", "owner"]
            let neKeys = ["code", "aClassDescription", "schedule", "venue", "courseId", "creatorId", "playerIds", "owner"]
            let values = self.formDataFieldValues(fromRequest: request, withRequiredFieldKeys: rfKeys, andNonEmptyFieldKeys: neKeys)
            
            // Check if class code already exists. If it exists,
            // disallow saving of a new class; otherwise, allow
            // it.
            if values != nil {
                let code = self.string(values!["code"])
                let classes = try Class.makeQuery().filter("code", .equals, code).all()
                
                if classes.count > 0 {
                    self.status = 1
                    self.message = "Class with code \"\(code)\" already exists!"
                    self.data = nil
                }
                else {
                    let klase = try Class(node: values!.makeNode(in: Node.defaultContext))
                    try klase.save()
                    
                    // Relate class to players
                    let players = values!["playerIds"] as! String
                    let newPlayerList = players.components(separatedBy: ",")
                   
                    if newPlayerList.count > 0 {
                        let oldPlayerList = try klase.players.all()
                        
                        for p in oldPlayerList {
                            try klase.players.remove(p)
                        }
                        
                        for p in newPlayerList {
                             if let player = try User.makeQuery().find(self.intString(p)) {
                                let isAttached = try klase.players.isAttached(player)
                                if !isAttached { try klase.players.add(player) }
                            }
                        }
                    }
                    
                    self.status = 0
                    self.message = "A new class has been successfully created."
                    self.data = ["class": klase]
                    
                    try self.logActivity("Created a new class with code \"\(klase.code)\"", inModule: "Class", byRequest: request)
                }
            }
            else {
                self.status = 1
                self.message = "Sent wrong data!"
                self.data = nil
            }
            
            return try JSON(node: ["status": self.status, "message": self.message, "data": self.data == nil ? "" : self.data!])
        }
        
        /// RETRIEVE
        /// Classes for user with id
        builder.get("retrieve", "classes", ":id", "requestor", ":requestorId") { request in
            guard let id = request.parameters["id"]?.int else { throw Abort.badRequest }
            let classes = try Class.makeQuery().filter("owner", .equals, id).all()
            var classList = [[String: Any]]()
            
            for c in classes {
                let course = try c.course.get()
                let creator = try c.creator.get()
                let players = try c.players.all()
    
                let data: [String: Any] = ["id": c.id?.int ?? 0,
                                           "code": c.code,
                                           "aClassDescription": c.aClassDescription,
                                           "schedule": c.schedule,
                                           "venue": c.venue,
                                           "owner": c.owner,
                                           "dateCreated": c.dateCreated,
                                           "dateUpdated": c.dateUpdated,
                                           "course": course ?? "",
                                           "creator": creator ?? "",
                                           "players": players]
                classList.append(data)
            }
            
            try self.logActivity("Retrieved classes created by user with id \"\(id)\"", inModule: "Class", byRequest: request)
            
            return try JSON(node: ["status": 0, "message": "success", "data": ["classes": classList]])
        }
        
        /// All classes
        builder.get("retrieve", "classes", "requestor", ":requestorId") { request in
            let classes = try Class.makeQuery().all()
            var classList = [[String: Any]]()
            
            for c in classes {
                let course = try c.course.get()
                let creator = try c.creator.get()
                let players = try c.players.all()
                
                let data: [String: Any] = ["id": c.id?.int ?? 0,
                                           "code": c.code,
                                           "aClassDescription": c.aClassDescription,
                                           "schedule": c.schedule,
                                           "venue": c.venue,
                                           "owner": c.owner,
                                           "dateCreated": c.dateCreated,
                                           "dateUpdated": c.dateUpdated,
                                           "course": course ?? "",
                                           "creator": creator ?? "",
                                           "players": players]
                classList.append(data)
            }
            
            try self.logActivity("Retrieved all classes", inModule: "Class", byRequest: request)
            
            return try JSON(node: ["status": 0, "message": "success", "data": ["classes": classList]])
        }
        
        /// UPDATE
        /// Update class details for class with id
        builder.post("update", "class", ":id", "requestor", ":requestorId") { request in
            guard let id = request.parameters["id"]?.int else { throw Abort.badRequest }
            guard let klase = try Class.makeQuery().find(id) else { throw Abort.notFound }
            
            let rfKeys = ["code", "aClassDescription", "schedule", "venue", "courseId", "creatorId", "playerIds", "owner"]
            let neKeys = ["code", "aClassDescription", "schedule", "venue", "courseId", "creatorId", "playerIds"]
            let values = self.formDataFieldValues(fromRequest: request, withRequiredFieldKeys: rfKeys, andNonEmptyFieldKeys: neKeys)
            
            // Check if class code already exists. If it exists,
            // disallow saving of a new class; otherwise, allow
            // it.
            if values != nil {
                let code = self.string(values!["code"])
                let classes = try Class.makeQuery().filter("code", .equals, code).all()
                
                if classes.count > 1 {
                    self.status = 1
                    self.message = "Class with code \"\(code)\" already exists!"
                    self.data = nil
                }
                else {
                    let newClass = try Class(node: values!.makeNode(in: Node.defaultContext))
                    klase.code = newClass.code
                    klase.aClassDescription = newClass.aClassDescription
                    klase.schedule = newClass.schedule
                    klase.venue = newClass.venue
                    klase.courseId = newClass.courseId
                    klase.creatorId = newClass.creatorId
                    klase.dateUpdated = Date()
                    try klase.save()
                    
                    // Relate class to players
                    let players = values!["playerIds"] as! String
                    let newPlayerList = players.components(separatedBy: ",")
                    
                    if newPlayerList.count > 0 {
                        let oldPlayerList = try klase.players.all()
                        
                        for p in oldPlayerList {
                            try klase.players.remove(p)
                        }
                        
                        for p in newPlayerList {
                            if let player = try User.makeQuery().find(self.intString(p)) {
                                let isAttached = try klase.players.isAttached(player)
                                if !isAttached { try klase.players.add(player) }
                            }
                        }
                    }
                    
                    self.status = 0
                    self.message = "Class with code \"\(code)\" has been successfully updated."
                    self.data = ["class": klase]
                    
                    try self.logActivity("Updated class with code \"\(klase.code)\"", inModule: "Class", byRequest: request)
                }
            }
            else {
                self.status = 1
                self.message = "Sent wrong data!"
                self.data = nil
            }
            
            return try JSON(node: ["status": self.status, "message": self.message, "data": self.data == nil ? "" : self.data!])
        }
        
        /// DELETE
        /// Class by class id
        builder.post("delete", "class", ":id", "requestor", ":requestorId") { request in
            guard let id = request.parameters["id"]?.int else { throw Abort.badRequest }
            guard let klase = try Class.makeQuery().find(id) else { throw Abort.notFound }
            try klase.delete()
            
            self.status = 0
            self.message = "Class with code \"\(klase.code)\" has been successfully deleted."
            self.data = ["class": klase]
            
            try self.logActivity("Deleted class with code \"\(klase.code)\"", inModule: "Class", byRequest: request)
            
            return try JSON(node: ["status": self.status, "message": self.message, "data": self.data == nil ? "" : self.data!])
        }
        
        //////////////////////
        /// USER ACTIVITY LOG
        //////////////////////
        
        builder.get("retrieve", "activities") { request in
            let activities = try Activity.makeQuery().all()
            return try JSON(node: ["status": 0, "message": "success", "data": ["activities": activities]])
        }
        
        //////////////////////
        /// CLUES
        //////////////////////
        
        /// CREATE
        /// A new clue
        builder.post("create", "clue", "requestor", ":requestorId") { request in
//            let rfKeys = ["type", "riddle", "longitude", "latitude", "locationName", "points", "pointsOnAttempts", "clue", "owner", "choices"]
            let rfKeys = ["type", "riddle", "points", "pointsOnAttempts", "owner", "choices"]
//            let neKeys = ["type", "riddle", "longitude", "latitude", "locationName", "points", "pointsOnAttempts", "clue", "owner", "choices"]
            let neKeys = ["type", "riddle", "points", "pointsOnAttempts", "owner", "choices"]
            let values = self.formDataFieldValues(fromRequest: request, withRequiredFieldKeys: rfKeys, andNonEmptyFieldKeys: neKeys)
            
            if values != nil {
                var didRelateChoices = false
                let choiceString = self.string(values!["choices"])
                
                if let choiceData = choiceString.data(using: .utf8, allowLossyConversion: true) {
                    if let choiceList = self.json(fromData: choiceData) as? [[String: Any]], choiceList.count > 0 {
                        let clue = try Clue(node: values!.makeNode(in: Node.defaultContext))
                        try clue.save()
                        
                        if let newClue = try Clue.makeQuery().all().last {
                            for choice in choiceList {
                                let clueId = newClue.id?.int ?? 0
                                let choiceStatement = self.string(choice["choiceStatement"])
                                let isCorrect = self.intString(self.string(choice["isCorrect"]))
                                let answer = self.string(choice["answer"])
                                let encryptedAnswer = self.string(choice["encryptedAnswer"])
                                let isCaseSensitive = self.intString(self.string(choice["isCaseSensitive"]))
                                let choiceDict: [String: Any] = ["clueId": clueId, "choiceStatement": choiceStatement, "isCorrect": isCorrect, "answer": answer, "encryptedAnswer": encryptedAnswer, "isCaseSensitive": isCaseSensitive]
                                let newChoice = try Choice(node: choiceDict.makeNode(in: Node.defaultContext))
                                try newChoice.save()

                                didRelateChoices = true
                            }
                            
                            if didRelateChoices {
                                self.status = 0
                                self.message = "A new question has been successfully created."
                                self.data = ["clue": newClue]
                                try self.logActivity("Created question with id \"\(newClue.id?.int ?? 0)\"", inModule: "Clue", byRequest: request)
                            }
                        }
                    }
                }
                
                if !didRelateChoices {
                    self.status = 1
                    self.message = "Creating a new question failed!"
                    self.data = nil
                }
            }
            else {
                self.status = 1
                self.message = "Sent wrong data!"
                self.data = nil
            }
            
            return try JSON(node: ["status": self.status, "message": self.message, "data": self.data == nil ? "" : self.data!])
        }
        
        /// RETRIEVE
        /// Clues for user with id
        builder.get("retrieve", "clues", "user", ":id", "requestor", ":requestorId") { request in
            guard let id = request.parameters["id"]?.int else { throw Abort.badRequest }
            let clues = try Clue.makeQuery().filter("owner", .equals, id).all()
            var clueList = [[String: Any]]()
            
            for c in clues {
                let choices = try Choice.makeQuery().filter("clueId", .equals, c.id?.int).all()
                let data: [String: Any] = ["id": c.id?.int ?? 0,
                                           "type": c.type,
                                           "riddle": c.riddle,
//                                           "longitude": c.longitude,
//                                           "latitude": c.latitude,
//                                           "locationName": c.locationName,
                                           "points": c.points,
                                           "pointsOnAttempts": c.pointsOnAttempts,
//                                           "clue": c.clue,
                                           "owner": c.owner,
                                           "choices": choices,
                                           "dateCreated": c.dateCreated,
                                           "dateUpdated": c.dateUpdated]
                clueList.append(data)
            }
            
            
            try self.logActivity("Retrieved questions created by user with id \"\(id)\"", inModule: "Clue", byRequest: request)
            return try JSON(node: ["status": 0, "message": "success", "data": ["clues": clueList]])
        }
        
        /// UPDATE
        /// Update clue details for clue with id
        builder.post("update", "clue", ":id", "requestor", ":requestorId") { request in
            guard let id = request.parameters["id"]?.int else { throw Abort.badRequest }
            guard let clue = try Clue.makeQuery().find(id) else { throw Abort.notFound }
            
//            let rfKeys = ["type", "riddle", "longitude", "latitude", "locationName", "points", "pointsOnAttempts", "clue", "owner", "choices"]
            let rfKeys = ["type", "riddle", "points", "pointsOnAttempts", "owner", "choices"]
//            let neKeys = ["type", "riddle", "longitude", "latitude", "locationName", "points", "pointsOnAttempts", "clue", "owner", "choices"]
            let neKeys = ["type", "riddle", "points", "pointsOnAttempts", "owner", "choices"]
            let values = self.formDataFieldValues(fromRequest: request, withRequiredFieldKeys: rfKeys, andNonEmptyFieldKeys: neKeys)
            
            if values != nil {
                var didRelateChoices = false
                let choiceString = self.string(values!["choices"])
                
                if let choiceData = choiceString.data(using: .utf8, allowLossyConversion: true) {
                    if let choiceList = self.json(fromData: choiceData) as? [[String: Any]], choiceList.count > 0 {
                        let newClue = try Clue(node: values!.makeNode(in: Node.defaultContext))
                        clue.type = newClue.type
                        clue.riddle = newClue.riddle
//                        clue.longitude = newClue.longitude
//                        clue.latitude = newClue.latitude
//                        clue.locationName = newClue.locationName
                        clue.points = newClue.points
                        clue.pointsOnAttempts = newClue.pointsOnAttempts
//                        clue.clue = newClue.clue
                        clue.dateUpdated = Date()
                        try clue.save()
                        
                        let choices = try Choice.makeQuery().filter("clueId", .equals, clue.id?.int).all()
                        for c in choices { try c.delete() }
                        
                        for choice in choiceList {
                            let clueId = clue.id?.int ?? 0
                            let choiceStatement = self.string(choice["choiceStatement"])
                            let isCorrect = self.intString(self.string(choice["isCorrect"]))
                            let answer = self.string(choice["answer"])
                            let encryptedAnswer = self.string(choice["encryptedAnswer"])
                            let isCaseSensitive = self.intString(self.string(choice["isCaseSensitive"]))
                            let choiceDict: [String: Any] = ["clueId": clueId, "choiceStatement": choiceStatement, "isCorrect": isCorrect, "answer": answer, "encryptedAnswer": encryptedAnswer, "isCaseSensitive": isCaseSensitive]
                            let newChoice = try Choice(node: choiceDict.makeNode(in: Node.defaultContext))
                            try newChoice.save()
                            
                            didRelateChoices = true
                        }
                        
                        if didRelateChoices {
                            self.status = 0
                            self.message = "Question has been successfully updated."
                            self.data = ["clue": newClue]
                            try self.logActivity("Updated question with id \"\(newClue.id?.int ?? 0)\"", inModule: "Clue", byRequest: request)
                        }
                    }
                }
                
                if !didRelateChoices {
                    self.status = 1
                    self.message = "Updating question with id \"\(clue.id?.int ?? 0)\" failed!"
                    self.data = nil
                }
            }
            else {
                self.status = 1
                self.message = "Sent wrong data!"
                self.data = nil
            }
            
            return try JSON(node: ["status": self.status, "message": self.message, "data": self.data == nil ? "" : self.data!])
        }
        
        /// DELETE
        /// Clue by clue id
        builder.post("delete", "clue", ":id", "requestor", ":requestorId") { request in
            guard let id = request.parameters["id"]?.int else { throw Abort.badRequest }
            guard let clue = try Clue.makeQuery().find(id) else { throw Abort.notFound }
            try clue.delete()
            
            self.status = 0
            self.message = "Question with id \"\(clue.id?.int ?? 0)\" has been successfully deleted."
            self.data = ["clue": clue]
            
            try self.logActivity("Deleted question with id \"\(clue.id?.int ?? 0)\"", inModule: "Clue", byRequest: request)
            
            return try JSON(node: ["status": self.status, "message": self.message, "data": self.data == nil ? "" : self.data!])
        }
        
        //////////////////////
        /// TREASURES
        //////////////////////
        
        /// CREATE
        /// A new treasure
        builder.post("create", "treasure", "requestor", ":requestorId") { request in
//            let rfKeys = ["name", "treasureDescription", "claimingQuestion", "claimingAnswers", "encryptedClaimingAnswers", "isCaseSensitive", "longitude", "latitude", "locationName", "points", "imageLocalName", "model3dLocalName" ,"owner"]
            let rfKeys = ["name", "treasureDescription", "imageLocalName", "model3dLocalName" ,"owner"]
//            let neKeys = ["name", "treasureDescription", "claimingQuestion", "claimingAnswers", "encryptedClaimingAnswers", "isCaseSensitive", "longitude", "latitude", "locationName", "points", "imageLocalName", "owner"]
            let neKeys = ["name", "treasureDescription", "imageLocalName", "owner"]
            var values = self.formDataFieldValues(fromRequest: request, withRequiredFieldKeys: rfKeys, andNonEmptyFieldKeys: neKeys)
            let fileSaved1 = self.saveFile(fromRequest: request, fileKey: "imageUrl")
            let fileSaved2 = self.saveFile(fromRequest: request, fileKey: "model3dUrl")
            
            if values != nil {
                values!["imageUrl"] = fileSaved1.1
                values!["model3dUrl"] = fileSaved2.1
                
                let treasure = try Treasure(node: values!.makeNode(in: Node.defaultContext))
                try treasure.save()
                
                self.status = 0
                self.message = "A new asset has been successfully created."
                self.data = ["treasure": treasure]
                
                try self.logActivity("Created a new asset with id \"\(treasure.id?.int ?? 0)\"", inModule: "Treasure", byRequest: request)
            }
            else {
                self.status = 1
                self.message = "Sent wrong data!"
                self.data = nil
            }
            
            return try JSON(node: ["status": self.status, "message": self.message, "data": self.data == nil ? "" : self.data!])
        }
        
        /// RETRIEVE
        /// Treasures for user with id
        builder.get("retrieve", "treasures", "user", ":id", "requestor", ":requestorId") { request in
            guard let id = request.parameters["id"]?.int else { throw Abort.badRequest }
            let treasures = try Treasure.makeQuery().filter("owner", .equals, id).all()
            try self.logActivity("Retrieved assets created by user with id \"\(id)\"", inModule: "Treasure", byRequest: request)
            return try JSON(node: ["status": 0, "message": "success", "data": ["treasures": treasures]])
        }
        
        /// UPDATE
        /// Update treasure details for treasure with id
        builder.post("update", "treasure", ":id", "requestor", ":requestorId") { request in
            guard let id = request.parameters["id"]?.int else { throw Abort.badRequest }
            guard let treasure = try Treasure.makeQuery().find(id) else { throw Abort.notFound }
            
//            let rfKeys = ["name", "treasureDescription", "claimingQuestion", "claimingAnswers", "encryptedClaimingAnswers", "isCaseSensitive", "longitude", "latitude", "locationName", "points", "imageLocalName", "model3dLocalName", "owner"]
            let rfKeys = ["name", "treasureDescription", "imageLocalName", "model3dLocalName", "owner"]
//            let neKeys = ["name", "treasureDescription", "claimingQuestion", "claimingAnswers", "encryptedClaimingAnswers", "isCaseSensitive", "longitude", "latitude", "locationName", "points", "imageLocalName", "owner"]
            let neKeys = ["name", "treasureDescription", "imageLocalName", "owner"]
            var values = self.formDataFieldValues(fromRequest: request, withRequiredFieldKeys: rfKeys, andNonEmptyFieldKeys: neKeys)
            let fileSaved1 = self.saveFile(fromRequest: request, fileKey: "imageUrl")
            let fileSaved2 = self.saveFile(fromRequest: request, fileKey: "model3dUrl")
            
            if values != nil {
                values!["imageUrl"] = fileSaved1.0 ? fileSaved1.1 : treasure.imageUrl
                values!["model3dUrl"] = fileSaved2.0 ? fileSaved2.1 : treasure.model3dUrl
                
                let newTreasure = try Treasure(node: values!.makeNode(in: Node.defaultContext))
                
                if treasure.imageUrl != "" && fileSaved1.0 { self.removeFile(fromEndUrl: treasure.imageUrl) }
                if treasure.model3dUrl != "" && fileSaved2.0 { self.removeFile(fromEndUrl: treasure.model3dUrl) }

                treasure.name = newTreasure.name
                treasure.treasureDescription = newTreasure.treasureDescription
//                treasure.claimingQuestion = newTreasure.claimingQuestion
//                treasure.claimingAnswers = newTreasure.claimingAnswers
//                treasure.encryptedClaimingAnswers = newTreasure.encryptedClaimingAnswers
//                treasure.isCaseSensitive = newTreasure.isCaseSensitive
//                treasure.longitude = newTreasure.longitude
//                treasure.latitude = newTreasure.latitude
//                treasure.locationName = newTreasure.locationName
//                treasure.points = newTreasure.points
                treasure.imageUrl = newTreasure.imageUrl
                treasure.imageLocalName = newTreasure.imageLocalName
                treasure.model3dUrl = newTreasure.model3dUrl
                treasure.model3dLocalName = newTreasure.model3dLocalName
                treasure.dateUpdated = Date()
                
                try treasure.save()
                
                self.status = 0
                self.message = "Asset with id \"\(treasure.id?.int ?? 0)\" has been successfully updated."
                self.data = ["treasure": treasure]
                
                try self.logActivity("Updated asset with id \"\(id)\"", inModule: "Treasure", byRequest: request)
            }
            else {
                self.status = 1
                self.message = "Sent wrong data!"
                self.data = nil
            }
            
            return try JSON(node: ["status": self.status, "message": self.message, "data": self.data == nil ? "" : self.data!])
        }
        
        /// DELETE
        /// Treasure by treasure id
        builder.post("delete", "treasure", ":id", "requestor", ":requestorId") { request in
            guard let id = request.parameters["id"]?.int else { throw Abort.badRequest }
            guard let treasure = try Treasure.makeQuery().find(id) else { throw Abort.notFound }
            
            if treasure.imageUrl != "" { self.removeFile(fromEndUrl: treasure.imageUrl) }
            if treasure.model3dUrl != "" { self.removeFile(fromEndUrl: treasure.model3dUrl) }
            
            try treasure.delete()
            
            self.status = 0
            self.message = "Asset with id \"\(treasure.id?.int ?? 0)\" has been successfully deleted."
            self.data = ["treasure": treasure]
            
            try self.logActivity("Deleted asset with id \"\(treasure.id?.int ?? 0)\"", inModule: "Treasure", byRequest: request)
            
            return try JSON(node: ["status": self.status, "message": self.message, "data": self.data == nil ? "" : self.data!])
        }
        
        //////////////////////
        /// GAMES
        //////////////////////
        
        /// CREATE
        /// A new game
        builder.post("create", "game", "requestor", ":requestorId") { request in
            let rfKeys = ["name", "discussion", "clueIds", "treasureId", "totalPoints", "isTimeBound", "minutes", "isNoExpiration", "start", "end", "isSecure", "securityCode", "encryptedSecurityCode", "startingClueId", "startingClueName", "owner"]
            let neKeys = ["name", "discussion", "clueIds", "treasureId", "totalPoints", "isTimeBound", "minutes", "isNoExpiration", "isSecure", "startingClueId", "startingClueName", "owner"]
            let values = self.formDataFieldValues(fromRequest: request, withRequiredFieldKeys: rfKeys, andNonEmptyFieldKeys: neKeys)
            
            if values != nil {
                let game = try Game(node: values!.makeNode(in: Node.defaultContext))
                try game.save()
                
                // Relate class to clues
                let clues = values!["clueIds"] as! String
                let newClueList = clues.components(separatedBy: ",")
                
                if newClueList.count > 0 {
                    let oldClueList = try game.clues.all()
                    
                    for c in oldClueList {
                        try game.clues.remove(c)
                    }
                    
                    for c in newClueList {
                        if let clue = try Clue.makeQuery().find(self.intString(c)) {
                            let isAttached = try game.clues.isAttached(clue)
                            if !isAttached { try game.clues.add(clue) }
                        }
                    }
                }
                
                self.status = 0
                self.message = "A new lesson has been successfully created."
                self.data = ["game": game]
                
                try self.logActivity("Created a new lesson with id \"\(game.id?.int ?? 0)\"", inModule: "Game", byRequest: request)
            }
            else {
                self.status = 1
                self.message = "Sent wrong data!"
                self.data = nil
            }
            
            return try JSON(node: ["status": self.status, "message": self.message, "data": self.data == nil ? "" : self.data!])
        }
        
        /// RETRIEVE
        /// Games for user with id
        builder.get("retrieve", "games", "user", ":id", "requestor", ":requestorId") { request in
            guard let id = request.parameters["id"]?.int else { throw Abort.badRequest }
            let games = try Game.makeQuery().filter("owner", .equals, id).all()
            var gameList = [[String: Any]]()
            
            for g in games {
                let treasure = try g.treasure.get()
                let clues = try g.clues.all()
                var clueList = [[String: Any]]()
                
                for c in clues {
                    let choices = try Choice.makeQuery().filter("clueId", .equals, c.id?.int).all()
                    let choiceData: [String: Any] = ["id": c.id?.int ?? 0,
                                                     "type": c.type,
                                                     "riddle": c.riddle,
//                                                     "longitude": c.longitude,
//                                                     "latitude": c.latitude,
//                                                     "locationName": c.locationName,
                                                     "points": c.points,
                                                     "pointsOnAttempts": c.pointsOnAttempts,
//                                                     "clue": c.clue,
                                                     "owner": c.owner,
                                                     "choices": choices,
                                                     "dateCreated": c.dateCreated,
                                                     "dateUpdated": c.dateUpdated]
                    clueList.append(choiceData)
                }
                
                let gameData: [String: Any] = ["id": g.id?.int ?? 0,
                                               "name": g.name,
                                               "discussion": g.discussion,
                                               "totalPoints": g.totalPoints,
                                               "isTimeBound": g.isTimeBound,
                                               "minutes": g.minutes,
                                               "isNoExpiration": g.isNoExpiration,
                                               "start": g.start,
                                               "end": g.end,
                                               "isSecure": g.isSecure,
                                               "securityCode": g.securityCode,
                                               "encryptedSecurityCode": g.encryptedSecurityCode,
                                               "startingClueId": g.startingClueId,
                                               "startingClueName": g.startingClueName,
                                               "owner": g.owner,
                                               "dateCreated": g.dateCreated,
                                               "dateUpdated": g.dateUpdated,
                                               "treasure": treasure ?? "",
                                               "clues": clueList]
                
                gameList.append(gameData)
            }
            
            try self.logActivity("Retrieved lessons created by user with id \"\(id)\"", inModule: "Game", byRequest: request)
            
            return try JSON(node: ["status": 0, "message": "success", "data": ["games": gameList]])
        }
        
        /// UPDATE
        /// Update game details for game with id
        builder.post("update", "game", ":id", "requestor", ":requestorId") { request in
            guard let id = request.parameters["id"]?.int else { throw Abort.badRequest }
            guard let game = try Game.makeQuery().find(id) else { throw Abort.notFound }
            
            let rfKeys = ["name", "discussion", "clueIds", "treasureId", "totalPoints", "isTimeBound", "minutes", "isNoExpiration", "start", "end", "isSecure", "securityCode", "encryptedSecurityCode", "startingClueId", "startingClueName", "owner"]
            let neKeys = ["name", "discussion", "clueIds", "treasureId", "totalPoints", "isTimeBound", "minutes", "isNoExpiration", "isSecure", "startingClueId", "startingClueName", "owner"]
            let values = self.formDataFieldValues(fromRequest: request, withRequiredFieldKeys: rfKeys, andNonEmptyFieldKeys: neKeys)
            
            if values != nil {
                let newGame = try Game(node: values!.makeNode(in: Node.defaultContext))
                game.name = newGame.name
                game.discussion = newGame.discussion
                game.treasureId = newGame.treasureId
                game.totalPoints = newGame.totalPoints
                game.isTimeBound = newGame.isTimeBound
                game.minutes = newGame.minutes
                game.isNoExpiration = newGame.isNoExpiration
                game.start = newGame.start
                game.end = newGame.end
                game.isSecure = newGame.isSecure
                game.securityCode = newGame.securityCode
                game.encryptedSecurityCode = newGame.encryptedSecurityCode
                game.startingClueId = newGame.startingClueId
                game.startingClueName = newGame.startingClueName
                game.dateUpdated = Date()
                try game.save()
                
                // Relate class to clues
                let clues = values!["clueIds"] as! String
                let newClueList = clues.components(separatedBy: ",")
                
                if newClueList.count > 0 {
                    let oldClueList = try game.clues.all()
                    
                    for c in oldClueList {
                        try game.clues.remove(c)
                    }
                    
                    for c in newClueList {
                        if let clue = try Clue.makeQuery().find(self.intString(c)) {
                            let isAttached = try game.clues.isAttached(clue)
                            if !isAttached { try game.clues.add(clue) }
                        }
                    }
                }
                
                self.status = 0
                self.message = "Lesson with id \"\(game.id?.int ?? 0)\" has been successfully updated."
                self.data = ["game": game]
                
                try self.logActivity("Updated lesson with id \"\(game.id?.int ?? 0)\"", inModule: "Game", byRequest: request)
            }
            else {
                self.status = 1
                self.message = "Sent wrong data!"
                self.data = nil
            }
            
            return try JSON(node: ["status": self.status, "message": self.message, "data": self.data == nil ? "" : self.data!])
        }
        
        /// DELETE
        /// Game by game id
        builder.post("delete", "game", ":id", "requestor", ":requestorId") { request in
            guard let id = request.parameters["id"]?.int else { throw Abort.badRequest }
            guard let game = try Game.makeQuery().find(id) else { throw Abort.notFound }
            try game.delete()
            
            self.status = 0
            self.message = "Lesson with id \"\(game.id?.int ?? 0)\" has been successfully deleted."
            self.data = ["game": game]
            
            try self.logActivity("Deleted lesson with id \"\(game.id?.int ?? 0)\"", inModule: "Game", byRequest: request)
            
            return try JSON(node: ["status": self.status, "message": self.message, "data": self.data == nil ? "" : self.data!])
        }
        
        //////////////////////
        /// GAME DEPLOYMENT
        //////////////////////
        
        /// DEPLOY
        /// Deploy game
        builder.post("deploy", "game", ":gameId", "requestor", ":requestorId") { request in
            guard let gameId = request.parameters["gameId"]?.int else { throw Abort.badRequest }
            guard let requestorId = request.parameters["requestorId"]?.int else { throw Abort.badRequest }
            
            let rfKeys = ["classIds"]
            let neKeys = ["classIds"]
            let values = self.formDataFieldValues(fromRequest: request, withRequiredFieldKeys: rfKeys, andNonEmptyFieldKeys: neKeys)
            
            var deployedToClasses = [String]()
            
            if values != nil {
                let classIds = values!["classIds"] as! String
                let classes = classIds.components(separatedBy: ",")
                
                for classId in classes {
                    let gameDeploymentValues: [String: Any] = ["gameId": gameId, "classId": classId, "deployedBy": requestorId, "dateDeployed": Date()]
                    
                    let deployedGames = try GameDeployment.makeQuery().and { andGroup in
                        try andGroup.filter("gameId", gameId)
                        try andGroup.filter("classId", classId)
                        }.all()
                    
                    if deployedGames.count == 0 {
                        let deployedGame = try GameDeployment(node: gameDeploymentValues.makeNode(in: Node.defaultContext))
                        deployedToClasses.append(classId)
                        try deployedGame.save()
                    }
                }
        
                self.status = 0
                self.message = "Lesson with id \"\(gameId)\" has been successfully deployed!"
                self.data = nil
                
                try self.logActivity("Deployed lesson with id \"\(gameId)\" to \(deployedToClasses.count > 1 ? "classes" : "class") with \(deployedToClasses.count > 1 ? "ids" : "id") \(deployedToClasses)", inModule: "Game", byRequest: request)
            }
            else {
                self.status = 1
                self.message = "Sent wrong data!"
                self.data = nil
            }
            
            return try JSON(node: ["status": self.status, "message": self.message, "data": self.data == nil ? "" : self.data!])
        }
        
        /// RETRIEVE
        /// Classes where game was deployed
        builder.get("retrieve", "classIds", "game", ":id", "requestor", ":requestorId") { request in
            guard let id = request.parameters["id"]?.int else { throw Abort.badRequest }
            let deployedGames = try GameDeployment.makeQuery().filter("gameId", .equals, id).all()
            
            var classIds = [Int]()
            
            for dg in deployedGames {
                let classId = dg.classId
                classIds.append(classId)
            }
            
            try self.logActivity("Retrieved class ids where by game with id \"\(id)\" was deployed", inModule: "Game", byRequest: request)
            return try JSON(node: ["status": 0, "message": "success", "data": ["classIds": classIds]])
        }
        
        /// UNDEPLOY
        /// Delete deployed game
        builder.post("undeploy", "game", ":gameId", "requestor", ":requestorId") { request in
            guard let gameId = request.parameters["gameId"]?.int else { throw Abort.badRequest }
            
            let rfKeys = ["classIds"]
            let neKeys = ["classIds"]
            let values = self.formDataFieldValues(fromRequest: request, withRequiredFieldKeys: rfKeys, andNonEmptyFieldKeys: neKeys)
            
            var undeployedToClasses = [String]()
            
            if values != nil {
                let classIds = values!["classIds"] as! String
                let classes = classIds.components(separatedBy: ",")
                
                for classId in classes {
                    let deployedGames = try GameDeployment.makeQuery().and { andGroup in
                        try andGroup.filter("gameId", gameId)
                        try andGroup.filter("classId", classId)
                        }.all()
                    
                    for dg in deployedGames {
                        undeployedToClasses.append(classId)
                        try dg.delete()
                    }
                }
                
                self.status = 0
                self.message = "Game with id \"\(gameId)\" has been successfully undeployed!"
                self.data = nil
                
                try self.logActivity("Undeployed game with id \"\(gameId)\" from \(undeployedToClasses.count > 1 ? "classes" : "class") with \(undeployedToClasses.count > 1 ? "ids" : "id") \(undeployedToClasses)", inModule: "Game", byRequest: request)
            }
            else {
                self.status = 1
                self.message = "Sent wrong data!"
                self.data = nil
            }
            
            return try JSON(node: ["status": self.status, "message": self.message, "data": self.data == nil ? "" : self.data!])
        }
        
        //////////////////////
        /// GAME-CLASS
        //////////////////////
        
        /// RETRIEVE
        /// Classes where player is enrolled to
        builder.get("retrieve", "classes", "player", ":id", "requestor", ":requestorId") { request in
            guard let id = request.parameters["id"]?.int else { throw Abort.badRequest }
            
            var classList = [[String: Any]]()
            let player = try User.makeQuery().filter("id", .equals, id).all().last
            
            if let p = player {
                let classes = try p.classes.all()
    
                for c in classes {
                    let course = try c.course.get()
                    let creator = try c.creator.get()
                    let players = try c.players.all()
                    
                    let data: [String: Any] = ["id": c.id?.int ?? 0,
                                               "code": c.code,
                                               "aClassDescription": c.aClassDescription,
                                               "schedule": c.schedule,
                                               "venue": c.venue,
                                               "owner": c.owner,
                                               "dateCreated": c.dateCreated,
                                               "dateUpdated": c.dateUpdated,
                                               "course": course ?? "",
                                               "creator": creator ?? "",
                                               "players": players]
                    classList.append(data)
                }
            }
            
            try self.logActivity("Retrieved classes where player with id \"\(id)\" are enrolled to", inModule: "Player-Class", byRequest: request)
            return try JSON(node: ["status": 0, "message": "success", "data": ["classes": classList]])
        }
        
        /// RETRIEVE
        /// Games for class with id
        builder.get("retrieve", "games", "class", ":id", "requestor", ":requestorId") { request in
            guard let id = request.parameters["id"]?.int else { throw Abort.badRequest }
            
            let deployedGames = try GameDeployment.makeQuery().filter("classId", .equals, id).all()
            var gameList = [[String: Any]]()
            
            for dg in deployedGames {
                let gameId = dg.gameId
                let game = try Game.makeQuery().filter("id", .equals, gameId).all().last
                
                if let g = game {
                    let treasure = try g.treasure.get()
                    let clues = try g.clues.all()
                    var clueList = [[String: Any]]()
                    
                    for c in clues {
                        let choices = try Choice.makeQuery().filter("clueId", .equals, c.id?.int).all()
                        let choiceData: [String: Any] = ["id": c.id?.int ?? 0,
                                                         "type": c.type,
                                                         "riddle": c.riddle,
//                                                         "longitude": c.longitude,
//                                                         "latitude": c.latitude,
//                                                         "locationName": c.locationName,
                                                         "points": c.points,
                                                         "pointsOnAttempts": c.pointsOnAttempts,
//                                                         "clue": c.clue,
                                                         "owner": c.owner,
                                                         "choices": choices,
                                                         "dateCreated": c.dateCreated,
                                                         "dateUpdated": c.dateUpdated]
                        clueList.append(choiceData)
                    }
                    
                    let gameData: [String: Any] = ["id": g.id?.int ?? 0,
                                                   "name": g.name,
                                                   "discussion": g.discussion,
                                                   "totalPoints": g.totalPoints,
                                                   "isTimeBound": g.isTimeBound,
                                                   "minutes": g.minutes,
                                                   "isNoExpiration": g.isNoExpiration,
                                                   "start": g.start,
                                                   "end": g.end,
                                                   "isSecure": g.isSecure,
                                                   "securityCode": g.securityCode,
                                                   "encryptedSecurityCode": g.encryptedSecurityCode,
                                                   "startingClueId": g.startingClueId,
                                                   "startingClueName": g.startingClueName,
                                                   "owner": g.owner,
                                                   "dateCreated": g.dateCreated,
                                                   "dateUpdated": g.dateUpdated,
                                                   "treasure": treasure ?? "",
                                                   "clues": clueList]
                    
                    gameList.append(gameData)
                }
            }
            
            try self.logActivity("Retrieved games for class with id \"\(id)\"", inModule: "Player-Game", byRequest: request)
            return try JSON(node: ["status": 0, "message": "success", "data": ["games": gameList]])
        }
        
        //////////////////////
        /// SIDEKICK
        //////////////////////
        
        /// CREATE
        /// A new sidekick
        builder.post("create", "sidekick", "requestor", ":requestorId") { request in
            let rfKeys = ["type", "name", "level", "points", "ownedBy"]
            let neKeys = ["type", "name", "level", "points", "ownedBy"]
            let values = self.formDataFieldValues(fromRequest: request, withRequiredFieldKeys: rfKeys, andNonEmptyFieldKeys: neKeys)

            if values != nil {
                let sidekick = try Sidekick(node: values!.makeNode(in: Node.defaultContext))
                try sidekick.save()
                
                self.status = 0
                self.message = "A new sidekick has been successfully created."
                self.data = ["sidekick": sidekick]
                
                try self.logActivity("Created a new sidekick with id \"\(sidekick.id?.int ?? 0)\"", inModule: "Player-Sidekick", byRequest: request)
            }
            else {
                self.status = 1
                self.message = "Sent wrong data!"
                self.data = nil
            }
            
            return try JSON(node: ["status": self.status, "message": self.message, "data": self.data == nil ? "" : self.data!])
        }
        
        /// RETRIEVE
        /// Sidekick assigned to player
        builder.get("retrieve", "sidekick", "player", ":id", "requestor", ":requestorId") { request in
            guard let id = request.parameters["id"]?.int else { throw Abort.badRequest }
            let sidekick = try Sidekick.makeQuery().filter("ownedBy", .equals, id).all().last
            try self.logActivity("Retrieved sidekick of player with id \"\(id)\"", inModule: "Player-Sidekick", byRequest: request)
            return try JSON(node: ["status": 0, "message": "success", "data": ["count": sidekick != nil ? 1 : 0, "sidekick": sidekick as Any]])
        }
        
        /// UPDATE
        /// Update sidekick details for sidekick with id
        builder.post("update", "sidekick", ":id", "requestor", ":requestorId") { request in
            guard let id = request.parameters["id"]?.int else { throw Abort.badRequest }
            guard let sidekick = try Sidekick.makeQuery().find(id) else { throw Abort.notFound }
            
            let rfKeys = ["type", "name", "level", "points", "ownedBy"]
            let neKeys = ["type", "name", "level", "points", "ownedBy"]
            let values = self.formDataFieldValues(fromRequest: request, withRequiredFieldKeys: rfKeys, andNonEmptyFieldKeys: neKeys)
            
            if values != nil {
                let newSidekick = try Sidekick(node: values!.makeNode(in: Node.defaultContext))
                sidekick.type = newSidekick.type
                sidekick.name = newSidekick.name
                sidekick.level = newSidekick.level
                sidekick.points = newSidekick.points
                sidekick.ownedBy = newSidekick.ownedBy
                sidekick.dateUpdated = Date()
                
                try sidekick.save()
                
                self.status = 0
                self.message = "Sidekick with id \"\(sidekick.id?.int ?? 0)\" has been successfully updated."
                self.data = ["sidekick": sidekick]
                
                try self.logActivity("Updated sidekick with id \"\(id)\"", inModule: "Player-Sidekick", byRequest: request)
            }
            else {
                self.status = 1
                self.message = "Sent wrong data!"
                self.data = nil
            }
            
            return try JSON(node: ["status": self.status, "message": self.message, "data": self.data == nil ? "" : self.data!])
        }
        
        /// DELETE
        /// Sidekick by sidekick id
        builder.post("delete", "sidekick", ":id", "requestor", ":requestorId") { request in
            guard let id = request.parameters["id"]?.int else { throw Abort.badRequest }
            guard let sidekick = try Sidekick.makeQuery().find(id) else { throw Abort.notFound }
            try sidekick.delete()
            
            self.status = 0
            self.message = "Sidekick with id \"\(sidekick.id?.int ?? 0)\" has been successfully deleted."
            self.data = ["sidekick": sidekick]
            
            try self.logActivity("Deleted sidekick with id \"\(sidekick.id?.int ?? 0)\"", inModule: "Player-Sidekick", byRequest: request)
            return try JSON(node: ["status": self.status, "message": self.message, "data": self.data == nil ? "" : self.data!])
        }
        
        //////////////////////
        /// RESULTS
        //////////////////////
        
        /// SUBMIT
        /// Assemble game result data and save to database
        builder.post("submit", "game", "result", "requestor", ":requestorId") { request in
            let rfKeys = ["clues", "treasure"]
            let neKeys = ["clues", "treasure"]
            let values = self.formDataFieldValues(fromRequest: request, withRequiredFieldKeys: rfKeys, andNonEmptyFieldKeys: neKeys)
            
            if values != nil {
                let clueString = self.string(values!["clues"])
                let treasureString = self.string(values!["treasure"])
                var ownedBy = 0
                var totalPoints = 0
                
                if let clueData = clueString.data(using: .utf8, allowLossyConversion: true),
                    let treasureData = treasureString.data(using: .utf8, allowLossyConversion: true) {
                    if let clueList = self.json(fromData: clueData) as? [[String: String]], clueList.count > 0,
                        let treasureList = self.json(fromData: treasureData) as? [[String: String]], treasureList.count > 0 {
                        
                        var classIdString = ""
                        var gameIdString = ""
                        var playerIdString = ""
                        
                        for clue in clueList {
                            let classId = self.intString(self.string(clue["classId"]))
                            let gameId = self.intString(self.string(clue["gameId"]))
                            let clueId = self.intString(self.string(clue["clueId"]))
                            let clueName = self.string(clue["clueName"])
                            let playerId = self.intString(self.string(clue["playerId"]))
                            let playerName = self.string(clue["playerName"])
                            let numberOfAttempts = self.intString(self.string(clue["numberOfAttempts"]))
                            let points = self.intString(self.string(clue["points"]))
                            let gameClueDict: [String: Any] = ["classId": classId, "gameId": gameId, "clueId": clueId, "clueName": clueName, "playerId": playerId, "playerName": playerName, "numberOfAttempts": numberOfAttempts, "points": points]
                            
                            let grcs = try GameResultClue.makeQuery().and { andGroup in
                                try andGroup.filter("classId", classId)
                                try andGroup.filter("gameId", gameId)
                                try andGroup.filter("clueId", clueId)
                                try andGroup.filter("playerId", playerId)
                                }.all()
                            
                            for grc in grcs { try grc.delete() }
                            let newGameClue = try GameResultClue(node: gameClueDict.makeNode(in: Node.defaultContext))
                            try newGameClue.save()
                            
                            ownedBy = playerId
                            totalPoints = totalPoints + points
 
                            classIdString = "\(classId)"
                            gameIdString = "\(gameId)"
                            playerIdString = "\(playerId)"
                        }
                        
                        for treasure in treasureList {
                            let classId = self.intString(self.string(treasure["classId"]))
                            let gameId = self.intString(self.string(treasure["gameId"]))
                            let treasureId = self.intString(self.string(treasure["treasureId"]))
                            let treasureName = self.string(treasure["treasureName"])
                            let playerId = self.intString(self.string(treasure["playerId"]))
                            let playerName = self.string(treasure["playerName"])
                            let numberOfAttempts = self.intString(self.string(treasure["numberOfAttempts"]))
                            let points = self.intString(self.string(treasure["points"]))
                            let gameTreasureDict: [String: Any] = ["classId": classId, "gameId": gameId, "treasureId": treasureId, "treasureName": treasureName, "playerId": playerId, "playerName": playerName, "numberOfAttempts": numberOfAttempts, "points": points]
                            
                            let grts = try GameResultTreasure.makeQuery().and { andGroup in
                                try andGroup.filter("classId", classId)
                                try andGroup.filter("gameId", gameId)
                                try andGroup.filter("treasureId", treasureId)
                                try andGroup.filter("playerId", playerId)
                                }.all()
                            
                            for grt in grts { try grt.delete() }
                            let newGameTreasure = try GameResultTreasure(node: gameTreasureDict.makeNode(in: Node.defaultContext))
                            try newGameTreasure.save()
                            
                            ownedBy = playerId
                            totalPoints = totalPoints + points
                            
                            classIdString = "\(classId)"
                            gameIdString = "\(gameId)"
                            playerIdString = "\(playerId)"
                        }
                        
                        if clueList.count > 0 && treasureList.count > 0 {
                            if let sidekick = try Sidekick.makeQuery().filter("ownedBy", .equals, ownedBy).all().last {
                                let totalAccPoints = sidekick.points + totalPoints
                                let level = totalAccPoints / self.sidekickLevelDivisor
                                sidekick.points = totalAccPoints
                                sidekick.level = level > 0 ? level : 1
                                sidekick.dateUpdated = Date()
                                try sidekick.save()
                            }
                            
                            self.status = 0
                            self.message = "Game result has been successfully submitted."
                            self.data = ["game": ["clues": clueList, "treasure": treasureList]]
                            try self.logActivity("Player with id \"\(playerIdString)\" just finished playing game with id \"\(gameIdString)\" deployed in class with id \"\(classIdString)\"", inModule: "Player-Result", byRequest: request)
                        }
                        else {
                            self.status = 1
                            self.message = "Sent wrong data!"
                            self.data = nil
                        }
                    }
                    else {
                        self.status = 1
                        self.message = "Sent wrong data!"
                        self.data = nil
                    }
                }
                else {
                    self.status = 1
                    self.message = "Sent wrong data!"
                    self.data = nil
                }
            }
            else {
                self.status = 1
                self.message = "Sent wrong data!"
                self.data = nil
            }

            return try JSON(node: ["status": self.status, "message": self.message, "data": self.data == nil ? "" : self.data!])
        }
        
        /// RETRIEVE
        /// Assemble game results and sent to requestor
        builder.get("retrieve", "game", "result", ":classId", ":gameId", "requestor", ":requestorId") { request in
            guard let classId = request.parameters["classId"]?.int else { throw Abort.badRequest }
            guard let gameId = request.parameters["gameId"]?.int else { throw Abort.badRequest }

            if let game = try Game.makeQuery().filter("id", .equals, gameId).all().last {
                let clues = try game.clues.all()
                var clueIds = [Int]()
                var clueNames = ""

                for clue in clues {
                    if !clueIds.contains(clue.id?.int ?? 0) {
                        clueIds.append(clue.id?.int ?? 0)
                        clueNames = "\(clueNames == "" ? "" : "\(clueNames)")<td nowrap><font size=\"100\">\(clue.riddle)</br>(PTS/ATT)</font></td>"
                    }
                }

                var treasureId = 0
                var treasureName = ""
                if let t = try game.treasure.get() {
                    treasureId = t.id?.int ?? 0
                    treasureName = "<td nowrap><font size=\"100\">\(t.name)</br>(PTS/ATT)</font></td>"
                }
                
                if let klase = try Class.makeQuery().filter("id", .equals, classId).all().last {
                    let players = try klase.players.all()
                    var playerIds = [Int]()
                    var playerNames = [String]()
                    
                    for player in players {
                        if !playerIds.contains(player.id?.int ?? 0) {
                            playerIds.append(player.id?.int ?? 0)
                            let name = player.middleName == "" ? "\(player.firstName) \(player.lastName)" : "\(player.firstName) \(player.middleName) \(player.lastName)"
                            playerNames.append(name)
                        }
                    }
                
                    var rankingPoints = [Int]()
                    
                    for playerId in playerIds {
                        var tp = 0
                        
                        for clueId in clueIds {
                            let grc = try GameResultClue.makeQuery().and { andGroup in
                                try andGroup.filter("classId", classId)
                                try andGroup.filter("gameId", gameId)
                                try andGroup.filter("clueId", clueId)
                                try andGroup.filter("playerId", playerId)
                                }.all().last
                            
                            if let c = grc { tp = tp + c.points }
                            else { tp = tp + 0 }
                        }

                        let grt = try GameResultTreasure.makeQuery().and { andGroup in
                            try andGroup.filter("classId", classId)
                            try andGroup.filter("gameId", gameId)
                            try andGroup.filter("treasureId", treasureId)
                            try andGroup.filter("playerId", playerId)
                            }.all().last
                        
                        if let t = grt { tp = tp + t.points }
                        else { tp = tp + 0 }
                        rankingPoints.append(tp)
                    }
                    
                    let sortedRankingPoints = rankingPoints.sorted(by: >)
                    
                    var tds = [String]()
                    var counter = 0
                    var overAllAttemptsCounter = [[Int]]()
                    var overAllPointsCounter = [[Int]]()
                    var accTreasurePoints = 0
                    var actAttempts = 0
                    var accTotalPoints = 0
                    
                    for playerId in playerIds {
                        var tdContent = ""
                        var totalPoints = 0
                        var datePlayed: Date? = nil
                        var attemptsCounter = [Int]()
                        var pointsCounter = [Int]()
                        
                        for clueId in clueIds {
                            let grc = try GameResultClue.makeQuery().and { andGroup in
                                try andGroup.filter("classId", classId)
                                try andGroup.filter("gameId", gameId)
                                try andGroup.filter("clueId", clueId)
                                try andGroup.filter("playerId", playerId)
                                }.all().last
                            
                            if let c = grc {
                                tdContent = "\(tdContent == "" ? "" : "\(tdContent)")<td nowrap><font size=\"100\">\(c.points) / \(c.numberOfAttempts)</font></td>"
                                totalPoints = totalPoints + c.points
                                attemptsCounter.append(c.numberOfAttempts)
                                pointsCounter.append(c.points)
                            }
                            else {
                                tdContent = "\(tdContent == "" ? "" : "\(tdContent)")<td nowrap><font size=\"100\"></font></td>"
                                totalPoints = totalPoints + 0
                                attemptsCounter.append(0)
                                pointsCounter.append(0)
                            }
                        }
                        
                        overAllAttemptsCounter.append(attemptsCounter)
                        overAllPointsCounter.append(pointsCounter)
                        
                        let grt = try GameResultTreasure.makeQuery().and { andGroup in
                            try andGroup.filter("classId", classId)
                            try andGroup.filter("gameId", gameId)
                            try andGroup.filter("treasureId", treasureId)
                            try andGroup.filter("playerId", playerId)
                            }.all().last
                        
                        if let t = grt {
//                            tdContent = "\(tdContent == "" ? "" : "\(tdContent)")<td nowrap><font size=\"100\">\(t.points) / \(t.numberOfAttempts)</font></td>"
//                            totalPoints = totalPoints + t.points
                            datePlayed = t.dateCreated
//                            actAttempts = actAttempts + t.numberOfAttempts
//                            accTreasurePoints = accTreasurePoints + t.points
                        }
                        else {
//                            tdContent = "\(tdContent == "" ? "" : "\(tdContent)")<td nowrap><font size=\"100\"></font></td>"
//                            totalPoints = totalPoints + 0
//                            actAttempts = actAttempts + 0
//                            accTreasurePoints = accTreasurePoints + 0
                        }
                        
                        var dateString = ""
                        
                        if let date = datePlayed {
                            let formattedDate = self.date(fromString: "\(date)", format: "yyyy-MM-dd HH:mm:ss +zzzz")
                            dateString = self.string(fromDate: formattedDate, format: "dd-MM-yyyy hh:mm:ss a")
                        }
                        
                        let rank = sortedRankingPoints.index(of: totalPoints)
                        
                        tdContent = tdContent == "" || tdContent == "<td nowrap><font size=\"100\"></font></td>" ? "<td nowrap><font size=\"100\"></font></td><td nowrap><font size=\"100\"></font></td>" : tdContent
                        tdContent = "<tr><td nowrap><font size=\"100\">\(playerNames[counter])</font></td>\(tdContent)<td nowrap><font size=\"100\">\(totalPoints)</font></td><td nowrap><font size=\"100\">\(dateString)</font></td><td nowrap><font size=\"100\">\((rank ?? -1) + 1)</font></td></tr>"
                        tds.append(tdContent)
                        
                        counter = counter + 1
                        accTotalPoints = accTotalPoints + totalPoints
                    }
                    
                    /// Compute average points and attempts per clue
                    var i = 0
                    var acaContent = ""
                    
                    while i < clueIds.count {
                        var accPoints = 0
                        var accAttempts = 0
                        for ap in overAllPointsCounter { accPoints = accPoints + ap[i] }
                        for ac in overAllAttemptsCounter { accAttempts = accAttempts + ac[i] }
                        let avecPointsString = String(format: "%.1f", (Double(accPoints) / Double(playerIds.count)))
                        let avecAttemptsString = String(format: "%.1f", (Double(accAttempts) / Double(playerIds.count)))
                        acaContent = "\(acaContent == "" ? "" : "\(acaContent)")<td nowrap><font size=\"100\"><b>\(avecPointsString) / \(avecAttemptsString)</b></font></td>"
                        i = i + 1
                    }
                    
                    /// Compute average attempts for treasure
                    var ataContent = ""
                    
                    if treasureName != "" {
                        let avetPointsString = String(format: "%.1f", (Double(accTreasurePoints) / Double(playerIds.count)))
                        let avetAttemptsString = String(format: "%.1f", (Double(actAttempts) / Double(playerIds.count)))
                        ataContent = "<td nowrap><font size=\"100\"><b>\(avetPointsString) / \(avetAttemptsString)</b></font></td>"
                    }
                    
                    /// Compute average of accumulated total points
                    let accTotalPointsString = String(format: "%.1f", (Double(accTotalPoints) / Double(playerIds.count)))
                    
                    /// Assemble html string
                    clueNames = clueNames == "" ? "<td nowrap><font size=\"100\">No Associated Clues</font></td>" : clueNames
                    treasureName = treasureName == "" ? "<td nowrap><font size=\"100\">No Associated Treasure</font></td>" : treasureName
                    acaContent = acaContent == "" ? "<td nowrap><font size=\"100\"></font></td>" : acaContent
                    ataContent = ataContent == "" ? "<td nowrap><font size=\"100\"></font></td>" : ataContent
                    
//                    let htContent = "<tr bgcolor=\"blue\"><td nowrap><font size=\"100\">Players</font></td>\(clueNames)\(treasureName)<td nowrap><font size=\"100\">Total Points</font></td><td nowrap><font size=\"100\">Date Played</font></td><td nowrap><font size=\"100\">Rank</font></td></tr>"
                    let htContent = "<tr bgcolor=\"blue\"><td nowrap><font size=\"100\">Students</font></td>\(clueNames)<td nowrap><font size=\"100\">Total Points</font></td><td nowrap><font size=\"100\">Date Played</font></td><td nowrap><font size=\"100\">Rank</font></td></tr>"
                    let preHtml = "<html><head><title>Game Results</title></head><body style=\"background-color:white;margin:25;padding:0\"><center><table border=\"1\" style=\"text-align:center\">"
                    var body = ""
                    for td in tds { body = "\(body == "" ? "" : "\(body)")\(td)" }
//                    let ftContent = "<tr bgcolor=\"orange\"><td nowrap><font size=\"100\"><b>Average</b></font></td>\(acaContent)\(ataContent)<td nowrap><font size=\"100\"><b>\(accTotalPointsString)</b></font></td><td nowrap><font size=\"100\"><b>NA</b></font></td><td nowrap><font size=\"100\"><b>NA</b></font></td></tr>"
                                        let ftContent = "<tr bgcolor=\"orange\"><td nowrap><font size=\"100\"><b>Average</b></font></td>\(acaContent)<td nowrap><font size=\"100\"><b>\(accTotalPointsString)</b></font></td><td nowrap><font size=\"100\"><b>NA</b></font></td><td nowrap><font size=\"100\"><b>NA</b></font></td></tr>"
                    let endHtml = "</table></center></body></html>"
                    
                    /// Assemble result
                    self.status = 0
                    self.message = "Game result has been successfully retrieve."
                    self.data = ["gameResult": "\(preHtml)\(htContent)\(body)\(ftContent)\(endHtml)"]
                    
                    try self.logActivity("Retrieved result of game with id \"\(gameId)\" deployed in class with id \"\(classId)\"", inModule: "Player-Result", byRequest: request)
                    return try JSON(node: ["status": self.status, "message": self.message, "data": self.data ?? ""])
                }
                else {
                    self.status = 1
                    self.message = "Class where game with id \"\(gameId)\" is deployed is no longer available."
                    self.data = nil
                    return try JSON(node: ["status": self.status, "message": self.message, "data": self.data ?? ""])
                }
            }
            else {
                self.status = 1
                self.message = "Game with id \"\(gameId)\" is no longer available."
                self.data = nil
                return try JSON(node: ["status": self.status, "message": self.message, "data": self.data ?? ""])
            }
        }
        
        /// RETRIEVE
        /// Details of each game that has been played by a player
        builder.get("retrieve", "games", "class", ":classId", "player", ":playerId", "requestor", ":requestorId") { request in
            guard let classId = request.parameters["classId"]?.int else { throw Abort.badRequest }
            guard let playerId = request.parameters["playerId"]?.int else { throw Abort.badRequest }
            
            var games = [[String: Any]]()
            
            let grts = try GameResultTreasure.makeQuery().and { andGroup in
                try andGroup.filter("classId", classId)
                try andGroup.filter("playerId", playerId)
                }.all()
            
            for grt in grts {
                var gameId = 0
                var imageUrl = ""
                if let game = try Game.makeQuery().filter("id", .equals, grt.gameId).all().last { gameId = game.id?.int ?? 0 }
                if let treasure = try Treasure.makeQuery().filter("id", .equals, grt.treasureId).all().last { imageUrl = treasure.imageUrl }
                let dict: [String: Any] = ["gameId": gameId, "imageUrl": imageUrl]
                games.append(dict)
            }
            
            self.status = 0
            self.message = "Details of each game that has been played by a player with id \"\(playerId)\" have been successfully retrieved."
            self.data = ["games": games]
            
            try self.logActivity("Retrieved details of each game deployed in class with id \"\(classId)\" by player with id \"\(playerId)\"", inModule: "Player-Result", byRequest: request)
            return try JSON(node: ["status": self.status, "message": self.message, "data": self.data ?? ""])
        }
        
        /// RETRIEVE
        /// Treasures unlocked by player withid
        builder.get("retrieve", "unlocked", "treasures", "player", ":playerId", "requestor", ":requestorId") { request in
            guard let playerId = request.parameters["playerId"]?.int else { throw Abort.badRequest }
            let treasures = try GameResultTreasure.makeQuery().and { andGroup in
                try andGroup.filter("playerId", playerId)
                try andGroup.filter("points", .notEquals, 0)
                }.all()
            
            var treasureList = [Treasure]()
            
            for treasure in treasures {
                let id = treasure.treasureId
                if let tr = try Treasure.makeQuery().filter("id", .equals, id).all().last { treasureList.append(tr) }
            }
            
            try self.logActivity("Retrieved treasures unlocked by player with id \"\(playerId)\"", inModule: "Player-Treasure", byRequest: request)
            return try JSON(node: ["status": 0, "message": "success", "data": ["treasures": treasureList]])
        }
        
        /// RETRIEVE
        /// List of players for ranking
        builder.get("retrieve", "players", "requestor", ":requestorId") { request in
            let sidekicks = try Sidekick.makeQuery().all()
            var players = [[String: Any]]()
            
            for sidekick in sidekicks {
                let playerId = sidekick.ownedBy
                
                if let player = try User.makeQuery().filter("id", .equals, playerId).all().last {
                    let middleName = player.middleName
                    let playerName = middleName == "" ? "\(player.firstName) \(player.lastName)" : "\(player.firstName) \(middleName) \(player.lastName)"
                    let dict: [String: Any] = ["playerId": playerId, "playerImageUrl": player.imageUrl, "playerName": playerName, "points": sidekick.points, "level": sidekick.level]
                    players.append(dict)
                }
            }
            
            try self.logActivity("Retrieved list of players of ranking", inModule: "Player-Ranking", byRequest: request)
            return try JSON(node: ["status": 0, "message": "success", "data": ["players": players]])
        }
        
        /// RETRIEVE
        /// Game Success Rate
        builder.get("retrieve", "game", "success", "rate", "user", ":id") { request in
            guard let id = request.parameters["id"]?.int else { throw Abort.badRequest }
            let deployedGames = try GameDeployment.makeQuery().filter("deployedBy", .equals, id).all()
            
            var gposList = [[String: Any]]()
            
            for game in deployedGames {
                if let laro = try Game.makeQuery().filter("id", .equals, game.gameId).all().last {
                    var points = 0
                    
                    if let klase = try Class.makeQuery().filter("id", .equals, game.classId).all().last {
                        let gameResultClues = try GameResultClue.makeQuery().and { andGroup in
                            try andGroup.filter("classId", klase.id?.int ?? 0)
                            try andGroup.filter("gameId", game.id?.int ?? 0)
                            }.all()
                        
                        let gameResultTreasures = try GameResultTreasure.makeQuery().and { andGroup in
                            try andGroup.filter("classId", klase.id?.int ?? 0)
                            try andGroup.filter("gameId", game.id?.int ?? 0)
                            }.all()
                        
                        for gameResultClue in gameResultClues { points = points + gameResultClue.points }
                        for gameResultTreasure in gameResultTreasures { points = points + gameResultTreasure.points }
                        
                        let numberOfPlayers = try klase.players.count()
                        let gpos = ((Double(points) / Double(numberOfPlayers)) / Double(laro.totalPoints)) * 100
                        let gposData: [String: Any] = ["gameId": laro.id?.int ?? 0, "gameName": laro.name, "gpos": gpos]

                        gposList.append(gposData)
                    }
                }
            }
            
            return try JSON(node: ["status": 0, "message": "success", "data": ["gpos": gposList]])
        }
    }
    
    // MARK: - Save File in Public Directory
    
    fileprivate func saveFile(fromRequest request: Request, fileKey: String) -> (Bool, String) {
        guard let fd = request.formData else { return (false, "") }
        guard let field = fd[fileKey] else { return (false, "") }
        guard let filename = field.filename else { return (false, "") }
        
        let fileExtension = (filename as NSString).pathExtension
        let path = workingDirectory()
        let pathComponent = "Public/files"
        let newFileName = "\(UUID().uuidString).\(fileExtension)"
        
        let saveURL = URL(fileURLWithPath: path).appendingPathComponent(pathComponent, isDirectory: true).appendingPathComponent(newFileName, isDirectory: false)
        
        do {
            let data = Data(bytes: field.part.body)
            try data.write(to: saveURL)
            return (true, "files/\(newFileName)")
        }
        catch {
            print("ERROR: Can't save file!")
            return (false, "")
        }
    }
    
    // MARK: - Remove File from Public Directory
    
    fileprivate func removeFile(fromEndUrl endUrl: String) {
        let path = workingDirectory()
        let pathComponent = "Public/\(endUrl)"
        let url = URL(fileURLWithPath: path).appendingPathComponent(pathComponent, isDirectory: false)
        let fileManager = FileManager.default
        
        do {
            try fileManager.removeItem(at: url)
        }
        catch {
            print("ERROR: Can't delete file!")
        }
    }
    
    // MARK: - Assemble Values of Required Fields
    
    fileprivate func formDataFieldValues(fromRequest request: Request, withRequiredFieldKeys rfKeys: [String], andNonEmptyFieldKeys neKeys: [String]?) -> [String: Any]? {
        // [1]
        // Check if the request contains valid form data.
        guard let fd = request.formData else {
            self.status = 1
            self.message = "Request contains invalid form data."
            self.data = nil
            return nil
        }
        
        // [2]
        // Assemble value of each field of form data
        // which key is required.
        var fdValues = [String: Any]()
        
        for k in fd.keys {
            if rfKeys.contains(k), let f = fd[k] {
                fdValues[k] = String(bytes: f.part.body)
            }
        }
        
        // [3]
        // Check if form data constitutes all required
        // field keys. It assembles all values of all
        // required fields. It also checks if nonempty
        // fields contain values.
        var vlValues = [String: Any]()
        
        for k in rfKeys {
            guard let vl = fdValues[k] as? String else {
                self.status = 1
                self.message = "The form data does not contain \(k) as one of its required field keys."
                self.data = nil
                return nil
            }
            
            if neKeys != nil, neKeys!.contains(k) && vl == "" {
                self.status = 1
                self.message = "\(k) is a required field. It cannot be empty."
                self.data = nil
                return nil
            }
            
            vlValues[k] = vl
        }
        
        // [4]
        // Return assembled values of all required fields
        // of form data
        return vlValues
    }
    
    // MARK: - Log User's Activity
    
    fileprivate func logActivity(_ activity: String, inModule module: String, byUserWithId userId: Int) throws {
        let log: [String: Any] = ["userId": userId, "module": module, "activity": activity, "date": Date()]
        let activity = try Activity(node: log.makeNode(in: Node.defaultContext))
        try activity.save()
    }
    
    fileprivate func logActivity(_ activity: String, inModule module: String, byRequest request: Request) throws {
        guard let requestorId = request.parameters["requestorId"]?.int else { return }
        let log: [String: Any] = ["userId": requestorId, "module": module, "activity": activity, "date": Date()]
        let activity = try Activity(node: log.makeNode(in: Node.defaultContext))
        try activity.save()
    }
    
    // MARK: - Utility Methods
    
    fileprivate func intString(_ string: String) -> Int {
        guard let i = Int(string) else { return 0 }
        return i
    }
    
    func doubleString(_ string: String) -> Double {
        guard let d = Double(string) else { return 0.0 }
        return d
    }
    
    fileprivate func json(fromData data: Data) -> Any? {
        do { return try JSONSerialization.jsonObject(with: data, options: .mutableContainers) }
        catch let error { print("Error parsing response data: \(error)") }
        return nil
    }
    
    func string(_ value: Any?) -> String {
        guard let v = value else { return "" }
        let newValue = "\(v)"
        if (newValue == "null") || (newValue == "<null>") || (newValue == "(null)") { return "" }
        return newValue
    }
    
    fileprivate func date(fromString string: String, format: String) -> Date {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.dateFormat = format
        dateFormatter.timeZone = TimeZone.autoupdatingCurrent
        
        guard let date = dateFormatter.date(from: string) else {
            print("ERROR: Can't create date!")
            return Date()
        }
        
        return date
    }
    
    fileprivate func string(fromDate date: Date, format: String) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.dateFormat = format
        dateFormatter.timeZone = TimeZone.autoupdatingCurrent
        return dateFormatter.string(from: date)
    }
    
}

