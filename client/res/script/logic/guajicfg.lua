require "logic.dialog"
require "logic.numbersel"

GuaJiAIDlg = {}
setmetatable(GuaJiAIDlg, Dialog)
GuaJiAIDlg.__index = GuaJiAIDlg

local _instance
function GuaJiAIDlg.getInstance()
	if not _instance then
		_instance = GuaJiAIDlg:new()
		_instance:OnCreate()
	end
	return _instance
end
function GuaJiAIDlg.getInstanceAndShow()
	if not _instance then
		_instance = GuaJiAIDlg:new()
		_instance:OnCreate()
	else
		_instance:SetVisible(true)
	end
	return _instance
end
function GuaJiAIDlg.getInstanceNotCreate()
	return _instance
end

function GuaJiAIDlg.DestroyDialog()
	if _instance then 
		if not _instance.m_bCloseIsHide then
			_instance:OnClose()
			_instance = nil
		else
			_instance:ToggleOpenClose()
		end
	end
end

function GuaJiAIDlg.GetLayoutFileName()
	return "guajifuzhu_mtg.layout"
end

function GuaJiAIDlg:new()
	local self = {}
	self = Dialog:new()
	setmetatable(self, GuaJiAIDlg)
	return self
end

function GuaJiAIDlg:OnCreate()
	Dialog.OnCreate(self)
	local winMgr = CEGUI.WindowManager:getSingleton()
    
    self.framewnd = winMgr:getWindow("guajifuzhu_mtg/diban")
	self.m_pCloseBtn = CEGUI.Window.toPushButton(winMgr:getWindow("guajifuzhu_mtg/close"))
    self.m_pCloseBtn:subscribeEvent("Clicked", GuaJiAIDlg.DestroyDialog, self)

    local zhiye = gGetDataManager():GetMainCharacterSchoolID()

    self.allset = {}
	local IDCollection = BeanConfigManager.getInstance():GetTableByName("battle.crolefighteai"):getAllID()
    for i = 1, #IDCollection do
		local nId = IDCollection[i]
		local record = BeanConfigManager.getInstance():GetTableByName("battle.crolefighteai"):getRecorder(nId)
        if zhiye==record.school  then
            local find = false
            for j=1,#self.allset do
                if self.allset[j].aiID == record.ai then
                    table.insert(self.allset[j].idlist,nId)
                    table.insert(self.allset[j].paramlist,record.param)
                    find = true
                    break
                end
            end
            if find == false then
                local ad = {}
                ad.aiID = record.ai
                ad.current = 1
                ad.selected = false 
                ad.skillID = record.skill
                ad.level = record.level
                local showLevel = RoleSkillManager.getInstance():GetRoleSkillLevel(record.skill)
                if showLevel == 0 then
                    ad.selenable = false
                else
                    ad.selenable = true
                end
                ad.idlist = {}
                ad.paramlist = {}
                table.insert(ad.idlist,nId)
                table.insert(ad.paramlist,record.param)
		        table.insert(self.allset,ad)
            end
        end
    end
    
    self.listWnd = CEGUI.toScrollablePane(winMgr:getWindow("guajifuzhu_mtg/diban/list"));
      
    self.listInfo = {}
    local sx = 10.0;
    local sy = 0.0;
    for i = 1, #self.allset do
        local info = {}
        local sID = tostring(i)
        info.lyout = winMgr:loadWindowLayout("guajifuzhucell_mtg.layout",sID);
        self.listWnd:addChildWindow(info.lyout)
        
        info.txt = winMgr:getWindow(sID.."guajifuzhucell_mtg/text")        
	    --info.txt:subscribeEvent("MouseButtonUp", GuaJiAIDlg.handleTextClicked, self)
        
        info.txtBtn = CEGUI.Window.toPushButton(winMgr:getWindow(sID.."guajifuzhucell_mtg/btn")) 
        info.txtBtn:setID(i)
	    info.txtBtn:subscribeEvent("MouseButtonUp", GuaJiAIDlg.handleCountClicked, self)
        info.txtBtn:setVisible(false)       
        
        info.chkBtn = CEGUI.Window.toCheckbox(winMgr:getWindow(sID.."guajifuzhucell_mtg/checkbox")) 
        info.chkBtn:setID(i)
	    info.chkBtn:subscribeEvent("CheckStateChanged", GuaJiAIDlg.handleCheckClicked, self)

	    info.lyout:setPosition(CEGUI.UVector2(CEGUI.UDim(0.0, sx), CEGUI.UDim(0.0, sy + (i-1) * 55)))
        info.lyout:setVisible(false)

        table.insert(self.listInfo,info)
    end
    
	self.m_btnFight = CEGUI.toPushButton(winMgr:getWindow("guajifuzhu_mtg/jinengdiban/pugong"))
	self.m_imgFight = winMgr:getWindow("guajifuzhu_mtg/jinengdiban/pugong/gouxuanzhuangtai7")
	self.m_btnDef = CEGUI.toPushButton(winMgr:getWindow("guajifuzhu_mtg/jinengdiban/fangyu"))
	self.m_imgDef = winMgr:getWindow("guajifuzhu_mtg/jinengdiban/pugong/gouxuanzhuangtai8")
    
	self.m_btnFight:subscribeEvent("Clicked", GuaJiAIDlg.HandleBtnFightClick, self)
	self.m_btnDef:subscribeEvent("Clicked", GuaJiAIDlg.HandleBtnDefClick, self)

	self.m_OperateTypePlayer = 0
	self.m_OperateIDPlayer = 0
    self.m_listSkillText =  { }
    for i = 1 , 6 do
        self.m_listSkillText[i] = winMgr:getWindow("guajifuzhu_mtg/jinengdiban/skill".. i .."/jinengmingcheng"..i)
    end
	self.m_tSkillInfoArr = {}
	for i = 1, 6 do
		local SkillInfo = {}
		SkillInfo.pBtn = tolua.cast(winMgr:getWindow("guajifuzhu_mtg/jinengdiban/skill" .. tostring(i)),"CEGUI::SkillBox")
		SkillInfo.pBtn:subscribeEvent("MouseClick", GuaJiAIDlg.HandleSkill, self)
		SkillInfo.pBtn:subscribeEvent("MouseButtonDown", GuaJiAIDlg.HandleTableClick, SkillInfo.pBtn)
				
		SkillInfo.pBtn:setID(i)
		SkillInfo.pCheck = winMgr:getWindow("guajifuzhu_mtg/jinengdiban/skill" .. i .. "/gouxuanzhuangtai" .. tostring(i))
		SkillInfo.ID = 0
		self.m_tSkillInfoArr[i] = SkillInfo
	end	

    self:refreshText()
    self:refreshSelect()
    if GetBattleManager():IsInBattle() then
        self:refreshBattleSkill()
    else
        self:refreshSkill()
    end 
	self.m_OperateTypePlayer = GetBattleManager():GetAutoCommandOperateType(0)
	self.m_OperateIDPlayer = GetBattleManager():GetAutoCommandOperateID(0)

    self:SetSel(self.m_OperateTypePlayer,self.m_OperateIDPlayer)

    self.netback = false
	local p = require "protodef.fire.pb.hook.cgetrolefightai":new()
    require "manager.luaprotocolmanager".getInstance():send(p)
end

function GuaJiAIDlg:OnClose()  
	Dialog.OnClose(self)        
    if self.netback == false then
        return
    end
	local p = require "protodef.fire.pb.hook.csetrolefightai":new()
    --p.fightaiids = {}
    for i=1,#self.allset do
        if self.allset[i].selected == true then            
            table.insert(p.fightaiids, self.allset[i].idlist[self.allset[i].current])  
        end
    end
    require "manager.luaprotocolmanager".getInstance():send(p)
end

function GuaJiAIDlg:handleCountClicked(args)
    local e = CEGUI.toWindowEventArgs(args)
	local nId = e.window:getID()
    self.currentSel = nId
    local dlg = NumberSelDlg.getInstanceAndShow(self.framewnd,self.allset[nId].paramlist,GuaJiAIDlg.handleNumClicked)
    local lpos = self.listInfo[nId].txtBtn:getPosition()
    if dlg and dlg.m_pMainFrame then
        dlg.m_pMainFrame:setPosition(CEGUI.UVector2(CEGUI.UDim(0.0, lpos.x.offset+90), CEGUI.UDim(0.0, lpos.y.offset)))
    end
    self:refreshText()
end
function GuaJiAIDlg:handleCheckClicked(args)
    local e = CEGUI.toWindowEventArgs(args)
	local nId = e.window:getID()
    if self.allset[nId].selected == self.listInfo[nId].chkBtn:isSelected() then
        return
    end
    if self.allset[nId].selenable == false then
        self.listInfo[nId].chkBtn:setSelected(false)
        local text = MHSD_UTILS.get_msgtipstring(166002)
        local nconfig = BeanConfigManager.getInstance():GetTableByName("skill.cskillconfig"):getRecorder(self.allset[nId].skillID)
        text = string.gsub(text, "%$parameter1%$", self.allset[nId].level)        
        text = string.gsub(text, "%$parameter2%$", nconfig.name)
        GetCTipsManager():AddMessageTip(text)
    end
    self.allset[nId].selected = self.listInfo[nId].chkBtn:isSelected()
    self:refreshSelect()
end

function GuaJiAIDlg:HandleSkill(args)
	local e = CEGUI.toWindowEventArgs(args)
	local SkillIndex = self:GetSelSkillIndex(e.window)
	local skillID = self.m_tSkillInfoArr[SkillIndex].ID
	if self.m_TipShow ~= true then
        self:HideSkillTip()
	    --判断是什么人物还是宠物
	    local dlg = MapChoseDlg.getInstanceNotCreate()
	
	    if dlg then
		    dlg:SetRoleSkill( 2, skillID )
	    end
	
	    self:SelSkill(2, skillID)
    end
end

--设置自动技能
function GuaJiAIDlg:SelSkill(OperateType,OperateID)
	self.m_OperateTypePlayer = OperateType
	self.m_OperateIDPlayer = OperateID
	GetBattleManager():SetAutoCommandOperateType(0,OperateType)
	GetBattleManager():SetAutoCommandOperateID(0,OperateID)	
    gCommon.RoleOperateType = OperateType
    gCommon.RoleSelecttedSkill = OperateID
    local dlg = BattleAutoFightDlg.getInstanceNotCreate()
    if dlg then
	    dlg:InitPlayerOrPetSkill(0,OperateType,OperateID)
    end
    self:SetSel(self.m_OperateTypePlayer,self.m_OperateIDPlayer)
	local p = require "protodef.fire.pb.hook.csetcharopt":new()
	p.charoptype = OperateType
	p.charopid = OperateID
	require "manager.luaprotocolmanager":send(p)
end

function GuaJiAIDlg:HandleBtnFightClick(args)
	
	local dlg = MapChoseDlg.getInstanceNotCreate()
	if dlg then
		dlg:SetRoleSkill( 1, SkillIndex )
	end
	self:SelSkill(1,0)
end

function GuaJiAIDlg:HandleBtnDefClick(args)

	local dlg = MapChoseDlg.getInstanceNotCreate()
	if dlg then
		dlg:SetRoleSkill( 4, SkillIndex )
	end
	self:SelSkill(4,0)
end

function GuaJiAIDlg:GetSelSkillIndex(Window)
	for i = 1, 6 do
		if self.m_tSkillInfoArr[i].pBtn == Window then
			return i
		end
	end
	return 0
end
function GuaJiAIDlg:SkillIDToIndex(SkillID)
	for i = 1, 6 do
		if SkillID == self.m_tSkillInfoArr[i].ID then
			return i
		end
	end
	return 0;
end
function GuaJiAIDlg:HideAllCheck()
	for i = 1, 6 do
		self.m_tSkillInfoArr[i].pCheck:setVisible(false)
	end
	self.m_imgFight:setVisible(false)
	self.m_imgDef:setVisible(false)
end
--这里设置攻击和防御的对勾
function GuaJiAIDlg:SetSel(OperateType,OperateID)
    self:HideAllCheck()
	if OperateType == 2 then--技能
		local SkillIndex = self:SkillIDToIndex(OperateID)
		if SkillIndex > 0 then
			self.m_tSkillInfoArr[SkillIndex].pCheck:setVisible(true)
		end
	else
		if OperateType == 1 then--普通攻击
			self.m_imgFight:setVisible(true)
		else--防御
			self.m_imgDef:setVisible(true)
		end
	end
end

function GuaJiAIDlg:refreshText()
	local winMgr = CEGUI.WindowManager:getSingleton()
    for i = 1, #self.listInfo do
		local record = BeanConfigManager.getInstance():GetTableByName("battle.crolefighteai"):getRecorder(self.allset[i].idlist[self.allset[i].current])
        local str = record.desc
        local replaceStr = "      "
        str = string.gsub(str, "%$parameter1%$", replaceStr)
        local idp = string.find(str,replaceStr)            
        local tColor = "[colour=".."\'".."FF8c5e2a".."\'".."]"
        if self.allset[i].selenable == false then
            tColor = "[colour=".."\'".."FF7f7f7f".."\'".."]"
        end
        self.listInfo[i].txt:setText(tColor .. str)
        if #self.allset[i].idlist > 1 then
            self.listInfo[i].txtBtn:setText(tostring(record.param))

            local textpos = self.listInfo[i].txt:getPosition()
            local pos = self.listInfo[i].txtBtn:getPosition()
            self.listInfo[i].txtBtn:setPosition(CEGUI.UVector2(CEGUI.UDim(0.0, textpos.x.offset+ (idp-1)*22), CEGUI.UDim(0.0, pos.y.offset)))
            
            self.listInfo[i].txtBtn:setVisible(true)
        else
            self.listInfo[i].txtBtn:setVisible(false)
        end
    end
end

function GuaJiAIDlg:refreshSelect()
	local winMgr = CEGUI.WindowManager:getSingleton()
    for i = 1, #self.listInfo do
        self.listInfo[i].chkBtn:setSelected(self.allset[i].selected)
    end
end

function GuaJiAIDlg:refreshBattleSkill()    
    for i = 1, #(self.m_listSkillText) do
		self.m_listSkillText[i]:setVisible(false)
        self.m_tSkillInfoArr[i].pBtn:setVisible(false)
	end

    local SkillIDArr = require("logic.battle.battlemanager").getInstance():GetRoleBattleSkillIDArr()
	local SkillCount = #SkillIDArr
    local k = 1
	local iLevel = require("logic.battle.battlemanager").getInstance():GetMainCharacterLevel()
	for i = 0, SkillCount - 1 do
        local bshow = true
        if GetBattleManager():IsInPVPBattle() == true then
             local skillconfig = BeanConfigManager.getInstance():GetTableByName("skill.cskillconfig"):getRecorder(SkillIDArr[i+1])
             if skillconfig and skillconfig.isonlypve == 1 then
                bshow = false
            end
        end
        
        if bshow then
		    self.m_tSkillInfoArr[k].ID = SkillIDArr[i+1]
		    SkillBoxControl.SetSkillInfo(self.m_tSkillInfoArr[k].pBtn, self.m_tSkillInfoArr[k].ID, 0)
		    self.m_tSkillInfoArr[k].pBtn:setVisible(true)

            --设置技能名称
            self.m_listSkillText[k]:setVisible(true)
		    local skilltypecfg = BeanConfigManager.getInstance():GetTableByName("skill.cschoolskillitem"):getRecorder(self.m_tSkillInfoArr[k].ID)
		    local name = skilltypecfg.skillabbrname
            self.m_listSkillText[k]:setText(skilltypecfg.skillabbrname)

            local schoolskillbase = BeanConfigManager.getInstance():GetTableByName("skill.cschoolskillitem"):getRecorder(self.m_tSkillInfoArr[k].ID)
		    local fParam1 = 0
		    if schoolskillbase then
			    fParam1 = schoolskillbase.paramA * iLevel + schoolskillbase.paramB
            end
		    local skillinfo = BeanConfigManager.getInstance():GetTableByName("skill.cskillitem"):getRecorder(self.m_tSkillInfoArr[k].ID)

            local rt = self:CheckCost(skillinfo.costTypeA, fParam1)
		    if rt == false then
			    local huoliColor = "FFFF0000"
			    local textColor = "tl:"..huoliColor.." tr:"..huoliColor.." bl:"..huoliColor.." br:"..huoliColor
			    self.m_listSkillText[k]:setProperty("TextColours", textColor)
		    else
			    local huoliColor = "FFFFffff"
			    local textColor = "tl:"..huoliColor.." tr:"..huoliColor.." bl:"..huoliColor.." br:"..huoliColor
			    self.m_listSkillText[k]:setProperty("TextColours", textColor)
            end

		    k = k + 1
         end
	end
    --[[		
    for k,v in pairs(sortskill) do

        

        index = index + 1
    end--]]
end

function GuaJiAIDlg:CheckCost(iCostType, iCostNum)
    if iCostType <= 0 or iCostNum <= 0 then
		return true
	end
	
	local CurCostValue = 0
	local MCD = gGetDataManager():GetMainCharacterData()
	CurCostValue = MCD:GetValue(iCostType)

	if CurCostValue < iCostNum then
		return false
    end
	return true
end

function GuaJiAIDlg:refreshSkill()    
	local SkillIDArr = RoleSkillManager.getInstance():GetRoleBattleSkillIDArr()
    for i = 1, #(self.m_listSkillText) do
		self.m_listSkillText[i]:setVisible(false)
        self.m_tSkillInfoArr[i].pBtn:setVisible(false)
	end

	local SkillCount = #SkillIDArr
	for i = 0, SkillCount - 1 do
		self.m_tSkillInfoArr[i + 1].ID = SkillIDArr[i+1]
		SkillBoxControl.SetSkillInfo(self.m_tSkillInfoArr[i + 1].pBtn, self.m_tSkillInfoArr[i + 1].ID, 0)
		self.m_tSkillInfoArr[i + 1].pBtn:setVisible(true)

        --设置技能名称
        self.m_listSkillText[i+1]:setVisible(true)
		local skilltypecfg = BeanConfigManager.getInstance():GetTableByName("skill.cschoolskillitem"):getRecorder(self.m_tSkillInfoArr[i + 1].ID)
		local name = skilltypecfg.skillabbrname
        self.m_listSkillText[i+1]:setText(skilltypecfg.skillabbrname)
	end
end

function GuaJiAIDlg:handleTextClicked(args)
    local e = CEGUI.toWindowEventArgs(args)
	local nItemId = e.window:getID()
end

 function  GuaJiAIDlg:initSelectList(list)
    for i=1,#self.allset do
        self.allset[i].selected = false
    end

    for i=1,#list do
        local sID = list[i]

        for j=1,#self.allset do
            for k=1,#self.allset[j].idlist do
                if self.allset[j].idlist[k] == sID then
                    self.allset[j].current = k
                    self.allset[j].selected = true
                    break
                end
            end
        end
    end
    for i = 1, #self.listInfo do
        self.listInfo[i].lyout:setVisible(true)
    end
    self:refreshText()
    self:refreshSelect()
    self.netback = true
 end
 
function GuaJiAIDlg:handleNumClicked(args)   
    local e = CEGUI.toWindowEventArgs(args)
	local nId = e.window:getID()

    local dlg = GuaJiAIDlg.getInstance()

    dlg.allset[dlg.currentSel].current = nId
    
    dlg:refreshText()
    NumberSelDlg.DestroyDialog()
end

function GuaJiAIDlg:HandleTableClick(args)
	GuaJiAIDlg.getInstance():HideSkillTip()
    local pCell = CEGUI.toSkillBox(CEGUI.toWindowEventArgs(args).window)
	if pCell == nil then
		return false
	end
	pCell:captureInput()
	local skillid = pCell:GetSkillID()
	if skillid == 0 then
		return false
	end
	GuaJiAIDlg.getInstance().m_DownSkill = pCell
	return true
end

function GuaJiAIDlg:HideSkillTip()
	self.m_DownSkill = nil
	self.m_TipTime = 0
	self.m_TipShow = false
	BattleSkillTip.DestroyDialog()
end
function GuaJiAIDlg:update(delta)    
    local pTargetWnd = CheckTipsWnd.GetCursorWindow()
    if pTargetWnd ~= nil then
        if self.m_TipShow == false then
            if self.m_DownSkill ~= nil then
                if self.m_DownSkill == pTargetWnd or pTargetWnd:isAncestor(m_DownSkill) then
                    self.m_TipTime = self.m_TipTime + delta
					if self.m_TipTime >= 500 then
						local pCell = self.m_DownSkill
						if pCell == nil then
							return
                        end
						local skillid = pCell:GetSkillID()
						if skillid == 0 then
							return
                        end
						BattleSkillTip.showAndSetSkill(skillid)
						self.m_TipShow = true
                    end
                else 
                    if pTargetWnd == nil then
						self.m_DownSkill = nil
					end
                end
            end
        end
    else
        self.m_DownSkill = nil
    end
end

local p = require "protodef.fire.pb.hook.sflushrolefightai"
function p:process()
     local dlg = GuaJiAIDlg.getInstance()
     dlg:initSelectList(self.fightaiids)
end
return GuaJiAIDlg
