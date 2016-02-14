require "ISUI/ISPanel"
require "ISUI/ISButton"
require "ISUI/ISInventoryPane"
require "ISUI/ISInventoryPage"
require "ISUI/ISResizeWidget"
require "ISUI/ISMouseDrag"
require "ISUI/ISLayoutManager"
require "TimedActions/ISInventoryTransferAction"
require "bcUtils"

require "defines"

HotBar = {};
HotBar.config = {};
HotBar.items = {};
HotBar.config.main = {};
HotBar.config.main.numSlots = 10;
HotBar.config.main.size = 75;

HotBar.loadConfig = function()--{{{
	HotBar.config.main = {};
	HotBar.config.main.numSlots = 10;
	HotBar.config.main.size = 75;
	HotBar.config.main.smart = "traditional";
	HotBar.config.main.showContext = "yes";
	HotBar.config.items = {};

	local ini = bcUtils.readINI("hotbar.ini");
	if not bcUtils.tableIsEmpty(ini) then
		if not ini.main then ini.main = {} end
		if not ini.items then ini.items = {} end -- safeguard
		HotBar.config.main.smart = ini.main.smart or "traditional";
		HotBar.config.main.showContext = ini.main.showContext or "yes";
		HotBar.config.main.numSlots = tonumber(ini.main.numSlots) or 10;
		HotBar.config.main.size = tonumber(ini.main.size) or 75;
		for k,v in pairs(ini.items) do
			HotBar.config.items[tonumber(k)] = v;
		end
		return;
	end

	local fd = getFileReader("hotbar_size.txt", false);
	if fd ~= nil then
		HotBar.config.main.size = tonumber(fd:readLine()) or 75;
		fd:close();
	else
		HotBar.config.main.size = 75;
	end

	fd = getFileReader("hotbar_numslots.txt", false);
	if fd ~= nil then
		HotBar.config.main.numSlots = tonumber(fd:readLine()) or 10;
		fd:close();
	else
		HotBar.config.main.numSlots = 10;
	end

	fd = getFileReader("hotbar_items.txt", true);
	if fd ~= nil then
		local i = 0;
		line = fd:readLine();
		while line ~= nil and i < HotBar.config.main.numSlots do
			if line == "nil" then line = nil end;
			HotBar.config.items[i] = line;
			line = fd:readLine();
			i = i + 1;
		end
		fd:close();
	end

	HotBar.saveConfig();
end
--}}}
HotBar.saveConfig = function()--{{{
	bcUtils.writeINI("hotbar.ini", HotBar.config);
end
--}}}

HotBar.ISInventoryTransferActionPerform = ISInventoryTransferAction.perform;
function ISInventoryTransferAction:perform() -- {{{
	HotBar.ISInventoryTransferActionPerform(self);
	if HotBar.inventoryPage ~= nil then
		HotBar.inventoryPage:updateInventory(true);
	end
end
-- }}}

HotBar.MainOptionsOnResolutionChange = MainOptions.onResolutionChange;
function MainOptions:onResolutionChange(oldw, oldh, neww, newh) -- {{{
	HotBar.MainOptionsOnResolutionChange(self, oldw, oldh, neww, newh);
	HotBar.ReInit()
end
-- }}}

HotBarISInventoryItem = ISPanel:derive("HotBarISInventoryItem");
function HotBarISInventoryItem:new (x, y, width, height, parent, object, slot) -- {{{
	local o = {}
	o = ISPanel:new(x, y, width, height);
	setmetatable(o, self)
	self.__index = self
	o.x = x;
	o.y = y;
	o.anchorBottom = true;
	o.anchorLeft = true;
	o.anchorRight = true;
	o.anchorTop = true;
	o.backgroundColor = {r=0, g=0, b=0, a=0.8};
	o.borderColor = {r=0.4, g=0.4, b=0.4, a=1};
	o.dirty = true;
	o.height = height;
	o.width = width;
	o.object = object;
	o.parent = parent;
	o.slot = slot;

	return o
end
-- }}}
function HotBarISInventoryItem:onRightMouseUp(x, y) -- {{{
	if self.object.item == nil then return end;
	local items = {};
	table.insert(items, getSpecificPlayer(self.parent.player):getInventory():FindAndReturn(self.object.item));

	ISInventoryPaneContextMenu.createMenu(self.parent.player, true, items, self:getAbsoluteX()+x, self:getAbsoluteY()+y)
end
-- }}}
function HotBarISInventoryItem:onMouseUp(x, y) -- {{{
	self.parent:onMouseUp(self:getX() + x, self:getY() + y);
end
-- }}}
function HotBarISInventoryItem:createChildren() -- {{{
	--self.drop = ISButton:new(0, self:getHeight() - 10, self:getWidth() / 2, 10, "Drop", self.slot, HotBar.DropItemInSlot)
	--self:addChild(self.drop);

	self.clear = ISButton:new(0, self:getHeight() - 10, self:getWidth(), 10, getText("UI_Clear"), self.slot, HotBar.ClearSlot)
	self:addChild(self.clear);
end
-- }}}
function HotBarISInventoryItem:render() -- {{{
	if self.object.item == nil then
		--self.drop:setVisible(false);
		self.clear:setVisible(false);
		return;
	end
	--self.drop:setVisible(false);
	self.clear:setVisible(true);

	local texture = self.object.texture;
	local imgSize = math.min(self.width, self.height-10);
	local alpha = 0.3;

	if self.object.count > 0 then
		if texture == nil then
			local i = getSpecificPlayer(self.parent.player):getInventory():FindAndReturn(self.object.item);
			if i ~= nil then
				texture = i:getTex();
			end
		end
		--self.drop:setVisible(true);
		alpha = 1;
	end

	self:drawTextureScaled(texture, (self.width - imgSize) / 2, 0, imgSize, imgSize, alpha, 1, 1, 1);
	local text = "("..self.object.count..")";
	local textWidth = getTextManager():MeasureStringX(UIFont.Small, text);
	local textHeight = getTextManager():MeasureStringY(UIFont.Small, text);
	self:drawText("("..self.object.count..")", self.width-textWidth, self.clear.y-(textHeight+1), 1, 1, 0, 1, UIFont.Small);
end
-- }}}

HotBarISInventoryPage = ISPanel:derive("HotBarISInventoryPage");
function HotBarISInventoryPage:createChildren() -- {{{
	local offx = self.width / HotBar.config.main.numSlots;
	self.slots = {};
	for x=0,HotBar.config.main.numSlots-1 do
		self.slots[x] = self:addChild(HotBarISInventoryItem:new(offx * x + 5, 5, offx - 10, self.height - 10, self, self.items[x], x));
	end
end
-- }}}
function HotBarISInventoryPage:updateInventory(force) -- {{{
	if force == true then self.dirty = true; end;
	if not self.dirty then return end;
	if getSpecificPlayer(self.player) == nil then return end;
	if getSpecificPlayer(self.player):getInventory() == nil then return end;

	local count = {};

	for f=0,getSpecificPlayer(self.player):getInventory():getItems():size()-1 do
		local item = getSpecificPlayer(self.player):getInventory():getItems():get(f);
		if count[item:getFullType()] == nil then
			count[item:getFullType()] = 0;
		end
		count[item:getFullType()] = count[item:getFullType()] + 1;
	end

	for i=0,HotBar.config.main.numSlots-1 do
		if self.items[i].item ~= nil then
			if count[self.items[i].item] ~= nil then
				self.items[i].count = count[self.items[i].item]
			else
				self.items[i].count = 0;
			end
			local p = InventoryItemFactory.CreateItem(self.items[i].item);
			self.items[i].texture = p:getTexture();
		else
			self.items[i].count = 0;
		end
	end

	self.dirty = false;
end -- }}}
function HotBarISInventoryPage:onMouseUp(x, y) -- {{{
	if ISMouseDrag.dragging == nil then return end;
	local items = {};
	for i,v in ipairs(ISMouseDrag.dragging) do
		if instanceof(v, "InventoryItem") then
			table.insert(items, v:getFullType());
		else
			table.insert(items, v.items[1]:getFullType());
		end
	end
	table.sort(items);

	local lastItem = "";
	local i = 1;
	local s = math.floor(x / (self.width / HotBar.config.main.numSlots));
	for s=s,HotBar.config.main.numSlots-1 do
		if items[i] ~= nil then
			if lastItem ~= items[i] then
				HotBar.PutItemInSlot(items[i], s);
			end
			lastItem = items[i]; -- prevent duplicates
		end
		i = i + 1;
	end
end
-- }}}
function HotBar.ActivateSlot(i) -- {{{
	if HotBar.inventoryPage.items[i] ~= nil then
		local item = getPlayer():getInventory():FindAndReturn(HotBar.inventoryPage.items[i].item);
		if not item then return end;

		if HotBar.config.main.smart == "smart" then
			if instanceof(item, "HandWeapon") then
				local primary = true;
				local twohanded = item:isTwoHandWeapon()
				ISTimedActionQueue.add(ISEquipWeaponAction:new(getPlayer(), item, 50, primary, twohanded));
			elseif instanceof(item, "InventoryContainer") and item:canBeEquipped() == "Back" then
				if item == getPlayer():getClothingItem_Back() then
					getPlayer():Say(getText("UI_AlreadyWorn"));
				else
					ISInventoryPaneContextMenu.wearItem(item, getPlayer():getPlayerNum());
				end
			elseif item:getCategory() == "Food" then
				if item:getHungChange() < 0 then
					ISInventoryPaneContextMenu.onEatItems({item}, 0.25, getPlayer():getPlayerNum());
				else
					ISInventoryPaneContextMenu.onEatItems({item}, 1, getPlayer():getPlayerNum());
				end
			elseif item:isCanBandage() then
				local bodyPartDamaged = ISInventoryPaneContextMenu.haveDamagePart(getPlayer():getPlayerNum());
				if #bodyPartDamaged > 0 then
					ISInventoryPaneContextMenu.onApplyBandage({item}, bodyPartDamaged[1], getPlayer():getPlayerNum());
				else
					getPlayer():Say(getText("UI_NotInjured"));
				end
			elseif item:getCategory() == "Literature" then
				ISInventoryPaneContextMenu.onLiteratureItems({item}, getPlayer():getPlayerNum());
			elseif luautils.stringStarts(item:getType(), "Pills") then
				ISInventoryPaneContextMenu.onPillsItems({item}, getPlayer():getPlayerNum());
			else
				getPlayer():Say(getText("UI_DoNotKnowWhatToDoWith", item:getDisplayName()));
			end
		else
			local primary = true;
			local twohanded = false;
			if instanceof(item, "HandWeapon") then
				twohanded = item:isTwoHandWeapon()
			else
				primary = false;
			end
			ISTimedActionQueue.add(ISEquipWeaponAction:new(getPlayer(), item, 50, primary, twohanded));
		end
	end
end
-- }}}

function HotBarISInventoryPage:prerender() -- {{{
	self:drawRect(0, 0, self:getWidth(), self:getHeight(), self.backgroundColor.a, self.backgroundColor.r, self.backgroundColor.g, self.backgroundColor.b);
	self:drawRectBorder(0, 0, self:getWidth(), 16, self.borderColor.a, self.borderColor.r, self.borderColor.g, self.borderColor.b);

	self:updateInventory();
end
-- }}}
function HotBarISInventoryPage:render() -- {{{
	self:drawRectBorder(0, 0, self:getWidth(), self:getHeight(), self.borderColor.a, self.borderColor.r, self.borderColor.g, self.borderColor.b);
end
-- }}}
function HotBarISInventoryPage:new (x, y, width, height, player) -- {{{
	local o = {}
	o = ISPanel:new(x, y, width, height);
	setmetatable(o, self)
	self.__index = self
	o.x = x;
	o.y = y;
	o.anchorBottom = true;
	o.anchorLeft = true;
	o.anchorRight = true;
	o.anchorTop = true;
	o.backgroundColor = {r=0, g=0, b=0, a=0.8};
	o.borderColor = {r=0.4, g=0.4, b=0.4, a=1};
	o.height = height;
	o.player = player;
	o.width = width;
	o.dirty = true;
	o.items = {};

	HotBar.loadConfig();

	for i=0,HotBar.config.main.numSlots-1 do
		o.items[i] = {};
		o.items[i].item = HotBar.config.items[i];
	end

	o:setWidth(height * HotBar.config.main.numSlots);
	o:setX((getCore():getScreenWidth() - height * HotBar.config.main.numSlots) / 2);
	return o
end
-- }}}

HotBarISInventoryPage.onKeyPressed = function(key) -- {{{
	if key == getCore():getKey("Toggle_Hotbar") and getSpecificPlayer(0) and getGameSpeed() > 0 then
		HotBar.Toggle();
	end

	for i=0,9 do
		if key == getCore():getKey("Slot"..(i+1)) and getSpecificPlayer(0) and getGameSpeed() > 0 then
			HotBar.ActivateSlot(i);
		end
	end
end
-- }}}
HotBar.Toggle = function() -- {{{
	if HotBar.inventoryPage == nil then
		HotBar.inventoryPage = HotBarISInventoryPage:new(0, getCore():getScreenHeight()-HotBar.config.main.size, 0, HotBar.config.main.size, 0); -- x and width now set in constructor
		HotBar.inventoryPage:setVisible(true);
		HotBar.inventoryPage:addToUIManager();
	else
		HotBar.inventoryPage:setVisible(not HotBar.inventoryPage:getIsVisible());
	end
end
-- }}}
HotBar.ReInit = function() -- {{{
	if HotBar.inventoryPage ~= nil then
		HotBar.inventoryPage:setVisible(false);
		HotBar.inventoryPage:removeFromUIManager();
		HotBar.inventoryPage = nil;
	end
	HotBar.Toggle();
end
-- }}}

-- Called when an object with a container is added/removed from the world.
-- Added this to handle campfire containers.
HotBarISInventoryPage.OnContainerUpdate = function(object) -- {{{
	if HotBar.inventoryPage ~= nil then
		HotBar.inventoryPage:updateInventory(true);
	end
end
-- }}}

HotBar.FillContextMenu = function(player, context, items) -- {{{
	if HotBar.config.main.showContext == "no" then return end
	if #items > 1 then return end; -- we only create an entry for the first object
	if HotBar.inventoryPage == nil then -- safeguard
		HotBarISInventoryPage.onKeyPressed(getCore():getKey("Toggle Inventory"));
		HotBar.inventoryPage:setVisible(false);
	end

	item = items[1];
	if not instanceof(item, "InventoryItem") then
		item = item.items[1];
	end
	if item == nil then return end;

	local subMenu = ISContextMenu:getNew(context);
	local buildOption = context:addOption(getText("UI_Hotbar"), item, nil);
	context:addSubMenu(buildOption, subMenu);

	for i=0,HotBar.config.main.numSlots-1 do
		if HotBar.inventoryPage.items[i].item == nil then
			subMenu:addOption(getText("UI_HotBarPutItemInSlot", item:getName(), i+1), item:getFullType(), HotBar.PutItemInSlot, i);
		else
			local name = InventoryItemFactory.CreateItem(HotBar.inventoryPage.items[i].item):getName();
			subMenu:addOption(getText("UI_HotBarReplaceItemInSlotWithItem", name, i+1, item:getName()), item:getFullType(), HotBar.PutItemInSlot, i);
		end
	end
end
-- }}}
HotBar.ClearSlot = function(slot) -- {{{
	HotBar.PutItemInSlot(nil, slot);
end
-- }}}
HotBar.PutItemInSlot = function(item, slot) -- {{{
	HotBar.inventoryPage.items[slot].item = item;
	HotBar.inventoryPage:updateInventory(true);

	HotBar.config.items[slot] = item;
	HotBar.saveConfig();
end
-- }}}

Events.OnKeyPressed.Add(HotBarISInventoryPage.onKeyPressed);
Events.OnContainerUpdate.Add(HotBarISInventoryPage.OnContainerUpdate);
Events.OnFillInventoryObjectContextMenu.Add(HotBar.FillContextMenu);
Events.OnGameStart.Add(HotBar.Toggle);
