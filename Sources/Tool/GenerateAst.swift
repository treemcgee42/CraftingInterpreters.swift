
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
          types: ["Binary": [("left", "Expr"), ("op", "Token"), ("right", "Expr")],
                  "Grouping": [("expression", "Expr")],
                  "Literal": [("value", "Optional<Any>")],
                  "Unary": [("op", "Token"), ("right", "Expr")]])
    }

    private static func defineAst(outputDir: String, baseName: String,
                                  types: [String: [(String, String)]]) throws {
        let path = "\(outputDir)/\(baseName).swift";

        var content =
          """
          // \(baseName).swift
          // This is a generated file.

          protocol \(baseName) {
              func accept<V: Visitor>(_ visitor: V) throws -> V.R
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
        content += "\nprotocol Visitor {"

        content += "\n\tassociatedtype R\n"

        for type in types {
            content += "\n\tfunc visit\(type)\(baseName)(_ \(baseName): \(type)) throws -> R"
        }

        content += "\n}\n\n"
    }

    private static func defineType(content: inout String, baseName: String, className: String,
                                   fieldList: [(String, String)]) {
        content += "struct \(className): \(baseName) {"

        for (fieldName, fieldType) in fieldList {
            content += "\n\tvar \(fieldName): \(fieldType)"
        }

        // Visitor pattern.
        content += "\n"
        content += "\n\tfunc accept<V: Visitor>(_ visitor: V) throws -> V.R {"
        content += "\n\t\treturn try visitor.visit\(className)\(baseName)(self)"
        content += "\n\t}"

        content += "\n}\n\n"
    }
}
