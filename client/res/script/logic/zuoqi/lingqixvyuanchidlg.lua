require "logic.dialog"

LingQiWishDlg = {}
setmetatable(LingQiWishDlg, Dialog)
LingQiWishDlg.__index = LingQiWishDlg

local _instance
function LingQiWishDlg.getInstance()
    if not _instance then
        _instance = LingQiWishDlg:new()
        _instance:OnCreate()
    end
    return _instance
end

function LingQiWishDlg.getInstanceAndShow()
    if not _instance then
        _instance = LingQiWishDlg:new()
        _instance:OnCreate()
    else
        _instance:SetVisible(true)
    end
    return _instance
end

function LingQiWishDlg.getInstanceNotCreate()
    return _instance
end

function LingQiWishDlg.DestroyDialog()
    if _instance then
        if _instance.spine then
            _instance.spine:delete()
            _instance.spine = nil
        end
        if not _instance.m_bCloseIsHide then
            _instance:OnClose()
            _instance = nil
        else
            _instance:ToggleOpenClose()
        end
    end
end

function LingQiWishDlg.ToggleOpenClose()
    if not _instance then
        _instance = LingQiWishDlg:new()
        _instance:OnCreate()
    else
        if _instance:IsVisible() then
            _instance:SetVisible(false)
        else
            _instance:SetVisible(true)
        end
    end
end

function LingQiWishDlg.GetLayoutFileName()
    return "lingqixvyuanchi.layout"
end

function LingQiWishDlg:new()
    local self = {}
    self = Dialog:new()
    setmetatable(self, LingQiWishDlg)
    return self
end

function LingQiWishDlg:OnCreate()
    Dialog.OnCreate(self)
    local winMgr = CEGUI.WindowManager:getSingleton()
    self:InsertScriptFunctor(
        function()
            if gGetDataManager() then
                return gGetDataManager().m_EventYuanBaoNumberChange;
            end
        end ,
        function()
            self:UpdateMoneyNum();
        end
      )
  
    self.closeBtn = CEGUI.toPushButton(winMgr:getWindow("lingqixvyuanchi_main/guanbi"))
    self.ActiveSpine = winMgr:getWindow("lingqixvyuanchi_main/guge")
    self.DrawBtn = CEGUI.toPushButton(winMgr:getWindow("lingqixvyuanchi_main/cjbtn"))
	self.MoneyNum = winMgr:getWindow("lingqixvyuanchi_main/xianyu1/text1")
	self.havaNum = winMgr:getWindow("lingqixvyuanchi_main/xianyu2/text2")
	self.wenzi = winMgr:getWindow("lingqixvyuanchi_main/wenben_di/wenben")
    self.wenzi:setText("祝君好运，获得喜爱的坐骑")
	

    self.closeBtn:subscribeEvent("Clicked", LingQiWishDlg.HandleCloseBtn, self)
    self.DrawBtn:subscribeEvent("Clicked", LingQiWishDlg.HandleDrawBtn, self)

	local pos = self.ActiveSpine:GetScreenPosOfCenter()
	local loc = Nuclear.NuclearPoint(pos.x-10, pos.y+50)
    self.spine = UISpineSprite:new("sp_2023sxbbg_kv")
    self.spine:SetUILocation(loc)
    self.ActiveSpine:getGeometryBuffer():setRenderEffect(GameUImanager:createXPRenderEffect(0, LingQiWishDlg.performPostRenderFunctions))
    self.spine:SetUIScale(0.8)
	self.spine:PlayAction(eActionStandRandom)
	self.oldx=pos.x-10
	self.oldy=pos.y+50
    self:UpdateMoneyNum()
end
function LingQiWishDlg:UpdateMoneyNum()
    local fushi =  CurrencyManager.getOwnCurrencyMount(111)
    self.MoneyNum:setText(MoneyFormat(fushi))
    local need= GameTable.common.GetCCommonTableInstance():getRecorder(592).value
    self.havaNum:setText(MoneyFormat(need))
end
function LingQiWishDlg:HandleCloseBtn(args)
    self:DestroyDialog()
end
function LingQiWishDlg.performPostRenderFunctions()
	if LingQiWishDlg:getInstance().spine then
		LingQiWishDlg:getInstance().spine:RenderUISprite()
	end
end
function LingQiWishDlg:HandleDrawBtn(args)
 
     local clottermount = require "protodef.fire.pb.item.clottermount"
     local req = clottermount.Create()
     LuaProtocolManager.getInstance():send(req)
end

return LingQiWishDlg
