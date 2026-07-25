require "utils.mhsdutils"
require "logic.dialog"

require "utils.commonutil"

JingMaiJiHuo1 = {}
setmetatable(JingMaiJiHuo1, Dialog)
JingMaiJiHuo1.__index = JingMaiJiHuo1
local _instance;
local _data;
local _index;
--//===============================
function JingMaiJiHuo1:OnCreate()
    Dialog.OnCreate(self)
    SetPositionScreenCenter(self:GetWindow())
    local winMgr = CEGUI.WindowManager:getSingleton()

    self.guanbi = CEGUI.toPushButton(winMgr:getWindow("jingmaijihuo1/btnyi1"))
    self.guanbi:subscribeEvent("MouseButtonUp", JingMaiJiHuo1.HandleguanbiClick, self)

    self.jihuo = CEGUI.toPushButton(winMgr:getWindow("jingmaijihuo1/btnyi"))
    self.jihuo:subscribeEvent("MouseButtonUp", JingMaiJiHuo1.HandlejihuoClick, self)

    self.icon1 = winMgr:getWindow("jingmaijihuo1/icon1")
    self.icon2 = winMgr:getWindow("jingmaijihuo1/icon11")
    self.num1 = winMgr:getWindow("jingmaijihuo1/cailiao1")
    self.num2 = winMgr:getWindow("jingmaijihuo1/cailiao11")

    self.jia1 = CEGUI.toPushButton(winMgr:getWindow("jingmaijihuo1/jia1"))
    self.jia1:subscribeEvent("MouseButtonUp", JingMaiJiHuo1.Handlejia1Click, self)

    self.jia2 = CEGUI.toPushButton(winMgr:getWindow("jingmaijihuo1/jia11"))
    self.jia2:subscribeEvent("MouseButtonUp", JingMaiJiHuo1.Handlejia2Click, self)
    local jihuoitem = BeanConfigManager.getInstance():GetTableByName("skill.cjingmaijihuoitem"):getRecorder(_index)
    local roleItemManager = require("logic.item.roleitemmanager").getInstance()
    local item1num=roleItemManager:GetItemNumByBaseID(jihuoitem.item1)

    self.num1:setText(item1num.."/"..jihuoitem.item1num)
    local jihuonum=0
    for k,v in pairs(_data.jingmais) do
        if v==1 then
            jihuonum=jihuonum+1
        end
    end
    self.num2:setText(_data.qianyuandan-jihuonum.."/1")

		--关闭按钮
	self.close = winMgr:getWindow("jingmaijihuo1/x")
	self.close:subscribeEvent("Clicked", self.DestroyDialog, nil)




end

function JingMaiJiHuo1:Handlejia1Click(arg)
    local e = CEGUI.toMouseEventArgs(arg)
    local touchPos = e.position

    local jihuoitem = BeanConfigManager.getInstance():GetTableByName("skill.cjingmaijihuoitem"):getRecorder(_index)

    --星辰结晶获取途径
    local itemAttrCfg = BeanConfigManager.getInstance():GetTableByName("item.citemattr"):getRecorder(jihuoitem.item1)
    if not itemAttrCfg then
        return
    end
    local nPosX = touchPos.x
    local nPosY = touchPos.y
    local Commontipdlg = require "logic.tips.commontipdlg"
    local commontipdlg = Commontipdlg.getInstanceAndShow()
    local nType = Commontipdlg.eType.eComeFrom
    --nType = Commontipdlg.eType.eNormal

    commontipdlg:RefreshItem(nType,jihuoitem.item1,nPosX,nPosY)
    commontipdlg.nComeFromItemId = jihuoitem.item1
end


function JingMaiJiHuo1:Handlejia2Click(arg)
    if _data.qianyuandan>=12 then
        GetCTipsManager():AddMessageTipById(199000)
        return
    end
    require "logic.workshop.jingmai.jingmaiqianyuandan".getInstanceAndShow()
end


function JingMaiJiHuo1:HandleguanbiClick(arg)
    self.DestroyDialog()
end

function JingMaiJiHuo1:HandlejihuoClick(arg)
    local jihuoitem = BeanConfigManager.getInstance():GetTableByName("skill.cjingmaijihuoitem"):getRecorder(_index)
    local roleItemManager = require("logic.item.roleitemmanager").getInstance()
    local item1num=roleItemManager:GetItemNumByBaseID(jihuoitem.item1)
    self.num1:setText(item1num.."/"..jihuoitem.item1num)

    if item1num < jihuoitem.item1num then
        GetCTipsManager():AddMessageTipById(150058)
        return
    end



    local p = require "logic.workshop.jingmai.cjingmaisel":new()
    p.idx = 3 --normal
    p.index = _index --normal
    require "manager.luaprotocolmanager":send(p)
end


function JingMaiJiHuo1.getInstance()
    if not _instance then
        _instance = JingMaiJiHuo1:new()
        _instance:OnCreate()
    end
    return _instance
end

function JingMaiJiHuo1.getInstanceAndShow(data,index)
    _data=data
    _index=index
    if not _instance then
        _instance = JingMaiJiHuo1:new()
        _instance:OnCreate()
    else
        _instance:SetVisible(true)
    end
    return _instance
end

function JingMaiJiHuo1.getInstanceNotCreate()
    return _instance
end

function JingMaiJiHuo1.getInstanceOrNot()
    return _instance
end

function JingMaiJiHuo1.GetLayoutFileName()
    return "jingmaijihuo1.layout"
end

function JingMaiJiHuo1:new()
    local self = {}
    self = Dialog:new()
    setmetatable(self, JingMaiJiHuo1)
    self:ClearData()
    return self
end

function JingMaiJiHuo1.DestroyDialog()
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
function JingMaiJiHuo1.ToggleOpenClose()
    if not _instance then
        _instance = JingMaiJiHuo1:new()
        _instance:OnCreate()
    else
        if _instance:IsVisible() then
            _instance:SetVisible(false)
        else
            _instance:SetVisible(true)
        end
    end
end

function JingMaiJiHuo1:ClearData()
    self.nItemCellSelId = 0
    self.ScrollEquip = {}
    self.bLoadUI = false
    self.fRefreshLeftDt = 0
    self.vItemCellHero = {}
end

--[[
function JingMaiJiHuo1:ClearDataInClose()
	self.nItemCellSelId = 0
	self.ScrollEquip = nil
	self.bLoadUI = false
end
--]]

function JingMaiJiHuo1:ClearCellAll()
end

function JingMaiJiHuo1:OnClose()
    Dialog.OnClose(self)
    _instance = nil
    --require("logic.jingji.jingjipipeidialog3").DestroyDialog()
end

return JingMaiJiHuo1
