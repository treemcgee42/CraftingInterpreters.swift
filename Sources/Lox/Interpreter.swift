
class Interpreter: ExprVisitor, StmtVisitor {
    typealias ExprR = Optional<Any>
    typealias StmtR = ()?

    var globals: Environment
    private var environment: Environment

    init() {
        globals = Environment()
        environment = globals

        globals.define(name: "clock", value: ClockNativeFunction())
    }
    
    func interpret(statements: [Stmt?]) {
        do {
            for statement in statements {
                try execute(stmt: statement)
            }
        } catch let re as RuntimeError {
            Lox.runtimeError(re)
        } catch {
            fatalError("Unexpected exception \(error)")
        }
    }
    
    func visitLiteralExpr(_ expr: LiteralExpr) -> Optional<Any> {
        return expr.value
    }

    func visitLogicalExpr(_ expr: LogicalExpr) throws -> Optional<Any> {
        let left = try evaluate(expr.left)

        if expr.op.type == .or_ {
            if isTruthy(left) {
                return left
            }
        } else {
            if !isTruthy(left) {
                return left
            }
        }

        return try evaluate(expr.right)
    }

    func visitUnaryExpr(_ expr: UnaryExpr) throws -> Optional<Any> {
        let right = try evaluate(expr.right)

        switch expr.op.type {
        case .bang:
            return !isTruthy(right)
        case .minus:
            try checkNumberOperand(op: expr.op, operand: right)
            return -(right as! Double)
        default:
            break
        }

        return nil
    }

    func visitVariableExpr(_ expr: VariableExpr) throws -> Optional<Any> {
        return try environment.get(name: expr.name)
    }

    private func checkNumberOperand(op: Token, operand: Optional<Any>) throws {
        if operand is Double {
            return
        }

        throw RuntimeError(token: op, msg: "Operand must be a number.")
    }

    private func checkNumberOperands(op: Token,
                                     left: Optional<Any>,
                                     right: Optional<Any>) throws {
        if (left is Double) && (right is Double) {
            return
        }

        throw RuntimeError(token: op, msg: "Operands must be numbers.")
    }

    private func isTruthy(_ object: Optional<Any>) -> Bool {
        if let nonNilObject = object {
            if nonNilObject is Bool {
                return nonNilObject as! Bool
            }

            return true
        } else {
            return false
        }
    }

    private func isEqual(_ lhs: Optional<Any>, _ rhs: Optional<Any>) -> Bool {
        switch (lhs, rhs) {
        case (nil, nil):
            return true
        case (nil, _), (_, nil):
            return false
        case let (left as Int, right as Int):
            return left == right
        case let (left as Double, right as Double):
            return left == right
        case let (left as String, right as String):
            return left == right
        case let (left as Bool, right as Bool):
            return left == right
            // Add more cases for other specific types you want to handle
        default:
            return false
        }
    }

    private func stringify(_ obj: Optional<Any>) -> String {
        if (obj == nil) {
            return "nil"
        }

        if obj is Double {
            var text = String(obj as! Double)
            if text.hasSuffix(".0") {
                text = String(text.dropLast(2))
            }
            return text
        }

        return String(describing: obj!)
    }

    func visitGroupingExpr(_ expr: GroupingExpr) throws -> Optional<Any> {
        return try evaluate(expr.expression)
    }

    private func evaluate(_ expr: Expr) throws -> Optional<Any> {
        return try expr.accept(self)
    }

    private func execute(stmt: Stmt?) throws {
        if let nonnil_stmt = stmt {
            _ = try nonnil_stmt.accept(self)
        }
    }

    func executeBlock(statements: [Stmt?], environment: Environment) throws {
        let previous = self.environment
        defer {
            self.environment = previous
        }
        
        self.environment = environment
        for statement in statements {
            try execute(stmt: statement)
        }
    }

    func visitBlockStmt(_ stmt: BlockStmt) throws -> ()? {
        try executeBlock(statements: stmt.statements,
                         environment: Environment(enclosing: self.environment))
        return nil
    }

    func visitBinaryExpr(_ expr: BinaryExpr) throws -> Optional<Any> {
        let left = try evaluate(expr.left)
        let right = try evaluate(expr.right)

        switch expr.op.type {
        case .greater:
            try checkNumberOperands(op: expr.op, left: left, right: right)
            return (left as! Double) > (right as! Double)
        case .greaterEqual:
            try checkNumberOperands(op: expr.op, left: left, right: right)
            return (left as! Double) >= (right as! Double)
        case .less:
            try checkNumberOperands(op: expr.op, left: left, right: right)
            return (left as! Double) < (right as! Double)
        case .lessEqual:
            try checkNumberOperands(op: expr.op, left: left, right: right)
            return (left as! Double) <= (right as! Double)
        case .bangEqual:
            return !isEqual(left, right)
        case .equalEqual:
            return isEqual(left, right)
        case .minus:
            try checkNumberOperands(op: expr.op, left: left, right: right)
            return (left as! Double) - (right as! Double)
        case .plus:
            if (left is Double) && (right is Double) {
                return (left as! Double) + (right as! Double)
            }
            if (left is Substring || left is String)
                 && (right is Substring || right is String) {
                var l: String
                if left is Substring {
                    l = String(left as! Substring)
                } else {
                    l = left as! String
                }
                var r: String
                if right is Substring {
                    r = String(right as! Substring)
                } else {
                    r = right as! String
                }
                return l + r
            }
            let l = String(describing: left)
            let r = String(describing: right)
            throw RuntimeError(token: expr.op,
                               msg: """
                                 Operands to '+' must be two numbers or two strings.
                                 Got (\(l), \(r)).
                                 """)
        case .slash:
            try checkNumberOperands(op: expr.op, left: left, right: right)
            return (left as! Double) / (right as! Double)
        case .star:
            try checkNumberOperands(op: expr.op, left: left, right: right)
            return (left as! Double) * (right as! Double)
        default:
            break;
        }

        // Unreachable.
        return nil;
    }

    func visitCallExpr(_ expr: CallExpr) throws -> Optional<Any> {
        let callee = try evaluate(expr.callee)

        var arguments: [Optional<Any>] = []
        for argument in expr.arguments {
            arguments.append(try evaluate(argument))
        }

        if !(callee is LoxCallable) {
            throw RuntimeError(token: expr.paren,
                               msg: "Can only call functions and classes.")
        }
        let function = callee as! LoxCallable

        if arguments.count != function.arity() {
            throw RuntimeError(token: expr.paren,
                               msg: """
                                 Expected \(function.arity()) arguments
                                 but got \(arguments.count).
                                 """)
        }
        return try function.call(interpreter: self, arguments: arguments)
    }

    func visitExpressionStmt(_ stmt: ExpressionStmt) throws -> ()? {
        _ = try evaluate(stmt.expression);
        return nil
    }

    func visitFunctionStmt(_ stmt: FunctionStmt) throws -> ()? {
        let function = LoxFunction(declaration: stmt, closure: self.environment)
        environment.define(name: String(stmt.name.lexeme), value: function)
        return nil
    }

    func visitIfStmt(_ stmt: IfStmt) throws -> ()? {
        if isTruthy(try evaluate(stmt.condition)) {
            try execute(stmt: stmt.thenBranch)
        } else if stmt.elseBranch != nil {
            try execute(stmt: stmt.elseBranch)
        }
        return nil
    }

    func visitPrintStmt(_ stmt: PrintStmt) throws -> ()? {
        let value = try evaluate(stmt.expression)
        print(stringify(value))
        return nil
    }

    func visitReturnStmt(_ stmt: ReturnStmt) throws -> ()? {
        var value: Optional<Any> = nil
        if let stmtValue = stmt.value {
            value = try evaluate(stmtValue)
        }

        throw Return(value: value)
    }

    func visitVarStmt(_ stmt: VarStmt) throws -> ()? {
        var value: Optional<Any> = nil
        if let initializer_expr = stmt.initializer {
            value = try evaluate(initializer_expr)
        }

        environment.define(name: String(stmt.name.lexeme), value: value)
        return nil
    }

    func visitWhileStmt(_ stmt: WhileStmt) throws -> ()? {
        while isTruthy(try evaluate(stmt.condition)) {
            try execute(stmt: stmt.body)
        }
        return nil
    }

    func visitAssignExpr(_ expr: AssignExpr) throws -> Optional<Any> {
        let value = try evaluate(expr.value)
        try environment.assign(name: expr.name, value: value)
        return value
    }
}
