
import Foundation

@main
class GenerateAst {
    static func main() throws {
        let args = CommandLine.arguments;

        if args.count != 2 {
            print("Usage: generate_ast <output directory>")
            exit(64)
        }

        let outputDir = args[1]
        try defineAst(
          outputDir: outputDir,
          baseName: "Expr",
          types: ["Assign": [("name", "Token"), ("value", "Expr")],
                  "Binary": [("left", "Expr"), ("op", "Token"), ("right", "Expr")],
                  "Call": [("callee", "Expr"), ("paren", "Token"),
                           ("arguments", "[Expr]")],
                  "Get": [("object", "Expr"), ("name", "Token")],
                  "Grouping": [("expression", "Expr")],
                  "Literal": [("value", "Optional<Any>")],
                  "Logical": [("left", "Expr"), ("op", "Token"), ("right", "Expr")],
                  "Set": [("object", "Expr"), ("name", "Token"), ("value", "Expr")],
                  "Super": [("keyword", "Token"), ("method", "Token")],
                  "This": [("keyword", "Token")],
                  "Unary": [("op", "Token"), ("right", "Expr")],
                  "Variable": [("name", "Token")]])

        try defineAst(
          outputDir: outputDir,
          baseName: "Stmt",
          types: ["Block": [("statements", "[Stmt?]")],
                  "Class": [("name", "Token"), ("superclass", "VariableExpr?"),
                            ("methods", "[FunctionStmt]")],
                  "Expression": [("expression", "Expr")],
                  "Function": [("name", "Token"), ("params", "[Token]"),
                               ("body", "[Stmt?]")],
                  "If": [("condition", "Expr"), ("thenBranch", "Stmt"),
                         ("elseBranch", "Stmt?")],
                  "Print": [("expression", "Expr")],
                  "Return": [("keyword", "Token"), ("value", "Expr?")],
                  "Var": [("name", "Token"), ("initializer", "Expr?")],
                  "While": [("condition", "Expr"), ("body", "Stmt")]])
    }

    private static func defineAst(outputDir: String, baseName: String,
                                  types: [String: [(String, String)]]) throws {
        let path = "\(outputDir)/\(baseName).swift";

        var content =
          """
          // \(baseName).swift
          // This is a generated file.

          import Foundation
          
          protocol \(baseName) {
              var id: UUID { get }
              func accept<V: \(baseName)Visitor>(_ visitor: V) throws -> V.\(baseName)R
          }
          
          """

        defineVisitor(content: &content, baseName: baseName, types: [String](types.keys))

        for (className, fields) in types {
            defineType(content: &content, baseName: baseName, className: className,
                       fieldList: fields)
        }

        try content.write(to: URL(fileURLWithPath: path), atomically: true, encoding: .utf8)
    }

    private static func defineVisitor(content: inout String, baseName: String, types: [String]) {
        content += "\nprotocol \(baseName)Visitor {"

        content += "\n\tassociatedtype \(baseName)R\n"

        for type in types {
            content += "\n\tfunc visit\(type)\(baseName)(_ \(baseName): \(type)\(baseName)) throws -> \(baseName)R"
        }

        content += "\n}\n\n"
    }

    private static func defineType(content: inout String, baseName: String, className: String,
                                   fieldList: [(String, String)]) {
        content += "struct \(className)\(baseName): \(baseName) {"

        for (fieldName, fieldType) in fieldList {
            content += "\n\tvar \(fieldName): \(fieldType)"
        }

        content += "\n\n\tvar id: UUID = UUID()"

        // Visitor pattern.
        content += "\n"
        content += "\n\tfunc accept<V: \(baseName)Visitor>(_ visitor: V) throws -> V.\(baseName)R {"
        content += "\n\t\treturn try visitor.visit\(className)\(baseName)(self)"
        content += "\n\t}"

        content += "\n}\n\n"
    }
}
