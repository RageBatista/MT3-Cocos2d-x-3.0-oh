require "utils.mhsdutils"
require "logic.dialog"

require "utils.commonutil"

JingMaiQianKunDan = {}
setmetatable(JingMaiQianKunDan, Dialog)
JingMaiQianKunDan.__index = JingMaiQianKunDan
local _instance;
--//===============================
function JingMaiQianKunDan:OnCreate()
    Dialog.OnCreate(self)
    --SetPositionScreenCenter(self:GetWindow())
    local winMgr = CEGUI.WindowManager:getSingleton()

    self.guanbi = CEGUI.toPushButton(winMgr:getWindow("jingmaiqiankundan/guanbi"))
    self.guanbi:subscribeEvent("MouseButtonUp", JingMaiQianKunDan.HandleguanbiClick, self)

    self.lianhua = CEGUI.toPushButton(winMgr:getWindow("jingmaiqiankundan/diban/di/btn"))
    self.lianhua:subscribeEvent("MouseButtonUp", JingMaiQianKunDan.HandlelianhuaClick, self)
    self.huoli = CEGUI.Window.toProgressBarTwoValue(winMgr:getWindow("jingmaiqiankundan/diban/di/huoli"))
    self.exp = CEGUI.Window.toProgressBarTwoValue(winMgr:getWindow("jingmaiqiankundan/diban/exp"))
    local p = require "logic.workshop.jingmai.cjingmaisel":new()
    p.idx = 10 --normal
    require "manager.luaprotocolmanager":send(p)


end
function JingMaiQianKunDan:setMain(data)
    if data.qiankundan >=4 then
        self.DestroyDialog()
        return
    end
    local qianyuandan = BeanConfigManager.getInstance():GetTableByName("skill.cjingmaiqiankundan"):getRecorder(data.qiankundan+1)
    if not qianyuandan then
        return
    end
    self.data=data
    local data = gGetDataManager():GetMainCharacterData()
    local xuqiuhuoli = qianyuandan.huoli
    local huoli = data:GetValue(fire.pb.attr.AttrType.ENERGY)
    --local pro = self.m_red:getProgress()
    local dest = huoli/xuqiuhuoli

    if dest< 0.000001 then
        self.huoli:setProgress(0.0)
    elseif dest >= 1.0 then
        self.huoli:setProgress(1.0)
    else
        self.huoli:setProgress(dest)
    end
    self.huoli:setText(huoli.."/"..xuqiuhuoli)




    local xuqiuexp = qianyuandan.exp
    local exp = data.exp
    --local pro = self.m_red:getProgress()
    local dest = exp / xuqiuexp

    if dest< 0.000001 then
        self.exp:setProgress(0.0)
    elseif dest >= 1.0 then
        self.exp:setProgress(1.0)
    else
        self.exp:setProgress(dest)
    end
    self.exp:setText(exp.."/"..xuqiuexp)
end

function JingMaiQianKunDan:HandleguanbiClick(arg)
    self.DestroyDialog()
end

function JingMaiQianKunDan:HandlelianhuaClick(arg)
    if self.data.qiankundan>=4 then
        return
    end

	if self.exp:getProgress() < 1 then
		GetCTipsManager():AddMessageTip("当前经验不足，无法炼化乾坤丹")
	    return
	
	end
	if self.huoli:getProgress() < 1 then
		GetCTipsManager():AddMessageTip("当前活力不足，无法炼化乾坤丹")
        return

	end

		GetCTipsManager():AddMessageTip("成功炼化乾坤丹！")

    local p = require "logic.workshop.jingmai.cjingmaisel":new()
    p.idx = 12 --normal
    require "manager.luaprotocolmanager":send(p)
end


function JingMaiQianKunDan.getInstance()
    if not _instance then
        _instance = JingMaiQianKunDan:new()
        _instance:OnCreate()
    end
    return _instance
end

function JingMaiQianKunDan.getInstanceAndShow()
    if not _instance then
        _instance = JingMaiQianKunDan:new()
        _instance:OnCreate()
    else
        _instance:SetVisible(true)
    end
    return _instance
end

function JingMaiQianKunDan.getInstanceNotCreate()
    return _instance
end

function JingMaiQianKunDan.getInstanceOrNot()
    return _instance
end

function JingMaiQianKunDan.GetLayoutFileName()
    return "jingmaiqiankundan.layout"
end

function JingMaiQianKunDan:new()
    local self = {}
    self = Dialog:new()
    setmetatable(self, JingMaiQianKunDan)
    self:ClearData()
    return self
end

function JingMaiQianKunDan.DestroyDialog()
    if not _instance then
        return
    end
    if not _instance.m_bCloseIsHide then
        _instance:OnClose()
        _instance = nil
    else
        _instance:ToggleOpenClose()
    end
end
function JingMaiQianKunDan.ToggleOpenClose()
    if not _instance then
        _instance = JingMaiQianKunDan:new()
        _instance:OnCreate()
    else
        if _instance:IsVisible() then
            _instance:SetVisible(false)
        else
            _instance:SetVisible(true)
        end
    end
end

function JingMaiQianKunDan:ClearData()
    self.nItemCellSelId = 0
    self.ScrollEquip = {}
    self.bLoadUI = false
    self.fRefreshLeftDt = 0
    self.vItemCellHero = {}
end

--[[
function JingMaiQianKunDan:ClearDataInClose()
	self.nItemCellSelId = 0
	self.ScrollEquip = nil
	self.bLoadUI = false
end
--]]

function JingMaiQianKunDan:ClearCellAll()
end

function JingMaiQianKunDan:OnClose()
    Dialog.OnClose(self)
    _instance = nil
    --require("logic.jingji.jingjipipeidialog3").DestroyDialog()
end

return JingMaiQianKunDan
