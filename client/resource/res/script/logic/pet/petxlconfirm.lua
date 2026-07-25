require "utils.mhsdutils"
require "logic.dialog"


Petxlconfirm = {}
setmetatable(Petxlconfirm, Dialog)
Petxlconfirm.__index = Petxlconfirm

------------------- public: -----------------------------------
local _instance;

function Petxlconfirm:OnCreate()
    Dialog.OnCreate(self)
	local winMgr = CEGUI.WindowManager:getSingleton()

    --SetPositionOfWindowWithLabel(self:GetWindow())

    self.labelName = winMgr:getWindow("petximan/diban/text2") 
	local closeBtn = CEGUI.toPushButton(winMgr:getWindow("petximan/diban/close"))
	closeBtn:subscribeEvent("MouseClick",Petxlconfirm.clickClose,self)
    local btnCancel = CEGUI.toPushButton(winMgr:getWindow("petximan/diban/btn1")) 
	btnCancel:subscribeEvent("MouseClick",Petxlconfirm.clickClose,self)
    local confirmBtn = CEGUI.toPushButton(winMgr:getWindow("petximan/diban/btn2"))
	confirmBtn:subscribeEvent("MouseClick",Petxlconfirm.clickConfirm,self)
    self.wndItemCellBg = winMgr:getWindow("petximan/diban/jineng") 
    self:GetWindow():setRiseOnClickEnabled(false)

end

function Petxlconfirm:refreshSkill(nPetId)
--skillid
	local winMgr = CEGUI.WindowManager:getSingleton()

    local petTable = BeanConfigManager.getInstance():GetTableByName("pet.cpetattr"):getRecorder(nPetId)
    if not petTable then
        return
    end
    local vItemCell = {}
    local nSkillNum = petTable.skillid:size()
    for nIndex=0,nSkillNum-1 do
        local nSkillId = petTable.skillid[nIndex]
        local itemCell =  CEGUI.toItemCell(winMgr:createWindow("TaharezLook/ItemCell"))
        itemCell:setSize(CEGUI.UVector2(CEGUI.UDim(0,70), CEGUI.UDim(0,70)))
        itemCell:subscribeEvent("MouseClick", Petxlconfirm.clickItemCell, self)
        local skillicon = RoleSkillManager.GetSkillIconByID(nSkillId)
	    itemCell:SetImage(gGetIconManager():GetSkillIconByID(skillicon))

        itemCell.nSkillId = nSkillId
        itemCell:setID(nSkillId)
        vItemCell[#vItemCell +1] = itemCell
        self.wndItemCellBg:addChildWindow(itemCell)
       
    end
    self:refreshItemCellPos(vItemCell)

    local nNoBianyizi = 0
    if  petTable.kind ~= fire.pb.pet.PetTypeEnum.VARIATION then
        nNoBianyizi = 11401
    end
    local strNoBiaoyizi = require("utils.mhsdutils").get_resstring(nNoBianyizi)
 
    local strTypeColor = "ff8c5e2a"
    local strNameColor = "FF02972C"
    local strName = ""
    if petTable.kind ~= fire.pb.pet.PetTypeEnum.VARIATION  then
      strName = strNoBiaoyizi
      strName = "[colour=".."\'"..strTypeColor.."\'".."]"..strName
    end
    strName = strName.."[colour=".."\'"..strNameColor.."\'".."]"..petTable.name
    
    local strbuilder = StringBuilder:new()
	strbuilder:Set("parameter1", strName)
    local msg=strbuilder:GetString(MHSD_UTILS.get_resstring(11532))
    strbuilder:delete()

    self.labelName:setText(msg)

end

function Petxlconfirm:clickItemCell(args)
    local cell = CEGUI.toItemCell(CEGUI.toWindowEventArgs(args).window)
    local nSkillId = cell:getID()
	local dlg = PetSkillTipsDlg.getInstanceAndShow()
	dlg:showPetSkillTips(nSkillId, 0, 0)

    local pos = cell:GetScreenPosOfCenter()
	SetPositionOffset(dlg:GetWindow(), pos.x, pos.y, 0, 1)

end

function Petxlconfirm:getBeginPosX(nSkillNum,bgSize,itemSize,nSpaceX)
    
    local nBeginPosX = bgSize.width*0.5
    if nSkillNum==1 then
        nBeginPosX = bgSize.width*0.5 -(nSpaceX+itemSize.width)*0
    elseif nSkillNum==2 then
        nBeginPosX = bgSize.width*0.5-nSpaceX*0.5-itemSize.width*0.5 --bgSize.width*0.5-nSpaceX*0.5-itemSize.width*0.5
    elseif nSkillNum==3 then
        nBeginPosX = bgSize.width*0.5 -(nSpaceX+itemSize.width)*1 --bgSize.width*0.5-itemSize.width*0.5-nSpaceX-itemSize.width*0.5
    elseif nSkillNum==4 then
        nBeginPosX = bgSize.width*0.5-nSpaceX*0.5-itemSize.width*0.5-(nSpaceX+itemSize.width)*1 -- bgSize.width*0.5-nSpaceX*0.5-itemSize.width-nSpaceX-itemSize.width*0.5
    elseif nSkillNum==5 then
        nBeginPosX = bgSize.width*0.5 -(nSpaceX+itemSize.width)*2 --bgSize.width*0.5-itemSize.width*0.5-nSpaceX-itemSize.width*0.5 -(itemSize.width+nSpaceX)
    end
    return nBeginPosX

end


function Petxlconfirm:refreshItemCellPos(vItemCell)
    if #vItemCell <= 0 then
        return
    end
    local itemCellone = vItemCell[1]
    local bgSize = self.wndItemCellBg:getPixelSize()
    local itemSize = itemCellone:getPixelSize()
    local nSpaceX = 10
    local nSkillNum = #vItemCell
    local nBeginPosX = self:getBeginPosX(nSkillNum,bgSize,itemSize,nSpaceX)
    for nIndex=1,nSkillNum do
        local itemCell = vItemCell[nIndex]
        local nPosX = nBeginPosX +(itemSize.width+nSpaceX)*(nIndex-1)
        nPosX = nPosX - itemSize.width*0.5
        local nPosY = bgSize.height*0.5-itemSize.height*0.5
        local p = CEGUI.UVector2(CEGUI.UDim(0, nPosX), CEGUI.UDim(0, nPosY))

	    itemCell:setPosition(p)
    end

end


function Petxlconfirm:clickClose(e)
	Petxlconfirm.DestroyDialog()
end

function Petxlconfirm:clickConfirm(e)
    Petxlconfirm.DestroyDialog()
    
    local petLyDlg = require("logic.pet.petlianyaodlg").getInstanceNotCreate()
    if petLyDlg then
        petLyDlg:confirmToSendxl()
    end

end

function Petxlconfirm:new()
    local self = {}
    self = Dialog:new()
    setmetatable(self, Petxlconfirm)
    return self
end

--//==========================================
function Petxlconfirm.getInstance()
    if not _instance then
        _instance = Petxlconfirm:new()
        _instance:OnCreate()
    end
    return _instance
end

function Petxlconfirm.getInstanceOrNot()
	return _instance
end
	
function Petxlconfirm.getInstanceAndShow()
    if not _instance then
        _instance = Petxlconfirm:new()
        _instance:OnCreate()
	else
		_instance:SetVisible(true)
    end
    return _instance
end

function Petxlconfirm.getInstanceNotCreate()
    return _instance
end

function Petxlconfirm.DestroyDialog()
	if _instance then 
		_instance:OnClose()
		_instance = nil
	end
end

function Petxlconfirm:OnClose()
	Dialog.OnClose(self)
	_instance = nil
end

function Petxlconfirm.GetLayoutFileName()
   return "petximan.layout"
end

return Petxlconfirm
