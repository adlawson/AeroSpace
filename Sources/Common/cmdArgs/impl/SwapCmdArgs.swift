public struct SwapCmdArgs: CmdArgs {
    /*conforms*/ public var commonState: CmdArgsCommonState
    public init(rawArgs: StrArrSlice) { self.commonState = .init(rawArgs) }
    public static let parser: CmdParser<Self> = .init(
        kind: .swap,
        allowInConfig: true,
        help: swap_help_generated,
        flags: [
            "--swap-focus": trueBoolFlag(\.swapFocus),
            "--wrap-around": trueBoolFlag(\.wrapAround),
            "--window-id": optionalWindowIdFlag(),
        ],
        posArgs: [newMandatoryPosArgParser(\.target, parseSwapTarget, placeholder: SwapTarget.argsUnion)],
    )

    public var target: Lateinit<SwapTarget> = .uninitialized
    public var swapFocus: Bool = false
    public var wrapAround: Bool = false

    public init(rawArgs: [String], target: SwapTarget) {
        self.commonState = .init(rawArgs.slice)
        self.target = .initialized(target)
    }
}

func parseSwapCmdArgs(_ args: StrArrSlice) -> ParsedCmd<SwapCmdArgs> {
    return parseSpecificCmdArgs(SwapCmdArgs(rawArgs: args), args)
}

public enum SwapTarget: Equatable, Sendable {
    case relative(CardinalOrDfsDirection)
    case direct(WindowId)

    static let argsUnion: String = "(left|down|up|right|dfs-next|dfs-prev|<window-id>)"
}

func parseSwapTarget(i: PosArgParserInput) -> ParsedCliArgs<SwapTarget> {
    switch i.arg {
        case "left": .succ(.relative(.direction(.left)), advanceBy: 1)
        case "down": .succ(.relative(.direction(.down)), advanceBy: 1)
        case "up": .succ(.relative(.direction(.up)), advanceBy: 1)
        case "right": .succ(.relative(.direction(.right)), advanceBy: 1)
        case "dfs-next": .succ(.relative(.dfsRelative(.dfsNext)), advanceBy: 1)
        case "dfs-prev": .succ(.relative(.dfsRelative(.dfsPrev)), advanceBy: 1)
        default: .init(WindowId.parse(i.arg).map(SwapTarget.direct), advanceBy: 1)
    }
}
