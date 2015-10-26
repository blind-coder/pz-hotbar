require 'OptionScreens/MainOptions'
require 'keyBinding'
require 'ISUI/hotbar_inventorypage'
require 'bcUtils'

-- Taken from the Spraypaint mod --
local function addBind(name, key)--{{{
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
addBind("Slot11", 0)
addBind("Slot12", 0)
addBind("Slot13", 0)
addBind("Slot14", 0)
addBind("Slot15", 0)
addBind("Slot16", 0)
addBind("Slot17", 0)
addBind("Slot18", 0)
addBind("Slot19", 0)
addBind("Slot20", 0)
addBind("Slot21", 0)
addBind("Slot22", 0)
addBind("Slot23", 0)
addBind("Slot24", 0)
addBind("Slot25", 0)
addBind("Slot26", 0)
addBind("Slot27", 0)
addBind("Slot28", 0)
addBind("Slot29", 0)
addBind("Slot30", 0)
addBind("Toggle_Hotbar", 15) -- Tab
--}}}

HotBarKeyBinds = {}

HotBar.loadConfig();

function HotBarKeyBinds.SizeChanged(_, box)
	if box.options[box.selected] ~= nil then
		local choices = { 100, 75, 50 };
		HotBar.config.main.size = choices[box.selected];
		HotBar.saveConfig();
		if MainScreen.instance.inGame then
			HotBar.ReInit();
		end
	end
end

function HotBarKeyBinds.NumSlotsChanged(_, box)
	if box.options[box.selected] ~= nil then
		local choices = { 5, 10, 15, 20, 25, 30 };
		HotBar.config.main.numSlots = choices[box.selected];
		HotBar.saveConfig();
		if MainScreen.instance.inGame then
			HotBar.ReInit();
		end
	end
end

function HotBarKeyBinds.SmartChanged(_, box)
	if box.options[box.selected] ~= nil then
		local choices = { "traditional", "smart" }
		HotBar.config.main.smart = choices[box.selected];
		HotBar.saveConfig();
	end
end

HotBarKeyBinds.MainOptionsCreate = MainOptions.create;
MainOptions.create = function(self)
	HotBarKeyBinds.MainOptionsCreate(self);

	HotBar.loadConfig();

	self:addPage(getText("UI_optionscreen_hotbar_title"));
	local y = 20;
	self.addY = 0;

	local x = self:getWidth() / 3;
	local h = 20;
	local w = self:getWidth() / 3;

	local selected = 0;
	if HotBar.config.main.size == 100 then
		selected = 1;
	elseif HotBar.config.main.size == 50 then
		selected = 3;
	else
		selected = 2;
	end
	local box = self:addCombo(x, y, w, h, getText("UI_optionscreen_hotbar_change_size"), { getText("UI_optionscreen_Large"), getText("UI_optionscreen_Medium"), getText("UI_optionscreen_Small") }, selected, self, HotBarKeyBinds.SizeChanged);

	selected = math.floor(HotBar.config.main.numSlots / 5);
	box = self:addCombo(x, y, w, h, getText("UI_optionscreen_hotbar_num_slots"), { "5", "10", "15", "20", "25", "30" }, selected, self, HotBarKeyBinds.NumSlotsChanged);

	if HotBar.config.main.smart == "smart" then
		selected = 2;
	else
		selected = 1;
	end
	box = self:addCombo(x, y, w, h, getText("UI_optionscreen_hotbar_smartaction"), { getText("UI_optionscreen_traditional"), getText("UI_optionscreen_smart") }, selected, self, HotBarKeyBinds.SmartChanged);
end

