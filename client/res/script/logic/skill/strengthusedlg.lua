require "logic.dialog"
StrengthUseDlg = {}

setmetatable(StrengthUseDlg,Dialog)
StrengthUseDlg.__index = StrengthUseDlg

local _instance

function StrengthUseDlg.getInstance() 
	if not _instance then
		_instance = StrengthUseDlg.new()
		_instance:OnCreate()
	end
	return _instance

end


function StrengthUseDlg.getInstanceAndShow()
	if not _instance then
		_instance = StrengthUseDlg.new()
		_instance:OnCreate()
	else
		_instance:SetVisible(true)
	end
	return _instance
end

function StrengthUseDlg.getInstanceNotCreate()
	return _instance
end


function StrengthUseDlg.DestroyDialog()
    if _instance.animationInstance then 
       _instance.animationInstance:stop()
       _instance.animationInstance = nil 
    end
	if _instance then
        gGetDataManager().m_EventMainCharacterDataChange:RemoveScriptFunctor(StrengthUseDlg.m_eventData)
		_instance:OnClose()
	end
end

function StrengthUseDlg:OnClose()
	Dialog.OnClose(self)
	_instance = nil
end

function StrengthUseDlg.GetLayoutFileName()
	return "lifeskillhuoliduixian.layout"
end

function StrengthUseDlg.new()
	local self = {}
	self = Dialog:new()
	setmetatable(self, StrengthUseDlg)
	return self	
end

function StrengthUseDlg:OnCreate()
 	Dialog.OnCreate(self)

	self.m_dagongStrength = 100
	self.m_tongxinStrength = 100
	
	local winMgr = CEGUI.WindowManager:getSingleton()
	local frameWnd=CEGUI.toFrameWindow(winMgr:getWindow("lifeskillhuoliduixian/ditu"))
	local closeBtn=CEGUI.toPushButton(frameWnd:getCloseButton())
	closeBtn:subscribeEvent("MouseClick",StrengthUseDlg.HandleQuitClick,self)
	
	self.cc_hldh = winMgr:getWindow("lifeskillhuoliduixian")

	local aniMan = CEGUI.AnimationManager:getSingleton()
    local animationOpen = aniMan:getAnimation("FrameWindow3ani2") 
    self.animationInstance = aniMan:instantiateAnimation(animationOpen) 
    self.animationInstance:setTargetWindow(self.cc_hldh)
    self.animationInstance:start()
	
    self.m_eventData = gGetDataManager().m_EventMainCharacterDataChange:InsertScriptFunctor(StrengthUseDlg.refreshENERGY)

	-- 当前活力与活力最大值对比
	self.m_strengthBar = CEGUI.Window.toProgressBar(winMgr:getWindow("lifeskillhuoliduixian/ditu/barhuoli"))
	local curStrength = gGetDataManager():GetMainCharacterData():GetValue(fire.pb.attr.AttrType.ENERGY)
	local maxStrength = gGetDataManager():GetMainCharacterData():GetValue(fire.pb.attr.AttrType.ENLIMIT)
	self.m_strengthBar:setProgress(curStrength/maxStrength)
	self.m_strengthBar:setText(curStrength.."/"..maxStrength)
	
	-- 提示按钮
	local info_si = winMgr:getWindow("lifeskillhuoliduixian/ditu/btntishi")
	info_si:subscribeEvent("MouseButtonUp", StrengthUseDlg.HandleInfoClick, self)

	local dagongRecord = BeanConfigManager.getInstance():GetTableByName("skill.clifeskill"):getRecorder(340001)
	local dagong_itemcell = CEGUI.toItemCell(winMgr:getWindow("lifeskillhuoliduixian/ditu/item1"))
	local commRecord = GameTable.common.GetCCommonTableInstance():getRecorder(106)
    if IsPointCardServer() then
        commRecord = GameTable.common.GetCCommonTableInstance():getRecorder(368)
    end
	if commRecord then
		local itemBean = BeanConfigManager.getInstance():GetTableByName("item.citemattr"):getRecorder(tonumber(commRecord.value))
        if itemBean then
		    dagong_itemcell:SetImage(gGetIconManager():GetImageByID(itemBean.icon))
        end
	end
		
	local strengthConsume1 = winMgr:getWindow("lifeskillhuoliduixian/ditu/xiaohao1")
	-- 活力消耗规则
	local skillCostRecord = BeanConfigManager.getInstance():GetTableByName("skill.clifeskillcost"):getRecorder(1)
	if skillCostRecord then
		local costRule = dagongRecord.strengthCostRule
		local costList = skillCostRecord.strengthCostList
		if costRule and costRule > 0 and costRule <= costList:size() then
			self.m_dagongStrength = costList[costRule-1]
			strengthConsume1:setText(tostring(self.m_dagongStrength))
		end
	end
	
	-- 定义回掉函数
	local dagongBtn = CEGUI.toPushButton(winMgr:getWindow("lifeskillhuoliduixian/ditu/btndagong"))
	dagongBtn:subscribeEvent("Clicked", StrengthUseDlg.HandleDagongClicked, self)

    local acupointVec = RoleSkillManager.getInstance():GetRoleAcupointVec()

    local acupointFumo = tonumber(GameTable.common.GetCCommonTableInstance():getRecorder(239).value)
    local acupointID = acupointVec[(acupointFumo - 1) * 2+1]
    self.acupointLevel = acupointVec[(acupointFumo - 1) * 2 + 2]
    --local acupointInfo = GameTable.role.GetAcupointInfoTableInstance():getRecorder(acupointID)
    local acupointInfo = BeanConfigManager.getInstance():GetTableByName("role.acupointinfo"):getRecorder(acupointID)
    local acuSkillID = acupointInfo.pointToSkillList[1]
    if acupointID and self.acupointLevel and acupointInfo then
    	local lifeSkillRecord = BeanConfigManager.getInstance():GetTableByName("skill.clifeskill"):getRecorder(acuSkillID)
        self.acuSkillName = lifeSkillRecord.name
        -- 附魔道具图标
        local acuItemID = lifeSkillRecord.fumoItemID
        local itemBean = BeanConfigManager.getInstance():GetTableByName("item.citemattr"):getRecorder(acuItemID)
        self.acuItemCell = CEGUI.toItemCell(winMgr:getWindow("lifeskillhuoliduixian/ditu/item3"))
        if itemBean then
            self.acuItemCell:SetImage(gGetIconManager():GetImageByID(itemBean.icon))
        end
		self.acuItemCell:setID(acuItemID)
        self.acuItemCell:setID2(0)
        self.acuItemCell:subscribeEvent("TableClick", StrengthUseDlg.HandleItemClickWithItemID, self)
        
        -- 需要消耗的活力值
        local huoli_st = winMgr:getWindow("lifeskillhuoliduixian/ditu/xiaohao11")
        local needHuoli = 0
        if self.acupointLevel == 0 then 
            huoli_st:setText("0")
        else 
        	local skillCostRecord = BeanConfigManager.getInstance():GetTableByName("skill.clifeskillcost"):getRecorder(self.acupointLevel)
	        local strengthCostRule = lifeSkillRecord.strengthCostRule
	        local strengthCostList = skillCostRecord.strengthCostList

	        if strengthCostRule and strengthCostRule >= 1 and strengthCostRule <= strengthCostList:size() then
		        needHuoli = strengthCostList[strengthCostRule-1]
                huoli_st:setText(needHuoli)
            end
        end

        local makeBtn = CEGUI.toPushButton(winMgr:getWindow("lifeskillhuoliduixian/ditu/zhizuo2"))
	    makeBtn:subscribeEvent("Clicked", StrengthUseDlg.HandleMakeClicked, self)
        makeBtn:setID(needHuoli)
    end

	local gonghui_itemcell = CEGUI.toItemCell(winMgr:getWindow("lifeskillhuoliduixian/ditu/item2"))
	commRecord = GameTable.common.GetCCommonTableInstance():getRecorder(107)
	if commRecord then
		gonghui_itemcell:SetImage(gGetIconManager():GetImageByID(commRecord.value))
		local itemBean = BeanConfigManager.getInstance():GetTableByName("item.citemattr"):getRecorder(tonumber(commRecord.value))
        if itemBean then
		    gonghui_itemcell:SetImage(gGetIconManager():GetImageByID(itemBean.icon))
        end
	end
	local zhizuoBtn = CEGUI.toPushButton(winMgr:getWindow("lifeskillhuoliduixian/ditu/zhizuo"))
	zhizuoBtn:subscribeEvent("Clicked", StrengthUseDlg.HandleGonghuiClicked, self)

	local tongxinRecord = BeanConfigManager.getInstance():GetTableByName("skill.clifeskill"):getRecorder(340101)
	self.m_tongxinName = tongxinRecord.name
	self.tongxin_itemcell = CEGUI.toItemCell(winMgr:getWindow("lifeskillhuoliduixian/ditu/item4"))
	commRecord = GameTable.common.GetCCommonTableInstance():getRecorder(108)
	if commRecord then
		local itemBean = BeanConfigManager.getInstance():GetTableByName("item.citemattr"):getRecorder(commRecord.value)
        if itemBean then
		    self.tongxin_itemcell:SetImage(gGetIconManager():GetImageByID(itemBean.icon))
        end
        self.tongxin_itemcell:setID(commRecord.value)
        self.tongxin_itemcell:setID2(1)
        self.tongxin_itemcell:subscribeEvent("TableClick", StrengthUseDlg.HandleItemClickWithItemID, self)
	end
	local strengthConsume3 = winMgr:getWindow("lifeskillhuoliduixian/ditu/xiaohao12")
	-- 活力消耗规则
	if skillCostRecord then
		local costRule = tongxinRecord.strengthCostRule
		local costList = skillCostRecord.strengthCostList
		if costRule and costRule > 0 and costRule <= costList:size() then
			self.m_tongxinStrength = costList[costRule-1]
			strengthConsume3:setText(tostring(self.m_tongxinStrength))
		end
	end
	local tongxinBtn = CEGUI.toPushButton(winMgr:getWindow("lifeskillhuoliduixian/ditu/zhizuo3"))
	tongxinBtn:subscribeEvent("Clicked", StrengthUseDlg.HandleTongxinClicked, self)
	
    local textDagong=winMgr:getWindow("lifeskillhuoliduixian/ditu/dagongzhuanqian")
    local textDagongPay=winMgr:getWindow("lifeskillhuoliduixian/ditu/dagongzhuanqian1")
    if IsPointCardServer() then
        textDagongPay:setVisible(true)
        textDagong:setVisible(false)
    else
        textDagongPay:setVisible(false)
        textDagong:setVisible(true)
    end
end

function StrengthUseDlg:refreshHyd()
	local curStrength = gGetDataManager():GetMainCharacterData():GetValue(fire.pb.attr.AttrType.ENERGY)
	local maxStrength = gGetDataManager():GetMainCharacterData():GetValue(fire.pb.attr.AttrType.ENLIMIT)
	self.m_strengthBar:setProgress(curStrength/maxStrength)
	self.m_strengthBar:setText(curStrength.."/"..maxStrength)
end

function StrengthUseDlg:HandleMakeClicked(args)
    local event = CEGUI.toWindowEventArgs(args)
	local needHuoli = math.floor(event.window:getID())
    if needHuoli == 0 then
        local strbuilder = StringBuilder:new()
        strbuilder:Set("parameter1", self.acuSkillName)
        local msg=strbuilder:GetString(MHSD_UTILS.get_msgtipstring(150095))
        strbuilder:delete()
        GetCTipsManager():AddMessageTip(msg)
    elseif needHuoli > 0 then
        local haveHuoli = gGetDataManager():GetMainCharacterData():GetValue(fire.pb.attr.AttrType.ENERGY)
        if haveHuoli >= needHuoli then
	        -- 发出制作附魔道具请求
	        local p = require "protodef.fire.pb.skill.liveskill.cliveskillmakeenhancement".Create()
	        LuaProtocolManager.getInstance():send(p)
        else
            GetCTipsManager():AddMessageTipById(150100)
        end
    end
end

function StrengthUseDlg:HandleInfoClick()
	local title = MHSD_UTILS.get_resstring(10032)
	local strAllString = MHSD_UTILS.get_resstring(10033)
	-- 获取玩家等级
	local roleLevel = gGetDataManager():GetMainCharacterLevel()
	local strbuilder =StringBuilder:new()
	strbuilder:Set("parameter1", tostring(math.floor(3+0.09*roleLevel)))
	local content = strbuilder:GetString(strAllString)
	strbuilder:delete()
	local tips1 = require "logic.workshop.tips1"
    tips1.getInstanceAndShow(content, title)
	
end

function StrengthUseDlg:HandleDagongClicked()

	local playerEnergy = gGetDataManager():GetMainCharacterData():GetValue(fire.pb.attr.AttrType.ENERGY)
	if playerEnergy < self.m_dagongStrength then
		local strbuilder = StringBuilder:new()
		strbuilder:Set("parameter1", tostring(self.m_dagongStrength))
		GetCTipsManager():AddMessageTip(strbuilder:GetString(MHSD_UTILS.get_msgtipstring(143432)))
        strbuilder:delete()
		return
	end
	local p = require "protodef.fire.pb.skill.liveskill.cliveskillmakefarm".Create()
	LuaProtocolManager.getInstance():send(p)

end

function StrengthUseDlg:HandleGonghuiClicked()----活力打开辅助技能后销毁界面
    if gGetDataManager():GetMainCharacterLevel() >= 35 then
        require "logic.skill.skilllable"
        SkillLable.Show(2)

        -- 获取 StrengthUseDlg 实例
        local strengthUseDlg = StrengthUseDlg.getInstanceNotCreate()
        -- 销毁 StrengthUseDlg 窗口
        if strengthUseDlg then
            strengthUseDlg:DestroyDialog() 
        end
    else
        local msg = require "utils.mhsdutils".get_msgtipstring(150096)
        msg = string.gsub(msg, "%$parameter1%$", "35")
        GetCTipsManager():AddMessageTip(msg)
    end
end

function StrengthUseDlg:HandleTongxinClicked()
	local playerEnergy = gGetDataManager():GetMainCharacterData():GetValue(fire.pb.attr.AttrType.ENERGY)
	if playerEnergy < self.m_tongxinStrength then
		local strbuilder = StringBuilder:new()
		strbuilder:Set("parameter1", tostring(self.m_tongxinStrength))
		GetCTipsManager():AddMessageTip(strbuilder:GetString(MHSD_UTILS.get_msgtipstring(143432)))
        strbuilder:delete()
		return
	end
	local p = require "protodef.fire.pb.skill.liveskill.cliveskillmakefriendgift".Create()
	LuaProtocolManager.getInstance():send(p)

end

function StrengthUseDlg:HandleQuitClick()
	_instance:DestroyDialog()
end

function StrengthUseDlg:DagongCallback(addGold)
	if not addGold then
		return
	end

    if IsPointCardServer() then
        local strbuilder = StringBuilder:new()
        strbuilder:Set("parameter1", tostring(addGold))
        local content = strbuilder:GetString(MHSD_UTILS.get_msgtipstring(160049))
        GetCTipsManager():AddMessageTip(content)
        strbuilder:delete()
    else
        local strbuilder = StringBuilder:new()
        strbuilder:Set("parameter1", tostring(addGold))
        local content = strbuilder:GetString(MHSD_UTILS.get_msgtipstring(160050))
        GetCTipsManager():AddMessageTip(content)
        strbuilder:delete()
    end

	-- 修改活力值
	local curStrength = gGetDataManager():GetMainCharacterData():GetValue(fire.pb.attr.AttrType.ENERGY)
	local maxStrength = gGetDataManager():GetMainCharacterData():GetValue(fire.pb.attr.AttrType.ENLIMIT)
	self.m_strengthBar:setProgress(curStrength/maxStrength)
	self.m_strengthBar:setText(curStrength.."/"..maxStrength)
end
function StrengthUseDlg:refreshENERGY()
	-- 修改活力值
	local curStrength = gGetDataManager():GetMainCharacterData():GetValue(fire.pb.attr.AttrType.ENERGY)
	local maxStrength = gGetDataManager():GetMainCharacterData():GetValue(fire.pb.attr.AttrType.ENLIMIT)
    local dlg = require "logic.skill.strengthusedlg".getInstanceNotCreate()
    if dlg then
	    dlg.m_strengthBar:setProgress(curStrength/maxStrength)
	    dlg.m_strengthBar:setText(curStrength.."/"..maxStrength)
    end

end
function StrengthUseDlg:TongxinCallback(itemid)
	if not itemid then
		return 
	end
	local itemBean = BeanConfigManager.getInstance():GetTableByName("item.citemattr"):getRecorder(itemid)
	if itemBean then
        local msg = require "utils.mhsdutils".get_msgtipstring(150107)
        msg = string.gsub(msg, "%$parameter1%$", itemBean.name)
	    msg = string.gsub(msg, "%$parameter2%$", itemBean.colour)
	    GetCTipsManager():AddMessageTip(msg)
    end
	
	-- 修改活力值
	local curStrength = gGetDataManager():GetMainCharacterData():GetValue(fire.pb.attr.AttrType.ENERGY)
	local maxStrength = gGetDataManager():GetMainCharacterData():GetValue(fire.pb.attr.AttrType.ENLIMIT)
	self.m_strengthBar:setProgress(curStrength/maxStrength)
	self.m_strengthBar:setText(curStrength.."/"..maxStrength)
end

function StrengthUseDlg:MakeEnhancementCallback()
	-- 修改活力值
	local curStrength = gGetDataManager():GetMainCharacterData():GetValue(fire.pb.attr.AttrType.ENERGY)
	local maxStrength = gGetDataManager():GetMainCharacterData():GetValue(fire.pb.attr.AttrType.ENLIMIT)
	self.m_strengthBar:setProgress(curStrength/maxStrength)
	self.m_strengthBar:setText(curStrength.."/"..maxStrength)

end

function StrengthUseDlg:HandleItemClickWithItemID(args)
	local event = CEGUI.toWindowEventArgs(args)
	local itemID = event.window:getID()
    local itemType = event.window:getID2()
	local Commontipdlg = require "logic.tips.commontipdlg"
	local commontipdlg = Commontipdlg.getInstanceAndShow()
	-- 计算提示窗口位置
	local winMgr = CEGUI.WindowManager:getSingleton()
    local itemCell = self.acuItemCell
    if itemType == 1 then
        itemCell = self.tongxin_itemcell
    end
    if not itemCell then
        return
    end

    local pObj = -1
    if itemType == 0 then
        pObj = self.acupointLevel
    end
     
	local itemPos = itemCell:GetScreenPos()
    local itemWidth = itemCell:getWidth().offset
    local itemHeight = itemCell:getHeight().offset
	local posX = itemPos.x + itemWidth*1.1
	local posY = itemPos.y
	
	local nType = Commontipdlg.eType.eSkill
	
	commontipdlg:RefreshItem(nType,itemID,posX,posY)
    local tipHeight = commontipdlg:GetMainFrame():getPixelSize().height
    commontipdlg:GetMainFrame():setPosition(CEGUI.UVector2(CEGUI.UDim(0, posX), CEGUI.UDim(0, posY+itemHeight-tipHeight)))
end


return StrengthUseDlg
