
class LoxFunction: LoxCallable {
    private var declaration: FunctionStmt
    private var closure: Environment

    init(declaration: FunctionStmt, closure: Environment) {
        self.declaration = declaration
        self.closure = closure
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
            return returnValue.value
        }
        return nil
    }
}
