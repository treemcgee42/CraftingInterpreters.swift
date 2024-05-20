
import Foundation

class ClockNativeFunction: LoxCallable {
    func arity() -> Int {
        return 0
    }

    func call(interpreter: Interpreter, arguments: [Optional<Any>]) -> Optional<Any> {
        return Double(Date().timeIntervalSince1970)
    }

    func description() -> String {
        return "<native fn>"
    }
}
