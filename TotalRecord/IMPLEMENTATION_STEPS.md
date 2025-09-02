# 🎯 Game Mode Implementation Steps
## Specific Steps for Your Current Codebase

**Branch**: `feature/game-mode-selection`  
**Current State**: You have 4 games with basic timer functionality, need to add mode selection

---

## 📋 **Current Code Analysis**

### **What You Have:**
- **Memory Match**: Timer-based game with pairs selection
- **Sequence Recall**: Level-based game with sequence memorization  
- **Card Locator**: Grid-based game with memorization phase
- **Speed Match**: Fast-paced matching game
- **TrophyRoom**: Score tracking system with GameType enum

### **What You Need to Add:**
- Game mode selection (Timed vs Infinite)
- Separate score tracking per mode
- Mode-specific game logic

---

## 🏗️ **Step 1: Create Game Mode Data Model**

### **File to Create**: `Models/GameMode.swift`
**What to do:**
1. Create a new `Models` folder in your project root
2. Create `GameMode.swift` file
3. Define an enum with two cases: `timed` and `infinite`
4. Make it `Codable` and `CaseIterable` for easy use

**Learning Questions:**
- Why put this in a separate Models folder?
- What does `Codable` allow you to do?
- How will you use `CaseIterable` in your UI?

### **File to Modify**: `TrophyRoom/TrophyRoomModels.swift`
**What to do:**
1. Add a `GameMode` property to your existing score tracking structures
2. Modify `TrophyScore` to track scores per mode
3. Update any functions that save/load scores

**Learning Questions:**
- How will you modify existing score structures?
- What happens to existing saved scores?
- How will you handle backward compatibility?

---

## 🎮 **Step 2: Update Setup Views**

### **Files to Modify:**
- `Games/MemoryMatch/MemoryMatchSetupView.swift`
- `Games/SequenceRecall/SequenceRecallSetupView.swift`
- `Games/CardLocator/CardLocatorSetupView.swift`
- `Games/SpeedMatch/SpeedMatchSetupView.swift`

### **What to do in each file:**
1. **Add mode selection state**: Create `@State private var selectedMode: GameMode = .timed`
2. **Add mode selection UI**: Create buttons or picker for mode selection
3. **Update game initialization**: Pass the selected mode to the game view
4. **Add mode explanation**: Show users what each mode does

### **UI Design Considerations:**
- **Visual distinction**: Use different colors for each mode
- **Clear explanation**: Help users understand the difference
- **Default selection**: Start with timed mode selected
- **Accessibility**: Make sure screen readers can understand the options

**Learning Questions:**
- Where should the mode selection go in the existing UI?
- How will you make the selection visually clear?
- What happens if a user doesn't select a mode?

---

## ⚙️ **Step 3: Update Game Views**

### **Files to Modify:**
- `Games/MemoryMatch/MemoryMatchView.swift`
- `Games/SequenceRecall/SequenceRecallView.swift`
- `Games/CardLocator/CardLocatorView.swift`
- `Games/SpeedMatch/SpeedMatchView.swift`

### **What to do in each file:**
1. **Add mode parameter**: Accept `GameMode` in the initializer
2. **Add mode-specific state**: Add lives for infinite mode, different timer logic
3. **Update game logic**: Handle different rules for each mode
4. **Update UI**: Show different information based on mode

### **Mode-Specific Logic:**

#### **Memory Match:**
- **Timed Mode**: Keep existing timer logic
- **Infinite Mode**: Add 3 lives, remove timer, continue playing after completion

#### **Sequence Recall:**
- **Timed Mode**: Level progression with time limits
- **Infinite Mode**: 3 lives, wrong sequence = lose life, continue playing

#### **Card Locator:**
- **Timed Mode**: Time limit for finding targets
- **Infinite Mode**: 3 lives, wrong guess = lose life, continue rounds

#### **Speed Match:**
- **Timed Mode**: Time pressure with level progression
- **Infinite Mode**: 3 lives, wrong guess = lose life, continue matching

**Learning Questions:**
- How will you handle the different timer logic?
- What happens when a game ends in each mode?
- How will you show different UI elements?

---

## 📊 **Step 4: Update Score Tracking**

### **File to Modify**: `TrophyRoom/TrophyRoomModels.swift`
**What to do:**
1. **Add mode to score structures**: Include GameMode in score tracking
2. **Update save functions**: Save scores per game + mode combination
3. **Update load functions**: Load and display scores per mode
4. **Add mode-specific achievements**: Create achievements for each mode

### **Score Storage Strategy:**
- **Key structure**: `[GameType][GameMode] = Score`
- **Best scores**: Track best score for each game + mode
- **Statistics**: Track games played, win rate per mode
- **Achievements**: Mode-specific goals and milestones

**Learning Questions:**
- How will you structure the data efficiently?
- What happens when a user gets a new best score?
- How will you display scores for each mode?

---

## 🎯 **Step 5: Game-Specific Implementation Details**

### **Memory Match Game:**
**Current**: Timer-based with pairs selection
**Changes needed:**
- **Timed Mode**: Keep existing logic, maybe adjust time limits
- **Infinite Mode**: 
  - Remove timer completely
  - Add 3 lives system
  - Add wrong press counter (5 wrong = 1 life)
  - Continue playing after completing all pairs
  - Show lives remaining in UI

**Learning Questions:**
- How will you handle the transition from timed to infinite?
- What's a fair life system for infinite mode?
- How will you show progress in infinite mode?

### **Sequence Recall Game:**
**Current**: Level-based with increasing sequence length
**Changes needed:**
- **Timed Mode**: 
  - Add time limit per level
  - Complete 8 levels to win
  - Time bonus for correct sequences
- **Infinite Mode**:
  - 3 lives system
  - Wrong sequence = lose 1 life
  - Continue with fixed sequence length (8 items)
  - Show lives remaining

**Learning Questions:**
- How will you balance difficulty between modes?
- What's a good time limit for timed mode?
- How will you handle level progression differently?

### **Card Locator Game:**
**Current**: Memorization phase + guessing phase
**Changes needed:**
- **Timed Mode**:
  - Time limit for finding all targets
  - Complete 5 levels to win
  - Wrong guess = game over
- **Infinite Mode**:
  - 3 lives system
  - Wrong guess = lose 1 life
  - Continue playing indefinitely
  - Show lives remaining

**Learning Questions:**
- How will you handle the memorization phase differently?
- What's a fair time limit for timed mode?
- How will you balance difficulty?

### **Speed Match Game:**
**Current**: Fast-paced matching with time pressure
**Changes needed:**
- **Timed Mode**:
  - Complete 10 levels to win
  - Time pressure increases with levels
  - Wrong guess = game over
- **Infinite Mode**:
  - 3 lives system
  - Wrong guess = lose 1 life
  - Continue matching indefinitely
  - Show lives remaining

**Learning Questions:**
- How will you handle the time pressure differently?
- What makes each mode engaging?
- How will you balance difficulty?

---

## 🧪 **Step 6: Testing Strategy**

### **What to Test:**
1. **Mode Selection**: Can users select and change modes?
2. **Game Logic**: Do games behave correctly in each mode?
3. **Score Tracking**: Are scores saved separately for each mode?
4. **UI/UX**: Is the interface clear and intuitive?

### **Testing Checklist:**
- [ ] Mode selection works in all games
- [ ] Timed mode has appropriate time limits
- [ ] Infinite mode has working lives system
- [ ] Scores are saved correctly per mode
- [ ] UI shows correct information for each mode
- [ ] No crashes or bugs
- [ ] User experience is smooth

**Learning Questions:**
- How will you test that scores are separate?
- What edge cases should you consider?
- How will you verify the user experience?

---

## 🚀 **Step 7: Implementation Order**

### **Recommended Sequence:**
1. **Start with Memory Match** (easiest to modify)
2. **Create the data model** (GameMode enum)
3. **Update Memory Match setup** (add mode selection)
4. **Update Memory Match game** (add infinite mode logic)
5. **Test Memory Match thoroughly**
6. **Apply same pattern to other games**
7. **Update score tracking system**
8. **Test all games together**

### **Why This Order:**
- **Memory Match is simplest**: Basic timer + pairs logic
- **Incremental approach**: Learn from one game before others
- **Risk management**: If something breaks, only one game is affected
- **Learning curve**: Build confidence with simpler changes first

**Learning Questions:**
- Why start with one game instead of all at once?
- What's the benefit of this incremental approach?
- How will you know when each step is complete?

---

## 💡 **Key SwiftUI Concepts to Master**

### **State Management:**
- **@State**: Track mode selection in setup views
- **@Binding**: Pass mode selection to game views
- **@ObservedObject**: Handle score updates

### **Navigation:**
- **NavigationLink**: Navigate between setup and game
- **Data passing**: Pass mode selection to game views
- **State restoration**: Maintain mode selection

### **Conditional UI:**
- **if/else statements**: Show different UI based on mode
- **Ternary operators**: Quick conditional styling
- **Group/AnyView**: Handle complex conditional views

### **Data Persistence:**
- **UserDefaults**: Save mode preferences and scores
- **Codable**: Make your data structures saveable
- **Error handling**: Handle save/load failures

**Learning Questions:**
- How will you use @State for mode selection?
- What's the difference between @State and @Binding?
- How will you handle data persistence?

---

## 🎯 **Success Criteria**

### **Before You Start:**
- [ ] Understand what each mode should do
- [ ] Know how to structure the data
- [ ] Plan the UI/UX design
- [ ] Decide on implementation order

### **During Implementation:**
- [ ] Mode selection works correctly
- [ ] Games behave differently in each mode
- [ ] Scores are saved separately
- [ ] UI is clear and intuitive

### **After Implementation:**
- [ ] All games support both modes
- [ ] Scores are displayed correctly
- [ ] No bugs or crashes
- [ ] User experience is smooth

---

## 🤔 **Questions to Ask Yourself**

### **Before Starting:**
1. What exactly should happen in each mode?
2. How will users understand the difference?
3. What's the best way to structure this code?
4. How will I test that everything works?

### **During Development:**
1. Is this the most efficient way to do this?
2. How will this affect existing functionality?
3. What edge cases should I consider?
4. How will users react to this feature?

### **After Completion:**
1. Does this meet all the requirements?
2. Is the user experience smooth?
3. Are there any bugs or issues?
4. How could this be improved?

---

**Remember**: Take your time, experiment, and learn from each step. The goal is to understand the concepts, not just complete the task. Good luck! 🚀
