
require "logic.dialog"

Spaceliuyancell = {}
setmetatable(Spaceliuyancell, Dialog)
Spaceliuyancell.__index = Spaceliuyancell

local nPrefix = 0
function Spaceliuyancell.create(parent)
    local dlg = Spaceliuyancell:new()
	dlg:OnCreate(parent)
	return dlg
end


Spaceliuyancell.eCallBackType = 
{
    clickBg =1,
    clickDel=2,
}

function Spaceliuyancell:clearData()
    self.mapCallBack = {}
end

function Spaceliuyancell:OnClose()
    self:clearData()
    Dialog.OnClose(self)
end

function Spaceliuyancell:new()
	local self = {}
	self = Dialog:new()
	setmetatable(self, Spaceliuyancell)
    self:clearData()
	return self
end

function Spaceliuyancell:OnCreate(parent)
    nPrefix = nPrefix + 1
    local strPrefix = tostring(nPrefix)
    Dialog.OnCreate(self,parent,strPrefix)

	local winMgr = CEGUI.WindowManager:getSingleton()
	--local layoutName = "kongjianzhuangtaicell.layout"
	--self.m_pMainFrame = winMgr:loadWindowLayout(layoutName)

    self.itemCell = CEGUI.toItemCell(winMgr:getWindow(strPrefix.."kongjianliwucell/touxiang"))
    self.labelSendTime = winMgr:getWindow(strPrefix.."kongjianliwucell/riqi")  
    self.labelRoleName = winMgr:getWindow(strPrefix.."kongjianliwucell/name") 

    self.richBoxSayContent = CEGUI.toRichEditbox(winMgr:getWindow(strPrefix.."kongjianliwucell/neirong")) 
    self.richBoxSayContent:setReadOnly(true)
    self.richBoxSayContent:getVertScrollbar():EnbalePanGuesture(false)
    self.richBoxSayContent:getVertScrollbar():setScrollPosition(0)

    self.imageItem = winMgr:getWindow(strPrefix.."kongjianliwucell/di/liwutubiao") --kongjianliwucell/di/liwutubiao
    self.labelGiftCount = winMgr:getWindow(strPrefix.."kongjianliwucell/di/number")  

    self.nodeItemNumBg = winMgr:getWindow(strPrefix.."kongjianliwucell/di")  

    --self.nodeInputBg = winMgr:getWindow(strPrefix.."kongjianzhuangtaicell/imputbg")
    --self.nodeSomeoneBg = winMgr:getWindow(strPrefix.."kongjianzhuangtaicell/diban")
    --self.richBoxSomeoneSay = CEGUI.toRichEditbox(winMgr:getWindow(strPrefix.."kongjianzhuangtaicell/diban/rich2")) 

    self.btnDel = CEGUI.toPushButton(winMgr:getWindow(strPrefix.."kongjianliwucell/btnshanchu"))
    self.btnDel:subscribeEvent("MouseClick", Spaceliuyancell.clickDel, self)


    self:GetWindow():subscribeEvent("MouseClick", Spaceliuyancell.clickBg, self)
    self.richBoxSayContent:subscribeEvent("MouseClick", Spaceliuyancell.clickBg, self)

    self.m_pMainFrame:setPosition(CEGUI.UVector2(CEGUI.UDim(0, 1), CEGUI.UDim(0, 0)))
    self.spaceManager = require("logic.space.spacemanager").getInstance()

    local nChildcount = self:GetWindow():getChildCount()
	for i = 0, nChildcount - 1 do
		local child = self:GetWindow():getChildAtIdx(i)
        if child ~= self.btnDel and child ~= self.richBoxSayContent then
		    child:setMousePassThroughEnabled(true)
        end
	end
    self.nOldBoxSize = self.richBoxSayContent:getPixelSize()
    self.nOldBgSize = self:GetWindow():getPixelSize()

end

function Spaceliuyancell:refreshDelBtnVisible(bVisible)
    self.btnDel:setVisible(bVisible)
end



function Spaceliuyancell:refreshLevel()
    local nLevel = self.oneCellData.nLevel
    self.itemCell:SetTextUnit(tostring(nLevel))
end

function Spaceliuyancell:refreshOneCell(oneLeftWord)
    if not oneLeftWord then
        return
    end
    self.oneCellData = oneLeftWord


    local nBbsId = oneLeftWord.nBbsId 
    --oneLeftWord.nnRoleId 
    --oneLeftWord.nStatus 
    local strContent = oneLeftWord.strContent 
    local strUserName = oneLeftWord.strUserName 
    local nLevel = oneLeftWord.nLevel 
    local nnSendTime = oneLeftWord.nnSendTime 
    local nShapeId = oneLeftWord.nShapeId 
    local nGiftType = oneLeftWord.nGiftType 
    local nToBbsId = oneLeftWord.nToBbsId 
    local nToRoleId = oneLeftWord.nToRoleId 
    local strToRoleName = oneLeftWord.strToRoleName 
    local nItemNum = oneLeftWord.nItemNum 

    local nnRoleId =  oneLeftWord.nnRoleId 
    local strUserName = oneLeftWord.strUserName

    ------------------------------
    local spaceManager = require("logic.space.spacemanager").getInstance()
    local shapeTable = BeanConfigManager.getInstance():GetTableByName("npc.cnpcshape"):getRecorder(nShapeId)
    if shapeTable and shapeTable.id ~= -1 then
         local image = gGetIconManager():GetImageByID(shapeTable.littleheadID)
         self.itemCell:SetImage(image)
    end
    self.itemCell:SetTextUnit(tostring(nLevel))

    local strTime = getSpaceManager():getSendTimeString(nnSendTime)
    self.labelSendTime:setText(strTime)
    self.labelRoleName:setText(strUserName)

    self.richBoxSayContent:Clear()
    local strUserNameLinkSend  = self.spaceManager:getUserNameLink(nnRoleId,strUserName)
    self.richBoxSayContent:AppendParseText(CEGUI.String(strUserNameLinkSend))

    local strTextColorSay = "c=\"ff02972c\""

    if nToRoleId ~= 0 and nToRoleId ~=nnRoleId then
        local strSayTozi = require("utils.mhsdutils").get_resstring(11536) 
        self.richBoxSayContent:AppendParseText(CEGUI.String(strSayTozi))

        local strUserNameLinkTarget  = self.spaceManager:getUserNameLink(nToRoleId,strToRoleName)
        self.richBoxSayContent:AppendParseText(CEGUI.String(strUserNameLinkTarget))
    end
    
    local strRoleSay = "" 
    local nIndex = string.find(strContent, "<T")
    local bHaveE = string.find(strContent, "<E")
	if nIndex or bHaveE then
		strRoleSay = strContent 
	else
        --11542 --<T t="$parameter1" c="ff02972c" ></T>
        local strContentzi = require("utils.mhsdutils").get_resstring(11542) 
        local sb = StringBuilder.new()
        sb:Set("parameter1",strContent)
        strContentzi = sb:GetString(strContentzi)
        sb:delete()
		strRoleSay = strContentzi
	end

    --spaceManager:getStringToRichContent(strRoleSay,strTextColorSay)
    self.richBoxSayContent:AppendParseText(CEGUI.String(strRoleSay) )
    self.richBoxSayContent:Refresh()

    if nItemNum >0 then
        self.nodeItemNumBg:setVisible(true)
        self.imageItem:setVisible(true)
        self.labelGiftCount:setText(tostring(nItemNum))
    else
        self.nodeItemNumBg:setVisible(false)
        self.imageItem:setVisible(false)
    end

    local nItemId = self.oneCellData.nItemId

    local itemTable = BeanConfigManager.getInstance():GetTableByName("item.citemattr"):getRecorder(nItemId)
    if itemTable then
        local strIconPath = gGetIconManager():GetImagePathByID(itemTable.icon):c_str()
        self.imageItem:setProperty("Image",strIconPath)
    end
    


    -------------------
    self:refreshSize()
end

function Spaceliuyancell:refreshSize()
    local nBoxWidth = self.nOldBoxSize.width
	local nFrameWidth = self.nOldBgSize.width

    local nAddHeight = self.richBoxSayContent:GetExtendSize().height - self.nOldBoxSize.height
    nAddHeight = nAddHeight > 0 and nAddHeight or 0

    nAddHeight = nAddHeight + 20
    local nNewFrameHeight =  self.nOldBgSize.height + nAddHeight
    local nNewBoxHeight = self.nOldBoxSize.height + nAddHeight

	--local nNewBoxHeight = self.nBoxHeightOld + nAddHeight
    self.richBoxSayContent:setSize(CEGUI.UVector2(CEGUI.UDim(0, nBoxWidth), CEGUI.UDim(0,nNewBoxHeight)))
    self:GetWindow():setSize(CEGUI.UVector2(CEGUI.UDim(0, nFrameWidth), CEGUI.UDim(0,nNewFrameHeight)))
end

function Spaceliuyancell:setDelegate(pTarget,callBackType,callBack)
    self.mapCallBack[callBackType] = {}
    self.mapCallBack[callBackType].pTarget = pTarget
    self.mapCallBack[callBackType].callBack = callBack
end

function Spaceliuyancell:callEvent(callType)
     local callBackData =  self.mapCallBack[callType]
    if not callBackData then
        return
    end
    if not callBackData.pTarget then
        return
    end
    callBackData.callBack(callBackData.pTarget,self)
end

function Spaceliuyancell:clickBg(args)
    self:callEvent(Spaceliuyancell.eCallBackType.clickBg)
end

function Spaceliuyancell:GetLayoutFileName()
	return "kongjianliwucell.layout"
end

function Spaceliuyancell:clickDel(args)
    self:callEvent(Spaceliuyancell.eCallBackType.clickDel)
end

return Spaceliuyancell