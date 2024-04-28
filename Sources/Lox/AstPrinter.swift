
class AstPrinter: Visitor {
    typealias R = String
    
    func printExpr(expr: Expr) -> String {
        return expr.accept(self)
    }

    func visitBinaryExpr(_ expr: Binary) -> String {
        return parenthesize(name: String(expr.op.lexeme), exprs: [expr.left, expr.right])
    }

    func visitGroupingExpr(_ expr: Grouping) -> String {
        return parenthesize(name: "group", exprs: [expr.expression])
    }

    func visitLiteralExpr(_ expr: Literal) -> String {
        if expr.value == nil {
            return "nil"
        }
        return String(describing: expr.value)
    }

    func visitUnaryExpr(_ expr: Unary) -> String {
        return parenthesize(name: String(expr.op.lexeme), exprs: [expr.right])
    }

    private func parenthesize(name: String, exprs: [Expr]) -> String {
        var toReturn = "(\(name)"
        for expr in exprs {
            toReturn += " \(expr.accept(self))"
        }
        toReturn += ")"

        return toReturn
    }

    static func main() {
        let expression = Binary(left: Unary(op: Token(type: .minus, lexeme: "-", literal: nil,
                                                      line: 1),
                                            right: Literal(value: 123)),
                                op: Token(type: .star, lexeme: "*", literal: nil, line: 1),
                                right: Grouping(expression: Literal(value: 45.67)))
        print(AstPrinter().printExpr(expr: expression))
        
    }
}
