require "ISUI/ISPanel"
require "ISUI/ISButton"
require "ISUI/ISInventoryPane"
require "ISUI/ISInventoryPage"
require "ISUI/ISResizeWidget"
require "ISUI/ISMouseDrag"
require "ISUI/ISLayoutManager"
require "TimedActions/ISInventoryTransferAction"

require "defines"

HotBar = {};
HotBar.dump = function(o, lvl) -- {{{ Small function to dump an object.
	if lvl == nil then lvl = 0 end
	if lvl >= 10 then return "SO ("..tostring(o)..")" end

	if type(o) == 'table' then
		local s = '{ '
		for k,v in pairs(o) do
			if k == "prev" or k == "next" then
				s = s .. '['..k..'] = '..tostring(v);
			else
				if type(k) ~= 'number' then k = '"'..k..'"' end
				s = s .. '['..k..'] = ' .. HotBar.dump(v, lvl + 1) .. ',\n'
			end
		end
		return s .. '}\n'
	else
		return tostring(o)
	end
end
-- }}}
HotBar.pline = function (text) -- {{{ Print text to logfile
	print(tostring(text));
end
-- }}}

HotBar.ISInventoryTransferActionPerform = ISInventoryTransferAction.perform;
function ISInventoryTransferAction:perform() -- {{{
	HotBar.ISInventoryTransferActionPerform(self);
	if HotBar.inventoryPage ~= nil then
		HotBar.inventoryPage:updateInventory(true);
	end
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
function HotBarISInventoryItem:createChildren() -- {{{
	--self.drop = ISButton:new(0, self:getHeight() - 10, self:getWidth() / 2, 10, "Drop", self.slot, HotBar.DropItemInSlot)
	--self:addChild(self.drop);

	self.clear = ISButton:new(0, self:getHeight() - 10, self:getWidth(), 10, "Clear", self.slot, HotBar.ClearSlot)
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
		texture = getSpecificPlayer(self.parent.player):getInventory():FindAndReturn(self.object.item):getTex();
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
	local offx = (self.width) / 10;
	for x=0,9 do
		self:addChild(HotBarISInventoryItem:new(offx * x + 5, 5, offx - 10, self.height - 10, self, self.items[x], x));
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

	for i=0,9 do
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

	o.items = { -- {{{
		[0] = { item = nil, count = 0, texture = nil },
		[1] = { item = nil, count = 0, texture = nil },
		[2] = { item = nil, count = 0, texture = nil },
		[3] = { item = nil, count = 0, texture = nil },
		[4] = { item = nil, count = 0, texture = nil },
		[5] = { item = nil, count = 0, texture = nil },
		[6] = { item = nil, count = 0, texture = nil },
		[7] = { item = nil, count = 0, texture = nil },
		[8] = { item = nil, count = 0, texture = nil },
		[9] = { item = nil, count = 0, texture = nil },
	}; -- }}}

	local options = getFileReader("hotbar_items.txt", true);
	local i = 0;
	line = options:readLine();
	while line ~= nil and i < 10 do
		if line == "nil" then line = nil end;
		o.items[i].item = line;
		line = options:readLine();
		i = i + 1;
	end
	options:close();
	return o
end
-- }}}

HotBarISInventoryPage.onKeyPressed = function(key) -- {{{
	if key == getCore():getKey("Toggle_Hotbar") and getSpecificPlayer(0) and getGameSpeed() > 0 then
		HotBar.Toggle();
	end
end
-- }}}
HotBar.Toggle = function() -- {{{
	local size = 75;

	local options = getFileReader("hotbar_size.txt", true);
	if options ~= nil then
		size = tonumber(options:readLine());
		options:close();
	end

	local width = (size * 10);

	if HotBar.inventoryPage == nil then
		HotBar.inventoryPage = HotBarISInventoryPage:new((getCore():getScreenWidth() - width) / 2, getCore():getScreenHeight()-size, width, size, 0);
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

	for i=0,9 do
		if HotBar.inventoryPage.items[i].item == nil then
			subMenu:addOption(getText("UI_HotBarPutItemInSlot", item:getName(), i), item:getFullType(), HotBar.PutItemInSlot, i);
		else
			local name = InventoryItemFactory.CreateItem(HotBar.inventoryPage.items[i].item):getName();
			subMenu:addOption(getText("UI_HotBarReplaceItemInSlotWithItem", name, i, item:getName()), item:getFullType(), HotBar.PutItemInSlot, i);
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

	local options = getFileWriter("hotbar_items.txt", true, false); -- overwrite
	for i=0,9 do
		options:write(tostring(HotBar.inventoryPage.items[i].item).."\n");
	end
	options:close();
end
-- }}}
--[[
HotBar.DropItemInSlot = function(slot) -- {{{
	local player = HotBar.inventoryPage.player;
	local item = getSpecificPlayer(player):getInventory():FindAndReturn(HotBar.inventoryPage.items[i].item);
	ISInventoryPaneContextMenu.dropItem(item, player);
end
-- }}}
--]]

Events.OnKeyPressed.Add(HotBarISInventoryPage.onKeyPressed);
Events.OnContainerUpdate.Add(HotBarISInventoryPage.OnContainerUpdate);
Events.OnFillInventoryObjectContextMenu.Add(HotBar.FillContextMenu);
Events.OnGameStart.Add(HotBar.Toggle);
