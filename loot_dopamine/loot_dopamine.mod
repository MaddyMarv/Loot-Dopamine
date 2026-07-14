return {
	run = function()
		fassert(rawget(_G, "new_mod"), "`loot_dopamine` encountered an error loading the Darktide Mod Framework.")

		new_mod("loot_dopamine", {
			mod_script       = "loot_dopamine/scripts/mods/loot_dopamine/loot_dopamine",
			mod_data         = "loot_dopamine/scripts/mods/loot_dopamine/loot_dopamine_data",
			mod_localization = "loot_dopamine/scripts/mods/loot_dopamine/loot_dopamine_localization",
		})
	end,
	packages = {},
}

