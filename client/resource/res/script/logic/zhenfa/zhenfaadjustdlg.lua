require "logic.dialog"

local p0 = {x=58,y=0}
local p1 = {x=0,y=30}
local p2 = {x=125,y=30}
local p3 = {x=68,y=71}

local function pToAngle(y, x)
	return math.atan2(y, x) * 57.29577951
end

local tAngle0 = pToAngle(p2.y-p0.y, p2.x-p0.x) --top
local tAngle1 = pToAngle(p1.y-p0.y, p1.x-p0.x)
local bAngle0 = pToAngle(p1.y-p3.y, p1.x-p3.x) --bottom
local bAngle1 = pToAngle(p2.y-p3.y, p2.x-p3.x)


ZhenFaAdjustDlg = {}
setmetatable(ZhenFaAdjustDlg, Dialog)
ZhenFaAdjustDlg.__index = ZhenFaAdjustDlg

local _instance
function ZhenFaAdjustDlg.getInstance()
	if not _instance then
		_instance = ZhenFaAdjustDlg:new()
		_instance:OnCreate()
	end
	return _instance
end

function ZhenFaAdjustDlg.getInstanceAndShow()
	if not _instance then
		_instance = ZhenFaAdjustDlg:new()
		_instance:OnCreate()
	else
		_instance:SetVisible(true)
	end
	return _instance
end

function ZhenFaAdjustDlg.getInstanceNotCreate()
	return _instance
end

function ZhenFaAdjustDlg.DestroyDialog()
	if _instance then 
		NotificationCenter.removeObserver(Notifi_TeamListChange, ZhenFaAdjustDlg.onEventMemberChange)
		if not _instance.m_bCloseIsHide then
			_instance:OnClose()
			_instance = nil
		else
			_instance:ToggleOpenClose()
		end
	end
end

function ZhenFaAdjustDlg.ToggleOpenClose()
	if not _instance then
		_instance = ZhenFaAdjustDlg:new()
		_instance:OnCreate()
	else
		if _instance:IsVisible() then
			_instance:SetVisible(false)
		else
			_instance:SetVisible(true)
		end
	end
end

function ZhenFaAdjustDlg.GetLayoutFileName()
	return "huobanzhuzhanzhenfa.layout"
end

function ZhenFaAdjustDlg:new()
	local self = {}
	self = Dialog:new()
	setmetatable(self, ZhenFaAdjustDlg)
	self.firstMemberPos = 0
	return self
end

function ZhenFaAdjustDlg:OnCreate()
	Dialog.OnCreate(self)
	local winMgr = CEGUI.WindowManager:getSingleton()

	self.frameWindow = CEGUI.toFrameWindow(winMgr:getWindow("huobanzhuzhanzhenfa"))
	self.listScroll = CEGUI.toScrollablePane(winMgr:getWindow("huobanzhuzhanzhenfa/list"))
	self.chooseArrow = winMgr:getWindow("huobanzhuzhanzhenfa/textbg/choosearrow")
	self.posBack = winMgr:getWindow("huobanzhuzhanzhenfa/textbg")
	self.zhenRongNum = winMgr:getWindow("huobanzhuzhanzhenfa/textbg/textditu/zhenrong")
	self.saveBtn = CEGUI.toPushButton(winMgr:getWindow("huobanzhuzhanzhenfa/textbg/btnbaocun"))

	self.saveBtn:subscribeEvent("Clicked", ZhenFaAdjustDlg.handleSaveClicked, self)
	self.frameWindow:getCloseButton():subscribeEvent("Clicked", ZhenFaAdjustDlg.DestroyDialog, nil)
	
	self.chooseArrow:setVisible(false)

	self.allpos = {}
	for i=1, 9 do
		if i > 5 then i = i+5 end
		local pos = {}
		pos.back = winMgr:getWindow("huobanzhuzhanzhenfa/textbg/pos"..i)
		pos.num = winMgr:getWindow("huobanzhuzhanzhenfa/textbg/num"..i)
		pos.school = winMgr:getWindow("huobanzhuzhanzhenfa/textbg/schoolicon"..i)
		table.insert(self.allpos, pos)
		pos.id = i
	end
	self.posBack:subscribeEvent("MouseClick", ZhenFaAdjustDlg.handleStandPosClicked, self)
	
	self.alldes = {}
	for i=1, 5 do
		local des = winMgr:getWindow("huobanzhuzhanzhenfa/textbg2/desText"..i)
		table.insert(self.alldes, des)
	end

    NotificationCenter.addObserver(Notifi_TeamListChange, ZhenFaAdjustDlg.onEventMemberChange)

end

function ZhenFaAdjustDlg:setZhenrongGroupIdx(idx)
	self.groupIdx = idx
	local str = self.zhenRongNum:getText()
	str = string.gsub(str, "(.*)%d", "%1" .. idx+1)
	self.zhenRongNum:setText(str)
	
	self:loadZhenfaList()
	
end

function ZhenFaAdjustDlg:getPosAtIdx(idx)
	for _,v in pairs(self.allpos) do
		if v.back:getID() == idx then
			return v
		end
	end
	return nil
end

function ZhenFaAdjustDlg:createZhenfaCell(conf)
	local winMgr = CEGUI.WindowManager:getSingleton()
	local cell = {conf=conf}
	local prefix = tostring(conf.id)
	cell.window = CEGUI.toGroupButton(winMgr:loadWindowLayout("zhenfacell.layout", prefix))
	cell.itemcell = CEGUI.toItemCell(winMgr:getWindow(prefix .. "zhenfacell/item"))
	cell.name = winMgr:getWindow(prefix .. "zhenfacell/name")
	cell.des = winMgr:getWindow(prefix .. "zhenfacell/des")
	cell.tipsign = winMgr:getWindow(prefix .. "zhenfacell/tipsign")
	
	cell.des:setVisible(false)
	cell.tipsign:setVisible(false)
	SetPositionYOffset(cell.name, cell.window:getPixelSize().height*0.5, 0.5)

	cell.window:setID(conf.id)
	cell.itemcell:SetImage(gGetIconManager():GetImageByID(conf.icon))
	
	local level = FormationManager.getInstance():getFormationLevel(conf.id)
	cell.name:setText(level .. MHSD_UTILS.get_resstring(3) .. conf.name)
	
	cell.formation = {}
	for i=1, 5 do
		cell.formation[i] = conf.formation[i-1]
	end

	return cell
end

function ZhenFaAdjustDlg:loadZhenfaList()
	self.listScroll:cleanupNonAutoChildren()
	self.lastSelectedBtn = nil
	
    local openedZhenfaId = MT3HeroManager.getInstance():getOpenedFormationId()

	self.allZhenfaCells = {}
    
    local selectedCell = nil
	local n = 0

	local dataTable = BeanConfigManager.getInstance():GetTableByName("battle.cformationbaseconfig")
    local ids = dataTable:getAllID()
    for _,id in pairs(ids) do
        local conf = dataTable:getRecorder(id)
		if conf.id > 0 and FormationManager.getInstance():getFormationLevel(conf.id) > 0 then
			local cell = self:createZhenfaCell(conf)
			self.listScroll:addChildWindow(cell.window)
			cell.window:setPosition(CEGUI.UVector2(CEGUI.UDim(0,1), CEGUI.UDim(0,1+cell.window:getPixelSize().height*n)))
			cell.window:subscribeEvent("SelectStateChanged", ZhenFaAdjustDlg.handleZhenfaSelected, self)
			self.allZhenfaCells[conf.id] = cell
			
			if (openedZhenfaId == 0 and n==0) or openedZhenfaId == conf.id then
				cell.window:setSelected(true)
                selectedCell = cell
			end
			n = n+1
		end
	end

    if selectedCell then
        SetVeticalScrollCellTop(self.listScroll, selectedCell.window)
    end
end

function ZhenFaAdjustDlg:refreshSelectedZhenfa(cell)
	self.lastSelectedBtn = cell.window
	self.selectedZhenfaID = cell.conf.id
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
	local dyeIDs = {}
	shapeIDs[1] = gGetDataManager():GetMainCharacterShape()
	schoolIDs[1] = gGetDataManager():GetMainCharacterSchoolID()
    dyeIDs[1] = {}
    table.insert(dyeIDs[1], GetMainCharacter():GetSpriteComponent(eSprite_DyePartA))
    table.insert(dyeIDs[1], GetMainCharacter():GetSpriteComponent(eSprite_DyePartB))
	
	local heroBaseInfoTable = BeanConfigManager.getInstance():GetTableByName("npc.cherobaseinfo")
	local members = MT3HeroManager.getInstance():getGroupMember(self.groupIdx)
	for i=0, members:size()-1 do
		local memberId = members[i]
		local record = heroBaseInfoTable:getRecorder(memberId)
		table.insert(shapeIDs, record.shapeid)
		table.insert(schoolIDs, record.type)
        local rs = {}
        table.insert(rs, 0)
        table.insert(rs, 0)
        table.insert(dyeIDs, rs)
	end
	
	for _,v in pairs(self.allpos) do
		local order = getOrder(v.id)
		if order > 0 then
			v.back:setVisible(true)
			v.back:setID(order) 
			v.num:setText(order)
			local shapeID = shapeIDs[order]
			local dyeInfo = dyeIDs[order]
			if shapeID then
				v.back:setID2(1)
				v.school:setVisible(true)
				if not v.sprite then
					local s = v.back:getPixelSize()
					v.sprite = gGetGameUIManager():AddWindowSprite(v.back, shapeID, Nuclear.XPDIR_TOPLEFT, s.width*0.5, s.height*0.5+10, false)
					v.sprite:SetUIScale(0.6)
				elseif v.sprite:GetModelID() ~= shapeID then
					v.sprite:SetModel(shapeID)
					v.sprite:SetUIDirection(Nuclear.XPDIR_TOPLEFT)
				end
				v.sprite:SetDyePartIndex(0,dyeInfo[1])
				v.sprite:SetDyePartIndex(1,dyeInfo[2])
				
				if order == 1 then  
					local schoolconf = BeanConfigManager.getInstance():GetTableByName("role.schoolinfo"):getRecorder(schoolIDs[order])
					if schoolconf then
						local set, image = string.match(schoolconf.schooliconpath, "set:(.*)%s+image:(.*)")
						v.school:setProperty("Image", schoolconf.schooliconpath)
					end
				else  
					local imgpath = GetRoleTypeIconPath(schoolIDs[order])
					local set, image = string.match(imgpath, "set:(.*)%s+image:(.*)")
					v.school:setProperty("Image", imgpath)
				end
			else
				gGetGameUIManager():RemoveWindowSprite(v.sprite)
				v.sprite = nil
				v.back:setID2(0)
				v.school:setVisible(false)
			end
		else
			v.back:setVisible(false)
			v.back:setID(0)
			v.back:setID2(0)
			gGetGameUIManager():RemoveWindowSprite(v.sprite)
			v.sprite = nil
		end
	end
	
	local level = FormationManager.getInstance():getFormationLevel(cell.conf.id)
	local zhenfaEffect = FormationManager.getInstance():getZhenfaEffectConf(cell.conf.id, level)
	self:refreshZhenfaEffect(zhenfaEffect)
end

function ZhenFaAdjustDlg:refreshZhenfaEffect(zhenfaEffect)
	if not zhenfaEffect then
		return
	end
	
	for i=1, 5 do
		if zhenfaEffect.describe:size() < i then
			break
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
				
				self.alldes[i]:setText(text1 .. '\n' .. text2)
			else
				self.alldes[i]:setText(text1)
			end
		end
	end
end

function ZhenFaAdjustDlg:handleZhenfaSelected(args)
	local btn = CEGUI.toWindowEventArgs(args).window
	if self.lastSelectedBtn == btn then
		return
	end

	self.lastSelectedBtn = btn

	self.firstMemberPos = 0
	self.chooseArrow:setVisible(false)
	
	self.newGroup = nil
	
	local id = btn:getID()
	local cell = self.allZhenfaCells[id]
	self:refreshSelectedZhenfa(cell)
end

function ZhenFaAdjustDlg:handleStandPosClicked(args)
	local wnd = nil
	local mp = CEGUI.MouseCursor:getSingleton():getPosition()
	for _, v in pairs(self.allpos) do
		local sp = v.back:GetScreenPos()
		local s = v.back:getPixelSize()
		local x = mp.x-sp.x
		local y = mp.y-sp.y
		if x >= 0 and x <= s.width and y >= 0 and y <= s.height then
			local angle1 = pToAngle(y-p0.y, x-p0.x)
			local angle2 = pToAngle(y-p3.y, x-p3.x)
			if angle1 >= tAngle0 and angle1 <= tAngle1 and angle2 >= bAngle0 and angle2 <= bAngle1 then
				wnd = v.back
				break
			end
		end
	end
	
	if not wnd then return end
	print('selected stand pos', wnd:getID(), wnd:getID2())

	if wnd:getID2()==0 then
		return
	end

	if wnd:getID() == 1 then
		self.firstMemberPos = 0
		self.chooseArrow:setVisible(false)
		GetCTipsManager():AddMessageTipById(150176) 
		return
	end
	
	if self.firstMemberPos == 0 then
		self.firstMemberPos = wnd:getID()
		self.chooseArrow:setVisible(true)
		local p = wnd:getPosition()
		local s = wnd:getPixelSize()
		SetPositionOffset(self.chooseArrow, p.x.offset+s.width*0.5, p.y.offset-30, 0.5, 1)
		return
	end
	
	if self.firstMemberPos ~= wnd:getID() then 
		local idx1 = self.firstMemberPos-2 
		local idx2 = wnd:getID()-2
		local members = self.newGroup or MT3HeroManager.getInstance():getGroupMember(self.groupIdx)
		members[idx1], members[idx2] = members[idx2], members[idx1]
		self.newGroup = members
		local pos1 = self:getPosAtIdx(self.firstMemberPos)
		local pos2 = self:getPosAtIdx(wnd:getID())
		if pos1 and pos2 then
			local shapeID = pos1.sprite:GetModelID()
			pos1.sprite:SetModel( pos2.sprite:GetModelID() )
			pos1.sprite:SetUIDirection(Nuclear.XPDIR_TOPLEFT)

            local roletype = BeanConfigManager.getInstance():GetTableByName("npc.cherobaseinfo"):getRecorder(members[idx1]).type
            local imgpath = GetRoleTypeIconPath(roletype)
			local set, image = string.match(imgpath, "set:(.*)%s+image:(.*)")
			pos1.school:setProperty("Image", imgpath)
			
			pos2.sprite:SetModel(shapeID)
			pos2.sprite:SetUIDirection(Nuclear.XPDIR_TOPLEFT)

            roletype = BeanConfigManager.getInstance():GetTableByName("npc.cherobaseinfo"):getRecorder(members[idx2]).type
            imgpath = GetRoleTypeIconPath(roletype)
			set, image = string.match(imgpath, "set:(.*)%s+image:(.*)")
			pos2.school:setProperty("Image", imgpath)
		end
	end
	
	self.firstMemberPos = 0
	self.chooseArrow:setVisible(false)
end

function ZhenFaAdjustDlg:handleSaveClicked(args)
	if self.newGroup then 
		local members = std.vector_int_()
		for i=0,self.newGroup:size()-1 do
			members:push_back(self.newGroup[i])
		end
		gGetNetConnection():send(fire.pb.huoban.CZhenrongMember(self.groupIdx, members))
	end
	
	if self.selectedZhenfaID ~= MT3HeroManager.getInstance():getGroupZhenfaId(self.groupIdx) then
		local p = require("protodef.fire.pb.huoban.cswitchzhenfa").Create()
		p.zhenrongid = self.groupIdx
		p.zhenfaid = self.selectedZhenfaID
		LuaProtocolManager:send(p)
	end
	
	ZhenFaAdjustDlg.DestroyDialog()
end

function ZhenFaAdjustDlg:onEventMemberChange()
	if _instance then
		local cell = _instance.allZhenfaCells[_instance.selectedZhenfaID]
		_instance:refreshSelectedZhenfa(cell)
	end
end

return ZhenFaAdjustDlg
