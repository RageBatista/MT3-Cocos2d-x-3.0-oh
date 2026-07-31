require "logic.dialog"
require "logic.bingfengwangzuo.bingfengwangzuocell"
require "logic.bingfengwangzuo.bingfengwangzuoBtnCell"
require "logic.bingfengwangzuo.bingfengwangzuozhiyecell"
require "logic.bingfengwangzuo.bingfengwangzuoRankCell"

bingfengwangzuoDlg = {}
setmetatable(bingfengwangzuoDlg, Dialog)
bingfengwangzuoDlg.__index = bingfengwangzuoDlg

local _instance
function bingfengwangzuoDlg.getInstance()
	if not _instance then
		_instance = bingfengwangzuoDlg:new()
		_instance:OnCreate( )
	end
	return _instance
end

function bingfengwangzuoDlg.getInstanceAndShow(stage, yesterdaystage)
	if not _instance then
		_instance = bingfengwangzuoDlg:new()
		_instance:OnCreate(stage, yesterdaystage)
	else
		_instance:SetVisible(true)
	end
	return _instance
end

function bingfengwangzuoDlg.getInstanceNotCreate()
	return _instance
end

function bingfengwangzuoDlg.DestroyDialog()
	if _instance then 
		if not _instance.m_bCloseIsHide then
			if _instance.cell then
				for index in pairs( _instance.cell ) do
					local cell = _instance.cell[index]
					if cell then
						cell:OnClose(false, false)
						cell = nil
					end
				end
			end
			if _instance.zhiyeCell then
				for index in pairs( _instance.zhiyeCell ) do
					local cell = _instance.zhiyeCell[index]
					if cell then
						cell:OnClose(false, false)
						cell = nil
					end
				end
			end
		if _instance.textScrollAnimation then
            _instance.textScrollAnimation:stop() 
        end
		if _instance.textScrollAnimation1 then
            _instance.textScrollAnimation1:stop() 
        end
			_instance:clearRankInfoCell()
			_instance:OnClose()
			_instance = nil
		else
			_instance:ToggleOpenClose()
		end
	end
end

function bingfengwangzuoDlg.ToggleOpenClose()
	if not _instance then
		_instance = bingfengwangzuoDlg:new()
		_instance:OnCreate( )
	else
		if _instance:IsVisible() then
			_instance:SetVisible(false)
		else
			_instance:SetVisible(true)
		end
	end
end

function bingfengwangzuoDlg.GetLayoutFileName()
	return "bingfengwangzuo_mtg.layout"
end

function bingfengwangzuoDlg.refreshMapInfo( page, stage )
	_instance.curPage = page
    _instance.stage = stage
	_instance:clearCell()
	_instance:initMapInfo(page)
end

function bingfengwangzuoDlg:new()
	local self = {}
	self = Dialog:new()
	setmetatable(self, bingfengwangzuoDlg)
	return self
end

function bingfengwangzuoDlg:OnCreate( stage, yesterdaystage )

	Dialog.OnCreate(self)
	local winMgr = CEGUI.WindowManager:getSingleton()
	self.stage = stage
    self.yesterdaystage = yesterdaystage
	self.selectButtonId = 0
	
	self.cc_mjxy = winMgr:getWindow("bingfengwangzuo_mtg/cczyc1")

    local aniMan = CEGUI.AnimationManager:getSingleton()
    local animationOpen = aniMan:getAnimation("ccjiemianc1") 
    self.animationInstance = aniMan:instantiateAnimation(animationOpen) 
    self.animationInstance:setTargetWindow(self.cc_mjxy)
    self.animationInstance:start()
	
	self.cc_mjphmb = winMgr:getWindow("bingfengwangzuo_mtg/ccmake/ccmb1")
	
    self.backGroundList = CEGUI.toScrollablePane(winMgr:getWindow("bingfengwangzuo_mtg/list"))
	self.btnRank = CEGUI.toPushButton(winMgr:getWindow("bingfengwangzuo_mtg/btnpaihang"))
	self.cc_Close = CEGUI.toPushButton(winMgr:getWindow("bingfengwangzuo_mtg/mjzz"))
	self.heikuang = winMgr:getWindow("bingfengwangzuo_mtg/heikuang")



	self.cc_tips = CEGUI.toRichEditbox(winMgr:getWindow("bingfengwangzuo_mtg/cczyc1/cctips"))
	self.cc_tips:Clear()
    self.cc_tips:AppendParseText(CEGUI.String(MHSD_UTILS.get_resstring(7564)))
    self.cc_tips:Refresh()

    local animationDefcc1 = CEGUI.AnimationManager:getSingleton():getAnimation("shangchenggundong1")
    self.textScrollAnimation = CEGUI.AnimationManager:getSingleton():instantiateAnimation(animationDefcc1)
    self.textScrollAnimation:setTargetWindow(self.cc_tips)
    self.textScrollAnimation:start()
    
	
	local animationDefcc2 = CEGUI.AnimationManager:getSingleton():getAnimation("shangchenggundong2")
    self.textScrollAnimation1 = CEGUI.AnimationManager:getSingleton():instantiateAnimation(animationDefcc2)
    self.textScrollAnimation1:setTargetWindow(self.cc_tips) 
	
	
    self.cc_tips:subscribeEvent(
        "AnimationEnded", 
        function(args)
            self.textScrollAnimation1:start() 
        end
    ) 
	
	self.heikuangList = CEGUI.toScrollablePane(winMgr:getWindow("bingfengwangzuo_mtg/heikuang/list"))
	self.leaveTime = winMgr:getWindow("bingfengwangzuo_mtg/cishu")
	self.text = winMgr:getWindow("bingfengwangzuo_mtg/text")
	self.btnLevel = CEGUI.Window.toPushButton(winMgr:getWindow("bingfengwangzuo_mtg/btndengji"))
	self.btnUp = CEGUI.Window.toPushButton(winMgr:getWindow("bingfengwangzuo_mtg/btndengji/xiajiantou"))
	self.btnDown = CEGUI.Window.toPushButton(winMgr:getWindow("bingfengwangzuo_mtg/btndengji/shangjiantou"))
	--self.schoolBg = winMgr:getWindow("bingfengwangzuo_mtg/paihangdi")
	self.schoolList = CEGUI.toScrollablePane(winMgr:getWindow("bingfengwangzuo_mtg/paihangdi/list"))
	--self.rankBg = winMgr:getWindow("bingfengwangzuo_mtg1")
	self.rankList = CEGUI.toScrollablePane(winMgr:getWindow("bingfengwangzuo_mtg/list1"))
	self.textSchool = winMgr:getWindow("bingfengwangzuo_mtg/zhiye")
	self.cc_mjxz = winMgr:getWindow("bingfengwangzuo_mtg/btnpaihang/czyc11")
	self.cc_mjfz = winMgr:getWindow("bingfengwangzuo_mtg/btnpaihang/ccmjfz")
	self.cc_mjjljm = winMgr:getWindow("bingfengwangzuo_mtg/ccmake1/ccjlbg")

	self.cc_mjph = CEGUI.toPushButton(winMgr:getWindow("bingfengwangzuo_mtg/ccmake"))
	self.cc_mjjlsm = CEGUI.toPushButton(winMgr:getWindow("bingfengwangzuo_mtg/ccmake1"))
	self.cc_jlyl = CEGUI.toPushButton(winMgr:getWindow("bingfengwangzuo_mtg/cczyc1/ccjlyl"))
	self.schoolList:setAlwaysOnTop(true)
	self.rankList:setAlwaysOnTop(true)

	self.btnLevel:subscribeEvent("Clicked", bingfengwangzuoDlg.HandleBtnLevelClick, self)
	self.btnRank:subscribeEvent("Clicked", bingfengwangzuoDlg.HandleBtnRankClick, self)
	self.cc_mjph:subscribeEvent("Clicked", bingfengwangzuoDlg.HandleBtnRankCClick, self)
	self.cc_mjjlsm:subscribeEvent("Clicked", bingfengwangzuoDlg.HandleBtnRankCCClick, self)
	self.cc_jlyl:subscribeEvent("Clicked", bingfengwangzuoDlg.HandleBtnjlylClick, self)
	self.cc_Close:subscribeEvent("Clicked", bingfengwangzuoDlg.btnCloseCallBack, self)
	self.heikuang:setVisible(false)
	self.btnDown:setVisible(false)
--	self.rankBg:setVisible(false)
	self.cc_mjph:setVisible(false)
	self.cc_mjjlsm:setVisible(false)
--	self.schoolBg:setVisible(false)
	self:initLevelMenu()
	self:initRankInfo()
	self:initMyRankInfo()
end
-- 初始化地图信息
function bingfengwangzuoDlg:initMapInfo( page )
    
	local num = BeanConfigManager.getInstance():GetTableByName("instance.cbingfengwangzuomap"):getSize()
    self.page = page
	self.mapInfo = BeanConfigManager.getInstance():GetTableByName("instance.cbingfengwangzuomap"):getRecorder(page)
	local imageNum = 0
	local index = 0
    self.enemyNum = self.mapInfo.enemyNum
	self.cell = {}
	self.image = {
		[1] = self.mapInfo.image1,
		[2] = self.mapInfo.image2,
		[3] = self.mapInfo.image3,
		[4] = self.mapInfo.image4,
		[5] = self.mapInfo.image5,
		[6] = self.mapInfo.image6,
		[7] = self.mapInfo.image7,
		[8] = self.mapInfo.image8,
	}
	for i=1,8 do
		if self.image[i] ~= "0" then
			imageNum = imageNum + 1
		end
	end
    if not self.m_tableView then
        local s = self.backGroundList:getPixelSize()
        self.m_tableView = TableView.create(self.backGroundList, TableView.HORIZONTAL)
        self.m_tableView:setViewSize(s.width, s.height)
        self.m_tableView:setPosition(0, 0)
        self.m_tableView:setDataSourceFunc(self, bingfengwangzuoDlg.tableViewGetCellAtIndex)
    end
    --self.m_tableView:reloadData()
    self.m_tableView:setCellCountAndSize(imageNum, 945, 520)
    self.m_tableView:setCellInterval(0,0)
    self.m_tableView:reloadData()
    local pageSize = self.backGroundList:getHorzScrollbar():getPageSize()
    local curPage = math.ceil((self.stage+1) / 4 - 1) -- 计算当前页面 原始是5
    local pageOffset = pageSize*curPage + self:getCurStagePosX()-- - pageSize * 0.5  -- 当前页面+itemcell位置-一半页面size+偏移 原始是0.5
    self.m_tableView:setContentOffset(pageOffset)
	local info = BeanConfigManager.getInstance():GetTableByName("instance.cbingfengwangzuomap"):getRecorder(page)
	--self.btnLevel:setText(info.mapName)
	self.cc_mjxz:setText(info.mapName)
	self.cc_mjfz:setProperty("Image", info.ccbiaoshi)
end

function bingfengwangzuoDlg:tableViewGetCellAtIndex(tableView, idx, cell)
    if not cell then
        cell = bingfengwangzuocell.CreateNewDlg( tableView.container, idx )
        cell:setParent(self)
    end
    cell.bg:setProperty("Image", self.image[idx+1])
    cell:setCellVisible(self.curPage, idx+1, self.enemyNum, self.stage, self.yesterdaystage)
    return cell
end
-- 初始化等级按钮菜单
function bingfengwangzuoDlg:initLevelMenu()
	self.btnCell = {}
	local index = 0
	local num = BeanConfigManager.getInstance():GetTableByName("instance.cbingfengwangzuomap"):getSize()
	for i=1,num do
		local info = BeanConfigManager.getInstance():GetTableByName("instance.cbingfengwangzuomap"):getRecorder(i)
		self.btnCell[i] = bingfengwangzuoBtnCell.CreateNewDlg( self.heikuangList )
		self.heikuangList:addChildWindow(self.btnCell[i].window)
		--self.btnCell[i].btn:setText(info.mapName)
		self.btnCell[i].mijingName:setText(info.ccmapName)
		self.btnCell[i].fjicon:setProperty("Image", info.ccbiaoshi)
		--self.btnCell[i].btn:setText(info.mapName)
		self.btnCell[i].btn:setID(i)
		local cellHeight = self.btnCell[i].m_pMainFrame:getPixelSize().height + 5
		local yPos = cellHeight*index
		local xPos = 1
		index = index  + 1
		self.btnCell[i].m_pMainFrame:setPosition(CEGUI.UVector2(CEGUI.UDim(0.0, xPos), CEGUI.UDim(0.0, yPos)))
		if gGetDataManager() and gGetDataManager():GetMainCharacterLevel() < info.level then
			self.btnCell[i].btn:setEnabled(false)
		end
		self.btnCell[i].btn:subscribeEvent("Clicked", bingfengwangzuoDlg.HandleBtnLevelSelectClick, self)
	end
end
-- 初始化排行榜信息
function bingfengwangzuoDlg:initRankInfo()
    self.zhiyeCell = {}
    local schoolTable = BeanConfigManager.getInstance():GetTableByName("role.schoolinfo")
    local allSchoolIds = schoolTable:getAllID()
    local cellPerRow = 2
    local cellWidth = self.schoolList:getPixelSize().width / cellPerRow 
    for _, schoolId in ipairs(allSchoolIds) do
        local schoolinfo = schoolTable:getRecorder(schoolId)
        local index = schoolId - 10
        if schoolinfo and index > 0 then
            self.zhiyeCell[index] = bingfengwangzuozhiyecell.CreateNewDlg( self.schoolList )
            self.zhiyeCell[index].schoolName:setText(schoolinfo.name)
            self.zhiyeCell[index].btn:setID(index)
            self.zhiyeCell[index].icon:setProperty("Image", schoolinfo.schooliconpath)
            local rowIndex = math.floor((index - 1) / cellPerRow)
            local colIndex = (index - 1) % cellPerRow
            local cellHeight = self.zhiyeCell[index].m_pMainFrame:getPixelSize().height + 4
            local xPos = colIndex * cellWidth
            local yPos =  cellHeight * rowIndex
            self.zhiyeCell[index].m_pMainFrame:setPosition(CEGUI.UVector2(CEGUI.UDim(0.0, xPos), CEGUI.UDim(0.0, yPos)))
            self.zhiyeCell[index].btn:subscribeEvent("Clicked", bingfengwangzuoDlg.HandleBtnSchoolSelectClick, self)
        end
    end
end
-- 发送进入副本协议
function bingfengwangzuoDlg:sendEnterFuben( id )
 	local p = require "protodef.fire.pb.instancezone.bingfeng.centerbingfengland".new()
	p.landid = id
	require "manager.luaprotocolmanager":send(p)
end
-- 发送获取冰封王座界面信息协议
function bingfengwangzuoDlg:sendFubenInfo( id )
 	local p = require "protodef.fire.pb.instancezone.bingfeng.creqbingfengrank".new()
	p.landid = id
	require "manager.luaprotocolmanager":send(p)
end

-- 排行榜点击
function bingfengwangzuoDlg:HandleBtnRankClick( args )
    local aniMan = CEGUI.AnimationManager:getSingleton()
    local animationOpen = aniMan:getAnimation("FrameWindow3ani") 
    self.animationInstance = aniMan:instantiateAnimation(animationOpen) 
    self.animationInstance:setTargetWindow(self.cc_mjphmb)
    self.animationInstance:start()
	if self.cc_mjph:isVisible() then
		self.cc_mjph:setVisible(false)
	else
		self.cc_mjph:setVisible(true)
	end
end


function bingfengwangzuoDlg:HandleBtnRankCClick( args )
	if self.cc_mjph:isVisible() then
		self.cc_mjph:setVisible(false)
	else
		self.cc_mjph:setVisible(true)
	end
end

function bingfengwangzuoDlg:HandleBtnjlylClick( args )
    local aniMan = CEGUI.AnimationManager:getSingleton()
    local animationOpen = aniMan:getAnimation("huadongc1") 
    self.animationInstance = aniMan:instantiateAnimation(animationOpen) 
    self.animationInstance:setTargetWindow(self.cc_mjjljm)
    self.animationInstance:start()
	if self.cc_mjjlsm:isVisible() then
		self.cc_mjjlsm:setVisible(false)
	else
		self.cc_mjjlsm:setVisible(true)
	end
end

function bingfengwangzuoDlg:HandleBtnRankCCClick( args )
	if self.cc_mjjlsm:isVisible() then
		self.cc_mjjlsm:setVisible(false)
	else
		self.cc_mjjlsm:setVisible(true)
	end
end

function bingfengwangzuoDlg:handleAssistClicked(arg)
    require "logic.team.huobanzhuzhandialog"
    HuoBanZhuZhanDialog.getInstanceAndShow()
end

-- 等级选择
function bingfengwangzuoDlg:HandleBtnLevelClick( args )
	local aniMan = CEGUI.AnimationManager:getSingleton()
    local animationOpen = aniMan:getAnimation("huadongc1") 
    self.animationInstance = aniMan:instantiateAnimation(animationOpen) 
    self.animationInstance:setTargetWindow(self.heikuang)
    self.animationInstance:start()
	if self.heikuang:isVisible() then
		--self.heikuang:setVisible(false)
	else
		self.heikuang:setVisible(true)
	end
end
-- 选择副本等级
function bingfengwangzuoDlg:HandleBtnLevelSelectClick( args )
	local e = CEGUI.toWindowEventArgs(args)
	local id = e.window:getID()
	self.heikuang:setVisible(false)
	if id == self.curPage then
		return true
	end
	self:sendFubenInfo(id)
end
-- 排行榜选择职业按钮
function bingfengwangzuoDlg:HandleBtnSchoolSelectClick( args )
	local e = CEGUI.toWindowEventArgs(args)
	local id = e.window:getID()
	if self.selectButtonId > 0 and self.zhiyeCell[self.selectButtonId] and self.zhiyeCell[self.selectButtonId].btn then
		self.zhiyeCell[self.selectButtonId].btn:SetPushState(false)
	end
	if not self.zhiyeCell[id] or not self.zhiyeCell[id].btn then
		return true
	end
	self.zhiyeCell[id].btn:SetPushState(true)
	self.selectButtonId = id
	self:refreshRankData(id + 10)
end
-- 清除地图cell
function bingfengwangzuoDlg:clearCell( )
	if self.cell then	
		for index in pairs( self.cell ) do
			local cell = self.cell[index]
			if cell then
				cell:OnClose(false, false)
				cell = nil
			end
		end
	end
end
-- 刷新剩余次数
function bingfengwangzuoDlg.refreshLeaveTime( time )
	local leaveTime = time
	if time < 0 then
		leaveTime = 0
	end
	if _instance then
		_instance.leaveTime:setText(leaveTime)
	end
end

-- 初始化个人职业排行榜数据
function bingfengwangzuoDlg:initMyRankInfo( )
	local Mydata = gGetDataManager():GetMainCharacterData()
	local schoolIndex = Mydata.school - 10
	if self.zhiyeCell and self.zhiyeCell[schoolIndex] and self.zhiyeCell[schoolIndex].btn then
		self.zhiyeCell[schoolIndex].btn:SetPushState(true)
		self.selectButtonId = schoolIndex
	end
	self:refreshRankData(Mydata.school)
end
-- 刷新排行列表数据
function bingfengwangzuoDlg:refreshRankData( schoolId )
	self:clearRankInfoCell()
	self.rankInfoCell = {}
	local schoolinfo = BeanConfigManager.getInstance():GetTableByName("role.schoolinfo"):getRecorder(schoolId)
	if schoolinfo then
		local strbuilder = StringBuilder:new()
		strbuilder:Set("parameter1", schoolinfo.name)
    	local msg=strbuilder:GetString(MHSD_UTILS.get_resstring(11360))
    	strbuilder:delete()
    	self.textSchool:setText(msg)
	else
		self.textSchool:setText("")
	end
	local index = 0
	local rankInfo = require "logic.bingfengwangzuo.bingfengwangzuomanager":getRankDataBySchool(schoolId)
	if rankInfo == nil then
		return
	end
	for k,v in pairs(rankInfo) do
		self.rankInfoCell[k] = bingfengwangzuoRankCell.CreateNewDlg( self.rankList )
		self.rankInfoCell[k]:reloadData(v)
		local cellHeight = self.rankInfoCell[k].m_pMainFrame:getPixelSize().height
		local yPos = cellHeight*index
		local xPos = 1
		index = index  + 1
		self.rankInfoCell[k].m_pMainFrame:setPosition(CEGUI.UVector2(CEGUI.UDim(0.0, xPos), CEGUI.UDim(0.0, yPos)))
	end
end
-- 清除排行榜信息
function bingfengwangzuoDlg:clearRankInfoCell( )
	if self.rankInfoCell then
		for k,v in pairs(self.rankInfoCell) do
			local cell = v
			if cell then
				cell:OnClose()
				cell = nil
			end
		end
	end
end

function bingfengwangzuoDlg:getCurStagePosX()
    local info = BeanConfigManager.getInstance():GetTableByName("instance.cenchoulunewconfig"):getRecorder(self.page*100 + self.stage)
    return info.posX
end

function bingfengwangzuoDlg:checkAllListBg( )
--	if self.rankBg:isVisible() then
--		self.rankBg:setVisible(false)
--	end
--	if self.schoolBg:isVisible() then
--		self.schoolBg:setVisible(false)
--	end
	if self.heikuang:isVisible() then
		self.heikuang:setVisible(false)
	end
end

function bingfengwangzuoDlg:getRankButton( )
	return self.btnRank
end

--function bingfengwangzuoDlg:getRankBtnBg(  )
--	return self.rankBg
--end

--function bingfengwangzuoDlg:getSchoolBg( )
--	return self.schoolBg
--end

function bingfengwangzuoDlg:getLevelBtnBg( )
	return self.heikuang
end


function bingfengwangzuoDlg:getLevelButton( )
	return self.btnLevel
end

function bingfengwangzuoDlg:btnCloseCallBack(args)
    bingfengwangzuoDlg.DestroyDialog()
end

return bingfengwangzuoDlg
