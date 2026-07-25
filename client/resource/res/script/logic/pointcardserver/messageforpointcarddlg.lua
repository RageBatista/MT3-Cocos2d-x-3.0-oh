require "logic.dialog"

MessageForPointCardDlg = {}
setmetatable(MessageForPointCardDlg, Dialog)
MessageForPointCardDlg.__index = MessageForPointCardDlg

local _instance
function MessageForPointCardDlg.getInstance()
	if not _instance then
		_instance = MessageForPointCardDlg:new()
		_instance:OnCreate()
	end
	return _instance
end

function MessageForPointCardDlg.getInstanceAndShow()
	if not _instance then
		_instance = MessageForPointCardDlg:new()
		_instance:OnCreate()
	else
		_instance:SetVisible(true)
	end
	return _instance
end

function MessageForPointCardDlg.getInstanceNotCreate()
	return _instance
end

function MessageForPointCardDlg.DestroyDialog()
	if _instance then 
		if not _instance.m_bCloseIsHide then
			_instance:OnClose()
			_instance = nil
		else
			_instance:ToggleOpenClose()
		end
	end
end

function MessageForPointCardDlg.ToggleOpenClose()
	if not _instance then
		_instance = MessageForPointCardDlg:new()
		_instance:OnCreate()
	else
		if _instance:IsVisible() then
			_instance:SetVisible(false)
		else
			_instance:SetVisible(true)
		end
	end
end

function MessageForPointCardDlg.GetLayoutFileName()
	return "messageboxfuwu.layout"
end

function MessageForPointCardDlg:new()
	local self = {}
	self = Dialog:new()
	setmetatable(self, MessageForPointCardDlg)
	return self
end

function MessageForPointCardDlg:OnCreate()
	Dialog.OnCreate(self)
	local winMgr = CEGUI.WindowManager:getSingleton()
    
	self.m_btnQuitgeren = CEGUI.toPushButton(winMgr:getWindow("messageboxfuwu/Canle11"))---法宝进阶
    self.m_btnQuitGame = CEGUI.toPushButton(winMgr:getWindow("messageboxfuwu/Canle"))---特技定制
	self.m_btnAdd = CEGUI.toPushButton(winMgr:getWindow("messageboxfuwu/OK"))----器灵套装
	self.m_btnAddchonghzhi = CEGUI.toPushButton(winMgr:getWindow("messageboxfuwu/zaixianchongzhi"))---器灵开孔
	self.m_btnAddxiangqian = CEGUI.toPushButton(winMgr:getWindow("messageboxfuwu/Canle51"))---器灵镶嵌
	self.m_btnAddzhuanzhi = CEGUI.toPushButton(winMgr:getWindow("messageboxfuwu/Canle2"))---门派转换	
	self.m_btnAddzuoqixl = CEGUI.toPushButton(winMgr:getWindow("messageboxfuwu/Canle211"))---坐骑洗炼	
	self.m_btnAddshenshoudh = CEGUI.toPushButton(winMgr:getWindow("messageboxfuwu/Canle2112"))---神兽兑换
	self.m_btnAddshenshouts = CEGUI.toPushButton(winMgr:getWindow("messageboxfuwu/Canle2111"))---神兽提升
    self.m_btnAddgonglue = CEGUI.toPushButton(winMgr:getWindow("messageboxfuwu/Canle21"))---攻略大全
	self.m_btnBaoshizhuan = CEGUI.toPushButton(winMgr:getWindow("messageboxfuwu/CanBao"))---宝石转换
    self.m_btnWuqizhuan = CEGUI.toPushButton(winMgr:getWindow("messageboxfuwu/CanWuqi"))---武器转换	

    

	
	self.m_btnBuyOrSell = CEGUI.toPushButton(winMgr:getWindow("messageboxfuwu/Canle1"))
	self.m_btnguanbi = CEGUI.toPushButton(winMgr:getWindow("messageboxfuwu/CloseButton"))
	

    self.m_btnBuyOrSell:subscribeEvent("Clicked", MessageForPointCardDlg.handleBuyOrSellBtnClicked, self) 
	self.m_btnQuitgeren:subscribeEvent("Clicked", MessageForPointCardDlg.handleBuyOrSellBtnClickedgeren, self) ----法宝进阶
	self.m_btnQuitGame:subscribeEvent("Clicked", MessageForPointCardDlg.handleQuitBtnClicked, self)----特技定制
    self.m_btnAdd:subscribeEvent("Clicked", MessageForPointCardDlg.handleAddtBtnClicked, self)---器灵套装
	self.m_btnAddchonghzhi:subscribeEvent("Clicked", MessageForPointCardDlg.handleAddtBtnchongzhi, self)---器灵开孔
	self.m_btnAddxiangqian:subscribeEvent("Clicked", MessageForPointCardDlg.handleAddtBtnxiangqian, self)---器灵镶嵌
	self.m_btnAddzhuanzhi:subscribeEvent("Clicked", MessageForPointCardDlg.handleAddtBtnzhuanzhi, self)---门派转换
	self.m_btnAddzuoqixl:subscribeEvent("Clicked", MessageForPointCardDlg.handleAddtBtnzuoqixl, self)---坐骑洗炼
	self.m_btnAddshenshoudh:subscribeEvent("Clicked", MessageForPointCardDlg.handleAddtBtnshenshoudh, self)---神兽兑换
	self.m_btnAddshenshouts:subscribeEvent("Clicked", MessageForPointCardDlg.handleAddtBtnshenshouts, self)---神兽提升
	self.m_btnAddgonglue:subscribeEvent("Clicked", MessageForPointCardDlg.handleAddtBtngonglue, self)---攻略大全
	self.m_btnBaoshizhuan:subscribeEvent("Clicked", MessageForPointCardDlg.handleAddtBtnbaoshizhuan, self)---宝石转换
	self.m_btnWuqizhuan:subscribeEvent("Clicked", MessageForPointCardDlg.handleAddtBtnwuqizhuan, self)---武器转换
	
	self.m_btnguanbi:subscribeEvent("Clicked", MessageForPointCardDlg.handguanbi, self)
    --self:GetWindow():subscribeEvent("ZChanged", MessageForPointCardDlg.handleZchange, self)
    self.m_text = winMgr:getWindow("messageboxfuwu/text")
    self.movingToFront = false
    self:refreshbtn()
	
	
	local strVer = GetServerInfo():getHttpAdressByEnum(eHttpJinglingUrl)
    self.m_text:setText(strVer)


	
end
function MessageForPointCardDlg:refreshbtn()
    local funopenclosetype = require("protodef.rpcgen.fire.pb.funopenclosetype"):new()
    local manager = require "logic.pointcardserver.pointcardservermanager".getInstanceNotCreate()
    if manager then
        if manager.m_OpenFunctionList.info then
            for i,v in pairs(manager.m_OpenFunctionList.info) do
                if v.key == funopenclosetype.FUN_CHECKPOINT then
                    if v.state == 1 then
                        self.m_btnBuyOrSell:setVisible(false)
                        self.m_text:setText(MHSD_UTILS.get_resstring(11594))
                        break
                    end
                end
            end
        end
    end
end
function MessageForPointCardDlg:handleZchange(e)
    if not self.movingToFront then
        self.movingToFront = true
        if self:GetWindow():getParent() then
            local drawList = self:GetWindow():getParent():getDrawList()
            if drawList:size() > 0 then
                local topWnd = drawList[drawList:size()-1]
                local wnd = tolua.cast(topWnd, "CEGUI::Window")
                if wnd:getName() == "NewsWarn" then
                    if drawList:size() > 2 then
                        local secondWnd = drawList[drawList:size()-1]
                        self:GetWindow():getParent():bringWindowAbove(self:GetWindow(), tolua.cast(secondWnd, "CEGUI::Window"))
                    end
                else
                    self:GetWindow():getParent():bringWindowAbove(self:GetWindow(), tolua.cast(topWnd, "CEGUI::Window"))
                end
                
            end
        end
        self.movingToFront = false
    end
end
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

function MessageForPointCardDlg:handleBuyOrSellBtnClickedgeren(e)----法宝进阶
	require "logic.workshop.workshopaq".getInstanceAndShow()
    MessageForPointCardDlg.DestroyDialog()
end

function MessageForPointCardDlg:handleQuitBtnClicked(e)----法宝重铸
	require "logic.workshop.tejidingzhi".getInstanceAndShow()
    MessageForPointCardDlg.DestroyDialog()
end

function MessageForPointCardDlg:handleAddtBtnClicked(e)---器灵套装
   require "logic.workshop.Attunement".getInstanceAndShow()
    MessageForPointCardDlg.DestroyDialog()
end

function MessageForPointCardDlg:handleAddtBtnchongzhi(e)---器灵开孔
   require "logic.workshop.superronglian".getInstanceAndShow()
    MessageForPointCardDlg.DestroyDialog()
end

function MessageForPointCardDlg:handleAddtBtnxiangqian(e)---器灵镶嵌
   require "logic.workshop.zhuangbeifumo".getInstanceAndShow()
    MessageForPointCardDlg.DestroyDialog()
end

function MessageForPointCardDlg:handleAddtBtnbaoshizhuan(e)---宝石转换
   require "logic.zhuanzhi.zhuanzhibaoshi".getInstanceAndShow()
    MessageForPointCardDlg.DestroyDialog()
end

function MessageForPointCardDlg:handleAddtBtnwuqizhuan(e)---武器转换
   require "logic.workshop.weaponswitch".getInstanceAndShow()
    MessageForPointCardDlg.DestroyDialog()
end

function MessageForPointCardDlg:handleAddtBtnzhuanzhi(e)---门派转换
    ZhuanZhiDlg.getInstanceAndShow() -- 职业转换
    if _instance then
        if not _instance.m_bCloseIsHide then
            _instance:OnClose()
            _instance = nil
        else
            _instance:ToggleOpenClose()
        end
    end
end

--[[function MessageForPointCardDlg:handleAddtBtnzhuanzhi(args)
--function MessageForPointCardDlg:handleAddtBtnzhuanzhi(args)
	if self.selectedCellIdx == -1 then
		return
	end
	
	if numkeyboardcdlg.getInstanceNotCreate() then
		numkeyboardcdlg.getInstanceNotCreate():SetVisible(true) --保持键盘在最上面
		return
	end
	
	local dlg = numkeyboardcdlg.getInstanceAndShow()
	if dlg then
		dlg:setTriggerBtn(self.buyNumText)
		dlg:setMaxValue(self.maxNum)
		dlg:setInputChangeCallFunc(CommerceDlg.onNumInputChanged, self)
		
		local p = self.buyNumText:GetScreenPos()
		SetPositionOffset(dlg:GetWindow(), p.x-110, p.y-10, 0, 1)
	end
end--]]


function MessageForPointCardDlg:handleAddtBtnzuoqixl(args)-----坐骑升级
   require("logic.workshop.workshopaq1").getInstanceAndShow()
    MessageForPointCardDlg.DestroyDialog()
end

function MessageForPointCardDlg:handleAddtBtnshenshoudh(args)-----装备熔炼

    local waManager = require "logic.workshop.workshopmanager".getInstance()
    local nShowType = waManager.nShowType
    WorkshopLabel.Show(3, 3, 0)
    self.m_fAutoHideTime = 0
    MessageForPointCardDlg.DestroyDialog()
    return true
end

function MessageForPointCardDlg:handleAddtBtnshenshouts(args)-----神兽提升
    require"logic.pet.shenshoucommon".Increase(itemname, npckey, needpetbaseid) -- 神兽提升
    if _instance then
        if not _instance.m_bCloseIsHide then
            _instance:OnClose()
            _instance = nil
        else
            _instance:ToggleOpenClose()
        end
    end
end


function MessageForPointCardDlg:handleAddtBtngonglue(args)
	IOS_MHSD_UTILS.OpenURL("https://docs.qq.com/doc/DR2JPaGZDRnd6d3J3?from_page=save")---攻略大全
	--require("logic.zhuanzhi.ZhuanZhiWuQiDlg").getInstanceAndShow()
   MessageForPointCardDlg.DestroyDialog()
end 






function MessageForPointCardDlg:handleBuyOrSellBtnClicked(e)
	
	-- require "handler.fire_pb_fushi"
	-- if b_fire_pb_fushi_OpenTrading == 1 then
		-- self:GetWindow():setVisible(false)
		-- require("logic.shop.stalllabel").show(3)
	-- else
		-- GetCTipsManager():AddMessageTip(MHSD_UTILS.get_msgtipstring(300011))
	-- end
	
	
	if _instance then 
		if not _instance.m_bCloseIsHide then
			_instance:OnClose()
			_instance = nil
		else
			_instance:ToggleOpenClose()
		end
	end
	
	
	
	
	
	
	
	
end



function MessageForPointCardDlg:handguanbi(e)
	if _instance then 
		if not _instance.m_bCloseIsHide then
			_instance:OnClose()
			_instance = nil
		else
			_instance:ToggleOpenClose()
		end
	end
end



return MessageForPointCardDlg