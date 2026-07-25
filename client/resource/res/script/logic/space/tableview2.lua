------------------------------------------------------------------
-- 列表控件
-- eg:
-- local t = TableView2.create(parent)
-- t:setViewSize(w, h)
-- t:setPosition(100, 200)
-- t:setCellInterval(5, 5)
-- t:setDataSourceFunc(func)
-- t:setCellCount(10)
-- t:reloadData()
--
-- dataSourceFunc eg:
-- @TableView2	this TableView2
-- @idx			count from 0
-- @cell		reused cell, if nil, you must create one
-- TableView2GetCellAtIndex(TableView2, idx, cell)
------------------------------------------------------------------

TableView2 = {}
TableView2.__index = TableView2

TableView2.VERTICAL	 = 0
TableView2.HORIZONTAL = 1

local EDGE_TOP      = 1
local EDGE_BOTTOM   = 2

local EDGE_OFFSET_TO_REFRESH = 50 --拉动位置偏移边界多少距离后触发上拉/下拉刷新

local function vec2(x,y)
	return CEGUI.UVector2(CEGUI.UDim(0, x), CEGUI.UDim(0, y))
end

local function dim(v)
	return CEGUI.UDim(0, v)
end

function TableView2.create(parent, direction)
	if not parent then
		return
	end
	local ret = {}
	setmetatable(ret, TableView2)
	ret:initTableView2(parent, direction)
   
	return ret
end

function TableView2:clearData()
    self.cellCount = 0
	self.columCount = 1
	self.visibleCells = {}
	self.reuseCells = {}
	self.dataSource = nil
	self.createCellCount = 0
	self.cellSize = {width=0, height=0}
    self.interval = {x=-1, y=-1}

    self.vCellData = {}
    self.getCellHeightCallFunc = {}
    self.nHeightAll = 0

end

function TableView2:initTableView2(parent, direction)
	local winMgr = CEGUI.WindowManager:getSingleton()
	
	self.scroll = CEGUI.toScrollablePane(winMgr:createWindow("TaharezLook/ScrollablePane"))
    if parent then
	    parent:addChildWindow(self.scroll)
    end
	
	self.container = winMgr:createWindow("DefaultWindow")
	self.container:setProperty("LimitWindowSize", "False")
	self.scroll:addChildWindow(self.container)
	
	self.scroll:subscribeEvent("ContentPaneScrolled", TableView2.handleContentScrolled, self)
    self.scroll:subscribeEvent("Drag", TableView2.handleScrollDrag, self)
	
	self.direction = direction or TableView2.VERTICAL
	if self.direction == TableView2.HORIZONTAL then
		self.scroll:EnableHorzScrollBar(true)
	end
	self:clearData()
end

function TableView2:setViewSize(width, height)
	self.scroll:setSize(vec2(width, height))
	--self.container:setSize(vec2(width, height))
end

function TableView2:setScrollContentSize(width,height)
    self.container:setSize(vec2(width, height))
end

function TableView2:setPosition(x, y)
	self.scroll:setPosition(vec2(x, y))
end

--TODO: 目前只对纵向做了处理
function TableView2:setColumCount(count)
	self.columCount = count
end

function TableView2:setCellCount(count)
	self.cellCount = count
    self:refreshScrollSize()
end

function TableView2:clearCellPosData()
    self.vCellData = {}
end



function TableView2:setCellInterval(x, y)
    self.interval.x = x or self.interval.x
    self.interval.y = y or self.interval.y
end




function TableView2:refreshScrollSize()
    local nHeightAll = self:refreshCurAllCellHeight()
    self.nHeightAll = nHeightAll
	local s = self.scroll:getPixelSize()
    if nHeightAll < s.height then
        nHeightAll = s.height
    end
	self.container:setSize(vec2(s.width, nHeightAll))
end


function TableView2:recalculateSize()
    self:refreshScrollSize()
end

--清空列表，不销毁
function TableView2:clear()
	self:setCellCount(0)
	self:reloadData()
end

function TableView2:destroyCells()
    self.vCellData = {}
	self:clear()
	for _,v in pairs(self.reuseCells) do
		if v.OnClose then
			v:OnClose(false, false)
		end
	end
	self.reuseCells = {}
end

function TableView2:empty()
	for _ in pairs(self.visibleCells) do
		return false
	end
	return true
end

function TableView2:genCellPrefix()
	return tostring(self.createCellCount)
end

--只会返回当前可见的cell
function TableView2:getCellAtIdx(idx)
	return self.visibleCells[idx]
end

function TableView2:refreshCurAllCellHeight()
    local nHeight =1
    for nIdx=0,self.cellCount-1 do
        local nIndex = nIdx+1
        local cellData = self:getOneCellHeightData(nIdx)
        if cellData then
            cellData.nPosY = nHeight
            nHeight = nHeight+cellData.nHeight
        end
    end
    return nHeight
end

--function TableView2:


function TableView2:getOneCellHeightData(nIdx) --0--

    if not self.getCellHeightCallFunc.target or not self.getCellHeightCallFunc.func then
        return nil
    end
    
    local nIndex = nIdx+1
    local cellData = self.vCellData[nIndex]
    if not cellData then
        local nHeight =  self.getCellHeightCallFunc.func(self.getCellHeightCallFunc.target,nIdx)
        self.vCellData[nIndex] = {}
        self.vCellData[nIndex].nHeight = nHeight
    else
        --cellData.nHeight = nHeight
    end
    return self.vCellData[nIndex]
end 


function TableView2:setGetCellHeightCallFunc(target,func)
    self.getCellHeightCallFunc = { target=target, func=func }
end

--@dataSourceFunc: function(target, TableView2, idx, reuseCell)
function TableView2:setDataSourceFunc(target, dataSourceFunc)
	self.dataSource = { target=target, func=dataSourceFunc }
end

--@func: function(target, TableView2, isReachTop)
function TableView2:setReachEdgeCallFunc(target, func)
    self.reachEdgeCallFunc = { target=target, func=func }
end

function TableView2:getContentOffset()
    if self.direction == TableView2.VERTICAL then
        return self.scroll:getVertScrollbar():getScrollPosition()
    else
    	return self.scroll:getHorzScrollbar():getScrollPosition()
    end
end

function TableView2:addCell(idx, reuseCell, forTest)
    local cell = self.dataSource.func(self.dataSource.target, self, idx, reuseCell)
	if cell then
		cell.window = cell.window or cell:GetWindow()
		if not reuseCell then
			if not cell.window:getParent() then
				self.container:addChildWindow(cell.window)
			end
			self.createCellCount = self.createCellCount+1
			self.scroll:EnableChildDrag(cell.window)
		else
			cell.window:setVisible(true)
		end
			
        local nPosY = 0
        if self.vCellData[idx+1] then
             nPosY = self.vCellData[idx+1].nPosY
        end
	    cell.window:setPosition(vec2(1, nPosY))
		--print('cell pos y', cell.window:getYPosition().offset, idx)
        if forTest then
            table.insert(self.reuseCells, cell)
        else
		    self.visibleCells[idx] = cell
        end
	end
    return cell
end

function TableView2:getIdxWithPosY(nContentOffset)
   local nResultIdx = 0
   for nIdx=0,self.cellCount-1 do
        local cellData = self.vCellData[nIdx+1]
        if cellData then
            if nContentOffset>=cellData.nPosY and nContentOffset<=cellData.nPosY+cellData.nHeight then
                nResultIdx = nIdx
                return nResultIdx
            end
        end
   end
   return nResultIdx
end


function TableView2:reloadData()
	for _,v in pairs(self.visibleCells) do
		table.insert(self.reuseCells, v)
		v.window:setVisible(false)
	end
	self.visibleCells = {}
	
	if self.cellCount == 0 then
		return
	end
    self.startIdx , self.endIdx = self:countCellIdxRange()
	
	for i=self.startIdx,self.endIdx do
		local reuseCell = nil
		if #self.reuseCells > 0 then
			reuseCell = self.reuseCells[1]
			table.remove(self.reuseCells, 1)
		end
        self:addCell(i, reuseCell)
	end
end

function TableView:setContentOffset(offset)
    
	local bar = self.scroll:getVertScrollbar()
	local pageH = bar:getPageSize()
	local docH  = bar:getDocumentSize()
		
	offset = math.max(0, math.min(docH-pageH, offset)) / docH
	self.scroll:getVertScrollbar():Stop()
	self.scroll:setVerticalScrollPosition(offset)
end


function TableView2:handleContentScrolled(args)
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
			local reuseCell = nil
			if #self.reuseCells > 0 then
				reuseCell = self.reuseCells[1]
				table.remove(self.reuseCells, 1)
			end
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
				local reuseCell = nil
				if #self.reuseCells > 0 then
					reuseCell = self.reuseCells[1]
					table.remove(self.reuseCells, 1)
				end

				self:addCell(i, reuseCell)
			end
		end
		if endIdx > self.endIdx then
			for i=self.endIdx+1, endIdx do
				local reuseCell = nil
				if #self.reuseCells > 0 then
					reuseCell = self.reuseCells[1]
					table.remove(self.reuseCells, 1)
				end
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

function TableView2:handleScrollDrag(args)
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
function TableView2:countCellIdxRange()
    
    local pane = self.scroll:getContentPane()
	local offset = pane:getYPosition().offset
    local nContentOffset = -offset

    local nStartIndex = self:getIdxWithPosY(nContentOffset)

    local nScrollHeight = self.container:getPixelSize().height
    if self.nHeightAll <= nScrollHeight then
        local nEndIndex = self.cellCount-1
        return nStartIndex,nEndIndex
    end

    local nBottomY = nContentOffset + self.scroll:getPixelSize().height
    local nEndIndex = self:getIdxWithPosY(nBottomY)
    return nStartIndex,nEndIndex	
end

return TableView2