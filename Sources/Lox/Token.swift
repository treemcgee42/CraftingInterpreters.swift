
class Token: CustomStringConvertible {
    var type: TokenType
    var lexeme: Substring
    var literal: Optional<Any>
    var line: Int

    init(type: TokenType, lexeme: Substring, literal: Optional<Any>, line: Int) {
        self.type = type
        self.lexeme = lexeme
        self.literal = literal
        self.line = line
    }

    var description: String {
        return "\(type) \(lexeme) \(String(describing: literal))"
    }
}
