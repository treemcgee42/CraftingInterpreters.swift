
protocol LoxCallable {
    func arity() -> Int
    func call(interpreter: Interpreter, arguments: [Optional<Any>]) throws -> Optional<Any>
}
