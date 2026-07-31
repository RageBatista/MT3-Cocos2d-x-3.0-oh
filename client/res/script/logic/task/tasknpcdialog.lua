require "logic.dialog"

Tasknpcdialog = {}
setmetatable(Tasknpcdialog, Dialog)
Tasknpcdialog.__index = Tasknpcdialog

local _instance
function Tasknpcdialog.getInstance()
	if not _instance then
		_instance = Tasknpcdialog:new()
		_instance:OnCreate()
	end
	return _instance
end


function Tasknpcdialog.getInstanceAndShow()
	if not _instance then
		_instance = Tasknpcdialog:new()
		_instance:OnCreate()
	else
		_instance:SetVisible(true)
	end
	return _instance
end

function Tasknpcdialog.getInstanceNotCreate()
	return _instance
end

function Tasknpcdialog.DestroyDialog()
	if _instance then
		if not _instance.m_bCloseIsHide then
			_instance:OnClose()
			_instance = nil
		else
			_instance:ToggleOpenClose()
		end
	end
end

function Tasknpcdialog.ToggleOpenClose()
	if not _instance then
		_instance = Tasknpcdialog:new()
		_instance:OnCreate()
	else
		if _instance:IsVisible() then
			_instance:SetVisible(false)
		else
			_instance:SetVisible(true)
		end
	end
end

function Tasknpcdialog.GetLayoutFileName()
	return "npcdialog.layout"
end

function Tasknpcdialog:new()
	local self = {}
	self = Dialog:new()
	setmetatable(self, Tasknpcdialog)
	return self
end

function Tasknpcdialog:OnClose()
	Dialog.OnClose(self)
	_instance = nil
end

Tasknpcdialog.eServiceId =
{
	stone =100018,
	xiayi =100019,
}

Tasknpcdialog.eType =
{
	renxing =1,
	commititem =2,
    commitpet =3
}

function Tasknpcdialog:OnCreate()
	local strPrefixName = "tasknpcdialog"
	print("strPrefixName="..strPrefixName)
	
	Dialog.OnCreate(self,nil,strPrefixName)
	local winMgr = CEGUI.WindowManager:getSingleton()

	
	self.richBoxChat = CEGUI.toRichEditbox(winMgr:getWindow(strPrefixName.."NpcDialog/RichEditBox"))
    self.npcTalkBoxHeight = self.richBoxChat:getPixelSize().height
	self.labelNpcName = winMgr:getWindow(strPrefixName.."NpcDialog/name")
	self.imageHead = winMgr:getWindow(strPrefixName.."NpcDialog/icon")
	self.richBoxBtn = CEGUI.toRichEditbox(winMgr:getWindow(strPrefixName.."NpcDialog/RichEditBox1")) --NpcDialog/RichEditBox1
	self.richBoxBtn:subscribeEvent("MouseClick", Tasknpcdialog.HandleMouseClicked,self);
	
	--self.richBoxBtn:SetTextBottomEdge(0.0f);
    self.richBoxBtn:SetBackGroundEnable(false);
    self.richBoxBtn:EnableClickSelectLine(true);
	self.richBoxBtn:SetLineSpace(36);
	
	--:subscribeEvent("MouseButtonUp", WorkshopDzNew.HandleSelLevelBtnClicked, self) 
	
	--NpcDialog/back/bg/text
	
	self.imageBgTop = winMgr:getWindow(strPrefixName.."NpcDialog/back/bg")

	--self.imageBgTop:setVisible(false)
	self.m_pMainFrame:setAlwaysOnTop(true)
	self.m_pMainFrame:activate()
	
	
	--local nBoxWidth = self.richBoxBtn:getPixelSize().width
	--local nFrameWidth = self:GetMainFrame():getPixelSize().width
	--local nAddHeight = self.richBoxBtn:GetExtendSize().height - self.nBoxHeightOld
	
	self.nBoxHeightOld = self.richBoxBtn:getPixelSize().height
	self.nImageBgTopHeightOld = self.imageBgTop:getPixelSize().height
	self.imageBgTopPosOld = self.imageBgTop:getPosition()
end

function Tasknpcdialog:HandleMouseClicked(e)

	LogInfo("Tasknpcdialog:HandleMouseClicked(e)")
	--[[
	const CEGUI::MouseEventArgs& MouseArgs = static_cast<const MouseEventArgs&>(e);
    CEGUI::RichEditbox* pBox=(CEGUI::RichEditbox*)(MouseArgs.window);
	CEGUI::RichEditboxComponent* component = pBox->GetComponentByPos(MouseArgs.position);
	--]]
	
	local mouseArgs = CEGUI.toMouseEventArgs(e)
	local pos = mouseArgs.position
	local clickWin = mouseArgs.window
	
	local component =  self.richBoxBtn:GetComponentByPos(pos);
	if not component then
        if self.richBoxBtn:isClickSelectLine() then
            component = self.richBoxBtn:GetLinkTextOnPos(pos)
        end
		--return 
	end

    if not component then

		return 
	end

    local nSelId = component:GetUserID()
	LogInfo("nSelId="..nSelId)

    local nServiceId =  self.nCurServiceId--component:GetUserID();
	LogInfo("Tasknpcdialog=nServiceId"..nServiceId)

    if self.eType == Tasknpcdialog.eType.renxing then
        
        local p1 = require "protodef.fire.pb.circletask.crenxingcircletask":new()
	    p1.serviceid = nServiceId
	    p1.moneytype = self:GetMoneyType(nSelId)
	    require "manager.luaprotocolmanager":send(p1)
    elseif self.eType == Tasknpcdialog.eType.commititem then
        local nNpcKey = self.nNpcKey
        require "manager.npcservicemanager".SendNpcService(nNpcKey, nServiceId)

    ------------------------------------------------------------
    elseif self.eType == Tasknpcdialog.eType.commitpet then
        local nNpcKey = self.nNpcKey
        local p = require "protodef.fire.pb.pet.cpetsell":new()
	    local nPetKey = component:GetUserID()
        p.petkey = nPetKey
	    require "manager.luaprotocolmanager":send(p)

    end

	Tasknpcdialog.DestroyDialog()
	
end
function Tasknpcdialog:RefreshNpcTalkBoxPosition()
	local y = (self.npcTalkBoxHeight - self.richBoxChat:GetExtendSize().height ) * 0.5
    if y<0 then
        y = 0
    end
    local pos = self.richBoxChat:getPosition()
    pos.y.offset = y
	self.richBoxChat:setPosition(pos)
end


function Tasknpcdialog:GetMoneyType(nServiceId)
	if Tasknpcdialog.eServiceId.stone == nServiceId then
		return fire.pb.game.MoneyType.MoneyType_HearthStone
	elseif  Tasknpcdialog.eServiceId.xiayi == nServiceId then
		return fire.pb.game.MoneyType.MoneyType_XiaYiVal
	end
end
--[[
<variable name="id" type="int" fromCol="任性次数" />
			<variable name="stonecost" type="int" fromCol="花费符石" />
			<variable name="xiayicost" type="int" fromCol="花费义值" />
--]]

--11205 使用$parameter1$符石任性
--
function Tasknpcdialog:RefreshNpcDialog_commititem(nNpcKey,nServiceId,strTitle)
    self.nCurServiceId = nServiceId
	--self.nCount = nCount
	self.nNpcKey = nNpcKey
    self.strTitle = strTitle
    self.eType = Tasknpcdialog.eType.commititem

    self.richBoxBtn:Clear()

   -- local nServiceId = vServiceId[nIndex]

	local strTitleCegui = CEGUI.String(strTitle)
	local color = CEGUI.ColourRect(CEGUI.PropertyHelper:stringToColour("ff8c5c2b"))
	local pTextLink = self.richBoxBtn:AppendLinkText(strTitleCegui,color)
    pTextLink:setTextHorizontalCenter(true)
	pTextLink:SetUserID(nServiceId)
	self.richBoxBtn:AppendBreak()

    self.richBoxBtn:Refresh()
	self:RefreshSize()
	self:RefreshNpcInfo()

end

function Tasknpcdialog:getAllPetYesheng(vPetKey)
   local nPeiKeyInBattle = gGetDataManager():GetBattlePetID()

    local nPetNum = MainPetDataManager.getInstance():GetPetNum()
	for nIndex = 1,nPetNum do
		local pPet = MainPetDataManager.getInstance():getPet(nIndex)
        if pPet then
            local nPetKey = pPet.key
            if pPet.kind == fire.pb.pet.PetTypeEnum.WILD and 
                nPeiKeyInBattle ~= nPetKey then --//类型，1野生，2宝宝，3变异，4神兽 PetTypeEnum: 
                vPetKey[#vPetKey +1] = nPetKey
            end
        end
	end

end

function Tasknpcdialog:RefreshNpcDialog_commitpet(nNpcKey,nServiceId)
    self.nCurServiceId = nServiceId
	--self.nCount = nCount
	self.nNpcKey = nNpcKey
    --self.strTitle = strTitle
    self.eType = Tasknpcdialog.eType.commitpet

   local vPetKey = {}
   self:getAllPetYesheng(vPetKey)

   if #vPetKey == 0 then
    --140481
    local strShowTip = require "utils.mhsdutils".get_msgtipstring(140481) 
	GetCTipsManager():AddMessageTip(strShowTip)
    Tasknpcdialog.DestroyDialog()
      return
   end

    self.richBoxBtn:Clear()

   -- local nServiceId = vServiceId[nIndex]
   

   for nIndex=1,#vPetKey do
		local nPetKey = vPetKey[nIndex]
		local pPet = MainPetDataManager.getInstance():FindMyPetByID(nPetKey)
        if pPet then
            local nPetId = pPet.baseid
            local strName = pPet.name
            local nLevel = pPet:getAttribute(fire.pb.attr.AttrType.LEVEL)

            local nLevelzi =  require "utils.mhsdutils".get_resstring(351)
            strName = strName.."  "..nLevel..nLevelzi
		    

            local strTitleCegui = CEGUI.String(strName)
	        local color = CEGUI.ColourRect(CEGUI.PropertyHelper:stringToColour("ff8c5c2b"))
	        local pTextLink = self.richBoxBtn:AppendLinkText(strTitleCegui,color)
            pTextLink:setTextHorizontalCenter(true)
	        pTextLink:SetUserID(nPetKey)
	        self.richBoxBtn:AppendBreak()

            self.btnHeight = pTextLink:getPixelSize().height
        end
		

    end

	

    -----------------------------------
    self.richBoxBtn:Refresh()
	self:RefreshSize()
	self:RefreshNpcInfo()

end



--[[
Tasknpcdialog.eType =
{
	renxing =1,
	commititem =2,
}

--]]
-- ren xing use only
function Tasknpcdialog:RefreshNpcDialog(nNpcKey,nCurServiceId,nCount)
    self.eType = Tasknpcdialog.eType.renxing
	self.nCurServiceId = nCurServiceId
	self.nCount = nCount
	self.nNpcKey = nNpcKey
    

	local vMoneyNum = {}
	vMoneyNum[1] = 0
	vMoneyNum[2] = 0
	
	local nCurCount = nCount + 1
	local needMoneyTable = BeanConfigManager.getInstance():GetTableByName("circletask.crenxingcirctaskcost"):getRecorder(nCurCount)
	if needMoneyTable and needMoneyTable.id ~= -1 then
		vMoneyNum[1] = needMoneyTable.stonecost
		vMoneyNum[2] = needMoneyTable.xiayicost
	end

		
	self.richBoxBtn:Clear()
	local vServiceId = {}
	vServiceId[1] = Tasknpcdialog.eServiceId.stone
	vServiceId[2] = Tasknpcdialog.eServiceId.xiayi
	
	local vstrTitle = {}
	vstrTitle[1] = require "utils.mhsdutils".get_resstring(11205)
	vstrTitle[2] = require "utils.mhsdutils".get_resstring(11206)
	
	--for k,nServiceId in pairs(Tasknpcdialog.vServiceId) do 
	for nIndex=1,#vServiceId do
		local nServiceId = vServiceId[nIndex]
		
		--local serviceTable = BeanConfigManager.getInstance():GetTableByName("npc.cnpcserverconfig"):getRecorder(nServiceId)
		--if serviceTable.id~=-1 then
			local strTitle = vstrTitle[nIndex]
			local nNeedMoneyNum = vMoneyNum[nIndex]
			--strTitle = strTitle..tostring(nNeedMoneyNum)
			
			local sb = StringBuilder.new()
			sb:Set("parameter1",tostring(nNeedMoneyNum))
			 strTitle = sb:GetString(strTitle)
			sb:delete()
			
			local strTitleCegui = CEGUI.String(strTitle)
			local color = CEGUI.ColourRect(CEGUI.PropertyHelper:stringToColour("ff8c5c2b"))
			local pTextLink = self.richBoxBtn:AppendLinkText(strTitleCegui,color)
			--pTextLink:setTextHorizontalCenter(true);
			pTextLink:SetUserID(nServiceId)
			self.richBoxBtn:AppendBreak()
		--end
	end
	self.richBoxBtn:Refresh()
	
	self:RefreshSize()
	self:RefreshNpcInfo()
end

function Tasknpcdialog:RefreshNpcInfo()
    local nNpcKey = self.nNpcKey
	if not nNpcKey then
		return
	end
	local pNpc = gGetScene():FindNpcByID(nNpcKey)
	if not pNpc then		
		return
	end
    local nNpcId = pNpc:GetNpcBaseID()
    local npcTable = BeanConfigManager.getInstance():GetTableByName("npc.cnpcconfig"):getRecorder(nNpcId)
    if not npcTable then
        return
    end

    local nChatNum = npcTable.chitchatidlist:size()
    local nRandIndex = math.random(0,nChatNum-1) 
    local nChatId = npcTable.chitchatidlist[nRandIndex]
    local chatTable = BeanConfigManager.getInstance():GetTableByName("npc.cnpcchat"):getRecorder(nChatId)
    if not chatTable then
        return
    end
    local strChat = chatTable.chat
	local nServiceId = self.nCurServiceId
    local serverInfo = BeanConfigManager.getInstance():GetTableByName("npc.cnpcserverconfig"):getRecorder(self.nCurServiceId)
    if serverInfo.servicedescribe ~= "" then
        strChat = serverInfo.servicedescribe
    end
	self.richBoxChat:Clear()
	--local strChat = serviceTable.servicedescribe
	local nIndex = string.find(strChat, "<T")
	if nIndex then
		self.richBoxChat:AppendParseText(CEGUI.String(strChat))
	else
		self.richBoxChat:AppendText(CEGUI.String(strChat))
	end
    self.richBoxChat:AppendBreak()
    self.richBoxChat:Refresh()
    self:RefreshNpcTalkBoxPosition()
	--end

	local strNpcName = pNpc:GetName()
	self.labelNpcName:setText(strNpcName)
	
	local npcCfg = BeanConfigManager.getInstance():GetTableByName("npc.cnpcconfig"):getRecorder(nNpcId)
	if not npcCfg then 
		return
	end
	
	local nNpcshapId = npcCfg.modelID
	local Shape = BeanConfigManager.getInstance():GetTableByName("npc.cnpcshape"):getRecorder(nNpcshapId)
	local strHeadPath = gGetIconManager():GetImagePathByID(Shape.headID):c_str()
	self.imageHead:setProperty("Image", strHeadPath)
	
	--[[
	local strNpcName = npcCfg.name
	self.labelNpcName:setText(strNpcName)
	
	local nNpcshapId = npcCfg.modelID
	local Shape = BeanConfigManager.getInstance():GetTableByName("npc.cnpcshape"):getRecorder(nNpcshapId)
	local strHeadPath = gGetIconManager():GetImagePathByID(Shape.headID):c_str()
	self.imageHead:setProperty("Image", strHeadPath)
	self.richBoxChat:Clear()
	self.richBoxChat:show()
	local nIndex = string.find(strChat, "<T")
	if nIndex then
		self.richBoxChat:AppendParseText(CEGUI.String(strChat))
	else
		self.richBoxChat:AppendText(CEGUI.String(strChat))
	end
	self.richBoxChat:Refresh()
	--]]
	
end
function Tasknpcdialog:RefreshSize()
	
	--function Commontiphelper.RefreshSize(self,bHaveBtn)
		
	--	self.nBoxHeightOld = self.richBoxBtn:getPixelSize().height
	--self.nImageBgTopHeightOld = self.imageBgTop:getPixelSize().heigh
	
	local nBoxWidth = self.richBoxBtn:getPixelSize().width
	local nFrameWidth = self.imageBgTop:getPixelSize().width
	local nAddHeight = self.richBoxBtn:GetExtendSize().height - self.nBoxHeightOld
    nAddHeight = nAddHeight > 0 and nAddHeight or 0
	nAddHeight = nAddHeight + 10
	
	local nNewFrameHeight =  self.nImageBgTopHeightOld+nAddHeight
	local nNewBoxHeight = self.nBoxHeightOld + nAddHeight
	

    local nLineCount = self.richBoxBtn:GetLineCount()
    if nLineCount > 6 then
        
        nNewBoxHeight = self.btnHeight * 6
        nNewFrameHeight = self.btnHeight * 6 + ( self.nImageBgTopHeightOld - self.nBoxHeightOld)

        nAddHeight = nNewFrameHeight -self.nImageBgTopHeightOld
    end

    ------------
	self.richBoxBtn:setSize(CEGUI.UVector2(
		CEGUI.UDim(0, nBoxWidth), 
		CEGUI.UDim(0,nNewBoxHeight)))
	
    self.imageBgTop:setSize(CEGUI.UVector2(CEGUI.UDim(0, nFrameWidth), CEGUI.UDim(0,nNewFrameHeight)))
	
	local btnPos = self.imageBgTopPosOld
	local nPosX = btnPos.x.offset
	local nPosY = btnPos.y.offset - nAddHeight
	self.imageBgTop:setPosition(CEGUI.UVector2(CEGUI.UDim(btnPos.x.scale,nPosX),CEGUI.UDim(btnPos.y.scale, nPosY)))

	
end

function Tasknpcdialog:ShowNpcChat(nNpcId,strChat)
	--[[
	local npcCfg = GameTable.npc.GetCNPCConfigTableInstance():getRecorder(nNpcId)
	if npcCfg.id == -1 then 
		return
	end
	local strNpcName = npcCfg.name
	self.labelNpcName:setText(strNpcName)
	
	local nNpcshapId = npcCfg.modelID
	local Shape = BeanConfigManager.getInstance():GetTableByName("npc.cnpcshape"):getRecorder(nNpcshapId)
	local strHeadPath = gGetIconManager():GetImagePathByID(Shape.headID):c_str()
	self.imageHead:setProperty("Image", strHeadPath)
	self.richBoxChat:Clear()
	self.richBoxChat:show()
	local nIndex = string.find(strChat, "<T")
	if nIndex then
		self.richBoxChat:AppendParseText(CEGUI.String(strChat))
	else
		self.richBoxChat:AppendText(CEGUI.String(strChat))
	end
	self.richBoxChat:Refresh()
	--]]
	
end

return Tasknpcdialog
