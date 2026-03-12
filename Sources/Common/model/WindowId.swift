public struct WindowId: Equatable, Sendable {
    public let raw: UInt32

    private init(_ raw: UInt32) {
        self.raw = raw
    }

    public static func parse(_ raw: String) -> Parsed<WindowId> {
        if let parsedNumeric = UInt32(raw) {
            return .success(WindowId(parsedNumeric))
        }
        return .failure("Window ID must be a number")
    }
}
