------------------------------------------------------------------
-- 列表控件
-- eg:
-- local t = TableView.create(parent)
-- t:setViewSize(w, h)
-- t:setPosition(100, 200)
-- t:setCellInterval(5, 5)
-- t:setDataSourceFunc(func)
-- t:setCellCount(10)
-- t:reloadData()
--
-- dataSourceFunc eg:
-- @tableView	this tableView
-- @idx			count from 0
-- @cell		reused cell, if nil, you must create one
-- tableViewGetCellAtIndex(tableView, idx, cell)
------------------------------------------------------------------

TableView = {}
TableView.__index = TableView

TableView.VERTICAL	 = 0
TableView.HORIZONTAL = 1

local EDGE_TOP      = 1
local EDGE_BOTTOM   = 2

local EDGE_OFFSET_TO_REFRESH = 50 --拉动位置偏移边界多少距离后触发上拉/下拉刷新

local function vec2(x,y)
	return CEGUI.UVector2(CEGUI.UDim(0, x), CEGUI.UDim(0, y))
end

local function dim(v)
	return CEGUI.UDim(0, v)
end

function TableView.create(parent, direction)
	if not parent then
		return
	end
	local ret = {}
	setmetatable(ret, TableView)
	ret:initTableView(parent, direction)
	return ret
end

function TableView:initTableView(parent, direction)
	local winMgr = CEGUI.WindowManager:getSingleton()
	
	self.scroll = CEGUI.toScrollablePane(winMgr:createWindow("TaharezLook/ScrollablePane"))
	if parent then
	    parent:addChildWindow(self.scroll)
    end
	
	self.container = winMgr:createWindow("DefaultWindow")
	self.container:setProperty("LimitWindowSize", "False")
	self.scroll:addChildWindow(self.container)
	
	self.scroll:subscribeEvent("ContentPaneScrolled", TableView.handleContentScrolled, self)
    self.scroll:subscribeEvent("Drag", TableView.handleScrollDrag, self)
	
	self.direction = direction or TableView.VERTICAL
	if self.direction == TableView.HORIZONTAL then
		self.scroll:EnableHorzScrollBar(true)
	end
	
	self.cellCount = 0
	self.columCount = 1
	self.visibleCells = {}
	self.reuseCells = {}
	self.dataSource = nil
	self.createCellCount = 0
	self.cellSize = {width=0, height=0}
    self.interval = {x=-1, y=-1}
end

function TableView:setViewSize(width, height)
	self.scroll:setSize(vec2(width, height))
	self.container:setSize(vec2(width, height))
end

function TableView:setPosition(x, y)
    if self.scroll then
	    self.scroll:setPosition(vec2(x, y))
    end
end

--TODO: 目前只对纵向做了处理
function TableView:setColumCount(count)
	self.columCount = count
end

function TableView:setCellSize(cellWidth, cellHeight)
    --@deprecated
    do return end

	self.cellSize.width = cellWidth or self.cellSize.width
	self.cellSize.height = cellHeight or self.cellSize.height
end

function TableView:setCellCount(count)
	self.cellCount = count

    if self.cellSize.width == 0 and self.cellSize.height == 0 then
        return
    end

	self.rowCount = math.ceil( count / self.columCount )
	
	local s = self.scroll:getPixelSize()
	if self.direction == TableView.VERTICAL then
		local h = math.max(self.rowCount * self.cellSize.height, s.height)
		self.container:setSize(vec2(s.width, h))
	else
		local w = math.max(count * self.cellSize.width, s.width)
		self.container:setSize(vec2(w, s.height))
	end
end

function TableView:setCellCountAndSize(count, cellWidth, cellHeight)
	self.cellCount = count
	self.rowCount = math.ceil( count / self.columCount )
	
    if self.cellSize.width == 0 and self.cellSize.height == 0 then
        return
    end

    --@deprecated
	--self.cellSize.width = cellWidth or self.cellSize.width
	--self.cellSize.height = cellHeight or self.cellSize.height
	
	local s = self.scroll:getPixelSize()
	if self.direction == TableView.VERTICAL then
		local h = math.max(self.rowCount * self.cellSize.height, s.height)
		self.container:setSize(vec2(s.width, h))
	else
		local w = math.max(count * self.cellSize.width, s.width)
		self.container:setSize(vec2(w, s.height))
	end
end

function TableView:setCellInterval(x, y)
    self.interval.x = x or self.interval.x
    self.interval.y = y or self.interval.y
end

function TableView:recalculateSize()
    if self.cellCount == 0 then
        return
    end
    
    if self.cellSize.width == 0 or self.cellSize.height == 0 then
        return
    end

    self.rowCount = math.ceil( self.cellCount / self.columCount )

    local s = self.scroll:getPixelSize()
	if self.direction == TableView.VERTICAL then
		local h = math.max(self.rowCount * self.cellSize.height, s.height)
		self.container:setSize(vec2(s.width, h))
	else
		local w = math.max(self.cellCount * self.cellSize.width, s.width)
		self.container:setSize(vec2(w, s.height))
	end
end

--清空列表，不销毁
function TableView:clear()
	self:setCellCount(0)
	self:reloadData()
end

function TableView:destroyCells()
	self:clear()
	for _,v in pairs(self.reuseCells) do
		if v.OnClose then
			v:OnClose(false, false)
		end
	end
	self.reuseCells = {}
end

function TableView:empty()
	for _ in pairs(self.visibleCells) do
		return false
	end
	return true
end

function TableView:genCellPrefix()
	return tostring(self.createCellCount)
end

--只会返回当前可见的cell
function TableView:getCellAtIdx(idx)
	return self.visibleCells[idx]
end

--调整offset，让对应的cell能够显示出来, idx从0算起
function TableView:focusCellAtIdx(idx)
	if idx < 0 or idx >= self.cellCount then
		return
	end
	
	if self.direction == TableView.VERTICAL then
		local row = math.floor(idx/self.columCount)
		self:setContentOffset(row * self.cellSize.height)
		self:reloadData()
		return self:getCellAtIdx(idx)
	end
	return nil
end

--@dataSourceFunc: function(target, tableView, idx, reuseCell)
function TableView:setDataSourceFunc(target, dataSourceFunc)
	self.dataSource = { target=target, func=dataSourceFunc }
end

--@func: function(target, tableView, isReachTop)
function TableView:setReachEdgeCallFunc(target, func)
    self.reachEdgeCallFunc = { target=target, func=func }
end

function TableView:setContentOffset(offset)
    if self.cellSize.height == 0 and self.cellCount > 0 then
        self:addCell(0, nil, true) --读取一个cell，获取cell的尺寸
    end
    
	if self.direction == TableView.VERTICAL then
		local bar = self.scroll:getVertScrollbar()
		bar:Stop()
		bar:setScrollPosition(offset)
	else
		local bar = self.scroll:getHorzScrollbar()
		bar:Stop()
		bar:setScrollPosition(offset)
	end
end

function TableView:getContentOffset()
    if self.direction == TableView.VERTICAL then
        return self.scroll:getVertScrollbar():getScrollPosition()
    else
    	return self.scroll:getHorzScrollbar():getScrollPosition()
    end
end

function TableView:getReuseCell()
	for k,cell in pairs(self.reuseCells) do
		if not cell.window:isCapturedByThis() then
			local reuseCell = self.reuseCells[k]
			table.remove(self.reuseCells, k)
			return reuseCell
		end
	end
	return nil
end

function TableView:addCell(idx, reuseCell, forTest)
    local cell = self.dataSource.func(self.dataSource.target, self, idx, reuseCell)
	if cell then
		cell.window = cell.window or cell:GetWindow()

        if self.cellSize.width == 0 then
            local s = cell.window:getPixelSize()
            if self.interval.x == -1 then
                if self.direction == TableView.VERTICAL then
                    local ws = self.scroll:getPixelSize()
                    self.interval.x = math.max(0, ws.width-s.width*self.columCount)
                    if self.columCount > 2 then
                        self.interval.x = self.interval.x / (self.columCount-1)
                    end
                else
                    self.interval.x = 0
                end 
            end
            if self.interval.y == -1 then
                self.interval.y = 0
            end
            self.cellSize.width = s.width + self.interval.x
            self.cellSize.height = s.height + self.interval.y
            self:recalculateSize()
        end

		if not reuseCell then
			if not cell.window:getParent() then
				self.container:addChildWindow(cell.window)
			end
			self.createCellCount = self.createCellCount+1
			self.scroll:EnableChildDrag(cell.window)
		else
			cell.window:setVisible(true)
		end
			
		if self.direction == TableView.VERTICAL then
			cell.window:setPosition(vec2(idx%self.columCount*self.cellSize.width, math.floor(idx/self.columCount)*self.cellSize.height))
		else
			cell.window:setPosition(vec2(idx*self.cellSize.width, 0))
		end
	
		--print('cell pos y', cell.window:getYPosition().offset, idx)
        if forTest then
            table.insert(self.reuseCells, cell)
            cell.window:setVisible(false)
        else
		    self.visibleCells[idx] = cell
        end
	end
    return cell
end

function TableView:reloadData()
	for _,v in pairs(self.visibleCells) do
		table.insert(self.reuseCells, v)
		v.window:setVisible(false)
	end
	self.visibleCells = {}
	
	if self.cellCount == 0 then
		return
	end

    if self.cellSize.height == 0 and self.cellCount > 0 then
        self:addCell(0, nil, true) --读取一个cell，获取cell的尺寸
    end
	
	self.startIdx, self.endIdx = self:countCellIdxRange()

	for i=self.startIdx, self.endIdx do
		local reuseCell = self:getReuseCell()
        self:addCell(i, reuseCell)
	end
end

function TableView:handleContentScrolled(args)
	if self.cellCount == 0 or not self.startIdx or not self.endIdx then
		return
	end
	
	local startIdx, endIdx = self:countCellIdxRange()
	--print('idx range', startIdx, endIdx, self.startIdx, self.endIdx)
	
	
	if startIdx > self.endIdx or endIdx < self.startIdx then
		--新范围与旧范围没有交集，全部回收
		for _,v in pairs(self.visibleCells) do
			table.insert(self.reuseCells, v)
			v.window:setVisible(false)
		end
		self.visibleCells = {}
		
		--显示新范围内的行
		for i=startIdx, endIdx do
			local reuseCell = self:getReuseCell()
            self:addCell(i, reuseCell)
		end
		
	else
		
		--回收不再显示的
		if startIdx > self.startIdx then
			for i=self.startIdx, startIdx-1 do
				local cell = self.visibleCells[i]
				if cell then
					table.insert(self.reuseCells, cell)
					cell.window:setVisible(false)
					self.visibleCells[i] = nil
				end
			end
		end
		
		if endIdx < self.endIdx then
			for i=endIdx+1, self.endIdx do
				local cell = self.visibleCells[i]
				if cell then
					table.insert(self.reuseCells, cell)
					cell.window:setVisible(false)
					self.visibleCells[i] = nil
				end
			end
		end
		
		--添加进入显示区域的
		if startIdx < self.startIdx then
			for i=startIdx, self.startIdx-1 do
				local reuseCell = self:getReuseCell()
				self:addCell(i, reuseCell)
			end
		end
		
		if endIdx > self.endIdx then
			for i=self.endIdx+1, endIdx do
				local reuseCell = self:getReuseCell()
                self:addCell(i, reuseCell)
			end
		end
	end
	
	self.startIdx, self.endIdx = startIdx, endIdx

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

function TableView:handleScrollDrag(args)
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

------------------------------------------------------
--from 0 to self.cellCount-1
function TableView:countCellIdxRange()
	local pane = self.scroll:getContentPane()
	
	local startIdx = 0
	local endIdx = 0
	
	if self.direction == TableView.VERTICAL then
		local offset = pane:getYPosition().offset
		
		local h = self.scroll:getPixelSize().height --view height
		
		startIdx = (offset >= 0 and 0 or math.floor(-offset / self.cellSize.height)*self.columCount)
		endIdx = math.ceil((h-offset) / self.cellSize.height)*self.columCount-1
		--print('endidx', h, offset, endIdx)
	else
		local offset = pane:getXPosition().offset
		
		local w = self.scroll:getPixelSize().width --view width
		
		startIdx = (offset >= 0 and 0 or math.floor(-offset / self.cellSize.width))
		endIdx = math.ceil((w-offset) / self.cellSize.width)-1
	end
	
	startIdx = math.min(math.max(startIdx, 0), self.cellCount-1)
	endIdx = math.min(math.max(endIdx, 0), self.cellCount-1)
	--print('idx range', startIdx, endIdx)
	
	return startIdx, endIdx
end
function TableView:setScrollEnbale(bln)
    self.scroll:getVertScrollbar():EnbalePanGuesture(bln)
end

return TableView