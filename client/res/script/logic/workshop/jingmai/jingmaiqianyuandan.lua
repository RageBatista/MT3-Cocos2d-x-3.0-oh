require "utils.mhsdutils"
require "logic.dialog"

require "utils.commonutil"

JingMaiQianYuanDan = {}
setmetatable(JingMaiQianYuanDan, Dialog)
JingMaiQianYuanDan.__index = JingMaiQianYuanDan
local _instance;
--//===============================
function JingMaiQianYuanDan:OnCreate()
    Dialog.OnCreate(self)
    --SetPositionScreenCenter(self:GetWindow())
    local winMgr = CEGUI.WindowManager:getSingleton()

    self.guanbi = CEGUI.toPushButton(winMgr:getWindow("jingmaiqianyuandan/guanbi"))
    self.guanbi:subscribeEvent("MouseButtonUp", JingMaiQianYuanDan.HandleguanbiClick, self)

    self.lianhua = CEGUI.toPushButton(winMgr:getWindow("jingmaiqianyuandan/diban/di/btn"))
    self.lianhua:subscribeEvent("MouseButtonUp", JingMaiQianYuanDan.HandlelianhuaClick, self)
    self.huoli = CEGUI.Window.toProgressBarTwoValue(winMgr:getWindow("jingmaiqianyuandan/diban/di/huoli"))
    self.exp = CEGUI.Window.toProgressBarTwoValue(winMgr:getWindow("jingmaiqianyuandan/diban/exp"))
    local p = require "logic.workshop.jingmai.cjingmaisel":new()
    p.idx = 10 --normal
    require "manager.luaprotocolmanager":send(p)


end
function JingMaiQianYuanDan:setMain(data)
    if data.qianyuandan >=12 then
        self.DestroyDialog()
        return
    end
    local qianyuandan = BeanConfigManager.getInstance():GetTableByName("skill.cjingmaiqianyuandan"):getRecorder(data.qianyuandan+1)
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

function JingMaiQianYuanDan:HandleguanbiClick(arg)
    self.DestroyDialog()
end

function JingMaiQianYuanDan:HandlelianhuaClick(arg)
    if self.data.qianyuandan>=12 then
        return
    end
	
	if self.exp:getProgress() < 1 then
		GetCTipsManager():AddMessageTip("当前经验不足，无法炼化乾元丹")
	    return
	
	end
	if self.huoli:getProgress() < 1 then
		GetCTipsManager():AddMessageTip("当前活力不足，无法炼化乾元丹")
        return

	end

		GetCTipsManager():AddMessageTip("成功炼化乾元丹！")
    local p = require "logic.workshop.jingmai.cjingmaisel":new()
    p.idx = 11 --normal
    require "manager.luaprotocolmanager":send(p)
end


function JingMaiQianYuanDan.getInstance()
    if not _instance then
        _instance = JingMaiQianYuanDan:new()
        _instance:OnCreate()
    end
    return _instance
end

function JingMaiQianYuanDan.getInstanceAndShow()
    if not _instance then
        _instance = JingMaiQianYuanDan:new()
        _instance:OnCreate()
    else
        _instance:SetVisible(true)
    end
    return _instance
end

function JingMaiQianYuanDan.getInstanceNotCreate()
    return _instance
end

function JingMaiQianYuanDan.getInstanceOrNot()
    return _instance
end

function JingMaiQianYuanDan.GetLayoutFileName()
    return "jingmaiqianyuandan.layout"
end

function JingMaiQianYuanDan:new()
    local self = {}
    self = Dialog:new()
    setmetatable(self, JingMaiQianYuanDan)
    self:ClearData()
    return self
end

function JingMaiQianYuanDan.DestroyDialog()
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
function JingMaiQianYuanDan.ToggleOpenClose()
    if not _instance then
        _instance = JingMaiQianYuanDan:new()
        _instance:OnCreate()
    else
        if _instance:IsVisible() then
            _instance:SetVisible(false)
        else
            _instance:SetVisible(true)
        end
    end
end

function JingMaiQianYuanDan:ClearData()
    self.nItemCellSelId = 0
    self.ScrollEquip = {}
    self.bLoadUI = false
    self.fRefreshLeftDt = 0
    self.vItemCellHero = {}
end

--[[
function JingMaiQianYuanDan:ClearDataInClose()
	self.nItemCellSelId = 0
	self.ScrollEquip = nil
	self.bLoadUI = false
end
--]]

function JingMaiQianYuanDan:ClearCellAll()
end

function JingMaiQianYuanDan:OnClose()
    Dialog.OnClose(self)
    _instance = nil
    --require("logic.jingji.jingjipipeidialog3").DestroyDialog()
end

return JingMaiQianYuanDan
