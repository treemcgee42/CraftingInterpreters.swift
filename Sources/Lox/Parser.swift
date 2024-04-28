
class Parser {
    private struct ParseError: Error {}
    
    private var tokens: [Token]
    private var current: Int = 0

    init(tokens: [Token]) {
        self.tokens = tokens
    }

    func parse() -> Optional<Expr> {
        do {
            return try expression()
        } catch {
            return nil
        }
    }

    private func expression() throws -> Expr {
        return try equality()
    }

    private func equality() throws -> Expr {
        var expr = try comparision()

        while match([.bangEqual, .equalEqual]) {
            let op = previous()
            let right = try comparision()
            expr = Binary(left: expr, op: op, right: right)
        }

        return expr
    }

    private func comparision() throws -> Expr {
        var expr = try term()

        while match([.greater, .greaterEqual, .less, .lessEqual]) {
            let op = previous()
            let right = try term()
            expr = Binary(left: expr, op: op, right: right)
        }

        return expr
    }

    private func term() throws -> Expr {
        var expr = try factor()

        while match([.minus, .plus]) {
            let op = previous()
            let right = try factor()
            expr = Binary(left: expr, op: op, right: right)
        }

        return expr
    }

    private func factor() throws -> Expr {
        var expr = try unary()

        while match([.slash, .star]) {
            let op = previous()
            let right = try unary()
            expr = Binary(left: expr, op: op, right: right)
        }

        return expr
    }

    private func unary() throws -> Expr {
        if match([.bang, .minus]) {
            let op = previous()
            let right = try unary()
            return Unary(op: op, right: right)
        }

        return try primary()
    }

    private func primary() throws -> Expr {
        if match([.false_]) {
            return Literal(value: false)
        }
        if match([.true_]) {
            return Literal(value: true)
        }
        if match([.nil_]) {
            return Literal(value: nil)
        }

        if match([.number, .string]) {
            return Literal(value: previous().literal)
        }

        if match([.leftParen]) {
            let expr = try expression()
            _ = try consume(type: .rightParen, msg: "Expect ')' after expression.")
            return Grouping(expression: expr)
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
