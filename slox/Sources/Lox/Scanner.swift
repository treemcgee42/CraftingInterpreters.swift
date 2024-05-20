
class Scanner {
    private var source: String
    private var tokens: [Token] = []
    private var start: String.Index
    private var current: String.Index
    private var line: Int = 1

    private static var keywords: [String: TokenType] = [
      "and": .and_,
      "class": .class_,
      "else": .else_,
      "false": .false_,
      "for": .for_,
      "fun": .fun,
      "if": .if_,
      "nil": .nil_,
      "or": .or_,
      "print": .print,
      "return": .return_,
      "super": .super_,
      "this": .this,
      "true": .true_,
      "var": .var_,
      "while": .while_,
    ]

    init(source: String) {
        self.source = source
        self.start = source.startIndex
        self.current = source.startIndex
    }

    func scanTokens() -> [Token] {
        while !isAtEnd() {
            start = current
            scanToken()
        }

        tokens.append(Token(type: .eof, lexeme: "", literal: nil, line: line));
        return tokens
    }

    private func scanToken() {
        let c: Character = advance()
        switch c {
        case "(":
            addToken(.leftParen)
        case ")":
            addToken(.rightParen)
        case "{":
            addToken(.leftBrace)
        case "}":
            addToken(.rightBrace)
        case ",":
            addToken(.comma)
        case ".":
            addToken(.dot)
        case "-":
            addToken(.minus)
        case "+":
            addToken(.plus)
        case ";":
            addToken(.semicolon)
        case "*":
            addToken(.star)
        case "!":
            addToken(match("=") ? .bangEqual : .bang)
        case "=":
            addToken(match("=") ? .equalEqual : .equal)
        case "<":
            addToken(match("=") ? .lessEqual : .less)
        case ">":
            addToken(match("=") ? .greaterEqual : .greater)
        case "/":
            if match("/") {
                // Comment.
                while (peek() != "\n") && (!isAtEnd()) {
                    _ = advance()
                }
            } else {
                addToken(.slash)
            }

        case " ", "\r", "\t":
            break
        case "\n":
            line += 1

        case "\"":
            string()
            
        default:
            if isDigit(c) {
                number()
            } else if isAlpha(c) {
                identifier()
            } else {
                Lox.error(line: line, message: "Unexpected character.")
            }
        }
    }

    private func identifier() {
        while isAlphaNumeric(peek()) {
            _ = advance()
        }

        let text = source[start..<current]
        let type = Scanner.keywords[String(text)] ?? .identifier
        addToken(type)
    }

    private func number() {
        while isDigit(peek()) {
            _ = advance()
        }

        // Look for a fractional part
        if (peek() == ".") && isDigit(peekNext()) {
            // Consume the ".".
            _ = advance()

            while isDigit(peek()) {
                _ = advance()
            }
        }

        addToken(type: .number, literal: Double(source[start..<current]))
    }

    private func string() {
        while (peek() != "\"") && (!isAtEnd()) {
            if peek() == "\n" {
                line += 1
            }
            _ = advance()
        }

        if isAtEnd() {
            Lox.error(line: line, message: "Unterminated string.");
            return;
        }

        // The closing ".
        _ = advance()

        // Trim the surrounding quotes.
        let value = source[source.index(after: start)..<source.index(before: current)]
        addToken(type: .string, literal: value)
    }

    private func match(_ expected: Character) -> Bool {
        if isAtEnd() {
            return false
        }
        if source[current] != expected {
            return false
        }

        source.formIndex(after: &current)
        return true
    }

    private func peek() -> Character {
        if isAtEnd() {
            return "\0"
        }
        return source[current]
    }

    private func peekNext() -> Character {
        if source.index(after: current) >= source.endIndex {
            return "\0"
        }
        return source[source.index(after: current)]
    }

    private func isAlpha(_ c: Character) -> Bool {
        return ((c >= "a") && (c <= "z")) ||
          ((c >= "A") && (c <= "Z")) ||
          (c == "_")
    }

    private func isAlphaNumeric(_ c: Character) -> Bool {
        return isAlpha(c) || isDigit(c)
    }

    private func isDigit(_ c: Character) -> Bool {
        return c >= "0" && c <= "9"
    }

    private func isAtEnd() -> Bool {
        return current >= source.endIndex
    }

    private func advance() -> Character {
        let c = source[current]
        source.formIndex(after: &current)
        return c
    }

    private func addToken(_ type: TokenType) {
        addToken(type: type, literal: nil)
    }

    private func addToken(type: TokenType, literal: Optional<Any>) {
        let text = source[start..<current]
        tokens.append(Token(type: type, lexeme: text, literal: literal, line: line))
    }
}
