local mod = get_mod("loot_dopamine")

local color_options = {}

for _, color_name in ipairs(Color.list) do
	table.insert(
		color_options,
		{
			text = color_name,
			value = color_name,
		}
	)
end

table.sort(color_options, function(a, b)
	return a.text < b.text
end)

local function get_color_options()
	return table.clone(color_options)
end

local data = {
	name = mod:localize("mod_title"),
	description = mod:localize("mod_description"),
	is_togglable = true,
	allow_rehooking = true,
	options = {
		widgets = {
				{
					setting_id = "general_options",
					type = "group",
					title = "general_options",
					tab = "general",
					sub_widgets = {
						{
							setting_id = "disable_base_notification",
							type = "checkbox",
							default_value = true,
							title = "disable_base_notification",
							tooltip = "disable_base_notification_description",
						},
						{
							setting_id = "show_totals",
							type = "checkbox",
							default_value = true,
							title = "show_totals",
							tooltip = "show_totals_description",
						},
						{
							setting_id = "enable_shake",
							type = "checkbox",
							default_value = true,
							title = "enable_shake",
							tooltip = "enable_shake_description",
						},
					},
				},
				{
					setting_id = "floating_text_options",
					type = "group",
					title = "floating_text_options",
					tab = "general",
					sub_widgets = {
						{
							setting_id = "anim_container_x_offset",
							type = "numeric",
							default_value = 0,
							range = { -900, 900 },
							title = "anim_container_x_offset",
							tooltip = "anim_container_x_offset_description",
						},
						{
							setting_id = "anim_container_y_offset",
							type = "numeric",
							default_value = -220,
							range = { -900, 900 },
							title = "anim_container_y_offset",
							tooltip = "anim_container_y_offset_description",
						},
						{
							setting_id = "anim_transparency",
							type = "numeric",
							default_value = 255,
							range = { 0, 255 },
							title = "anim_transparency",
							tooltip = "anim_transparency_description",
						},
						{
							setting_id = "label_size",
							type = "dropdown",
							default_value = "label_size_default",
							options = {
								{ text = "largest", value = "label_size_largest" },
								{ text = "large", value = "label_size_large" },
								{ text = "default", value = "label_size_default" },
								{ text = "small", value = "label_size_small" },
							},
							title = "label_size",
							tooltip = "label_size_description",
						},
					},
				},
				{
					setting_id = "color_options",
					type = "group",
					title = "color_options",
					tab = "colors",
					sub_widgets = {
						{
							setting_id = "plasteel_color",
							type = "dropdown",
							default_value = "ui_hud_green_light",
							options = get_color_options(),
							title = "plasteel_color",
							tooltip = "plasteel_color_description",
						},
						{
							setting_id = "diamantine_color",
							type = "dropdown",
							default_value = "ui_toughness_default",
							options = get_color_options(),
							title = "diamantine_color",
							tooltip = "diamantine_color_description",
						},
						{
							setting_id = "salvage_color",
							type = "dropdown",
							default_value = "terminal_text_header",
							options = get_color_options(),
							title = "salvage_color",
							tooltip = "salvage_color_description",
						},
						{
							setting_id = "scrap_color",
							type = "dropdown",
							default_value = "terminal_text_header",
							options = get_color_options(),
							title = "scrap_color",
							tooltip = "scrap_color_description",
						},
						{
							setting_id = "event_material_color",
							type = "dropdown",
							default_value = "terminal_text_header",
							options = get_color_options(),
							title = "event_material_color",
							tooltip = "event_material_color_description",
						},
					},
				}
			},
		},
}

return data

