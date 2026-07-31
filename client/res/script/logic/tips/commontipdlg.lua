require "logic.dialog"
require "utils.mhsdutils"
require "logic.tips.commontiphelper"

Commontipdlg = {}

setmetatable(Commontipdlg,Dialog)
Commontipdlg.__index = Commontipdlg

local _instance

local HUOBAN = 6

Commontipdlg.eType=
{
	eComeFrom =1,
	eSkill =2,
	eNormal = 3,
	eSignIn = 4, --qiandao , signin
	eBeiBao = 5, --beibao
	epetequip = 6, --chongwuzhuangbei
	--eUserItem =5,
}

Commontipdlg.eUseType = 
{
	gotoNpc =1, 
	gotoMap=2,
	openUI=3,
	sendServer=4,
    gotoRandomNpc=5,
}

function Commontipdlg:OnCreate()
	self.prefix = "commontipdlg"
	Dialog.OnCreate(self,nil,self.prefix)
	
	self.bLeftOpen = false
	self.bRequestTipsProtocol = false
	self.vBtnLeft = {}
	self:InitUI()
	
end

function Commontipdlg.getInstance() 
	if not _instance then
		_instance = Commontipdlg.new()
		_instance:OnCreate()
	end
	return _instance

end

function Commontipdlg.getInstanceAndShow()
	if not _instance then
		_instance = Commontipdlg.new()
		_instance:OnCreate()
	else
		_instance:SetVisible(true)
        local compareDlg = require("logic.tips.equipcomparetipdlg").getInstanceNotCreate()
        if compareDlg then
            compareDlg:SetVisible(false)
        end
	end
	if _instance then
		_instance.willCheckTipsWnd = false
	end
	return _instance
end

function Commontipdlg.getInstanceNotCreate()
	return _instance
end

function Commontipdlg.DestroyDialog()
 	if _instance then
	_instance.btnLeft.animation:stop()
	_instance.btnUse.animation:stop()
	_instance.btnComeFrom.animation:stop()
		if not _instance.m_bCloseIsHide then
			_instance:OnClose()
			_instance = nil
		else
			_instance:ToggleOpenClose()
		end
	end
end

function Commontipdlg:OnClose()
	self:ClearLeftBtn()
	Dialog.OnClose(self)
    require("logic.tips.equipcomparetipdlg").DestroyDialog()
    require("logic.tips.equipinfotips").DestroyDialog()

end

function Commontipdlg.GetLayoutFileName()
	return "itemtips_mtg.layout"
end

function Commontipdlg.new()
	local self = {}
	self = Dialog:new()
	setmetatable(self, Commontipdlg)
    self:clearData()
	return self	
end

function Commontipdlg:clearData()
  self.bCompareEquip = true
  self.nBagId = -1
  self.bCompareEquip = false
  self.nComeFromItemId = -1
end 


function Commontipdlg:initzi()
    self.strUsezi = MHSD_UTILS.get_resstring(2668)
	self.strMorezi = MHSD_UTILS.get_resstring(11045)
	self.strBaiTanChuShouzi = MHSD_UTILS.get_resstring(11042)
	self.strZengSongzi = MHSD_UTILS.get_resstring(11043)
	self.strDiuQizi = MHSD_UTILS.get_resstring(11044)
	self.strGongNengzi = MHSD_UTILS.get_resstring(11032) 
	self.strYaoQiuzi = MHSD_UTILS.get_resstring(11033)
	self.strGongXiaozi = MHSD_UTILS.get_resstring(11038)
	self.strPinZhizi = MHSD_UTILS.get_resstring(11039)
	self.strShangHuizi = MHSD_UTILS.get_resstring(11046)
	self.strZuoBiaozi = MHSD_UTILS.get_resstring(11040)
    self.strHechengzi = MHSD_UTILS.get_resstring(11482)

    self.strZhuangbei = require("utils.mhsdutils").get_resstring(2666)
    self.strXiexia =  require("utils.mhsdutils").get_resstring(2667)
    self.strXiangqian = require("utils.mhsdutils").get_resstring(126)

    self.strFenjie = require("utils.mhsdutils").get_resstring(11299)
	self.strhuishou="回收"
	self.strallhuishou="一键回收"
    --self.strchongzhu = tostring("装备重铸")
	--self.strronglian = tostring("熔 炼")
	--self.strjinjie = tostring("装备进阶")
	self.strpetfenjie=tostring("分解")
	self.strallhecheng=tostring("一键合成")
 	self.stralluse = tostring("一键使用")
	self.strzahuofenjie=tostring("分解")
end

function Commontipdlg:addButtonAnimation(button, animationName)
    local animationDef = CEGUI.AnimationManager:getSingleton():getAnimation(animationName)
    if animationDef then
        local animation = CEGUI.AnimationManager:getSingleton():instantiateAnimation(animationDef)
        animation:setTargetWindow(button)
        animation:setSpeed(0.7)
        button.animation = animation
        button:subscribeEvent("MouseButtonDown", function()
            animation:start()
        end, self)
    end
end

function Commontipdlg:InitUI()
	local prefix = self.prefix
	local winMgr = CEGUI.WindowManager:getSingleton()
	
    self:initzi()

	local winbg = winMgr:getWindow(prefix.."itemtips_mtg")
	winbg:subscribeEvent("MouseClick", Commontipdlg.HandlClickBg, self) 

	self.itemCell = CEGUI.toItemCell(winMgr:getWindow(prefix.."itemtips_mtg/item"))
	self.labelName = winMgr:getWindow(prefix.."itemtips_mtg/names")
	self.labelType = winMgr:getWindow(prefix.."itemtips_mtg/leixingming")
	self.labelTypec = winMgr:getWindow(prefix.."itemtips_mtg/leixingming1")
	self.labelLevelTitle = winMgr:getWindow(prefix.."itemtips_mtg/pinzhi") 
	self.labelLevel = winMgr:getWindow(prefix.."itemtips_mtg/pinzhiming")

    self.m_timeText = winMgr:getWindow(prefix.."itemtips_mtg/time")
	
	self.ScrollablePane = CEGUI.toRichEditbox(winMgr:getWindow(prefix.."itemtips_mtg/ScrollablePane"))--scro滑动-层次1
	self.richBox = CEGUI.toRichEditbox(winMgr:getWindow(prefix.."itemtips_mtg/editbox"))--富文本滑动-层次2
	self.richBox:setReadOnly(true)
	self.richBox:setMousePassThroughEnabled(true)
	local nWidth = self:GetMainFrame():getPixelSize().width
	self.nFrameHeightOld = self:GetMainFrame():getPixelSize().height
	self.nBoxHeightOld = self.richBox:getPixelSize().height
	self.nPaneHeightOld = self.ScrollablePane:getPixelSize().height--跟随窗口高度
		
	self.btnLeft = CEGUI.toPushButton(winMgr:getWindow(prefix.."itemtips_mtg/btngengduo"))
	self:addButtonAnimation(self.btnLeft, "studyBtnPress")
	
    self.btnUse = CEGUI.toPushButton(winMgr:getWindow(prefix.."itemtips_mtg/btnshiyong"))
	self:addButtonAnimation(self.btnUse, "studyBtnPress")
	
	self.btnComeFrom = CEGUI.toPushButton(winMgr:getWindow(prefix.."itemtips_mtg/btnshiyong1"))
	self:addButtonAnimation(self.btnComeFrom, "studyBtnPress")
	
    self.btnInfo = CEGUI.toPushButton(winMgr:getWindow(prefix.."itemtips_mtg/yulan"))
	self.btnInfo:subscribeEvent("MouseButtonDown", Commontipdlg.PreHandlBtnClickInfo, self) 
    self.btnInfo:subscribeEvent("MouseButtonUp", Commontipdlg.HandlBtnClickInfo, self) 
    self.labelInfo = winMgr:getWindow(prefix.."itemtips_mtg/zhuangbeiyulan")

	self.lastBtn = CEGUI.toPushButton(winMgr:getWindow(prefix.."itemtips_mtg/zuo"))
	self.nextBtn = CEGUI.toPushButton(winMgr:getWindow(prefix.."itemtips_mtg/you"))
	self.lastBtn:subscribeEvent("Clicked", Commontipdlg.handleLastClicked, self)
	self.nextBtn:subscribeEvent("Clicked", Commontipdlg.handleNextClicked, self)

    self.btnInfo:setVisible(false)
    self.labelInfo:setVisible(false)


	self.btnComeFrom:setVisible(false)
	
	self.btnLeft:subscribeEvent("MouseButtonUp", Commontipdlg.HandlBtnClickLeft, self) 
	self.btnUse:subscribeEvent("MouseClick", Commontipdlg.HandlBtnClickRight, self) 
	self.btnComeFrom:subscribeEvent("MouseButtonUp", Commontipdlg.HandlBtnClickComeFrom, self) 
	
	self:ResetBtn()
	
	self.itemCell:setMousePassThroughEnabled(true)
	self.labelName:setMousePassThroughEnabled(true)
	self.labelType:setMousePassThroughEnabled(true)
	self.labelTypec:setMousePassThroughEnabled(true)
	self.labelLevelTitle:setMousePassThroughEnabled(true)
	self.labelLevel:setMousePassThroughEnabled(true)
	self.richBox:setMousePassThroughEnabled(true)

    self.m_pMainFrame:setAlwaysOnTop(true)
	self.m_pMainFrame:moveToFront()
    self.m_pMainFrame:activate()
	
    --���𱳰�id
    self.nBagId = -1

    local defaultColor =  require("logic.tips.commontiphelper").defaultColor()
    self.richBox:SetColourRect(defaultColor);

    local nSpaceNormal = require("logic.tips.commontiphelper").nSpaceNormal
    self.richBox:SetLineSpace(nSpaceNormal);

    self.m_num = 0 -- ��������
end
function Commontipdlg:refreshTime()
    --ʧЧʱ�䵹��ʱ
	if self.pObj then
        if self.pObj.data.loseeffecttime then
            self.m_timeText:setVisible(true)
            if self.pObj.data.loseeffecttime > 0  then
                local hour = math.floor(self.pObj.data.loseeffecttime / 1000 / 3600 )
                local strhour = ""
    
                if hour < 10 then
                    strhour = "0"..tostring(hour)
                else
                    strhour = tostring(hour)
                end
                local min = math.floor((self.pObj.data.loseeffecttime / 1000 - hour * 3600) / 60)
                local strmin = ""
                if min < 10 then
                    strmin = "0"..tostring(min)
                else
                    strmin = tostring(min)
                end
    
                local sec = math.floor((self.pObj.data.loseeffecttime / 1000 - hour * 3600 -  min * 60))
                local strsec = ""
                if sec < 10 then
                    strsec = "0"..tostring(sec)
                else
                    strsec = tostring(sec)
                end
                local strTime = (tostring(strhour..":"..strmin..":"..strsec))
                if hour > 24 then
                    strTime = math.floor(hour / 24) .. require "utils.mhsdutils".get_resstring(317)
                    if hour % 24 > 1 then
                        strTime = strTime .. math.floor(hour % 24) .. require "utils.mhsdutils".get_resstring(318)
                    end
                elseif hour > 0 then
                    strTime = hour .. require "utils.mhsdutils".get_resstring(318)
                elseif min > 0 then
                    strTime = min .. require "utils.mhsdutils".get_resstring(499)
                else 
                    strTime = sec .. require "utils.mhsdutils".get_resstring(10015)
                end
                self.m_timeText:setText(require "utils.mhsdutils".get_resstring(11533)..strTime)
            elseif self.pObj.data.loseeffecttime == - 1 and bit.band(self.pObj.data.flags, fire.pb.Item.TIMEOUT) > 0 then
                self.m_timeText:setText(require "utils.mhsdutils".get_resstring(11545))
            else
                self.m_timeText:setVisible(false)
            end
        else
            self.m_timeText:setVisible(false)
        end

    end
end
function Commontipdlg:setNum(num)
    self.m_num = num
    self:RefreshNormalInfo()
end
function Commontipdlg:setEquipInfoVisible(bVisible)
    self.btnInfo:setVisible(bVisible)
    self.labelInfo:setVisible(bVisible)
end

function Commontipdlg:setAllBottomVisible(bVisible)
    self.btnLeft:setVisible(bVisible) 
	self.btnUse:setVisible(bVisible) 
	self.btnComeFrom:setVisible(bVisible) 
end

function Commontipdlg:setPreviewVisible(bVisible)
      self.btnInfo:setVisible(bVisible)
      self.labelInfo:setVisible(bVisible)
end

function Commontipdlg:refreshPreview(nItemId)
    local itemAttrCfg = BeanConfigManager.getInstance():GetTableByName("item.citemattr"):getRecorder(nItemId)
	if not itemAttrCfg then
		return false
	end
	local nItemType = itemAttrCfg.itemtypeid
	local nFirstType = require("utils.mhsdutils").GetItemFirstType(nItemType)
	if nFirstType==eItemType_EQUIP then
       self:setPreviewVisible(true)
    else
       self:setPreviewVisible(false)
    end
end

 function Commontipdlg:PreHandlBtnClickInfo(e)
 	--��ֹ�����Ʒ�رձ������--by yangbin
	local insetdlg = require("logic.chat.insertdlg").getInstanceNotCreate()
	if insetdlg then
		insetdlg.willCheckTipsWnd = true
	end
 end

 function Commontipdlg:HandlBtnClickInfo(e)
	self.willCheckTipsWnd = false

	--防止点击物品详情关闭表情界面--by yangbin
	local insetdlg = require("logic.chat.insertdlg").getInstanceNotCreate()
	if insetdlg then
		insetdlg.willCheckTipsWnd = true
	end

    require("logic.tips.equipcomparetipdlg").DestroyDialog()
    
    local nEquipId = self.nItemId
    local pObj = self.pObj
    local equipDlg = require("logic.tips.equipinfotips").getInstanceAndShow()
    equipDlg:RefreshWithObj(nEquipId,pObj)
    equipDlg:RefreshSize()
    
    local nWidth = self:GetMainFrame():getPixelSize().width
	local nHeight = self:GetMainFrame():getPixelSize().height
	local nRootWidth = CEGUI.System:getSingleton():getGUISheet():getPixelSize().width
	--local th = GetWindow():getPixelSize().height
	--local nRootHeight = CEGUI.System:getSingleton():getGUISheet():getPixelSize().height

    
    local mainFrame = self:GetMainFrame()
    local bRight = true
	local nX,nY = require("logic.tips.commontiphelper").getTipPosXY(mainFrame,bRight)
	self:RefreshPosCorrect(nX,nY)

    local selfX = self:GetMainFrame():getPosition().x.offset 

	local nPosX = selfX -nWidth -10 --nRootWidth*0.5 - nWidth -10
    local nPosY = self:GetMainFrame():getPosition().y.offset 
    equipDlg:RefreshPosition(nPosX,nPosY)

 end


--refresh right btn usebtn
function Commontipdlg:refreshUseBtn()
    --self.btnUse:setEnabled(true)
    local nItemId = self.nItemId

    local itemAttrCfg = BeanConfigManager.getInstance():GetTableByName("item.citemattr"):getRecorder(nItemId)
	if not itemAttrCfg then
        return
    end
    if itemAttrCfg.battleuse == 0 and
        itemAttrCfg.battleuser ==0 and
        itemAttrCfg.outbattleuse ==0 then

        self.btnUse:setEnabled(false)
    else 
        self.btnUse:setEnabled(true)
    end

    local nFirstType = Commontiphelper.getItemFirstType(nItemId)
    if nFirstType == eItemType_EQUIP then
        local pObj = self.pObj
        if pObj then
            if pObj.loc.tableType == fire.pb.item.BagTypes.BAG then
                self.btnUse:setText(self.strZhuangbei)
            elseif pObj.loc.tableType == fire.pb.item.BagTypes.EQUIP then
                self.btnUse:setText(self.strXiexia)
            end
        end
	elseif itemAttrCfg.itemtypeid == ITEM_TYPE.HORSE then
		local rideItemId = RoleItemManager.getInstance():getRideItemId()
		if rideItemId == nItemId then
			self.btnUse:setText(MHSD_UTILS.get_resstring(11394)) --����
		else
			self.btnUse:setText(MHSD_UTILS.get_resstring(11393)) --����
		end
    else
        self.btnUse:setText(self.strUsezi)
    end

end

function Commontipdlg:HandlClickBg(e)
	Commontipdlg.DestroyDialog()
end

function Commontipdlg:ResetBtn()
	
	self.btnLeft:setVisible(true)
	self.btnUse:setVisible(true)
	self.btnComeFrom:setVisible(false)
	
	self.btnLeft:setText(self.strMorezi)
	self.btnUse:setText(self.strUsezi)
	--self.btnComeFrom:setText()
	
	self.btnLeft:removeEvent("MouseButtonUp") --left
	self.btnUse:removeEvent("MouseClick") --right
	self.btnComeFrom:removeEvent("MouseButtonUp") --middle
	
	self.btnLeft:subscribeEvent("MouseButtonUp", Commontipdlg.HandlBtnClickLeft, self) 
	self.btnUse:subscribeEvent("MouseButtonUp", Commontipdlg.HandlBtnClickRight, self) 
	self.btnComeFrom:subscribeEvent("MouseButtonUp", Commontipdlg.HandlBtnClickComeFrom, self) 

    
end

Commontipdlg.eLeftBtnType=
{
	gengduo=0,
	diuqi =1,
	baitan=2,
	--shanghui=3,
	fenjie=4,
	zengsong=5,
    xiangqian=6,
	--chongzhu=7,
	--ronglian=8,
	alluse=7,
	allhecheng=8,	
	--jinjie=10,
	huishou=9,
	allhuishou=11,
	zahuofenjie=12
	
}

function Commontipdlg:zaHuoFenjie()
	local item=BeanConfigManager.getInstance():GetTableByName("item.cfenjie"):getRecorder(self.nItemId)
	if item and item.canfenjie==1 then
		return true
	end
	return false
end
function Commontipdlg:GetLeftBtnTitle(nType)
	if Commontipdlg.eLeftBtnType.diuqi== nType then
        local nFirstType = Commontiphelper.getItemFirstType(self.nItemId)
        if nFirstType == eItemType_GEM then
            return self.strHechengzi
        end
		LogInfo(nType.." "..nFirstType)
		if nFirstType == eItemType_PETEQUIPITEM then
		 return self.strpetfenjie
		else
		 return self.strDiuQizi
		end
	elseif Commontipdlg.eLeftBtnType.alluse== nType then
		return self.stralluse
	elseif Commontipdlg.eLeftBtnType.allhecheng== nType then
		return self.strallhecheng		
	elseif Commontipdlg.eLeftBtnType.baitan== nType then
		return self.strBaiTanChuShouzi
--	elseif Commontipdlg.eLeftBtnType.shanghui== nType then
--		return self.strShangHuizi
	elseif Commontipdlg.eLeftBtnType.fenjie== nType then
		return self.strFenjie
	elseif Commontipdlg.eLeftBtnType.huishou==nType then
		return self.strhuishou
	elseif Commontipdlg.eLeftBtnType.allhuishou==nType then
		return self.strallhuishou
	elseif Commontipdlg.eLeftBtnType.zengsong== nType then
    elseif Commontipdlg.eLeftBtnType.xiangqian== nType then
        return self.strXiangqian
	elseif Commontipdlg.eLeftBtnType.zahuofenjie== nType then
		return self.strzahuofenjie
	--elseif Commontipdlg.eLeftBtnType.chongzhu== nType then
   --     return self.strchongzhu
--	elseif Commontipdlg.eLeftBtnType.ronglian== nType then
  --      return self.strronglian
	--elseif Commontipdlg.eLeftBtnType.jinjie== nType then
--        return self.strjinjie
	end
    local nFirstType = Commontiphelper.getItemFirstType(self.nItemId)
        if nFirstType == eItemType_GEM then
            return self.strHechengzi
        end

	return self.strDiuQizi
end


function Commontipdlg:GetBtnType(nItemId,vTypeId)
	local itemAttrCfg = BeanConfigManager.getInstance():GetTableByName("item.citemattr"):getRecorder(nItemId)
	if not itemAttrCfg then
		LogInfo("Gemtipmaker:GetBtnType=error=self.nItemId"..nItemId)
		return false
	end
    local nFirstType = Commontiphelper.getItemFirstType(nItemId)

     if nFirstType == eItemType_EQUIP then
        if self.pObj then
            if self.pObj.loc.tableType == fire.pb.item.BagTypes.EQUIP then
                vTypeId[#vTypeId + 1] = Commontipdlg.eLeftBtnType.xiangqian
                return
            end
        end
    end
    -------------------------------------
	local bDiuQi = itemAttrCfg.bManuleDesrtrol
	local nBaiTan = (ShopManager:getGoodsConfByItemID(nItemId) and 1 or 0)
	local nShangHui = itemAttrCfg.bCanSaleToNpc
	local libao = itemAttrCfg.itemtypeid
	LogInfo("Commontipdlg:GetBtnType()=nBaiTan="..nBaiTan)
	LogInfo("Commontipdlg:GetBtnType()=nShangHui="..nShangHui)

	local huishouconf = BeanConfigManager.getInstance():GetTableByName("item.chuishou"):getRecorder(nItemId)
	if huishouconf and huishouconf.canhuishou==1 then
		vTypeId[#vTypeId + 1] = Commontipdlg.eLeftBtnType.huishou
		vTypeId[#vTypeId + 1] = Commontipdlg.eLeftBtnType.allhuishou
	end

	if nBaiTan==1 then
		vTypeId[#vTypeId + 1] = Commontipdlg.eLeftBtnType.baitan
	end
	if nShangHui>0 then
		vTypeId[#vTypeId + 1] = Commontipdlg.eLeftBtnType.shanghui
	end
	if bDiuQi then
		LogInfo("Commontipdlg:GetBtnType()=bDiuQi=true")
		if libao == 4518 or libao ==  166 or libao ==  4262 or libao ==  4710 or libao ==  4726 then
			vTypeId[#vTypeId + 1] = Commontipdlg.eLeftBtnType.alluse
		end
		if libao == 154 then
			vTypeId[#vTypeId + 1] = Commontipdlg.eLeftBtnType.petefj
		end
		vTypeId[#vTypeId + 1] = Commontipdlg.eLeftBtnType.diuqi
	end

    if nFirstType == eItemType_EQUIP then
        if self.pObj then
            if self.pObj.loc.tableType == fire.pb.item.BagTypes.EQUIP or 
               self.pObj.loc.tableType == fire.pb.item.BagTypes.BAG then
               vTypeId[#vTypeId + 1] = Commontipdlg.eLeftBtnType.xiangqian
			   vTypeId[#vTypeId + 1] = Commontipdlg.eLeftBtnType.chongzhu
			   vTypeId[#vTypeId + 1] = Commontipdlg.eLeftBtnType.ronglian
			   vTypeId[#vTypeId + 1] = Commontipdlg.eLeftBtnType.jinjie
            end
        end
    end
    --ncanfenjie
    if nFirstType == eItemType_EQUIP then
        if self.pObj then
            if self.pObj.loc.tableType == fire.pb.item.BagTypes.BAG then
                local bCanFenjie = Commontipdlg.isCanFenjie(nItemId)
                if bCanFenjie == true then
                    vTypeId[#vTypeId + 1] = Commontipdlg.eLeftBtnType.fenjie
                end
            end
        end
    end

	if self:zaHuoFenjie() then
		if self.pObj then
            if self.pObj.loc.tableType == fire.pb.item.BagTypes.BAG then
                    vTypeId[#vTypeId + 1] = Commontipdlg.eLeftBtnType.zahuofenjie
            end
        end
	end
    -------------------------------
    if nFirstType == eItemType_GEM then
        if self.pObj then
            if self.pObj.loc.tableType == fire.pb.item.BagTypes.BAG then
                local bCanFenjie = Commontipdlg.isCanFenjie_gem(nItemId)
                if bCanFenjie == true then
                    vTypeId[#vTypeId + 1] = Commontipdlg.eLeftBtnType.fenjie
                end
            end
        end
    end
 if nFirstType == eItemType_GEM then
        if self.pObj then
            if self.pObj.loc.tableType == fire.pb.item.BagTypes.BAG then
				vTypeId[#vTypeId + 1] = Commontipdlg.eLeftBtnType.allhecheng
               -- local bCanFenjie = Commontipdlg.isCanFenjie_gem(nItemId)
                --if bCanFenjie == true then
                    --vTypeId[#vTypeId + 1] = Commontipdlg.eLeftBtnType.fenjie
               -- end
            end
        end
    end	
	
end

function Commontipdlg.isCanFenjie_gem(nItemId)
        local gemTable = BeanConfigManager.getInstance():GetTableByName("item.cgemeffect"):getRecorder(nItemId)
	    if not gemTable then
		    return false
	    end
        if gemTable.ncanfenjie == 1 then
           return true
        end
        return false
end

function Commontipdlg.isCanFenjie(nItemId)
        local equipTable = BeanConfigManager.getInstance():GetTableByName("item.cequipitemattr"):getRecorder(nItemId)
	    if not equipTable then
		    return false
	    end
        if equipTable.ncanfenjie == 1 then
           return true
        end
        return false
end

function Commontipdlg:RefreshLeftBtn()
	LogInfo("Commontipdlg:RefreshLeftBtn()")
	if not self.nItemId then
		return
	end
	local nItemId = self.nItemId
	local itemAttrCfg = BeanConfigManager.getInstance():GetTableByName("item.citemattr"):getRecorder(nItemId)
	if not itemAttrCfg then
		LogInfo("Gemtipmaker:HandlBtnClickRight=error=self.nItemId"..nItemId)
		return false
	end
	self.btnLeft:setVisible(true)
	--self.btnLeft:setText(self.strMorezi)
	self.btnLeft:setText(self.strDiuQizi)
	local vTypeId = {}
	self:GetBtnType(nItemId,vTypeId)
	self.btnLeft:setEnabled(true)
	local nTypeBtnNum  = #vTypeId
	LogInfo("nTypeBtnNum="..nTypeBtnNum)
	if 0==nTypeBtnNum then
		self.btnLeft:setEnabled(false)
		self.btnLeft.nTypeId = -1
	elseif 1==nTypeBtnNum then
		local nTypeId = vTypeId[1]
		local strTitle = self:GetLeftBtnTitle(nTypeId)
		self.btnLeft:setText(strTitle)
		self.btnLeft.nTypeId = nTypeId
		
	else
		self.btnLeft:setText(self.strMorezi)
		self.btnLeft.nTypeId = 0 --more
	end

    if  self.nBagId == fire.pb.item.BagTypes.TEMP then
			self.btnLeft:setEnabled(false)
	end
end


--[[
Commontipdlg.eLeftBtnType=
{
	gengduo=0,
	diuqi =1,
	baitan=2,
	shanghui=3,
	fenjie=4,
	zengsong=5,
	
}
--]]

function Commontipdlg:HandlBtnClickLeft(e)
	
	LogInfo("Commontipdlg:HandlBtnClickLeft(e)")
	local mouseArgs = CEGUI.toMouseEventArgs(e)
	local clickWin = mouseArgs.window
	local nTypeId = clickWin.nTypeId
	--if 
	--LogInfo("Commontipdlg:HandlBtnClickLeft(e)=nTypeId="..nTypeId)
	if Commontipdlg.eLeftBtnType.gengduo == nTypeId then
		self:ClickLeft_gengduo(e)
	elseif Commontipdlg.eLeftBtnType.diuqi == nTypeId then
		--self:ClickLeft_diuqi(e)
	    self:ClickLeft_diuqi(e)
	elseif Commontipdlg.eLeftBtnType.alluse == nTypeId then
	    self:ClickLeft_alluse(e)
	elseif Commontipdlg.eLeftBtnType.allhecheng == nTypeId then
		self:ClickLeft_allhecheng(e)		
	elseif Commontipdlg.eLeftBtnType.baitan == nTypeId then
		self:ClickLeft_baitan(e)
--	elseif Commontipdlg.eLeftBtnType.shanghui == nTypeId then
--		self:ClickLeft_shanghui(e)
	elseif Commontipdlg.eLeftBtnType.fenjie == nTypeId then
		self:ClickLeft_fenjie(e)
	elseif Commontipdlg.eLeftBtnType.zengsong == nTypeId then
		self:ClickLeft_zengsong(e)
    elseif Commontipdlg.eLeftBtnType.xiangqian == nTypeId then
		self:ClickLeft_xiangqian(e)
	elseif Commontipdlg.eLeftBtnType.zahuofenjie == nTypeId then
		self:ClickLeft_zahuofenjie(e)
	--elseif Commontipdlg.eLeftBtnType.chongzhu == nTypeId then
	--	self:ClickLeft_chongzhu(e)
--	elseif Commontipdlg.eLeftBtnType.ronglian == nTypeId then
--		self:ClickLeft_ronglian(e)
--	elseif Commontipdlg.eLeftBtnType.jinjie == nTypeId then
	--	self:ClickLeft_jinjie(e)
	elseif Commontipdlg.eLeftBtnType.huishou== nTypeId then
		self:ClickLeft_huishou(e)
	elseif Commontipdlg.eLeftBtnType.allhuishou== nTypeId then
		self:ClickLeft_huishouall(e)
	end
end

function Commontipdlg:ClickLeft_huishou(e)
	LogInfo("Commontipdlg:ClickLeft_fenjie(e)")

	local function nofactioninvitation(self, args)
		if CEGUI.toWindowEventArgs(args).handled ~= 1 then
			gGetMessageManager():CloseCurrentShowMessageBox()
		end
	end

	local function acceptfactioninvitation(self, args)
		if CEGUI.toWindowEventArgs(args).handled ~= 1 then
			gGetMessageManager():CloseCurrentShowMessageBox()
		end

		local cmd = require "protodef.fire.pb.item.chuishouitem".Create()
		cmd.packid = self.nBagId
	    cmd.keyinpack = self.nItemKey
		cmd.huishou=0
        LuaProtocolManager.getInstance():send(cmd)
		 
		print("物品key"..tostring(self.nItemKey).."包id"..tostring(self.nBagId))
	end

   gGetMessageManager():AddMessageBox("", "您确定要回收当前这个物品吗?", acceptfactioninvitation, self, nofactioninvitation, self, eMsgType_Normal, 30000,0,0,nil,MHSD_UTILS.get_resstring(996),MHSD_UTILS.get_resstring(997))
	 
end
function Commontipdlg:ClickLeft_huishouall(e)
	LogInfo("Commontipdlg:ClickLeft_fenjie(e)")

	local function nofactioninvitation(self, args)
		 
			gGetMessageManager():CloseCurrentShowMessageBox()
		 
	end

	local function acceptfactioninvitation(self, args)
		 
			gGetMessageManager():CloseCurrentShowMessageBox()
		 

		local cmd = require "protodef.fire.pb.item.chuishouitem".Create()
		cmd.packid = self.nBagId
	    cmd.keyinpack = self.nItemKey
		cmd.huishou=1
        LuaProtocolManager.getInstance():send(cmd)
		 
			
	print("物品key"..tostring(self.nItemKey).."包id"..tostring(self.nBagId))
	end

   gGetMessageManager():AddMessageBox("", "您确定要回收当前所有物品吗?", acceptfactioninvitation, self, nofactioninvitation, self, eMsgType_Normal, 30000,0,0,nil,MHSD_UTILS.get_resstring(996),MHSD_UTILS.get_resstring(997))
	 
end

function Commontipdlg:ClickLeft_allhecheng(e)
-- local cmd = require "protodef.fire.pb.item.callgemhecheng".Create()
	-- cmd.packid = self.nBagId
	-- cmd.keyinpack = self.nItemKey
    -- LuaProtocolManager.getInstance():send(cmd)
	Commontipdlg.DestroyDialog()
	local function onConfirm(self, args)
		gGetMessageManager():CloseCurrentShowMessageBox()
		local cmd = require "protodef.fire.pb.item.callgemhecheng".Create()
		cmd.packid = self.nBagId
	    cmd.keyinpack = self.nItemKey
        LuaProtocolManager.getInstance():send(cmd)
		return true
	end

	local function onCancel(self, args)
		if CEGUI.toWindowEventArgs(args).handled ~= 1 then
			gGetMessageManager():CloseCurrentShowMessageBox()
		end
	end

	if gGetMessageManager() then
		gGetMessageManager():AddMessageBox(
				"", MHSD_UTILS.get_msgtipstring(200182),
				onConfirm, self, onCancel, self,
				eMsgType_Normal, 30000, 0, 0, nil,
				MHSD_UTILS.get_resstring(2037),
				MHSD_UTILS.get_resstring(2038))
	end
	
	LogInfo("物品key"..self.nItemKey.."包id"..self.nBagId)
end

function Commontipdlg:ClearLeftBtn()
	local mainFrame = self:GetMainFrame()
	if not self.vBtnLeft then
		return
	end
	for nIndex=1,#self.vBtnLeft do
		local btn = self.vBtnLeft[nIndex]
		mainFrame:removeChildWindow(btn)
	end
	self.vBtnLeft = {}
	--self.vBtnLeft
end

function Commontipdlg:AddLeftBtn()
	local winMgr = CEGUI.WindowManager:getSingleton()
	
	local btnPos = self.btnLeft:getPosition()
	self.vBtnLeft = {}
	local nItemId = self.nItemId
	local vTypeId = {}
	self:GetBtnType(nItemId,vTypeId)
	
	local btnWidth = self.btnLeft:getPixelSize().width
	local btnHeight = self.btnLeft:getPixelSize().height
	
	local  mainFrame = self:GetMainFrame()
	local nPosX = btnPos.x.offset 
	local nPosY = btnPos.y.offset 
	
	local nAllBtnNum = #vTypeId-------更多功能的按钮距离
	local nSpaceY = -53
	for nIndex=1,nAllBtnNum do
		nPosY = nPosY + nSpaceY
		local nIndexCorrect = nAllBtnNum- nIndex +1
		local nTypeId = vTypeId[nIndexCorrect]
		local strTitle = self:GetLeftBtnTitle(nTypeId)
		
		local btnPanel1 = winMgr:createWindow("TaharezLook/acc_huansebtn") --common_roll
		self:addButtonAnimation(btnPanel1, "studyBtnPress")
        local btnPanel = CEGUI.toPushButton(btnPanel1)
		btnPanel1:EnableClickAni(false)
		btnPanel1:setAlwaysOnTop(true)--置顶

		btnPanel:setSize(CEGUI.UVector2(CEGUI.UDim(0, btnWidth), CEGUI.UDim(0, btnHeight)))
		btnPanel:setPosition(CEGUI.UVector2(CEGUI.UDim(btnPos.x.scale,nPosX),CEGUI.UDim(btnPos.y.scale, nPosY)))
		btnPanel:subscribeEvent("Clicked", Commontipdlg.HandlBtnClickLeft, self)
		btnPanel:setText(strTitle)
		btnPanel.nTypeId = nTypeId
	
		mainFrame:addChildWindow(btnPanel)
		
        btnPanel:setFont(self.btnLeft:getFont())

		self.vBtnLeft[#self.vBtnLeft + 1] = btnPanel	
		
	end
end

function Commontipdlg:ClickLeft_xiangqian(e)
    local Openui= require("logic.openui")
    
    local nBagId = -1
    local nItemKey = -1

    if self.nBagId then
        nBagId = self.nBagId
        nItemKey = self.nItemKey
    end
        
	Openui.OpenUI(Openui.eUIId.zhuangbeixiangqian_09,nBagId,nItemKey)

    Commontipdlg.DestroyDialog()
end

function Commontipdlg:ClickLeft_chongzhu(e)----装备重铸
	require "logic.workshop.zhuangbeichongzhu".getInstanceAndShow()
    Commontipdlg.DestroyDialog()
end

function Commontipdlg:ClickLeft_ronglian(e)----装备熔炼快捷键
	require "logic.workshop.zhuangbeiqh".getInstanceAndShow()
    Commontipdlg.DestroyDialog()
end

function Commontipdlg:ClickLeft_jinjie(e)----装备进阶
	require "logic.workshop.workshopaq".getInstanceAndShow()
    Commontipdlg.DestroyDialog()
end

function Commontipdlg:ClickLeft_gengduo(e)
	local mouseArgs = CEGUI.toMouseEventArgs(e)
	local clickWin = mouseArgs.window
	local btnPos = clickWin:getPosition()
	
	if self.bLeftOpen==false then
		self:AddLeftBtn()
		self.bLeftOpen = true
	else
		self:ClearLeftBtn()
		self.bLeftOpen = false
	end
end

function Commontipdlg:ClickLeft_diuqi(e)
	Commontiphelper:ClickLeft_diuqi(e,self)
	Commontipdlg.DestroyDialog()
	
end

function Commontipdlg:ClickLeft_alluse(e)
	Commontiphelper:ClickLeft_alluse(e,self)
	Commontipdlg.DestroyDialog()
end

function Commontipdlg:ClickLeft_baitan(e)
	LogInfo("Commontipdlg:ClickLeft_baitan(e)")

    --��ʱ������Ʒ��̯�� ��������Ʒ��
    if _instance.nBagId == fire.pb.item.BagTypes.TEMP then
	    require("logic.shop.stalllabel").show()
    else
	    local nItemKey = self.nItemKey
	    require("logic.shop.stalldlg").showStallSell(nItemKey)
    end

	Commontipdlg.DestroyDialog()
end

function Commontipdlg:ClickLeft_shanghui(e)
	LogInfo("Commontipdlg:ClickLeft_shanghui(e)")

     if _instance.nBagId == fire.pb.item.BagTypes.TEMP then
        require("logic.shop.shoplabel").getInstance():showOnly(1)
    else
	   local dlg = require("logic.shop.commercequickselldlg").getInstanceAndShow()
        dlg:setItemKey(self.nItemKey) 
    end

	--require("logic.shop.shoplabel").getInstance():showOnly(1) --1shang hui
	
	Commontipdlg.DestroyDialog()
end

function  Commontipdlg:ClickLeft_zahuofenjie(e)
	local p = require "protodef.fire.pb.product.czahuofenjie":new()
	p.itemkey = self.nItemKey
	require "manager.luaprotocolmanager":send(p)
end

function Commontipdlg:ClickLeft_fenjie(e)
	LogInfo("Commontipdlg:ClickLeft_fenjie(e)")

	local function nofactioninvitation(self, args)
		if CEGUI.toWindowEventArgs(args).handled ~= 1 then
			gGetMessageManager():CloseCurrentShowMessageBox()
		end
	end

	local function acceptfactioninvitation(self, args)
		if CEGUI.toWindowEventArgs(args).handled ~= 1 then
			gGetMessageManager():CloseCurrentShowMessageBox()
		end

		self:FenJieItem()
	end

	local roleItemManager = require("logic.item.roleitemmanager").getInstance()
	local pItem = roleItemManager:FindItemByBagAndThisID(self.nItemKey, self.nBagId)

	if pItem then
        local itemAttrCfg = pItem:GetBaseObject()
		if itemAttrCfg.id == -1 then
			return
		end
		local nItemType = itemAttrCfg.itemtypeid
		local nFirstType = require("utils.mhsdutils").GetItemFirstType(nItemType)
		
		if pItem:GetBaseObject().nquality >= 1 and nFirstType==eItemType_EQUIP  then---所有装备分解都需要提示
			gGetMessageManager():AddMessageBox("", MHSD_UTILS.get_resstring(11573), acceptfactioninvitation, self, nofactioninvitation, self, eMsgType_Normal, 30000,0,0,nil,MHSD_UTILS.get_resstring(996),MHSD_UTILS.get_resstring(997))
		else
			self:FenJieItem()
		end
	end
	
end

function Commontipdlg:FenJieItem()
		local nBagId = self.nBagId
		local nItemKey = self.nItemKey

		local roleItemManager = require("logic.item.roleitemmanager").getInstance()
		local pItem = roleItemManager:FindItemByBagAndThisID(nItemKey, nBagId)
		if not pItem then
			return
		end

		local itemAttrCfg = pItem:GetBaseObject()
		if itemAttrCfg.id == -1 then
			return
		end
		local nItemType = itemAttrCfg.itemtypeid
		local nFirstType = require("utils.mhsdutils").GetItemFirstType(nItemType)
		if nFirstType == eItemType_GEM then
			require("logic.item.mainpackhelper").showFenjieGem(pItem)
			Commontipdlg.DestroyDialog()
			return
		end



		local strLevelOpen = GameTable.common.GetCCommonTableInstance():getRecorder(209).value
		local nLevelOpen = tonumber(strLevelOpen)

		local nUserLevel = gGetDataManager():GetMainCharacterLevel()
		if nUserLevel < nLevelOpen then
			local strLevelLimit = require "utils.mhsdutils".get_msgtipstring(160308)
			GetCTipsManager():AddMessageTip(strLevelLimit)
			return
		end

		local pObj = pItem:GetObject()
		if not pObj then
			return
		end

		local pEquipData = pObj

		local vcGemList = pEquipData:GetGemlist()
		if vcGemList:size() > 0 then
			self:showConfirmFenjie()
			Commontipdlg.DestroyDialog()
			return
		end


		-- CResolveEquip
		local p = require "protodef.fire.pb.product.cresolveequip":new()
		p.itemkey = nItemKey
		require "manager.luaprotocolmanager":send(p)


		Commontipdlg.DestroyDialog()
end

function Commontipdlg:clickConfirmBoxOk_fenjie()

    local nItemKey = self.nItemKey

    
    local p = require "protodef.fire.pb.product.cresolveequip":new()
	p.itemkey = nItemKey
	require "manager.luaprotocolmanager":send(p)

   
    gGetMessageManager():CloseConfirmBox(eConfirmNormal,false)
end

function Commontipdlg:clickConfirmBoxCancel_fenjie()
    --gGetMessageManager():CloseCurrentShowMessageBox()
    gGetMessageManager():CloseConfirmBox(eConfirmNormal,false)
end

function Commontipdlg:showConfirmFenjie()
--160217
    local strMsg =  require "utils.mhsdutils".get_msgtipstring(160217) 
	local msgManager = gGetMessageManager()
		
	gGetMessageManager():AddConfirmBox(eConfirmNormal,
		strMsg,
		self.clickConfirmBoxOk_fenjie,
	  	self,
	  	self.clickConfirmBoxCancel_fenjie,
	  	self)
        
end


function Commontipdlg:ClickLeft_zengsong(e)
	LogInfo("Commontipdlg:ClickLeft_zengsong(e)")
	Commontipdlg.DestroyDialog()
end


--//��� ʹ�ð�ť rightBtn

function Commontipdlg.UseItemCommon(nBagId, nItemKey, temp1, temp2)
	local roleItemManager = require("logic.item.roleitemmanager").getInstance()
	local pItem = roleItemManager:FindItemByBagAndThisID(nItemKey,nBagId)
    local nItemId = -1
    if pItem then
		nItemId = pItem:GetBaseObject().id
		LogInfo("Commontipdlg.UseItemCommon")
        --commontip.pObj = pObj
	end
	local itemAttrCfg = BeanConfigManager.getInstance():GetTableByName("item.citemattr"):getRecorder(nItemId)
	if not itemAttrCfg then
		LogInfo("Gemtipmaker:HandlBtnClickRight=error=self.nItemId"..nItemId)
		return false
	end
	LogInfo("Commontipdlg:HandlBtnClickRight=itemAttrCfg.nusetype="..itemAttrCfg.nusetype)
	
	local LuaUIManager = require "logic.luauimanager"
	local Taskhelpergoto = require "logic.task.taskhelpergoto"
--[[
	Commontipdlg.eUseType = 
{
	gotoNpc =1, 
	gotoMap=2,
	openUI=3,
	sendServer=4,
}--]]
	local nParam1 = -1
	if itemAttrCfg.vuseparam:size() >=1 then
		nParam1 = itemAttrCfg.vuseparam[0]
	end
	local nParam2 = -1
	if itemAttrCfg.vuseparam:size() >=2 then
		nParam2 = itemAttrCfg.vuseparam[1]
	end
	local nParam3 = -1
	if itemAttrCfg.vuseparam:size() >=3 then
		nParam3 = itemAttrCfg.vuseparam[2]
	end

	if Commontipdlg.eUseType.gotoNpc==itemAttrCfg.nusetype then
		local nNpcId = nParam1
		local flyWalkData = {}
		Taskhelpergoto.GetInitedFlyWalkData(flyWalkData)
		flyWalkData.nNpcId = nNpcId
		Taskhelpergoto.FlyOrWalkTo(flyWalkData)

		require "logic.item.mainpackdlg"
        if CMainPackDlg:getInstanceOrNot() then
			CMainPackDlg:getInstanceOrNot():DestroyDialog()
        end

	elseif Commontipdlg.eUseType.gotoMap==itemAttrCfg.nusetype then
		local nMapId = nParam1
		local nTargetPosX = nParam2
		local nTargetPosY = nParam3
		local flyWalkData = {}
		Taskhelpergoto.GetInitedFlyWalkData(flyWalkData)
		--flyWalkData.nNpcId = nNpcId
		flyWalkData.nMapId = nMapId
		flyWalkData.nTargetPosX = nTargetPosX
		flyWalkData.nTargetPosY = nTargetPosY
		Taskhelpergoto.FlyOrWalkTo(flyWalkData)

		require "logic.item.mainpackdlg"
        if CMainPackDlg:getInstanceOrNot() then
			CMainPackDlg:getInstanceOrNot():DestroyDialog()
        end

	elseif Commontipdlg.eUseType.openUI==itemAttrCfg.nusetype then
		local nUIId = nParam1
		--local uimanager = require "logic.luauimanager".getInstance()
        local nParam1 = nItemId
        local nParam2 = -1
		require("logic.openui").OpenUI(nUIId,nParam1,nParam2)
		
	elseif Commontipdlg.eUseType.sendServer==itemAttrCfg.nusetype then
		Commontipdlg.ClickUseItem(nBagId,nItemKey)
		--self��
    elseif Commontipdlg.eUseType.gotoRandomNpc==itemAttrCfg.nusetype then
        local mainPack = CMainPackDlg:GetSingleton()
		if mainPack then
			mainPack:DestroyDialog()
		else
			local depot = require("logic.item.depot"):getInstanceOrNot()
			if depot then
				depot:DestroyDialog()
			end
		end
        local p = require("protodef.fire.pb.game.cusexueyuekey"):new()
        p.npckid = itemAttrCfg.vuseparam[0]
	    LuaProtocolManager:send(p)

	else
		Commontipdlg.ClickUseItem(nBagId,nItemKey)
		
	end

end
function Commontipdlg:HandlBtnClickRight(e) 
    Commontipdlg.UseItemCommon(self.nBagId, self.nItemKey, 0, 0)
	Commontipdlg.DestroyDialog()
	
end

function Commontipdlg.ClickUseItem(bagid, itemkey)
	LogInfo("Commontipdlg:ClickUseItem(e)")
	--new add
    --���ߵ�ʹ�÷��ڷ����������
	--[[
    if GetBattleManager() then
		if GetBattleManager():IsInBattle() then
			local tip = GameTable.message.GetCMessageTipTableInstance():getRecorder(131451)
			if tip.id ~= -1 then
				GetCTipsManager():AddMessageTip(tip.msg)
			end
			return true;
		end
	end
    ]]--
	require "logic.tips.commontiphelper".ClickUseItem(bagid,itemkey)
end


--//�߽��λ
function Commontipdlg:RefreshPosCorrect(nX,nY)
	local mainFrame = self:GetMainFrame()
	local nCorrectX,nCorrectY = require "logic.tips.commontiphelper".RefreshPosCorrect(mainFrame,nX,nY)
     
    self.nCellPosX = nCorrectX
	self.nCellPosY = nCorrectY
end

--//�����ȡ;��
function Commontipdlg:HandlBtnClickComeFrom(e)
	require "logic.tips.commontiphelper".HandlBtnClickComeFrom(self)
end

--//ˢ��size
function Commontipdlg:RefreshSize(bHaveBtn)
	require "logic.tips.commontiphelper".RefreshSize(self,bHaveBtn)
end


function Commontipdlg:RefreshSkillInfo()
	local itemAttrCfg = BeanConfigManager.getInstance():GetTableByName("item.citemattr"):getRecorder(self.nItemId)
	if not itemAttrCfg then
		LogInfo("Commontipdlg:RefreshSkillInfo=error=self.nItemId"..self.nItemId)
		return
	end
	local itemTypeTable = BeanConfigManager.getInstance():GetTableByName("item.citemtype"):getRecorder(itemAttrCfg.itemtypeid)
	if not itemTypeTable then
		LogInfo("Commontipdlg:RefreshSkillInfo=error=self.itemTypeTable"..itemTypeTable)
		return
	end
	
	self.itemCell:SetImage(gGetIconManager():GetItemIconByID(itemAttrCfg.icon))
	
	self.labelName:setText(itemAttrCfg.name)
	self.labelType:setText(itemTypeTable.name)
	if self.pObj and tonumber(self.pObj) >= 0 then
		self.labelLevelTitle:setText(MHSD_UTILS.get_resstring(1))
		self.labelLevel:setText(tostring(self.pObj))
	elseif self.pObj and self.pObj < 0 then
		local strResult1,strResult2  = require("logic.tips.commontiphelper").getStringForBottomLabel(self.nItemId,0)
		self.labelLevelTitle:setText(strResult1)
		self.labelLevel:setText(strResult2)
	else
		local strPinzhi = MHSD_UTILS.get_resstring(2461)
		self.labelLevel:setText(strPinzhi)
	end
end

function Commontipdlg:checkForShowSaleCoolCd()
end

--������Ϣ ����Ԥ��
function Commontipdlg:RefreshNormalInfo()
	self.willCheckTipsWnd = false
	local itemAttrCfg = BeanConfigManager.getInstance():GetTableByName("item.citemattr"):getRecorder(self.nItemId)
	if not itemAttrCfg then
		LogInfo("Commontipdlg:RefreshNormalInfo=error=self.nItemId"..self.nItemId)
		return
	end
	local itemTypeTable = BeanConfigManager.getInstance():GetTableByName("item.citemtype"):getRecorder(itemAttrCfg.itemtypeid)
	if not itemTypeTable then
		LogInfo("Commontipdlg:RefreshNormalInfo=error=self.itemTypeTable"..itemTypeTable)
		return
	end
	local strLevelzi = MHSD_UTILS.get_resstring(1)
	
     local nFirstType = Commontiphelper.getItemFirstType(self.nItemId)
     self.itemCell:SetImage(gGetIconManager():GetItemIconByID(itemAttrCfg.icon))

     if itemAttrCfg.itemtypeid == GetNumberValueForStrKey("ITEM_TYPE_HUOBAN") then
		   self.itemCell:SetStyle(CEGUI.ItemCellStyle_IconExtend)
     else 
        self.itemCell:SetStyle(CEGUI.ItemCellStyle_IconInside)
     end

    --[[
    local bBind = itemAttrCfg.bBind --true 
    if bBind==true then
        --self.itemCell:SetCornerImageAtPos("common_equip", "suo", 1, 0.5,7,7)
        self.itemCell:SetCornerImageAtPos("common_equip", "suo", 1, 0.5,7,7)

    end
    --]]
    self.itemCell:SetCornerImageAtPos(nil, 0, 1)
    ShowItemTreasureIfNeed(self.itemCell,self.nItemId)
    SetItemCellBoundColorByQulityItem(self.itemCell, itemAttrCfg.nquality)
    if self.pObj then
        if self.pObj.data.flags and  self.pObj.data.timeout  then
            if bit.band(self.pObj.data.flags, fire.pb.Item.TIMEOUT) > 0 and self.pObj.data.timeout == -1  then
                self.itemCell:SetCornerImageAtPos("shopui", "shixiao", 0, 1)
            end
        end

    end

    local nBagId = -1
    local nItemKey = -1

    if self.pObj then
        nBagId = self.pObj.loc.tableType
        nItemKey = self.pObj.data.key
    end
    refreshItemCellBind(self.itemCell,nBagId,nItemKey)
    g_refreshItemCellEquipEndureFlag(self.itemCell,nBagId,nItemKey)

    local content = ""
    if self.nItemId == tonumber(GameTable.common.GetCCommonTableInstance():getRecorder(312).value) or  
        self.nItemId == tonumber(GameTable.common.GetCCommonTableInstance():getRecorder(313).value) or  
        self.nItemId == tonumber(GameTable.common.GetCCommonTableInstance():getRecorder(314).value) or  
        self.nItemId == tonumber(GameTable.common.GetCCommonTableInstance():getRecorder(315).value) or 
        self.nItemId == tonumber(GameTable.common.GetCCommonTableInstance():getRecorder(345).value)
    then
        local strbuilder = StringBuilder:new()
        strbuilder:Set("parameter1", tostring(self.m_num))
        content = strbuilder:GetString(itemAttrCfg.name)
        strbuilder:delete()
    else
        content= itemAttrCfg.name
        
    end
    self.labelName:setText(content)
    if string.len(itemAttrCfg.colour) > 0 then
        --local color = CEGUI.ColourRect(CEGUI.PropertyHelper:stringToColour(itemAttrCfg.colour))
         --local color = CEGUI.ColourRect(CEGUI.PropertyHelper:stringToColour("fffff2df"))

       -- local color = CEGUI.PropertyHelper:stringToColour(itemAttrCfg.colour)
       -- if  color then
           -- [colour='FF00FF00']
            local strNewName = "[colour=".."\'"..itemAttrCfg.colour.."\'".."]"..content
            self.labelName:setText(strNewName)
       -- end
    else
        local strNewName = "[colour=".."\'".."ffffffff".."\'".."]"..content
            self.labelName:setText(strNewName)
    end

	self.labelType:setText(itemTypeTable.name)
	self.labelTypec:setText(itemAttrCfg.name1)----道具类名

	local nItemId = self.nItemId
	local pObj = self.pObj
	
	local strResult1,strResult2  = require("logic.tips.commontiphelper").getStringForBottomLabel(nItemId,pObj)
	self.labelLevelTitle:setText(strResult1)
	self.labelLevel:setText(strResult2)
	
    self:refreshPreview(nItemId)
    self:refreshEquipLevelColor(nItemId)


    self:ClearLeftBtn()
    self.bLeftOpen = false
    --self:RefreshLeftBtn()
    self.m_pMainFrame:activate()

   
    require("logic.tips.equipinfotips").DestroyDialog()

end

function Commontipdlg:refreshEquipLevelColor(nItemId)
    local itemAttrCfg = BeanConfigManager.getInstance():GetTableByName("item.citemattr"):getRecorder(nItemId)
	if not itemAttrCfg then
		return false
	end
	local nItemType = itemAttrCfg.itemtypeid
	local nFirstType = require("utils.mhsdutils").GetItemFirstType(nItemType)
	if nFirstType~=eItemType_EQUIP then
        return
    end
    if self.pObj==nil then
        return
    end
    if self.pObj.loc.tableType~=fire.pb.item.BagTypes.BAG then
        return
    end
    local nUserLevel = gGetDataManager():GetMainCharacterLevel()
    if nUserLevel >= itemAttrCfg.level then
        return
    end
    self.labelLevelTitle:setProperty("TextColours","ffffff00")
	self.labelLevel:setProperty("TextColours","ffffff00")----装备等级红色显示cc.254

end

--//��ȡ;��
function Commontipdlg:RefreshItem_comeFrom()
	self.btnLeft:setVisible(false)
	self.btnUse:setVisible(false)
	self.btnComeFrom:setVisible(true)
	
	self:RefreshNormalInfo()
	
	local itemAttrCfg = BeanConfigManager.getInstance():GetTableByName("item.citemattr"):getRecorder(self.nItemId)
	if not itemAttrCfg then
		return
	end
	self.richBox:Clear()
	local nItemId = self.nItemId
	local pObj = nil
	require("logic.tips.commontiphelper").RefreshRichBox(self.richBox,nItemId,pObj)
	
	--self.richBox:AppendText(CEGUI.String(itemAttrCfg.destribe) )
	--self.richBox:AppendBreak()
	
	--self.richBox:AppendText(CEGUI.String("") )
	self.richBox:AppendBreak()
	
	local strComezi = MHSD_UTILS.get_resstring(11029)
	local strBuild = StringBuilder:new()
	strBuild:Set("parameter1", itemAttrCfg.name)
	local atrCome = strBuild:GetString(strComezi)
	strBuild:delete()
	
	self.richBox:AppendText(CEGUI.String(atrCome),CEGUI.ColourRect(CEGUI.PropertyHelper:stringToColour("ffff0000")))
	self.richBox:AppendBreak()
	self.richBox:Refresh()
	
	--//========================
	local bHaveBtn = true
	self:RefreshSize(bHaveBtn)
	self.richBox:HandleTop()
	
	--//========================
	local nX = self.nCellPosX
	local nY = self.nCellPosY
	self:RefreshPosCorrect(nX,nY)
	
end


--//��ͨ��Ʒ
function Commontipdlg:RefreshItem_normal()
	self.btnLeft:setVisible(false)
	self.btnUse:setVisible(false)
	self.btnComeFrom:setVisible(false)
	
	self:RefreshNormalInfo()
	
	local itemAttrCfg = BeanConfigManager.getInstance():GetTableByName("item.citemattr"):getRecorder(self.nItemId)
	if not itemAttrCfg then
		return
	end
	self.richBox:Clear()

	local nItemId = self.nItemId
	
	local pObj = self.pObj
	require("logic.tips.commontiphelper").RefreshRichBox(self.richBox,nItemId,pObj)
	
	--self.richBox:AppendText(CEGUI.String(itemAttrCfg.destribe) )
	--self.richBox:AppendBreak()
	--self.richBox:Refresh()
	
	local bHaveBtn = false
	self:RefreshSize(bHaveBtn)
	local nX = self.nCellPosX
	local nY = self.nCellPosY
	self:RefreshPosCorrect(nX,nY)
	self.richBox:HandleTop()
	
end

--//���ܽ���ʹ��
function Commontipdlg:RefreshItem_skill()
	self.btnLeft:setVisible(false)
	self.btnUse:setVisible(false)
	self.btnComeFrom:setVisible(false)
	self:RefreshSkillInfo()
	local itemAttrCfg = BeanConfigManager.getInstance():GetTableByName("item.citemattr"):getRecorder(self.nItemId)
	if not itemAttrCfg then
		return
	end
	self.richBox:Clear()
	--[[
	local nItemId = self.nItemId
	local pObj = self.pObj
	require("logic.tips.commontiphelper").RefreshRichBox(self,nItemId,pObj)
	--]]
	--self.richBox:AppendText(CEGUI.String(itemAttrCfg.destribe) )

    local textColor = nil
    require("logic.tips.commontiphelper").appendText(self.richBox,itemAttrCfg.destribe,textColor)


	self.richBox:AppendBreak()
	self.richBox:Refresh()

	local bHaveBtn = false
	self:RefreshSize(bHaveBtn)
	local nX = self.nCellPosX
	local nY = self.nCellPosY
	self:RefreshPosCorrect(nX,nY)
	self.richBox:HandleTop()
	
end
function Commontipdlg:RefreshItem_petequip()
    self.btnLeft:setVisible(false)
    self.btnUse:setVisible(false)
    self.btnComeFrom:setVisible(false)

    self:RefreshNormalInfo()

    local itemAttrCfg = BeanConfigManager.getInstance():GetTableByName("item.citemattr"):getRecorder(self.nItemId)
    if not itemAttrCfg then
        return
    end
    self.richBox:Clear()

    local nItemId = self.nItemId

    local pObj = self.pObj
    require("logic.tips.commontiphelper").RefreshRichBox(self.richBox, nItemId, pObj)
     LogInfo("petweizhi"..pObj.petequippos)
	 
    local bHaveBtn = false
    self:RefreshSize(bHaveBtn)
    local nX = self.nCellPosX
    local nY = self.nCellPosY
    self:RefreshPosCorrect(nX, nY)
    self.richBox:HandleTop()

end


--[[
--//lua call
function Commontipdlg:RefreshItem(nType,nItemId,nCellPosX,nCellPosY) --1=huoqutujing 2=normal
--]]

--��ͬ�Ľ������
function Commontipdlg:RefreshItem(nType,nItemId,nCellPosX,nCellPosY,pObj) --��idΪǩ������id

	self.nType = nType
	self.nItemId = nItemId
	self.pObj = pObj
	self.nCellPosX = nCellPosX
	self.nCellPosY = nCellPosY
	
	if nType==Commontipdlg.eType.eComeFrom then
		self:RefreshItem_comeFrom()
	elseif nType==Commontipdlg.eType.eSkill then
		self:RefreshItem_skill()
	elseif nType == Commontipdlg.eType.epetequip then
        self:RefreshItem_petequip()
	elseif nType==Commontipdlg.eType.eNormal then
		self:RefreshItem_normal() 
        if pObj== nil then
            self:setEquipInfoVisible(false)
        end
	elseif nType==Commontipdlg.eType.eSignIn then
		self:RefreshItem_signin(nItemId) 	
        self:setEquipInfoVisible(false)
	elseif nType==Commontipdlg.eType.eBeiBao then
        self:refreshItemForBeibao(nItemId,pObj,nCellPosX,nCellPosY)
	--elseif nType == Commontipdlg.eType.eUserItem
		
	else 
		self:RefreshItem_normal() 
         
	end

    
end

--//========================================
--//========================================
--//========================================
function Commontipdlg:MakeSeparator()
	--self.richBox:AppendImage(CEGUI.String("lifeskillui"),CEGUI.String("life_line"))
    --self.richBox:AppendBreak()
end

function Commontipdlg:GetColourRect(str)
	return CEGUI.ColourRect(CEGUI.PropertyHelper:stringToColour(str))
end

--//c call  bag and dlg
--nbagid=-1  use itembaseid ��������ʱ��������
function Commontipdlg.LuaShowItemTip(nBagId, nItemKey, nCellPosX,nCellPosY)
	
	LogInfo("Commontipdlg.LuaShowItemTip(pItem,nItemId,nCellPosX,nCellPosY)")

	local commontip = Commontipdlg.getInstanceAndShow()
	commontip.nBagId = nBagId
	commontip.nItemKey = nItemKey
	
	if nBagId == fire.pb.item.BagTypes.TEMP then
        --��ʱ����tips��ʾ
        local bLuaHandleSuccess = commontip:RefreshItemWithObjForTempPack( nItemKey,nCellPosX,nCellPosY )
        return bLuaHandleSuccess
    end
	
	
	LogInfo("Commontipdlg.LuaShowItemTip2")
	local nItemId = -1
	if nBagId==-1 then
		nItemId = nItemKey
	end

	local roleItemManager = require("logic.item.roleitemmanager").getInstance()
	local pItem = roleItemManager:FindItemByBagAndThisID(nItemKey,nBagId)
	local pObj = nil
	if pItem then
		pObj = pItem:GetObject()
		nItemId = pItem:GetBaseObject().id
		LogInfo("Commontipdlg.LuaShowItemTip3")
        --commontip.pObj = pObj
	end
    
	local nType = Commontipdlg.eType.eBeiBao 
	commontip:RefreshItem(nType,nItemId,nPosX,nPosY,pObj)

	if nCellPosX == 0 and nCellPosY == 0 then
		commontip:DisableBtn()
	end
	
	return true
end

function Commontipdlg.LuaShowItemTipFromChat(Item, nBagId, nItemKey)

	local commontip = Commontipdlg.getInstanceAndShow()
	commontip.nBagId = nBagId
	commontip.nItemKey = nItemKey

	local nItemId = -1
	if nBagId==-1 then
		nItemId = nItemKey
	end
	local pItem = Item
	local pObj = nil
	if pItem then
		nItemId = pItem:GetBaseObject().id
		pObj = pItem:GetObject()
	end
    commontip:refreshItemForBeibao(nItemId, pObj, 0, 0)

	commontip:DisableBtn()
	
	return true
end

function Commontipdlg:DisableBtn()
		self.btnLeft:setVisible(false)
		self.btnUse:setVisible(false)
		self.btnComeFrom:setVisible(false)
end




--bei bao call only 
function Commontipdlg:refreshItemForBeibao(nItemId,pObj,nCellPosX,nCellPosY)
    
	local bCompareEquip = false --beibao need compare
    local eBagType = -1
    if pObj then
        eBagType = pObj.loc.tableType
    end
    
    local pItemInBody = nil
    if eBagType == fire.pb.item.BagTypes.BAG then
        pItemInBody = require("logic.tips.commontiphelper").getEquipInBodySameComponent(nItemId)
        if pItemInBody and not IsNewEquip(pItemInBody:GetItemTypeID()) then
            bCompareEquip = true
        end
		local itemAttrCfg = BeanConfigManager.getInstance():GetTableByName("item.citemattr"):getRecorder(nItemId)
        if not itemAttrCfg then
            return false
        end
        local itemtypeid = itemAttrCfg.itemtypeid
		if IsNewEquip(itemtypeid) then
		bCompareEquip = false
		end
    end


    --====================================
   --[[
    if 1 then --wangbin test
        local bShowBottomBtn = true
        require("logic.tips.commontiphelper").showItemTip(nItemId,pObj,bCompareEquip,bShowBottomBtn,nCellPosX,nCellPosY)
        return 
    end
    --]]
    self:RefreshItemWithObjectNormal(nItemId,pObj,nCellPosX,nCellPosY,bCompareEquip)

	local bHaveBtn = true
	self:RefreshSize(bHaveBtn)


	--=====================================
    --pos
    local bRight = false
    if self.bCompareEquip == true or eBagType == fire.pb.item.BagTypes.EQUIP then
        bRight = true
    end
   
	local mainFrame = self:GetMainFrame()
    --Commontiphelper.getTipPosXY(mainFrame,bRight)
	local nX,nY = require("logic.tips.commontiphelper").getTipPosXY(mainFrame,bRight)
    if bCompareEquip == false then
		-- ycl �������׿�ֻ���װ��tipsλ�ò���ȷ���ᵲסװ��icon������
		local uiRootSize = GetScreenSize();
        if nX < uiRootSize.width / 2 then
            nX = uiRootSize.width / 8
        else
            nX = uiRootSize.width - uiRootSize.width / 8
        end 

		

    end
	self:RefreshPosCorrect(nX,nY)
    --=====================================
	
    --=====================================
    --compare show
    if  self.bCompareEquip == true then
        local nItemId2 = -1
        local pObj2 = nil
        if pItemInBody then
            nItemId2 = pItemInBody:GetBaseObject().id
            pObj2 = pItemInBody:GetObject()
        end

        local compareDlg = require("logic.tips.equipcomparetipdlg").getInstanceAndShow()
        local mainFrame2 = compareDlg:GetMainFrame()
        local bRight2 = false
        local nCellPosX2,nCellPosY2 =  require("logic.tips.commontiphelper").getTipPosXY(mainFrame2,bRight2) 
        compareDlg:RefreshItem(nItemId2,pObj2,nCellPosX2,nCellPosY2)
       
        --compareDlg:RefreshPosCorrect(nCellPosX2,nCellPosY2)

        --=====================================
        --compare pos
         nCellPosX2,nCellPosY2 = require("logic.tips.commontiphelper").getTipPosXY(mainFrame2,bRight2)
         local nPosY2 = nCellPosY2
         if nCellPosY2 < nY then
            nPosY2 = nCellPosY2
         else
            nPosY2 = nY
         end
         compareDlg:RefreshPosCorrect(nCellPosX2,nPosY2)

    end

    --=====================================
    --compare pos
    

    --=====================================

    --=====================================
	self:RefreshLeftBtn()
    self:refreshUseBtn()
    --=====================================
	

	
	return true
end

--cpp ����
function Commontipdlg.LuaShowItemTipWithBaseId(nItemId,nCellPosX,nCellPosY)
    local nPosX = nCellPosX
	local nPosY = nCellPosY
	local commontipdlg = Commontipdlg.getInstanceAndShow()
	--local nType = Commontipdlg.eType.eComeFrom
	local nType = Commontipdlg.eType.eNormal 
	commontipdlg:RefreshItem(nType,nItemId,nPosX,nPosY)
end

----�ֿ���
function Commontipdlg:RefreshItemWithObjForCangKu(nItemId,pObj,nCellPosX,nCellPosY,strBtnTitle,callback)
	if not pObj  then
		LogInfo("error=RefreshItemWithObjForCangKu=pObj=nil")
	end
	self.btnLeft:setVisible(false)
	self.btnUse:setVisible(false)
	self.btnComeFrom:setVisible(true)
	
	self.btnComeFrom:setText(strBtnTitle)

	self.btnComeFrom:removeEvent("MouseButtonUp") --right btn
	self.btnComeFrom:subscribeEvent("MouseButtonUp",callback) 
	
    local bCompareEquip = false
	self:RefreshItemWithObjectNormal(nItemId,pObj,nCellPosX,nCellPosY,bCompareEquip)
	local bHaveBtn = true
	self:RefreshSize(bHaveBtn)
    local mainFrame = self:GetMainFrame()
    local nX,nY = require("logic.tips.commontiphelper").getTipPosXY(mainFrame,false)
   
	self:RefreshPosCorrect(nCellPosX,nY)

end

--��ʱ������
function Commontipdlg:RefreshItemWithObjForTempPack(nItemId,nCellPosX,nCellPosY)
	--if not pObj  then
	--	LogInfo("error=RefreshItemWithObjForCangKu=pObj=nil")
	--end
	self.btnLeft:setVisible(true)
	self.btnUse:setVisible(true)
	self.btnComeFrom:setVisible(false)
	
    local strBtnTitle = require "utils.mhsdutils".get_resstring(2916)

	self.btnUse:setText(strBtnTitle)

	--self.btnComeFrom:removeEvent("MouseButtonUp") --right btn
	--self.btnComeFrom:subscribeEvent("MouseButtonUp",callback) 
    self.btnUse:removeEvent("MouseButtonUp") --right btn
    self.btnUse:setID(nItemId)
	self.btnUse:subscribeEvent("MouseButtonUp", self.HandleTempPackMoveItem) 
	
	local roleItemManager = require("logic.item.roleitemmanager").getInstance()
    local pItem = roleItemManager:FindItemByBagAndThisID(nItemId,fire.pb.item.BagTypes.TEMP)
	local itemid = pItem:GetBaseObject().id
    local pObj = pItem:GetObject()
    local bCompareEquip = false
	self:RefreshItemWithObjectNormal(itemid,pObj,nCellPosX,nCellPosY,bCompareEquip)
	local bHaveBtn = true
	self.nItemId = itemid
	self:RefreshLeftBtn()
	self:RefreshSize(bHaveBtn)
	self:RefreshPosCorrect(nCellPosX,nCellPosY)

	return true
end
--��ʱ������
function Commontipdlg:HandleTempPackMoveItem( e )
    local eventargs = CEGUI.toWindowEventArgs(args)
	local commontip = Commontipdlg.getInstanceAndShow()
	local id = commontip.nItemKey

	require "protodef.fire.pb.item.ctransitem"
	local p = CTransItem.Create()
    p.srckey = id
    p.srcpackid = fire.pb.item.BagTypes.TEMP
    p.dstpackid = fire.pb.item.BagTypes.BAG
    p.number = -1 
    p.dstpos = -1
    p.page = -1	
    p.npcid = -1
    LuaProtocolManager.getInstance():send(p)
	
    Commontipdlg.DestroyDialog()
end

--����
function Commontipdlg:RefreshItemWithObjectNormal(nItemId,pObj,nCellPosX,nCellPosY,bCompareEquip)
	self.nItemId = nItemId
    self.pObj = pObj
	self.nCellPosX = nCellPosX
	self.nCellPosY = nCellPosY
    self.bCompareEquip = bCompareEquip
	
	
	self:RefreshNormalInfo()
	
    --local bCompareEquip = self.bCompareEquip
    local defaultColor = nil
	require("logic.tips.commontiphelper").RefreshRichBox(self.richBox,nItemId,pObj,defaultColor,bCompareEquip)
    self:refreshTime()
end

function Commontipdlg:Update(delta)
    self:refreshTime()
    
end

--//pObj=nil  usebaseid use in  bag call ֻ�б���ʹ��
function Commontipdlg:RefreshItemWithObj(nItemId,pObj,nCellPosX,nCellPosY)
    local bCompareEquip = true
	self:RefreshItemWithObjectNormal(nItemId,pObj,nCellPosX,nCellPosY,bCompareEquip)
	local bHaveBtn = true
	self:RefreshSize(bHaveBtn)
	
	local mainFrame = self:GetMainFrame()
	local nX,nY = require("logic.tips.commontiphelper").getTipPosForBag(mainFrame)
	self:RefreshPosCorrect(nX,nY)
	
	self:RefreshLeftBtn()
    self:refreshUseBtn()
	
	return true
	
end


function Commontipdlg:RefreshBottomBtn()
end

--1237 %d��%d��%d�� 
--1238 %dʱ%d��%d��
--1239 %d��%d��
--1240 %dСʱ%d����
--1241 %d����
--1242 %dСʱ

--[[ 
11031	����:
11032	����:
11033	Ҫ��:
11034	��Чʱ��:
11035	����ʱ��:
11036	�����ѹ���
11037	��Ƕ:
11038	��Ч:
11039	Ʒ��:
11040	����:
11041	�ȼ�:
11042	��̯����
11043	����
11044	����

--]]

--//��ͨ��Ʒ
function Commontipdlg:RefreshItem_signin( nSignID )
	self.btnLeft:setVisible(false)
	self.btnUse:setVisible(false)
	self.btnComeFrom:setVisible(false)
	
	local cfg = BeanConfigManager.getInstance():GetTableByName("game.cqiandaojiangli"):getRecorder(nSignID) --��ȡ�󣬿����޸�itemid��
	local itemAttrCfg
		
	if cfg.itemid == 0 then
		--self.nItemId = 50046		--ֱ��д�̶�ֵ
		if cfg.mtype == 1 then
			self.nItemId = 50046		--ֱ��д�̶�ֵ
		elseif cfg.mtype == 2 then
			self.nItemId = 50046		--ֱ��д�̶�ֵ
		elseif cfg.mtype == 3 then
			self.nItemId = 50046		--ֱ��д�̶�ֵ
		end
		itemAttrCfg = BeanConfigManager.getInstance():GetTableByName("item.citemattr"):getRecorder(self.nItemId)
	else
		itemAttrCfg = BeanConfigManager.getInstance():GetTableByName("item.citemattr"):getRecorder(cfg.itemid)
		self.nItemId = cfg.itemid
	end
	
	self:RefreshNormalInfo()

	if not itemAttrCfg then
		return
	end
	self.richBox:Clear()
	--self.richBox:AppendText(CEGUI.String(itemAttrCfg.destribe) )
    --require("logic.tips.commontip")
    local textColor = nil
    local strDes = itemAttrCfg.destribe
    require("logic.tips.commontiphelper").appendText(self.richBox,strDes,textColor)

	self.richBox:AppendBreak()
	
	local parentDlg = QiandaosongliDlg.getInstanceNotCreate()
	local strGot = MHSD_UTILS.get_resstring( 11177 )
	
	local strbuilder = StringBuilder:new()
	strbuilder:Set("parameter1", nSignID % 100 - parentDlg.m_times )
	local strSignTimes = strbuilder:GetString(MHSD_UTILS.get_resstring( 11178 )) 
	strbuilder:delete()
	
	if nSignID % 100 <=  parentDlg.m_times then--had signed
		self.richBox:AppendParseText(CEGUI.String(strGot))
		self.richBox:AppendBreak()
	else
		self.richBox:AppendParseText(CEGUI.String(strSignTimes))
		self.richBox:AppendBreak()
	end
	
	self.richBox:Refresh()
	
	--//========================
	local bHaveBtn = false
	self:RefreshSize(bHaveBtn)
	
	--//========================
	local nX = self.nCellPosX
	local nY = self.nCellPosY
	self:RefreshPosCorrect(nX,nY)
	self.richBox:HandleTop()
	
end

function Commontipdlg:HandleHideTip(args)
	self:DestroyDialog()
end


--//�л�ǰ��ͬ��Ʒtip
function Commontipdlg:showSwitchPageArrow(isShow)
	self.lastBtn:setVisible(isShow)
	self.nextBtn:setVisible(isShow)
end

function Commontipdlg:setSwitchPageCallFunc(func, tar)
	if func then
		self.switchCallFunc = {func=func, tar=tar}
	end
end

function Commontipdlg:setCloseCallFunc(func, tar)
	if func then
		self.closeCallFunc = {func=func, tar=tar}
	end
end

function Commontipdlg:handleLastClicked(args)
	if self.switchCallFunc then
		self.switchCallFunc.func(self.switchCallFunc.tar, false)
	end
end

function Commontipdlg:handleNextClicked(args)
	if self.switchCallFunc then
		self.switchCallFunc.func(self.switchCallFunc.tar, true)
	end
end

return Commontipdlg
