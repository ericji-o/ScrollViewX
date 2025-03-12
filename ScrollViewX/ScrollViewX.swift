import SwiftUI

struct ScrollViewX<Content: View>: UIViewRepresentable {
    let content: Content
    let actionHandler: (ScrollViewXAction) -> Void

    init(
        actionHandler: @escaping (ScrollViewXAction) -> Void,
        @ViewBuilder content: () -> Content
    ) {
        self.content = content()
        self.actionHandler = actionHandler
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(actionHandler: actionHandler)
    }

    func makeUIView(context: Context) -> UIScrollView {
        let scrollView = UIScrollView()
        scrollView.delegate = context.coordinator

        let hostingController = ContentHostingController(
            rootView: content
        ) { [weak scrollView] hostingController in
            guard let scrollView else { return }
            let newHeight = hostingController.updateHostingControllerHeight(for: scrollView)
            scrollView.contentSize = CGSize(width: scrollView.bounds.width, height: newHeight)
        }

        context.coordinator.hostingController = hostingController
        hostingController.view.backgroundColor = .clear
        hostingController.view.autoresizingMask = [.flexibleWidth]

        scrollView.addSubview(hostingController.view)
        let newHeight = hostingController.updateHostingControllerHeight(for: scrollView)
        scrollView.contentSize = CGSize(width: scrollView.bounds.width, height: newHeight)

        return scrollView
    }

    func updateUIView(_ uiView: UIScrollView, context: Context) {
        guard let hostingController = context.coordinator.hostingController else { return }
        hostingController.rootView = content
        hostingController.view.setNeedsLayout()
    }

    final class Coordinator: NSObject, UIScrollViewDelegate {
        let actionHandler: (ScrollViewXAction) -> Void
        var hostingController: ContentHostingController?

        init(actionHandler: @escaping (ScrollViewXAction) -> Void) {
            self.actionHandler = actionHandler
        }

        func scrollViewDidScroll(_ scrollView: UIScrollView) {
            actionHandler(
                .didScroll(
                    scrollView: scrollView,
                    isUserAction: scrollView.isDragging || scrollView.isTracking || scrollView.isDecelerating
                )
            )
        }

        func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
            actionHandler(.didEndDecelerating(scrollView: scrollView))
        }

        func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
            if !decelerate {
                actionHandler(.didEndDragging(scrollView: scrollView))
            }
        }
    }

    final class ContentHostingController: UIHostingController<Content> {
        let callback: (ContentHostingController) -> Void

        init(
            rootView: Content,
            callback: @escaping (ContentHostingController) -> Void
        ) {
            self.callback = callback
            super.init(rootView: rootView)
        }

        @available(*, unavailable)
        @MainActor @preconcurrency required dynamic init?(coder aDecoder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }

        override func viewDidLayoutSubviews() {
            super.viewDidLayoutSubviews()
            callback(self)
        }

        func updateHostingControllerHeight(for scrollView: UIScrollView) -> CGFloat {
            let targetSize = CGSize(width: scrollView.bounds.width, height: CGFloat.greatestFiniteMagnitude)
            let newSize = sizeThatFits(in: targetSize)
            view.frame.size.height = newSize.height
            return newSize.height
        }
    }
}

public enum ScrollViewXAction {
    // add more delegate methods here
    case didScroll(scrollView: UIScrollView, isUserAction: Bool)
    case didEndDecelerating(scrollView: UIScrollView)
    case didEndDragging(scrollView: UIScrollView)
}
