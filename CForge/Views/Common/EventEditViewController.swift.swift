//
//  EventEditViewController.swift.swift
//  CForge
//
//  Created by Harshit Raj on 12/04/26.
//

import SwiftUI
import EventKitUI

struct EventEditViewController: UIViewControllerRepresentable {
    @Binding var isPresented: Bool
    var event: EKEvent
    var eventStore: EKEventStore
    
    func makeCoordinator() -> Coordinator { Coordinator(self) }
    
    func makeUIViewController(context: Context) -> EKEventEditViewController {
        let controller = EKEventEditViewController()
        controller.event = event
        controller.eventStore = eventStore
        controller.editViewDelegate = context.coordinator
        return controller
    }
    
    func updateUIViewController(_ uiViewController: EKEventEditViewController, context: Context) {}
    
    class Coordinator: NSObject, EKEventEditViewDelegate {
        var parent: EventEditViewController
        init(_ parent: EventEditViewController) { self.parent = parent }
        func eventEditViewController(_ controller: EKEventEditViewController, didCompleteWith action: EKEventEditViewAction) {
            parent.isPresented = false
        }
    }
}
