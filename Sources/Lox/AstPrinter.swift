
class AstPrinter: ExprVisitor {
    typealias R = String
    
    func printExpr(expr: Expr) throws -> String {
        return try expr.accept(self)
    }

    func visitBinaryExpr(_ expr: BinaryExpr) throws -> String {
        return try parenthesize(name: String(expr.op.lexeme),
                                exprs: [expr.left, expr.right])
    }

    func visitGroupingExpr(_ expr: GroupingExpr) throws -> String {
        return try parenthesize(name: "group", exprs: [expr.expression])
    }

    func visitLiteralExpr(_ expr: LiteralExpr) -> String {
        if expr.value == nil {
            return "nil"
        }
        return String(describing: expr.value)
    }

    func visitUnaryExpr(_ expr: UnaryExpr) throws -> String {
        return try parenthesize(name: String(expr.op.lexeme),
                                exprs: [expr.right])
    }

    private func parenthesize(name: String, exprs: [Expr]) throws -> String {
        var toReturn = "(\(name)"
        for expr in exprs {
            toReturn += " \(try expr.accept(self))"
        }
        toReturn += ")"

        return toReturn
    }

    func visitVariableExpr(_ expr: VariableExpr) throws -> String {
        return try parenthesize(name: "eval-var \(expr.name.lexeme)", exprs: []) 
    }

    func visitAssignExpr(_ expr: AssignExpr) throws -> String {
        return try parenthesize(name: "assign \(expr.name.lexeme)", exprs: [expr.value])
    }

    func visitLogicalExpr(_ expr: LogicalExpr) throws -> String {
        return try parenthesize(name: "\(expr.op.lexeme)", exprs: [expr.left, expr.right])
    }

    static func main() {
        let expression = BinaryExpr(left: UnaryExpr(op: Token(type: .minus, lexeme: "-", literal: nil,
                                                      line: 1),
                                            right: LiteralExpr(value: 123)),
                                op: Token(type: .star, lexeme: "*", literal: nil, line: 1),
                                right: GroupingExpr(expression: LiteralExpr(value: 45.67)))
        print(try! AstPrinter().printExpr(expr: expression))
        
    }
}
