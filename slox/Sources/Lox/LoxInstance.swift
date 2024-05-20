
class LoxInstance: CustomStringConvertible {
    private var klass: LoxClass
    private var fields: [String:Optional<Any>] = [:]

    init(klass: LoxClass) {
        self.klass = klass
    }

    func get(name: Token) throws -> Optional<Any> {
        if let value = fields[String(name.lexeme)] {
            return value
        }

        if let method = klass.findMethod(name: String(name.lexeme)) {
            return method.bind(instance: self)
        }
        
        throw RuntimeError(token: name,
                           msg: "Undefined property '\(name.lexeme)'.")

    }

    func set(name: Token, value: Optional<Any>) {
        fields[String(name.lexeme)] = value
    }

    var description: String {
        return "\(klass.name) instance"
    }
}
