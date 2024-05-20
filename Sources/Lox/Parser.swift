
class Parser {
    private struct ParseError: Error {}
    
    private var tokens: [Token]
    private var current: Int = 0

    init(tokens: [Token]) {
        self.tokens = tokens
    }

    func parse() -> [Stmt?] {
        do {
            var statements: [Stmt?] = []
            while (!isAtEnd()) {
                statements.append(try declaration())
            }
            return statements;
        } catch {
            // TODO
            return []
        }
    }

    private func expression() throws -> Expr {
        return try assignment()
    }

    private func declaration() throws -> Stmt? {
        do {
            if match([.class_]) {
                return try classDeclaration()
            }
            if match([.fun]) {
                return try function(kind: "function")
            }
            if match([.var_]) {
                return try varDeclaration()
            }
            return try statement()
        } catch is ParseError {
            synchronize()
            return nil
        }
    }

    private func classDeclaration() throws -> Stmt {
        let name = try consume(type: .identifier, msg: "Expect class name.");
        _ = try consume(type: .leftBrace, msg: "Expect '{' before class body.")

        var methods: [FunctionStmt] = []
        while !check(.rightBrace) && !isAtEnd() {
            methods.append(try function(kind: "method"))
        }

        _ = try consume(type: .rightBrace, msg: "Expect '}' after class body.")
        return ClassStmt(name: name, methods: methods)
    }

    private func statement() throws -> Stmt {
        if match([.for_]) {
            return try forStatement()
        }
        if match([.if_]) {
            return try ifStatement()
        }
        if match([.print]) {
            return try printStatement()
        }
        if match([.return_]) {
            return try returnStatement()
        }
        if match([.while_]) {
            return try whileStatement()
        }
        if match([.leftBrace]) {
            return BlockStmt(statements: try block())
        }

        return try expressionStatement()
    }

    private func forStatement() throws -> Stmt {
        _ = try consume(type: .leftParen, msg: "Expect '(' after 'for'.")

        var initializer: Stmt?
        if match([.semicolon]) {
            initializer = nil
        } else if match([.var_]) {
            initializer = try varDeclaration()
        } else {
            initializer = try expressionStatement()
        }

        var condition: Expr? = nil
        if !check(.semicolon) {
            condition = try expression()
        }
        _ = try consume(type: .semicolon, msg: "Expect ';' after loop condition.")

        var increment: Expr? = nil
        if !check(.rightParen) {
            increment = try expression()
        }
        _ = try consume(type: .rightParen, msg: "Expect ')' after for clauses.")

        var body = try statement()

        // --- desugar
        
        if let increment = increment {
            body = BlockStmt(statements: [body, ExpressionStmt(expression: increment)])
        }
        
        if condition == nil {
            condition = LiteralExpr(value: true)
        }
        body = WhileStmt(condition: condition!, body: body)
        
        if let initializer = initializer {
            body = BlockStmt(statements: [initializer, body])
        }

        return body
    }

    private func ifStatement() throws -> Stmt {
        _ = try consume(type: .leftParen, msg: "Expect '(' after 'if'.")
        let condition = try expression()
        _ = try consume(type: .rightParen, msg: "Expect ')' after if condition.")

        let thenBranch = try statement()
        var elseBranch: Stmt? = nil
        if match([.else_]) {
            elseBranch = try statement()
        }

        return IfStmt(condition: condition, thenBranch: thenBranch,
                      elseBranch: elseBranch)
    }

    private func printStatement() throws -> Stmt {
        let value = try expression()
        _ = try consume(type: .semicolon, msg: "Expect ';' after value.")
        return PrintStmt(expression: value)
    }

    private func returnStatement() throws -> Stmt {
        let keyword = previous()
        var value: Expr? = nil
        if !check(.semicolon) {
            value = try expression()
        }

        _ = try consume(type: .semicolon, msg: "Expect ';' after return value.")
        return ReturnStmt(keyword: keyword, value: value)
    }

    private func varDeclaration() throws -> Stmt {
        let name = try consume(type: .identifier, msg: "Expect variable name.")

        var initializer: Expr? = nil
        if match([.equal]) {
            initializer = try expression()
        }

        _ = try consume(type: .semicolon, msg: "Expect ';' after variable declaration.")
        return VarStmt(name: name, initializer: initializer)
    }

    private func whileStatement() throws -> Stmt {
        _ = try consume(type: .leftParen, msg: "Expect '(' after 'while'.")
        let condition = try expression()
        _ = try consume(type: .rightParen, msg: "Expect ')' after condition.")
        let body = try statement()

        return WhileStmt(condition: condition, body: body)
    }

    private func expressionStatement() throws -> Stmt {
        let expr = try expression()
        _ = try consume(type: .semicolon, msg: "Expect ';' after expression.")
        return ExpressionStmt(expression: expr)
    }

    private func function(kind: String) throws -> FunctionStmt {
        let name = try consume(type: .identifier,
                               msg: "Expect \(kind) name.")
        _ = try consume(type: .leftParen,
                        msg: "Expect '(' after \(kind) name.")
        var parameters: [Token] = []
        if !check(.rightParen) {
            while true {
                if parameters.count >= 255 {
                    _ = error(token: peek(),
                              msg: "Can't have more than 255 parameters.")
                }
                parameters.append(try consume(type: .identifier,
                                              msg: "Expect parameter name."))

                if !match([.comma]) {
                    break
                }
            }
        }

        _ = try consume(type: .rightParen, msg: "Expect ')' after parameters.")

        _ = try consume(type: .leftBrace, msg: "Expect '{' before \(kind) body.")
        let body = try block()

        return FunctionStmt(name: name, params: parameters, body: body)
    }

    private func block() throws -> [Stmt?] {
        var statements: [Stmt?] = []

        while (!check(.rightBrace)) && (!isAtEnd()) {
            statements.append(try declaration())
        }

        _ = try consume(type: .rightBrace, msg: "Expect '}' after block.")
        return statements
    }

    private func assignment() throws -> Expr {
        let expr = try or()

        if match([.equal]) {
            let equals = previous()
            let value = try assignment()

            if expr is VariableExpr {
                let name = (expr as! VariableExpr).name
                return AssignExpr(name: name, value: value)
            } else if expr is GetExpr {
                let get = expr as! GetExpr
                return SetExpr(object: get.object, name: get.name,
                               value: value)
            }

            _ = error(token: equals, msg: "Invalid assignment target")
        }

        return expr
    }

    private func or() throws -> Expr {
        var expr = try and()

        while match([.or_]) {
            let op = previous()
            let right = try and()
            expr = LogicalExpr(left: expr, op: op, right: right)
        }

        return expr
    }

    private func and() throws -> Expr {
        var expr = try equality()

        while match([.and_]) {
            let op = previous()
            let right = try equality()
            expr = LogicalExpr(left: expr, op: op, right: right)
        }

        return expr
    }

    private func equality() throws -> Expr {
        var expr = try comparision()

        while match([.bangEqual, .equalEqual]) {
            let op = previous()
            let right = try comparision()
            expr = BinaryExpr(left: expr, op: op, right: right)
        }

        return expr
    }

    private func comparision() throws -> Expr {
        var expr = try term()

        while match([.greater, .greaterEqual, .less, .lessEqual]) {
            let op = previous()
            let right = try term()
            expr = BinaryExpr(left: expr, op: op, right: right)
        }

        return expr
    }

    private func term() throws -> Expr {
        var expr = try factor()

        while match([.minus, .plus]) {
            let op = previous()
            let right = try factor()
            expr = BinaryExpr(left: expr, op: op, right: right)
        }

        return expr
    }

    private func factor() throws -> Expr {
        var expr = try unary()

        while match([.slash, .star]) {
            let op = previous()
            let right = try unary()
            expr = BinaryExpr(left: expr, op: op, right: right)
        }

        return expr
    }

    private func unary() throws -> Expr {
        if match([.bang, .minus]) {
            let op = previous()
            let right = try unary()
            return UnaryExpr(op: op, right: right)
        }

        return try call()
    }

    private func finishCall(callee: Expr) throws -> Expr {
        var arguments: [Expr] = []
        if !check(.rightParen) {
            while true {
                if arguments.count >= 255 {
                    _ = error(token: peek(),
                              msg: "Can't have more than 255 arguments.")
                }
                arguments.append(try expression())
                if !match([.comma]) {
                    break;
                }
            }
        }

        let paren = try consume(type: .rightParen,
                                msg: "Expect ')' after aguments.")

        return CallExpr(callee: callee, paren: paren, arguments: arguments)
    }

    private func call() throws -> Expr {
        var expr = try primary()

        while true {
            if match([.leftParen]) {
                expr = try finishCall(callee: expr)
            } else if match([.dot]) {
                let name = try consume(type: .identifier,
                                       msg: "Expect property name after '.'.")
                expr = GetExpr(object: expr, name: name)
            } else {
                break;
            }
        }

        return expr
    }

    private func primary() throws -> Expr {
        if match([.false_]) {
            return LiteralExpr(value: false)
        }
        if match([.true_]) {
            return LiteralExpr(value: true)
        }
        if match([.nil_]) {
            return LiteralExpr(value: nil)
        }

        if match([.number, .string]) {
            return LiteralExpr(value: previous().literal)
        }

        if match([.this]) {
            return ThisExpr(keyword: previous())
        }

        if match([.identifier]) {
            return VariableExpr(name: previous())
        }

        if match([.leftParen]) {
            let expr = try expression()
            _ = try consume(type: .rightParen, msg: "Expect ')' after expression.")
            return GroupingExpr(expression: expr)
        }

        throw error(token: peek(), msg: "Expect expression.")
    }

    private func match(_ types: [TokenType]) -> Bool {
        for type in types {
            if check(type) {
                _ = advance()
                return true
            }
        }

        return false
    }

    private func consume(type: TokenType, msg: String) throws -> Token {
        if check(type) {
            return advance()
        }

        throw error(token: peek(), msg: msg)
    }

    private func check(_ type: TokenType) -> Bool {
        if isAtEnd() {
            return false
        }
        return peek().type == type
    }

    private func advance() -> Token {
        if !isAtEnd() {
            current += 1;
        }
        return previous()
    }

    private func isAtEnd() -> Bool {
        return peek().type == .eof
    }

    private func peek() -> Token {
        return tokens[current]
    }

    private func previous() -> Token {
        return tokens[current-1]
    }

    private func error(token: Token, msg: String) -> ParseError {
        Lox.error(token: token, msg: msg)
        return ParseError()
    }

    private func synchronize() {
        _ = advance()

        while !isAtEnd() {
            if previous().type == .semicolon {
                return
            }

            switch peek().type {
            case .class_, .fun, .var_, .for_, .if_, .while_, .print, .return_:
                return
            default:
                break
            }

            _ = advance()
        }
    }
                
}
