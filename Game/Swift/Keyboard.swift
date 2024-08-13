import AppKit // for `NSEvent`

struct Keyboard {

    private enum Keycode: UInt16 {
        case up = 126, down = 125, left = 123, right = 124
        case enter = 36, backspace = 51, tab = 48, escape = 53
    }

    private var isPressed:[Keycode: Bool] = [
        .up: false, .down: false, .left: false, .right: false,
        .enter: false, .backspace: false, .tab: false, .escape: false
    ]

    mutating func handle(event: NSEvent) {

        guard !event.isARepeat, let keycode = Keycode(rawValue: event.keyCode) else { return }

        isPressed[keycode] = event.type == NSEvent.EventType.keyDown
    }

    mutating func update(uniforms: inout Uniforms, viewport: MTLViewport) {

        let zoom = UInt32(uniforms.zoom)
        let heightOfMap = uniforms.gridSize.y * TILE_SIZE * zoom
        let bottomOfMap = heightOfMap - uniforms.camera.y * zoom

        if isPressed[.left]! { uniforms.camera.x &-= 1 }
        else if isPressed[.right]! { uniforms.camera.x &+= 1 }

        if isPressed[.up]!, uniforms.camera.y > 0 { uniforms.camera.y -= 1 }
        else if isPressed[.down]!, bottomOfMap >= UInt32(viewport.height) { uniforms.camera.y += 1 }

        if isPressed[.enter]! {

            uniforms.zoom *= 2
            isPressed[.enter] = false

        } else if isPressed[.backspace]! {

            uniforms.zoom /= 2
            isPressed[.backspace] = false
        }
    }
    
}
