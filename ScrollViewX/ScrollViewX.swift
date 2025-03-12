import SwiftUI

struct ScrollViewX<Content: View>: UIViewRepresentable {
    let content: Content
    let actionHandler: (Action) -> Void

    init(
        actionHandler: @escaping (Action) -> Void,
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
        scrollView.bounces = false

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
        let newHeight = hostingController.updateHostingControllerHeight(for: uiView)
        uiView.contentSize = CGSize(width: uiView.bounds.width, height: newHeight)
    }

    final class Coordinator: NSObject, UIScrollViewDelegate {
        let actionHandler: (Action) -> Void
        var hostingController: ContentHostingController?

        init(actionHandler: @escaping (Action) -> Void) {
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

extension ScrollViewX {
    public enum Action {
        case didScroll(scrollView: UIScrollView, isUserAction: Bool)
        case didEndDecelerating(scrollView: UIScrollView)
        case didEndDragging(scrollView: UIScrollView)
    }
}

