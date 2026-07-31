
require "logic.dialog"

Spacerenqicell = {}
setmetatable(Spacerenqicell, Dialog)
Spacerenqicell.__index = Spacerenqicell


local nPrefix = 0
function Spacerenqicell.create(parent)
    local dlg = Spacerenqicell:new()
	dlg:OnCreate(parent)
	return dlg
end

function Spacerenqicell:clearData()
    self.mapCallBack = {}
    self.oneCellData = nil
end

function Spacerenqicell:new()
	local self = {}
	self = Dialog:new()
	setmetatable(self, Spacerenqicell)
    self:clearData()
	return self
end

function Spacerenqicell:OnClose()

    self:clearData()
    Dialog.OnClose(self)
end

function Spacerenqicell:OnCreate(parent)
    nPrefix = nPrefix + 1
    local strPrefix = tostring(nPrefix)
    Dialog.OnCreate(self,parent,strPrefix)

	local winMgr = CEGUI.WindowManager:getSingleton()

    self.itemCell = CEGUI.toItemCell(winMgr:getWindow(strPrefix.."kongjianrenqi/touxiang"))
    --self.labelSendTime = winMgr:getWindow(strPrefix.."kongjianzhuangtaicell/time")  
    self.labelRoleName = winMgr:getWindow(strPrefix.."kongjianrenqi/mingzi") 
    --self.richBoxSayContent = CEGUI.toRichEditbox(winMgr:getWindow(strPrefix.."kongjianzhuangtaicell/neirong")) 

    self.imageCai = winMgr:getWindow(strPrefix.."kongjianrenqi/tucaiyixia") 
    self.labelCai = winMgr:getWindow(strPrefix.."kongjianrenqi/caiyixia")

    self.imageGift = winMgr:getWindow(strPrefix.."kongjianrenqi/tuhuodeliwu") 
    self.labelGift = winMgr:getWindow(strPrefix.."kongjianrenqi/huodeliwu")

    

    self.btnSpace = CEGUI.toPushButton(winMgr:getWindow(strPrefix.."kongjianrenqi/btnkongjian"))
    self.btnSpace:subscribeEvent("MouseClick", Spacerenqicell.clickOpenSpace, self)

    --self:GetWindow():subscribeEvent("MouseClick", Spacerenqicell.clickBg, self)

    self.m_pMainFrame:setPosition(CEGUI.UVector2(CEGUI.UDim(0, 1), CEGUI.UDim(0, 0)))
    self.spaceManager = require("logic.space.spacemanager").getInstance()

    local bGetGift = false
    self:refreshImage(bGetGift)
end

function Spacerenqicell:refreshImage(bReceiveItem)
    if bReceiveItem then
        self.imageCai:setVisible(false)
        self.labelCai:setVisible(false)

        self.imageGift:setVisible(true)
        self.labelGift:setVisible(true)

    else
        self.imageCai:setVisible(true)
        self.labelCai:setVisible(true)

        self.imageGift:setVisible(false)
        self.labelGift:setVisible(false)
    end
end

function Spacerenqicell:GetLayoutFileName()
	return "kongjianrenqi.layout"
end

function Spacerenqicell:refreshLevel()
    local nLevel = self.oneCellData.nLevel
    self.itemCell:SetTextUnit(tostring(nLevel))
end


function Spacerenqicell:refreshOneCell(oneCellData)
    if not oneCellData then
        return
    end
    self.oneCellData = oneCellData
    local nMsgIndex = oneCellData.nMsgIndex
    local nShapeId = oneCellData.nShapeId
    local nUserLevel = oneCellData.nUserLevel
    local strUserName = oneCellData.strUserName
    local nLevel = oneCellData.nLevel

    self.itemCell:SetTextUnit(tostring(nLevel))
    self.nMsgIndex = nMsgIndex
    local shapeTable = BeanConfigManager.getInstance():GetTableByName("npc.cnpcshape"):getRecorder(nShapeId)
    if shapeTable and shapeTable.id ~= -1 then
         local image = gGetIconManager():GetImageByID(shapeTable.littleheadID)
         self.itemCell:SetImage(image)
    end
    
    self.labelRoleName:setText(strUserName)

end


function Spacerenqicell:clickOpenSpace(args)
    local nnRoleId = self.oneCellData.nnRoleId
    local spManager = getSpaceManager()
    local nRoleLevel = self.oneCellData.nLevel
    spManager:openSpace(nnRoleId,nRoleLevel)

    gGetFriendsManager():SetContactRole(nnRoleId, false)

end



return Spacerenqicell