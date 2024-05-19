
private enum FunctionType {
    case none_
    case function
}

class Resolver: ExprVisitor, StmtVisitor {
    typealias ExprR = ()?
    typealias StmtR = ()?

    var interpreter: Interpreter
    var scopes: [[String:Bool]] = []
    private var currentFunction: FunctionType = .none_

    init(interpreter: Interpreter) {
        self.interpreter = interpreter
    }

    func resolve(stmts: [Stmt?]) {
        for statement in stmts {
            resolve(stmt: statement)
        }
    }

    func visitBlockStmt(_ stmt: BlockStmt) -> ()? {
        beginScope()
        resolve(stmts: stmt.statements)
        endScope()
        return nil
    }

    func visitExpressionStmt(_ stmt: ExpressionStmt) -> ()? {
        resolve(expr: stmt.expression)
        return nil
    }

    func visitFunctionStmt(_ stmt: FunctionStmt) -> ()? {
        declare(name: stmt.name)
        define(name: stmt.name)

        resolveFunction(function: stmt, functionType: .function)
        return nil
    }

    func visitIfStmt(_ stmt: IfStmt) -> ()? {
        resolve(expr: stmt.condition)
        resolve(stmt: stmt.thenBranch)
        if let elseBranch = stmt.elseBranch {
            resolve(stmt: elseBranch)
        }
        return nil
    }

    func visitPrintStmt(_ stmt: PrintStmt) -> ()? {
        resolve(expr: stmt.expression)
        return nil
    }

    func visitReturnStmt(_ stmt: ReturnStmt) -> ()? {
        if self.currentFunction == .none_ {
            Lox.error(token: stmt.keyword,
                      msg: "Can't return from top-level code.")
        }
        
        if let value = stmt.value {
            resolve(expr: value)
        }
        return nil
    }

    func visitVarStmt(_ stmt: VarStmt) -> ()? {
        declare(name: stmt.name)
        if let initializer = stmt.initializer {
            resolve(expr: initializer)
        }
        define(name: stmt.name)
        return nil
    }

    func visitWhileStmt(_ stmt: WhileStmt) -> ()? {
        resolve(expr: stmt.condition)
        resolve(stmt: stmt.body)
        return nil
    }

    func visitAssignExpr(_ expr: AssignExpr) -> ()? {
        resolve(expr: expr.value)
        resolveLocal(expr: expr, name: expr.name)
        return nil
    }

    func visitBinaryExpr(_ expr: BinaryExpr) -> ()? {
        resolve(expr: expr.left)
        resolve(expr: expr.right)
        return nil
    }

    func visitCallExpr(_ expr: CallExpr) -> ()? {
        resolve(expr: expr.callee)
        for argument in expr.arguments {
            resolve(expr: argument)
        }
        return nil
    }

    func visitGroupingExpr(_ expr: GroupingExpr) -> ()? {
        resolve(expr: expr.expression)
        return nil
    }

    func visitLiteralExpr(_ expr: LiteralExpr) -> ()? {
        return nil
    }

    func visitLogicalExpr(_ expr: LogicalExpr) -> ()? {
        resolve(expr: expr.left)
        resolve(expr: expr.right)
        return nil
    }

    func visitUnaryExpr(_ expr: UnaryExpr) -> ()? {
        resolve(expr: expr.right)
        return nil
    }

    func visitVariableExpr(_ expr: VariableExpr) -> ()? {
        if let lastScope = scopes.last,
           let thisVarScope = lastScope[String(expr.name.lexeme)],
           !thisVarScope {
           Lox.error(token: expr.name,
                     msg: "Can't read local variable in its own initializer.")
        }

        resolveLocal(expr: expr, name: expr.name)
        return nil
    }

    func resolve(stmt: Stmt?) {
        if let stmt = stmt {
            try! stmt.accept(self)
        }
    }

    func resolve(expr: Expr) {
        try! expr.accept(self)
    }

    private func resolveFunction(function: FunctionStmt,
                                 functionType: FunctionType) {
        let enclosingFunction = self.currentFunction
        self.currentFunction = functionType
        
        beginScope()
        for param in function.params {
            declare(name: param)
            define(name: param)
        }
        resolve(stmts: function.body)
        endScope()

        self.currentFunction = enclosingFunction
    }

    private func beginScope() {
        self.scopes.append([:])
    }

    private func endScope() {
        _ = self.scopes.removeLast()
    }

    private func declare(name: Token) {
        if scopes.count == 0 {
            return
        }

        if scopes.last![String(name.lexeme)] != nil {
            Lox.error(token: name,
                      msg: "Already a variable with this name in this scope.")
        }

        (scopes[scopes.count-1])[String(name.lexeme)] = false
    }

    private func define(name: Token) {
        if scopes.count == 0 {
            return
        }

        (scopes[scopes.count-1])[String(name.lexeme)] = true
    }

    private func resolveLocal(expr: Expr, name: Token) {
        for i in stride(from: scopes.count - 1, through: 0, by: -1) {
            if scopes[i][String(name.lexeme)] != nil {
                interpreter.resolve(expr: expr, depth: scopes.count-1-i)
                return
            }
        }
    }
}
