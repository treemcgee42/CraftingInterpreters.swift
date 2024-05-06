
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
                  "Grouping": [("expression", "Expr")],
                  "Literal": [("value", "Optional<Any>")],
                  "Logical": [("left", "Expr"), ("op", "Token"), ("right", "Expr")],
                  "Unary": [("op", "Token"), ("right", "Expr")],
                  "Variable": [("name", "Token")]])

        try defineAst(
          outputDir: outputDir,
          baseName: "Stmt",
          types: ["Block": [("statements", "[Stmt?]")],
                  "Expression": [("expression", "Expr")],
                  "If": [("condition", "Expr"), ("thenBranch", "Stmt"),
                         ("elseBranch", "Stmt?")],
                  "Print": [("expression", "Expr")],
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

          protocol \(baseName) {
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

        // Visitor pattern.
        content += "\n"
        content += "\n\tfunc accept<V: \(baseName)Visitor>(_ visitor: V) throws -> V.\(baseName)R {"
        content += "\n\t\treturn try visitor.visit\(className)\(baseName)(self)"
        content += "\n\t}"

        content += "\n}\n\n"
    }
}
