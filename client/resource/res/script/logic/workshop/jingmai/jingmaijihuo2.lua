require "utils.mhsdutils"
require "logic.dialog"

require "utils.commonutil"

JingMaiJiHuo2 = {}
setmetatable(JingMaiJiHuo2, Dialog)
JingMaiJiHuo2.__index = JingMaiJiHuo2
local _instance;
local _data;
local _index;
--//===============================
function JingMaiJiHuo2:OnCreate()
    Dialog.OnCreate(self)
    SetPositionScreenCenter(self:GetWindow())
    local winMgr = CEGUI.WindowManager:getSingleton()

    self.guanbi = CEGUI.toPushButton(winMgr:getWindow("jingmaijihuo2/btnyi1"))
    self.guanbi:subscribeEvent("MouseButtonUp", JingMaiJiHuo2.HandleguanbiClick, self)

    self.jihuo = CEGUI.toPushButton(winMgr:getWindow("jingmaijihuo2/btnyi"))
    self.jihuo:subscribeEvent("MouseButtonUp", JingMaiJiHuo2.HandlejihuoClick, self)

    self.icon1 = winMgr:getWindow("jingmaijihuo2/icon1")
    self.icon2 = winMgr:getWindow("jingmaijihuo2/icon11")
    self.icon3 = winMgr:getWindow("jingmaijihuo2/icon111")

    self.num1 = winMgr:getWindow("jingmaijihuo2/cailiao1")
    self.num2 = winMgr:getWindow("jingmaijihuo2/cailiao11")
    self.num3 = winMgr:getWindow("jingmaijihuo2/cailiao111")

    self.jia1 = CEGUI.toPushButton(winMgr:getWindow("jingmaijihuo2/jia1"))
    self.jia1:subscribeEvent("MouseButtonUp", JingMaiJiHuo2.Handlejia1Click, self)

    self.jia2 = CEGUI.toPushButton(winMgr:getWindow("jingmaijihuo2/jia11"))
    self.jia2:subscribeEvent("MouseButtonUp", JingMaiJiHuo2.Handlejia2Click, self)

    self.jia3 = CEGUI.toPushButton(winMgr:getWindow("jingmaijihuo2/jia111"))
    self.jia3:subscribeEvent("MouseButtonUp", JingMaiJiHuo2.Handlejia3Click, self)



    local jihuoitem = BeanConfigManager.getInstance():GetTableByName("skill.cjingmaijihuoitem"):getRecorder(_index)
    local roleItemManager = require("logic.item.roleitemmanager").getInstance()
    local item1num=roleItemManager:GetItemNumByBaseID(jihuoitem.item1)
    local item2num=roleItemManager:GetItemNumByBaseID(jihuoitem.item2)

    self.num1:setText(item1num.."/"..jihuoitem.item1num)

    self.num2:setText(item2num.."/"..jihuoitem.item2num)
    local jihuonum=0
    for k,v in pairs(_data.jingmais) do
        if v==1 then
            jihuonum=jihuonum+1
        end
    end
    jihuonum=jihuonum-12
    self.num3:setText(_data.qiankundan-jihuonum.."/1")


	--关闭按钮
	self.close = winMgr:getWindow("jingmaijihuo2/x")
	self.close:subscribeEvent("Clicked", self.DestroyDialog, nil)



end

function JingMaiJiHuo2:Handlejia1Click(arg)
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


function JingMaiJiHuo2:Handlejia2Click(arg)
    local e = CEGUI.toMouseEventArgs(arg)
    local touchPos = e.position

    local jihuoitem = BeanConfigManager.getInstance():GetTableByName("skill.cjingmaijihuoitem"):getRecorder(_index)

    --星辰结晶获取途径
    local itemAttrCfg = BeanConfigManager.getInstance():GetTableByName("item.citemattr"):getRecorder(jihuoitem.item2)
    if not itemAttrCfg then
        return
    end
    local nPosX = touchPos.x
    local nPosY = touchPos.y
    local Commontipdlg = require "logic.tips.commontipdlg"
    local commontipdlg = Commontipdlg.getInstanceAndShow()
    local nType = Commontipdlg.eType.eComeFrom
    --nType = Commontipdlg.eType.eNormal

    commontipdlg:RefreshItem(nType,jihuoitem.item2,nPosX,nPosY)
    commontipdlg.nComeFromItemId = jihuoitem.item2
end

function JingMaiJiHuo2:Handlejia3Click(arg)

    if _data.qianyuandan < 12 then
        GetCTipsManager():AddMessageTipById(199002)
        return
    end
    if _data.qiankundan>=4 then
        GetCTipsManager():AddMessageTipById(199001)
        return
    end
    require "logic.workshop.jingmai.jingmaiqiankundan".getInstanceAndShow()
end


function JingMaiJiHuo2:HandleguanbiClick(arg)
    self.DestroyDialog()
end

function JingMaiJiHuo2:HandlejihuoClick(arg)
    local jihuoitem = BeanConfigManager.getInstance():GetTableByName("skill.cjingmaijihuoitem"):getRecorder(_index)
    local roleItemManager = require("logic.item.roleitemmanager").getInstance()
    local item1num=roleItemManager:GetItemNumByBaseID(jihuoitem.item1)

    local item2num=roleItemManager:GetItemNumByBaseID(jihuoitem.item2)

    if item1num < jihuoitem.item1num then
        return
    end

    if item2num < jihuoitem.item2num then
        return
    end


    local p = require "logic.workshop.jingmai.cjingmaisel":new()
    p.idx = 3 --normal
    p.index = _index --normal
    require "manager.luaprotocolmanager":send(p)
end


function JingMaiJiHuo2.getInstance()
    if not _instance then
        _instance = JingMaiJiHuo2:new()
        _instance:OnCreate()
    end
    return _instance
end

function JingMaiJiHuo2.getInstanceAndShow(data,index)
    _data=data
    _index=index
    if not _instance then
        _instance = JingMaiJiHuo2:new()
        _instance:OnCreate()
    else
        _instance:SetVisible(true)
    end
    return _instance
end

function JingMaiJiHuo2.getInstanceNotCreate()
    return _instance
end

function JingMaiJiHuo2.getInstanceOrNot()
    return _instance
end

function JingMaiJiHuo2.GetLayoutFileName()
    return "jingmaijihuo2.layout"
end

function JingMaiJiHuo2:new()
    local self = {}
    self = Dialog:new()
    setmetatable(self, JingMaiJiHuo2)
    self:ClearData()
    return self
end

function JingMaiJiHuo2.DestroyDialog()
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
function JingMaiJiHuo2.ToggleOpenClose()
    if not _instance then
        _instance = JingMaiJiHuo2:new()
        _instance:OnCreate()
    else
        if _instance:IsVisible() then
            _instance:SetVisible(false)
        else
            _instance:SetVisible(true)
        end
    end
end

function JingMaiJiHuo2:ClearData()
    self.nItemCellSelId = 0
    self.ScrollEquip = {}
    self.bLoadUI = false
    self.fRefreshLeftDt = 0
    self.vItemCellHero = {}
end

--[[
function JingMaiJiHuo2:ClearDataInClose()
	self.nItemCellSelId = 0
	self.ScrollEquip = nil
	self.bLoadUI = false
end
--]]

function JingMaiJiHuo2:ClearCellAll()
end

function JingMaiJiHuo2:OnClose()
    Dialog.OnClose(self)
    _instance = nil
    --require("logic.jingji.jingjipipeidialog3").DestroyDialog()
end

return JingMaiJiHuo2
