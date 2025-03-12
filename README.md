# ScrollViewX

<video width="300" controls>
  <source src="./screenshot/video.mp4" type="video/mp4">
</video>

SwiftUI's ScrollView is simple but doesn't support many useful events. It doesn’t provide methods to detect when scrolling starts, stops, or when the user interacts with it. This makes it hard to create animations that react to scrolling.

## Issue
When working on animations, I needed a way to get more control over scrolling events. Instead of struggling with SwiftUI's limitations, I built a custom ScrollViewX using UIScrollView from UIKit. This allows me to access delegate methods easily and handle events more smoothly.

## What This Custom ScrollView Does

By wrapping UIScrollView in UIViewRepresentable, we can:

- Get scroll events – Detect when scrolling starts, stops, or when the user drags.
- Improve UIKit compatibility – Work better with UIKit components inside SwiftUI.
- Handle dynamic content – Adjust contentSize automatically when the content changes.

## How It Works

The SwiftUI content is placed inside a UIHostingController, so it works inside UIScrollView.
A Coordinator acts as the UIScrollViewDelegate, capturing events like scrollViewDidScroll and scrollViewDidEndDragging.
contentSize updates when new content is added, making sure the scrollable area resizes correctly.
A callback sends scrolling events back to SwiftUI, so you can use them for animations or other UI updates.

## Why This Is Useful

- More control – Get detailed scroll events missing from SwiftUI.
- Easier animations – Sync animations with scrolling smoothly.
- Better UIKit support – Works well when mixing SwiftUI and UIKit.
- Automatic layout updates – Keeps scrollable content updated when new views are added.

This custom scroll view makes it much easier to work with animations and scrolling events in SwiftUI.