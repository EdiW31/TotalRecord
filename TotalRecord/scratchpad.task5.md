# Task 5: Card Locator Game Mode - Implementation Plan

## Current Progress
- [x] Setup screen (`CardLocatorSetupView.swift`) with title, description, and Start Game button
- [x] Navigation from setup to game view using state
- [x] Basic grid layout in `CardLocatorView.swift` using GeometryReader and ForEach
- [x] GameCards component used for each card in the grid

## Next Steps (To Do)
- [x] 1. Fix visibility/import issues so CardLocatorView and GameCards are recognized in all files
- [x] 2. Add state to track which cards are targets (to be memorized) and which are revealed/hidden
- [x] 3. Implement memorization phase: randomly select a few cards to show as targets, display them for a few seconds
- [x] 4. Hide all cards after memorization phase, prompt user to tap the target cards from memory
- [x] 5. Handle user taps: reveal tapped cards, check if they are correct (target) or incorrect
- [x] 6. Provide feedback: highlight correct/incorrect taps, show a message for win/lose
- [x] 7. Add scoring: track number of correct taps, mistakes, and rounds completed
- [x] 8. Add a "Play Again" or "Restart" button to reset the game state
- [ ] 9. Polish UI: add animations for card reveal/hide, feedback colors, and responsive layout
- [x] 10. (Optional) Add difficulty settings to setup screen (e.g., grid size, number of targets)

## Notes
- Use GeometryReader for responsive grid sizing
- Use @State/@StateObject for game state and UI updates
- Use Timer or DispatchQueue for memorization phase timing
- Use the color palette documented in CardLocatorView.swift for consistent styling

---
Check off each step as you complete it. Update this file with lessons learned, bugs, or reusable patterns as you go! 