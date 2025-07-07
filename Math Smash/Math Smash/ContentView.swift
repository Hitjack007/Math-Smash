//
//  ContentView.swift
//  Math Smash
//
//  Created by Mark Greene on 07/07/2025.
//
import SwiftUI

struct Question: Identifiable, Equatable {
    let id = UUID()
    let left: Int
    let right: Int

    var text: String { "\(left) × \(right)" }
    var answer: Int { left * right }
}

struct ContentView: View {
    enum GameState {
        case settings, playing, results
    }

    @State private var gameState: GameState = .settings

    @State private var maxTable = 2
    @State private var questionCount = 5

    @State private var questions: [Question] = []
    @State private var currentQuestionIndex = 0
    @State private var userAnswer = ""
    @State private var score = 0

    @State private var feedbackText = ""
    @State private var feedbackColor = Color.clear
    @State private var showFeedback = false
    
    var background: some View {
        VStack {
            LinearGradient(colors: [.blue, .purple], startPoint: .top, endPoint: .bottom)
                .ignoresSafeArea(edges: .all)
        }
    }

    var body: some View {
        ZStack {
            background

            VStack(spacing: 30) {
                Spacer()

                switch gameState {
                case .settings:
                    settingsView
                case .playing:
                    gameView
                case .results:
                    resultsView
                }

                Spacer()
            }
            .padding()
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
            .animation(.default, value: gameState)
        }
    }

    var settingsView: some View {
        VStack(spacing: 20) {
            Text("Choose Tables")
                .font(.title)
                .bold()
            HStack {
                Text("Up to: \(maxTable)")
                Stepper("", value: $maxTable, in: 2...12)
                    .labelsHidden()
            }

            Text("Number of Questions")
                .font(.title2)
                .bold()
            HStack(spacing: 15) {
                ForEach([5,10,20], id: \.self) { count in
                    Button {
                        questionCount = count
                    } label: {
                        Text("\(count)")
                            .frame(width: 50, height: 50)
                            .background(questionCount == count ? Color.blue : Color.gray.opacity(0.3))
                            .foregroundColor(questionCount == count ? .white : .black)
                            .cornerRadius(25)
                    }
                }
            }

            Button(action: startGame) {
                Text("Start Game")
                    .bold()
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            .padding(.top, 20)
        }
    }

    var gameView: some View {
        VStack(spacing: 20) {
            Text("Question \(currentQuestionIndex + 1) of \(questions.count)")
                .font(.headline)

            Text(questions[currentQuestionIndex].text)
                .font(.largeTitle)
                .bold()

            Text(userAnswer.isEmpty ? "?" : userAnswer)
                .font(.system(size: 50, weight: .bold))
                .frame(width: 150, height: 80)
                .background(Color.gray.opacity(0.2))
                .cornerRadius(15)

            keypad

            Button(action: submitAnswer) {
                Text("Submit")
                    .bold()
                    .padding()
                    .frame(width: 140)
                    .background(userAnswer.isEmpty ? Color.gray : Color.green)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            .disabled(userAnswer.isEmpty)

            if showFeedback {
                Text(feedbackText)
                    .font(.title3)
                    .bold()
                    .foregroundColor(feedbackColor)
                    .transition(.opacity)
            }
        }
    }

    var keypad: some View {
        let buttons = [
            ["1","2","3"],
            ["4","5","6"],
            ["7","8","9"],
            ["C","0","⌫"]
        ]

        return VStack(spacing: 10) {
            ForEach(buttons, id: \.self) { row in
                HStack(spacing: 15) {
                    ForEach(row, id: \.self) { label in
                        Button {
                            handleKeypadTap(label)
                        } label: {
                            Text(label)
                                .font(.title2)
                                .frame(width: 50, height: 50)
                                .background(Color.blue.opacity(0.6))
                                .foregroundColor(.white)
                                .cornerRadius(25)
                        }
                    }
                }
            }
        }
    }

    var resultsView: some View {
        VStack(spacing: 20) {
            Text("Great Job!")
                .font(.largeTitle)
                .bold()

            Text("You scored \(score) out of \(questions.count)")
                .font(.title2)

            Button(action: resetGame) {
                Text("Play Again")
                    .bold()
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
        }
    }

    // Helper functions

    func startGame() {
        questions = generateQuestions(upTo: maxTable, count: questionCount)
        currentQuestionIndex = 0
        userAnswer = ""
        score = 0
        showFeedback = false
        gameState = .playing
    }

    func submitAnswer() {
        guard let answerInt = Int(userAnswer) else { return }

        let correctAnswer = questions[currentQuestionIndex].answer
        if answerInt == correctAnswer {
            score += 1
            feedbackText = "Correct!"
            feedbackColor = .green
        } else {
            feedbackText = "Wrong!"
            feedbackColor = .red
        }

        withAnimation {
            showFeedback = true
        }

        userAnswer = ""

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            withAnimation {
                showFeedback = false
            }

            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                if currentQuestionIndex + 1 < questions.count {
                    currentQuestionIndex += 1
                } else {
                    gameState = .results
                }
            }
        }
    }

    func resetGame() {
        gameState = .settings
        questions = []
        currentQuestionIndex = 0
        userAnswer = ""
        score = 0
        showFeedback = false
    }

    func generateQuestions(upTo max: Int, count: Int) -> [Question] {
        var generated: [Question] = []

        while generated.count < count {
            let left = Int.random(in: 1...max)
            let right = Int.random(in: 1...max)
            let q = Question(left: left, right: right)

            if !generated.contains(q) {
                generated.append(q)
            }
        }

        return generated
    }

    func handleKeypadTap(_ label: String) {
        switch label {
        case "C":
            userAnswer = ""
        case "⌫":
            if !userAnswer.isEmpty {
                userAnswer.removeLast()
            }
        default:
            if userAnswer.count < 3 {
                userAnswer.append(label)
            }
        }
    }
}

#Preview {
    ContentView()
}

