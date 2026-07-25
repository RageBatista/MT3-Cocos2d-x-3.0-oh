require "logic.dialog"
require "utils.commonutil"


Taskcommitpetdialog = {}
setmetatable(Taskcommitpetdialog, Dialog)
Taskcommitpetdialog.__index = Taskcommitpetdialog
local _instance



function Taskcommitpetdialog:OnCreate()
	Dialog.OnCreate(self)
	local winMgr = CEGUI.WindowManager:getSingleton()
	self.scrollPane = CEGUI.toScrollablePane(winMgr:getWindow("renwuwupinshangjiaocw_mtg/textbg/list"))
	self.btnUse = winMgr:getWindow("renwuwupinshangjiaocw_mtg/btnshangjiao")
	self.btnUse:subscribeEvent("MouseClick", self.HandleClickedUse, self)
	--self.btnClose = winMgr:getWindow("UseToRemindcard/closed")
	--self.btnClose:subscribeEvent("MouseClick", self.HandleClickedClose, self)
	self.itemCell = CEGUI.toItemCell(winMgr:getWindow("renwuwupinshangjiaocw_mtg/textbg1/item"))
	self.labelName = winMgr:getWindow("renwuwupinshangjiaocw_mtg/textbg1/name") 
	self.labelLevel = winMgr:getWindow("renwuwupinshangjiaocw_mtg/textbg1/jishu") 
	self.m_pMainFrame:setAlwaysOnTop(true)
	
	for nIndex=1,8 do
		local strIndex = tostring(nIndex)
		local strPaneName = "renwuwupinshangjiaocw_mtg/textbg1/"..strIndex
		self.vLabelValue[nIndex] =  winMgr:getWindow(strPaneName)
	end
	--self:RefreshPetList()
end


function Taskcommitpetdialog:setDelegateTarget(target,targetCallback)
    self.delegateTarget = target
    self.targetCallback = targetCallback
end


function Taskcommitpetdialog:HandleClickedUse(e)

	local nPeiKeyInBattle = gGetDataManager():GetBattlePetID()
	if nPeiKeyInBattle == self.nCurItemKey then
		local strShowTipzi = MHSD_UTILS.get_resstring(11209)
		GetCTipsManager():AddMessageTip(strShowTipzi)
		return 
	end

    if self.delegateTarget and self.targetCallback then
        self.targetCallback(self.delegateTarget,self)
        self:DestroyDialog()
        return 
    end


	local Taskhelpertable = require "logic.task.taskhelpertable"
	local submitUnit  = require "protodef.rpcgen.fire.pb.npc.submitunit":new()
	local nItemId = self.nCurItemKey
	local nTaskTypeId = self.nTaskTypeId
	
	submitUnit.key = nItemId
	submitUnit.num = Taskhelpertable.GetSchoolNeedNum(nTaskTypeId)
	local nNpcKey = self.nNpcKey 
	local TaskHelper = require "logic.task.taskhelper"
	
	local p = require "protodef.fire.pb.npc.csubmit2npc":new()
	p.questid = nTaskTypeId
	p.npckey = nNpcKey
	p.submittype = 2 --1=item 2=pet
	p.things[1] = submitUnit
	require "manager.luaprotocolmanager":send(p)
	self:DestroyDialog()
end

function Taskcommitpetdialog:HandleClickedClose(e)
	self:DestroyDialog()
end

--刷新所有单元的位置.
function Taskcommitpetdialog:RefeshAllCellPos()
	for nIndex=1,#self.vCell do
		local cell = self.vCell[nIndex]
		
		local height = cell:getHeight():asAbsolute(0)
		local offset = height * (nIndex-1) or 1
		cell:setPosition(CEGUI.UVector2(CEGUI.UDim(0, 1), CEGUI.UDim(0, offset)))
	end
end


function Taskcommitpetdialog:SetCommitItemId(vItemKeyAll,nNpcKey,nTaskTypeId)
	--11209
	--local nPeiKeyInBattle = gGetDataManager():GetBattlePetID()
    self:ClearAllCell()

	local nPeiKeyInBattle = gGetDataManager():GetBattlePetID()
	
	local vItemKey = {}
	for k,nPetKey in pairs(vItemKeyAll) do 
		if nPetKey ~= nPeiKeyInBattle then
			vItemKey[#vItemKey +1] = nPetKey
		end
	end
	if table.getn(vItemKey) == 0 then
        return
    end
	
	self.nTaskTypeId = nTaskTypeId
	self.nNpcKey = nNpcKey
	local winMgr = CEGUI.WindowManager:getSingleton()
	local strLevelzi = MHSD_UTILS.get_resstring(11813)
	for nIndex=1,#vItemKey do
		local nPetKey = vItemKey[nIndex]
		local pPet = MainPetDataManager.getInstance():FindMyPetByID(nPetKey)
		local nPetId = pPet.baseid
		local petAttrCfg = BeanConfigManager.getInstance():GetTableByName("pet.cpetattr"):getRecorder(nPetId)
		local unusualId = petAttrCfg.unusualid
		local petKind = pPet.kind 
        if petAttrCfg then
		    local shapeCfg = BeanConfigManager.getInstance():GetTableByName("npc.cnpcshape"):getRecorder(petAttrCfg.modelid)
		    local nStarLevel = pPet:getAttribute(fire.pb.attr.AttrType.LEVEL)
		
		    local prefixName = "Taskcommitpetdialog"..tostring(nIndex-1)
		    local layoutCell = winMgr:loadWindowLayout("renwuwupinshangjiaocwcell_mtg.layout",prefixName)
		    local btnGroup = CEGUI.toGroupButton(layoutCell)
	        btnGroup:EnableClickAni(false) 
	
		    layoutCell:subscribeEvent("MouseClick", self.HandleClickedCell, self)
		    layoutCell.itemCellIcon =  CEGUI.toItemCell(winMgr:getWindow(prefixName.."renwuwupinshangjiaocwcell_mtg/touxiang1"))
		    layoutCell.labelName = winMgr:getWindow(prefixName.."renwuwupinshangjiaocwcell_mtg/name")
		    layoutCell.labelLevel = winMgr:getWindow(prefixName.."renwuwupinshangjiaocwcell_mtg/level")
			layoutCell.Skilllistlen = winMgr:getWindow(prefixName.."renwuwupinshangjiaocwcell_mtg/Skilllistlen")--技能数
			layoutCell.petlife = winMgr:getWindow(prefixName.."renwuwupinshangjiaocwcell_mtg/petlife")--寿命
			layoutCell.pinzhi = winMgr:getWindow(prefixName .. "renwuwupinshangjiaocwcell_mtg/pinzhi")--品质
		    local shapeData = BeanConfigManager.getInstance():GetTableByName("npc.cnpcshape"):getRecorder(pPet:GetShapeID())
		    layoutCell.nItemKey = nPetKey
		    local path = gGetIconManager():GetImagePathByID(shapeData.littleheadID):c_str()

            local image = gGetIconManager():GetImageByID(shapeCfg.littleheadID)

		    layoutCell.itemCellIcon:SetImage(image)
            local nQuality = petAttrCfg.quality
            SetItemCellBoundColorByQulityPet(layoutCell.itemCellIcon, nQuality)
			
            local nSkillCount = pPet:getSkilllistlen()  -- 技能数
            layoutCell.Skilllistlen:setText(tostring(nSkillCount)) 
			
			local nPetLife = pPet:getAttribute(fire.pb.attr.AttrType.PET_LIFE) -- 寿命
            layoutCell.petlife:setText(tostring(nPetLife))
			
            local qualityText = GetPetQualityText(petKind, unusualId)  -- 品质
            layoutCell.pinzhi:setText(qualityText)
		
		    layoutCell.labelName:setText(petAttrCfg.name)
		    local strLevel = tostring(nStarLevel)..strLevelzi
		    layoutCell.labelLevel:setText(strLevel)
		    self.scrollPane:addChildWindow(layoutCell)
		    if self.nCurItemKey==-1 then
			    self.nCurItemKey = nPetKey
		    end
		    self.vCell[nIndex] = layoutCell
		    TaskHelper.SetChildNoCutTouch(layoutCell)
        end
	end
	self:RefreshPetProperty()
	self:RefeshAllCellPos()
	self:RefreshCellSel()
end

function Taskcommitpetdialog:HandleClickedCell(e)
	local mouseArgs = CEGUI.toMouseEventArgs(e)
	local clickWin = mouseArgs.window
	self.nCurItemKey = clickWin.nItemKey

	self:RefreshCellSel()
	self:RefreshPetProperty()
end

function Taskcommitpetdialog:RefreshCellSel()
	for nIndex=1,#self.vCell do
		local cell = self.vCell[nIndex]
		local nItemKey = cell.nItemKey
		local groupBtn = CEGUI.toGroupButton(cell)
		if self.nCurItemKey==nItemKey then
			
			groupBtn:setSelected(true)
		else
			groupBtn:setSelected(false)
			--cell.imageBg:setProperty("Image","")
		end
	end  
end

function Taskcommitpetdialog:RefreshPetProperty()
	self.itemCell:Clear()
	local pPetData = MainPetDataManager.getInstance():FindMyPetByID(self.nCurItemKey)
    if not pPetData then
        return
    end
	local nPetId = pPetData.baseid
	local petAttrCfg = BeanConfigManager.getInstance():GetTableByName("pet.cpetattr"):getRecorder(nPetId)
    if not petAttrCfg then return end
	local shapeCfg = BeanConfigManager.getInstance():GetTableByName("npc.cnpcshape"):getRecorder(petAttrCfg.modelid)
	local nStarLevel = pPetData:getAttribute(fire.pb.attr.AttrType.LEVEL)
	local shapeData = BeanConfigManager.getInstance():GetTableByName("npc.cnpcshape"):getRecorder(pPetData:GetShapeID())
	local image = gGetIconManager():GetImageByID(shapeData.littleheadID)
	self.itemCell:SetImage(image)

    local nQuality = petAttrCfg.quality
    SetItemCellBoundColorByQulityPet(self.itemCell, nQuality)

	local nPeiKeyInBattle = gGetDataManager():GetBattlePetID()
	if nPeiKeyInBattle==self.nCurItemKey then
		self.itemCell:SetCornerImageAtPos("chongwuui", "chongwu_zhan", 1, 0.5)
	else
		self.itemCell:SetCornerImageAtPos(nil, 1, 0.5)
	end
	
	self.labelName:setText(petAttrCfg.name)
	local strLevelzi = MHSD_UTILS.get_resstring(351)
	local strLevel = tostring(nStarLevel)..strLevelzi
	self.labelLevel:setText(strLevel)
	
	local vnValue = {}
	local curVal = pPetData:getAttribute(fire.pb.attr.AttrType.PET_ATTACK_APT)
	vnValue[#vnValue + 1] = curVal
	curVal = pPetData:getAttribute(fire.pb.attr.AttrType.PET_DEFEND_APT)
	vnValue[#vnValue + 1] = curVal
		
	curVal = pPetData:getAttribute(fire.pb.attr.AttrType.PET_PHYFORCE_APT)
	vnValue[#vnValue + 1] = curVal
		
	curVal = pPetData:getAttribute(fire.pb.attr.AttrType.PET_MAGIC_APT)
	vnValue[#vnValue + 1] = curVal
	
	curVal = pPetData:getAttribute(fire.pb.attr.AttrType.PET_SPEED_APT)
	vnValue[#vnValue + 1] = curVal
	
	curVal = pPetData:getAttribute(fire.pb.attr.AttrType.PET_LIFE)
	vnValue[#vnValue + 1] = curVal
	curVal = math.floor(pPetData.growrate*1000) / 1000
	vnValue[#vnValue + 1] = curVal
    curVal = pPetData:getSkilllistlen()
	vnValue[#vnValue + 1] = curVal
	
	for nIndex=1,#vnValue do
		local strValue = tostring(vnValue[nIndex])
		self.vLabelValue[nIndex]:setText(strValue)
	end
		
end

--//==============================
function Taskcommitpetdialog:GetLayoutFileName()
	return "renwuwupinshangjiaocw_mtg.layout"
	      
end

function Taskcommitpetdialog.getInstance()
	if _instance == nil then
		_instance = Taskcommitpetdialog:new()
		_instance:OnCreate()
	end
	return _instance
end

function Taskcommitpetdialog.getInstanceNotCreate()
	return _instance
end

function Taskcommitpetdialog.getInstanceOrNot()
	return _instance
end


function Taskcommitpetdialog:new()
	local self = {}
	self = Dialog:new()
	setmetatable(self, Taskcommitpetdialog)
	self:ClearData()
	return self
end

function Taskcommitpetdialog:DestroyDialog()
	self:OnClose()
end

function Taskcommitpetdialog:ClearAllCell()
	for k,v in pairs(self.vCell) do 
		self.scrollPane:removeChildWindow(v)
		CEGUI.WindowManager:getSingleton():destroyWindow(v)
	end
	self.vCell = {}
end

function Taskcommitpetdialog:ClearData()
	self.nServiceId = -1
	self.nNpcKey = -1
	self.vLabelValue = {}
	self.nCurItemKey = -1
	self.vCell = {}
    self.delegateTarget = nil
    self.targetCallback= nil

end

function Taskcommitpetdialog:OnClose()
	self:ClearAllCell()
	self:ClearData()
	Dialog.OnClose(self)
	
	_instance = nil
end

return Taskcommitpetdialog

