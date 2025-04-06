// FocusFlowApp.swift
import SwiftUI

@main
struct FocusFlowApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}

// Models/Session.swift
import Foundation

struct Session: Identifiable, Codable {
    let id: UUID
    let date: Date
    let duration: TimeInterval
    let isBreak: Bool
    
    init(duration: TimeInterval, isBreak: Bool) {
        self.id = UUID()
        self.date = Date()
        self.duration = duration
        self.isBreak = isBreak
    }
}

// ViewModels/TimerViewModel.swift
import Foundation
import Combine

class TimerViewModel: ObservableObject {
    @Published var timeRemaining: Int = 1500 // 25 min default
    @Published var isRunning = false
    @Published var isBreak = false

    private var timer: AnyCancellable?
    private var sessionLength: Int = 1500 // default
    private var breakLength: Int = 300 // default
    
    func startTimer() {
        isRunning = true
        timer = Timer.publish(every: 1, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                self?.tick()
            }
    }
    
    func stopTimer() {
        isRunning = false
        timer?.cancel()
    }

    private func tick() {
        guard timeRemaining > 0 else {
            stopTimer()
            switchSession()
            return
        }
        timeRemaining -= 1
    }

    func reset() {
        stopTimer()
        timeRemaining = isBreak ? breakLength : sessionLength
    }

    private func switchSession() {
        isBreak.toggle()
        timeRemaining = isBreak ? breakLength : sessionLength
        startTimer()
    }
}

// Views/ContentView.swift
import SwiftUI

struct ContentView: View {
    @StateObject var timerVM = TimerViewModel()

    var body: some View {
        VStack(spacing: 40) {
            Text(timerVM.isBreak ? "Break Time" : "Focus Time")
                .font(.largeTitle)

            Text(formatTime(timerVM.timeRemaining))
                .font(.system(size: 64, weight: .bold, design: .monospaced))

            HStack(spacing: 20) {
                Button(action: {
                    timerVM.isRunning ? timerVM.stopTimer() : timerVM.startTimer()
                }) {
                    Text(timerVM.isRunning ? "Pause" : "Start")
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                
                Button(action: {
                    timerVM.reset()
                }) {
                    Text("Reset")
                        .padding()
                        .background(Color.gray)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
            }
        }
        .padding()
    }

    func formatTime(_ seconds: Int) -> String {
        let mins = seconds / 60
        let secs = seconds % 60
        return String(format: "%02d:%02d", mins, secs)
    }
}

