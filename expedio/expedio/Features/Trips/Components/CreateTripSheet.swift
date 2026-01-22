//
//  CreateTripSheet.swift
//  Expedio
//
//  Sheet for creating a new trip
//

import SwiftUI

struct CreateTripSheet: View {
    @Environment(\.dismiss) private var dismiss
    @State private var name = ""
    @State private var destination = ""
    @State private var startDate = Date()
    @State private var endDate = Date()
    @State private var includeDates = false

    let onCreate: (String, String, Date?, Date?) -> Void

    private var isValid: Bool {
        !name.trimmingCharacters(in: .whitespaces).isEmpty &&
        !destination.trimmingCharacters(in: .whitespaces).isEmpty
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Trip Details") {
                    TextField("Trip Name", text: $name)
                    TextField("Destination", text: $destination)
                }

                Section {
                    Toggle("Include Dates", isOn: $includeDates)
                    if includeDates {
                        DatePicker("Start Date", selection: $startDate, displayedComponents: .date)
                        DatePicker("End Date", selection: $endDate, in: startDate..., displayedComponents: .date)
                    }
                }
            }
            .navigationTitle("New Trip")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Create") {
                        onCreate(
                            name.trimmingCharacters(in: .whitespaces),
                            destination.trimmingCharacters(in: .whitespaces),
                            includeDates ? startDate : nil,
                            includeDates ? endDate : nil
                        )
                    }
                    .disabled(!isValid)
                }
            }
        }
    }
}
