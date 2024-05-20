
struct Return: Error {
    var value: Optional<Any>

    init(value: Optional<Any>) {
        self.value = value
    }
}
