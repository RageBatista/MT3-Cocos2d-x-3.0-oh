require "logic.dialog"

VipDialog = {}
setmetatable(VipDialog, Dialog)
VipDialog.__index = VipDialog
VipDialog.m_MaxVipLevel = 16
VipDialog.m_VipIconIndex = 1000

local _instance

function VipDialog:OnCreate()
	Dialog.OnCreate(self)

    self:SwitchVipState()
    
    -- ����Ϣ����VIP��Ϣ�����ɹ����ٴ���.
    require "protodef.fire.pb.fushi.crequestvipinfo"
    local msg = CRequestVipInfo.Create()
    LuaProtocolManager.getInstance():send(msg)
end

function VipDialog.create()
    if not _instance then
		_instance = VipDialog:new()
		_instance:OnCreate()
	end
	return _instance
end

function VipDialog.remove()
     _instance = nil
end

function VipDialog.getInstance()
	if not _instance then
		_instance = VipDialog:new()
		_instance:OnCreate()
	end
	return _instance
end

function VipDialog.getInstanceAndShow()
	if not _instance then
		_instance = VipDialog:new()
		_instance:OnCreate()
	else
		_instance:SetVisible(true)
	end
	return _instance
end

function VipDialog.getInstanceNotCreate()
	return _instance
end

function VipDialog.DestroyDialog()
	if _instance then 
		if not _instance.m_bCloseIsHide then
			_instance:OnClose()
			_instance = nil
		else
			_instance:ToggleOpenClose()
		end
	end
end

function VipDialog.ToggleOpenClose()
	if not _instance then
		_instance = VipDialog:new()
		_instance:OnCreate()
	else
		if _instance:IsVisible() then
			_instance:SetVisible(false)
		else
			_instance:SetVisible(true)
		end
	end
end

function VipDialog.GetLayoutFileName()
	return "viplibao.layout"
end

function VipDialog:new()
	local self = {}
	self = Dialog:new()
	setmetatable(self, VipDialog)
	return self
end

-- ����VIP����Ϣ
-- ����1 ��ҵ�ǰ��VIP�ȼ�
-- ����2 ��ҿ��Դﵽ��VIP�ȼ�
-- ����3 �ѳ��ʯ��
function VipDialog:SetVipInfo(vipLevel,goVipLevel,vipExp)
	
    self.m_VipLevel = vipLevel
    self.m_GoVipLevel = goVipLevel
    self.m_VipExp = vipExp

    self.m_IsMaxVipLevel = self.m_VipLevel == VipDialog.m_MaxVipLevel
    if self.m_IsMaxVipLevel then
        self.m_VipLevel = vipLevel - 1
    end

    local table =  BeanConfigManager.getInstance():GetTableByName("fushi.cvipinfo")
	-- ȡ��ǰ����
    local curRecord = table:getRecorder(self.m_VipLevel)
    local curRecordExp = 0
    if curRecord ~= nil then
        curRecordExp = curRecord.exp;
    end
    -- ȡ��һ������
    local nextRecord = table:getRecorder(self.m_VipLevel + 1)
    if nextRecord == nil then
        return
    end

    -- ������VIPͼ��
    local winMgr = CEGUI.WindowManager:getSingleton()
    local leftVipIconWnd = winMgr:getWindow("VIPBG/leftVipIcon")
    local iconName = "set:vip1 image:vip" .. (self.m_VipLevel+1)
    if self.m_VipLevel >= 21 then
        iconName = "set:vip2 image:VIP" .. (self.m_VipLevel+1)
    end
    leftVipIconWnd:setProperty("Image",iconName)
    -- ���ý�����
	local progressWnd = CEGUI.toProgressBar(winMgr:getWindow("VIPBG/Progress"))
    if vipExp < nextRecord.exp and vipExp >= curRecordExp then
        progressWnd:setText(vipExp.."/"..nextRecord.exp)
        progressWnd:setProgress((vipExp-curRecordExp)/(nextRecord.exp-curRecordExp))
    elseif vipExp >= nextRecord.exp then
        progressWnd:setText(nextRecord.exp.."/"..nextRecord.exp)
        progressWnd:setProgress(1.0)
    else
        progressWnd:setText(vipExp.."/"..nextRecord.exp)
        progressWnd:setProgress(0.0)
    end
    -- ���û���Ҫ��ֵ������
	local fuShiTextWnd = winMgr:getWindow("VIPBG/typeText2")
    local fuShiTypeWnd = winMgr:getWindow("VIPBG/typeText")
    if vipExp < nextRecord.exp then
        fuShiTextWnd:setText(tostring(nextRecord.exp-vipExp).."元")
    else
        fuShiTextWnd:setText("0元")
    end
    fuShiTypeWnd:setVisible(not self.m_IsMaxVipLevel)
    fuShiTextWnd:setVisible(not self.m_IsMaxVipLevel)
    -- ���÷�ʯͼ���λ��
    local width = fuShiTextWnd:getProperty("HorzExtent") + 50
	local fuShiIconWnd = winMgr:getWindow("VIPBG/fushiicon")
    local newPosX = fuShiTextWnd:getXPosition()
    fuShiIconWnd:setXPosition(CEGUI.UDim(0,newPosX.offset + width))
    fuShiIconWnd:setVisible(false)--not self.m_IsMaxVipLevel
    -- ������Ȩ�ı�
    local tequanTypeWnd = winMgr:getWindow("VIPBG/jianglibg/typeText1")
    local strbuilder = StringBuilder:new()
    strbuilder:Set("parameter1", self.m_VipLevel+1)
    local msg=strbuilder:GetString(MHSD_UTILS.get_msgtipstring(190022))
    strbuilder:delete()
    tequanTypeWnd:setText(msg)

	local tequan1TextWnd = winMgr:getWindow("VIPBG/jianglibg/typeText2")
	local tequan2TextWnd = winMgr:getWindow("VIPBG/jianglibg/typeText3")
    local tequan3TextWnd = winMgr:getWindow("VIPBG/jianglibg/typeText31")
    tequan1TextWnd:setText(nextRecord.type1)
    tequan2TextWnd:setText(nextRecord.type2)
    tequan3TextWnd:setText(nextRecord.type3)

    -- ���õ���
    for i=1,5 do
        local itemWnd = CEGUI.toItemCell(winMgr:getWindow("VIPBG/jianglibg/item"..i))
        itemWnd:setVisible(false)
    end
    local items = nextRecord.itemids
    local itemscount = nextRecord.itemcounts
    for i=0,items:size()-1 do
        local itemWnd = CEGUI.toItemCell(winMgr:getWindow("VIPBG/jianglibg/item"..i + 1))
        local itemId = items[i]
		local item = BeanConfigManager.getInstance():GetTableByName("item.citemattr"):getRecorder(itemId);
        local itemIcon = gGetIconManager():GetItemIconByID(item.icon)
        if itemscount[i] ~= 0 then
            itemWnd:setVisible(true)
            itemWnd:setID(itemId)
            itemWnd:SetImage(itemIcon)
            if itemscount[i] > 0 then
                itemWnd:SetTextUnit(itemscount[i])
            end
            SetItemCellBoundColorByQulityItemWithId(itemWnd,items[i])
        end
    end

    -- �շѰ�ť�ɷ�
    self.m_GetState = vipLevel < goVipLevel and goVipLevel > 0 -- �Ƿ�����ȡ״̬.
    local chargedBtn = CEGUI.toPushButton(winMgr:getWindow("VIPBG/ChongZhiBtn"))
    local lingquBtn = CEGUI.toPushButton(winMgr:getWindow("VIPBG/LingQuBtn"))

    if vipLevel < goVipLevel then
        lingquBtn:setVisible(true)
        chargedBtn:setVisible(false)
    else
        lingquBtn:setVisible(false)
        chargedBtn:setVisible(vipLevel < VipDialog.m_MaxVipLevel)
    end

end

-- �л���VIP�Ի���.
-- ����1 ��ǰ��VIP�ȼ�
-- ����2 �ѳ��ʯ��
-- ����3 ���콱��
-- ����4 ���콱��
function VipDialog:SwitchVipState()    

    local winMgr = CEGUI.WindowManager:getSingleton()
    local chargedBtn = CEGUI.toPushButton(winMgr:getWindow("VIPBG/ChongZhiBtn"))
	--IOS_MHSD_UTILS.OpenURL("https://docs.qq.com/doc/DUmthYW9waGlWdlNF")
    chargedBtn:subscribeEvent("Clicked",VipDialog.HandleChargedButton,self)
	
	
	local ChongZhiVIPBtn = CEGUI.toPushButton(winMgr:getWindow("VIPBG/ChongZhiVIPBtn"))
    ChongZhiVIPBtn:subscribeEvent("Clicked",VipDialog.HandleChargedChongZhiVIPBtn,self)
	
	

    local lingquBtn = CEGUI.toPushButton(winMgr:getWindow("VIPBG/LingQuBtn"))
    lingquBtn:subscribeEvent("Clicked",VipDialog.HandleGetItemsButton,self)

    --��װͼ���¼�
    for i=1,5 do
        local itemWnd = CEGUI.toItemCell(winMgr:getWindow("VIPBG/jianglibg/item"..i))
        itemWnd:subscribeEvent("TableClick", GameItemTable.HandleShowToolTipsWithItemID)
    end

end


--��ת����ҳ�̳�.
local function encodeBase64(source_str)
    local b64chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/'
    local s64 = ''
    local str = source_str
 
    while #str > 0 do
        local bytes_num = 0
        local buf = 0
 
        for byte_cnt=1,3 do
            buf = (buf * 256)
            if #str > 0 then
                buf = buf + string.byte(str, 1, 1)
                str = string.sub(str, 2)
                bytes_num = bytes_num + 1
            end
        end
 
        for group_cnt=1,(bytes_num+1) do
            local b64char = math.fmod(math.floor(buf/262144), 64) + 1
            s64 = s64 .. string.sub(b64chars, b64char, b64char)
            buf = buf * 64
        end
 
        for fill_cnt=1,(3-bytes_num) do
            s64 = s64 .. '='
        end
    end
 
    return s64
end
function VipDialog:HandleChargedButton(args)
    require("logic.shop.shoplabel").getInstance():showOnly(3)
        -- require("logic.libaoduihuan.libaoduihuanma")
        -- Libaoduihuanma.getInstanceAndShow()
    --IOS_MHSD_UTILS.OpenURL("https://docs.qq.com/doc/DUmthYW9waGlWdlNF")
end


--��ת���շ�.
--function VipDialog:HandleChargedChongZhiVIPBtn(args)---福利界面的VIP礼包更改为跳转腾讯文档
--	IOS_MHSD_UTILS.OpenURL("https://docs.qq.com/doc/DUmthYW9waGlWdlNF")
--end 

function VipDialog:HandleChargedChongZhiVIPBtn(args)
        -- require("logic.libaoduihuan.libaoduihuanma")
        -- Libaoduihuanma.getInstanceAndShow()
    require("logic.shop.shoplabel").getInstance():showOnly(3)
end

-- ��ȡ����.
function VipDialog:HandleGetItemsButton(args)
	require "protodef.fire.pb.fushi.crequestvipjiangli"
	local msg = CRequestVipJiangli.Create()
    msg.bounusindex = self.m_VipLevel + 1;
	LuaProtocolManager.getInstance():send(msg)
end

return VipDialog