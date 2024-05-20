
class RuntimeError: Error {
    var token: Token
    var msg: String

    init(token: Token, msg: String) {
        self.token = token
        self.msg = msg
    }
}
