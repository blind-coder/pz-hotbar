require 'OptionScreens/MainOptions'
require 'keyBinding'

-- Taken from RJs Spraypaint mod --

HotBarKeyBinds = {}

local function addBind(name, key)
	local bind = {}
	bind.value = name
	bind.key = key
	table.insert(keyBinding, bind) -- global key bindings in zomboid/media/lua/shared/keyBindings.lua
end

table.insert(keyBinding, {value="[Hotbar]"}) -- adds a section header to keys.ini and the options screen
addBind("Toggle_Hotbar", 15) -- Tab

function HotBarKeyBinds.SizeChanged(_, box)
	if box.options[box.selected] ~= nil then
		local choices = { 100, 75, 50 };
		local options = getFileWriter("hotbar_size.txt", true, false); -- overwrite
		options:write(tostring(choices[box.selected]));
		options:close();
		if MainScreen.instance.inGame then
			HotBar.ReInit();
		end
	end
end

HotBarKeyBinds.MainOptionsCreate = MainOptions.create;
MainOptions.create = function(self)
	HotBarKeyBinds.MainOptionsCreate(self);

	for _,el in pairs(self.mainPanel.children) do
		if tostring(el.internal) == "Toggle_Hotbar" then
			local x = el.x + el.width + 150;

			local options = getFileReader("hotbar_size.txt", true);
			local size = 75;
			if options ~= nil then
				size = tonumber(options:readLine());
				options:close();
			end
			if size == 100 then
				selected = 1;
			elseif size == 50 then
				selected = 3;
			else
				selected = 2;
			end

			local box = self:addCombo(x, el.y - self.addY, self:getWidth() - (x - 50), 20, getText("UI_optionscreen_hotbar_change_size"), { getText("UI_optionscreen_Large"), getText("UI_optionscreen_Medium"), getText("UI_optionscreen_Small") }, selected, self, HotBarKeyBinds.SizeChanged);
			return; -- need to bail out here or we get a java.util.ConcurrentModificationException
		end
	end
end
