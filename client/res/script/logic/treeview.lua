------------------------------------------------------------------
-- 树状列表控件
--[[
[ EXAMPLE ]
local tree = TreeView.create(self:GetWindow(), 150, 400)
tree:setPosition(100, 100)
for i=1,4 do
	local parent = tree:addParentItem("TaharezLook/GroupButton", 150, 50)
	parent.item:setText('parent' .. i)
	for j=1,2 do
		local child = tree:addChildItem("TaharezLook/CellGroupButton", parent, 150, 80)
		child:setText('child' .. j)
	end
end
tree:fresh()
--]]
------------------------------------------------------------------

TreeView = {}
TreeView.__index = TreeView

local EDGE_TOP      = 1
local EDGE_BOTTOM   = 2

local EDGE_OFFSET_TO_REFRESH = 50 --拉动位置偏移边界多少距离后触发上拉/下拉刷新

local function vec2(x,y)
	return CEGUI.UVector2(CEGUI.UDim(0, x), CEGUI.UDim(0, y))
end

function TreeView.create(parent, width, height)
	if not parent then
		return
	end
	local ret = {}
	setmetatable(ret, TreeView)
	ret:initTreeView(parent, width, height)
	return ret
end

function TreeView:initTreeView(parent, width, height)
	local winMgr = CEGUI.WindowManager:getSingleton()
	self.winMgr = winMgr

	self.scroll = CEGUI.toScrollablePane(winMgr:createWindow("TaharezLook/ScrollablePane"))
    if parent then
	    parent:addChildWindow(self.scroll)
    end
	self.scroll:subscribeEvent("Drag", TreeView.handleScrollDrag, self)
	self.scroll:subscribeEvent("ContentPaneScrolled", TreeView.handleContentScrolled, self)
	
	self.container = winMgr:createWindow("DefaultWindow")
	self.container:setProperty("LimitWindowSize", "False")
	self.scroll:addChildWindow(self.container)

	self.scroll:setSize(vec2(width, height))
	self.container:setSize(vec2(width, height))

	self.parentItems = {}
	self.openedParentItem = nil
	self.selectedChildItem = nil
	self.child2parent = {}
end




function TreeView:handleContentScrolled(args)
    if self.draging and not self.reachEdge then
        local bar = self.scroll:getVertScrollbar()
        local p = bar:getScrollPosition()
        --print("scroll position " .. p)
        if p < -EDGE_OFFSET_TO_REFRESH then
            self.reachEdge = EDGE_TOP
            print("reach top")
        else
            local pageH = bar:getPageSize()
            local docH = math.max(bar:getDocumentSize(), pageH) 
            if p > docH - pageH + EDGE_OFFSET_TO_REFRESH then
                self.reachEdge = EDGE_BOTTOM
                print("reach bottom")
            end
        end
    end
end

function TreeView:handleScrollDrag(args)
    local e = CEGUI.toGestureEventArgs(args)
    local state = e.d_Recognizer:GetState()
    if state == CEGUI.Gesture.GestureRecognizerStateBegan then
        self.draging = true
    elseif state == CEGUI.Gesture.GestureRecognizerStateEnded then
        self.draging = false
        if self.reachEdge then
            if self.reachEdgeCallFunc then
                self.reachEdgeCallFunc.func(self.reachEdgeCallFunc.target, self, self.reachEdge==EDGE_TOP)
            end
            self.reachEdge = nil
        end
    end
end

--@func: function(target, tableView, isReachTop)
function TreeView:setReachEdgeCallFunc(target, func)
    self.reachEdgeCallFunc = { target=target, func=func }
end


function TreeView:setPosition(x, y)
    if self.scroll then
    	self.scroll:setPosition(CEGUI.UVector2(CEGUI.UDim(0,x), CEGUI.UDim(0, y)))
    end
end

function TreeView:setScrollPos(y)
    self.scroll:getVertScrollbar():setScrollPosition(y, false)
    self.scroll:getVertScrollbar():Back()
end

function TreeView:addParentItem(widgetType, width, height)
	if not widgetType then
		return
	end
	local item = CEGUI.toGroupButton(self.winMgr:createWindow(widgetType))
	if not item then
		return
	end
	item:setGroupID(1)
	item:setProperty("AllowModalStateClick", "True")
	item:setSize(vec2(width, height))
	item:EnableClickAni(false)
	self.container:addChildWindow(item)
	self.scroll:EnableChildDrag(item)
	item:subscribeEvent("MouseClick", TreeView.handleParentItemClicked, self)
	local newItem = {}
	newItem.item = item
	newItem.children = {}
	table.insert(self.parentItems, newItem)
	return newItem
end

function TreeView:addChildItem(widgetType, parentItem, width, height)
	if not widgetType or not parentItem then
		return
	end
	local item = CEGUI.toGroupButton(self.winMgr:createWindow(widgetType))
	if not item then
		return
	end
	item:setGroupID(2)
	item:setProperty("AllowModalStateClick", "True")
	item:setSize(vec2(width, height))
	item:EnableClickAni(false)
	item:subscribeEvent("MouseClick", TreeView.handleChildItemClicked, self)
	self.container:addChildWindow(item)
	self.scroll:EnableChildDrag(item)
	self.child2parent[item] = parentItem.item
	table.insert(parentItem.children, item)
	return item
end

function TreeView:fresh()
	if not self.parentItems or #self.parentItems == 0 then
		return
	end
	local y = 0;
	for _,v in pairs(self.parentItems) do
		v.item:setYPosition(CEGUI.UDim(0, y))
		y = y + v.item:getPixelSize().height
		if self.openedParentItem == v.item then
			for _,v1 in pairs(v.children) do
				v1:setVisible(true)
				v1:setYPosition(CEGUI.UDim(0, y))
				y = y + v1:getPixelSize().height
			end
		else
			for _,v2 in pairs(v.children) do
				v2:setVisible(false)
			end
		end
	end

    local nTotalHeight = y
    local sizeWidth =  self.scroll:getPixelSize().width
    local sizeHeight =  self.scroll:getPixelSize().height
    if  nTotalHeight < sizeHeight then
        nTotalHeight = sizeHeight
    end

    self.container:setSize(vec2(sizeWidth, nTotalHeight))
    
	
	 if self.draging and not self.reachEdge then
        local bar = self.scroll:getVertScrollbar()
        local p = bar:getScrollPosition()
        --print("scroll position " .. p)
        if p < -EDGE_OFFSET_TO_REFRESH then
            self.reachEdge = EDGE_TOP
            print("reach top")
        else
            local pageH = bar:getPageSize()
            local docH = math.max(bar:getDocumentSize(), pageH) 
            if p > docH - pageH + EDGE_OFFSET_TO_REFRESH then
                self.reachEdge = EDGE_BOTTOM
                print("reach bottom")
            end
        end
    end
	
end

function TreeView:setParentItemClickCallFunc(func, target)
	self.parentCallFunc = {target=target, func=func}
end

function TreeView:setChildItemClickCallFunc(func, target)
	self.childCallFunc = {target=target, func=func}
end

function TreeView:handleParentItemClicked(args)
	local wnd = CEGUI.toWindowEventArgs(args).window
	if self.openedParentItem ~= wnd then
		self.openedParentItem = wnd
	else
		self.openedParentItem = nil
	end
	self:fresh()

	if self.parentCallFunc and self.parentCallFunc.func then
		self.parentCallFunc.func(self.parentCallFunc.target, wnd)
	end
end

function TreeView:handleChildItemClicked(args)
	local wnd = CEGUI.toWindowEventArgs(args).window
	self.selectedChildItem = wnd
	if self.childCallFunc and self.childCallFunc.func then
		self.childCallFunc.func(self.childCallFunc.target, wnd)
	end
end

function TreeView:setOpenParentItem(wnd)
    if not wnd then
        return 
    end
    if self.openedParentItem == wnd then
        return
    end
    if self.openedParentItem ~= wnd then
		self.openedParentItem = wnd
        self.openedParentItem:setSelected(true)
	end
	self:fresh()
end
