import SwiftyJSON

public struct ServerMeal {
    public let id: String?
    public let name: String
    public let photo: String
    public let rating: Double

    public init(id: String?, name: String, photo: String, rating: Double) {
        self.id = id
        self.name = name
        self.photo = photo
        self.rating = rating
    }

    public init(json: JSON) throws {
        // Required properties
        guard json["name"].exists() else {
            throw ModelError.requiredPropertyMissing(name: "name")
        }
        guard let name = json["name"].string else {
            throw ModelError.propertyTypeMismatch(name: "name", type: "string", value: json["name"].description, valueType: String(describing: json["name"].type))
        }
        self.name = name
        guard json["photo"].exists() else {
            throw ModelError.requiredPropertyMissing(name: "photo")
        }
        guard let photo = json["photo"].string else {
            throw ModelError.propertyTypeMismatch(name: "photo", type: "string", value: json["photo"].description, valueType: String(describing: json["photo"].type))
        }
        self.photo = photo
        guard json["rating"].exists() else {
            throw ModelError.requiredPropertyMissing(name: "rating")
        }
        guard let rating = json["rating"].number else {
            throw ModelError.propertyTypeMismatch(name: "rating", type: "number", value: json["rating"].description, valueType: String(describing: json["rating"].type))
        }
        self.rating = Double(rating)

        // Optional properties
        if json["id"].exists() &&
           json["id"].type != .string {
            throw ModelError.propertyTypeMismatch(name: "id", type: "string", value: json["id"].description, valueType: String(describing: json["id"].type))
        }
        self.id = json["id"].string

        // Check for extraneous properties
        if let jsonProperties = json.dictionary?.keys {
            let properties: [String] = ["id", "name", "photo", "rating"]
            for jsonPropertyName in jsonProperties {
                if !properties.contains(where: { $0 == jsonPropertyName }) {
                    throw ModelError.extraneousProperty(name: jsonPropertyName)
                }
            }
        }
    }

    public func settingID(_ newId: String?) -> ServerMeal {
      return ServerMeal(id: newId, name: name, photo: photo, rating: rating)
    }

    public func updatingWith(json: JSON) throws -> ServerMeal {
        if json["id"].exists() &&
           json["id"].type != .string {
            throw ModelError.propertyTypeMismatch(name: "id", type: "string", value: json["id"].description, valueType: String(describing: json["id"].type))
        }
        let id = json["id"].string ?? self.id

        if json["name"].exists() &&
           json["name"].type != .string {
            throw ModelError.propertyTypeMismatch(name: "name", type: "string", value: json["name"].description, valueType: String(describing: json["name"].type))
        }
        let name = json["name"].string ?? self.name

        if json["photo"].exists() &&
           json["photo"].type != .string {
            throw ModelError.propertyTypeMismatch(name: "photo", type: "string", value: json["photo"].description, valueType: String(describing: json["photo"].type))
        }
        let photo = json["photo"].string ?? self.photo

        if json["rating"].exists() &&
           json["rating"].type != .number {
            throw ModelError.propertyTypeMismatch(name: "rating", type: "number", value: json["rating"].description, valueType: String(describing: json["rating"].type))
        }
        let rating = json["rating"].number.map { Double($0) } ?? self.rating

        return ServerMeal(id: id, name: name, photo: photo, rating: rating)
    }

    public func toJSON() -> JSON {
        var result = JSON([
            "name": JSON(name),
            "photo": JSON(photo),
            "rating": JSON(rating),
        ])
        if let id = id {
            result["id"] = JSON(id)
        }

        return result
    }
}
