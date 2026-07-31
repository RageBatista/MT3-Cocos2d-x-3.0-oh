
require "utils.mhsdutils"

Commontiphelper = {}

Commontiphelper.nSpaceNormal = 5

function Commontiphelper.gongxiaoColor()
 local color = CEGUI.ColourRect(CEGUI.PropertyHelper:stringToColour("ffffff00"))----宝石功效名字
 return color
end

function Commontiphelper.defaultColor()
 local color = CEGUI.ColourRect(CEGUI.PropertyHelper:stringToColour("fffff2df"))
 return color
end



--[[
function Commontipdlg:RefreshPos()
	
	local nPosX,nPosY = Tipsdialog.GetPosXY()
	
	local nWidth = self:GetMainFrame():getPixelSize().width
	--local nHeight = self:GetMainFrame():getPixelSize().width
	local nRootWidth = CEGUI.System:getSingleton():getGUISheet():getPixelSize().width
	--local th = GetWindow():getPixelSize().height
	--local nRootHeight = CEGUI.System:getSingleton():getGUISheet():getPixelSize().height
	nPosX = nRootWidth*0.5 - nWidth -10
	self:GetMainFrame():setPosition(CEGUI.UVector2(CEGUI.UDim(0, nPosX), CEGUI.UDim(0, nPosY)))
	
end
--]]


--[[
	local tw = self:GetMainFrame():getPixelSize().width
	--local pw = CEGUI.System:getSingleton():getGUISheet():getPixelSize().width
	local th = self:GetMainFrame():getPixelSize().height
	local pw = CEGUI.System:getSingleton():getGUISheet():getPixelSize().width
	local ph = CEGUI.System:getSingleton():getGUISheet():getPixelSize().height
	if nX + tw > pw then
		nX = nX - tw
	end
	if nX<0 then
		nX = 0
	end
	if nY<0 then
		nY = 0
	end
	if nY + th > ph then
		if nY > th then
			nY = nY - th
		else
			nY = ph - th
		end
	end
	self:GetMainFrame():setPosition(CEGUI.UVector2(CEGUI.UDim(0, nX) , CEGUI.UDim(0, nY)))
--]]

function Commontiphelper.RefreshPosCorrect(mainFrame,nX,nY)
	local tw = mainFrame:getPixelSize().width
	local th = mainFrame:getPixelSize().height
	local pw = CEGUI.System:getSingleton():getGUISheet():getPixelSize().width
	local ph = CEGUI.System:getSingleton():getGUISheet():getPixelSize().height
	if nX + tw > pw then
		nX = nX - tw
	end
	if nX<0 then
		nX = 0
	end
	if nY<0 then
		nY = 0
	end
	if nY + th > ph then
		if nY > th then
			nY = nY - th
		else
			nY = ph - th
		end
	end
	mainFrame:setPosition(CEGUI.UVector2(CEGUI.UDim(0, nX) , CEGUI.UDim(0, nY)))
    return nX,nY
end


function Commontiphelper.getTipPosForBag(mainFrame)
	local tw = mainFrame:getPixelSize().width
	local th = mainFrame:getPixelSize().height
	local pw = CEGUI.System:getSingleton():getGUISheet():getPixelSize().width
	local ph = CEGUI.System:getSingleton():getGUISheet():getPixelSize().height
	
	local nX = pw * 0.5 - tw
	local nY = ph*0.5 - (th*0.5)
	return nX,nY
end

function Commontiphelper.getTipPosXY(mainFrame,bRight)
	local tw = mainFrame:getPixelSize().width
	local th = mainFrame:getPixelSize().height
	local pw = CEGUI.System:getSingleton():getGUISheet():getPixelSize().width
	local ph = CEGUI.System:getSingleton():getGUISheet():getPixelSize().height
	
    local nX = pw * 0.5 - tw
	local nY = ph*0.5 - (th*0.5)

    if bRight then
        nX = pw * 0.5
	    nY = ph*0.5 - (th*0.5)
    else
        nX = pw * 0.5 - tw
	    nY = ph*0.5 - (th*0.5)
    end

	return nX,nY

end



function Commontiphelper.HandlBtnClickComeFrom(commonDlg)

	local nItemId = commonDlg.nItemId

    if commonDlg.nComeFromItemId ~= -1 then
        nItemId = commonDlg.nComeFromItemId
    end
	local itemAttrCfg = BeanConfigManager.getInstance():GetTableByName("item.citemattr"):getRecorder(nItemId)
	if not itemAttrCfg then
		return
	end
	
	--[[
	if itemAttrCfg.vcomefrom:size()==0 then
		return
	end
	--]]
	
	local comefromtips = require "logic.workshop.comefromtips".getInstanceAndShow()
	comefromtips:RefreshWithItemId(nItemId)
	--//11029 
	--Tipsdialog.RefreshCometipsPosition(comefromtips)
	local sizeTip = commonDlg:GetMainFrame():getPixelSize()
	local tw = sizeTip.width
	local th = sizeTip.height
	local tPos = commonDlg:GetMainFrame():getPosition()
	local nComeWidth = comefromtips:GetMainFrame():getPixelSize().width
	local nComeHeight = comefromtips:GetMainFrame():getPixelSize().height
	local nRootWidth = CEGUI.System:getSingleton():getGUISheet():getPixelSize().width
	local nRootHeight = CEGUI.System:getSingleton():getGUISheet():getPixelSize().height
	
	local nX = nRootWidth* 0.5 - nComeWidth
	local nY = nRootHeight* 0.5 - th*0.5
	--Tipsdialog.RefreshPosForComeTips(nX-nComeWidth,nY)
	commonDlg:RefreshPosCorrect(nX,nY)
	
	tPos = commonDlg:GetMainFrame():getPosition()
	--skillUi:setPosition(CEGUI.UVector2(CEGUI.UDim(pos.x.scale,pos.x.offset+10),pos.y+skillUi:getPosition().y+attrUi:getPosition().y))
	local nComPosX = tPos.x.offset + tw 
	nComPosX = nComPosX + 20
	local nComPosY = tPos.y.offset + th 
	nComPosY = nComPosY - nComeHeight
	comefromtips:GetMainFrame():setPosition(CEGUI.UVector2(CEGUI.UDim(0, nComPosX), CEGUI.UDim(0, nComPosY)))

end
	
function Commontiphelper.RefreshSize(self,bHaveBtn)---更改函数-滑动窗口，换端的时候直接复制这个函数替换，跟随窗口高度
	local nBoxWidth = self.richBox:getPixelSize().width
	local nPaneWidth = self.ScrollablePane:getPixelSize().width
	local nFrameWidth = self:GetMainFrame():getPixelSize().width
	local nAddHeight = self.richBox:GetExtendSize().height - self.nBoxHeightOld
    nAddHeight = nAddHeight > 0 and nAddHeight or 0
	nAddHeight = nAddHeight + 10
	
	local nNewBoxHeight = self.nBoxHeightOld + nAddHeight
	if nAddHeight > 400 then
		nAddHeight2 = nAddHeight - 400
	else
		nAddHeight2 = 0
	end
	local nNewPaneHeight = self.nPaneHeightOld + nAddHeight - nAddHeight2
	local nNewFrameHeight = self.nFrameHeightOld + nAddHeight - nAddHeight2

	
	if bHaveBtn==false then
		nNewFrameHeight = nNewFrameHeight - 100 +20
	end
	print(nNewFrameHeight)
	self.richBox:setSize(CEGUI.UVector2(
		CEGUI.UDim(0, nBoxWidth), 
		CEGUI.UDim(0,nNewBoxHeight)))
	
	self.ScrollablePane:setSize(CEGUI.UVector2(
		CEGUI.UDim(0, nPaneWidth), 
		CEGUI.UDim(0,nNewPaneHeight)))
    self:GetMainFrame():setSize(CEGUI.UVector2(CEGUI.UDim(0, nFrameWidth), CEGUI.UDim(0,nNewFrameHeight)))
end
	
	
function Commontiphelper:ClickLeft_diuqi(e,commontip)
	LogInfo("Commontiphelper:ClickLeft_diuqi(e)")
	local nBagId = commontip.nBagId
	local nItemKey = commontip.nItemKey
	
	local roleItemManager = require("logic.item.roleitemmanager").getInstance()
	local pItem = roleItemManager:FindItemByBagAndThisID(nItemKey,nBagId)
	if not pItem then
		LogInfo("Commontiphelper:OnUseItem_task=error=nItemKey"..nItemKey)
		return 
	end

    local nFirstType = Commontiphelper.getItemFirstType(pItem:GetBaseObject().id)
    if nFirstType == eItemType_GEM then
require "logic.zhuanzhi.zhuanzhibaoshi33"
        ZhuanZhiBaoShi33.getInstanceAndShow()
          return 
    end

	roleItemManager:DestroyItem(true,pItem)
	
	--Commontipdlg.DestroyDialog()
end

function Commontiphelper:ClickLeft_alluse(e,commontip)
	local nBagId = commontip.nBagId
	local nItemKey = commontip.nItemKey
	
	local roleItemManager = require("logic.item.roleitemmanager").getInstance()
	local pItem = roleItemManager:FindItemByBagAndThisID(nItemKey,nBagId)
	if not pItem then
		LogInfo("Commontiphelper:OnUseItem_task=error=nItemKey"..nItemKey)
		return 
	end
	require "protodef.fire.pb.item.cappenditem"
	local useItem = CAppendItem.Create()
	useItem.keyinpack = pItem:GetThisID()
	useItem.idtype = 2
	useItem.id = gGetDataManager():GetMainCharacterID()
	useItem.isalluse=1
	LuaProtocolManager.getInstance():send(useItem)
	
end

Commontiphelper.eAddPropertyType = 
{
     LIVE_SKILL_ENHANCEMENT_TYPE_HP = 1,
     LIVE_SKILL_ENHANCEMENT_TYPE_PY_ATT = 2, 
     LIVE_SKILL_ENHANCEMENT_TYPE_IMAGE_ATT = 3,
     LIVE_SKILL_ENHANCEMENT_TYPE_PHY_DEF = 4, 
     LIVE_SKILL_ENHANCEMENT_TYPE_IMAGE_DEF = 5,
     LIVE_SKILL_ENHANCEMENT_TYPE_ANGER = 6,
     LIVE_SKILL_ENHANCEMENT_TYPE_HEAL =7,
     LIVE_SKILL_ENHANCEMENT_TYPE_CONTROL =8,
     LIVE_SKILL_ENHANCEMENT_TYPE_SPEED =9

}

function Commontiphelper.getPropertyTypeWithJobType(nAddPropertyType,vProperType)
    if nAddPropertyType==Commontiphelper.eAddPropertyType.LIVE_SKILL_ENHANCEMENT_TYPE_HP then
        vProperType[#vProperType + 1] = fire.pb.attr.AttrType.MAX_HP
    elseif nAddPropertyType==Commontiphelper.eAddPropertyType.LIVE_SKILL_ENHANCEMENT_TYPE_PY_ATT then
        vProperType[#vProperType + 1] = fire.pb.attr.AttrType.ATTACK
    elseif nAddPropertyType==Commontiphelper.eAddPropertyType.LIVE_SKILL_ENHANCEMENT_TYPE_IMAGE_ATT then
        vProperType[#vProperType + 1] = fire.pb.attr.AttrType.MAGIC_ATTACK
    elseif nAddPropertyType==Commontiphelper.eAddPropertyType.LIVE_SKILL_ENHANCEMENT_TYPE_PHY_DEF then
        vProperType[#vProperType + 1] = fire.pb.attr.AttrType.DEFEND
    elseif nAddPropertyType==Commontiphelper.eAddPropertyType.LIVE_SKILL_ENHANCEMENT_TYPE_IMAGE_DEF then
        vProperType[#vProperType + 1] = fire.pb.attr.AttrType.MAGIC_DEF
    elseif nAddPropertyType==Commontiphelper.eAddPropertyType.LIVE_SKILL_ENHANCEMENT_TYPE_ANGER then
        vProperType[#vProperType + 1] = fire.pb.attr.AttrType.MAX_SP

    elseif nAddPropertyType==Commontiphelper.eAddPropertyType.LIVE_SKILL_ENHANCEMENT_TYPE_HEAL then
        vProperType[#vProperType + 1] = fire.pb.attr.AttrType.MEDICAL
    elseif nAddPropertyType==Commontiphelper.eAddPropertyType.LIVE_SKILL_ENHANCEMENT_TYPE_CONTROL then
        vProperType[#vProperType + 1] = fire.pb.attr.AttrType.SEAL
        vProperType[#vProperType + 1] = fire.pb.attr.AttrType.UNSEAL
    elseif nAddPropertyType==Commontiphelper.eAddPropertyType.LIVE_SKILL_ENHANCEMENT_TYPE_SPEED then
        vProperType[#vProperType + 1] = fire.pb.attr.AttrType.SPEED
    end
end

function Commontiphelper.getEquipPosWithJobType(nAddPropertyType,vProperType)
     if nAddPropertyType==Commontiphelper.eAddPropertyType.LIVE_SKILL_ENHANCEMENT_TYPE_HP then
        vProperType[#vProperType + 1] = eEquipType_LORICAE
    elseif nAddPropertyType==Commontiphelper.eAddPropertyType.LIVE_SKILL_ENHANCEMENT_TYPE_PY_ATT then
        vProperType[#vProperType + 1] = eEquipType_ARMS
    elseif nAddPropertyType==Commontiphelper.eAddPropertyType.LIVE_SKILL_ENHANCEMENT_TYPE_IMAGE_ATT then
        vProperType[#vProperType + 1] = eEquipType_ADORN
    elseif nAddPropertyType==Commontiphelper.eAddPropertyType.LIVE_SKILL_ENHANCEMENT_TYPE_PHY_DEF then
        vProperType[#vProperType + 1] = eEquipType_TIRE
    elseif nAddPropertyType==Commontiphelper.eAddPropertyType.LIVE_SKILL_ENHANCEMENT_TYPE_IMAGE_DEF then
        vProperType[#vProperType + 1] = eEquipType_BOOT
    elseif nAddPropertyType==Commontiphelper.eAddPropertyType.LIVE_SKILL_ENHANCEMENT_TYPE_ANGER then
        vProperType[#vProperType + 1] = eEquipType_WAISTBAND

    elseif nAddPropertyType==Commontiphelper.eAddPropertyType.LIVE_SKILL_ENHANCEMENT_TYPE_HEAL then
        vProperType[#vProperType + 1] = eEquipType_ARMS
    elseif nAddPropertyType==Commontiphelper.eAddPropertyType.LIVE_SKILL_ENHANCEMENT_TYPE_CONTROL then
        vProperType[#vProperType + 1] = eEquipType_LORICAE
    elseif nAddPropertyType==Commontiphelper.eAddPropertyType.LIVE_SKILL_ENHANCEMENT_TYPE_SPEED then
        vProperType[#vProperType + 1] = eEquipType_BOOT
    end

end


function Commontiphelper.getPropertyIdWithType(nType)
    local vProperType = {}
    Commontiphelper.getPropertyTypeWithJobType(nType,vProperType)
    if #vProperType==0 then
        return -1
    end

    local nId = vProperType[1]
    if not nId then
        return -1
    end
    return nId
end

function Commontiphelper.getEquipPosWithType(nType)

   local vEquipPos = {}
   Commontiphelper.getEquipPosWithJobType(nType,vEquipPos)
    if #vEquipPos==0 then
        return -1
    end
    local nId = vEquipPos[1]
    if not nId then
        return -1
    end
    return nId
end

function Commontiphelper.isHaveFumo(nItemId,mapItemValue)
    local itemAttrCfg = BeanConfigManager.getInstance():GetTableByName("item.citemattr"):getRecorder(nItemId)
	if not itemAttrCfg then
		return false
	end

	local nItemType = itemAttrCfg.itemtypeid
    if nItemType ~= 358 then --358 fumo item
        return false
    end

    local zahuoTable = BeanConfigManager.getInstance():GetTableByName("item.cgroceryeffect"):getRecorder(nItemId)
    if not zahuoTable then
        return false
    end
    local nTypeId = tonumber( zahuoTable.tmpType)
    local nPropertyId = Commontiphelper.getPropertyIdWithType(nTypeId)
    if nPropertyId == -1 then
        return false
    end
    local nSecondType = Commontiphelper.getEquipPosWithType(nTypeId)

    local pEquipItem = Commontiphelper.getEquipItemWithSecondType(nSecondType)
    if not pEquipItem then
        return false
    end

    local pObj = pEquipItem:GetObject()

    local pEquipData = nil
    if pObj then
       pEquipData = pObj 
    end
    if not pEquipData then
        return false
    end

    local nFumoCount = pEquipData:getFumoCount()
    if nFumoCount <= 0 then
        return false
    end

    local mapItemValueTable = {}
    local fumoFormula = BeanConfigManager.getInstance():GetTableByName("item.cfumoeffectformula"):getRecorder(nItemId)
    if fumoFormula.npropertyid > 0 then
        mapItemValueTable[fumoFormula.npropertyid] = 0
    end
    if fumoFormula.npropertyid2 > 0 then
        mapItemValueTable[fumoFormula.npropertyid2] = 0
    end 
    
    local mapValue = {}
     
    local bHave = false
    Commontiphelper.getPropertyValue(pEquipData,mapValue)
    for nPropertyId,nValue in pairs(mapValue) do
 		for npId,pvalue in pairs(mapItemValueTable) do
            if npId==nPropertyId then
                mapItemValue[npId] = nValue
                bHave = true
            end
        end
    end
    

    return bHave

end

function Commontiphelper.isHaveFumoInTime(pEquipData,nIndexCount)
    local fumoData = pEquipData:getFumoDataWidthIndex(nIndexCount)
    local nFomoEndTime = 0 
    if fumoData then
          nFomoEndTime = fumoData.nFomoEndTime
    end
    if nFomoEndTime > 0 then
          local nServerTime = gGetServerTime() /1000
          local nLeftSecond = nFomoEndTime / 1000 - nServerTime
          if nLeftSecond>0 then
            return true
          end
     end   
     return false           
end

function Commontiphelper.getPropertyValue(pEquipData,mapValue)
    local nFumoCount = pEquipData:getFumoCount()
    if nFumoCount <= 0 then
        return
    end
     for nIndexCount=0,nFumoCount-1 do
        local vFumoKey = pEquipData:GetFumoIdWithIndex(nIndexCount)
        local bInTime =  Commontiphelper.isHaveFumoInTime(pEquipData,nIndexCount)
        if bInTime then
        for nIndex=0,vFumoKey:size()-1 do
            local nFumoId = vFumoKey[nIndex]
            local nFumoValue = pEquipData:GetFumoValueWithId(nIndexCount,nFumoId) 
            mapValue[nFumoId] = nFumoValue
        end
        end
    end
end

function  Commontiphelper.showConfirmFumo(nBagId,nItemKey,mapFumoValue)

	local roleItemManager = require("logic.item.roleitemmanager").getInstance()
    local pItem = roleItemManager:FindItemByBagAndThisID(nItemKey,nBagId)
	if not pItem then
		return 
	end

    local sb = StringBuilder.new()
    local nParameterCount = 0
    for npId,npValue in pairs(mapFumoValue) do
        nParameterCount = nParameterCount +1
        sb:Set("parameter"..nParameterCount,tostring(npValue))
    end
    local nTipId = 0
    if nParameterCount==1 then
        nTipId = 160320
    else
        nTipId = 150092
    end
    local strMsg =  require "utils.mhsdutils".get_msgtipstring(nTipId) --��ǰװ���Ѿ���ħ�ˣ���ֵΪ$parameter1$���Ƿ�Ҫ���¸�ħ
    strMsg = sb:GetString(strMsg)
    sb:delete()
    
    local msgManager = gGetMessageManager()
		
    Commontiphelper.nBagId_fumo = nBagId
    Commontiphelper.nItemKey_fumo = nItemKey

	gGetMessageManager():AddConfirmBox(eConfirmNormal,
		strMsg,
		Commontiphelper.clickConfirmBoxOk_fumo,
	  	Commontiphelper,
	  	Commontiphelper.clickConfirmBoxCancel_fumo,
	  	Commontiphelper)

end
function Commontiphelper.clickConfirmBoxOk_fumo()
   local bSendCancelEvent = false
	gGetMessageManager():CloseConfirmBox(eConfirmNormal,bSendCancelEvent)

    local nBagId = Commontiphelper.nBagId_fumo
	local nItemKey = Commontiphelper.nItemKey_fumo

	local roleItemManager = require("logic.item.roleitemmanager").getInstance()
	local pItem = roleItemManager:FindItemByBagAndThisID(nItemKey,nBagId)
	if not pItem then
		return 
	end

    roleItemManager:RightClickItem(pItem)
end

function Commontiphelper.clickConfirmBoxCancel_fumo()
   local bSendCancelEvent = false
	gGetMessageManager():CloseConfirmBox(eConfirmNormal,bSendCancelEvent)
end

function Commontiphelper.ClickUseItem(bagid, itemkey)
	LogInfo("Commontiphelper.ClickUseItem(bagid, itemkeyp)")
	
	local nBagId = bagid
	local nItemKey = itemkey
	
	local roleItemManager = require("logic.item.roleitemmanager").getInstance()

	local pItem = roleItemManager:FindItemByBagAndThisID(nItemKey,nBagId)
	if not pItem then
		LogInfo("Commontiphelper:ClickUseItem=error=nItemKey"..nItemKey)
		return 
	end

    if nBagId ==  fire.pb.item.BagTypes.QUEST then
        if GetTeamManager() and GetTeamManager():CanIMove()==false then
            local strDuiyuanmomovezi = require("utils.mhsdutils").get_msgtipstring(160193)
		    GetCTipsManager():AddMessageTip(strDuiyuanmomovezi)
		    return
	    end
    end
    local nItemId = pItem:GetBaseObject().id
    if nBagId == fire.pb.item.BagTypes.BAG then
        local mapFumoValue = {}
        local bShowFumo = Commontiphelper.isHaveFumo(nItemId,mapFumoValue)
        if bShowFumo == true then
            Commontiphelper.showConfirmFumo(nBagId,nItemKey,mapFumoValue)
            return
        end

    end

    if nBagId == fire.pb.item.BagTypes.EQUIP then
        roleItemManager:DownEquip(nItemKey) 
    else
        roleItemManager:RightClickItem(pItem)
    end
    
end




function Commontiphelper.RefreshRichBox(richBox,nItemId,pObj,remainOldText,bCompareEquip)
	if not remainOldText then
	    richBox:Clear()
    end

	--//=====================================
	local itemAttrCfg = BeanConfigManager.getInstance():GetTableByName("item.citemattr"):getRecorder(nItemId)
	if not itemAttrCfg then
		LogInfo(" Commontipdlg:RefreshItem=error=nItemId"..nItemId)
		return false
	end
	local nItemType = itemAttrCfg.itemtypeid

	local nFirstType = require "utils.mhsdutils".GetItemFirstType(nItemType) --GetItemFirstType
	LogInfo(" Commontipdlg:RefreshItem=nFirstType="..nFirstType)
	--//=====================================
	local bLuaHandleSuccess = false
	--//===================================== --chongwu wu pin
	if nFirstType==eItemType_PETITEM then
		bLuaHandleSuccess = require "logic.tips.petitemtipmaker".makeTip(richBox,nItemId,pObj)
    elseif nFirstType == eItemType_PETEQUIPITEM then
        bLuaHandleSuccess = debugrequire("logic.tips.petequipitemtipmaker").makeTip(richBox, nItemId, pObj)
	--//===================================== --shi wu
	elseif nFirstType==eItemType_FOOD then
		bLuaHandleSuccess = require "logic.tips.foodtipmaker".makeTip(richBox,nItemId,pObj)
	--//===================================== --yao pin
	elseif nFirstType==eItemType_DRUG then
		bLuaHandleSuccess = require "logic.tips.drugtipmaker".makeTip(richBox,nItemId,pObj)
		--return false
	--//===================================== --an qi
	elseif nFirstType==eItemType_DIMARM then
		return false
	--//===================================== --bao shi
	elseif nFirstType==eItemType_GEM then
		bLuaHandleSuccess = require "logic.tips.gemtipmaker".makeTip(richBox,nItemId,pObj)
	--//===================================== --za huo
	elseif nFirstType==eItemType_GROCERY then
		bLuaHandleSuccess = require "logic.tips.grocerytipmaker".makeTip(richBox,nItemId,pObj)
	--//=====================================
	elseif nFirstType==eItemType_EQUIP_RELATIVE then
		return false
	--//=====================================
	elseif nFirstType==eItemType_EQUIP then
        Commontiphelper.makeTipBox_equip(richBox,nItemId,pObj,bCompareEquip)
        --Equiptipmaker.makeTip(richBox,nItemId,pObj,nItemIdInBody,pObjInBody)
	--//===================================== --ren wu wu pin
	elseif nFirstType==eItemType_TASKITEM then
		bLuaHandleSuccess = require "logic.tips.tasktipmaker".makeTip(richBox,nItemId,pObj)
	--//=====================================
	end
	
	richBox:Refresh()
	if richBox:GetLineCount() > 0 then
        richBox:SetLineSpace(-10);
		richBox:AppendText(CEGUI.String(" ") )
		richBox:AppendBreak()
	end
	
	local strDes = itemAttrCfg.destribe
	if Commontiphelper.nPetEquipItemTypeId == nItemType then
    richBox:SetLineSpace(Commontiphelper.nSpaceNormal);
	Commontiphelper.appendText(richBox,strDes)
	richBox:AppendBreak()
	if itemAttrCfg.itemtypeid == 4678 then
		richBox:AppendBreak() 
		richBox:AppendBreak() 
		richBox:AppendBreak() 
		local strDes = 	require "utils.mhsdutils".get_resstring(11695)
		Commontiphelper.appendText(richBox,strDes)
		richBox:AppendBreak() 
	end
    ------------------------
    	end
    richBox:SetLineSpace(Commontiphelper.nSpaceNormal);
    Commontiphelper.appendText(richBox, strDes)
    richBox:AppendBreak()
    ------------------------

    local bBind = false  --itemAttrCfg.bBind --true 

    local nBagId = -1
    local nItemKey = -1

    if pObj then
        nBagId = pObj.loc.tableType
        nItemKey = pObj.data.key
	    local roleItemManager = require("logic.item.roleitemmanager").getInstance()
        local roleItem = roleItemManager:FindItemByBagAndThisID(nItemKey, nBagId)
        if roleItem then
             bBind = roleItem:isBind()
        end
    end


    if bBind==true then
        --itemCell:SetCornerImageAtPos("common_equip", "suo", 1, 0.5)
        --richBox:Refresh()
        --richBox:SetLineSpace(10); --wangbin test
        local strBind = require "utils.mhsdutils".get_resstring(11350)
        Commontiphelper.appendText(richBox,strBind)
        richBox:AppendBreak()
    end
    ------------------------
    Commontiphelper.checkOnSaleShowText(richBox,pObj)
	richBox:Refresh()
	richBox:HandleTop()
	
end

function Commontiphelper.GetLeftTimeString(seconds)
    local strTime = ""

    local strDayzi = require "utils.mhsdutils".get_resstring(2164) --�� 
    local strHourzi = require "utils.mhsdutils".get_resstring(2165)  --Сʱ
    local strMinutezi = require "utils.mhsdutils".get_resstring(499) --����
    local strSecondzi = require "utils.mhsdutils".get_resstring(10015) --��

    local nDay = math.floor(seconds/(3600*24))
    if nDay > 0 then
        strTime = tostring(nDay)..strDayzi
        return strTime
    end

    local nHour = math.floor(seconds/3600)
    if nHour > 0 then
        strTime = tostring(nHour)..strHourzi
        return strTime
    end

    local nMin = math.floor(seconds/60)
    if nMin > 0 then
         strTime = tostring(nMin)..strMinutezi
         return strTime
    end

    seconds = math.floor(seconds)
    strTime = tostring(seconds)..strSecondzi
     return strTime

end


function Commontiphelper.checkOnSaleShowText(richBox,pObj)
    
    local nBagId = -1
    local nItemKey = -1
    if not pObj then
        return
    end
    nBagId = pObj.loc.tableType
    nItemKey = pObj.data.key
	local roleItemManager = require("logic.item.roleitemmanager").getInstance()
    local roleItem = roleItemManager:FindItemByBagAndThisID(nItemKey, nBagId)
    if not roleItem then
        return
    end
  
    if pObj.data.markettime <= 0 then
        return
    end

    local strTextzi = require "utils.mhsdutils".get_resstring(11367)
    local nTimeEnd = pObj.data.markettime
    local nServerTime = gGetServerTime() /1000
    local nLeftSecond = nTimeEnd / 1000 - nServerTime
    if nLeftSecond <= 0 then
        return
    end
    
    local strTimeStr = Commontiphelper.GetLeftTimeString(nLeftSecond)
    local sb = StringBuilder.new()
	sb:Set("parameter1", strTimeStr)
	sb:delete()
    strTextzi = sb:GetString(strTextzi)
    Commontiphelper.appendText(richBox,strTextzi)
    richBox:AppendBreak()
    
   
end

function Commontiphelper.makeTipBox_equip(richBox,nItemId,pObj,bCompareEquip)
    local nItemIdInBody = -1
    local pObjInBody = nil

    if bCompareEquip==true then
        
        local pItemInBody = require("logic.tips.commontiphelper").getEquipInBodySameComponent(nItemId)
        if pItemInBody then
             nItemIdInBody = pItemInBody:GetBaseObject().id
             pObjInBody = pItemInBody:GetObject()
        end

    end
	require("logic.tips.equiptipmaker").makeTip(richBox,nItemId,pObj,nItemIdInBody,pObjInBody) 

end

function Commontiphelper.appendText(richBox,strChat)
	
	local nIndex = string.find(strChat, "<T")
	if nIndex then
		richBox:AppendParseText(CEGUI.String(strChat))
	else
        local defaultColor = nil
        local colorStr = richBox:GetColourString():c_str()
        if colorStr == "FFFF0000" then
            --fff2df 
            defaultColor = Commontiphelper.defaultColor()	        
        else
            defaultColor = CEGUI.ColourRect(CEGUI.PropertyHelper:stringToColour(colorStr))
        end
        richBox:AppendText(CEGUI.String(strChat),defaultColor)
	end
end



function Commontiphelper.getFoodQuality(pObj)
	local nQuality = -1
	local pFoodData = nil
	if pObj then
		pFoodData = pObj
	end
	if pFoodData then
		nQuality = pFoodData.qualiaty
	else
		LogInfo("Foodtipmaker=error=pFoodData=nil")
	end
	LogInfo("Foodtipmaker.makeTip_normal(commonTip,nItemId,pObj)=nQuality="..nQuality)
	--//=========================
	return nQuality
end


function Commontiphelper.getDrugQuality(pObj)
	local nQuality = -1
	local pDrugData = nil
	if pObj then
		pDrugData = pObj
	end
	if pDrugData then
		nQuality = pDrugData.qualiaty
	end
	return nQuality
	--[[
	--//===================================
	if nQuality >0 then
		local strPinZhizi = MHSD_UTILS.get_resstring(11039)
		commonTip.labelLevelTitle:setText(strPinZhizi)
		commonTip.labelLevel:setText(tostring(nQuality))
		--]]
end

Commontiphelper.nPetEquipItemTypeId = 54

Commontiphelper.nCangBaoTuTypeId = 118
Commontiphelper.nTypeIdCangBaoTuGaoJi = 198


Commontiphelper.nHeroItemTypeId = 518
Commontiphelper.nPetItemTypeId = 534

--show level
Commontiphelper.nDaZaoCaiLiaoTypeId = 422 
Commontiphelper.nDuanZaoShi = 310
Commontiphelper.nCaiFengRanLiao = 326
Commontiphelper.nLianJinRongJi = 342
Commontiphelper.nLinShiFuTypeId = 358 --��ʱ��  server level



function Commontiphelper.getCangBaoTuTitle(nItemId,pObj)
	local strResult1 = ""
	local strResult2 = ""
	
	local nMapId = -1
	local nPosX = -1
	local nPosY = -1
	
	local pGroceryData = nil
	if pObj then
		pGroceryData = pObj
	end
	if pGroceryData then
		nMapId = pGroceryData.mapID
		nPosX = pGroceryData.x
		nPosY = pGroceryData.y
	end
	
	local strZuoBiaozi = MHSD_UTILS.get_resstring(11040)
	
	local strMapName = ""
	local mapCfg = BeanConfigManager.getInstance():GetTableByName("map.cmapconfig"):getRecorder(nMapId)
	if mapCfg then
		strMapName = mapCfg.mapName
	end
	
	local strZuoBiaoXYzi = MHSD_UTILS.get_resstring(11047)
	
	local sb = StringBuilder.new()
	sb:Set("parameter1",tostring(nPosX) )
	sb:Set("parameter2",tostring(nPosY) )
	strZuoBiaoXYzi = sb:GetString(strZuoBiaoXYzi)
	local strAll = strMapName..strZuoBiaoXYzi
	sb:delete()
	
	strResult1 = strZuoBiaozi
	strResult2 = strAll
    if nPosX == -1 then
        --2461
        strResult2 = MHSD_UTILS.get_resstring(2461)
    end
	return strResult1,strResult2
end

function Commontiphelper.getTitleBottomForGrocery(nItemId,pObj)
	local strResult1 = ""
	local strResult2 = ""
	local itemAttrCfg = BeanConfigManager.getInstance():GetTableByName("item.citemattr"):getRecorder(nItemId)
	if not itemAttrCfg then
		return false
	end
	local nItemType = itemAttrCfg.itemtypeid
	if  Commontiphelper.nDaZaoCaiLiaoTypeId == nItemType or
		Commontiphelper.nDuanZaoShi == nItemType or
		Commontiphelper.nCaiFengRanLiao == nItemType or
		Commontiphelper.nLianJinRongJi == nItemType 
		 then
		strResult1 = MHSD_UTILS.get_resstring(1)
		strResult2 = tostring(itemAttrCfg.level)
		return true,strResult1,strResult2
    --==============================================
    elseif Commontiphelper.nLinShiFuTypeId == nItemType then

        local pGroceryData = nil
	    if pObj then
		    pGroceryData = pObj
	    end
        local nLevel = itemAttrCfg.level
	    if pGroceryData then
		    nLevel = pGroceryData.nLevel
	    end

        strResult1 = MHSD_UTILS.get_resstring(1)
		strResult2 = tostring(nLevel)
		return true,strResult1,strResult2

	elseif Commontiphelper.nCangBaoTuTypeId == nItemType or 
		   Commontiphelper.nTypeIdCangBaoTuGaoJi == nItemType then
		strResult1,strResult2 = Commontiphelper.getCangBaoTuTitle(nItemId,pObj)
		return true,strResult1,strResult2
	end
	return false
end

function Commontiphelper.getItemQuality(pRoleItem)
    local nQuality = 0
    if not pRoleItem then
        return nQuality
    end
    local nItemId = pRoleItem:GetBaseObject().id
    local pObj = pRoleItem:GetObject()
    if not pObj then
        return nQuality
    end

    local itemAttrCfg = BeanConfigManager.getInstance():GetTableByName("item.citemattr"):getRecorder(nItemId)
	if not itemAttrCfg then
		return nQuality
	end
    local nItemType = itemAttrCfg.itemtypeid
    local nFirstType = require "utils.mhsdutils".GetItemFirstType(nItemType)
	
    if nFirstType==eItemType_FOOD then
		 nQuality = require("logic.tips.commontiphelper").getFoodQuality(pObj)
		if nQuality > 0 then
			return nQuality
		end
	--//===================================== --yao pin
	elseif nFirstType==eItemType_DRUG then
		 nQuality = require("logic.tips.commontiphelper").getDrugQuality(pObj)
		if nQuality > 0 then
			return nQuality
		end
    end
    nQuality = itemAttrCfg.nquality
    return nQuality
end

function Commontiphelper.getStringForBottomLabel(nItemId,pObj)
	
	local strResult1 = ""
	local strResult2 = ""
	local itemAttrCfg = BeanConfigManager.getInstance():GetTableByName("item.citemattr"):getRecorder(nItemId)
	if not itemAttrCfg then
		return nil
	end
	local nItemType = itemAttrCfg.itemtypeid
	--local itemTypeTable = BeanConfigManager.getInstance():GetTableByName("item.citemtype"):getRecorder(nItemType)
	--if not itemTypeTable then
	--	LogInfo("Commontiphelper:RefreshNormalInfo=error=self.itemTypeTable"..itemTypeTable)
	--	return nil
	--end
	local strLevelzi = MHSD_UTILS.get_resstring(1) --deng ji

	if itemAttrCfg.needLevel>1 then
		local strYaoQiuzi = MHSD_UTILS.get_resstring(11033)
		local strNeedLevel =  MHSD_UTILS.get_resstring(11048) --parameter1 �������
		
		local sb = StringBuilder.new()
		sb:Set("parameter1",tostring(itemAttrCfg.needLevel) )
		strNeedLevel = sb:GetString(strNeedLevel)
		sb:delete()
		
		strResult1 = strYaoQiuzi
		strResult2 = strNeedLevel
		--return strYaoQiuzi,strNeedLevel
		
	else
		local strGongNengzi = MHSD_UTILS.get_resstring(11032) 
		local strEffectDes = itemAttrCfg.effectdes
		--return strGongNengzi,strResult
		strResult1 = strGongNengzi
		strResult2 = strEffectDes
	end
	
	local nFirstType = require "utils.mhsdutils".GetItemFirstType(nItemType)
	if nFirstType==eItemType_PETITEM then
	--//===================================== --shi wu
	elseif nFirstType==eItemType_FOOD then
		local nQuality = Commontiphelper.getFoodQuality(pObj)
		if nQuality > 0 then
			local strPinZhizi = MHSD_UTILS.get_resstring(11039)
			strResult1 = strPinZhizi
			strResult2 = tostring(nQuality)
		end
	--//===================================== --yao pin
	elseif nFirstType==eItemType_DRUG then
		local nQuality = Commontiphelper.getDrugQuality(pObj)
		if nQuality and nQuality > 0 then
			local strPinZhizi = MHSD_UTILS.get_resstring(11039)
			strResult1 = strPinZhizi
			strResult2 = tostring(nQuality)
		end
	--//===================================== --an qi
	elseif nFirstType==eItemType_DIMARM then
		--return false
	--//===================================== --bao shi---------宝石
	elseif nFirstType==eItemType_GEM then
		local gemconfig = BeanConfigManager.getInstance():GetTableByName("item.cgemeffect"):getRecorder(nItemId)
		if gemconfig then
			local strXiaoGuozi = gemconfig.inlaypos---inlaypos---MHSD_UTILS.get_resstring(7203) --Ч��:----更改宝石类型
			local strEffect = gemconfig.inlayeffect---inlaypos
			strResult2 = strXiaoGuozi
			strResult1 = strEffect
		end
	--//===================================== --za huo
	elseif nFirstType==eItemType_GROCERY then
	    local bSucc,str1,str2 = Commontiphelper.getTitleBottomForGrocery(nItemId,pObj)
		if bSucc then
			strResult1 = str1
			strResult2 = str2
		end
	--//=====================================
	elseif nFirstType==eItemType_EQUIP_RELATIVE then
	--//=====================================
	elseif nFirstType==eItemType_EQUIP then
		strResult1 = strLevelzi
		strResult2 = tostring(itemAttrCfg.needLevel)--------装备等级显示
	--//===================================== --ren wu wu pin
	elseif nFirstType==eItemType_TASKITEM then
	--//=====================================
	end
	return strResult1,strResult2
end


function Commontiphelper.getItemFirstType(nItemId)
    local itemAttrCfg = BeanConfigManager.getInstance():GetTableByName("item.citemattr"):getRecorder(nItemId)
	if not itemAttrCfg then
		return -1
	end
	local nItemType = itemAttrCfg.itemtypeid
	local nFirstType = require("utils.mhsdutils").GetItemFirstType(nItemType)
    return nFirstType
end

function Commontiphelper.getItemSecondType(nItemId)
    local itemAttrCfg = BeanConfigManager.getInstance():GetTableByName("item.citemattr"):getRecorder(nItemId)
	if not itemAttrCfg then
		return -1
	end
	local nItemType = itemAttrCfg.itemtypeid
	local nSecondType = require("utils.mhsdutils").GetItemSecondType(nItemType)
    return nSecondType
end


function Commontiphelper.getEquipInBodySameComponent(nItemId)------应该是装备

    local nFirstType = Commontiphelper.getItemFirstType(nItemId)
    if nFirstType ~= eItemType_EQUIP then
        return
    end

    local nSecondType = Commontiphelper.getItemSecondType(nItemId)

	local roleItemManager = require("logic.item.roleitemmanager").getInstance()
	local vItemKeyAll = roleItemManager:GetItemKeyListByBag(fire.pb.item.BagTypes.EQUIP)
	for i = 0, vItemKeyAll:size() - 1 do
		local nItemKey = vItemKeyAll[i]
		local pRoleItem = roleItemManager:FindItemByBagAndThisID(nItemKey, fire.pb.item.BagTypes.EQUIP)
		if pRoleItem then
			local nTableId = pRoleItem:GetObjectID()
            if pRoleItem:GetSecondType() == nSecondType then
                return pRoleItem
            end
			--if nTableId == nItemId then
			--	vItemKey[#vItemKey + 1] = nItemKey
			--end
		end
	end

    return nil

end


function Commontiphelper.showItemTip(nItemId,pObj,bCompareEquip,bShowBottomBtn,nPosX,nPosY)
    local commontip = require("logic.tips.commontipdlg").getInstanceAndShow()
    
    commontip:RefreshItemWithObjectNormal(nItemId,pObj,nPosX,nPosY,bCompareEquip)

	local bHaveBtn = bShowBottomBtn
	commontip:RefreshSize(bHaveBtn)

    --=======================================
    local nX1 = nPosX
    local nY1 = nPosY
    if bCompareEquip == true then
         local bRight = true
        local mainFrame = commontip:GetMainFrame()
         --Commontiphelper.getTipPosXY(mainFrame,bRight)
	    nX1,nY1 = require("logic.tips.commontiphelper").getTipPosXY(mainFrame,bRight)
	    commontip:RefreshPosCorrect(nX1,nY1)
    end

      --=======================================
      --compare
    local pItemInBody = require("logic.tips.commontiphelper").getEquipInBodySameComponent(nItemId)
    
     if  bCompareEquip == true and 
         pItemInBody
     then

        local nItemId2 = -1
        local pObj2 = nil

        nItemId2 = pItemInBody:GetBaseObject().id
        pObj2 = pItemInBody:GetObject()

        local compareDlg = require("logic.tips.equipcomparetipdlg").getInstanceAndShow()
        local mainFrame2 = compareDlg:GetMainFrame()
        local bRight2 = false
        local nCellPosX2,nCellPosY2 =  require("logic.tips.commontiphelper").getTipPosXY(mainFrame2,bRight2) 
        compareDlg:RefreshItem(nItemId2,pObj2,nCellPosX2,nCellPosY2)
       
        --compareDlg:RefreshPosCorrect(nCellPosX2,nCellPosY2)

        --=====================================
        --compare pos
         nCellPosX2,nCellPosY2 = require("logic.tips.commontiphelper").getTipPosXY(mainFrame2,bRight2)
         local nPosY2 = 0
         if nCellPosY2 < nY1 then
            nPosY2 = nCellPosY2
         else
            nPosY2 = nY1
         end
         compareDlg:RefreshPosCorrect(nCellPosX2,nPosY2)

    end

    if bShowBottomBtn==true then
         commontip:RefreshLeftBtn()
         commontip:refreshUseBtn()
    else
        commontip:setAllBottomVisible(false)
    end
   
    return commontip
end

function Commontiphelper.getEquipItemWithSecondType(nSecondType)
	local roleItemManager = require("logic.item.roleitemmanager").getInstance()
    local vItemKeyAll = roleItemManager:GetItemKeyListByBag(fire.pb.item.BagTypes.EQUIP)
	for i = 0, vItemKeyAll:size() - 1 do
		local nItemKey = vItemKeyAll[i]
		local pRoleItem = roleItemManager:FindItemByBagAndThisID(nItemKey, fire.pb.item.BagTypes.EQUIP)
		if pRoleItem then
			local nTableId = pRoleItem:GetObjectID()
            if pRoleItem:GetSecondType() == nSecondType then
                return pRoleItem
            end
			
		end
	end
    return nil
end

--��Ʒ����ʾ���֣��ȼ�/Ʒ��
function Commontiphelper.getItemLevelValue(nItemId,pObj)
    local itemAttrCfg = BeanConfigManager.getInstance():GetTableByName("item.citemattr"):getRecorder(nItemId)
	if not itemAttrCfg then
		return 0
	end

    local nItemType = itemAttrCfg.itemtypeid
    local nFirstType = require "utils.mhsdutils".GetItemFirstType(nItemType)

    if nFirstType == eItemType_FOOD then
        local pFoodData = pObj
        return (pFoodData and pFoodData.qualiaty or itemAttrCfg.level)
    end

    if nFirstType==eItemType_DRUG then
        local pDrugData = pObj
        return (pDrugData and pDrugData.qualiaty or itemAttrCfg.level)
    end

    if nFirstType==eItemType_GROCERY then
        if Commontiphelper.nLinShiFuTypeId == nItemType then
            local pGroceryData = pObj
            return (pGroceryData and pGroceryData.nLevel or itemAttrCfg.level)
        end
    end

    return itemAttrCfg.level
end

	
return Commontiphelper
