require "logic.bingfengwangzuo.bingfengwangzuoTips"
bingfengwangzuocell = {}

setmetatable(bingfengwangzuocell, Dialog)
bingfengwangzuocell.__index = bingfengwangzuocell
local prefix = 0
local height = 93
local width = 185
function bingfengwangzuocell.CreateNewDlg(parent)
	local newDlg = bingfengwangzuocell:new()
	newDlg:OnCreate(parent)
	return newDlg
end

function bingfengwangzuocell.GetLayoutFileName()
	return "bingfengwangzuocell_mtg.layout"
end

function bingfengwangzuocell:new()
	local self = {}
	self = Dialog:new()
	setmetatable(self, bingfengwangzuocell)
	return self
end

function bingfengwangzuocell:OnCreate(parent)
	prefix = prefix + 1
	Dialog.OnCreate(self, parent, prefix)
	local winMgr = CEGUI.WindowManager:getSingleton()
	local prefixstr = tostring(prefix)
	

	self.btnCell = {}
	self.cellName = {}
	self.di = {}
	self.cclihui = {}
	self.ccmake = {}
	self.ccguanshu = {}
	self.ccktz = {}
	self.ccyzs = {}
	self.cctjzr = {}
	self.cc_cyz = {}
	self.cc_cyc = {}
	self.cc_clihui = {}
	self.cc_cname = {}
	self.ccbgc = {}
	self.touxiang = {}
	self.touxiangText = {}
	self.pageCellNum = 5
	for i=1,5 do
		self.btnCell[i] = CEGUI.toItemCell(winMgr:getWindow(prefixstr .. "bingfengwangzuocell_mtg/btn"..i))
		if self.btnCell[i] then
			self.btnCell[i]:setVisible(false)
		end
		self.cellName[i] = winMgr:getWindow(prefixstr .. "bingfengwangzuocell_mtg/text"..i)
		self.cclihui[i] = winMgr:getWindow(prefixstr .. "bingfengwangzuocell_mtg/btn1/cclihui"..i)
		self.ccmake[i] = winMgr:getWindow(prefixstr .. "bingfengwangzuocell_mtg/btn1/cymk"..i)
		self.ccguanshu[i] = winMgr:getWindow(prefixstr .. "bingfengwangzuocell_mtg/guanka"..i)
		self.ccktz[i] = winMgr:getWindow(prefixstr .. "bingfengwangzuocell_mtg/btn1/ccktz"..i)
		self.ccyzs[i] = winMgr:getWindow(prefixstr .. "bingfengwangzuocell_mtg/btn1/ccyzs"..i)
		self.ccbgc[i] = winMgr:getWindow(prefixstr .. "bingfengwangzuocell_mtg/btn1/ccbgc"..i)
		
		
		self.cc_cyz[i] = winMgr:getWindow(prefixstr .. "bingfengwangzuocell_mtg/btn1/cyz"..i)
		self.cc_cyc[i] = winMgr:getWindow(prefixstr .. "bingfengwangzuocell_mtg/btn1/cyc"..i)
		self.cc_clihui[i] = winMgr:getWindow(prefixstr .. "bingfengwangzuocell_mtg/btn1/cclihuic"..i)
		self.cc_cname[i] = winMgr:getWindow(prefixstr .. "bingfengwangzuocell_mtg/textc"..i)
		
		self.cctjzr[i] = CEGUI.toRichEditbox(winMgr:getWindow(prefixstr .. "bingfengwangzuocell_mtg/btn1/tuijian"..i))  
		self.di[i] = winMgr:getWindow(prefixstr .. "bingfengwangzuocell_mtg/di"..i)
		self.di[i]:setVisible(false)
		self.touxiang[i] = winMgr:getWindow(prefixstr .. "bingfengwangzuocell_mtg/touxiang"..i)
		self.touxiang[i]:setVisible(false)
		self.touxiangText[i] = winMgr:getWindow(prefixstr .. "bingfengwangzuocell_mtg/touxiang"..tostring(i).."/text"..tostring(i))
	end
	self.imageBoss = winMgr:getWindow(prefixstr .. "bingfengwangzuocell_mtg/boss")
	self.imageBoss:setVisible(false)
	self.bg = winMgr:getWindow(prefixstr .. "bingfengwangzuocell_mtg")
end

function bingfengwangzuocell:setParent( parent )
	self.m_Parent = parent:GetWindow()
end

function bingfengwangzuocell:setCellVisible( page, index, enemyNum, stage ,yesterdaystage)
    local num = index - 1
    self.page = page
    self.stage = stage
    self.yesterdaystage = yesterdaystage
    local level = 1
    for i=num*5+1, num*5+5 do
        if i > enemyNum then
            break
        end
        if self.btnCell[level] then
            local info = BeanConfigManager.getInstance():GetTableByName("instance.cenchoulunewconfig"):getRecorder(page*100 + i - 1)
            local npcConfig = BeanConfigManager.getInstance():GetTableByName("npc.cnpcconfig"):getRecorder(info.FocusNpc)
            if npcConfig then
                local shapeID = npcConfig.modelID
                local shapeTable = BeanConfigManager.getInstance():GetTableByName("npc.cnpcshape"):getRecorder(shapeID)
         --       local iconPath = gGetIconManager():GetImagePathByID(shapeTable.headID)
                local imageId
                if i > stage then
					imageId = shapeTable.mapheadcID
                    self.ccyzs[level]:setVisible(false)
                else
                    imageId = shapeTable.mapheadcID
                    self.ccyzs[level]:setVisible(true)
                end
				
				if i > stage + 1  then  -- 只有大于 stage + 1 的关卡才显示 self.ccmake
                self.ccmake[level]:setVisible(true) 
                else
                self.ccmake[level]:setVisible(false)
                end
				
				if i == stage + 1  then  -- 当前关卡显示ccktz
                self.ccktz[level]:setVisible(true)
				self.cc_cyz[level]:setVisible(true)
				self.cc_cyc[level]:setVisible(false)
				self.cctjzr[level]:setVisible(true)
                else
                self.ccktz[level]:setVisible(false)
				self.cc_cyz[level]:setVisible(false)
				self.cctjzr[level]:setVisible(false)
				self.cc_cyc[level]:setVisible(true)
                end
	
	
                local image = gGetIconManager():GetImageByID(imageId)
                self.cellName[level]:setVisible(true)
                self.di[level]:setVisible(true)
                self.touxiang[level]:setVisible(true)
                self.cclihui[level]:setVisible(true)
				self.cc_cname[level]:setVisible(true)
				self.cc_clihui[level]:setVisible(true)
				self.ccguanshu[level]:setVisible(true)
				self.ccbgc[level]:setVisible(true)
                self.touxiangText[level]:setText(info.state + 1)
                gGetGameUIManager():RemoveUIEffect(self.btnCell[level])
                if stage + 1 == i then -- 当前关卡设置特效
                    self:addEffectToCell(self.ccktz[level])
					--self:addEffectToCell2(self.cc_cname[level])
                end
                self.cellName[level]:setText(info.describe)
				self.ccguanshu[level]:setText(info.ccguanka)
				self.cc_cname[level]:setText(info.describe)
                self.cclihui[level]:setProperty("Image", info.ccicon)
				self.cc_clihui[level]:setProperty("Image", info.ccicon)
				if self.cctjzr[level] then
                self.cctjzr[level]:Clear()  -- 清空之前的内容
                self.cctjzr[level]:AppendParseText(CEGUI.String(info.ccintroduce)) -- 设置文本内容
                self.cctjzr[level]:Refresh() -- 刷新显示
                end
                self.btnCell[level]:setPosition(CEGUI.UVector2(CEGUI.UDim(0, info.posX), CEGUI.UDim(0, info.posY)))
                local pos = self.btnCell[level]:getPosition()
                local y = CEGUI.UDim(0, height)
                local x = CEGUI.UDim(0, width)
                local posOff = CEGUI.UVector2(pos.x - x, y + pos.y)
                self.di[level]:setPosition(posOff)
                self.touxiang[level]:setPosition(CEGUI.UVector2(pos.x - CEGUI.UDim(0, width), CEGUI.UDim(0, height - 1) + pos.y))
                self.btnCell[level]:subscribeEvent("MouseClick", bingfengwangzuocell.HandleShowEnemyInfo, self)
                self.btnCell[level]:setID(page*100 + i - 1)
                self.btnCell[level]:setID2(i-1)
                self.btnCell[level]:SetImage(image)
                self.btnCell[level]:setVisible(true)
                if info.boss == 1 then
                    self.btnCell[level]:SetBackGroundImage("ccfuben", "tm")
                    self.imageBoss:setVisible(true)
                    local bossPos = CEGUI.UVector2(pos.x - CEGUI.UDim(0, width - 185), CEGUI.UDim(0, height + 10) + pos.y)
                    self.imageBoss:setPosition(bossPos)
                end
            end
        end
        level = level + 1
    end
end

function bingfengwangzuocell:addEffectToCell( cell )
	if cell then
        local strEffectPath = require ("utils.mhsdutils").get_effectpath(11104)
        local bCycle = true
        local nPosX = 0
        local nPosY = 0
        local bClicp = true
        local bBounds = true
		gGetGameUIManager():AddParticalEffect(cell,strEffectPath,bCycle,nPosX,nPosY,bClicp,bBounds)
	end
end

--[[function bingfengwangzuocell:addEffectToCell2( cell ) -- 新建一个函数用于添加 11147 特效
    if cell then
        local strEffectPath = require ("utils.mhsdutils").get_effectpath(11106) -- 新的特效编号
        local bCycle = true
        local nPosX = 0
        local nPosY = 0
        local bClicp = false
        local bBounds = false
        gGetGameUIManager():AddParticalEffect(cell,strEffectPath,bCycle,nPosX,nPosY,bClicp,bBounds)
    end
end]]




function bingfengwangzuocell:HandleShowEnemyInfo( args )
	local e = CEGUI.toWindowEventArgs(args)
	local id = e.window:getID()
	local id2 = e.window:getID2()
	local stage = id2
	if id2 > self.stage and self.yesterdaystage < id2 then
		-- 添加未开启提示
	else
		if self.m_Parent then
			local dlg = bingfengwangzuoTips.getInstanceAndShow(self.m_Parent)
			dlg:initData(id)
			dlg:initPageInfo(self.page, stage)
			self:sendGuanQiaInfo(id2)
		end
	end
end

function bingfengwangzuocell:sendGuanQiaInfo( stage )
  	local p = require "protodef.fire.pb.instancezone.bingfeng.cgetbingfengdetail".new()
	p.landid = self.page
	p.stage = stage
	require "manager.luaprotocolmanager":send(p)
end

return bingfengwangzuocell
