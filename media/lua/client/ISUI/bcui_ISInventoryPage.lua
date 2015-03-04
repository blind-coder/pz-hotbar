require "ISUI/ISPanel"
require "ISUI/ISButton"
require "ISUI/ISInventoryPane"
require "ISUI/ISResizeWidget"
require "ISUI/ISMouseDrag"
require "ISUI/ISLayoutManager"

require "defines"

--[[
function BCUIISInventoryPage:refreshBackpacks() -- {{{
	for i,v in ipairs(self.backpacks) do
		self:removeChild(v);
	end

	if BCUIISInventoryPage.floorContainer == nil then
		BCUIISInventoryPage.floorContainer = {}
	end
	if BCUIISInventoryPage.floorContainer[self.player+1] == nil then
		BCUIISInventoryPage.floorContainer[self.player+1] = ItemContainer.new("floor", nil, nil, 10, 10);
		BCUIISInventoryPage.floorContainer[self.player+1]:setExplored(true)
	end

	self.inventoryPane.lastinventory = self.inventoryPane.inventory;

	self.inventoryPane:hideButtons()

	local oldNumBackpacks = #self.backpacks
	self.backpacks = {}

	local found = false;
	local c = 1;
	local foundIndex = -1;
	local containerButton = nil;

	if self.onCharacter then
		containerButton = ISButton:new(self:getWidth()-32, ((c-1)*32)+15, 32, 32, "", self, BCUIISInventoryPage.selectContainer, BCUIISInventoryPage.onBackpackMouseDown, true);
		containerButton.anchorBottom = false;
		containerButton.anchorRight = true;
		containerButton.anchorTop = false;
		containerButton.anchorLeft = false;
		containerButton.name = getText("IGUI_InventoryName", getSpecificPlayer(self.player):getDescriptor():getForename(), getSpecificPlayer(self.player):getDescriptor():getSurname());
		if not self.title then
			self.title = containerButton.name;
		end
		containerButton:setOnMouseOverFunction(BCUIISInventoryPage.onMouseOverButton);
		containerButton:setOnMouseOutFunction(BCUIISInventoryPage.onMouseOutButton);
		containerButton:initialise();
		containerButton.borderColor.a = 0.0;
		containerButton.capacity = self.inventory:getMaxWeight();
		if not self.capacity then
			self.capacity = containerButton.capacity;
		end
		containerButton.backgroundColor.a = 0.0;
		containerButton.backgroundColorMouseOver = {r=0.3, g=0.3, b=0.3, a=1.0};
		containerButton:setImage(self.invbasic);

		containerButton.inventory = getSpecificPlayer(self.player):getInventory();

		if self.inventoryPane.inventory == containerButton.inventory then
			containerButton.backgroundColor = {r=0.7, g=0.7, b=0.7, a=1.0};
			foundIndex = c
			found = true;
		end
		self:addChild(containerButton);
		self.backpacks[c] = containerButton;
		c = c + 1;
		local it = getSpecificPlayer(self.player):getInventory():getItems();
		for i = 0, it:size()-1 do
			local item = it:get(i);

			if item:getCategory() == "Container" and getSpecificPlayer(self.player):isEquipped(item) or item:getType() == "KeyRing" then
				-- found a container, so create a button for it...
				local containerButton = ISButton:new(self.width-32, ((c-1)*32)+15, 32, 32, "", self, BCUIISInventoryPage.selectContainer, BCUIISInventoryPage.onBackpackMouseDown, true);
				containerButton:setImage(item:getTex());
				containerButton:forceImageSize(item:getTex():getRealWidth() + item:getTex():getWidth(), item:getTex():getRealHeight() + item:getTex():getHeight())
				containerButton.anchorBottom = false;
				containerButton:setOnMouseOverFunction(BCUIISInventoryPage.onMouseOverButton);
				containerButton:setOnMouseOutFunction(BCUIISInventoryPage.onMouseOutButton);
				containerButton.anchorRight = true;
				containerButton.anchorTop = false;
				containerButton.anchorLeft = false;
				containerButton:initialise();
				containerButton.borderColor.a = 0.0;
				containerButton.backgroundColor.a = 0.0;
				containerButton.backgroundColorMouseOver = {r=0.3, g=0.3, b=0.3, a=1.0};
				containerButton.inventory = item:getInventory();
				containerButton.capacity = item:getCapacity();
				containerButton.name = item:getName();
				if self.inventoryPane.inventory == containerButton.inventory then
					containerButton.backgroundColor = {r=0.7, g=0.7, b=0.7, a=1.0};
					foundIndex = c;
					found = true;
				end
				self:addChild(containerButton);
				self.backpacks[c] = containerButton;
				c = c + 1;
			end

		end
	else
		--  print("a");
		local cx = getSpecificPlayer(self.player):getX();
		local cy = getSpecificPlayer(self.player):getY();
		local cz = getSpecificPlayer(self.player):getZ();
		--  print("b");
		-- Do floor
		--

		--
		BCUIISInventoryPage.floorContainer[self.player+1]:clear();

		local sqs = {}

		local dir = getSpecificPlayer(self.player):getDir();

		if(dir == IsoDirections.N) then         sqs[2] = getCell():getGridSquare(cx-1, cy-1, cz); sqs[3] = getCell():getGridSquare(cx, cy-1, cz); sqs[4] = getCell():getGridSquare(cx+1, cy-1, cz);
		elseif (dir == IsoDirections.NE) then   sqs[2] = getCell():getGridSquare(cx, cy-1, cz); sqs[3] = getCell():getGridSquare(cx+1, cy-1, cz); sqs[4] = getCell():getGridSquare(cx+1, cy, cz);
		elseif (dir == IsoDirections.E) then    sqs[2] = getCell():getGridSquare(cx+1, cy-1, cz); sqs[3] = getCell():getGridSquare(cx+1, cy, cz); sqs[4] = getCell():getGridSquare(cx+1, cy+1, cz);
		elseif (dir == IsoDirections.SE) then   sqs[2] = getCell():getGridSquare(cx+1, cy, cz); sqs[3] = getCell():getGridSquare(cx+1, cy+1, cz); sqs[4] = getCell():getGridSquare(cx, cy+1, cz);
		elseif (dir == IsoDirections.S) then    sqs[2] = getCell():getGridSquare(cx+1, cy+1, cz); sqs[3] = getCell():getGridSquare(cx, cy+1, cz); sqs[4] = getCell():getGridSquare(cx-1, cy+1, cz);
		elseif (dir == IsoDirections.SW) then   sqs[2] = getCell():getGridSquare(cx, cy+1, cz); sqs[3] = getCell():getGridSquare(cx-1, cy+1, cz); sqs[4] = getCell():getGridSquare(cx-1, cy, cz);
		elseif (dir == IsoDirections.W) then    sqs[2] = getCell():getGridSquare(cx-1, cy+1, cz); sqs[3] = getCell():getGridSquare(cx-1, cy, cz); sqs[4] = getCell():getGridSquare(cx-1, cy-1, cz);
		elseif (dir == IsoDirections.NW) then   sqs[2] = getCell():getGridSquare(cx-1, cy, cz); sqs[3] = getCell():getGridSquare(cx-1, cy-1, cz); sqs[4] = getCell():getGridSquare(cx, cy-1, cz);
		end

		sqs[1] = getCell():getGridSquare(cx, cy, cz);
		-- print("c");
		for x = 1, 4 do
			local gs = sqs[x];

			-- stop grabbing thru walls...
			local currentSq = getSpecificPlayer(self.player):getCurrentSquare()
			if gs ~= currentSq and currentSq and currentSq:isBlockedTo(gs) then
				gs = nil
			end

			if gs ~= nil then

				--for y = -1, 1 do
				local obs = gs:getObjects();
				local sobs =  gs:getStaticMovingObjects();
				local wobs = gs:getWorldObjects();

				if wobs ~= nil then
					for i = 0, wobs:size()-1 do
						local o = wobs:get(i);
						if instanceof(o, "IsoWorldInventoryObject") then
							-- FIXME: An item can be in only one container; in coop the item won't be displayed for every player.
							BCUIISInventoryPage.floorContainer[self.player+1]:AddItem(o:getItem());
						end
					end
				end

				for i = 0, sobs:size()-1 do
					local so = sobs:get(i);
					local doIt = true;

					if so:getContainer() ~= nil then
						-- if container is locked with a padlock and we don't have the key, return
						if instanceof(so, "IsoThumpable") then
							print("thumpable");
						end
						if instanceof(so, "IsoThumpable") and so:isLockedByPadlock() and not getSpecificPlayer(self.player):getInventory():haveThisKey(so:getKeyId()) then
							doIt = false;
						end
						if doIt then
							local containerButton = ISButton:new(self.width-32, ((c-1)*32)+15, 32, 32, "", self, BCUIISInventoryPage.selectContainer, BCUIISInventoryPage.onBackpackMouseDown, true);
							containerButton.anchorBottom = false;
							containerButton:setOnMouseOverFunction(BCUIISInventoryPage.onMouseOverButton);
							containerButton:setOnMouseOutFunction(BCUIISInventoryPage.onMouseOutButton);
							containerButton.anchorRight = true;
							containerButton.anchorTop = false;
							containerButton.anchorLeft = false;
							containerButton:initialise();
							containerButton.borderColor.a = 0.0;
							containerButton.backgroundColor.a = 0.0;
							containerButton.backgroundColorMouseOver = {r=0.3, g=0.3, b=0.3, a=1.0};
							containerButton.inventory = so:getContainer();
							containerButton.capacity = so:getContainer():getMaxWeight();
							if self.containerIconMaps[containerButton.inventory:getType()] ~= nil then
								containerButton:setImage(self.containerIconMaps[containerButton.inventory:getType()]);
							else
								containerButton:setImage(self.conDefault);
							end
							containerButton:forceImageSize(30, 30)
							containerButton.name = "";--getSpecificPlayer(self.player):getDescriptor():getForename().." "..getSpecificPlayer(self.player):getDescriptor():getSurname().."'s " .. item:getName();
							if self.inventoryPane.inventory == containerButton.inventory then
								containerButton.backgroundColor = {r=0.7, g=0.7, b=0.7, a=1.0};
								foundIndex = c;
								found = true;
							end
							if not containerButton.inventory:isExplored() then
								if not isClient() then
									ItemPicker.fillContainer(containerButton.inventory, self.player)
								else
									containerButton.inventory:requestServerItemsForContainer();
								end
								containerButton.inventory:setExplored(true);
							end
							self:addChild(containerButton);
							self.backpacks[c] = containerButton;
							c = c + 1;
						end
					end
				end

				for i = 0, obs:size()-1 do
					local o = obs:get(i);
					local doIt = true;

					if o:getContainer() ~= nil then
						if doIt then
							-- if container is locked with a padlock and we don't have the key, don't allow it to open
							--                           if instanceof(o, "IsoThumpable") and ((o:isLockedByPadlock() and not getSpecificPlayer(self.player):getInventory():haveThisKeyId(o:getKeyId())) or o:getLockedByCode() > 0) then
							----                               local containerImage = ISImage:new(self.width-32, ((c-1)*32)+15, 32, 32, getTexture("media/ui/Container_Crate.png"));
							----                               if self.containerIconMaps[o:getContainer():getType()] ~= nil then
							----                                   containerImage.texture = self.containerIconMaps[o:getContainer():getType()];
							----                               end
							----                               containerImage.textureOverride = getTexture("media/ui/lock.png");
							----                               self:addChild(containerImage);
							----                               c = c + 1;
							--
							--                               local containerButton = ISButton:new(self.width-32, ((c-1)*32)+15, 32, 32, "", self, nil, nil, true);
							--                               containerButton.anchorBottom = false;
							--                               containerButton.anchorRight = true;
							--                               containerButton.anchorTop = false;
							--                               containerButton.anchorLeft = false;
							--                               containerButton:initialise();
							--                               containerButton.borderColor.a = 0.0;
							--                               containerButton.backgroundColor.a = 0.0;
							--                               containerButton.backgroundColorMouseOver = {r=0.3, g=0.3, b=0.3, a=1.0};
							--
							--                               if self.containerIconMaps[o:getContainer():getType()] ~= nil then
							--                                   containerButton:setImage(self.containerIconMaps[o:getContainer():getType()]);
							--                               else
							--                                   containerButton:setImage(self.conDefault);
							--                               end
							--                               containerButton:forceImageSize(30, 30)
							--
							--                               containerButton.textureOverride = getTexture("media/ui/lock.png");
							--
							--                               self:addChild(containerButton);
							--                               self.backpacks[c] = containerButton;
							-- else
							local containerButton = nil;
							if instanceof(o, "IsoThumpable") and ((o:isLockedByPadlock() and not getSpecificPlayer(self.player):getInventory():haveThisKeyId(o:getKeyId())) or o:getLockedByCode() > 0) then
								containerButton = ISButton:new(self.width-32, ((c-1)*32)+15, 32, 32, "", self, nil,nil, true);
								containerButton.textureOverride = getTexture("media/ui/lock.png");
							else
								containerButton = ISButton:new(self.width-32, ((c-1)*32)+15, 32, 32, "", self, BCUIISInventoryPage.selectContainer, BCUIISInventoryPage.onBackpackMouseDown, true);
								containerButton:setOnMouseOverFunction(BCUIISInventoryPage.onMouseOverButton);
								containerButton:setOnMouseOutFunction(BCUIISInventoryPage.onMouseOutButton);
							end
							containerButton.anchorBottom = false;
							containerButton.anchorRight = true;
							containerButton.anchorTop = false;
							containerButton.anchorLeft = false;
							containerButton:initialise();
							containerButton.borderColor.a = 0.0;
							containerButton.backgroundColor.a = 0.0;
							containerButton.backgroundColorMouseOver = {r=0.3, g=0.3, b=0.3, a=1.0};
							containerButton.inventory = o:getContainer();

							if instanceof(o, "IsoThumpable") and o:isLockedByPadlock() and getSpecificPlayer(self.player):getInventory():haveThisKeyId(o:getKeyId()) then
								containerButton.textureOverride = getTexture("media/ui/lockOpen.png");
							end

							containerButton.capacity = o:getContainer():getMaxWeight();
							if self.containerIconMaps[containerButton.inventory:getType()] ~= nil then
								containerButton:setImage(self.containerIconMaps[containerButton.inventory:getType()]);
							else
								containerButton:setImage(self.conDefault);
							end
							containerButton:forceImageSize(30, 30)
							containerButton.name = "";--getSpecificPlayer(self.player):getDescriptor():getForename().." "..getSpecificPlayer(self.player):getDescriptor():getSurname().."'s " .. item:getName();
							if self.inventoryPane.inventory == containerButton.inventory then
								containerButton.backgroundColor = {r=0.7, g=0.7, b=0.7, a=1.0};
								foundIndex = c;
								found = true;
							end
							if not containerButton.inventory:isExplored() then

								if not isClient() then
									ItemPicker.fillContainer(containerButton.inventory, self.player);
								else
									containerButton.inventory:requestServerItemsForContainer();
								end

								containerButton.inventory:setExplored(true);
							end
							self:addChild(containerButton);
							self.backpacks[c] = containerButton;
							c = c + 1;
						end
					end


				end
			end

		end
		-- print("d");
		local containerButton = ISButton:new(self.width-32, ((c-1)*32)+15, 32, 32, "", self, BCUIISInventoryPage.selectContainer, BCUIISInventoryPage.onBackpackMouseDown, true);
		containerButton:setImage(self.conFloor);
		containerButton:forceImageSize(30, 30)
		containerButton.anchorBottom = false;
		containerButton:setOnMouseOverFunction(BCUIISInventoryPage.onMouseOverButton);
		containerButton:setOnMouseOutFunction(BCUIISInventoryPage.onMouseOutButton);
		containerButton.anchorRight = true;
		containerButton.anchorTop = false;
		containerButton.anchorLeft = false;
		containerButton:initialise();
		containerButton.borderColor.a = 0.0;
		containerButton.backgroundColor.a = 0.0;
		containerButton.backgroundColorMouseOver = {r=0.3, g=0.3, b=0.3, a=1.0};
		containerButton.inventory = BCUIISInventoryPage.floorContainer[self.player+1];
		containerButton.capacity = BCUIISInventoryPage.floorContainer[self.player+1]:getMaxWeight();
		containerButton.name = "";--getSpecificPlayer(self.player):getDescriptor():getForename().." "..getSpecificPlayer(self.player):getDescriptor():getSurname().."'s " .. item:getName();
		if self.inventoryPane.inventory == containerButton.inventory then
			containerButton.backgroundColor = {r=0.7, g=0.7, b=0.7, a=1.0};
			foundIndex = c;
			found = true;
		end
		self:addChild(containerButton);
		self.backpacks[c] = containerButton;
		local floor = c;
		c = c + 1;
		-- print("e");
		if not containerButton.inventory:isExplored() then
			if not isClient() then
				ItemPicker.fillContainer(containerButton.inventory, self.player);
			else
				containerButton.inventory:requestServerItemsForContainer();
			end
			containerButton.inventory:setExplored(true);
		end

	end
	--	print("f");
	self.inventoryPane.inventory = self.inventoryPane.lastinventory;
	self.inventory = self.inventoryPane.inventory;
	if self.backpackChoice ~= nil and getSpecificPlayer(self.player):getJoypadBind() ~= -1 then
		if self.backpackChoice >= c then
			if #self.backpacks > 1 then
				self.backpackChoice = 2;
			else
				self.backpackChoice = 1;
			end

		end
		if self.backpacks[self.backpackChoice] ~= nil then
			self.inventoryPane.inventory = self.backpacks[self.backpackChoice].inventory;
		end
	else
		--	    print("g");
		if not self.onCharacter and oldNumBackpacks == 1 and c > 1 then
			self.inventoryPane.inventory = self.backpacks[1].inventory;
			self.capacity = self.backpacks[1].capacity
		elseif found then
			self.capacity = self.backpacks[foundIndex].capacity
		elseif not found and c > 1 then
			if self.backpacks[1] and self.backpacks[1].inventory then
				self.inventoryPane.inventory = self.backpacks[1].inventory;
				self.capacity = self.backpacks[1].capacity
			end
		elseif self.inventoryPane.lastinventory ~= nil then
			self.inventoryPane.inventory = self.inventoryPane.lastinventory;
		end

		--	    print("h");
	end

	if not found then
		self.toggleStove:setVisible(false);
	end
	self.inventoryPane:bringToTop();

	self.resizeWidget2:bringToTop();
	self.resizeWidget:bringToTop();
	--	print("i");

	self.inventory = self.inventoryPane.inventory;
	--	print("j");

	for k,containerButton in ipairs(self.backpacks) do
		if containerButton.inventory == self.inventory then
			containerButton.backgroundColor = {r=0.7, g=0.7, b=0.7, a=1.0}
		else
			containerButton.backgroundColor.a = 0
		end
	end

	if self.inventoryPane ~= nil then self.inventoryPane:refreshContainer(); end
	self:refreshWeight();

	self:syncToggleStove()
end
-- }}}
--]]

BCUI = {};

BCUIISInventoryItem = ISPanel:derive("BCUIISInventoryItem");
function BCUIISInventoryItem:new (x, y, width, height, parent, object) -- {{{
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
	o.object = object;
	o.parent = parent;

	return o
end
-- }}}
function BCUIISInventoryItem:createChildren() -- {{{
	self.drop = ISButton:new(2, self:getHeight() - 42, self:getWidth() / 2 - 4, 20, "Drop")
	self:addChild(self.drop);

	self.equip = ISButton:new(self:getWidth() / 2 + 2, self:getHeight() - 42, self:getWidth() / 2 - 4, 20, "Equip")
	self:addChild(self.equip);

	self.unpack = ISButton:new(2, self:getHeight() - 22, self:getWidth() / 2 - 4, 20, "Unpack")
	self:addChild(self.unpack);

	self.other = ISButton:new(self:getWidth() / 2 + 2, self:getHeight() - 22, self:getWidth() / 2 - 4, 20, "Other")
	self:addChild(self.other);
end
-- }}}
function BCUIISInventoryItem:render() -- {{{
	if self.object.item == nil then
		self:drawText("Nothing", 2, 2, 0.8, 0.8, 0.8, 1);
		self.drop:setVisible(false);
		self.equip:setVisible(false);
		self.unpack:setVisible(false);
		self.other:setVisible(false);
		return;
	end
	self.drop:setVisible(true);
	self.equip:setVisible(true);
	self.unpack:setVisible(true);
	self.other:setVisible(true);

	local itemDesc = self.object.item:getName();
	local textWidth = getTextManager():MeasureStringX(UIFont.Small, itemDesc);
	local textHeight = getTextManager():MeasureStringY(UIFont.Small, itemDesc);

	local imgDim = {};
	imgDim.y = 4 + textHeight;
	imgDim.w = self.drop:getY() - (imgDim.y + 18); -- condition text is 14px high, 2px buffer on each side and 1px inside
	imgDim.h = imgDim.w;
	imgDim.x = (self:getWidth() - imgDim.w) / 2;

	if self.object.item:getConditionMax() ~= 100 then -- 100 is default and hints at indestructible. TODO: confirm! -- {{{
		local percent = math.floor(self.object.item:getCondition() * 100 / self.object.item:getConditionMax());
		local r = 0;
		local g = 0;
		local b = 0;
		local a = 1;
		if percent >= 50 then
			r = 1 - ((percent - 50) * 0.02);
			g = 1;
		else
			r = 1;
			g = 1 - ((50 - percent) * 0.02);
		end
		local cond = percent.."%";
		local condWidth = getTextManager():MeasureStringX(UIFont.Small, cond);

		self:drawRect(0, imgDim.y + imgDim.h + 1, self:getWidth(), 16, a, r, g, b); -- condition text is 14px high, 1px buffer
		self:drawText(cond, (self:getWidth() - condWidth) / 2, imgDim.y + imgDim.h + 2, 1-r, 1-g, 1-b, a);
	end
	-- }}}
	if self.object.item.getUseDelta ~= nil then -- object can have a fill level (usedelta) -- {{{
		local usesMax = 1/self.object.item:getUseDelta();
		local usesLeft = self.object.item:getDelta()/self.object.item:getUseDelta();

		local percent = math.floor(usesLeft * 100 / usesMax);
		local r = 0;
		local g = 0;
		local b = 0;
		local a = 1;
		if percent >= 50 then
			r = 1 - ((percent - 50) * 0.02);
			g = 1;
		else
			r = 1;
			g = 1 - ((50 - percent) * 0.02);
		end
		local cond = percent.."%";
		local condWidth = getTextManager():MeasureStringX(UIFont.Small, cond);

		self:drawRect(0, imgDim.y + imgDim.h + 1, self:getWidth(), 16, a, r, g, b); -- condition text is 14px high, 1px buffer
		self:drawText(cond, (self:getWidth() - condWidth) / 2, imgDim.y + imgDim.h + 2, 1-r, 1-g, 1-b, a);
	end
	-- }}}
	self:drawTextureScaled(self.object.item:getTexture(), imgDim.x, imgDim.y, imgDim.w, imgDim.h, 1, 1, 1, 1);
	self:drawText(itemDesc, self:getWidth() / 2 - textWidth / 2, 2, 1, 1, 1, 1);
end
-- }}}

BCUIISInventoryPage = ISPanel:derive("BCUIISInventoryPage");
function BCUIISInventoryPage:createChildren() -- {{{
	local offx = (self.width  - 50)/ 4;
	local offy = (self.height - 50) / 4;
	for x=0,3 do
		for y=0,3 do
			self:addChild(BCUIISInventoryItem:new(55 + offx * x, 25 + offy * y, offx - 10, offy - 10, self, self.items[x][y]));
		end
	end
end
-- }}}
function BCUIISInventoryPage.sortItems(a, b) -- {{{
	local conda = a:getCondition() / a:getConditionMax();
	local condb = b:getCondition() / b:getConditionMax();
	if a:getName() ~= b:getName() then
		for off=1,math.min(string.len(a:getName()), string.len(b:getName())) do
			local oa = string.byte(a:getName(), off);
			local ob = string.byte(b:getName(), off);
			if oa ~= ob then
				return oa < ob;
			end
		end
		return false;
	end
	return conda < condb;
end -- }}}
function BCUIISInventoryPage:updateInventory(force) -- {{{
	if force == true then self.dirty = true; end
	if not self.dirty then return end;
	self.dirty = false;

	local allItems = {};
	for i=0,self.inventory:getItems():size()-1 do
		table.insert(allItems, self.inventory:getItems():get(i));
	end
	table.sort(allItems, BCUIISInventoryPage.sortItems);

	for y=0,3 do
		for x=0,3 do
			self.items[x][y].item = allItems[1+self.page*16+y*4+x];
		end
	end
end -- }}}
function BCUIISInventoryPage:prerender() -- {{{
	local height = self:getHeight();
	-- if self.isCollapsed then
		-- height = 16;
	-- end

	self:drawRect(0, 0, self:getWidth(), height, self.backgroundColor.a, self.backgroundColor.r, self.backgroundColor.g, self.backgroundColor.b);
	self:drawTextureScaled(self.titlebarbkg, 2, 1, self:getWidth() - 4, 14, 1, 1, 1, 1);
	self:drawRectBorder(0, 0, self:getWidth(), 16, self.borderColor.a, self.borderColor.r, self.borderColor.g, self.borderColor.b);

	-- if not self.isCollapsed then
		-- Draw border for backpack area...
		-- self:drawRect(self:getWidth()-32, 15, 32, height-16-7,  self.backgroundColor.a, self.backgroundColor.r, self.backgroundColor.g, self.backgroundColor.b);
	-- end

	if self.title then
		self:drawText(self.title, 32, 0, 1,1,1,1);
	end

	self:setStencilRect(0,0,self.width+1, height);

	self:updateInventory();
end
-- }}}
function BCUIISInventoryPage:render() -- {{{
	local height = self:getHeight();
	-- if self.isCollapsed then
		-- height = 16;
	-- end
	-- Draw backpack border over backpacks....
	-- if not self.isCollapsed then
		-- self:drawRectBorder(self:getWidth()-32, 15, 32, height-16-7, self.borderColor.a, self.borderColor.r, self.borderColor.g, self.borderColor.b);
		--self:drawRect(0, 0, self.width-32, self.height, 1, 1, 1, 1);
		-- self:drawRectBorder(0, height-9, self:getWidth(), 9, self.borderColor.a, self.borderColor.r, self.borderColor.g, self.borderColor.b);
		-- self:drawTextureScaled(self.statusbarbkg, 2,  height-7, self:getWidth() - 4, 6, 1, 1, 1, 1);
		-- self:drawTexture(self.resizeimage, self:getWidth()-9, height-8, 1, 1, 1, 1);
	-- end

	self:clearStencilRect();
	self:drawRectBorder(0, 0, self:getWidth(), height, self.borderColor.a, self.borderColor.r, self.borderColor.g, self.borderColor.b);
end
-- }}}

function BCUIISInventoryPage:new (x, y, width, height, inventory, onCharacter) -- {{{
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
	o.backpackChoice = 1;
	o.backpacks = {}
	o.borderColor = {r=0.4, g=0.4, b=0.4, a=1};
	o.collapseCounter = 0;
	o.height = height;
	o.inventory = inventory;
	o.isCollapsed = false;
	o.isCollapsed = true;
	o.onCharacter = onCharacter;
	o.pin = true;
	o.title = nil;
	if onCharacter then
		self.title = getText("IGUI_InventoryName", getSpecificPlayer(0):getDescriptor():getForename(), getSpecificPlayer(0):getDescriptor():getSurname());
	end
	o.width = width;
	o.dirty = true;
	o.page = 0;

	o.items = { -- {{{
		[0] = {
			[0] = { item = {}, },
			[1] = { item = {}, },
			[2] = { item = {}, },
			[3] = { item = {}, }
		},
		[1] = {
			[0] = { item = {}, },
			[1] = { item = {}, },
			[2] = { item = {}, },
			[3] = { item = {}, }
		},
		[2] = {
			[0] = { item = {}, },
			[1] = { item = {}, },
			[2] = { item = {}, },
			[3] = { item = {}, }
		},
		[3] = {
			[0] = { item = {}, },
			[1] = { item = {}, },
			[2] = { item = {}, },
			[3] = { item = {}, }
		}
	}; -- }}}
	-- {{{ Load Textures
	o.titlebarbkg = getTexture("media/ui/Panel_TitleBar.png");
	o.statusbarbkg = getTexture("media/ui/Panel_StatusBar.png");
	o.resizeimage = getTexture("media/ui/Panel_StatusBar_Resize.png");
	o.invbasic = getTexture("media/ui/Icon_InventoryBasic.png");
	o.closebutton = getTexture("media/ui/Panel_Icon_Close.png");
	o.collapsebutton = getTexture("media/ui/Panel_Icon_Collapse.png");
	o.pinbutton = getTexture("media/ui/Panel_Icon_Pin.png");

	o.conFloor = getTexture("media/ui/Container_Floor.png");
	o.conOven = getTexture("media/ui/Container_Oven.png");
	o.conCabinet = getTexture("media/ui/Container_Cabinet.png");
	o.conSack = getTexture("media/ui/Container_Sack.png");
	o.conShelf = getTexture("media/ui/Container_Shelf.png");
	o.conCounter = getTexture("media/ui/Container_Counter.png");
	o.conMedicine = getTexture("media/ui/Container_Medicine.png");
	o.conGarbage = getTexture("media/ui/Container_Garbage.png");
	o.conFridge = getTexture("media/ui/Container_Fridge.png");
	o.conDrawer = getTexture("media/ui/Container_Drawer.png");
	o.conCrate = getTexture("media/ui/Container_Crate.png");
	o.conFemaleZombie = getTexture("media/ui/Container_DeadPerson_FemaleZombie.png");
	o.conMaleZombie = getTexture("media/ui/Container_DeadPerson_MaleZombie.png");
	o.conMicrowave = getTexture("media/ui/Container_Microwave.png");
	o.conVending = getTexture("media/ui/Container_Vendingt.png");
	o.logs = getTexture("media/ui/Item_Logs.png");
	o.plant = getTexture("media/ui/Container_Plant.png");
	o.campfire = getTexture("camping_01_6")
	o.conDefault = o.conShelf;
	-- }}}
	o.containerIconMaps = { -- {{{ Map textures
		floor=o.conFloor,
		crate=o.conCrate,
		officedrawers=o.conDrawer,
		bin=o.conGarbage,
		fridge=o.conFridge,
		sidetable=o.conDrawer,
		wardrobe=o.conCabinet,
		counter=o.conCounter,
		medicine= o.conMedicine,
		barbecue= o.conOven,
		fireplace= o.conOven,
		stove= o.conOven,
		shelves= o.conShelf,
		filingcabinet= o.conCabinet,
		garage_storage= o.conCrate,
		smallcrate= o.conCrate,
		smallbox= o.conCrate,
		inventorymale = o.conMaleZombie;
		inventoryfemale = o.conFemaleZombie;
		microwave = o.conMicrowave;
		vendingGt = o.conVending;
		logs = o.logs;
		fruitbusha = o.plant;
		fruitbushb = o.plant;
		fruitbushc = o.plant;
		fruitbushd = o.plant;
		fruitbushe = o.plant;
		corn = o.plant;
		vendingsnack = o.conVending;
		vendingpop = o.conVending;
		campfire = o.campfire
	} -- }}}

	return o
end
-- }}}

BCUIISInventoryPage.onKeyPressed = function(key) -- {{{
	if key == getCore():getKey("Toggle Inventory") and getSpecificPlayer(0) and getGameSpeed() > 0 then
		if BCUI.inventoryPage == nil then
			BCUI.inventoryPage = BCUIISInventoryPage:new(50, 50, getCore():getScreenWidth() / 2 - 50, getCore():getScreenHeight() - 100, getSpecificPlayer(0):getInventory(), true);
			BCUI.inventoryPage:setVisible(true);
			BCUI.inventoryPage:addToUIManager();
		else
			BCUI.inventoryPage:setVisible(not BCUI.inventoryPage:getIsVisible());
		end
	end
end
-- }}}

-- Called when an object with a container is added/removed from the world.
-- Added this to handle campfire containers.
-- BCUIISInventoryPage.OnContainerUpdate = function(object) -- {{{
	-- BCUIISInventoryPage.dirtyUI()
-- end

Events.OnKeyPressed.Add(BCUIISInventoryPage.onKeyPressed);
-- Events.OnContainerUpdate.Add(BCUIISInventoryPage.OnContainerUpdate)

--Events.OnCreateUI.Add(testInventory);
