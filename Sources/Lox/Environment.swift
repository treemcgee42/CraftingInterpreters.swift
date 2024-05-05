
class Environment {
    var enclosing: Environment?
    var values: [String:Optional<Any>] = [:]

    init() {
        self.enclosing = nil
    }

    init(enclosing: Environment) {
        self.enclosing = enclosing
    }
    
    func get(name: Token) throws -> Optional<Any> {
        if let to_return = values[String(name.lexeme)] {
            return to_return
        }

        if let nonnil_enclosing = self.enclosing {
            return try nonnil_enclosing.get(name: name)
        }
        
        throw RuntimeError(token: name,
                           msg: "Undefined variable '\(name.lexeme)'.")
    }

    func assign(name: Token, value: Optional<Any>) throws {
        if values[String(name.lexeme)] != nil {
            values[String(name.lexeme)] = value
            return
        }

        if let nonnil_enclosing = self.enclosing {
            try nonnil_enclosing.assign(name: name, value: value)
            return
        }

        throw RuntimeError(token: name,
                           msg: "Undefined variable '\(name.lexeme)'.")
    }
    
    func define(name: String, value: Optional<Any>) {
        values[name] = value
    }
}
