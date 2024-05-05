
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
            if match([.var_]) {
                return try varDeclaration()
            }
            return try statement()
        } catch is ParseError {
            synchronize()
            return nil
        }
    }

    private func statement() throws -> Stmt {
        if match([.print]) {
            return try printStatement()
        }
        if match([.leftBrace]) {
            return BlockStmt(statements: try block())
        }

        return try expressionStatement()
    }

    private func printStatement() throws -> Stmt {
        let value = try expression()
        _ = try consume(type: .semicolon, msg: "Expect ';' after value.")
        return PrintStmt(expression: value)
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

    private func expressionStatement() throws -> Stmt {
        let expr = try expression()
        _ = try consume(type: .semicolon, msg: "Expect ';' after expression.")
        return ExpressionStmt(expression: expr)
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
        let expr = try equality()

        if match([.equal]) {
            let equals = previous()
            let value = try assignment()

            if expr is VariableExpr {
                let name = (expr as! VariableExpr).name
                return AssignExpr(name: name, value: value)
            }

            _ = error(token: equals, msg: "Invalid assignment target")
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

        return try primary()
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
