//
//  UIButton+Combine.swift
//  CombineDemo
//
//  Created by yfm on 2023/5/15.
//
//  两种方法都可以，生成自定义发布者复杂点，通过subject实现简单点

import UIKit.UIControl
import Combine
import Foundation

// 扩展UIButton1，通过subject，实现生成publisher的方法
//extension UIButton {
//
//    private struct AssociatedKeys {
//        static var tapPublisher = "tapPublisher"
//    }
//
//    private var tapPublisher: PassthroughSubject<Void, Never> {
//        if let publisher = objc_getAssociatedObject(self, &AssociatedKeys.tapPublisher) as? PassthroughSubject<Void, Never> {
//            return publisher
//        }
//
//        let publisher = PassthroughSubject<Void, Never>()
//        objc_setAssociatedObject(self, &AssociatedKeys.tapPublisher, publisher, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
//
//        addTarget(self, action: #selector(handleTap), for: .touchUpInside)
//
//        return publisher
//    }
//
//    @objc func handleTap() {
//        tapPublisher.send()
//    }
//
//    var publisher: AnyPublisher<Void, Never> {
//        tapPublisher.eraseToAnyPublisher()
//    }
//}

// 扩展UIButton2，通过实现Publisher协议，实现生成publisher的方法
extension UIButton {
    var tapPublisher: AnyPublisher<Void, Never> {
        Publishers.ControlEvent(control: self, events: .touchUpInside)
            .eraseToAnyPublisher()
    }
}

@available(iOS 13.0, *)
extension Combine.Publishers {
    struct ControlEvent<Control: UIControl>: Publisher {
        typealias Output = Void
        typealias Failure = Never
        
        private let control: Control
        private let controlEvents: Control.Event
        
        public init(control: Control,
                    events: Control.Event) {
            self.control = control
            self.controlEvents = events
        }

        public func receive<S: Subscriber>(subscriber: S) where S.Failure == Failure, S.Input == Output {
            let subscription = Subscription(subscriber: subscriber,
                                            control: control,
                                            event: controlEvents)
            
            subscriber.receive(subscription: subscription)
        }
    }
}


@available(iOS 13.0, *)
extension Combine.Publishers.ControlEvent {
    private final class Subscription<S: Subscriber, Control: UIControl>: Combine.Subscription where S.Input == Void {
        private var subscriber: S?
        weak private var control: Control?

        init(subscriber: S, control: Control, event: Control.Event) {
            self.subscriber = subscriber
            self.control = control
            control.addTarget(self, action: #selector(processControlEvent), for: .touchUpInside)
        }

        func request(_ demand: Subscribers.Demand) {
            //
        }

        func cancel() {
            subscriber = nil
        }

        @objc private func processControlEvent() {
            _ = subscriber?.receive()
        }
    }
}


