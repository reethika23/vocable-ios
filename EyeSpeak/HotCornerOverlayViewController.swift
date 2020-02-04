//
//  HotCornerOverlayViewController.swift
//  EyeSpeak
//
//  Created by Chris Stroud on 2/4/20.
//  Copyright © 2020 WillowTree. All rights reserved.
//

import UIKit

final private class HotCornerExpandingView: UIButton {

    private var gazeBeginDate: Date?

    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }

    private func commonInit() {
        backgroundColor = .gray
    }

    override func gazeBegan(_ gaze: UIHeadGaze, with event: UIHeadGazeEvent?) {
        backgroundColor = .green
        gazeBeginDate = Date()
    }

    override func gazeMoved(_ gaze: UIHeadGaze, with event: UIHeadGazeEvent?) {
        guard let beginDate = gazeBeginDate else { return }
        let elapsedTime = Date().timeIntervalSince(beginDate)
        if elapsedTime >= gaze.selectionHoldDuration {
            sendActions(for: .primaryActionTriggered)
            gazeBeginDate = nil
        }
    }

    override func gazeEnded(_ gaze: UIHeadGaze, with event: UIHeadGazeEvent?) {
        backgroundColor = .gray
        gazeBeginDate = nil
    }

    override var intrinsicContentSize: CGSize {
        return CGSize(width: 88, height: 88)
    }
}

final private class HotCornerOverlayView: UIView {

    var isInterceptingAllGazeEvents: Bool = false

    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }

    private func commonInit() {
        backgroundColor = .clear
    }

    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        let existing = super.hitTest(point, with: event)
        if isInterceptingAllGazeEvents {
            return existing ?? self
        } else if existing == self {
            return nil
        }
        return existing
    }

    override func gazeableHitTest(_ point: CGPoint, with event: UIHeadGazeEvent?) -> UIView? {
        guard let existing = super.gazeableHitTest(point, with: event) else {
            if isInterceptingAllGazeEvents {
                return self
            }
            return nil
        }
        if existing == self && !isInterceptingAllGazeEvents {
            return nil
        }
        return existing
    }
}

final class HotCornerOverlayViewController: UIViewController {

    private let pauseView = HotCornerExpandingView()

    private var overlayView: HotCornerOverlayView {
        return self.view as! HotCornerOverlayView
    }

    override func loadView() {
        self.view = HotCornerOverlayView(frame: .zero)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.addSubview(pauseView)
        pauseView.translatesAutoresizingMaskIntoConstraints = false
        pauseView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        pauseView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        pauseView.addTarget(self, action: #selector(pauseTracking(_:)), for: .primaryActionTriggered)
        pauseView.setTitle("Pause", for: .normal)
    }

    @objc private func pauseTracking(_ sender: Any?) {
        overlayView.isInterceptingAllGazeEvents.toggle()
        if overlayView.isInterceptingAllGazeEvents {
            pauseView.setTitle("Resume", for: .normal)
            overlayView.backgroundColor = UIColor.gray.withAlphaComponent(0.3)
        } else {
            pauseView.setTitle("Pause", for: .normal)
            overlayView.backgroundColor = UIColor.clear
        }
    }
}
