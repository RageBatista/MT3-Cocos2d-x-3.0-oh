require "utils.mhsdutils"
require "logic.dialog"

require "utils.commonutil"

Guaji = {}
setmetatable(Guaji, Dialog)
Guaji.__index = Guaji
local _instance;

--//===============================
function Guaji:OnCreate()
    Dialog.OnCreate(self)
    SetPositionScreenCenter(self:GetWindow())
    local winMgr = CEGUI.WindowManager:getSingleton()
    self.mianxuanze = CEGUI.toScrollablePane(winMgr:getWindow("guaji/xuanze"))
    self.labelLeftTime = winMgr:getWindow("guaji/huodongshijian/time") --19:09 jingjichangdiglog/huodongshijian/time
    local guajis = BeanConfigManager.getInstance():GetTableByName("npc.cnpcguaji"):getAllID()
    local index = 0
    self.maps={}
    local colCount = 5
    local rowCount = math.floor(#guajis/ colCount) + 5
    self.pageId=0
    local sz = self.mianxuanze:getPixelSize()
    local wndWidth = sz.width / colCount
    local wndHeight = 60
    self.listInfo = {}
  --  self.exchangeNum_st = winMgr:getWindow("guaji/jiemian/zhi3/zhi")
   -- self.exchangeNum_st:subscribeEvent("MouseClick", Guaji.handleStoneNumClicked, self)
    for _,id in pairs(guajis) do
        local info = {}
        local sID = tostring(index+1)
        info.lyout = winMgr:loadWindowLayout("guajicell.layout",sID);
        self.mianxuanze:addChildWindow(info.lyout)

        --self.maps[id] = CEGUI.toCheckbox(winMgr:getWindow("guaji/"..id))
        local guajia = BeanConfigManager.getInstance():GetTableByName("npc.cnpcguaji"):getRecorder(index+1)
        --self.maps[id]:setText(guajia.name)
        info.pButton = CEGUI.Window.toCheckbox(winMgr:getWindow(sID.."guajicell/guaji"))
        info.pname = CEGUI.Window.toCheckbox(winMgr:getWindow(sID.."guajicell/wenben1"))
        info.pcishu = CEGUI.Window.toCheckbox(winMgr:getWindow(sID.."guajicell/wenben2"))		
        --info.pButton = CEGUI.toCheckbox(winMgr:createWindow("TaharezLook/Checkbox", "" .. index))
        info.pButton:setID(id)
        info.pname:setText(guajia.name, 0xffff0000)
        info.pButton:setProperty("AllowModalStateClick", "True")
        info.pButton:setProperty("AlwaysOnTop", "True")
--        info.pname:setProperty("NormalTextColour", "FF693F00")
        info.pButton:setProperty("LuaForDialog", "True")
        info.pButton:setProperty("EnableSound", "True")
        info.pname:setProperty("Font", "simhei-10")
     	local activities = HuoDongManager.getInstanceNotCreate().m_activities		
	    local activitynum = 0
	    if activities[guajia.actid] ~= nil then
		activitynum = activities[guajia.actid].num
     	end
        info.pcishu:setText(tostring(activitynum) .. "/" .. tostring(guajia.awardCnt))		
        info.pcishu:setProperty("Font", "simhei-10")
        self.pageId = math.floor(index / (colCount*rowCount))

        local colId = math.floor(index % colCount)
        local rowId = math.floor(index / colCount)

        local xPos = colId * wndWidth
        local yPos =(rowId % rowCount) * wndHeight +30

        xPos = xPos + self.pageId * sz.width -30

        local offsetX = info.pButton:getPixelSize().width/2;
        info.lyout:setPosition(CEGUI.UVector2(CEGUI.UDim(0, xPos - offsetX + 40), CEGUI.UDim(0, yPos + 5)))
        table.insert(self.listInfo,info.pButton)
        index=index+1
    end

    self.btnBeginPipei = CEGUI.toPushButton(winMgr:getWindow("guaji/pipei"))
    self.btnBeginPipei:subscribeEvent("MouseButtonUp", Guaji.clickBeginPipei, self)
    self.btnBeginPipei:setRiseOnClickEnabled(false)
    self.leixijng=0
    self.labelLeftTimeTitle = winMgr:getWindow("guaji/huodongshijian/tishiyu")
    self.lixianTime = winMgr:getWindow("guaji/huodongshijian/tishiyu13")
    self.labelBegin = winMgr:getWindow("guaji/tiaozhan")

    self.fRefreshLeftDt = 0
    self:GetWindow():subscribeEvent("WindowUpdate", Guaji.HandleWindowUpate, self)	
    self.titles = GameTable.common.GetCCommonTableInstance():getRecorder(655).value
    self.result = {}
    local fuhao=";"
    for substring in self.titles:gmatch("([^"..fuhao.."]+)") do
        table.insert(self.result, substring)
    end
    self.lixiantitles = GameTable.common.GetCCommonTableInstance():getRecorder(657).value
    self.lixian = {}
    for substring in self.lixiantitles:gmatch("([^"..fuhao.."]+)") do
        table.insert(self.lixian, substring)
    end	
	
end

function Guaji:HandleWindowUpate(args)
    local ue = CEGUI.toUpdateEventArgs(args)
    local fdt = ue.d_timeSinceLastFrame  --??
    local vecID = gGetDataManager():GetAllTitleID()
    local num = #vecID
    local time=0

    for i=1,num,1 do
        for x, value in ipairs(self.result) do
            if tonumber(value) == vecID[i] then
                time= gGetDataManager():getTitleTime(vecID[i])
            end
        end
    end
    local currentTimestamp = os.time()
    if time~=-1 and time-currentTimestamp>0 then
        self.labelLeftTime:setText(tostring(math.floor(time/1000)-currentTimestamp), 0xffff0000)
    elseif time==-1 then
        self.labelLeftTime:setText(MHSD_UTILS.get_resstring(13001), 0xffff0000)
    elseif time-currentTimestamp<0 then
        self.labelLeftTime:setText(MHSD_UTILS.get_resstring(13002), 0xffff0000)
    end
	
    local num2 = #vecID
    local panduan = 0
    for i=1,num2,1 do
        for x, value in ipairs(self.lixian) do
            if tonumber(value) == vecID[i] then
                panduan= gGetDataManager():getTitleTime(vecID[i])
            end
        end
    end
    if panduan~=-1 and panduan-currentTimestamp>0 then
        self.lixianTime:setText(tostring(math.floor(panduan/1000)-currentTimestamp), 0xffff0000)
    elseif panduan==-1 then
        self.lixianTime:setText(MHSD_UTILS.get_resstring(13001), 0xffff0000)
    elseif panduan-currentTimestamp<0 then
        self.lixianTime:setText(MHSD_UTILS.get_resstring(13002), 0xffff0000)
    end
end



function Guaji:refreshLeftTime(disTime)
    --计算倒计时时间
    local hour = math.floor(disTime / 3600)
    local strhour = ""

    if hour < 10 then
        strhour = "0"..tostring(hour)
    else
        strhour = tostring(hour)
    end
    local min = math.floor((disTime - hour * 3600) / 60)
    local strmin = ""
    if min < 10 then
        strmin = "0"..tostring(min)
    else
        strmin = tostring(min)
    end

    local sec = math.floor((disTime - hour * 3600 -  min * 60))
    local strsec = ""
    if sec < 10 then
        strsec = "0"..tostring(sec)
    else
        strsec = tostring(sec)
    end
    self.labelLeftTime:setText(tostring(strhour..":"..strmin..":"..strsec))
end

function Guaji:sendReady(nReady,leixing)
    local p = require "logic.guaji.cguaji":new()
    p.ready = nReady
    for index=1,#leixing do
        p.leixing[index]=leixing[index]
    end
 --   p.cishu = tonumber(self.exchangeNum_st:getText())
    require "manager.luaprotocolmanager":send(p)
end

function Guaji:clickBeginPipei(arg)
    local guajis = BeanConfigManager.getInstance():GetTableByName("npc.cnpcguaji"):getAllID()
    local gouxuanTable = {}
    local index = 1
    for _, id in pairs(guajis) do
        if self.listInfo[id]:isSelected() then
            gouxuanTable[index]=id
            index=index+1
        end
    end

    local vecID = gGetDataManager():GetAllTitleID()
    local num = #vecID
    local panduan = 0
    for i=1,num,1 do
        for x, value in ipairs(self.result) do
            if tonumber(value) == vecID[i] then
                panduan = panduan + 1
            end
        end
    end
    if panduan == 0 then
        GetCTipsManager():AddMessageTip(MHSD_UTILS.get_msgtipstring(201031))
        return
    end
    local bLeader = GetMainCharacter():IsTeamLeader()
    if not bLeader then
        GetCTipsManager():AddMessageTip(MHSD_UTILS.get_msgtipstring(201032))
        return
    end
    if #gouxuanTable==0 then
        GetCTipsManager():AddMessageTip(MHSD_UTILS.get_msgtipstring(201028))
        return
    end

    self:sendReady(10086,gouxuanTable)
    self.ToggleOpenClose()
    --end
end
--//=========================================
function Guaji.getInstance()
    if not _instance then
        _instance = Guaji:new()
        _instance:OnCreate()
    end
    return _instance
end

function Guaji.getInstanceAndShow()
    if not _instance then
        _instance = Guaji:new()
        _instance:OnCreate()
    else
        _instance:SetVisible(true)
    end
    return _instance
end




function Guaji.getInstanceNotCreate()
    return _instance
end

function Guaji.getInstanceOrNot()
    return _instance
end

function Guaji.GetLayoutFileName()
    return "guaji.layout"
end

function Guaji:new()
    local self = {}
    self = Dialog:new()
    setmetatable(self, Guaji)
    self:ClearData()
    return self
end

function Guaji.DestroyDialog()
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
function Guaji.ToggleOpenClose()
    if not _instance then
        _instance = Guaji:new()
        _instance:OnCreate()
    else
        if _instance:IsVisible() then
            _instance:SetVisible(false)
        else
            _instance:SetVisible(true)
        end
    end
end

function Guaji:ClearData()
    self.nItemCellSelId = 0
    self.ScrollEquip = {}
    self.bLoadUI = false
    self.fRefreshLeftDt = 0
    self.vItemCellHero = {}
end

--[[
function Guaji:ClearDataInClose()
	self.nItemCellSelId = 0
	self.ScrollEquip = nil
	self.bLoadUI = false
end
--]]

function Guaji:ClearCellAll()
end

function Guaji:OnClose()
    Dialog.OnClose(self)
    _instance = nil
    --require("logic.jingji.jingjipipeidialog3").DestroyDialog()
end

return Guaji
