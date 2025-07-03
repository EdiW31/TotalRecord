## High-Level Task Breakdown: Sequence Recall Game (Task 4)

- [x] Task 4.1: Define Game State and Sequence Data
  - ✅ Success Criteria: State variables for the current sequence, user input, and game phase are defined in SequenceRecallView.
  - 🎯 Learning Goal: Understand how to use @State and arrays to manage dynamic game data.
  - 📘 Educator Notes:
    - Use @State for variables that change and affect the UI.
    - Example: @State var sequence: [Int] = [], @State var userInput: [Int] = [], @State var isShowingSequence: Bool = true.

- [x] Task 4.2: Generate and Display the Sequence
  - ✅ Success Criteria: The game generates a random sequence and displays it to the user, one item at a time, with animation.
  - 🎯 Learning Goal: Learn about timers, delays, and animating UI in SwiftUI.
  - 📘 Educator Notes:
    - Use Timer or DispatchQueue.main.asyncAfter to animate the sequence.
    - Example: Show each card for 0.5 seconds, then move to the next.

- [ ] Task 4.3: Collect User Input
  - ✅ Success Criteria: User can tap buttons/cards to input the sequence after it is shown.
  - 🎯 Learning Goal: Handle tap gestures and update arrays in SwiftUI.
  - 📘 Educator Notes:
    - Use Button or tappable CardView for input.
    - Append each tap to userInput.

- [ ] Task 4.4: Compare User Input to Sequence
  - ✅ Success Criteria: After each tap, the app checks if the input matches the sequence so far, and ends the round on a mistake.
  - 🎯 Learning Goal: Implement logic to compare arrays and provide feedback.
  - 📘 Educator Notes:
    - Use zip(userInput, sequence) to compare.
    - If input is correct and complete, advance to next round.

- [ ] Task 4.5: Advance Game or End on Mistake
  - ✅ Success Criteria: If the user completes the sequence, the next round starts with a longer sequence. If they make a mistake, show a "Game Over" message and allow restart.
  - 🎯 Learning Goal: Manage game state transitions and UI feedback.
  - 📘 Educator Notes:
    - Use state variables to control the view (e.g., isGameOver).
    - Show alerts or overlays for feedback.

- [ ] Task 4.6: Add Restart and Difficulty Controls
  - ✅ Success Criteria: User can restart the game and optionally select difficulty (starting sequence length).
  - 🎯 Learning Goal: Build simple setup and reset logic.
  - 📘 Educator Notes:
    - Add a "Restart" button.
    - Optionally, let user pick sequence length at the start. 