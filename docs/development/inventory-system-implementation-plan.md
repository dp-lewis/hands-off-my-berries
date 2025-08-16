# 🎒 Inventory System Implementation Plan

## Overview

This plan outlines the implementation of a comprehensive inventory system that extends beyond simple resource quantities to support individual items with states, tools, and player item selection. Building on your existing ResourceManager foundation.

## Current Architecture Analysis

### ✅ Existing Foundation (Strong)
- **ResourceManager**: Dictionary-based storage with capacity management
- **PlayerInteraction**: Component-based interaction system
- **PlayerInputHandler**: Multi-player input mapping
- **UI Components**: Resource displays with progress bars
- **Chest Storage**: Working item transfer system

### 🎯 Target Architecture (Enhanced)

```
PlayerInventory (new)
├── InventorySlots: Array[InventorySlot]
├── SelectedSlot: int (hotbar selection)
├── ItemSelection: InventorySlot
└── SignalSystem: item_selected, slot_changed

InventorySlot (new)
├── ItemType: String (bucket, watering_can, berries)
├── ItemState: String (empty, full, broken)
├── Quantity: int (for stackable items)
└── ItemData: Dictionary (custom properties)

ItemManager (new)
├── ItemDefinitions: Dictionary[String, ItemDefinition]
├── ItemFactory: create_item(), use_item()
└── ItemInteractions: right_click, left_click behaviors

InventoryUI (enhanced)
├── HotbarDisplay: Visual slot selection
├── FullInventoryView: Complete item grid
└── ItemTooltips: Detailed item information
```

## Implementation Phases

### **Phase 1: Core Item System (Foundation)**

#### 1.1 Create Item Definition System
**File**: `systems/items/item_definition.gd`

```gdscript
class_name ItemDefinition
extends Resource

@export var item_id: String
@export var display_name: String
@export var description: String
@export var icon_texture: Texture2D
@export var max_stack_size: int = 1
@export var item_type: String  # "tool", "consumable", "resource"
@export var is_stackable: bool = false
@export var has_durability: bool = false
@export var max_durability: int = 100

# Tool-specific properties
@export var tool_efficiency: float = 1.0
@export var tool_actions: Array[String] = []  # ["water", "dig", "chop"]

# State management
@export var possible_states: Array[String] = ["empty"]  # ["empty", "full"]
@export var default_state: String = "empty"
```

#### 1.2 Create Inventory Slot System
**File**: `systems/items/inventory_slot.gd`

```gdscript
class_name InventorySlot
extends RefCounted

var item_definition: ItemDefinition
var quantity: int = 0
var current_state: String = ""
var durability: int = 100
var custom_data: Dictionary = {}

signal slot_changed()

func set_item(definition: ItemDefinition, qty: int = 1, state: String = ""):
	item_definition = definition
	quantity = qty
	current_state = state if state != "" else definition.default_state
	durability = definition.max_durability
	slot_changed.emit()

func is_empty() -> bool:
	return item_definition == null or quantity <= 0

func can_stack_with(other_slot: InventorySlot) -> bool:
	if not item_definition or not other_slot.item_definition:
		return false
	
	return (item_definition.item_id == other_slot.item_definition.item_id 
		and current_state == other_slot.current_state
		and item_definition.is_stackable)

func get_display_name() -> String:
	if not item_definition:
		return ""
	
	var name = item_definition.display_name
	if current_state != item_definition.default_state:
		name += " (" + current_state.capitalize() + ")"
	
	return name
```

#### 1.3 Create Player Inventory Component
**File**: `components/player_inventory.gd`

```gdscript
class_name PlayerInventory
extends "res://components/player_component.gd"

# Inventory configuration
@export var inventory_size: int = 20
@export var hotbar_size: int = 8

# Inventory storage
var inventory_slots: Array[InventorySlot] = []
var selected_hotbar_slot: int = 0

# Signals
signal inventory_changed(slot_index: int)
signal selected_slot_changed(new_slot: int)
signal item_used(item: InventorySlot)

func _on_initialize():
	# Initialize empty slots
	for i in range(inventory_size):
		inventory_slots.append(InventorySlot.new())
		inventory_slots[i].slot_changed.connect(_on_slot_changed.bind(i))
	
	print("PlayerInventory initialized with ", inventory_size, " slots")

func add_item(item_definition: ItemDefinition, quantity: int = 1, state: String = "") -> int:
	"""Add items to inventory, returns amount actually added"""
	var remaining = quantity
	
	# First try to stack with existing items
	if item_definition.is_stackable:
		for slot in inventory_slots:
			if not slot.is_empty() and slot.item_definition.item_id == item_definition.item_id:
				var can_add = min(remaining, item_definition.max_stack_size - slot.quantity)
				if can_add > 0:
					slot.quantity += can_add
					remaining -= can_add
					slot.slot_changed.emit()
				
				if remaining <= 0:
					break
	
	# Then fill empty slots
	if remaining > 0:
		for slot in inventory_slots:
			if slot.is_empty():
				var to_add = min(remaining, item_definition.max_stack_size)
				slot.set_item(item_definition, to_add, state)
				remaining -= to_add
				
				if remaining <= 0:
					break
	
	return quantity - remaining

func get_selected_item() -> InventorySlot:
	"""Get currently selected hotbar item"""
	if selected_hotbar_slot < inventory_slots.size():
		return inventory_slots[selected_hotbar_slot]
	return null

func use_selected_item() -> bool:
	"""Use the currently selected item"""
	var selected = get_selected_item()
	if selected and not selected.is_empty():
		item_used.emit(selected)
		return true
	return false
```

### **Phase 2: Specific Item Types**

#### 2.1 Create Bucket Item System
**File**: `systems/items/bucket_item.gd`

```gdscript
extends RefCounted
class_name BucketItem

# Bucket states and behaviors
static func get_bucket_definition() -> ItemDefinition:
	var def = ItemDefinition.new()
	def.item_id = "bucket"
	def.display_name = "Bucket"
	def.description = "Used to collect and store water"
	def.max_stack_size = 1
	def.item_type = "tool"
	def.is_stackable = false
	def.possible_states = ["empty", "full"]
	def.default_state = "empty"
	def.tool_actions = ["collect_water", "pour_water", "drink_water"]
	return def

static func use_bucket(bucket_slot: InventorySlot, player: Node3D, action_type: String) -> bool:
	"""Handle bucket usage based on context and action"""
	match action_type:
		"collect_water":
			return collect_water(bucket_slot, player)
		"pour_water": 
			return pour_water(bucket_slot, player)
		"drink_water":
			return drink_water(bucket_slot, player)
		_:
			return false

static func collect_water(bucket_slot: InventorySlot, player: Node3D) -> bool:
	"""Collect water into bucket"""
	if bucket_slot.current_state != "empty":
		print("Bucket is already full!")
		return false
	
	# Check if player is near water source
	var interaction = player.get_component("interaction")
	if interaction and interaction.nearby_water:
		bucket_slot.current_state = "full"
		bucket_slot.slot_changed.emit()
		print("Filled bucket with water")
		return true
	else:
		print("No water source nearby")
		return false

static func pour_water(bucket_slot: InventorySlot, player: Node3D) -> bool:
	"""Pour water from bucket (for crop watering)"""
	if bucket_slot.current_state != "full":
		print("Bucket is empty!")
		return false
	
	# Check if player is near something that can be watered
	var interaction = player.get_component("interaction")
	if interaction and interaction.nearby_food:
		var crop = interaction.nearby_food
		if crop.has_method("water_crop"):
			if crop.water_crop(player):
				bucket_slot.current_state = "empty"
				bucket_slot.slot_changed.emit()
				print("Used bucket to water crop")
				return true
	
	print("Nothing here needs watering")
	return false

static func drink_water(bucket_slot: InventorySlot, player: Node3D) -> bool:
	"""Drink water from bucket"""
	if bucket_slot.current_state != "full":
		print("Bucket is empty!")
		return false
	
	# Restore thirst
	var survival = player.get_component("survival")
	if survival and survival.has_method("restore_thirst"):
		survival.restore_thirst(50.0)  # Restore 50 thirst points
		bucket_slot.current_state = "empty"
		bucket_slot.slot_changed.emit()
		print("Drank water from bucket")
		return true
	
	return false
```

#### 2.2 Item Registry System
**File**: `systems/items/item_registry.gd`

```gdscript
class_name ItemRegistry
extends RefCounted

static var _definitions: Dictionary = {}
static var _initialized: bool = false

static func initialize():
	if _initialized:
		return
	
	# Register all item definitions
	register_item(BucketItem.get_bucket_definition())
	
	# Register berry seeds
	var berry_seeds = ItemDefinition.new()
	berry_seeds.item_id = "berry_seeds"
	berry_seeds.display_name = "Berry Seeds"
	berry_seeds.description = "Plant these to grow berry bushes"
	berry_seeds.max_stack_size = 10
	berry_seeds.item_type = "consumable"
	berry_seeds.is_stackable = true
	register_item(berry_seeds)
	
	# Register watering can
	var watering_can = ItemDefinition.new()
	watering_can.item_id = "watering_can"
	watering_can.display_name = "Watering Can"
	watering_can.description = "More efficient than a bucket for watering crops"
	watering_can.max_stack_size = 1
	watering_can.item_type = "tool"
	watering_can.has_durability = true
	watering_can.max_durability = 50
	watering_can.tool_efficiency = 2.0
	watering_can.tool_actions = ["water_crops"]
	register_item(watering_can)
	
	_initialized = true
	print("ItemRegistry initialized with ", _definitions.size(), " items")

static func register_item(definition: ItemDefinition):
	_definitions[definition.item_id] = definition

static func get_item_definition(item_id: String) -> ItemDefinition:
	if not _initialized:
		initialize()
	
	return _definitions.get(item_id, null)

static func get_all_item_ids() -> Array[String]:
	if not _initialized:
		initialize()
	
	return _definitions.keys()
```

### **Phase 3: Hotbar and Item Selection**

#### 3.1 Update PlayerInputHandler for Item Selection
**File**: `components/player_input_handler.gd` (additions)

```gdscript
# Add to existing PlayerInputHandler class

# Hotbar selection mappings
var hotbar_keys: Dictionary = {}

func setup_input_mappings():
	# ... existing mappings ...
	
	# Hotbar selection mappings (1-8 keys)
	hotbar_keys = {
		0: ["p1_slot_1", "p1_slot_2", "p1_slot_3", "p1_slot_4", 
			"p1_slot_5", "p1_slot_6", "p1_slot_7", "p1_slot_8"],
		1: ["p2_slot_1", "p2_slot_2", "p2_slot_3", "p2_slot_4",
			"p2_slot_5", "p2_slot_6", "p2_slot_7", "p2_slot_8"],
		# ... other players
	}

func _process(delta: float) -> void:
	# ... existing input handling ...
	
	# Handle hotbar selection
	if player_id in hotbar_keys:
		for i in range(hotbar_keys[player_id].size()):
			if Input.is_action_just_pressed(hotbar_keys[player_id][i]):
				hotbar_slot_selected.emit(i)

# Add new signal
signal hotbar_slot_selected(slot_index: int)
```

#### 3.2 Update PlayerInteraction for Item Usage
**File**: `components/player_interaction.gd` (enhancements)

```gdscript
# Add to existing PlayerInteraction class

var player_inventory # : PlayerInventory component reference

func _on_initialize() -> void:
	# ... existing initialization ...
	
	# Get inventory component
	player_inventory = get_sibling_component("inventory")
	if player_inventory:
		player_inventory.item_used.connect(_on_item_used)

func _handle_interaction_pressed():
	# Check if player has selected item that can be used
	if player_inventory:
		var selected_item = player_inventory.get_selected_item()
		if selected_item and not selected_item.is_empty():
			# Try to use the selected item based on context
			if try_use_selected_item(selected_item):
				return  # Item usage handled the interaction
	
	# ... existing interaction logic ...

func try_use_selected_item(item_slot: InventorySlot) -> bool:
	"""Try to use the selected item based on current context"""
	var item_id = item_slot.item_definition.item_id
	
	match item_id:
		"bucket":
			return try_use_bucket(item_slot)
		"watering_can":
			return try_use_watering_can(item_slot)
		"berry_seeds":
			return try_plant_seeds(item_slot)
		_:
			return false

func try_use_bucket(bucket_slot: InventorySlot) -> bool:
	"""Context-sensitive bucket usage"""
	# Near water source = collect water
	if nearby_water and bucket_slot.current_state == "empty":
		return BucketItem.collect_water(bucket_slot, player_controller)
	
	# Near crop = water crop
	elif nearby_food and bucket_slot.current_state == "full":
		return BucketItem.pour_water(bucket_slot, player_controller)
	
	# No context = drink water
	elif bucket_slot.current_state == "full":
		return BucketItem.drink_water(bucket_slot, player_controller)
	
	return false
```

### **Phase 4: UI Integration**

#### 4.1 Create Hotbar UI Component
**File**: `ui/components/hotbar_ui.gd`

```gdscript
class_name HotbarUI
extends HBoxContainer

var hotbar_slots: Array[Control] = []
var target_inventory: PlayerInventory
var selected_slot: int = 0

signal slot_clicked(slot_index: int)

func setup_for_inventory(inventory: PlayerInventory):
	target_inventory = inventory
	create_hotbar_slots()
	
	# Connect to inventory signals
	inventory.inventory_changed.connect(_on_inventory_changed)
	inventory.selected_slot_changed.connect(_on_selected_slot_changed)

func create_hotbar_slots():
	# Clear existing slots
	for child in get_children():
		child.queue_free()
	
	hotbar_slots.clear()
	
	# Create hotbar slots
	for i in range(target_inventory.hotbar_size):
		var slot_control = create_slot_control(i)
		add_child(slot_control)
		hotbar_slots.append(slot_control)

func create_slot_control(slot_index: int) -> Control:
	var slot = PanelContainer.new()
	slot.custom_minimum_size = Vector2(64, 64)
	slot.add_theme_stylebox_override("panel", create_slot_style(false))
	
	var vbox = VBoxContainer.new()
	slot.add_child(vbox)
	
	# Item icon
	var icon = TextureRect.new()
	icon.custom_minimum_size = Vector2(48, 48)
	icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	vbox.add_child(icon)
	
	# Item count label
	var count_label = Label.new()
	count_label.text = ""
	count_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(count_label)
	
	# Make clickable
	slot.gui_input.connect(_on_slot_clicked.bind(slot_index))
	
	return slot

func _on_slot_clicked(event: InputEvent, slot_index: int):
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		slot_clicked.emit(slot_index)

func update_slot_display(slot_index: int):
	if slot_index >= hotbar_slots.size() or not target_inventory:
		return
	
	var slot_control = hotbar_slots[slot_index]
	var inventory_slot = target_inventory.inventory_slots[slot_index]
	
	# Update visual style
	var is_selected = (slot_index == selected_slot)
	slot_control.add_theme_stylebox_override("panel", create_slot_style(is_selected))
	
	# Update icon and count
	var icon = slot_control.get_child(0).get_child(0) as TextureRect
	var count_label = slot_control.get_child(0).get_child(1) as Label
	
	if inventory_slot.is_empty():
		icon.texture = null
		count_label.text = ""
	else:
		icon.texture = inventory_slot.item_definition.icon_texture
		if inventory_slot.quantity > 1:
			count_label.text = str(inventory_slot.quantity)
		else:
			count_label.text = ""

func create_slot_style(is_selected: bool) -> StyleBoxFlat:
	var style = StyleBoxFlat.new()
	style.bg_color = Color.DARK_GRAY
	style.border_width_left = 2
	style.border_width_right = 2
	style.border_width_top = 2
	style.border_width_bottom = 2
	
	if is_selected:
		style.border_color = Color.YELLOW
	else:
		style.border_color = Color.GRAY
	
	return style
```

#### 4.2 Integration with Existing UI
**File**: `ui/player_ui.gd` (additions)

```gdscript
# Add to existing PlayerUI class

@onready var hotbar_ui: HotbarUI = $HotbarContainer/HotbarUI  # Add to scene

func setup_for_player(player: Node3D):
	# ... existing setup ...
	
	# Setup hotbar UI
	var player_inventory = player.get_component("inventory")
	if player_inventory and hotbar_ui:
		hotbar_ui.setup_for_inventory(player_inventory)
		hotbar_ui.slot_clicked.connect(_on_hotbar_slot_clicked)

func _on_hotbar_slot_clicked(slot_index: int):
	if target_player:
		var inventory = target_player.get_component("inventory")
		if inventory:
			inventory.selected_hotbar_slot = slot_index
			inventory.selected_slot_changed.emit(slot_index)
```

## Integration Strategy

### **Step 1: Foundation (Week 1)**
1. Create item definition and slot systems
2. Create basic PlayerInventory component  
3. Add PlayerInventory to player scene
4. Test basic item addition/removal

### **Step 2: Core Items (Week 2)**
1. Implement bucket item with all states
2. Create item registry system
3. Add basic hotbar selection (keyboard only)
4. Test bucket fill/pour/drink cycle

### **Step 3: UI Integration (Week 3)**
1. Create hotbar UI component
2. Add hotbar to existing player UI
3. Implement visual item selection feedback
4. Test full UI → item selection → usage pipeline

### **Step 4: Advanced Features (Week 4)**
1. Add watering can and berry seeds
2. Integrate with existing berry crop system
3. Add chest storage for items (not just resources)
4. Create item tooltips and information display

## Technical Considerations

### **Resource vs Item Distinction**
- **Resources**: Basic quantities (wood, food) - keep existing ResourceManager
- **Items**: Individual objects with states/properties - new PlayerInventory
- **Bridge**: Items can be consumed to add resources (berries → food)

### **Backward Compatibility**
- Keep existing ResourceManager for basic resources
- PlayerInventory handles complex items
- Both systems can coexist and interact

### **Performance**
- Use RefCounted for InventorySlot (no scene overhead)
- Signal-based UI updates (only update changed slots)
- Lazy-load item icons and definitions

### **Multiplayer Ready**
- Each player has independent PlayerInventory
- Items have unique IDs and serializable state
- Ready for future save/load and networking

## Success Metrics

### **Phase 1 Complete When:**
- [ ] Player can have bucket in inventory slot
- [ ] Bucket shows "empty" or "full" state
- [ ] Can select bucket with number keys

### **Phase 2 Complete When:**
- [ ] Player can collect water near water source
- [ ] Player can pour water on berry crops
- [ ] Player can drink water from bucket
- [ ] All state transitions work properly

### **Phase 3 Complete When:**
- [ ] Hotbar UI shows selected item
- [ ] Visual feedback for item selection
- [ ] Mouse and keyboard item selection both work

### **Phase 4 Complete When:**
- [ ] Multiple item types work (bucket, watering can, seeds)
- [ ] Items integrate with existing chest storage
- [ ] Item tooltips show useful information

## Future Extensions

### **After Core Implementation:**
1. **Tool Durability**: Tools break after use, need repair
2. **Crafting System**: Combine resources to create items
3. **Advanced Tools**: Hoe for tilling, scythe for harvesting
4. **Item Variants**: Different bucket sizes, tool qualities
5. **Container Items**: Bags that expand inventory space

This comprehensive system will provide the foundation for rich item-based gameplay while maintaining compatibility with your existing systems!
