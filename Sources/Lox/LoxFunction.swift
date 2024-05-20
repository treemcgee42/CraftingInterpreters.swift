
class LoxFunction: LoxCallable {
    private var declaration: FunctionStmt
    private var closure: Environment
    private var isInitializer: Bool

    init(declaration: FunctionStmt, closure: Environment,
         isInitializer: Bool) {
        self.declaration = declaration
        self.closure = closure
        self.isInitializer = isInitializer
    }

    func bind(instance: LoxInstance) -> LoxFunction {
        let environment = Environment(enclosing: closure)
        environment.define(name: "this", value: instance)
        return LoxFunction(declaration: declaration,
                           closure: environment,
                           isInitializer: self.isInitializer)
    }

    func description() -> String {
        return "<fn \(declaration.name.lexeme)>"
    }

    func arity() -> Int {
        return declaration.params.count
    }

    func call(interpreter: Interpreter, arguments: [Optional<Any>]) throws -> Optional<Any> {
        let environment = Environment(enclosing: self.closure)
        for i in 0..<declaration.params.count {
            environment.define(name: String(declaration.params[i].lexeme),
                               value: arguments[i])
        }

        do {
            try interpreter.executeBlock(statements: declaration.body,
                                         environment: environment)
        } catch let returnValue as Return {
            if self.isInitializer {
                return try closure.getAt(distance: 0, name: "this")
            }
            return returnValue.value
        }

        if isInitializer {
            return try closure.getAt(distance: 0, name: "this")
        }
        return nil
    }
}
