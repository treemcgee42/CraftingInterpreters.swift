
import Foundation

@main
struct Lox {
    static var hadError: Bool = false
    
    static func main() {
        let args = CommandLine.arguments

        if args.count > 2 {
            print("Usage: lox [script]")
            exit(64)
        } else if args.count == 2 {
            do {
                try runFile(path: args[1])
            } catch {
                print("Error: exception: \(error)")
            }
        } else {
            do {
                try runPrompt()
            } catch {
                print("Error: exception: \(error)")
            }
        }
    }

    private static func runFile(path: String) throws {
        let fileAsString = try String(contentsOf: URL(fileURLWithPath: path), encoding: .utf8)
        run(source: fileAsString)

        if hadError {
            exit(65)
        }
    }

    private static func runPrompt() throws {
        while true {
            print("> ", terminator: "")
            fflush(stdout)

            let line = readLine()
            if line == nil { break }

            run(source: line!)
            hadError = false;
        }
    }

    private static func run(source: String) {
        let scanner = Scanner(source: source)
        let tokens = scanner.scanTokens()

        for token in tokens {
            print(token)
        }
    }

    static func error(line: Int, message: String) {
        report(line: line, loc: "", msg: message)
    }

    private static func report(line: Int, loc: String, msg: String) {
        print("[line \(line)] Error\(loc): \(msg)")
        self.hadError = true
    }
}
