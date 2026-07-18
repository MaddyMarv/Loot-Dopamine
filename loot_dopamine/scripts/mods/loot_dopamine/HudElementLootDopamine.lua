local mod = get_mod("loot_dopamine")

local UIWorkspaceSettings = require("scripts/settings/ui/ui_workspace_settings")
local UIWidget = require("scripts/managers/ui/ui_widget")
local WalletSettings = require("scripts/settings/wallet_settings")
local TextUtils = require("scripts/utilities/ui/text")

local function get_active_event_wallet_settings(live_event_manager)
	if not live_event_manager then
		return nil
	end
	if live_event_manager.get_active_event_wallet_settings then
		return live_event_manager:get_active_event_wallet_settings()
	end
	local event_id = live_event_manager.active_event_id and live_event_manager:active_event_id()
	return event_id and live_event_manager.get_event_wallet_settings and live_event_manager:get_event_wallet_settings(event_id) or nil
end

local font_size_anim = 140
local size = { 60, 40 }
local sizeAnim = { 1000, font_size_anim }
local currency_info_size = { 110, 33 }

local function generate_currency_passes(currency_texture)
	return {
		{
			pass_type = "rect",
			style_id = "reward_background",
			style = {
				color = { 200, 0, 0, 0 },
			},
		},
		{
			pass_type = "texture",
			style_id = "reward_gradient",
			value = "content/ui/materials/gradients/gradient_vertical",
			style = {
				color = { 32, 169, 211, 158 },
				offset = { 0, 0, 1 },
			},
		},
		{
			pass_type = "texture",
			style_id = "reward_frame",
			value = "content/ui/materials/frames/frame_tile_2px",
			style = {
				scale_to_material = true,
				color = Color.terminal_frame(255, true),
				offset = { 0, 0, 2 },
			},
		},
		{
			pass_type = "texture",
			style_id = "reward_icon",
			value = currency_texture,
			style = {
				horizontal_alignment = "right",
				vertical_alignment = "center",
				size = { 28, 20 },
				offset = { 0, 0, 3 },
			},
		},
		{
			pass_type = "text",
			style_id = "reward_text",
			value = "0",
			value_id = "amount_id",
			style = {
				font_size = 20,
				font_type = "proxima_nova_bold",
				text_horizontal_alignment = "right",
				text_vertical_alignment = "center",
				text_color = Color.terminal_text_body(255, true),
				offset = { -28, 0, 3 },
			},
		},
	}
end

local scenegraph_definition = {
	screen = UIWorkspaceSettings.screen,
	animContainer = {
		parent = "screen",
		vertical_alignment = "center",
		horizontal_alignment = "center",
		size = sizeAnim,
		position = { 0, 0, 10 },
	},
	totalsContainer = {
		parent = "screen",
		vertical_alignment = "top",
		horizontal_alignment = "center",
		size = { 250, 120 },
		position = { 0, 50, 10 },
	},
	plasteelTotal = {
		parent = "totalsContainer",
		vertical_alignment = "top",
		horizontal_alignment = "center",
		size = currency_info_size,
		position = { -60, 0, 1 },
	},
	diamantineTotal = {
		parent = "totalsContainer",
		vertical_alignment = "top",
		horizontal_alignment = "center",
		size = currency_info_size,
		position = { 60, 0, 1 },
	},
	salvageTotal = {
		parent = "totalsContainer",
		vertical_alignment = "top",
		horizontal_alignment = "center",
		size = currency_info_size,
		position = { -60, 40, 1 },
	},
	lootTotal = {
		parent = "totalsContainer",
		vertical_alignment = "top",
		horizontal_alignment = "center",
		size = currency_info_size,
		position = { 60, 40, 1 },
	},
}

local styleAnimated = {
	line_spacing = 1.2,
	drop_shadow = true,
	font_type = "machine_medium",
	text_color = Color.terminal_text_header(255, true),
	size = sizeAnim,
	text_horizontal_alignment = "center",
	text_vertical_alignment = "bottom",
	offset = { 0, 0, 0 },
}

local outlineColor = Color.black(255, true)
local outlineOffset = 2

local function create_animated_text_def()
	return UIWidget.create_definition(
		{
			{
				value_id = "text",
				style_id = "text_outline_1",
				pass_type = "text",
				value = "",
				style = table.clone(styleAnimated),
			},
			{
				value_id = "text",
				style_id = "text_outline_2",
				pass_type = "text",
				value = "",
				style = table.clone(styleAnimated),
			},
			{
				value_id = "text",
				style_id = "text_outline_3",
				pass_type = "text",
				value = "",
				style = table.clone(styleAnimated),
			},
			{
				value_id = "text",
				style_id = "text_outline_4",
				pass_type = "text",
				value = "",
				style = table.clone(styleAnimated),
			},
			{
				value_id = "text",
				style_id = "text",
				pass_type = "text",
				value = "",
				style = styleAnimated,
			},
		},
		"animContainer"
	)
end

local widget_definitions = {
	plasteelTotal = UIWidget.create_definition(
		generate_currency_passes("content/ui/materials/icons/currencies/plasteel_small"),
		"plasteelTotal",
		nil,
		currency_info_size
	),
	diamantineTotal = UIWidget.create_definition(
		generate_currency_passes("content/ui/materials/icons/currencies/diamantine_small"),
		"diamantineTotal",
		nil,
		currency_info_size
	),
	salvageTotal = UIWidget.create_definition(
		generate_currency_passes("content/ui/materials/icons/currencies/salvage_small"),
		"salvageTotal",
		nil,
		currency_info_size
	),
	lootTotal = UIWidget.create_definition(
		generate_currency_passes("content/ui/materials/icons/currencies/tech_remnant_small"),
		"lootTotal",
		nil,
		currency_info_size
	),
}

local HudElementLootDopamine = class("HudElementLootDopamine", "HudElementBase")

HudElementLootDopamine.init = function(self, parent, draw_layer, start_scale)
	HudElementLootDopamine.super.init(self, parent, draw_layer, start_scale, {
		scenegraph_definition = scenegraph_definition,
		widget_definitions = widget_definitions,
	})

	self.duration_seconds = 1.5

	self._active_popups = {}
	self._next_popup_idx = 1
	self._max_popups = 15

	for i = 1, self._max_popups do
		local name = "animatedText_" .. i
		local def = create_animated_text_def()
		local widget = self:_create_widget(name, def)
		self._widgets[#self._widgets + 1] = widget
	end

	self.totals_timer = 0
	self.totals_timer_running = false
	self.totals_duration_seconds = 3.0
	self.totals_alpha = 0

	self._shake_timer = 0
	self._shake_intensity = 0

	mod.show_floating_text = function(material_type, material_size, amount)
		local wallet_settings = WalletSettings[material_type]

		local current_color = nil
		local current_text = ""


		if material_type == "event_material" then
			local live_event_manager = Managers.live_event
			if live_event_manager then
				wallet_settings = get_active_event_wallet_settings(live_event_manager)
			end

			if wallet_settings then
				local material_name = "Event Material"
				if wallet_settings.pickup_localization_by_size and wallet_settings.pickup_localization_by_size[material_size] then
					material_name = Localize(wallet_settings.pickup_localization_by_size[material_size])
				elseif wallet_settings.display_name then
					material_name = Localize(wallet_settings.display_name)
				end
				local text = string.format("+%d %s", amount, material_name)
				current_color = mod.event_material_color
				current_text = text
				self:_start_popup_animation(current_text, current_color)
				return
			end
		end

		if not wallet_settings then
			return
		end

		local material_name = Localize(wallet_settings.display_name)
		local text = string.format("+%d %s", amount, material_name)

		if material_type == "plasteel" then
			current_color = mod.plasteel_color
		elseif material_type == "diamantine" then
			current_color = mod.diamantine_color
		elseif material_type == "expedition_salvage" then
			current_color = mod.salvage_color
		elseif material_type == "expedition_loot" then
			current_color = mod.scrap_color
		else
			current_color = mod.anim_color
		end

		current_text = text
		self:_start_popup_animation(current_text, current_color)

		if mod:get("enable_shake") then
			local shake_triggered = false
			if amount >= 25 then
				self._shake_intensity = 4
				shake_triggered = true
			elseif #self._active_popups >= 3 then
				self._shake_intensity = 2
				shake_triggered = true
			end

			if shake_triggered then
				self._shake_timer = 0.5
			end
		end


		if mod:get("show_totals") and material_type ~= "event_material" then
			self:_show_totals(material_type, amount)
		end
	end

	mod.show_event_material_text = function(material_size, material_value, optional_notification_settings)
		local live_event_manager = Managers.live_event
		local event_material_settings = nil

		if live_event_manager then
			event_material_settings = get_active_event_wallet_settings(live_event_manager)
		end

		local material_name = "Event Material"
		local pickup_localization_by_size = nil

		if optional_notification_settings and optional_notification_settings.pickup_localization_by_size then
			pickup_localization_by_size = optional_notification_settings.pickup_localization_by_size
		elseif event_material_settings and event_material_settings.pickup_localization_by_size then
			pickup_localization_by_size = event_material_settings.pickup_localization_by_size
		end

		if material_size and type(material_size) == "string" and pickup_localization_by_size then
			local localization_key = pickup_localization_by_size[material_size]

			if localization_key then
				material_name = Localize(localization_key)
			elseif event_material_settings and event_material_settings.display_name then
				material_name = Localize(event_material_settings.display_name)
			end
		elseif event_material_settings and event_material_settings.display_name then
			material_name = Localize(event_material_settings.display_name)
		end

		local text = string.format("+%d %s", material_value, material_name)
		self:_start_popup_animation(text, mod.event_material_color)
	end

	local plasteel_widget = self._widgets_by_name.plasteelTotal
	local diamantine_widget = self._widgets_by_name.diamantineTotal
	local salvage_widget = self._widgets_by_name.salvageTotal
	local loot_widget = self._widgets_by_name.lootTotal
	plasteel_widget.visible = false
	diamantine_widget.visible = false
	salvage_widget.visible = false
	loot_widget.visible = false

	mod.apply_widget_settings = function()
		local font_size = mod.label_size
		size[2] = font_size
		local widgets = self._widgets_by_name
		local transparency = mod:get("anim_transparency") or 255
		local current_outline_color = Color.black(transparency, true)
		for i = 1, self._max_popups do
			local widget = widgets["animatedText_" .. i]
			if widget then
				widget.style.text.font_size = font_size
				widget.style.text_outline_1.font_size = font_size
				widget.style.text_outline_2.font_size = font_size
				widget.style.text_outline_3.font_size = font_size
				widget.style.text_outline_4.font_size = font_size

				widget.style.text_outline_1.text_color = current_outline_color
				widget.style.text_outline_2.text_color = current_outline_color
				widget.style.text_outline_3.text_color = current_outline_color
				widget.style.text_outline_4.text_color = current_outline_color
			end
		end
	end
	mod.apply_widget_settings()
end

HudElementLootDopamine._start_popup_animation = function(self, text, color)
	local idx = self._next_popup_idx
	self._next_popup_idx = (self._next_popup_idx % self._max_popups) + 1

	local popup = {
		widget_idx = idx,
		text = text,
		color = color,
		timer = 0,
		target_x = math.random(-80, 80),
		start_y = mod.anim_offset[2],
		start_x = mod.anim_offset[1]
	}

	local found = false
	for i = 1, #self._active_popups do
		if self._active_popups[i].widget_idx == idx then
			self._active_popups[i] = popup
			found = true
			break
		end
	end

	if not found then
		table.insert(self._active_popups, popup)
	end

	local widget = self._widgets_by_name["animatedText_" .. idx]
	widget.content.text = text
	if color then
		widget.style.text.text_color = table.clone(color)
	end
	widget.alpha_multiplier = 1
end

HudElementLootDopamine._update_animation = function(self, dt, shake_x, shake_y)
	for i = #self._active_popups, 1, -1 do
		local popup = self._active_popups[i]
		popup.timer = popup.timer + dt
		local t = popup.timer / self.duration_seconds

		local widget = self._widgets_by_name["animatedText_" .. popup.widget_idx]

		if t > 1 then
			widget.alpha_multiplier = 0
			widget.content.text = ""
			table.remove(self._active_popups, i)
		else
			local current_x = math.lerp(popup.start_x, popup.start_x + popup.target_x, t) + (shake_x or 0)
			local multiplier = math.pow(2.2, t * 5.5 + 2)
			local drift_y = t * multiplier
			local current_y = popup.start_y - drift_y + (shake_y or 0)

			local anim_font_scale = math.min(1, drift_y * 6.6)
			local font_size = mod.label_size * anim_font_scale
			widget.style.text.font_size = font_size
			widget.style.text_outline_1.font_size = font_size
			widget.style.text_outline_2.font_size = font_size
			widget.style.text_outline_3.font_size = font_size
			widget.style.text_outline_4.font_size = font_size

			widget.style.text.offset[1] = current_x
			widget.style.text.offset[2] = current_y
			widget.style.text.offset[3] = mod.anim_offset[3]

			widget.style.text_outline_1.offset[1] = current_x - outlineOffset
			widget.style.text_outline_1.offset[2] = current_y
			widget.style.text_outline_1.offset[3] = mod.anim_offset[3] - 1

			widget.style.text_outline_2.offset[1] = current_x + outlineOffset
			widget.style.text_outline_2.offset[2] = current_y
			widget.style.text_outline_2.offset[3] = mod.anim_offset[3] - 1

			widget.style.text_outline_3.offset[1] = current_x
			widget.style.text_outline_3.offset[2] = current_y - outlineOffset
			widget.style.text_outline_3.offset[3] = mod.anim_offset[3] - 1

			widget.style.text_outline_4.offset[1] = current_x
			widget.style.text_outline_4.offset[2] = current_y + outlineOffset
			widget.style.text_outline_4.offset[3] = mod.anim_offset[3] - 1

			if t > 0.6 then
				local alpha_t = (t - 0.6) * 2.5
				widget.alpha_multiplier = 1 - alpha_t
			else
				widget.alpha_multiplier = 1
			end
		end
	end
end

HudElementLootDopamine._total_materials_collected = function(self, material_type, current_pickup_amount)
	local total = 0

	if material_type == "plasteel" or material_type == "diamantine" then
		local pickup_system = Managers.state.extension:system("pickup_system")
		local collected_materials = pickup_system:get_collected_materials()
		local small_value = Managers.backend:session_setting("craftingMaterials", material_type, "small", "value")
		local large_value = Managers.backend:session_setting("craftingMaterials", material_type, "large", "value")
		local small_count = collected_materials[material_type] and collected_materials[material_type].small or 0
		local large_count = collected_materials[material_type] and collected_materials[material_type].large or 0

		total = small_count * small_value + large_count * large_value
		if current_pickup_amount and not pickup_system._is_server then
			total = total + current_pickup_amount
		end
	elseif material_type == "expedition_salvage" then
		local game_mode_manager = Managers.state.game_mode
		if game_mode_manager and game_mode_manager:game_mode_name() == "expedition" then
			local game_mode = game_mode_manager:game_mode()
			if game_mode then
				total = game_mode:expedition_currency(Network.peer_id()) or 0
			end
		end
	elseif material_type == "expedition_loot" then
		local game_mode_manager = Managers.state.game_mode
		if game_mode_manager and game_mode_manager:game_mode_name() == "expedition" then
			local game_mode = game_mode_manager:game_mode()
			if game_mode then
				total = game_mode:expedition_team_loot() or 0
			end
		end
	end

	return TextUtils.format_currency(total)
end

HudElementLootDopamine._show_totals = function(self, current_material_type, current_pickup_amount)
	self.totals_timer_running = true
	self.totals_timer = 0

	local plasteel_widget = self._widgets_by_name.plasteelTotal
	local diamantine_widget = self._widgets_by_name.diamantineTotal
	local salvage_widget = self._widgets_by_name.salvageTotal
	local loot_widget = self._widgets_by_name.lootTotal

	local plasteel_amount = current_material_type == "plasteel" and current_pickup_amount or nil
	local diamantine_amount = current_material_type == "diamantine" and current_pickup_amount or nil
	plasteel_widget.content.amount_id = self:_total_materials_collected("plasteel", plasteel_amount)
	diamantine_widget.content.amount_id = self:_total_materials_collected("diamantine", diamantine_amount)

	plasteel_widget.visible = true
	diamantine_widget.visible = true

	local is_expedition = Managers.state.game_mode and Managers.state.game_mode:game_mode_name() == "expedition"

	if is_expedition then
		self:set_scenegraph_position("totalsContainer", nil, 130, nil)
	else
		self:set_scenegraph_position("totalsContainer", nil, 50, nil)
	end

	if is_expedition then
		local salvage_amount = current_material_type == "expedition_salvage" and current_pickup_amount or nil
		local loot_amount = current_material_type == "expedition_loot" and current_pickup_amount or nil

		salvage_widget.content.amount_id = self:_total_materials_collected("expedition_salvage", salvage_amount)
		loot_widget.content.amount_id = self:_total_materials_collected("expedition_loot", loot_amount)

		salvage_widget.visible = true
		loot_widget.visible = true
	else
		salvage_widget.visible = false
		loot_widget.visible = false
	end
end

HudElementLootDopamine._update_totals_animation = function(self, dt)
	self.totals_timer = self.totals_timer + dt
	local t = self.totals_timer / self.totals_duration_seconds

	local plasteel_widget = self._widgets_by_name.plasteelTotal
	local diamantine_widget = self._widgets_by_name.diamantineTotal
	local salvage_widget = self._widgets_by_name.salvageTotal
	local loot_widget = self._widgets_by_name.lootTotal

	if t < 0.2 then
		self.totals_alpha = math.min(1, t * 5)
	elseif t > 0.8 then
		self.totals_alpha = math.max(0, 1 - (t - 0.8) * 5)
	else
		self.totals_alpha = 1
	end

	local base_y = 50
	local anim_y = base_y - math.sin(t * math.pi) * 20

	plasteel_widget.alpha_multiplier = self.totals_alpha
	diamantine_widget.alpha_multiplier = self.totals_alpha
	salvage_widget.alpha_multiplier = self.totals_alpha
	loot_widget.alpha_multiplier = self.totals_alpha

	if t >= 1.0 then
		self.totals_timer_running = false
		self.totals_timer = 0
		plasteel_widget.visible = false
		diamantine_widget.visible = false
		salvage_widget.visible = false
		loot_widget.visible = false
	end
end

HudElementLootDopamine.update = function(self, dt, t, ui_renderer, render_settings, input_service)
	HudElementLootDopamine.super.update(self, dt, t, ui_renderer, render_settings, input_service)

	local current_shake_x = 0
	local current_shake_y = 0
	local is_shaking = false

	if self._shake_timer > 0 then
		self._shake_timer = self._shake_timer - dt
		if self._shake_timer > 0 then
			local intensity = self._shake_intensity * (self._shake_timer / 0.5)
			current_shake_x = math.random(-intensity, intensity)
			current_shake_y = math.random(-intensity, intensity)
			is_shaking = true
		end
	end

	if is_shaking or (self._shake_timer <= 0 and self._shake_intensity > 0) then
		local is_expedition = Managers.state.game_mode and Managers.state.game_mode:game_mode_name() == "expedition"
		local base_y = is_expedition and 130 or 50
		self:set_scenegraph_position("totalsContainer", current_shake_x, base_y + current_shake_y, nil)

		if not is_shaking then
			self._shake_intensity = 0
		end
	end

	if #self._active_popups > 0 then
		self:_update_animation(dt, current_shake_x, current_shake_y)
	end

	if self.totals_timer_running then
		self:_update_totals_animation(dt)
	end
end

return HudElementLootDopamine

