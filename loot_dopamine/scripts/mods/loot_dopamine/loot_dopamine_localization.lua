local InputUtils = require("scripts/managers/input/input_utils")

local localization = {
	mod_title = {
		en = "Loot Dopamine",
	},
	mod_description = {
		en = "Shows floating combat text when teammates pick up Plasteel or Diamantine. Option to disable base game notifications.",
	},
	disable_base_notification = {
		en = "Disable Base Game Notification",
	},
	disable_base_notification_description = {
		en = "Disables the base game's material pickup notification on the right side of the screen.",
	},
	show_totals = {
		en = "Show Totals Display",
	},
	show_totals_description = {
		en = "Shows the total plasteel and diamantine collected at the top of the screen when materials are picked up.",
	},
	enable_shake = {
		en = "Enable Shake Effects",
	},
	enable_shake_description = {
		en = "Adds a screen shake/jitter effect when picking up large bundles or many items rapidly.",
	},
	floating_text_options = {
		en = "Floating Text Options",
	},
	anim_container_x_offset = {
		en = "X Offset",
	},
	anim_container_x_offset_description = {
		en = "Horizontal offset of the floating text.",
	},
	anim_container_y_offset = {
		en = "Y Offset",
	},
	anim_container_y_offset_description = {
		en = "Vertical offset of the floating text.",
	},
	anim_transparency = {
		en = "Transparency",
	},
	anim_transparency_description = {
		en = "Transparency of the floating text (0-255).",
	},
	anim_color = {
		en = "Colour",
	},
	anim_color_description = {
		en = "Color of the floating text (overridden by material-specific colors).",
	},
	label_size = {
		en = "Text Size",
	},
	label_size_description = {
		en = "Size of the floating text.",
	},
	default = {
		en = "Default",
	},
	large = {
		en = "Large",
	},
	largest = {
		en = "Largest",
	},
	small = {
		en = "Small",
	},
	color_options = {
		en = "Color Options",
	},
	plasteel_color = {
		en = "Plasteel Color",
	},
	plasteel_color_description = {
		en = "Color of the floating text when plasteel is picked up.",
	},
	diamantine_color = {
		en = "Diamantine Color",
	},
	diamantine_color_description = {
		en = "Color of the floating text when diamantine is picked up.",
	},
	salvage_color = {
		en = "Salvage Color",
	},
	salvage_color_description = {
		en = "Color of the floating text when expedition salvage is picked up.",
	},
	scrap_color = {
		en = "Scrap Color",
	},
	scrap_color_description = {
		en = "Color of the floating text when expedition scrap/loot is picked up.",
	},
	event_material_color = {
		en = "Event Material Color",
	},
	event_material_color_description = {
		en = "Color of the floating text when event materials are picked up.",
	},
}

local function readable(text)
	local readable_string = ""
	for token in string.gmatch(text, "([^_]+)") do
		local first = string.sub(token, 1, 1)
		token = string.format("%s%s", string.upper(first), string.sub(token, 2))
		readable_string = string.trim(string.format("%s %s", readable_string, token))
	end
	return readable_string
end

for _, color_name in ipairs(Color.list) do
	local color_values = Color[color_name](100, true)
	local text = InputUtils.apply_color_to_input_text(readable(color_name), color_values)
	localization[color_name] = {
		en = text,
	}
end

return localization

