## Background and Motivation
> TotalRecard is an iOS app designed to help users improve memory through card-based games and the memory palace technique. The goal is to make memory training fun, challenging, and educational, while also deepening understanding of SwiftUI, game logic, and data persistence.

## Key Challenges and Analysis
> - Designing flexible, scalable game logic for multiple game types
> - Managing complex state and UI updates in SwiftUI
> - Implementing smooth, animated grid layouts for cards
> - Persisting user progress, scores, and palace data locally
> - Balancing usability, accessibility, and visual appeal
> - Introducing spatial learning concepts in an intuitive way
> - Ensuring code is testable and maintainable

## High-Level Task Breakdown
- [ ] Task 1: Set up SwiftUI project structure and navigation
  - ✅ Success Criteria: App launches to a home screen with navigation to "Games" and "Memory Palace" sections.
  - 🎯 Learning Goal: Understand SwiftUI app structure, navigation stacks, and view composition.
  - 📘 Educator Notes: 
    - SwiftUI uses `@main` and `App` protocol for entry point.
    - Navigation is managed with `NavigationStack` or `NavigationView`.
    - Try creating a simple two-screen navigation example.
    - **Exercise:** Build a minimal app with a home screen and a button to a second view.

- [ ] Task 2: Implement Memory Match (match-the-pairs) game logic and UI
  - ✅ Success Criteria: User can play a basic match-the-pairs game with cards flipping and matching.
  - 🎯 Learning Goal: Learn about state management, grid layouts, and user interaction in SwiftUI.
  - 📘 Educator Notes:
    - Use `@State` and `@StateObject` for reactive UI.
    - Grids can be built with `LazyVGrid`.
    - Card flip animations use `.rotation3DEffect`.
    - **Exercise:** Make a 2x2 grid of tappable cards that flip on tap.

- [ ] Task 3: Add scoring, timer, and difficulty settings to Memory Match
  - ✅ Success Criteria: Game tracks score, time, and allows difficulty selection.
  - 🎯 Learning Goal: Implement timers, scoring logic, and user settings.
  - 📘 Educator Notes:
    - Use `Timer.publish` and `.onReceive` for game timers.
    - Store scores in `@State` or `@ObservedObject`.
    - **Exercise:** Add a timer to a view and display elapsed time.

- [ ] Task 4: Implement Sequence Recall game mode
  - ✅ Success Criteria: User can view and repeat a sequence of cards, with increasing difficulty.
  - 🎯 Learning Goal: Manage dynamic sequences and validate user input.
  - 📘 Educator Notes:
    - Arrays and randomization for sequence generation.
    - Compare user input to stored sequence.
    - **Exercise:** Generate a random array and check if user input matches.

- [ ] Task 5: Implement Card Locator game mode
  - ✅ Success Criteria: User can remember and tap the location of hidden cards.
  - 🎯 Learning Goal: Use spatial layouts and tap detection.
  - 📘 Educator Notes:
    - Use `GeometryReader` for custom layouts.
    - Track card positions and user taps.
    - **Exercise:** Build a grid where tapping a cell reveals its content.

- [ ] Task 6: Implement Speed Match game mode
  - ✅ Success Criteria: User matches patterns quickly under a timer.
  - 🎯 Learning Goal: Handle fast-paced input and real-time feedback.
  - 📘 Educator Notes:
    - Use timers and state to manage fast rounds.
    - Provide immediate feedback on correct/incorrect matches.
    - **Exercise:** Create a button that must be tapped within a time limit.

- [ ] Task 7: Build Memory Palace creation and editing UI
  - ✅ Success Criteria: User can create, name, and edit palaces with rooms/locations.
  - 🎯 Learning Goal: Model hierarchical data and build forms in SwiftUI.
  - 📘 Educator Notes:
    - Use structs/classes for palace and room models.
    - Use `Form` and `List` for input and editing.
    - **Exercise:** Make a form to add/edit items in a list.

- [ ] Task 8: Implement card-location assignment and recall in palaces
  - ✅ Success Criteria: User can assign cards to locations and later recall them.
  - 🎯 Learning Goal: Build association logic and recall UI.
  - 📘 Educator Notes:
    - Use dictionaries or arrays for associations.
    - Design recall screens to test memory.
    - **Exercise:** Map items to locations and display them.

- [ ] Task 9: Add local persistence for scores, palaces, and assignments
  - ✅ Success Criteria: All user data persists between app launches.
  - 🎯 Learning Goal: Use SwiftData or UserDefaults for persistence.
  - 📘 Educator Notes:
    - Compare `UserDefaults`, `SwiftData`, and `CoreData`.
    - Save/load simple models.
    - **Exercise:** Store and retrieve a value using UserDefaults.

- [ ] Task 10: Polish UI with animations, accessibility, and responsive layouts
  - ✅ Success Criteria: App looks good on all devices, is accessible, and uses smooth animations.
  - 🎯 Learning Goal: Apply animation and accessibility best practices.
  - 📘 Educator Notes:
    - Use `.animation`, `.transition`, and `.accessibilityLabel`.
    - Test with different device previews.
    - **Exercise:** Animate a view's appearance/disappearance.

- [ ] Task 11: Add tests for scoring, timing, and sequence validation logic
  - ✅ Success Criteria: Key logic is covered by unit tests.
  - 🎯 Learning Goal: Write and run tests in Xcode.
  - 📘 Educator Notes:
    - Use `XCTest` for unit testing.
    - Test pure functions and logic.
    - **Exercise:** Write a test for a function that adds two numbers.

## Project Status Board
- [ ] Task 1: Set up SwiftUI project structure and navigation
- [ ] Task 2: Implement Memory Match game logic and UI
- [ ] Task 3: Add scoring, timer, and difficulty to Memory Match
- [ ] Task 4: Implement Sequence Recall game mode
- [ ] Task 5: Implement Card Locator game mode
- [ ] Task 6: Implement Speed Match game mode
- [ ] Task 7: Build Memory Palace creation and editing UI
- [ ] Task 8: Implement card-location assignment and recall
- [ ] Task 9: Add local persistence for scores, palaces, assignments
- [ ] Task 10: Polish UI with animations and accessibility
- [ ] Task 11: Add tests for scoring, timing, sequence validation

## Executor's Feedback or Assistance Requests
> (To be filled during execution: blockers, bugs, or questions for the user.)

## Lessons
> (To be filled during execution: bugs, fixes, reusable patterns, and key insights.) 