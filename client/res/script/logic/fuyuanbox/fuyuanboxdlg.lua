require "logic.dialog"

fuyuanBoxDlg = {}
setmetatable(fuyuanBoxDlg, Dialog)
fuyuanBoxDlg.__index = fuyuanBoxDlg

local _instance
local m_ClickStart = false
function fuyuanBoxDlg.getInstance()
	if not _instance then
		_instance = fuyuanBoxDlg:new()
		_instance:OnCreate()
	end
	return _instance
end

function fuyuanBoxDlg.getInstanceAndShow()
	if not _instance then
		_instance = fuyuanBoxDlg:new()
		_instance:OnCreate()
	else
		_instance:SetVisible(true)
	end
	return _instance
end

function fuyuanBoxDlg.getInstanceNotCreate()
	return _instance
end

function fuyuanBoxDlg.DestroyDialog()
	if _instance then 
		if not _instance.m_bCloseIsHide then
            gGetRoleItemManager():RemoveLuaItemNumChangeNotify(_instance.eventItemNumChange)
			_instance:OnClose()
			_instance = nil
		else
			_instance:ToggleOpenClose()
		end
        require("logic.tips.commontipdlg").DestroyDialog()
	end
end

function fuyuanBoxDlg.ToggleOpenClose()
	if not _instance then
		_instance = fuyuanBoxDlg:new()
		_instance:OnCreate()
	else
		if _instance:IsVisible() then
			_instance:SetVisible(false)
		else
			_instance:SetVisible(true)
		end
	end
end

function fuyuanBoxDlg.GetLayoutFileName()
	return "fuyuanbaoxiang.layout"
end

function fuyuanBoxDlg:new()
	local self = {}
	self = Dialog:new()
	setmetatable(self, fuyuanBoxDlg)
	return self
end

function fuyuanBoxDlg:OnCreate()
	Dialog.OnCreate(self)
	local winMgr = CEGUI.WindowManager:getSingleton()
    

    
	self.m_Panel = winMgr:getWindow("fuyuanbaoxiang/texiao")
    --Կ��
    self.m_keyItem = CEGUI.Window.toItemCell(winMgr:getWindow("fuyuanbaoxiang/daoju"))
    self.m_keyItem:subscribeEvent("MouseClick",fuyuanBoxDlg.HandleItemClicked,self)
    self.m_keyText = CEGUI.Window.toItemCell(winMgr:getWindow("fuyuanbaoxiang/mingzi"))
	self.m_keyTextc = CEGUI.Window.toItemCell(winMgr:getWindow("fuyuanbaoxiang/mingzic"))
	self.m_keyTextcc = CEGUI.Window.toItemCell(winMgr:getWindow("fuyuanbaoxiang/mingzicc"))
    self.m_keyNum = winMgr:getWindow("fuyuanbaoxiang/number")
    --��ť
    self.m_startBtn = CEGUI.Window.toPushButton(winMgr:getWindow("fuyuanbaoxiang/btn1"))
    self.m_startBtn:subscribeEvent("MouseClick",fuyuanBoxDlg.HandleStartClicked,self)
    self.m_startBtn:setVisible(true)
	self.m_startBtn1 = CEGUI.Window.toPushButton(winMgr:getWindow("fuyuanbaoxiang/btn11"))
    self.m_startBtn1:subscribeEvent("MouseClick",fuyuanBoxDlg.HandleShiLianClicked,self)
    self.m_startBtn1:setVisible(true)
    self.m_startBtn2 = CEGUI.Window.toPushButton(winMgr:getWindow("fuyuanbaoxiang/btn14"))
    self.m_startBtn2:subscribeEvent("MouseClick",fuyuanBoxDlg.HandleStartClicked,self)
    self.m_startBtn2:setVisible(true)
    --��Ʒ 
    self.m_itemID = 0
    self.m_boxItem = {}
    self.m_boxBright = {}
	self.m_CellParent = {}
    self.m_itemsData = {}
	self.m_ItemCellEffect = nil
	self.m_NiHongDengEffect = nil
    for i = 1, 25 do
		self.m_CellParent[i] = winMgr:getWindow("fuyuanbaoxiang/"..i)
        self.m_boxItem[i] = CEGUI.Window.toItemCell(winMgr:getWindow("fuyuanbaoxiang/"..i.."/item"..i))
        self.m_boxItem[i]:subscribeEvent("MouseClick",fuyuanBoxDlg.HandleItemClicked,self)
        self.m_boxBright[i] = CEGUI.Window.toItemCell(winMgr:getWindow("fuyuanbaoxiang/"..i.."/liang"..i))
    end
    
    self.eventItemNumChange = gGetRoleItemManager():InsertLuaItemNumChangeNotify(fuyuanBoxDlg.onEventBagItemNumChange)
	self.m_CloseBtn = winMgr:getWindow("fuyuanbaoxiang/close")
    self.m_CloseBtn:subscribeEvent("Clicked", fuyuanBoxDlg.HandleEndClicked, self)
    --Կ��id  2Ϊ�������ˣ�3ΪѪ��С��
    self.m_KeyIndex = 2
    self.m_Stauts = 0 -- 0Ϊ��ʼ��1���˿�ʼ��ť��2���˽�����ť

	self.m_Tips_1 = winMgr:getWindow("fuyuanbaoxiang/yinwenzi")
	self.m_Tips_1:setVisible(false)
	self.m_Tips_2 = winMgr:getWindow("fuyuanbaoxiang/jinwenzi")
	self.m_Tips_2:setVisible(false)
	self.m_Tips_3 = winMgr:getWindow("fuyuanbaoxiang/huanwenzi")
	self.m_Tips_3:setVisible(false)


end
function fuyuanBoxDlg:realAwardListRandomSort( num )
	local N = num
	for i = 1, N do
		local j = math.random(N-i+1)+i-1
		self.m_itemsData[i], self.m_itemsData[j] = self.m_itemsData[j], self.m_itemsData[i]
	end
end
function fuyuanBoxDlg.onEventBagItemNumChange(bagid, itemkey, itembaseid) 
    local dlg = require"logic.fuyuanbox.fuyuanboxdlg".getInstanceNotCreate()
    if dlg then
        if itembaseid == dlg.m_itemID then
            dlg:InitKey()
        end
    end
end
function fuyuanBoxDlg:totalTimeNum()
	self.m_totalTime = self.m_baseSpeed * self.m_totalMoveNum + self.m_addSpeed * self:addTime(self.m_addSpeedNum) + self.m_slowSpeed * self:addTime(self.m_slowNum)
end
function fuyuanBoxDlg:addTime( num )
	local totalNum = 0
	if num <= 0 then
		return
	end
	for i = 1, num do
		totalNum = totalNum + i 
	end
	return totalNum
end
function fuyuanBoxDlg:InitDlg(index, npckey)
    self.m_KeyIndex = index
    self.m_NpcKey = npckey
    --��ʼ����Ʒ
    self:InitItem()

    --�������� ��Ҫ ���˽�Ҵ�
    if self.m_KeyIndex == 2 then
        self.m_itemID = tonumber(GameTable.common.GetCCommonTableInstance():getRecorder(284).value)
		self.m_startBtn2:setVisible(false)
    --Ѫ��С�� ��Ҫ �������Ҵ�
    elseif self.m_KeyIndex == 3 then
        self.m_itemID = tonumber(GameTable.common.GetCCommonTableInstance():getRecorder(285).value)
		self.m_startBtn2:setVisible(false)
	elseif self.m_KeyIndex == 4 then
        self.m_itemID = tonumber(GameTable.common.GetCCommonTableInstance():getRecorder(488).value)
		self.m_startBtn:setVisible(false)
		self.m_startBtn1:setVisible(false)
	elseif self.m_KeyIndex == 5 then
        self.m_itemID = tonumber(GameTable.common.GetCCommonTableInstance():getRecorder(490).value)
		self.m_startBtn:setVisible(false)
		self.m_startBtn1:setVisible(false)
	elseif self.m_KeyIndex == 6 then
        self.m_itemID = tonumber(GameTable.common.GetCCommonTableInstance():getRecorder(492).value)
		self.m_startBtn:setVisible(false)
		self.m_startBtn1:setVisible(false)
    end
    
    --��ʼ������
    self:InitKey()

    --��ʼ��תתת����
    self:InitData()

	if self.m_KeyIndex == 2 then
		self.m_Tips_2:setText(MHSD_UTILS.get_resstring(7302))
		self.m_Tips_2:setVisible(true)	
	elseif self.m_KeyIndex == 3 then
		self.m_Tips_1:setText(MHSD_UTILS.get_resstring(7301))
		self.m_Tips_1:setVisible(true)
	elseif self.m_KeyIndex == 4 then
		self.m_Tips_3:setText(MHSD_UTILS.get_resstring(11813))
		self.m_Tips_3:setVisible(true)
	elseif self.m_KeyIndex == 5 then
		self.m_Tips_3:setText(MHSD_UTILS.get_resstring(11813))
		self.m_Tips_3:setVisible(true)
	elseif self.m_KeyIndex == 6 then
		self.m_Tips_3:setText(MHSD_UTILS.get_resstring(11813))
		self.m_Tips_3:setVisible(true)
	end
    
end
function fuyuanBoxDlg:InitData()
    self.m_addSpeedNum = tonumber(GameTable.common.GetCCommonTableInstance():getRecorder(275).value) -- ���ٸ�����
    self.m_normalSpeed = tonumber(GameTable.common.GetCCommonTableInstance():getRecorder(276).value) -- ���������ٶ�
	self.m_minSlowNum = tonumber(GameTable.common.GetCCommonTableInstance():getRecorder(277).value)  -- ����������С��
	self.m_maxSlowNum = tonumber(GameTable.common.GetCCommonTableInstance():getRecorder(278).value)  -- �������������
	self.m_minTotalMoveNum = tonumber(GameTable.common.GetCCommonTableInstance():getRecorder(279).value) -- �ܸ����ƶ�������С��
	self.m_maxTotalMoveNum = tonumber(GameTable.common.GetCCommonTableInstance():getRecorder(280).value) -- �ܸ����ƶ����������
	
    self.m_closeTime = tonumber(GameTable.common.GetCCommonTableInstance():getRecorder(281).value) -- ���ٸ�����
    self.m_closeTime = self.m_closeTime * 1000

    self.m_curAwardIndex = math.random(1, 25)
    self.m_startIndex = self.m_curAwardIndex

    self.m_realAwardNum = 25
    self.m_elapse = 0     
	self.m_moveNum = 1       -- ��¼�Ѿ��ƶ��ĸ�������
	self.m_tTime = 0      
	self.m_speed = 0         -- �����ٶ�
	self.m_addSpeed = 120    -- ��ʼ���ٶ�
	self.m_slowSpeed = 120   -- �����ٶ�
	self.m_laseTime = 0 -- ��¼֮ǰ�����ƶ���ʱ�䣨�Ѿ��ƶ������и��ӣ�
	self.m_slowNum = math.random(self.m_minSlowNum, self.m_maxSlowNum)                -- �����ٵĸ�����
	self.m_totalMoveNum = math.random(self.m_minTotalMoveNum, self.m_maxTotalMoveNum) -- ��Ҫ�ƶ��ĸ���������
	self.m_baseSpeed = 1 * self.m_normalSpeed -- �����ٶ�
	self.m_totalTime = 0   --  �����ƶ�����ʱ��
	self.m_closeTime = 0
	self:totalTimeNum()
   
    self:realAwardListRandomSort(25) -- ������ʾ�ڽ����Ͻ�����˳��
    --self:changeRealAwardPos(awardId) 
    for i = 1, 25 do
        local iconManager = gGetIconManager()
        local itemAttrCfg = BeanConfigManager.getInstance():GetTableByName("item.citemattr"):getRecorder(self.m_itemsData[i])
        if itemAttrCfg then
        	self.m_boxItem[i]:SetImage(iconManager:GetItemIconByID(itemAttrCfg.icon) )
	        self.m_boxItem[i]:setID(self.m_itemsData[i])
            ShowItemTreasureIfNeedtm(self.m_boxItem[i],self.m_itemsData[i])
            SetItemCellBoundColorByQulityItemcj(self.m_boxItem[i], itemAttrCfg.nquality)
        end

    end

	self.m_ItemCellEffect = gGetGameUIManager():AddUIEffect(self.m_boxItem[self.m_curAwardIndex], MHSD_UTILS.get_effectpath(11077))
    self.m_boxItem[self.m_curAwardIndex]:moveToFront()
    --self.m_boxBright[self.m_curAwardIndex]:setVisible(true)

--	local winMgr = CEGUI.WindowManager:getSingleton()
--	local tmp = winMgr:getWindow("fuyuanbaoxiang")

--	local pos = self.m_CellParent[self.m_curAwardIndex]:getPosition()
--	local x = pos.x.offset + self.m_CellParent[self.m_curAwardIndex]:getPixelSize().width/2
--	local y = pos.y.offset + self.m_CellParent[self.m_curAwardIndex]:getPixelSize().height/2
--	local offx = tmp:getXPosition():asAbsolute(tmp:getParent():getPixelSize().width)--tmp:getPosition().x.offset
--	local offy = tmp:getYPosition():asAbsolute(tmp:getParent():getPixelSize().height)
--	self.m_ItemCellEffect:SetLocation(Nuclear.NuclearPoint(offx + x, offy + y))
    --gGetGameUIManager():AddUIEffect(self.m_boxItem[self.m_curAwardIndex], MHSD_UTILS.get_effectpath(11077))
end
function fuyuanBoxDlg:changeRealAwardPos( awardId )
	local tmp
	for i = 1, self.m_realAwardNum do
		if self.m_itemsData[i] == awardId then
			tmp = i
		end
	end
	local realIndex = math.floor((self.m_totalMoveNum + self.m_startIndex - 1) % 25)
	if realIndex == 0 then
		realIndex = 25
	end
    if tmp < realIndex then
        for i = 1, (realIndex - tmp) do
            self.m_totalMoveNum = self.m_totalMoveNum - 1
        end
    else 
        for i = 1, (realIndex - tmp + self.m_realAwardNum) do
            self.m_totalMoveNum = self.m_totalMoveNum - 1
        end
    end
    self:totalTimeNum()

end
function fuyuanBoxDlg:InitKey()
    local itemAttrCfg = BeanConfigManager.getInstance():GetTableByName("item.citemattr"):getRecorder(self.m_itemID)
    if itemAttrCfg then
        local iconManager = gGetIconManager()
        self.m_keyItem:SetImage(iconManager:GetItemIconByID(itemAttrCfg.icon) )
	    self.m_keyItem:setID(self.m_itemID)
        ShowItemTreasureIfNeed(self.m_keyItem,self.m_itemID)
        SetItemCellBoundColorByQulityItemtm(self.m_keyItem, itemAttrCfg.nquality)
        local roleItemManager = require("logic.item.roleitemmanager").getInstance()
        local nItemNum = roleItemManager:GetItemNumByBaseID(self.m_itemID)
        if nItemNum == 0 then
        	local huoliColor = "FF348539"
			local textColor = "tl:"..huoliColor.." tr:"..huoliColor.." bl:"..huoliColor.." br:"..huoliColor
			self.m_keyNum:setProperty("TextColours", textColor)
		else	
        	local huoliColor = "FF348539"
			local textColor = "tl:"..huoliColor.." tr:"..huoliColor.." bl:"..huoliColor.." br:"..huoliColor
			self.m_keyNum:setProperty("TextColours", textColor)
		end
        self.m_keyText:setText(itemAttrCfg.name)
		self.m_keyTextc:setText(itemAttrCfg.name)
		self.m_keyTextcc:setText(itemAttrCfg.namecc1)
        if string.len(itemAttrCfg.colour) > 0 then
            local textColor = "tl:"..itemAttrCfg.colour.." tr:"..itemAttrCfg.colour.." bl:"..itemAttrCfg.colour.." br:"..itemAttrCfg.colour
            self.m_keyText:setProperty("TextColours", textColor)
        end
        self.m_keyNum:setText(nItemNum.."")
    end
end
function fuyuanBoxDlg.Sfunyuan_pro(index)
    local dlg = require"logic.fuyuanbox.fuyuanboxdlg".getInstanceNotCreate()
    if dlg then
        dlg:StartRotate(index)
    end
end
function fuyuanBoxDlg:StartRotate(index)
    local record = BeanConfigManager.getInstance():GetTableByName("game.cschoolwheel"):getRecorder(self.m_KeyIndex)
    if record == nil then
        return
    end
    local strs = StringBuilder.Split(record.items[index],";")
    self.m_Stauts = 1
    self.m_startBtn:setVisible(false)
	self.m_startBtn1:setVisible(false)
    self:changeRealAwardPos(tonumber(strs[1]))
    --gGetGameUIManager():RemoveUIEffect(self.m_boxItem[self.m_curAwardIndex])
end
function fuyuanBoxDlg:InitItem()
    local record = BeanConfigManager.getInstance():GetTableByName("game.cschoolwheel"):getRecorder(self.m_KeyIndex)
    if record == nil then
        return
    end
    for i = 1, 25 do
        local strs = StringBuilder.Split(record.items[i-1],";")
        local itemAttrCfg = BeanConfigManager.getInstance():GetTableByName("item.citemattr"):getRecorder(tonumber(strs[1]))
        if itemAttrCfg then
            self.m_itemsData[i] = tonumber(strs[1])
        end

    end
end
function fuyuanBoxDlg:HandleItemClicked(args)
	local e = CEGUI.toMouseEventArgs(args)
	local touchPos = e.position
	local nPosX = touchPos.x
	local nPosY = touchPos.y
	
	local index = e.window:getID()
	
	local Commontipdlg = require "logic.tips.commontipdlg"
	local commontipdlg = Commontipdlg.getInstanceAndShow()
	local nType = Commontipdlg.eNormal
	local nItemId = index
	
	commontipdlg:RefreshItem(nType,nItemId,nPosX,nPosY)
end
function fuyuanBoxDlg:HandleEndClicked(args)
	local pro = require "protodef.fire.pb.game.cendxueyuewheel".Create()
    LuaProtocolManager.getInstance():send(pro)

	gGetGameUIManager():RemoveUIEffect(self.m_ItemCellEffect)

    self.DestroyDialog()
	self:GotoNextGoods()
end
function fuyuanBoxDlg:HandleStartClicked(args)
    local roleItemManager = require("logic.item.roleitemmanager").getInstance()
    local nItemNum = roleItemManager:GetItemNumByBaseID(self.m_itemID)

    if nItemNum == 0 then
        local recordQuickBuy = BeanConfigManager.getInstance():GetTableByName(CheckTableName("shop.cquickbuy")):getRecorder(self.m_itemID)
        if not recordQuickBuy then
		    local configItem = BeanConfigManager.getInstance():GetTableByName("item.citemattr"):getRecorder(self.m_itemID)
            if configItem then
		        local name = configItem.name;
		
		        local strbuilder = StringBuilder:new()
		        strbuilder:Set("parameter1", name)
		        local tempStrTip = strbuilder:GetString(MHSD_UTILS.get_msgtipstring(150020))
                strbuilder:delete()
		        GetCTipsManager():AddMessageTip(tempStrTip)
            end
        else
            ShopManager:tryQuickBuy(self.m_itemID)
        end
        return
    end
    --��Э��
    local pro = require "protodef.fire.pb.game.cbeginxueyuewheel".Create()
    pro.boxtype = self.m_KeyIndex
    pro.npckey = self.m_NpcKey
	pro.shilian = 1--这个代表不是10连抽
    LuaProtocolManager.getInstance():send(pro)

	--��������Ч
	local winMgr = CEGUI.WindowManager:getSingleton()
	local tmp = winMgr:getWindow("fuyuanbaoxiang/paomadeng")

	local w = tmp:getPixelSize().width/2
	local h = tmp:getPixelSize().height/2

	gGetGameUIManager():AddUIEffect(tmp, MHSD_UTILS.get_effectpath(11078), true, w, h)

	m_ClickStart = true
end
function fuyuanBoxDlg:HandleShiLianClicked(args)
    local roleItemManager = require("logic.item.roleitemmanager").getInstance()
    local nItemNum = roleItemManager:GetItemNumByBaseID(self.m_itemID)

    if nItemNum < 10 then
        local recordQuickBuy = BeanConfigManager.getInstance():GetTableByName(CheckTableName("shop.cquickbuy")):getRecorder(self.m_itemID)
        if not recordQuickBuy then
		    local configItem = BeanConfigManager.getInstance():GetTableByName("item.citemattr"):getRecorder(self.m_itemID)
            if configItem then
		        local name = configItem.name;
		
		        local strbuilder = StringBuilder:new()
		        strbuilder:Set("parameter1", name)
		        local tempStrTip = strbuilder:GetString(MHSD_UTILS.get_msgtipstring(150020))
                strbuilder:delete()
		        GetCTipsManager():AddMessageTip(tempStrTip)
            end
        else
            ShopManager:tryQuickBuy(self.m_itemID)
        end
        return
    end
    --��Э��
    self.DestroyDialog();
    local pro = require "protodef.fire.pb.game.cbeginxueyuewheel".Create()
    pro.boxtype = self.m_KeyIndex
    pro.npckey = self.m_NpcKey
	pro.shilian = 2--这个代表是10连抽
    LuaProtocolManager.getInstance():send(pro)
end
function fuyuanBoxDlg:update(delta)
    if self.m_Stauts == 1 then
    	self.m_elapse = self.m_elapse + delta
	    if self.m_elapse < self.m_totalTime then -- С����ʱ��
		    self.m_tTime = self.m_elapse
		    if self.m_moveNum < self.m_addSpeedNum+1 then -- ǰ�������ٸ���
			    self.m_speed = (self.m_addSpeedNum+1 - self.m_moveNum)*self.m_addSpeed + self.m_baseSpeed
		    elseif self.m_moveNum > self.m_totalMoveNum - self.m_slowNum then -- �󼸸����ٸ���
			    self.m_speed = (self.m_moveNum - (self.m_totalMoveNum - self.m_slowNum))*self.m_slowSpeed + self.m_baseSpeed
		    else
			    self.m_speed = self.m_baseSpeed   -- �м����ٵĸ���
		    end
		    self.m_tTime = self.m_elapse - self.m_laseTime
		    if self.m_tTime > self.m_speed then  
			    if self.m_boxBright[self.m_curAwardIndex] then
				    --self.m_boxBright[self.m_curAwardIndex]:setVisible(false) --��ǰһ���������ñ������ɼ�
			    end
			    self.m_curAwardIndex = self.m_curAwardIndex + 1
			    self.m_moveNum = self.m_moveNum + 1
			    if self.m_curAwardIndex > self.m_realAwardNum then  
				    self.m_curAwardIndex = 1   -- ���ø��ӱ��
			    end
			    if self.m_boxBright[self.m_curAwardIndex] then
				    --self.m_boxBright[self.m_curAwardIndex]:setVisible(true)

					local winMgr = CEGUI.WindowManager:getSingleton()
					local tmp = winMgr:getWindow("fuyuanbaoxiang")
	
					local pos = self.m_CellParent[self.m_curAwardIndex]:getPosition()
					local x = pos.x.offset + self.m_CellParent[self.m_curAwardIndex]:getPixelSize().width/2
					local y = pos.y.offset + self.m_CellParent[self.m_curAwardIndex]:getPixelSize().height/2
					local offx = tmp:getXPosition():asAbsolute(tmp:getParent():getPixelSize().width)--tmp:getPosition().x.offset
					local offy = tmp:getYPosition():asAbsolute(tmp:getParent():getPixelSize().height)
					self.m_ItemCellEffect:SetLocation(Nuclear.NuclearPoint(offx + x, offy + y))
			    end
			    self.m_laseTime = self.m_laseTime + self.m_speed
			
			    if self.m_moveNum == self.m_totalMoveNum then  -- ת�꽫ok��ť����
				    local pro = require "protodef.fire.pb.game.cendxueyuewheel".Create()
                    LuaProtocolManager.getInstance():send(pro)

						local winMgr = CEGUI.WindowManager:getSingleton()
						local tmp = winMgr:getWindow("fuyuanbaoxiang/paomadeng")
						gGetGameUIManager():RemoveUIEffect(tmp)
			    end
		    end
	    elseif self.m_elapse > self.m_totalTime + self.m_closeTime then

			gGetGameUIManager():RemoveUIEffect(self.m_ItemCellEffect)

		    self.DestroyDialog()
			self:GotoNextGoods()
	    end
    end
end

function fuyuanBoxDlg:GotoNextGoods()
	if not m_ClickStart then
		return
	end

	m_ClickStart = false

	local roleItemManager = require("logic.item.roleitemmanager").getInstance()
	local nItemNum = roleItemManager:GetItemNumByBaseID(self.m_itemID)

	local yinbox = tonumber(GameTable.common.GetCCommonTableInstance():getRecorder(283).value)
	local jinbox = tonumber(GameTable.common.GetCCommonTableInstance():getRecorder(282).value)
	local huanbox = tonumber(GameTable.common.GetCCommonTableInstance():getRecorder(487).value)
	local erbox = tonumber(GameTable.common.GetCCommonTableInstance():getRecorder(489).value)
	local sanbox = tonumber(GameTable.common.GetCCommonTableInstance():getRecorder(491).value)

	for i = 1, gGetScene():GetSceneNPCNum() do
		local npc = gGetScene():GetSceneNPC(i)
		if npc:GetNpcTypeID() == 29 and nItemNum >= 1 then
			if self.m_KeyIndex == 2 then
				if npc:GetNpcBaseID() == jinbox then
					GetMainCharacter():OnVisitNpc(npc)
					break
				end
			end
			if self.m_KeyIndex == 3 then
			    if npc:GetNpcBaseID() == yinbox then
					GetMainCharacter():OnVisitNpc(npc)
					break
			    end
			end
			if self.m_KeyIndex == 4 then
			    if npc:GetNpcBaseID() == huanbox then
					GetMainCharacter():OnVisitNpc(npc)
					break
				end
			end
			if self.m_KeyIndex == 5 then
			    if npc:GetNpcBaseID() == erbox then
					GetMainCharacter():OnVisitNpc(npc)
					break
				end
			end
			if self.m_KeyIndex == 6 then
			    if npc:GetNpcBaseID() == sanbox then
					GetMainCharacter():OnVisitNpc(npc)
					break
				end
			end
			
		end
	end
end



return fuyuanBoxDlg