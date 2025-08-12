# Chest Storage System - Testing Guide

## 🎯 What We Just Implemented

The chest storage system now connects to the player's ResourceManager and allows full resource transfer between players and chests!

## ✅ Features Added

### **Resource Transfer System**
- **Store Resources**: Transfer wood/food from player inventory to chest
- **Retrieve Resources**: Transfer wood/food from chest to player inventory  
- **Capacity Management**: Respects both player inventory limits and chest storage capacity
- **Smart Transfer**: Only transfers what's possible (no overflow/underflow)

### **Simple Text-Based Interface**
- Shows current player resources and chest contents
- Displays clear storage options with number key shortcuts
- Auto-closes after 30 seconds or when operation is complete

### **Integration with Game Systems**
- **Player Interaction System**: Chests now appear in interaction priority list
- **Resource Manager**: Uses the game's existing resource management system
- **Input Handling**: Simple number key shortcuts for quick operations

---

## 🎮 How to Test

### **Step 1: Build a Chest (Should work from previous implementation)**
1. Start the game
2. Press **Build button** to cycle: tent → chest → exit → tent...
3. Place a chest (costs **4 wood**)
4. Wait for chest to be built (appears solid, not transparent)

### **Step 2: Test Storage Interface**
1. Walk up to the built chest
2. Press **E** (interact button)
3. You should see:
   ```
   === CHEST STORAGE INTERFACE ===
   Player Resources:
     Wood: [current amount]
     Food: [current amount]
   
   Chest Contents:
     Storage: 0/20 items
   
   Storage Options:
     Press 1: Store 5 wood
     Press 2: Store 5 food
     Press 3: Take 5 wood
     Press 4: Take 5 food
     Press 5: Store all wood
     Press 6: Store all food
     Press 7: Take all wood
     Press 8: Take all food
   ================================
   ```

### **Step 3: Test Resource Transfers**
1. **Store wood**: Press **1** to store 5 wood (if you have any)
2. **Store food**: Press **2** to store 5 food (if you have any)
3. **Retrieve wood**: Press **3** to take 5 wood from chest
4. **Retrieve food**: Press **4** to take 5 food from chest
5. **Store all**: Press **5** or **6** to store all wood/food
6. **Take all**: Press **7** or **8** to take all wood/food from chest

### **Step 4: Test Edge Cases**
1. **Full inventory**: Try to retrieve when player inventory is full
2. **Empty chest**: Try to retrieve from empty chest
3. **Full chest**: Try to store when chest is at capacity (20 items)
4. **No resources**: Try to store when player has nothing

---

## 🔍 Expected Output

### **Successful Transfer Example:**
```
Transferred 5 wood to chest
Chest status: 5/20 items
  Wood: 5
Closed storage interface for player Player1
```

### **Error Handling Examples:**
```
Player inventory is full!
Chest has no wood!
Chest is full! Cannot store wood.
Player has no food to store!
```

---

## 🚀 Next Steps

Once this is working, we can enhance it with:

1. **Visual UI**: Replace text interface with proper drag-and-drop UI
2. **More Resources**: Add stone, tools, etc. to the storage system
3. **Chest Varieties**: Small/Medium/Large chests with different capacities
4. **Quick Commands**: Hotkeys for common operations
5. **Chest Labels**: Name your chests for organization

---

## 🐛 If Something Doesn't Work

**No interaction prompt?**
- Make sure the chest is built (solid, not transparent)
- Check that you're close enough to the chest
- Try walking in and out of the chest area

**Numbers don't work?**
- Make sure the storage interface is open (you should see the menu)
- Try different number keys (1-8)
- Check console output for any error messages

**No resource transfer?**
- Verify you have resources to transfer
- Check if inventories are full
- Look for error messages in console

Let me know how the testing goes! 🎯
