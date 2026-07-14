local mod = get_mod("loot_dopamine")

local EventPickupUtils = {}

local EVENT_PICKUP_VALUES = {
	small = 1,
	medium = 5,
	large = 10,
}

local function get_active_event_id()
	local live_event_manager = Managers.live_event
	if not live_event_manager then
		return nil
	end
	
	return live_event_manager:active_event_id()
end

local function get_event_pickup_name(event_id, size)
	if not event_id then
		return nil
	end
	
	local live_event_manager = Managers.live_event
	local active_event = live_event_manager._events and live_event_manager._events[event_id]
	if not active_event then
		return nil
	end
	
	local template_name = active_event.template_name
	if not template_name then
		return nil
	end
	
	local Pickups = require("scripts/settings/pickup/pickups")
	
	local possible_names = {
		string.format("live_event_%s_01_pickup_%s", template_name, size),
		string.format("%s_01_pickup_%s", template_name, size),
	}
	
	for _, name in ipairs(possible_names) do
		if Pickups.by_name[name] then
			return name
		end
	end
	
	return nil
end

function EventPickupUtils.spawn_event_pickup(size, position, rotation, optional_pickup_name)
	size = size or "small"
	position = position or Vector3.zero()
	rotation = rotation or Quaternion.identity()
	
	local pickup_name = optional_pickup_name
	
	if not pickup_name then
		local event_id = get_active_event_id()
		pickup_name = get_event_pickup_name(event_id, size)
	end
	
	if not pickup_name then
		mod:error("Could not find event pickup name for size '%s'. Either specify pickup_name directly or ensure an active event is running.", size)
		return nil
	end
	
	local pickup_system = Managers.state.extension:system("pickup_system")
	if not pickup_system then
		mod:error("PickupSystem not available")
		return nil
	end
	
	return pickup_system:spawn_pickup(pickup_name, position, rotation)
end

function EventPickupUtils.get_active_event_info()
	local live_event_manager = Managers.live_event
	if not live_event_manager then
		return nil
	end
	
	local event_id = live_event_manager:active_event_id()
	if not event_id then
		return nil
	end
	
	local active_event = live_event_manager._events and live_event_manager._events[event_id]
	if not active_event then
		return nil
	end
	
	return {
		event_id = event_id,
		template_name = active_event.template_name,
		name = live_event_manager:get_active_event_name(),
	}
end

function EventPickupUtils.register_event_material_collected(size, player_unit, optional_material_value)
	size = size or "small"
	
	local material_value = optional_material_value or EVENT_PICKUP_VALUES[size]
	if not material_value then
		mod:error("Invalid event pickup size: %s. Use 'small', 'medium', or 'large'", size)
		return false
	end
	
	if not Managers.state.game_session:is_server() then
		mod:warning("register_event_material_collected must be called on server")
		return false
	end
	
	local caused_by_player = Managers.state.player_unit_spawn:owner(player_unit)
	if not caused_by_player then
		mod:error("Could not find player for unit")
		return false
	end
	
	if not caused_by_player.is_server then
		mod:warning("Player is not server, event may not process correctly")
	end
	
	local material_size_lookup = NetworkLookup.material_size_lookup[size]
	if not material_size_lookup then
		mod:error("Invalid material size lookup: %s", size)
		return false
	end
	
	Managers.event:trigger("mutator_pickup_collected", caused_by_player, material_size_lookup, material_value)
	
	return true
end

function EventPickupUtils.generate_event_materials(player_unit, size, count)
	size = size or "small"
	count = count or 1
	
	if not Managers.state.game_session:is_server() then
		mod:warning("generate_event_materials must be called on server")
		return false
	end
	
	for i = 1, count do
		EventPickupUtils.register_event_material_collected(size, player_unit)
	end
	
	return true
end

mod.event_pickup_utils = EventPickupUtils

local function apply_settings()
	if mod.anim_offset then
		mod.anim_offset[1] = mod:get("anim_container_x_offset")
		mod.anim_offset[2] = mod:get("anim_container_y_offset")
	else
		mod.anim_offset = {
			mod:get("anim_container_x_offset"),
			mod:get("anim_container_y_offset"),
			10
		}
	end

	local transparency = mod:get("anim_transparency")

	if mod:get("label_size") == "label_size_default" then
		mod.label_size = 26
		mod.label_y_offset = -11
	elseif mod:get("label_size") == "label_size_large" then
		mod.label_size = 32
		mod.label_y_offset = -8
	elseif mod:get("label_size") == "label_size_largest" then
		mod.label_size = 36
		mod.label_y_offset = -6
	elseif mod:get("label_size") == "label_size_small" then
		mod.label_size = 22
		mod.label_y_offset = -12
	end

	local plasteel_color_name = mod:get("plasteel_color") or "ui_hud_green_light"
	local diamantine_color_name = mod:get("diamantine_color") or "ui_toughness_default"
	local salvage_color_name = mod:get("salvage_color") or "terminal_text_header"
	local scrap_color_name = mod:get("scrap_color") or "terminal_text_header"
	local event_color_name = mod:get("event_material_color") or "terminal_text_header"

	mod.plasteel_color = Color[plasteel_color_name](transparency, true)
	mod.diamantine_color = Color[diamantine_color_name](transparency, true)
	mod.salvage_color = Color[salvage_color_name](transparency, true)
	mod.scrap_color = Color[scrap_color_name](transparency, true)
	mod.event_material_color = Color[event_color_name](transparency, true)
	mod.anim_color = mod.event_material_color

	if mod.apply_widget_settings then
		mod.apply_widget_settings()
	end
end

apply_settings()

mod:register_hud_element({
	filename = "loot_dopamine/scripts/mods/loot_dopamine/HudElementLootDopamine",
	class_name = "HudElementLootDopamine",
	visibility_groups = {
		"tactical_overlay",
		"alive",
		"communication_wheel",
	},
	use_hud_scale = true,
	validation_function = function(params)
		return Managers.state.game_mode:game_mode_name() ~= "hub"
	end
})

mod.on_setting_changed = function()
	apply_settings()
end

function mod.on_game_state_changed(status, state_name)
	if state_name == 'GameplayStateRun' or state_name == "StateGameplay" and status == "enter" then
		apply_settings()
	end
end

mod:hook(CLASS.PickupSystem, "_show_collected_materials_notification",
function(func, self, peer_id, material_type, material_size)
	if material_type == "plasteel" or material_type == "diamantine" then
		local amount = Managers.backend:session_setting("craftingMaterials", material_type, material_size, "value")
		
		if mod.show_floating_text then
			mod.show_floating_text(material_type, material_size, amount)
		end
	end

	if mod:get("disable_base_notification") then
		return
	end
	
	return func(self, peer_id, material_type, material_size)
end)


mod:hook(CLASS.MutatorGameplay, "rpc_player_interacted_mutator_materials",
function(func, self, channel_id, peer_id, material_type_lookup, material_size_lookup, interaction_type_lookup, material_value)
	local material_type = NetworkLookup.material_type_lookup[material_type_lookup]
	local material_size = NetworkLookup.material_size_lookup[material_size_lookup]
	
	if material_type == "event_material" then
		if mod.show_event_material_text then
			local notification_settings = self._side_notification_settings
			mod.show_event_material_text(material_size, material_value, notification_settings)
		end
		
		if mod:get("disable_base_notification") then
			return
		end
	end
	
	return func(self, channel_id, peer_id, material_type_lookup, material_size_lookup, interaction_type_lookup, material_value)
end)

mod:hook(CLASS.MutatorGameplay, "_show_collected_materials_notification",
function(func, self, peer_id, material_type, material_size, interaction_type_lookup, material_value)
	if material_type == "event_material" and mod:get("disable_base_notification") then
		return
	end
	
	return func(self, peer_id, material_type, material_size, interaction_type_lookup, material_value)
end)


mod:hook(CLASS.ExpeditionCurrencyHandler, "_show_collected_materials_notification",
function(func, self, peer_id, amount)
	if mod.show_floating_text then
		mod.show_floating_text("expedition_salvage", nil, amount)
	end

	if mod:get("disable_base_notification") then
		return
	end
	
	return func(self, peer_id, amount)
end)

mod:hook(CLASS.ExpeditionLootHandler, "_show_collected_materials_notification",
function(func, self, peer_id, amount, loot_type)
	if mod.show_floating_text then
		mod.show_floating_text("expedition_loot", nil, amount)
	end

	if mod:get("disable_base_notification") then
		return
	end
	
	return func(self, peer_id, amount, loot_type)
end)


mod:hook(CLASS.HudElementTacticalOverlay, "init", function(func, self, parent, draw_layer, start_scale, optional_context)
	func(self, parent, draw_layer, start_scale, optional_context)
	
	local UIWidget = require("scripts/managers/ui/ui_widget")
	
	local function generate_currency_passes(currency_texture)
		return {
			{ pass_type = "rect", style_id = "reward_background", style = { color = { 200, 0, 0, 0 } } },
			{ pass_type = "texture", style_id = "reward_gradient", value = "content/ui/materials/gradients/gradient_vertical", style = { color = { 32, 169, 211, 158 }, offset = { 0, 0, 1 } } },
			{ pass_type = "texture", style_id = "reward_frame", value = "content/ui/materials/frames/frame_tile_2px", style = { scale_to_material = true, color = Color.terminal_frame(255, true), offset = { 0, 0, 2 } } },
			{ pass_type = "texture", style_id = "reward_icon", value = currency_texture, style = { horizontal_alignment = "right", vertical_alignment = "center", size = { 28, 20 }, offset = { 0, 0, 3 } } },
			{ pass_type = "text", style_id = "reward_text", value = "0", value_id = "amount_id", style = { font_size = 20, font_type = "proxima_nova_bold", text_horizontal_alignment = "right", text_vertical_alignment = "center", text_color = Color.terminal_text_body(255, true), offset = { -28, 0, 3 } } },
		}
	end

	local salvage_def = UIWidget.create_definition(generate_currency_passes("content/ui/materials/icons/currencies/salvage_small"), "crafting_pickup_panel", nil, { 110, 33 })
	local scrap_def = UIWidget.create_definition(generate_currency_passes("content/ui/materials/icons/currencies/tech_remnant_small"), "crafting_pickup_panel", nil, { 110, 33 })
	
	local salvage_widget = self:_create_widget("mod_salvage_info", salvage_def)
	local scrap_widget = self:_create_widget("mod_scrap_info", scrap_def)
	
	salvage_widget.offset = { 0, 50, 0 }
	scrap_widget.offset = { 130, 50, 0 }

	self._left_panel_widgets[#self._left_panel_widgets + 1] = salvage_widget
	self._left_panel_widgets[#self._left_panel_widgets + 1] = scrap_widget
end)

local TextUtils = require("scripts/utilities/ui/text")

mod:hook(CLASS.HudElementTacticalOverlay, "_update_materials_collected", function(func, self, ui_renderer)
	func(self, ui_renderer)
	
	local show_details = self._context.show_left_side_details
	local salvage_widget = self._widgets_by_name.mod_salvage_info
	local scrap_widget = self._widgets_by_name.mod_scrap_info
	
	if not salvage_widget or not scrap_widget then return end
	
	local is_expedition = self._game_mode_name == "expedition"
	
	salvage_widget.visible = show_details and is_expedition
	scrap_widget.visible = show_details and is_expedition
	
	if not is_expedition then return end
	
	local salvage_total = 0
	local scrap_total = 0
	
	local game_mode_manager = Managers.state.game_mode
	if game_mode_manager and game_mode_manager:game_mode_name() == "expedition" then
		local game_mode = game_mode_manager:game_mode()
		if game_mode then
			local peer_id = self._peer_id or Network.peer_id()
			salvage_total = game_mode:expedition_currency(peer_id) or 0
			scrap_total = game_mode:expedition_team_loot() or 0
		end
	end
	
	salvage_widget.content.amount_id = TextUtils.format_currency(salvage_total)
	scrap_widget.content.amount_id = TextUtils.format_currency(scrap_total)
	
	-- Align horizontally the same as plasteel and diamantine
	salvage_widget.offset[1] = self._widgets_by_name.plasteel_info.offset[1]
	scrap_widget.offset[1] = self._widgets_by_name.diamantine_info.offset[1]
end)
