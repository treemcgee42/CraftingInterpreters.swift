
enum TokenType {
    // Single-character tokens.
    case leftParen, rightParen
    case leftBrace, rightBrace
    case comma
    case dot
    case minus, plus, slash, star
    case semicolon

    // One or two character tokens.
    case bang, bangEqual
    case equal, equalEqual
    case greater, greaterEqual
    case less, lessEqual

    // Literals.
    case identifier
    case string
    case number

    // Keywords.
    case and_, or_
    case false_, true_
    case if_, else_
    case for_, while_
    case class_, super_, this
    case fun
    case nil_
    case print
    case return_
    case var_

    case eof
}
