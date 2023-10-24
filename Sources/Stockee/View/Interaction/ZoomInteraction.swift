//
//  ZoomInteraction.swift
//  Stockee
//
//  Created by octree on 2022/3/19.
//
//  Copyright (c) 2022 Octree <fouljz@gmail.com>
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.

import UIKit

final class ZoomInteraction: NSObject, UIInteraction {
    weak var view: UIView?
    private var preScale: CGFloat = 1.0
    private lazy var gesture: UIPinchGestureRecognizer = .init(target: self, action: #selector(handlePinch(gesture:)))
    private var handler: (UIPinchGestureRecognizer) -> Void

    init(handler: @escaping (UIPinchGestureRecognizer) -> Void) {
        self.handler = handler
        super.init()
        gesture.delegate = self
    }

    func willMove(to view: UIView?) {
        self.view?.removeGestureRecognizer(gesture)
        self.view = nil
    }

    func didMove(to view: UIView?) {
        self.view = view
        view?.addGestureRecognizer(gesture)
    }

    @objc private func handlePinch(gesture: UIPinchGestureRecognizer) {
        handler(gesture)
    }
}

extension ZoomInteraction: UIGestureRecognizerDelegate {
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        if otherGestureRecognizer is UIPanGestureRecognizer {
            return false
        }
        return otherGestureRecognizer.view !== view
    }
}
