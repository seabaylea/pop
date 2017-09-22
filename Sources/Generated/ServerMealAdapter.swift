public protocol ServerMealAdapter {
    func findAll(onCompletion: @escaping ([ServerMeal], Error?) -> Void)
    func create(_ model: ServerMeal, onCompletion: @escaping (ServerMeal?, Error?) -> Void)
    func deleteAll(onCompletion: @escaping (Error?) -> Void)

    func findOne(_ maybeID: String?, onCompletion: @escaping (ServerMeal?, Error?) -> Void)
    func update(_ maybeID: String?, with model: ServerMeal, onCompletion: @escaping (ServerMeal?, Error?) -> Void)
    func delete(_ maybeID: String?, onCompletion: @escaping (ServerMeal?, Error?) -> Void)
}
