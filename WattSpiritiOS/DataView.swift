//
//  DataView.swift
//  WattSpiritiOS
//
//  Created by Robin Bouchet on 17/05/2025.
//

import SwiftUI
import Charts

struct DataView: View {
    
    @EnvironmentObject var navManager: NavigationManager
    @State var startDate: Date = Date()
    @State var endDate: Date = Date()
    @State var consumptionData: [ConsumptionData] = []
    @State var singleDayMode: Bool = false
    
    var body: some View {
        VStack {
            // Date Pickers
            DatePicker("Start Date", selection: $startDate, displayedComponents: .date)
                .datePickerStyle(.compact)
            DatePicker("End Date", selection: $endDate, displayedComponents: .date)
                .datePickerStyle(.compact)
            
            Toggle("Single day view", isOn: $singleDayMode)
                .padding(.vertical)

            Button("Fetch Data") {
                Task {
                    do {
                        consumptionData = try await NetworkingManager().getData(startDate: startDate, endDate: endDate)
                    } catch {
                        print("Error fetching data: \(error.localizedDescription)")
                    }
                }
            }
            .buttonStyle(.borderedProminent)
            .padding(.top)

            let allConsumptions = consumptionData.flatMap(\.consumption)

            if !allConsumptions.isEmpty {
                Chart {
                    if singleDayMode {
                        // Overlay: Group by day and normalize to midnight
                        let grouped = Dictionary(grouping: allConsumptions) { (entry) -> Date in
                            let fullDate = Date(timeIntervalSince1970: entry.time / 1000)
                            return Calendar.current.startOfDay(for: fullDate)
                        }
                        ForEach(grouped.sorted(by: { $0.key < $1.key }), id: \.key) { (day, entries) in
                            ForEach(entries, id: \.time) { entry in
                                LineMark(
                                    x: .value("Time", timeOfDay(from: entry.time)),
                                    y: .value("Value", entry.value)
                                )
                                .foregroundStyle(by: .value("Day", dayFormatted(day)))
                            }
                        }
                    } else {
                        // Normal mode: full timestamp
                        ForEach(allConsumptions, id: \.time) { entry in
                            LineMark(
                                x: .value("Time", Date(timeIntervalSince1970: entry.time / 1000)),
                                y: .value("Value", entry.value)
                            )
                        }
                    }
                }
                .chartXAxis {
                    AxisMarks(values: .automatic(desiredCount: 6)) { value in
                        AxisGridLine()
                        AxisValueLabel(format: singleDayMode ? .dateTime.hour().minute() : .dateTime.day().hour().minute())
                    }
                }
                .frame(height: 300)
                .padding()
            } else {
                Spacer()
                Text("No data yet.")
                    .foregroundColor(.gray)
                Spacer()
            }
        }
        .padding()
    }

    private func dayFormatted(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE dd MMM"
        return formatter.string(from: date)
    }

    private func timeOfDay(from millis: TimeInterval) -> Date {
        let fullDate = Date(timeIntervalSince1970: millis / 1000)
        let components = Calendar.current.dateComponents([.hour, .minute, .second], from: fullDate)
        return Calendar.current.date(from: components)!
    }
}
