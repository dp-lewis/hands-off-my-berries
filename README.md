# Metropolis - Survival Game Project

A 3D survival game built in Godot featuring comprehensive resource management, building systems, multi-player support, and component-based architecture.

## 🎉 **Current Status: Production-Ready Foundation Complete**

### **Latest Achievements (December 2024)**
- ✅ **Chest Storage System**: Multi-player storage with interaction controls and movement prevention
- ✅ **Death State Management**: Complete input/movement prevention for dead players with respawn capability  
- ✅ **Multi-Player Polish**: Perfect 4-player couch co-op with input isolation
- ✅ **Component Architecture**: 6-component system with zero breaking changes

## 🏗️ Architecture

### Component-Based Player System
**Status**: ✅ **PRODUCTION READY** - Complete refactor from monolithic to component architecture

- **PlayerController** - Main coordinator (400+ lines) managing 6 components
- **PlayerMovement** - Movement, physics, animation with enable/disable control
- **PlayerSurvival** - Health, hunger, thirst, tiredness, death management
- **PlayerBuilder** - Building system with tents and chests
- **PlayerInteraction** - Object proximity, gathering, interaction enable/disable
- **PlayerInputHandler** - Multi-player input mapping with input enable/disable

### Key Features
- **Zero Breaking Changes** - Complete legacy compatibility maintained
- **4-Player Couch Co-op** - Keyboard + 3 gamepads with complete input isolation
- **Signal-Based Communication** - Clean, event-driven component coordination
- **Resource Management** - Comprehensive inventory and resource systems
- **Shelter System** - Day/night survival mechanics

## 🧪 Testing

### Test Framework
Uses **GUT (Godot Unit Test)** for unified, reliable testing.

### Quick Test Commands
```bash
# Run all tests
godot --headless -s addons/gut/gut_cmdln.gd -gdir=tests -gexit

# Run specific component tests
godot --headless -s addons/gut/gut_cmdln.gd -gdir=tests -gselect=test_resource_manager.gd -gexit
```

### Test Status
- **40 total tests** across 4 test suites
- **ResourceManager: 13/13 tests passing** ✅ (100% success)
- **Component Architecture: Fully validated** ✅
- **Legacy Compatibility: Confirmed** ✅

**📖 See [tests/README.md](tests/README.md) for detailed testing documentation**

## 🚀 Development Status

### ✅ **Completed Systems (Production Ready)**
- **Component Architecture** - Complete 6-component system with zero breaking changes
- **Multi-Player Support** - 4-player couch co-op with perfect input isolation
- **Resource Management** - Dynamic system with 13/13 tests passing
- **Survival Mechanics** - Health, hunger, thirst, tiredness, death management
- **Building System** - Tents and chests with resource costs and interaction controls
- **Storage System** - Multi-player chest UI with movement control and anti-recursion
- **Death State System** - Complete input/movement prevention with manual respawn
- **Testing Infrastructure** - 40 tests across 4 suites with comprehensive coverage

### 🎯 **Foundation Complete - Ready for Feature Expansion**
**Technical Debt**: ✅ **ZERO CRITICAL DEBT** - Clean, maintainable codebase  
**Architecture**: ✅ **PRODUCTION READY** - Solid component foundation  
**Multi-Player**: ✅ **FULLY FUNCTIONAL** - 4-player couch co-op working perfectly  
**Testing**: ✅ **COMPREHENSIVE** - 40 tests providing confidence for expansion

### 🌱 **Next Phase: Farming Mechanics Implementation**
With the foundation complete, development focus shifts to implementing comprehensive farming mechanics that will significantly expand gameplay depth while building on the robust component-based architecture.

## 📁 Project Structure

```
metropolis/
├── scenes/players/
│   ├── player_new.gd           # Integrated PlayerController (production ready)
│   ├── player_legacy_backup.gd # Original monolithic backup
│   └── components/             # Component-based architecture
│       ├── player_interaction.gd
│       └── player_input_handler.gd
├── components/                 # Core player components
│   ├── player_movement.gd
│   ├── player_survival.gd
│   └── player_builder.gd
├── tests/                      # GUT-based test suite
│   ├── README.md               # Detailed testing docs
│   ├── test_resource_manager.gd
│   ├── test_player_interaction.gd
│   ├── test_player_input_handler.gd
│   └── test_integrated_player_controller.gd
└── config/
    └── resource_config.gd      # Resource system configuration
```

## � Documentation

Comprehensive documentation is organized in the `/docs` directory:

- **[📖 Documentation Overview](docs/README.md)** - Complete docs navigation
- **[🏗️ Architecture Guide](docs/refactoring/player-refactoring-quick-reference.md)** - Component system reference
- **[🧪 Testing Guide](docs/testing/TESTING_QUICK_REFERENCE.md)** - Test commands and procedures  
- **[🎮 Game Design](docs/design/GAME_DESIGN_DOCUMENT.md)** - Core mechanics and design
- **[⚙️ Game Systems](docs/game-systems/)** - Individual system documentation

## �🛠️ Built With
- **Godot Engine 4.4+** - Game engine
- **GUT Framework** - Testing infrastructure
- **GDScript** - Primary programming language
