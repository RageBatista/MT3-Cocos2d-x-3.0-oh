require "logic.dialog"

PetEquipTips = {}
setmetatable(PetEquipTips, Dialog)
PetEquipTips.__index = PetEquipTips

local _instance
function PetEquipTips.getInstance()
	if not _instance then
		_instance = PetEquipTips:new()
		_instance:OnCreate()
	end
	return _instance
end
function PetEquipTips.closeDialog()
	if not _instance then 
		return
	end
	-- _instance:DestroyDialog()
	
	
end
function PetEquipTips.getInstanceAndShow(petkey,itemid,itemkey)
	if not _instance then
		_instance = PetEquipTips:new()
		_instance:OnCreate()
	else
		_instance:SetVisible(true)
	end
	itemkey1=petkey
	itemkey2=itemid
	itemkey3=itemkey
	return _instance
end

function PetEquipTips.getInstanceNotCreate()
	return _instance
end

function PetEquipTips.DestroyDialog()
	if _instance then 
		if not _instance.m_bCloseIsHide then
			_instance:OnClose()
			_instance = nil
		else
			_instance:ToggleOpenClose()
		end
	end
end

function PetEquipTips.ToggleOpenClose()
	if not _instance then
		_instance = PetEquipTips:new()
		_instance:OnCreate()
	else
		if _instance:IsVisible() then
			_instance:SetVisible(false)
		else
			_instance:SetVisible(true)
		end
	end
end

function PetEquipTips.GetLayoutFileName()
	return "petequiptips.layout"
end

function PetEquipTips:new()
	local self = {}
	self = Dialog:new()
	setmetatable(self, PetEquipTips)
	return self
end

function PetEquipTips:OnCreate()
	Dialog.OnCreate(self)
	local winMgr = CEGUI.WindowManager:getSingleton()
	self.itemcell = CEGUI.toItemCell(winMgr:getWindow("petequipinfo/item"))
	self.name = winMgr:getWindow("petequipinfo/names")
	self.jcsz = winMgr:getWindow("petequipinfo/jcsz")
	self.name1 = winMgr:getWindow("petequipinfo/jcsx")
	self.jcsz1 = winMgr:getWindow("petequipinfo/jcsz1")
	self.name11 = winMgr:getWindow("petequipinfo/jcsx1")
    self.name2 = winMgr:getWindow("petequipinfo/leixingming")
	self.shuoming = winMgr:getWindow("petequipinfo/shuoming")
	self.defaultShuoming = self.shuoming:getText()
	

	self.xiexia = CEGUI.toPushButton(winMgr:getWindow("petequipinfo/button"))
	self.xiexia:subscribeEvent("MouseClick", PetEquipTips.handlewearEquipClicked, self)
	self.guanbi = CEGUI.toPushButton(winMgr:getWindow("petequipinfo/tanchuanggank"))
	self.guanbi:subscribeEvent("MouseClick", PetEquipTips.DestroyDialog, self)
end

--//杈圭晫褰掍綅
function PetEquipTips:RefreshPosCorrect(nX, nY)
    local mainFrame = self:GetMainFrame()
    local nCorrectX, nCorrectY = require "logic.tips.commontiphelper".RefreshPosCorrect(mainFrame, nX, nY)

    self.nCellPosX = nCorrectX
    self.nCellPosY = nCorrectY
end


function PetEquipTips:makepetequiptips(nItemId,petequipinfo,effect)
    self:RefreshPosCorrect(400,150)
    local itemAttrCfg = BeanConfigManager.getInstance():GetTableByName("item.citemattr"):getRecorder(nItemId)
    if not itemAttrCfg then
        return false
    end
	local strSpace1 = " "
	local strNormalColor = "FF00FF00"
	self.name:setText(itemAttrCfg.name)
	self.name1:setText(itemAttrCfg.namecc1)
	local function parseLevelFromText(strText)
		if strText == nil then
			return 0
		end
		local strLevel = string.match(tostring(strText), "(%d+)")
		if strLevel then
			return tonumber(strLevel) or 0
		end
		return 0
	end
	local nShowLevel = tonumber(itemAttrCfg.level) or 0
	if nShowLevel <= 0 then
		nShowLevel = tonumber(itemAttrCfg.needLevel) or 0
	end
	if nShowLevel <= 0 then
		nShowLevel = parseLevelFromText(itemAttrCfg.destribe)
	end
	if nShowLevel <= 0 then
		nShowLevel = parseLevelFromText(itemAttrCfg.usemethod)
	end
	self.name2:setText(itemAttrCfg.name1)
	local strEffectDesc = itemAttrCfg.effectdes
	if strEffectDesc == nil or string.len(strEffectDesc) == 0 then
		strEffectDesc = self.defaultShuoming
	end
	self.shuoming:setText(strEffectDesc)
    if string.len(itemAttrCfg.colour) > 0 then
        local strNewName = "[colour=" .. "\'" .. itemAttrCfg.colour .. "\'" .. "]" .. itemAttrCfg.name
        self.name:setText(strNewName)
        -- end
    else
        local strNewName = "[colour=" .. "\'" .. "FF00FF00" .. "\'" .. "]" .. itemAttrCfg.name
        self.name:setText(strNewName)
    end
	self.itemcell:SetImage(gGetIconManager():GetItemIconByID(itemAttrCfg.icon))
	local strLabel = ""
	if nShowLevel > 0 then
		local strLevelTitle = require "utils.mhsdutils".get_resstring(1)
		strLabel = strLevelTitle .. ":" .. tostring(nShowLevel) .. "\n"
	end
	for i, v in pairs(petequipinfo) do
		LogInfo("Key:"..i.."Value"..v)
			local propertyCfg =  BeanConfigManager.getInstance():GetTableByName("item.cattributedesconfig"):getRecorder(i)
			local nBaseValue = v
			if	i==1500 then
				 nBaseValue = v/1000
			end
			
			if nBaseValue~=0 then
				local strPropertyName = propertyCfg.name
				local strValue = "+"..nBaseValue
				local strLabelAll = strPropertyName..strSpace1
				strLabelAll = strLabelAll..strValue
				strLabel=strLabel..strLabelAll .."\n"
			end
	end
	self.jcsz:setText(strLabel)
	self.jcsz:setProperty("TextColours", "tl:FF00FF00 tr:FF00FF00 bl:FF00FF00 br:FF00FF00")
	-- local propertyCfg = BeanConfigManager.getInstance():GetTableByName("item.cattributedesconfig"):getRecorder(itemkey)
	-- if itemkey == 1500 then
	-- itemvalue = itemvalue/20
	-- end
	
	-- if propertyCfg ~=nil then
	--     strTitleName = propertyCfg.name .. " " .. "+" .. tostring(itemvalue)
	-- 	self.jcsz:setText(strTitleName)
	-- LogInfo("itemkey====="..strTitleName)
	-- end
	
			if effect>0 then 
			LogInfo("***" ..effect)
    local skillid = BeanConfigManager.getInstance():GetTableByName("item.cpettaozhuang"):getRecorder(effect)
    local skillid1 = BeanConfigManager.getInstance():GetTableByName("skill.cPetSkillConfig"):getRecorder(skillid.skill)
	self.name11:setText("濂楄")
	self.jcsz1:setText(skillid1.skillname)
	self.jcsz1:setProperty("TextColours", "tl:FFFF0000 tr:FFFF0000 bl:FFFF0000 br:FFFF0000")
			end
end

function PetEquipTips:handlewearEquipClicked(args)
			   local p = require("protodef.fire.pb.pet.coutpetequip"):new()
			    p.petkey = itemkey1
			    p.itemid = itemkey2
			    p.itemkey = itemkey2
			   LuaProtocolManager:send(p)
			   self.DestroyDialog()
end

return PetEquipTips

