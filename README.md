# Flash.swift

Flash messages for UIKit.

Flash messages -- or toasts, in Android parlance -- are discrete, non-modal alerts designed to notify the user without completely capturing their focus. For example, you might use a flash message to let the user know that new data has finished loading, or that a piece of data has been saved.

Flash.swift makes displaying these kinds of messages easy, and gives you flexibility to custom their appearance and behaviour.

## Usage

### UIKit

#### Basic example

Showing a flash message can be as simple as creating a `FlashView` instance and calling the `show()` function:

```Swift
let flash = FlashView(text: "Hello!")
flash.show()
```

You can also pass an image:

```Swift
let star = UIImage(systemName: "star.fill")
let flash = FlashView(text: "Hello!", image: star)
flash.show()
```

By default, the flash message be added to the active window's view heirarchy. It will automatically be inset from the safe area, and any navigation UI (navigation bars, tab bars, toolbars). Added the flash view direct to the window has some advantages, namely that the flash message can survive changes to the view heirarchy, like a view controller being popped from a navigation controller's stack.

If you want to show a flash message in a specific view, you can do so by passing a `UIView` instance to the `show()` method:

```Swift
flash.show(in: view)
```

You can also change the flash message duration by passing a `TimeInterval`:

```Swift
flash.show(in: view, duration: 5) // seconds
```

#### Custom configuration

#### Custom animation

### SwiftUI

Flash.swift does not yet expose a native SwiftUI interface, but you can invoke a flash alert as a side effect. For example:

```Swift
struct ExampleView: View {
    private func showFlash() {
        let flash = FlashView(text: "Hello!")
        flash.show()
    }

    var body: some View {
        Button("Show Flash") {
            showFlash()
        }
    }
}
```
