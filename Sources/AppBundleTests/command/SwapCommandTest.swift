@testable import AppBundle
import Common
import XCTest

@MainActor
final class SwapCommandTest: XCTestCase {
    override func setUp() async throws { setUpWorkspacesForTests() }

    func testSwap_swapWindows_Directional() async throws {
        let root = Workspace.get(byName: name).rootTilingContainer.apply {
            TilingContainer.newVTiles(parent: $0, adaptiveWeight: 1).apply {
                assertEquals(TestWindow.new(id: 1, parent: $0).focusWindow(), true)
                TestWindow.new(id: 2, parent: $0)
            }
            TestWindow.new(id: 3, parent: $0)
        }

        try await SwapCommand(args: SwapCmdArgs(rawArgs: [], target: .relative(.direction(.right)))).run(.defaultEnv, .emptyStdin)
        assertEquals(root.layoutDescription,
                     .h_tiles([.v_tiles([.window(3), .window(2)]),
                               .window(1)]))
        assertEquals(focus.windowOrNil?.windowId, 1)

        try await SwapCommand(args: SwapCmdArgs(rawArgs: [], target: .relative(.direction(.left)))).run(.defaultEnv, .emptyStdin)
        assertEquals(root.layoutDescription,
                     .h_tiles([.v_tiles([.window(1), .window(2)]),
                               .window(3)]))
        assertEquals(focus.windowOrNil?.windowId, 1)

        try await SwapCommand(args: SwapCmdArgs(rawArgs: [], target: .relative(.direction(.down)))).run(.defaultEnv, .emptyStdin)
        assertEquals(root.layoutDescription,
                     .h_tiles([.v_tiles([.window(2), .window(1)]),
                               .window(3)]))
        assertEquals(focus.windowOrNil?.windowId, 1)

        try await SwapCommand(args: SwapCmdArgs(rawArgs: [], target: .relative(.direction(.up)))).run(.defaultEnv, .emptyStdin)
        assertEquals(root.layoutDescription,
                     .h_tiles([.v_tiles([.window(1), .window(2)]),
                               .window(3)]))
        assertEquals(focus.windowOrNil?.windowId, 1)
    }

    func testSwap_swapWindows_DfsRelative() async throws {
        let root = Workspace.get(byName: name).rootTilingContainer.apply {
            TilingContainer.newVTiles(parent: $0, adaptiveWeight: 1).apply {
                assertEquals(TestWindow.new(id: 1, parent: $0).focusWindow(), true)
                TestWindow.new(id: 2, parent: $0)
            }
            TestWindow.new(id: 3, parent: $0)
        }

        try await SwapCommand(args: SwapCmdArgs(rawArgs: [], target: .relative(.dfsRelative(.dfsNext)))).run(.defaultEnv, .emptyStdin)
        assertEquals(root.layoutDescription,
                     .h_tiles([.v_tiles([.window(2), .window(1)]),
                               .window(3)]))
        assertEquals(focus.windowOrNil?.windowId, 1)

        try await SwapCommand(args: SwapCmdArgs(rawArgs: [], target: .relative(.dfsRelative(.dfsNext)))).run(.defaultEnv, .emptyStdin)
        assertEquals(root.layoutDescription,
                     .h_tiles([.v_tiles([.window(2), .window(3)]),
                               .window(1)]))
        assertEquals(focus.windowOrNil?.windowId, 1)

        try await SwapCommand(args: SwapCmdArgs(rawArgs: [], target: .relative(.dfsRelative(.dfsPrev)))).run(.defaultEnv, .emptyStdin)
        assertEquals(root.layoutDescription,
                     .h_tiles([.v_tiles([.window(2), .window(1)]),
                               .window(3)]))
        assertEquals(focus.windowOrNil?.windowId, 1)

        try await SwapCommand(args: SwapCmdArgs(rawArgs: [], target: .relative(.dfsRelative(.dfsPrev)))).run(.defaultEnv, .emptyStdin)
        assertEquals(root.layoutDescription,
                     .h_tiles([.v_tiles([.window(1), .window(2)]),
                               .window(3)]))
        assertEquals(focus.windowOrNil?.windowId, 1)
    }

    func testSwap_DirectionalWrapping() async throws {
        let root = Workspace.get(byName: name).rootTilingContainer.apply {
            assertEquals(TestWindow.new(id: 1, parent: $0).focusWindow(), true)
            TestWindow.new(id: 2, parent: $0)
            TestWindow.new(id: 3, parent: $0)
        }

        var args = SwapCmdArgs(rawArgs: [], target: .relative(.direction(.left)))
        args.wrapAround = true
        try await SwapCommand(args: args).run(.defaultEnv, .emptyStdin)
        assertEquals(root.layoutDescription, .h_tiles([.window(3), .window(2), .window(1)]))
        assertEquals(focus.windowOrNil?.windowId, 1)

        args.target = .initialized(.relative(.direction(.right)))
        try await SwapCommand(args: args).run(.defaultEnv, .emptyStdin)
        assertEquals(root.layoutDescription, .h_tiles([.window(1), .window(2), .window(3)]))
        assertEquals(focus.windowOrNil?.windowId, 1)
    }

    func testSwap_DfsRelativeWrapping() async throws {
        let root = Workspace.get(byName: name).rootTilingContainer.apply {
            assertEquals(TestWindow.new(id: 1, parent: $0).focusWindow(), true)
            TestWindow.new(id: 2, parent: $0)
            TestWindow.new(id: 3, parent: $0)
        }

        var args = SwapCmdArgs(rawArgs: [], target: .relative(.dfsRelative(.dfsPrev)))
        args.wrapAround = true
        try await SwapCommand(args: args).run(.defaultEnv, .emptyStdin)
        assertEquals(root.layoutDescription, .h_tiles([.window(3), .window(2), .window(1)]))
        assertEquals(focus.windowOrNil?.windowId, 1)

        args.target = .initialized(.relative(.dfsRelative(.dfsNext)))
        try await SwapCommand(args: args).run(.defaultEnv, .emptyStdin)
        assertEquals(root.layoutDescription, .h_tiles([.window(1), .window(2), .window(3)]))
        assertEquals(focus.windowOrNil?.windowId, 1)
    }

    func testSwap_SwapFocus() async throws {
        let root = Workspace.get(byName: name).rootTilingContainer.apply {
            TestWindow.new(id: 1, parent: $0)
            assertEquals(TestWindow.new(id: 2, parent: $0).focusWindow(), true)
            TestWindow.new(id: 3, parent: $0)
        }

        var args = SwapCmdArgs(rawArgs: [], target: .relative(.direction(.right)))
        args.swapFocus = true
        try await SwapCommand(args: args).run(.defaultEnv, .emptyStdin)
        assertEquals(root.layoutDescription, .h_tiles([.window(1), .window(3), .window(2)]))
        assertEquals(focus.windowOrNil?.windowId, 3)
    }
}
