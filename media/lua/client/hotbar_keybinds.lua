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

addBind("Slot1", 0)
addBind("Slot2", 0)
addBind("Slot3", 0)
addBind("Slot4", 0)
addBind("Slot5", 0)
addBind("Slot6", 0)
addBind("Slot7", 0)
addBind("Slot8", 0)
addBind("Slot9", 0)
addBind("Slot10", 0)
addBind("Toggle_Hotbar", 15) -- Tab

function HotBarKeyBinds.SizeChanged(_, box)--{{{
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
--}}}
function HotBarKeyBinds.NumSlotsChanged(_, box)--{{{
	if box.options[box.selected] ~= nil then
		local choices = { 5, 10, 15, 20, 25, 30 };
		local options = getFileWriter("hotbar_numslots.txt", true, false); -- overwrite
		options:write(tostring(choices[box.selected]));
		options:close();
		if MainScreen.instance.inGame then
			HotBar.ReInit();
		end
	end
end
--}}}

HotBarKeyBinds.MainOptionsCreate = MainOptions.create;
MainOptions.create = function(self)
	HotBarKeyBinds.MainOptionsCreate(self);

	self:addPage("Hotbar");
	local y = 20;
	self.addY = 0;

	local x = self:getWidth() / 3;
	local h = 20;
	local w = self:getWidth() / 3;

	local options = getFileReader("hotbar_size.txt", false);
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

	local box = self:addCombo(x, y, w, h, getText("UI_optionscreen_hotbar_change_size"), { getText("UI_optionscreen_Large"), getText("UI_optionscreen_Medium"), getText("UI_optionscreen_Small") }, selected, self, HotBarKeyBinds.SizeChanged);

	local options = getFileReader("hotbar_numslots.txt", false);
	local size;
	if options ~= nil then
		size = tonumber(options:readLine());
		options:close();
	else
		size = 10;
	end
	local selected = math.floor(size / 5);

	local box = self:addCombo(x, y, w, h, getText("UI_optionscreen_hotbar_num_slots"), { "5", "10", "15", "20", "25", "30" }, selected, self, HotBarKeyBinds.NumSlotsChanged);
end
