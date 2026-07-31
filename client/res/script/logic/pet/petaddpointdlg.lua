------------------------------------------------------------------
-- 宠物加点
------------------------------------------------------------------
require "logic.dialog"
require "logic.pet.petaddpointsetting"

PetAddPointDlg = {}
setmetatable(PetAddPointDlg, Dialog)
PetAddPointDlg.__index = PetAddPointDlg

local ATTR = {
	TIZHI = 1,	--体质
	MAGIC = 2,	--魔力(IQ)
	POWER = 3,	--力量
	NAILI = 4,	--耐力
	MINJIE = 5	--敏捷
}


local THUMB_OFFSET = 40 --25是thumb图片左边缘离图案中心的距离

local _instance
function PetAddPointDlg.getInstance()
	if not _instance then
		_instance = PetAddPointDlg:new()
		_instance:OnCreate()
	end
	return _instance
end

function PetAddPointDlg.getInstanceAndShow()
	if not _instance then
		_instance = PetAddPointDlg:new()
		_instance:OnCreate()
	else
		_instance:SetVisible(true)
	end
	return _instance
end

function PetAddPointDlg.getInstanceNotCreate()
	return _instance
end

function PetAddPointDlg.DestroyDialog()
	if _instance then
		gGetDataManager().m_EventPetDataChange:RemoveScriptFunctor(_instance.eventPetDataChange)
		if not _instance.m_bCloseIsHide then
			_instance:OnClose()
			_instance = nil
		else
			_instance:ToggleOpenClose()
		end
	end
end

function PetAddPointDlg.ToggleOpenClose()
	if not _instance then
		_instance = PetAddPointDlg:new()
		_instance:OnCreate()
	else
		if _instance:IsVisible() then
			_instance:SetVisible(false)
		else
			_instance:SetVisible(true)
		end
	end
end

function PetAddPointDlg.GetLayoutFileName()
	return "petjiadian_mtg.layout"
end

function PetAddPointDlg:new()
	local self = {}
	self = Dialog:new()
	setmetatable(self, PetAddPointDlg)
	return self
end

function PetAddPointDlg:addButtonAnimation(button, animationName)
    local animationDef = CEGUI.AnimationManager:getSingleton():getAnimation(animationName)
    if animationDef then
        local animation = CEGUI.AnimationManager:getSingleton():instantiateAnimation(animationDef)
        animation:setTargetWindow(button)
        animation:setSpeed(0.6) 
        button:subscribeEvent("MouseButtonDown", function()
            animation:start()
        end, self)
    end
end

function PetAddPointDlg:OnCreate()
	Dialog.OnCreate(self)
	local winMgr = CEGUI.WindowManager:getSingleton()

	self.leftPointText = winMgr:getWindow("petjiadian_mtg/right/0")
	self.hp = winMgr:getWindow("petjiadian_mtg/left/textbg/1")
	self.mp = winMgr:getWindow("petjiadian_mtg/left/textbg/2")
	self.phyHurt = winMgr:getWindow("petjiadian_mtg/left/textbg/3")
	self.magicHurt = winMgr:getWindow("petjiadian_mtg/left/textbg/4")
	self.phyDefend = winMgr:getWindow("petjiadian_mtg/left/textbg/5")
	self.magicDefend = winMgr:getWindow("petjiadian_mtg/left/textbg/6")
	self.speed = winMgr:getWindow("petjiadian_mtg/left/textbg/7")
	self.hpAdd = winMgr:getWindow("petjiadian_mtg/left/textbg/add1")
	self.mpAdd = winMgr:getWindow("petjiadian_mtg/left/textbg/add2")
	self.phyHurtAdd = winMgr:getWindow("petjiadian_mtg/left/textbg/add3")
	self.magicHurtAdd = winMgr:getWindow("petjiadian_mtg/left/textbg/add4")
	self.phyDefendAdd = winMgr:getWindow("petjiadian_mtg/left/textbg/add5")
	self.magicDefendAdd = winMgr:getWindow("petjiadian_mtg/left/textbg/add6")
	self.speedAdd = winMgr:getWindow("petjiadian_mtg/left/textbg/add7")
	self.nameText = winMgr:getWindow("petjiadian_mtg/left/titlename/name")
	self.petlevelText = winMgr:getWindow("petjiadian_mtg/left/titlename/leve")
	self.petitemcell = CEGUI.Window.toItemCell(winMgr:getWindow("petjiadian_mtg/left/titlename/iconcell")) 
	
	self.jiadiantishi = CEGUI.toRichEditbox(winMgr:getWindow("petjiadian_mtg/left/tishicc1"))
	self.jiadiantishi:Clear()
    self.jiadiantishi:AppendParseText(CEGUI.String(MHSD_UTILS.get_resstring(7408)))
    self.jiadiantishi:Refresh()


	

	
	self.resetBtn = CEGUI.toPushButton(winMgr:getWindow("petjiadian_mtg/right/xidianbutton"))---宠物洗点按钮
	self.sureBtn = CEGUI.toPushButton(winMgr:getWindow("petjiadian_mtg/right/querenjiadian"))---确认加点
	self.settingBtn = CEGUI.toPushButton(winMgr:getWindow("petjiadian_mtg/right/tuijianjiadian"))---加点方案
	self.sxsmButton = CEGUI.toPushButton(winMgr:getWindow("petjiadian_mtg/right/shuxingshuoming"))


    self.sxsmButton:subscribeEvent("Clicked", PetAddPointDlg.handleClickTipButton, self)
	self:addButtonAnimation(self.sxsmButton, "stucdyBtnPress")
	
	self.resetBtn:subscribeEvent("Clicked", PetAddPointDlg.handleResetClicked, self)
	self:addButtonAnimation(self.resetBtn, "stucwdyBtnPress")
	
	self.sureBtn:subscribeEvent("Clicked", PetAddPointDlg.handleSureClicked, self)
	self:addButtonAnimation(self.sureBtn, "stucwdyBtnPress")
	
	self.settingBtn:subscribeEvent("Clicked", PetAddPointDlg.handleSettingClicked, self)
    self:addButtonAnimation(self.settingBtn, "stucdyBtnPress")
	
    local thumbParent = winMgr:getWindow("petjiadian_mtg/right/thumbparent")
    self.progressWidth = thumbParent:getPixelSize().width

	self.bars = {}
	for i=1,5 do
		local bar = self:loadAttributeBar(i)
		self.bars[i] = bar
	end

	self.potentialPoint = 0
	
	self.eventPetDataChange = gGetDataManager().m_EventPetDataChange:InsertScriptFunctor(PetAddPointDlg.handleEventPetDataChange)
end

function PetAddPointDlg:loadAttributeBar(idx)
	local winMgr = CEGUI.WindowManager:getSingleton()
	
	local bar = {}
	bar.type = idx
	bar.minusBtn = CEGUI.toPushButton(winMgr:getWindow("petjiadian_mtg/right/jianhao" .. idx))
	bar.plusBtn = CEGUI.toPushButton(winMgr:getWindow("petjiadian_mtg/right/jiahao" .. idx))
	bar.thumbBtn = CEGUI.toThumb(winMgr:getWindow("petjiadian_mtg/right/thumb" .. idx))
	bar.blueBar = CEGUI.toProgressBar(winMgr:getWindow("petjiadian_mtg/right/blue" .. idx))
	bar.yellowBar = CEGUI.toProgressBar(winMgr:getWindow("petjiadian_mtg/right/yellow" .. idx))
	bar.curPointText = winMgr:getWindow("petjiadian_mtg/right/curpoint" .. idx)
	bar.addPointText = winMgr:getWindow("petjiadian_mtg/right/addpoint" .. idx)
	
	bar.thumbBtn:subscribeEvent("ThumbPosChanged", PetAddPointDlg.handleThumbeMoved, self)
	bar.thumbBtn:subscribeEvent("MouseButtonDown", PetAddPointDlg.handleThumbeDown, self)
	bar.minusBtn:subscribeEvent("MouseButtonDown", PetAddPointDlg.handleMinusClicked, self)
	bar.plusBtn:subscribeEvent("MouseButtonDown", PetAddPointDlg.handlePlusClicked, self)
	bar.thumbBtn:EnableClickAni(false)
	bar.minusBtn:EnableClickAni(false)
	bar.plusBtn:EnableClickAni(false)
	bar.curPointText:setText("")
	bar.curPointText:setText("")
	
	bar.thumbBtn:setID(idx)
	bar.minusBtn:setID(idx)
	bar.plusBtn:setID(idx)
	
	bar.basePoint = 0
	bar.curPoint = 0
	bar.addedPoint = 0
	
	function bar.refresh()
		bar.curPointText:setText(bar.curPoint)
		bar.yellowBar:setProgress(bar.basePoint/bar.max())
		bar.blueBar:setProgress((bar.curPoint+bar.addedPoint)/bar.max())
		bar.addPointText:setText(bar.addedPoint>0 and "+"..bar.addedPoint or "")
		self.leftPointText:setText(self.leftPoint)
		
		self:refreshBtnState()
	end
	
	function bar.plus(n)
		if self.leftPoint < n or bar.curPoint+bar.addedPoint+n > bar.max() then
			return
		end
		bar.addedPoint = bar.addedPoint+n
		self.leftPoint = self.leftPoint-n
		bar.refresh()
		bar.thumbBtn:setXPosition(CEGUI.UDim((bar.curPoint+bar.addedPoint)/bar.max()-bar.adjust,0))
		self:previewAttribute()
	end
	
	function bar.minus(n)
		if bar.addedPoint < n then
			return
		end
		bar.addedPoint = bar.addedPoint-n
		self.leftPoint = self.leftPoint+n
		bar.refresh()
		bar.thumbBtn:setXPosition(CEGUI.UDim((bar.curPoint+bar.addedPoint)/bar.max()-bar.adjust,0))
		self:previewAttribute()
	end
	
	function bar.total()
		return bar.curPoint+bar.addedPoint
	end
	
	function bar.max()
		return bar.basePoint+self.potentialPoint
	end
	
	function bar.thumbMoved(x) 
		local added = math.floor(bar.max()*(x/self.progressWidth))-bar.curPoint
        if added < 0 then
            added = 0
            bar.thumbBtn:setXPosition(CEGUI.UDim(bar.rangeMin, 0))
        elseif added >= bar.addedPoint + self.leftPoint then
            added = bar.addedPoint + self.leftPoint
            local rangeMax = math.min(1,(bar.curPoint+added)/bar.max())-bar.adjust
            bar.thumbBtn:setXPosition(CEGUI.UDim(rangeMax, 0))
        end

		local delta = added-bar.addedPoint

		self.leftPoint = self.leftPoint-delta
		bar.addedPoint = bar.addedPoint+delta
		bar.refresh()
		self:previewAttribute()
	end
	
	function bar.resetRange()
		bar.adjust = THUMB_OFFSET/self.progressWidth --THUMB_OFFSET是thumb图片左边缘离图案中心的距离
		bar.rangeMin = math.max(0,bar.curPoint/bar.max())-bar.adjust
        if self.leftPoint > 0 or bar.addedPoint > 0 then

            bar.thumbBtn:setHorzRange(0, 1)
        else
            --bar.rangeMax = bar.rangeMin
            bar.thumbBtn:setHorzRange(bar.rangeMin, bar.rangeMin)
        end
	end
	
	function bar.init(basePoint, curPoint)
		local needChangePos = true
		if bar.curPoint and bar.addedPoint and bar.curPoint+bar.addedPoint == curPoint then
			needChangePos = false
		end
		bar.basePoint = basePoint
		bar.curPoint = curPoint
		bar.addedPoint = 0
        bar.rangeMin = 0
        bar.rangeMax = 1
		bar.resetRange()
		bar.refresh()
		if needChangePos then
			bar.thumbBtn:setXPosition(CEGUI.UDim(bar.curPoint/bar.max()-bar.adjust,0))
		end
	end
	
	return bar
end

function PetAddPointDlg:handleClickTipButton(args)
    local tipsStr = ""
    if IsPointCardServer() then
        -- 去掉第二条提示
    else
        tipsStr = require("utils.mhsdutils").get_resstring(7410)----第一条
    end
    local title = require("utils.mhsdutils").get_resstring(7409)----标题名称
    local tipdlg = require "logic.workshop.tips1".getInstanceAndShow(tipsStr, title)
    SetPositionScreenCenter(tipdlg:GetWindow())
end

function PetAddPointDlg:refreshBtnState()
	for _, bar in pairs(self.bars) do
		bar.minusBtn:setEnabled(bar.addedPoint > 0)
		bar.plusBtn:setEnabled(bar.total() < bar.max() and self.leftPoint > 0)
	end
	
	local added = false
	for _,v in pairs(self.bars) do
		if v.addedPoint > 0 then
			added = true
			break
		end
	end
	
	self.sureBtn:setEnabled(added)
end

function PetAddPointDlg:setPetData(petData)
    local shapeData = BeanConfigManager.getInstance():GetTableByName("npc.cnpcshape"):getRecorder(petData:GetShapeID())
    local image = gGetIconManager():GetImageByID(shapeData.littleheadID)
    self.petitemcell:SetImage(image)
	
	self.petData = petData
	self.nameText:setText(petData.name)
--	self.petlevelText:setText("级"..petData:getAttribute(fire.pb.attr.AttrType.LEVEL))
	self.petlevelText:setText(petData:getAttribute(fire.pb.attr.AttrType.LEVEL)..MHSD_UTILS.get_resstring(3))
	self:refreshAttributes()
end



function PetAddPointDlg:refreshAttributes()
	print('PetAddPointDlg:refreshAttributes')
	if not self.petData then
		return
	end
	local petData = self.petData
	local petLevel = petData:getAttribute(fire.pb.attr.AttrType.LEVEL)
	self.potentialPoint = petLevel * 5 --潜力点总和
	self.leftPoint = petData:getAttribute(fire.pb.attr.AttrType.POINT)
	
	self.leftPointText:setText(self.leftPoint)
	print('--- init bfp:', petData.initbfp.cons, petData.initbfp.iq, petData.initbfp.str, petData.initbfp.endu, petData.initbfp.agi)
	self.bars[ATTR.TIZHI].init(petData.initbfp.cons+petLevel, petData:getAttribute(fire.pb.attr.AttrType.CONS))
	self.bars[ATTR.MAGIC].init(petData.initbfp.iq+petLevel, petData:getAttribute(fire.pb.attr.AttrType.IQ))
	self.bars[ATTR.POWER].init(petData.initbfp.str+petLevel, petData:getAttribute(fire.pb.attr.AttrType.STR))
	self.bars[ATTR.NAILI].init(petData.initbfp.endu+petLevel, petData:getAttribute(fire.pb.attr.AttrType.ENDU))
	self.bars[ATTR.MINJIE].init(petData.initbfp.agi+petLevel, petData:getAttribute(fire.pb.attr.AttrType.AGI))
	
	self.hp:setText(petData:getAttribute(fire.pb.attr.AttrType.MAX_HP))
	self.mp:setText(petData:getAttribute(fire.pb.attr.AttrType.MAX_MP))
	self.phyHurt:setText(petData:getAttribute(fire.pb.attr.AttrType.ATTACK))
	self.magicHurt:setText(petData:getAttribute(fire.pb.attr.AttrType.MAGIC_ATTACK))
	self.phyDefend:setText(petData:getAttribute(fire.pb.attr.AttrType.DEFEND))
	self.magicDefend:setText(petData:getAttribute(fire.pb.attr.AttrType.MAGIC_DEF))
	self.speed:setText(petData:getAttribute(fire.pb.attr.AttrType.SPEED))
	
	self.hpAdd:setText("")
	self.mpAdd:setText("")
	self.phyHurtAdd:setText("")
	self.magicHurtAdd:setText("")
	self.phyDefendAdd:setText("")
	self.magicDefendAdd:setText("")
	self.speedAdd:setText("")
end

function PetAddPointDlg:countSkillEffect(attrType, curVal, level)
    local skillnum = (self.petData and self.petData:getSkilllistlen() or 0)
    if skillnum == 0 then
        return math.floor(curVal)
    end

    local delta = 0
    local effectTable = BeanConfigManager.getInstance():GetTableByName("skill.cpetskilleffect")
    for i = 1, skillnum do
		local skill = self.petData:getSkill(i)
        local effectConf = effectTable:getRecorder(skill.skillid)
        if effectConf then
            for j = 0, effectConf.attrs:size()-1 do
                local attrid = effectConf.attrs[j]
                if attrid ~= 0 and attrid == attrType and effectConf.formulas:size() > j then
                    local formula = effectConf.formulas[j]
                    if formula ~= "" then
                        formula = formula:gsub("VALUE", curVal)
                        formula = formula:gsub("LEVEL", level)
                        delta = delta + loadstring("return " .. formula)()
                    end
                end
            end
        end
	end

    if delta ~= 0 then
        return math.floor(curVal + delta)
    end
    return math.floor(curVal)
end

--(力量点数*力量系数+智力点数*智力系数……) * 成长率 + 宠物等级*资质值/资质系数
function PetAddPointDlg:previewAttribute()
	if not self.petData then
		return
	end

    if self.bars[ATTR.TIZHI].addedPoint == 0 and
        self.bars[ATTR.MAGIC].addedPoint == 0 and
        self.bars[ATTR.POWER].addedPoint == 0 and
        self.bars[ATTR.NAILI].addedPoint == 0 and
        self.bars[ATTR.MINJIE].addedPoint == 0
      then
        self.hpAdd:setText("")
        self.mpAdd:setText("")
        self.phyHurtAdd:setText("")
        self.magicHurtAdd:setText("")
        self.phyDefendAdd:setText("")
        self.magicDefendAdd:setText("")
        self.speedAdd:setText("")
        return
    end

	local dataTable = BeanConfigManager.getInstance():GetTableByName("pet.cpetattrmoddata")
	local function countGrow(attrType)
		local conf = dataTable:getRecorder(attrType)
		return (self.bars[ATTR.TIZHI].total()*conf.consfactor +
				 self.bars[ATTR.MAGIC].total()*conf.iqfactor +
				 self.bars[ATTR.POWER].total()*conf.strfactor +
				 self.bars[ATTR.NAILI].total()*conf.endufactor +
				 self.bars[ATTR.MINJIE].total()*conf.agifactor) * self.petData.growrate
	end

	local level = self.petData:getAttribute(fire.pb.attr.AttrType.LEVEL)

	
	--hp
	local val = countGrow(fire.pb.attr.AttrType.MAX_HP)
    local countVal = val+level*self.petData:getAttribute(fire.pb.attr.AttrType.PET_PHYFORCE_APT)/360
    countVal = self:countSkillEffect(fire.pb.attr.AttrType.MAX_HP, countVal, level)
	local addValue = countVal - self.petData:getAttribute(fire.pb.attr.AttrType.MAX_HP)
	self.hpAdd:setText(addValue > 0 and "+" .. addValue or "")

	val = countGrow(fire.pb.attr.AttrType.MAX_MP)
    countVal = val+level*self.petData:getAttribute(fire.pb.attr.AttrType.PET_MAGIC_APT)/400
    countVal = self:countSkillEffect(fire.pb.attr.AttrType.MAX_MP, countVal, level)
	addValue = countVal - self.petData:getAttribute(fire.pb.attr.AttrType.MAX_MP)
	self.mpAdd:setText(addValue > 0 and "+" .. addValue or "")

	val = countGrow(fire.pb.attr.AttrType.ATTACK)
    countVal = val+level*self.petData:getAttribute(fire.pb.attr.AttrType.PET_ATTACK_APT)/400
    countVal = self:countSkillEffect(fire.pb.attr.AttrType.ATTACK, countVal, level)
	addValue = countVal - self.petData:getAttribute(fire.pb.attr.AttrType.ATTACK)
	self.phyHurtAdd:setText(addValue > 0 and "+" .. addValue or "")
	

	val = countGrow(fire.pb.attr.AttrType.MAGIC_ATTACK)
    countVal = val+level*self.petData:getAttribute(fire.pb.attr.AttrType.PET_MAGIC_APT)/1000
    countVal = self:countSkillEffect(fire.pb.attr.AttrType.MAGIC_ATTACK, countVal, level)
	addValue = countVal - self.petData:getAttribute(fire.pb.attr.AttrType.MAGIC_ATTACK)
	self.magicHurtAdd:setText(addValue > 0 and "+" .. addValue or "")

	val = countGrow(fire.pb.attr.AttrType.DEFEND)
    countVal = val+level*self.petData:getAttribute(fire.pb.attr.AttrType.PET_DEFEND_APT)/300
    countVal = self:countSkillEffect(fire.pb.attr.AttrType.DEFEND, countVal, level)
	addValue = countVal - self.petData:getAttribute(fire.pb.attr.AttrType.DEFEND)
	self.phyDefendAdd:setText(addValue > 0 and "+" .. addValue or "")

	val = countGrow(fire.pb.attr.AttrType.MAGIC_DEF)
    countVal = val+level*self.petData:getAttribute(fire.pb.attr.AttrType.PET_MAGIC_APT)/1000
    countVal = self:countSkillEffect(fire.pb.attr.AttrType.MAGIC_DEF, countVal, level)
	addValue = countVal - self.petData:getAttribute(fire.pb.attr.AttrType.MAGIC_DEF)
	self.magicDefendAdd:setText(addValue > 0 and "+" .. addValue or "")

	val = countGrow(fire.pb.attr.AttrType.SPEED)
    countVal = val+level*self.petData:getAttribute(fire.pb.attr.AttrType.PET_SPEED_APT)/480
    countVal = self:countSkillEffect(fire.pb.attr.AttrType.SPEED, countVal, level)
	addValue = countVal - self.petData:getAttribute(fire.pb.attr.AttrType.SPEED)
	self.speedAdd:setText(addValue > 0 and "+" .. addValue or "")

end

function PetAddPointDlg:requestResetPoint()
 
    if GetBattleManager():IsInBattle() then    
	    if self.petData.key == gGetDataManager():GetBattlePetID() then
		    GetCTipsManager():AddMessageTipById(160303) --战斗中不能进行此操作
		    return
	    end
    end

	local p = require("protodef.fire.pb.pet.cpetresetpoint").Create()
	p.petkey = self.petData.key 

	local count = self.petData.pointresetcount
	local costConf = BeanConfigManager.getInstance():GetTableByName("pet.cpetresetpointconfig"):getRecorder(count+1>5 and 5 or count+1)
	local roleItemManager = require("logic.item.roleitemmanager").getInstance()
	if costConf.cost > roleItemManager:GetPackMoney() then
	
		gGetMessageManager():CloseConfirmBox(eConfirmNormal,false)
		local needNum = costConf.cost - roleItemManager:GetPackMoney()
		CurrencyManager.handleCurrencyNotEnough(fire.pb.game.MoneyType.MoneyType_SilverCoin, needNum, costConf.cost, p)
		return
	end
	
	LuaProtocolManager:send(p)
	gGetMessageManager():CloseConfirmBox(eConfirmNormal,false)
end

function PetAddPointDlg:handleThumbeMoved(args)
	local wnd = CEGUI.toWindowEventArgs(args).window
	local xpos = wnd:getXPosition()
    local x = xpos.scale*self.progressWidth + xpos.offset + THUMB_OFFSET
	self.bars[wnd:getID()].thumbMoved(x)
end

function PetAddPointDlg:handleThumbeDown(args)
	local wnd = CEGUI.toWindowEventArgs(args).window
	self.bars[wnd:getID()].resetRange()
end

function PetAddPointDlg:handleMinusClicked(args)
	local idx = CEGUI.toWindowEventArgs(args).window:getID()
	self.bars[idx].minus(1)
end

function PetAddPointDlg:handlePlusClicked(args)
	local idx = CEGUI.toWindowEventArgs(args).window:getID()
	self.bars[idx].plus(1)
end

function PetAddPointDlg:handleResetClicked(args)
	if not self.petData then
		return
	end
	
	local canReset = false
	for _,bar in pairs(self.bars) do
		if bar.curPoint > bar.basePoint then
			canReset = true
			break
		end
	end
	if not canReset then
		GetCTipsManager():AddMessageTipById(150109) --可重置属性点为0，无需重置
		return
	end
	
	local count = self.petData.pointresetcount
	if count < 2 then
		local sb = StringBuilder:new()
		sb:Set("parameter1", count+1)
		gGetMessageManager():AddConfirmBox(
			eConfirmNormal,
			sb:GetString(MHSD_UTILS.get_msgtipstring(150042)),
			PetAddPointDlg.requestResetPoint,self,
			MessageManager.HandleDefaultCancelEvent,MessageManager
		)
        sb:delete()
	else
		local costConf = BeanConfigManager.getInstance():GetTableByName("pet.cpetresetpointconfig"):getRecorder(count+1>5 and 5 or count+1)		
		local sb = StringBuilder:new()
		sb:Set("parameter1", count+1)
		sb:Set("parameter2", costConf.cost)
		gGetMessageManager():AddConfirmBox(
			eConfirmNormal,
			sb:GetString(MHSD_UTILS.get_msgtipstring(150043)),
			PetAddPointDlg.requestResetPoint,self,
			MessageManager.HandleDefaultCancelEvent,MessageManager
		)
        sb:delete()
	end
end

function PetAddPointDlg:handleSureClicked(args)

    if GetBattleManager():IsInBattle() then    
	    if self.petData.key == gGetDataManager():GetBattlePetID() then
		    GetCTipsManager():AddMessageTipById(131451) --战斗中不能进行此操作
		    return
	    end
    end

	local added = false
	for _,v in pairs(self.bars) do
		if v.addedPoint > 0 then
			added = true
			break
		end
	end
	
	if not added then return end
		local req = require "protodef.fire.pb.pet.cpetaddpoint".Create()
		req.petkey = self.petData.key
		req.str = self.bars[ATTR.POWER].addedPoint
		req.iq = self.bars[ATTR.MAGIC].addedPoint
		req.cons = self.bars[ATTR.TIZHI].addedPoint
		req.endu = self.bars[ATTR.NAILI].addedPoint
		req.agi = self.bars[ATTR.MINJIE].addedPoint
		LuaProtocolManager.getInstance():send(req)
		self:refreshAttributes()---尝试刷新
		
end

function PetAddPointDlg:handleSettingClicked(args)

	local dlg = debugrequire('logic.pet.petaddpointsetting').getInstanceAndShow()
	dlg:setPetData(self.petData)
end

function PetAddPointDlg.handleEventPetDataChange(key)
	if not _instance or not _instance.petData or _instance.petData.key ~= key then
		return
	end
	_instance:refreshAttributes()
end

return PetAddPointDlg
