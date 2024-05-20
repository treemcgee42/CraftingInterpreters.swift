
class LoxClass: CustomStringConvertible, LoxCallable {
    var name: String
    var methods: [String:LoxFunction]

    init(name: String, methods: [String:LoxFunction]) {
        self.name = name
        self.methods = methods
    }

    func findMethod(name: String) -> LoxFunction? {
        if let method = methods[name] {
            return method
        }
        
        return nil
    }

    var description: String {
        return name
    }

    func call(interpreter: Interpreter,
              arguments: [Optional<Any>]) throws -> Optional<Any> {
        let instance = LoxInstance(klass: self)
        if let initializer = findMethod(name: "init") {
            _ = try initializer
              .bind(instance: instance)
              .call(interpreter: interpreter, arguments: arguments)
        }
        
        return instance
    }

    func arity() -> Int {
        if let initializer = findMethod(name: "init") {
            return initializer.arity()
        }

        return 0
    }
}
