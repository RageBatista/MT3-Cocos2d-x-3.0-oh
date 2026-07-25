require "logic.dialog"
require "logic.zhenfa.zhenfabookchoosedlg"
require "logic.team.formationmanager"
require "logic.shop.shoplabel"
require "logic.shop.commercedlg"

--[[
local p0 = {x=58,y=0}
local p1 = {x=0,y=30}
local p2 = {x=125,y=30}
local p3 = {x=68,y=71}
--]]

local p0, p2 ,p3 ,p4
local tAngle0, tAngle1, bAngle0, bAngle1

local function pToAngle(y, x)
	return math.atan2(y, x) * 57.29577951
end

local function initAngles(gridSize)
    p0 = {x=gridSize.width*0.5, y=0}
    p1 = {x=0, y=gridSize.height*0.5}
    p2 = {x=gridSize.width, y=gridSize.height*0.5}
    p3 = {x=gridSize.width*0.5, y=gridSize.height}

    tAngle0 = pToAngle(p2.y-p0.y, p2.x-p0.x) --top
    tAngle1 = pToAngle(p1.y-p0.y, p1.x-p0.x)
    bAngle0 = pToAngle(p1.y-p3.y, p1.x-p3.x) --bottom
    bAngle1 = pToAngle(p2.y-p3.y, p2.x-p3.x)
end

--[[
local tAngle0 = pToAngle(p2.y-p0.y, p2.x-p0.x) --top
local tAngle1 = pToAngle(p1.y-p0.y, p1.x-p0.x)
local bAngle0 = pToAngle(p1.y-p3.y, p1.x-p3.x) --bottom
local bAngle1 = pToAngle(p2.y-p3.y, p2.x-p3.x)
--]]


local NO_ROLE	= 0 --没有人
local PLAYER	= 1 --玩家
local ASSIST	= 2 --助战

ZhenFaDlg = {}
setmetatable(ZhenFaDlg, Dialog)
ZhenFaDlg.__index = ZhenFaDlg

local _instance
function ZhenFaDlg.getInstance()
	if not _instance then
		_instance = ZhenFaDlg:new()
		_instance:OnCreate()
	end
	return _instance
end

--isTeamZhenFa: 区分从队伍打开还是从助战打开
function ZhenFaDlg.getInstanceAndShow(isTeamZhenFa)
	if not _instance then
		_instance = ZhenFaDlg:new()
		_instance:OnCreate(isTeamZhenFa)
	else
		_instance:SetVisible(true)
	end
	return _instance
end

function ZhenFaDlg.getInstanceNotCreate()
	return _instance
end

function ZhenFaDlg.DestroyDialog()
	if _instance then
		if not _instance.m_bCloseIsHide then
			NotificationCenter.removeObserver(Notifi_TeamListChange, ZhenFaDlg.onEventMemberChange)
			_instance:OnClose()
			_instance = nil
		else
			_instance:ToggleOpenClose()
		end
	end
end

function ZhenFaDlg.ToggleOpenClose()
	if not _instance then
		_instance = ZhenFaDlg:new()
		_instance:OnCreate()
	else
		if _instance:IsVisible() then
			_instance:SetVisible(false)
		else
			_instance:SetVisible(true)
		end
	end
end

function ZhenFaDlg.GetLayoutFileName()
	return "duiwuzhenfa.layout"
end

function ZhenFaDlg:new()
	local self = {}
	self = Dialog:new()
	setmetatable(self, ZhenFaDlg)
	self.firstMemberPos = 0
	return self
end

function ZhenFaDlg:OnCreate(isTeamZhenFa)
	Dialog.OnCreate(self)
    SetPositionScreenCenter(self:GetWindow())
	local winMgr = CEGUI.WindowManager:getSingleton()

    if isTeamZhenFa == nil then
        self.isTeamZhenFa = true
    else
        self.isTeamZhenFa = isTeamZhenFa
    end
    self.selectedZhenFa = 0
	self.frameWindow = CEGUI.toFrameWindow(winMgr:getWindow("duiwuzhenfa/framewindow"))
	self.listScroll = CEGUI.toScrollablePane(winMgr:getWindow("duiwuzhenfa/list"))
	--self.posBack = winMgr:getWindow("duiwuzhenfa/textbg")
    --self.switchStateText = winMgr:getWindow("duiwuzhenfa/textbg/kaiqitext")
	--self.chooseArrow = winMgr:getWindow("duiwuzhenfa/textbg/choosearrow")
	self.leftBtn = CEGUI.toPushButton(winMgr:getWindow("duiwuzhenfa/textbg2/zuoanniu"))
	self.desText = winMgr:getWindow("duiwuzhenfa/textbg2/dengjizhanshi/wenben")
	self.rightBtn = CEGUI.toPushButton(winMgr:getWindow("duiwuzhenfa/textbg2/youanniu"))
	self.curZhenfaName = winMgr:getWindow("duiwuzhenfa/zhenfashuxuexi/")
	self.curZhenfaDes = winMgr:getWindow("duiwuzhenfa/zhenfashuxuexi/curzhenfades")
	self.curZhenfaProgress = CEGUI.toProgressBar(winMgr:getWindow("duiwuzhenfa/zhenfashuxuexi/zhenfajindu"))
	self.learnBtn = CEGUI.toPushButton(winMgr:getWindow("duiwuzhenfa/zhenfashuxuexi/xuexianniu"))
	self.learnTipDot = winMgr:getWindow("duiwuzhenfa/zhenfashuxuexi/xuexianniu/tixinghongdian")

    self.openBtn = CEGUI.toPushButton(winMgr:getWindow("duiwuzhenfa/zhenfashuxuexi/switch"))
    self.openBtn:subscribeEvent("Clicked", ZhenFaDlg.handleOpenClicked, self)
	self.leftBtn:subscribeEvent("MouseButtonDown", ZhenFaDlg.handleLeftClicked, self)
	self.rightBtn:subscribeEvent("MouseButtonDown", ZhenFaDlg.handleRightClicked, self)
	self.learnBtn:subscribeEvent("Clicked", ZhenFaDlg.handleLearnClicked, self)
	self.frameWindow:getCloseButton():subscribeEvent("Clicked", ZhenFaDlg.DestroyDialog, nil)
	--self.chooseArrow:setVisible(false)
	self.learnTipDot:setVisible(false)
	--站位点
	self.allpos = {}
	for i=1, 9 do
		if i > 5 then i = i+5 end
		local pos = {}
		pos.back = winMgr:getWindow("duiwuzhenfa/textbg/pos"..i)
		pos.num = winMgr:getWindow("duiwuzhenfa/textbg/num"..i)
		pos.school = winMgr:getWindow("duiwuzhenfa/textbg/schoolicon"..i)
        pos.item = CEGUI.Window.toItemCell(winMgr:getWindow("duiwuzhenfa/textbg/pos4/"..i)) 
        pos.item:subscribeEvent("MouseClick", ZhenFaDlg.handleStandPosClicked, self)
		table.insert(self.allpos, pos)
		pos.id = i

        if not p0 then
            initAngles(pos.back:getPixelSize())
        end
	end
	
    local centerY = 0
	self.members = {}
	for i=1, 5 do
		local cell = {}
        cell.groupButton = CEGUI.toGroupButton(winMgr:getWindow("duiwuzhenfa/textbg2/box"..i))
		cell.itemcell = CEGUI.toItemCell(winMgr:getWindow("duiwuzhenfa/textbg2/box/tubiao" .. i))
		cell.text = winMgr:getWindow("duiwuzhenfa/textbg2/box/shuxing" .. i)
		cell.upArrow = winMgr:getWindow("duiwuzhenfa/textbg2/box/arrowup" .. i)
		cell.downArrow = winMgr:getWindow("duiwuzhenfa/textbg2/box/arrowdown" .. i)
        cell.name = winMgr:getWindow("duiwuzhenfa/textbg2/box/mingzi".. i)
        if centerY == 0 then
            centerY = cell.downArrow:getParent():getPixelSize().height*0.5
        end
        SetPositionYOffset(cell.downArrow, centerY+15, 0)
		cell.groupButton:subscribeEvent("SelectStateChanged", ZhenFaDlg.SelectedHandler, self)
		table.insert(self.members, cell)
	end
    local openedZhenfaId = 0
	if self.isTeamZhenFa then
        groupid = MT3HeroManager.getInstance():getActiveGroupId()
    else
        groupid = MT3HeroManager.getInstance():getSelectGroupId()
    end
    local openedZhenfaId = MT3HeroManager.getInstance():getGroupZhenfaId(groupid)
    gCommon.selectedZhenfaID = openedZhenfaId
	self:loadZhenfaList()
	self:focusOnZhenfaById(openedZhenfaId)
	
    NotificationCenter.addObserver(Notifi_TeamListChange, ZhenFaDlg.onEventMemberChange)
end

function ZhenFaDlg:SelectedHandler(args)
    local wndArgs = CEGUI.toWindowEventArgs(args)
	local strWndName = wndArgs.window:getName()
    local index = 0
	if strWndName == "duiwuzhenfa/textbg2/box1" then
		index = 1
	elseif strWndName == "duiwuzhenfa/textbg2/box2" then
		index = 2
	elseif strWndName == "duiwuzhenfa/textbg2/box3" then
		index = 3
	elseif strWndName == "duiwuzhenfa/textbg2/box4" then
		index = 4
	elseif strWndName == "duiwuzhenfa/textbg2/box5" then
		index = 5
	end
    local wnd = nil
    for _,v in pairs(self.allpos) do
        if v.back:getID() == index then
            wnd = v.back
        end
    end

    	if not wnd then return end
	print('selected stand pos', wnd:getID(), wnd:getID2())

	--该位置没有人
	if wnd:getID2()==0 then
		return
	end

	--队伍里的首位
	if wnd:getID() == 1 then
		self.firstMemberPos = 0
		--self.chooseArrow:setVisible(false)
		GetCTipsManager():AddMessageTipById(150176) --队长不能更换位置哦
		return
	end
	
	if self.firstMemberPos == 0 then
		self.firstMemberPos = wnd:getID()
		self.firstMemberRoleType = wnd:getID2()
		return
	end

	if self.firstMemberPos ~= wnd:getID() and self.firstMemberRoleType == wnd:getID2() then
		if self.firstMemberRoleType == PLAYER then --队伍交换位置
			if GetBattleManager():IsInBattle() then
				GetCTipsManager():AddMessageTipById(131451) --战斗中不能进行此操作。
			elseif GetTeamManager():IsMyselfLeader() then
				GetTeamManager():RequestSwapMember(self.firstMemberPos, wnd:getID())
			else
				GetCTipsManager():AddMessageTipById(145076) --只有队长才可以调整队伍光环
			end
		elseif self.firstMemberRoleType == ASSIST then --助战交换位置
			local idx1 = self.firstMemberPos - self.playerCount - 1
			local idx2 = wnd:getID() - self.playerCount - 1
			local activeGroupId = self:getZhuZhanGroupId()
			MT3HeroManager.getInstance():swapGroupMember(activeGroupId, idx1, idx2)
		end
	end
	self.firstMemberPos = 0
    return true
end

function ZhenFaDlg:getZhuZhanGroupId()
    if self.isTeamZhenFa then
        return MT3HeroManager.getInstance():getActiveGroupId()
    end
    return MT3HeroManager.getInstance():getSelectGroupId()
end

function ZhenFaDlg:createZhenfaCell(conf)
	local winMgr = CEGUI.WindowManager:getSingleton()
	local cell = {conf=conf}
	local prefix = tostring(conf.id)
	cell.window = CEGUI.toGroupButton(winMgr:loadWindowLayout("zhenfacell.layout", prefix))
	cell.itemcell = CEGUI.toItemCell(winMgr:getWindow(prefix .. "zhenfacell/item"))
	cell.name = winMgr:getWindow(prefix .. "zhenfacell/name")
	cell.des = winMgr:getWindow(prefix .. "zhenfacell/des")
	cell.tipsign = winMgr:getWindow(prefix .. "zhenfacell/tipsign")
	cell.tipsign:setVisible(false)

	cell.window:EnableClickAni(false)
	cell.window:setID(conf.id)
	cell.window:setGroupID(1)
	cell.itemcell:SetImage(gGetIconManager():GetImageByID(conf.icon))
	cell.name:setText(conf.name)

	local level = FormationManager.getInstance():getFormationLevel(conf.id)
	if level > 0 then
		cell.des:setText("[colour='ff36974a']" .. level .. MHSD_UTILS.get_resstring(3))
	else
		cell.des:setText("[colour='ffff0000']" .. MHSD_UTILS.get_resstring(11141)) --未习得
		cell.window:setProperty("StateImageExtendID", 1)
	end
	
	cell.formation = {}
	for i=1, 5 do
		cell.formation[i] = conf.formation[i-1]
	end

	return cell
end

function ZhenFaDlg:loadZhenfaList()
	self.listScroll:cleanupNonAutoChildren()
	self.lastSelectedBtn = nil
	
	local groupid = 0
    if self.isTeamZhenFa then
        groupid = MT3HeroManager.getInstance():getActiveGroupId()
    else
        groupid = MT3HeroManager.getInstance():getSelectGroupId()
    end
    local openedZhenfaId = MT3HeroManager.getInstance():getGroupZhenfaId(groupid)
	self.allZhenfaCells = {}

    local dataTable = BeanConfigManager.getInstance():GetTableByName("battle.cformationbaseconfig")
    local ids = dataTable:getAllID()
	
	--按是否已学习排序
    for i = 1, #ids-1 do
        for j = i+1, #ids do
			local leveli = FormationManager.getInstance():getFormationLevel(ids[i])
			local levelj = FormationManager.getInstance():getFormationLevel(ids[j])
			if leveli == 0 and levelj > 0 then
				ids[i], ids[j] = ids[j], ids[i]
			end
		end
	end
	
	local n = 0
    for _,id in pairs(ids) do
		local conf = dataTable:getRecorder(id)
		if conf.id > 0 then
			local cell = self:createZhenfaCell(conf)
			self.listScroll:addChildWindow(cell.window)
			cell.window:setPosition(CEGUI.UVector2(CEGUI.UDim(0,1), CEGUI.UDim(0,1+(cell.window:getPixelSize().height+3)*n)))
			cell.window:subscribeEvent("SelectStateChanged", ZhenFaDlg.handleZhenfaSelected, self)
			self.allZhenfaCells[conf.id] = cell
			
			local level = FormationManager.getInstance():getFormationLevel(conf.id)
			local needexp = FormationManager.getInstance():getUpgradeExp(conf.id, level)
	        local roleItemManager = require("logic.item.roleitemmanager").getInstance()
			if roleItemManager:GetItemByBaseID(conf.bookid) and not (level > 0 and needexp == 0) then
				cell.tipsign:setVisible(true)
			end
			
			if openedZhenfaId == conf.id then
				cell.itemcell:SetCornerImageAtPos("teamui", "yikaiqi", 0, 1)
			end
			--默认选中开启的光环，没有开启的就选择第一个
			if  (openedZhenfaId ~= 0 and gCommon.selectedZhenfaID == 0 and openedZhenfaId == conf.id) or
				(openedZhenfaId == 0 and gCommon.selectedZhenfaID == 0 and n==0) or
				gCommon.selectedZhenfaID == conf.id then
				cell.window:setSelected(true)
			end
			n = n+1
		end
	end
end

function ZhenFaDlg:handleOpenClicked(args)
    if FormationManager.getInstance():getFormationLevel(gCommon.selectedZhenfaID) == 0 then
		GetCTipsManager():AddMessageTipById(150178) --该光环还未习得
		return true
	end

   	local p = require("protodef.fire.pb.huoban.cswitchzhenfa").Create()
	p.zhenrongid = self:getZhuZhanGroupId()
	p.zhenfaid = gCommon.selectedZhenfaID
    self.selectedZhenFa = gCommon.selectedZhenfaID
	LuaProtocolManager:send(p) 
    return true
end
function ZhenFaDlg:setZhenFaId(id)
    self.m_ZhenFaId = id
end
function ZhenFaDlg:refreshSelectedZhenfa(cell)
	local conf = cell.conf
	local level = FormationManager.getInstance():getFormationLevel(conf.id)
	
	--判断光环是否已开启
	local groupid = 0
    if self.isTeamZhenFa then
        groupid = MT3HeroManager.getInstance():getActiveGroupId()
    else
        groupid = MT3HeroManager.getInstance():getSelectGroupId()
    end
    local openedZhenfaId = MT3HeroManager.getInstance():getGroupZhenfaId(groupid)
	if openedZhenfaId == cell.conf.id then
        self.openBtn:setEnabled(false)
	    self.selectedZhenFa = openedZhenfaId
        self.openBtn:setText(MHSD_UTILS.get_resstring(11598))
    else
        self.openBtn:setEnabled(true)
        self.openBtn:setText(MHSD_UTILS.get_resstring(11597)) 
	end
	self.lastSelectedBtn = cell.window
	gCommon.selectedZhenfaID = cell.conf.id
	self.learnBtn:setEnabled(true)
	local isLevelFull = false
	if level > 0 then
		self.curZhenfaName:setText(level .. MHSD_UTILS.get_resstring(3) .. conf.name)
		self.curZhenfaProgress:setVisible(true)
		local curexp = FormationManager.getInstance():getFormationExp(conf.id)
		local needexp = FormationManager.getInstance():getUpgradeExp(conf.id, level)
		if needexp == 0 then
			self.curZhenfaProgress:setText(MHSD_UTILS.get_resstring(2835)) --已满级
			self.curZhenfaProgress:setProgress(1)
			self.learnBtn:setEnabled(false)
			isLevelFull = true
		else
			self.curZhenfaProgress:setText(curexp .. "/" .. needexp)
			self.curZhenfaProgress:setProgress(curexp / needexp)
		end
		self.learnBtn:setText(MHSD_UTILS.get_resstring(11150)) --提升
	else
		self.curZhenfaName:setText(conf.name)
		self.curZhenfaProgress:setVisible(false)
		self.learnBtn:setText(MHSD_UTILS.get_resstring(11151)) --学习
	end
	
	--红点提示
	local roleItemManager = require("logic.item.roleitemmanager").getInstance()
	if roleItemManager:GetItemByBaseID(conf.bookid) and not isLevelFull then
		self.learnTipDot:setVisible(true)
	else
		self.learnTipDot:setVisible(false)
	end
	--根据站位点的id（1-14）获得在队伍里的序号（1-5）
	local function getOrder(id)
		for k,v in pairs(cell.formation) do
			if v == id then
				return k
			end
		end
		return 0
	end
	
	local shapeIDs = {}
	local schoolIDs = {}
	local roleTypes = {}
	local dyeIDs = {}
    local names = {}
	
	--如果有队伍取队伍列表，否则取助战阵容
	self.playerCount = 0
	if GetTeamManager():IsOnTeam() and self.isTeamZhenFa then
		local teamlist = GetTeamManager():GetMemberList() --MemberList
		for i=1, #teamlist do
			shapeIDs[i] = teamlist[i].shapeID
            names[i] = teamlist[i].name
			schoolIDs[i] = teamlist[i].eSchool
            dyeIDs[i] = {}            
            table.insert(dyeIDs[i], teamlist[i]:getComponent(eSprite_DyePartA))
            table.insert(dyeIDs[i], teamlist[i]:getComponent(eSprite_DyePartB))
			roleTypes[i] = PLAYER
		end
		self.playerCount = #teamlist
	else
		shapeIDs[1] = gGetDataManager():GetMainCharacterShape()
		schoolIDs[1] = gGetDataManager():GetMainCharacterSchoolID()
        names[1] = gGetDataManager():GetMainCharacterName()
        dyeIDs[1] = {}
        table.insert(dyeIDs[1], GetMainCharacter():GetSpriteComponent(eSprite_DyePartA))
        table.insert(dyeIDs[1], GetMainCharacter():GetSpriteComponent(eSprite_DyePartB))
		roleTypes[1] = PLAYER
		self.playerCount = 1
	end
	
	--在剩余的空位上显示助战
	if not GetTeamManager():IsOnTeam() or GetTeamManager():IsMyselfLeader() or not self.isTeamZhenFa then
		local heroBaseInfoTable = BeanConfigManager.getInstance():GetTableByName("npc.cherobaseinfo")
		local activeGroupId = self:getZhuZhanGroupId()
		local members = MT3HeroManager.getInstance():getGroupMember(activeGroupId)
		local n = math.min(members:size()-1, 5-self.playerCount-1)
		for i=0, n do
			local memberId = members[i]
			local record = heroBaseInfoTable:getRecorder(memberId)
			shapeIDs[self.playerCount+i+1] = record.shapeid
            names[self.playerCount+i+1] = record.name
			schoolIDs[self.playerCount+i+1] = record.type
            dyeIDs[self.playerCount+i+1] = {}
            table.insert(dyeIDs[self.playerCount+i+1], 0)
            table.insert(dyeIDs[self.playerCount+i+1], 0)
			roleTypes[self.playerCount+i+1] = ASSIST
		end
	end

	for _,v in pairs(self.allpos) do
        v.item:SetHaveSelectedState(false)
		local order = getOrder(v.id)
		if order > 0 then
			--v.back:setVisible(true)
            v.back:setProperty("Image", "set:ccui image:jinengkuang")
			v.back:setID(order) --在队伍里所在的序号
            v.item:setID(order)
			v.num:setText(order)
            v.num:setVisible(true)
			local shapeID = shapeIDs[order]
			local dyeInfo = dyeIDs[order]
            local name = names[order]
			if shapeID then
				v.back:setID2(roleTypes[order]) --标示是否有队员
				v.school:setVisible(true)
				--set head image
				local shapeConf = BeanConfigManager.getInstance():GetTableByName("npc.cnpcshape"):getRecorder(shapeID)
				local headIcon = gGetIconManager():GetImageByID(shapeConf.littleheadID)
				self.members[order].itemcell:SetImage(headIcon) 
                self.members[order].name:setText(name)
                v.item:setVisible(true)
                v.item:SetImage(headIcon)      
                if order ~= 1 then
                    v.item:SetHaveSelectedState(true)
                end     
				--school
				if roleTypes[order] == PLAYER then  --玩家显示职业
					local schoolconf = BeanConfigManager.getInstance():GetTableByName("role.schoolinfo"):getRecorder(schoolIDs[order])
					if schoolconf then
						local set, image = string.match(schoolconf.schooliconpath, "set:(.*)%s+image:(.*)")
						self.members[order].itemcell:SetCornerImageAtPos(set, image, 2, -10)
						v.school:setProperty("Image", schoolconf.schooliconpath)
                        v.item:SetStyle(CEGUI.ItemCellStyle_IconInside)
					end
				elseif roleTypes[order] == ASSIST then  --助战显示类型
					local imgpath = GetRoleTypeIconPath(schoolIDs[order])
					local set, image = string.match(imgpath, "set:(.*)%s+image:(.*)")
					self.members[order].itemcell:SetCornerImageAtPos(set, image, 2, 0.3, -3, -3)
					v.school:setProperty("Image", imgpath)
                    v.item:SetStyle(CEGUI.ItemCellStyle_IconExtend)
				end
			else
				v.back:setProperty("Image", "set:ccui image:jinengkuang")
			    v.back:setID(0)
			    v.back:setID2(0)
                v.school:setVisible(false)
                v.num:setVisible(false)
                v.item:setVisible(true)
                v.item:Clear()
			end
		else
            v.back:setProperty("Image", "set:ccui image:jinengkuang")
			v.back:setID(0)
			v.back:setID2(0)
            v.school:setVisible(false)
            v.num:setVisible(false)
            v.item:setVisible(false)
            v.item:Clear()
		end
	end
	for k,v in pairs(self.members) do
	    v.groupButton:setSelected(false)
	end

    for _,v in pairs(self.allpos) do
        v.item:SetSelected(false)
    end
	
	--更新描述
	self.curZhenfaLevel = FormationManager.getInstance():getFormationLevel(conf.id)
    self.curZhenfaLevel = math.max(self.curZhenfaLevel, 1)
	local zhenfaEffect = FormationManager.getInstance():getZhenfaEffectConf(conf.id, math.max(self.curZhenfaLevel,1))
	self:refreshZhenfaEffect(zhenfaEffect)
	
	self:refreshOppositeView()
end

--光环效果描述
function ZhenFaDlg:refreshZhenfaEffect(zhenfaEffect)
	if not zhenfaEffect then
		return
	end
	
    local centerY = 0
	for i=1, 5 do
		if zhenfaEffect.describe:size() < i then
			break
		end
		local member = self.members[i]
        if centerY == 0 then
            centerY = member.upArrow:getParent():getPixelSize().height*0.5
        end

		local str = zhenfaEffect.describe[i-1]
		local text1,text2 = string.match(str, '.*%"(.*)%".*%"(.*)%".*')
		if not text1 then
			text1 = string.match(str, '.*%"(.*)%".*')
		end
		
		if text1 then
			local p = string.find(text1, "+")
			if p then
				text1 = "[colour='ff6d4124']" .. string.sub(text1, 0, p-1) .. "[colour='ff36974a']" .. string.sub(text1, p)
			end
			
			if text2 then
				local p = string.find(text2, "-")
				if p then
					text2 = "[colour='ff6d4124']" .. string.sub(text2, 0, p-1) .. "[colour='ffff0000']" .. string.sub(text2, p)
				end
				
				member.text:setText(text1 .. '\n' .. text2)
				member.downArrow:setVisible(true)
				SetPositionYOffset(member.upArrow, centerY+10, 1)
			else
				member.text:setText(text1)
				member.downArrow:setVisible(false)
				SetPositionYOffset(member.upArrow, centerY+ 10, 0.5)
			end
		end
	end
	
	if zhenfaEffect.zhenfaLv == FormationManager.getInstance():getFormationLevel(zhenfaEffect.zhenfaid) then
		self.desText:setText(MHSD_UTILS.get_resstring(11144))
	else
		self.desText:setText(zhenfaEffect.zhenfaLv .. MHSD_UTILS.get_resstring(11145))
	end
end

function ZhenFaDlg:clipZhenfaIDs(str)
	local ret = {}
	local _,p,s = string.find(str, '(%d+)')
	table.insert(ret, tonumber(s))
	while p do
		_,p,s = string.find(str, '(%d+)', p+1)
		table.insert(ret, tonumber(s))
	end
	return ret
end

--相克描述
function ZhenFaDlg:refreshOppositeView()
	self.curZhenfaDes:cleanupNonAutoChildren()
	local selectBaseConf = BeanConfigManager.getInstance():GetTableByName("battle.cformationbaseconfig"):getRecorder(gCommon.selectedZhenfaID)
	local restrainConf = BeanConfigManager.getInstance():GetTableByName("battle.cformationrestrain"):getRecorder(gCommon.selectedZhenfaID)
	if not restrainConf then
		return
	end
	local winMgr = CEGUI.WindowManager:getSingleton()
	local top = 0
	local function deploy(parent, restrain, restrainArg, isRestrain, index)
		restrainArg = math.floor(tonumber(restrainArg)*100)
		
		local t = winMgr:createWindow("TaharezLook/StaticText")
		if isRestrain then
            if index == 1 then
                t:setText("[colour='FF005B0F']" .. MHSD_UTILS.get_resstring(11148))
            elseif index == 2 then
                t:setText("[colour='FF005B0F']" .. MHSD_UTILS.get_resstring(11601))
            end
		else
            if index == 3 then
                t:setText("[colour='FFE71F12']" .. MHSD_UTILS.get_resstring(11149))
            elseif index == 4 then
                t:setText("[colour='FFE71F12']" .. MHSD_UTILS.get_resstring(11602))
            end
		end
		t:setSize(CEGUI.UVector2(CEGUI.UDim(0,100), CEGUI.UDim(0,25)))
		t:setProperty("TextColours", "FFFFFFFF")
		t:setProperty("Font", "simhei-10")
		parent:addChildWindow(t)
		SetPositionOffset(t, 0, top)
		
		local ids = self:clipZhenfaIDs(restrain)
		for i=1,#ids do			
			local id = ids[i]
			local baseConf = BeanConfigManager.getInstance():GetTableByName("battle.cformationbaseconfig"):getRecorder(id)	
			t = winMgr:createWindow("TaharezLook/StaticText")
			t:setText("[colour='ff6d4124']" .. baseConf.name)
			t:setSize(CEGUI.UVector2(CEGUI.UDim(0,100), CEGUI.UDim(0,24)))
			t:setProperty("TextColours", "FFFFFFFF")
			t:setProperty("Font", "simhei-10")
			parent:addChildWindow(t)
			SetPositionOffset(t, i*80-20, top)
--            if i >= 5 then
--                top = top + 20
--                SetPositionOffset(t, (i-4)*80-20, top)
--            end
		end
		top = top + 23
	end
	deploy(self.curZhenfaDes, restrainConf.restrain1, restrainConf.restrainArg1, true, 1)				--克制3%
	deploy(self.curZhenfaDes,restrainConf.restrain2, restrainConf.restrainArg2, true, 2)					--克制6%
	deploy(self.curZhenfaDes,restrainConf.beRestrained1, restrainConf.beRestrainedArg1, false, 3)	--被克3%
	deploy(self.curZhenfaDes,restrainConf.beRestrained2, restrainConf.beRestrainedArg2, false, 4)	--被克6%
end

function ZhenFaDlg:refreshOpenedZhenfa(zhenfaid)
	for k,v in pairs(self.allZhenfaCells) do
		if k == zhenfaid then
			v.itemcell:SetCornerImageAtPos("teamui", "yikaiqi", 0, 1)
		else
			v.itemcell:SetCornerImageAtPos(nil, 0, 0)
		end
	end
    self.openBtn:setEnabled(false)
    self.openBtn:setText(MHSD_UTILS.get_resstring(11598))
end

function ZhenFaDlg:recvZhenfaChanged()
	local offset = self.listScroll:getVertScrollbar():getScrollPosition()
	self:loadZhenfaList()
	if IsVerticalScrollCellInViewArea(self.listScroll, self.lastSelectedBtn) then
		SetVeticalScrollCellTop(self.listScroll, self.lastSelectedBtn)
	else
		self.listScroll:getVertScrollbar():Stop()
		self.listScroll:getVertScrollbar():setScrollPosition(offset)
	end
end

function ZhenFaDlg:handleZhenfaSelected(args)
	local btn = CEGUI.toWindowEventArgs(args).window
	if self.lastSelectedBtn == btn then
		return
	end
	self.lastSelectedBtn = btn

	self.firstMemberPos = 0
	--self.chooseArrow:setVisible(false)
	
	local id = btn:getID()
	local cell = self.allZhenfaCells[id]
	self:refreshSelectedZhenfa(cell)
end

function ZhenFaDlg:handleStandPosClicked(args)
	--图片是菱形，非规则的方形按钮，根据四边斜率计算选中的站位
	local wnd = nil
--	local mp = CEGUI.MouseCursor:getSingleton():getPosition() --mouse pos
--	for _, v in pairs(self.allpos) do
--		local sp = v.back:GetScreenPos() --screen pos
--		local s = v.back:getPixelSize()
--		local x = mp.x-sp.x
--		local y = mp.y-sp.y
--		if x >= 0 and x <= s.width and y >= 0 and y <= s.height then
--			local angle1 = pToAngle(y-p0.y, x-p0.x)
--			local angle2 = pToAngle(y-p3.y, x-p3.x)
--			if angle1 >= tAngle0 and angle1 <= tAngle1 and angle2 >= bAngle0 and angle2 <= bAngle1 then
--				wnd = v.back
--				break
--			end
--		end
--	end

    local event = CEGUI.toWindowEventArgs(args)
	local itemID = event.window:getID()
    for _,v in pairs(self.allpos) do
        if v.back:getID() == itemID then
            wnd = v.back
        end
    end

	if not wnd then return end
	print('selected stand pos', wnd:getID(), wnd:getID2())

	--该位置没有人
	if wnd:getID2()==0 then
		return
	end

	--队伍里的首位
	if wnd:getID() == 1 then
		self.firstMemberPos = 0
        for _,v in pairs(self.allpos) do
            v.item:SetSelected(false)
        end
		GetCTipsManager():AddMessageTipById(150176) --队长不能更换位置哦
		return
	end
	
	if self.firstMemberPos == 0 then
		self.firstMemberPos = wnd:getID()
		self.firstMemberRoleType = wnd:getID2()
		return
	end

	if self.firstMemberPos ~= wnd:getID() and self.firstMemberRoleType == wnd:getID2() then
		if self.firstMemberRoleType == PLAYER then --队伍交换位置
			if GetBattleManager():IsInBattle() then
				GetCTipsManager():AddMessageTipById(131451) --战斗中不能进行此操作。
			elseif GetTeamManager():IsMyselfLeader() then
				GetTeamManager():RequestSwapMember(self.firstMemberPos, wnd:getID())
			else
				GetCTipsManager():AddMessageTipById(145076) --只有队长才可以调整队伍光环
			end
		elseif self.firstMemberRoleType == ASSIST then --助战交换位置
			local idx1 = self.firstMemberPos - self.playerCount - 1
			local idx2 = wnd:getID() - self.playerCount - 1
			local activeGroupId = self:getZhuZhanGroupId()
			MT3HeroManager.getInstance():swapGroupMember(activeGroupId, idx1, idx2)
		end
	end
	
	self.firstMemberPos = 0
	--self.chooseArrow:setVisible(false)
end

function ZhenFaDlg:handleLeftClicked(args)
	if self.curZhenfaLevel == 1 then
		return
	end
	local level = self.curZhenfaLevel - 1
	local zhenfaEffect = FormationManager.getInstance():getZhenfaEffectConf(gCommon.selectedZhenfaID, level)
	if zhenfaEffect then
		self.curZhenfaLevel = level
		self:refreshZhenfaEffect(zhenfaEffect)
	end
end

function ZhenFaDlg:handleRightClicked(args)
	local level = self.curZhenfaLevel + 1
	local zhenfaEffect = FormationManager.getInstance():getZhenfaEffectConf(gCommon.selectedZhenfaID, level)
	if zhenfaEffect then
		self.curZhenfaLevel = level
		self:refreshZhenfaEffect(zhenfaEffect)
	end
end

function ZhenFaDlg:handleLearnClicked(args)

	local baseconf = BeanConfigManager.getInstance():GetTableByName("battle.cformationbaseconfig"):getRecorder(gCommon.selectedZhenfaID)
	local data = FormationManager.getInstance():getFormationData(gCommon.selectedZhenfaID)

	local roleItemManager = require("logic.item.roleitemmanager").getInstance()
	if data.level > 0 then
		local items = {}
		items = roleItemManager:GetItemKeyListByType(items, ITEM_TYPE.FORMATION_CAN_JUAN)
		items = roleItemManager:GetItemKeyListByType(items, ITEM_TYPE.FORMATION_BOOK)
		if items:size() > 0 then
			local dlg = ZhenfaBookChooseDlg.getInstanceAndShow()
			dlg:setZhenfaData(baseconf, data.level, data.exp)
		else
			MessageBoxSimple.show(
				MHSD_UTILS.get_msgtipstring(160055),  --升级该光环需要消耗光环书或光环残卷。。。
				ZhenFaDlg.handleConfirmBuyBook, self, nil, nil,
				MHSD_UTILS.get_resstring(480)
			)
		end
	else
		if roleItemManager:GetItemByBaseID(baseconf.bookid) then --学习
			local p = require("protodef.fire.pb.team.cuseformbook").Create()
			p.formationid = gCommon.selectedZhenfaID
			local book = UseFormBook:new()
			book.bookid = baseconf.bookid
			book.num = 1
			table.insert(p.listbook, book)
			LuaProtocolManager:send(p)
			
		else
			MessageBoxSimple.show(
				MHSD_UTILS.get_msgtipstring(150177),  --学习该光环需要消耗一本同名光环书
				ZhenFaDlg.handleConfirmBuyBook, self, nil, nil,
				MHSD_UTILS.get_resstring(480)
			)
		end
	end
end

function ZhenFaDlg:handleConfirmBuyBook()
	--gGetMessageManager():CloseConfirmBox(eConfirmDropItem,false)
	ShopLabel.showCommerce()
	
	local baseconf = BeanConfigManager.getInstance():GetTableByName("battle.cformationbaseconfig"):getRecorder(gCommon.selectedZhenfaID)
	CommerceDlg.getInstance():selectGoodsByItemid(baseconf.bookid)
	
	ShopLabel.getInstance().callbackWhenHide = function()
		ZhenFaDlg.getInstanceAndShow()
		--红点提示
	    local roleItemManager = require("logic.item.roleitemmanager").getInstance()
		for _,cell in pairs(_instance.allZhenfaCells) do
			if roleItemManager:GetItemByBaseID(cell.conf.bookid) then
				cell.tipsign:setVisible(true)
				_instance.learnTipDot:setVisible(true)
			end	
		end
	end
end

function ZhenFaDlg.onEventMemberChange()
	if _instance then
		local cell = _instance.allZhenfaCells[gCommon.selectedZhenfaID]
		_instance:refreshSelectedZhenfa(cell)
	end
end

function ZhenFaDlg:focusOnZhenfaById(zhenfaId)
	local cell = self.allZhenfaCells[zhenfaId]
	if not cell then
		return
	end
	SetVeticalScrollCellTop(self.listScroll, cell.window)
	cell.window:setSelected(true)
end

function ZhenFaDlg.useZhenfaBookItemFromBag(itemid)
	ZhenFaDlg.getInstanceAndShow()

    local dataTable = BeanConfigManager.getInstance():GetTableByName("battle.cformationbaseconfig")
    local ids = dataTable:getAllID()
    for _,id in pairs(ids) do
        local conf = dataTable:getRecorder(id)
		if conf.bookid == itemid then
			_instance:focusOnZhenfaById(conf.id)
			break
		end
	end
end
return ZhenFaDlg
