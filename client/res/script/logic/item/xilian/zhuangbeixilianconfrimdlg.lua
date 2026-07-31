require "logic.dialog"

ZhuangBeiXiLianConfirmDlg = {}
setmetatable(ZhuangBeiXiLianConfirmDlg, Dialog)
ZhuangBeiXiLianConfirmDlg.__index = ZhuangBeiXiLianConfirmDlg

local _instance
function ZhuangBeiXiLianConfirmDlg.getInstance()
    if not _instance then
        _instance = ZhuangBeiXiLianConfirmDlg:new()
        _instance:OnCreate()
    end
    return _instance
end

function ZhuangBeiXiLianConfirmDlg.getInstanceAndShow()
    if not _instance then
        _instance = ZhuangBeiXiLianConfirmDlg:new()
        _instance:OnCreate()
    else
        _instance:SetVisible(true)
    end
    return _instance
end

function ZhuangBeiXiLianConfirmDlg.getInstanceNotCreate()
    return _instance
end

function ZhuangBeiXiLianConfirmDlg.DestroyDialog()
    if _instance then
        if not _instance.m_bCloseIsHide then
            _instance:OnClose()
            _instance = nil
        else
            _instance:ToggleOpenClose()
        end
    end
end

function ZhuangBeiXiLianConfirmDlg.ToggleOpenClose()
    if not _instance then
        _instance = ZhuangBeiXiLianConfirmDlg:new()
        _instance:OnCreate()
    else
        if _instance:IsVisible() then
            _instance:SetVisible(false)
        else
            _instance:SetVisible(true)
        end
    end
end

function ZhuangBeiXiLianConfirmDlg.GetLayoutFileName()
    return "zhuangbeixilianqueren.layout"
end

function ZhuangBeiXiLianConfirmDlg:new()
    local self = {}
    self = Dialog:new()
    setmetatable(self, ZhuangBeiXiLianConfirmDlg)
    return self
end

function ZhuangBeiXiLianConfirmDlg:OnCreate()
    Dialog.OnCreate(self)
    local winMgr = CEGUI.WindowManager:getSingleton()

    --local needmoney = GameTable.common.GetCCommonTableInstance():getRecorder(433).value
    self.m_NeedYinBi = winMgr:getWindow("zhuangbeixilianqueren/kuang/di/text")

    self.m_OKBtn = CEGUI.toPushButton(winMgr:getWindow("zhuangbeixilianqueren/queren"))
    self.m_OKBtn:subscribeEvent("MouseButtonUp", ZhuangBeiXiLianConfirmDlg.HandlerOkBtn, self)

    self.m_CancelBtn = CEGUI.toPushButton(winMgr:getWindow("zhuangbeixilianqueren/quxiao"))
    self.m_CancelBtn:subscribeEvent("MouseButtonUp", ZhuangBeiXiLianConfirmDlg.HandlerCancelBtn, self)

    self.m_TextInfo = CEGUI.toRichEditbox(winMgr:getWindow("zhuangbeixilianqueren/miaoshu"))

    self.m_key = 0
    self.m_id = 0

end

function ZhuangBeiXiLianConfirmDlg:SetInfoData(text1, key, id)
    local needChangeItemNum = require "logic.item.xilian.zhuangbeixiliandlg".getInstanceNotCreate():getNeedChangeItemNum(id)
    self.m_NeedYinBi:setText(tostring(needChangeItemNum))

    local tip = GameTable.message.GetCMessageTipTableInstance():getRecorder(191112)

    local sb = require "utils.stringbuilder":new()
    sb:Set("parameter1", text1)
    local strmsg = sb:GetString(tip.msg)
    sb:delete()

    self.m_key = key
    self.m_id = id

    self.m_TextInfo:AppendParseText(CEGUI.String(strmsg), false)
    self.m_TextInfo:Refresh()
end

function ZhuangBeiXiLianConfirmDlg:HandlerOkBtn(e)
    local cmd = require "protodef.fire.pb.item.xilian.cxilianzhuangbei".Create()
    cmd.srcweaponkey = self.m_key
    LuaProtocolManager.getInstance():send(cmd)

    ZhuangBeiXiLianConfirmDlg.DestroyDialog()
    --转换完成刷新数据
    local zhuangbeixiliandlg = require "logic.item.xilian.zhuangbeixiliandlg".getInstance()
    zhuangbeixiliandlg:RefreshAllWeaponData()
    zhuangbeixiliandlg:SetZhuangBeiXiLianDlgVisible(true)
end

function ZhuangBeiXiLianConfirmDlg:HandlerCancelBtn(e)
    ZhuangBeiXiLianConfirmDlg.DestroyDialog()
    local zhuangbeixiliandlg = require "logic.item.xilian.zhuangbeixiliandlg".getInstance()
    zhuangbeixiliandlg:SetZhuangBeiXiLianDlgVisible(true)
end

return ZhuangBeiXiLianConfirmDlg