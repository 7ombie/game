import AppKit

struct Keyboard {

    private enum Keycode: UInt16 {
        case up = 126, down = 125, left = 123, right = 124
        case enter = 36, backspace = 51, tab = 48, escape = 53
    }

    private var state:[Keycode: Bool] = [
        .up: false, .down: false, .left: false, .right: false,
        .enter: false, .backspace: false, .tab: false, .escape: false
    ]

    mutating func handle(event: NSEvent) {

        guard !event.isARepeat, let keycode = Keycode(rawValue: event.keyCode) else { return }

        state[keycode] = event.type == NSEvent.EventType.keyDown
    }

    mutating func update(uniforms: inout Uniforms, level: Level) {

        if state[.up]!, uniforms.camera.y > 0 { uniforms.camera.y -= 1 }
        else if state[.down]!, uniforms.camera.y < level.extents.y { uniforms.camera.y += 1 }

        if state[.left]!, uniforms.camera.x > 0 { uniforms.camera.x -= 1 }
        else if state[.right]!, uniforms.camera.x < level.extents.x { uniforms.camera.x += 1 }

        if state[.enter]! {

            uniforms.zoom += 1
            state[.enter] = false

        } else if state[.backspace]! {

            uniforms.zoom -= 1
            state[.backspace] = false
        }
    }
}
