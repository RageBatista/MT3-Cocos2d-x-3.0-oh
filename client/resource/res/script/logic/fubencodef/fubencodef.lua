require "logic.dialog"
require "logic.fubencodef.fubencodefcell"

fubencodef = {}
setmetatable(fubencodef, Dialog)
fubencodef.__index = fubencodef

local _instance;
function fubencodef.getInstance()
	if not _instance then
		_instance = fubencodef:new()
		_instance:OnCreate()
	end
	return _instance
end

function fubencodef.getInstanceAndShow()
	if not _instance then
		_instance = fubencodef:new()
		_instance:OnCreate()
	else
		_instance:SetVisible(true)
	end
	return _instance
end

function fubencodef.getInstanceNotCreate()
	return _instance
end

function fubencodef.DestroyDialog()
    if _instance then 
        if _instance.animationInstance then 
            _instance.animationInstance:stop() 
            _instance.animationInstance = nil 
        end
		if _instance.txAnimationInstance then  
            _instance.txAnimationInstance:stop()
            _instance.txAnimationInstance = nil 
        end
        if not _instance.m_bCloseIsHide then
            for index in pairs( _instance.cell ) do
                local cell = _instance.cell[index]
                if cell then
                    cell:OnClose(false, false)
                    cell = nil
                end
            end
            Dialog.OnClose(_instance)
            _instance = nil
        else
            _instance:ToggleOpenClose()
        end
    end
end

function fubencodef.ToggleOpenClose()
	if not _instance then

		_instance = fubencodef:new()
		_instance:OnCreate()
	else
		if _instance:IsVisible() then
			_instance:SetVisible(false)
		else
			_instance:SetVisible(true)
		end
	end
end

function fubencodef.GetLayoutFileName()
	return "moshouchuanqi_mtg.layout"
end

function fubencodef:new()
	local self = {}
	self = Dialog:new()
	setmetatable(self, fubencodef)
	return self
end

function fubencodef:OnCreate()
	Dialog.OnCreate(self)
	local winMgr = CEGUI.WindowManager:getSingleton()

	self.m_pane = CEGUI.toScrollablePane(winMgr:getWindow("moshouchuanqi_mtg/bg/list"))
    self.cc_fuben = winMgr:getWindow("moshouchuanqi_mtg/bgcc")
    local aniMan = CEGUI.AnimationManager:getSingleton()
    local animationOpen = aniMan:getAnimation("cc_bgani_1") 
    self.animationInstance = aniMan:instantiateAnimation(animationOpen) 
    self.animationInstance:setTargetWindow(self.cc_fuben)
    self.animationInstance:start()
	
	self.back = CEGUI.toPushButton(winMgr:getWindow("moshouchuanqi_mtg/zuofanye"))
	self.forward = CEGUI.toPushButton(winMgr:getWindow("moshouchuanqi_mtg/youfanye"))
    
    self.m_pane:subscribeEvent("ScrollPageChanged", fubencodef.HandleScrollChange,self)
	self.back:subscribeEvent("Clicked", fubencodef.HandleBackClicked,self)
	self.forward:subscribeEvent("Clicked", fubencodef.HandleForwardClicked,self)

	self.index = 0
	self.m_pane:EnableHorzScrollBar(true)
	self.m_pane:EnablePageScrollMode(true)
	self:initPageInfo()
	
	self.cc_shijian = CEGUI.toRichEditbox(winMgr:getWindow("moshouchuanqi_mtg/bgcc/ccshijianc1"))
	self.cc_shijian:Clear()
    self.cc_shijian:AppendParseText(CEGUI.String(MHSD_UTILS.get_resstring(7565)))
    self.cc_shijian:Refresh()
	
	self.cc_jiangli = CEGUI.toPushButton(winMgr:getWindow("moshouchuanqi_mtg/bgcc/jiangliyulanc1"))--奖励预览
    self.cc_jiangli:subscribeEvent("Clicked", fubencodef.ccjiangliyulan, self)
	
	self.cc_jiangli_x = CEGUI.toPushButton(winMgr:getWindow("moshouchuanqi_mtg/bgcc1"))--点击隐藏自己
	self.cc_jiangli_x:subscribeEvent("Clicked", fubencodef.ccjiangliyulanx, self)
	self.cc_jiangli_x:setVisible(false)

	self.cc_fubenbg = winMgr:getWindow("moshouchuanqi_mtg/bgcc1/cczy")--奖励CK
    self.cc_jlhdck = CEGUI.toScrollablePane(winMgr:getWindow("moshouchuanqi_mtg/bgcc1/jlhd"))
    self.cc_jlitemcells = {}
	self.cc_jlicons = {} -- 存储 cc_jlicon 控件
    self.cc_jlnames = {} -- 存储 cc_jlname 控件
    -- 创建一个二维数组来存储 ItemCell，第一维表示 cell 序号，第二维表示 award 序号
    for cellIndex = 1, 5 do
        self.cc_jlitemcells[cellIndex] = {} -- 为每个 cell 初始化一个空数组
        for awardIndex = 1, 5 do
        local itemCell = CEGUI.toItemCell(winMgr:getWindow("moshouchuanqi_mtg/bgcc1/jlhd/itemc" .. ((cellIndex - 1) * 5 + awardIndex))) -- 计算 ItemCell 的序号
		table.insert(self.cc_jlitemcells[cellIndex], itemCell) 
        end

    end
	
	for iconIndex = 1, 5 do
        self.cc_jlicons[iconIndex] = winMgr:getWindow("moshouchuanqi_mtg/bgcc1/jlhd/ccz1/tmkdz/cc" .. iconIndex) -- 修改读取路径
        self.cc_jlnames[iconIndex] = winMgr:getWindow("moshouchuanqi_mtg/bgcc1/jlhd/ccz1/namec" .. iconIndex) -- 修改读取路径
    end
	
	--特效位置
	self.cc_dhck = winMgr:getWindow("moshouchuanqi_mtg/ccdhck")
	local aniMan = CEGUI.AnimationManager:getSingleton()
    local animationOpen = aniMan:getAnimation("huadongc2") 
    self.txAnimationInstance = aniMan:instantiateAnimation(animationOpen) 
    self.txAnimationInstance:setTargetWindow(self.cc_dhck)
    self.txAnimationInstance:start()
	gGetGameUIManager():AddUIEffect(self.cc_dhck, "geffect/ui/ccnewani/cc_fubenzs", true) 
	
    self.cc_close = CEGUI.toPushButton(winMgr:getWindow("moshouchuanqi_mtg/ccx"))
    self.cc_close:subscribeEvent("Clicked", fubencodef.btnCloseCallBack, self)
end


function fubencodef:ccjiangliyulan(args)
    local aniMan = CEGUI.AnimationManager:getSingleton()
    local animationOpen = aniMan:getAnimation("cc_bgani_2") 
    self.animationInstance = aniMan:instantiateAnimation(animationOpen) 
    self.animationInstance:setTargetWindow(self.cc_fubenbg)
    self.animationInstance:start()
    
    if self.cc_jiangli_x:isVisible() then
        self.cc_jiangli_x:setVisible(false)
    else
        self.cc_jiangli_x:setVisible(true)
    end

    -- 读取配置表并设置 ItemCell
    local info = BeanConfigManager.getInstance():GetTableByName("mission.cshiguangzhixueconfig"):getRecorder(self.index + 1) -- 获取当前 cell 对应的配置信息
    
    if info then 
    for cellIndex = 1, 5 do -- 遍历 5 个 cell
        local info = BeanConfigManager.getInstance():GetTableByName("mission.cshiguangzhixueconfig"):getRecorder(cellIndex)

        if info then
            -- 设置 cc_jlicon 和 cc_jlname
            self.cc_jlicons[cellIndex]:setProperty("Image", info.ccimage) -- 设置奖励标识图片
            self.cc_jlnames[cellIndex]:setText(info.name) -- 设置副本名称

            for awardIndex = 1, 5 do
                local awardId = info["award" .. awardIndex] -- 获取 awardId
                local itemCell = self.cc_jlitemcells[cellIndex][awardIndex] -- 获取对应的 ItemCell

                if awardId and awardId > 0 then
                    local awardInfo = BeanConfigManager.getInstance():GetTableByName("item.citemattr"):getRecorder(awardId)
                    if awardInfo then
                        itemCell:setID(awardId)
                        itemCell:SetImage(gGetIconManager():GetItemIconByID(awardInfo.icon))
                        SetItemCellBoundColorByQulityItemWithId(itemCell, awardInfo.id)
                        itemCell:subscribeEvent("TableClick", GameItemTable.HandleShowToolTipsWithItemID)
                        itemCell:setVisible(true) -- 显示 ItemCell
                    end
                else
                    itemCell:setVisible(false) -- 隐藏没有奖励的 ItemCell
                end
            end
        end
    end
end
end

function fubencodef:ccjiangliyulanx( args )
	if self.cc_jiangli_x:isVisible() then
		self.cc_jiangli_x:setVisible(false)
	else
		self.cc_jiangli_x:setVisible(true)
	end
end

-- 初始化cell
function fubencodef:initPageInfo()
    local dataInfo = require "logic.fubencodef.fubencodefmanager":getDataInfo()
	self.cell = {}
    local vAllTableId = BeanConfigManager.getInstance():GetTableByName("mission.cshiguangzhixueconfig"):getAllID()
	local num = #vAllTableId
	self.maxIndex = num
	local index = 0
	local scrollPos = 0
	for i = 1, num do
		local info = BeanConfigManager.getInstance():GetTableByName("mission.cshiguangzhixueconfig"):getRecorder(i)
 		self.cell[i] = fubencodescell.CreateNewDlg( self.m_pane )
		self.cell[i]:loadServerData(dataInfo[info.fubenId])
		self.cell[i].btnFight:setID(info.fubenId)
		self.cell[i].btnFight:subscribeEvent("Clicked", fubencodef.HandleFightClicked,self)
		self.cell[i]:refreshData(info)
		self.m_pane:addChildWindow(self.cell[i].window)
		local cellWidth = self.cell[i].m_pMainFrame:getPixelSize().width
		local xGap = 280 
		
		local yPos = 1
		local xPos = xGap*index
		index = index  + 1
		self.cell[i].m_pMainFrame:setPosition(CEGUI.UVector2(CEGUI.UDim(0.0, xPos), CEGUI.UDim(0.0, yPos)))
		SetHorizontalScrollCellRight(self.m_pane,self.cell[i].m_pMainFrame)
		if dataInfo[info.fubenId].state == 2 and i+1 <= num then
			local nextInfo = BeanConfigManager.getInstance():GetTableByName("mission.cshiguangzhixueconfig"):getRecorder(i+1)
			if gGetDataManager():GetMainCharacterLevel() >= nextInfo.enterLevel then
				scrollPos = scrollPos + 1
			end
		end
	end
	self.index = self.index + scrollPos
	self.m_pane:setHorizontalScrollPosition(1/num*scrollPos)
	self.m_panePos = self.m_pane:getHorizontalScrollPosition()
end

function fubencodef:HandleScrollChange( args )

	if self.m_panePos then
		local  dPos=  self.m_pane:getHorizontalScrollPosition() 
		local  dW = 1.00/self.maxIndex 
		for i = 1 , self.maxIndex  do
            local pos = dW * (i - 1)		
			if pos -dW*0.3 < dPos and pos + dW*0.3 > dPos then
				self.index = i -1
				break
			end	
		end 
		if self.index < 0  then
			self.index = 0
		elseif  self.index  > self.maxIndex -1 then 
			self.index = self.maxIndex -1
		end
		self.m_panePos =  dPos
	end 
end

function fubencodef:HandleBackClicked( args )
	if self.index >	0 then
		self.m_pane:setHorizontalScrollPosition(self.m_pane:getHorizontalScrollPosition() - 1 / self.maxIndex)
		self.index = self.index - 1
	else
     	self.index = 0
	end
end

function fubencodef:HandleForwardClicked( args )
	if self.index >= 0 and self.index < self.maxIndex -1 then
		self.m_pane:setHorizontalScrollPosition(self.m_pane:getHorizontalScrollPosition() + 1 / self.maxIndex)		
		self.index = self.index + 1
	else
       	self.index = self.maxIndex-1
	end
end


function fubencodef:HandleFightClicked(args)
	local e = CEGUI.toWindowEventArgs(args)
	local id = e.window:getID()
	local targetCell = nil
    for i, cell in pairs(self.cell) do
        if cell.btnFight:getID() == id then
            targetCell = cell
            break
        end
    end
	
	if targetCell then
        targetCell:stopAnimation()
    end
	
	local p = require "protodef.fire.pb.mission.creqlinetask":new()
	p.taskid = id
	require "manager.luaprotocolmanager":send(p)
	fubencodef.DestroyDialog()
end

function fubencodef:btnCloseCallBack(args)
    fubencodef.DestroyDialog()
end

return fubencodef
