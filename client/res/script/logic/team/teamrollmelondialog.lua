require "logic.dialog"

TeamRollMelondDialog = { }
setmetatable(TeamRollMelondDialog, Dialog)
TeamRollMelondDialog.__index = TeamRollMelondDialog

local _instance
local maxWaitTime = 5900

local teamRollInfoList = {}

function TeamRollMelondDialog.onInternetReconnected()
    TeamRollMelondDialog.DestroyDialog()
end

-- 到等待退出状态
function TeamRollMelondDialog:toWaitQuitState()
    if _instance == nil then
        return
    end

    self.state = "wait quit"

    local winMgr = CEGUI.WindowManager:getSingleton()
    local bg = winMgr:getWindow("teamrolldialog/window")
    bg:removeChildWindow(self.mWndProgress)
    bg:cleanupNonAutoChildren()
    winMgr:destroyWindow(self.mWndProgress)
    self.DestroyDialog()
end

-- TICK
function TeamRollMelondDialog:run(delta)
    if _instance == nil then
        return
    end

    if self.state == "wait quit" then
        return
    end

    local winMgr = CEGUI.WindowManager:getSingleton()
    self.waitTime = self.waitTime - delta
    if self.state == "wait roll" then
        local tableInstance = BeanConfigManager.getInstance():GetTableByName("message.cstringres")
        local timeText = tableInstance:getRecorder(10015).msg
        if self.waitTime > 0 then
            if self.progressBar then
                self.progressBar:setProgress(self.waitTime / maxWaitTime)
            end
        else
            self.state = "wait quit"

            if self.progressBar then
                self.progressBar:setVisible(false)
            end

            for i, v in pairs(teamRollInfoList) do
                local cellName = tostring(i) .. "teamrollcell/window/cell"
                if winMgr:isWindowPresent(cellName) then
                    local cellWnd = winMgr:getWindow(cellName)
                    if cellWnd ~= nil then
                        if cellWnd:isVisible() then
                            cellWnd:setVisible(false)
                        end
                    end
                end
            end
        end
    end
end

function TeamRollMelondDialog.SetRollInfoList(melonlist)
    teamRollInfoList = { }
    for i, v in ipairs(melonlist) do
        teamRollInfoList[i] = { }
        teamRollInfoList[i].melonid = v.melonid
        teamRollInfoList[i].itemid = v.itemid
        teamRollInfoList[i].itemnum = v.itemnum
        teamRollInfoList[i].itemdata = v.itemdata
    end
end

-- Roll点的装备的详细信息
function TeamRollMelondDialog:onSTeamRollMelon(melonlist)
    self:AppendProgressBar()
    self.cellCount = 0
    for i, v in ipairs(teamRollInfoList) do
            self:AppendCell(i, v.melonid, v.itemid, v.itemnum, v.itemdata)
            self.cellCount = self.cellCount + 1
    end
    self.waitTime = maxWaitTime
    self:RefeshAllCellPos()
end

function TeamRollMelondDialog:checkCouldRoll(baseid)
    local SettingEnum = require "protodef.rpcgen.fire.pb.sysconfigtype":new()
    local record = GameTable.SysConfig.GetCGameconfigTableInstance():getRecorder(SettingEnum.rolldianshezhi)
    if record then
        local strKey = record.key
        local value = gGetGameConfigManager():GetConfigValue(strKey)
        if value == 0 then
            return true
        end
    end
    local itemInfo = BeanConfigManager.getInstance():GetTableByName("item.citemattr"):getRecorder(baseid)
    if itemInfo then
        local nItemType = itemInfo.itemtypeid
        local nFirstType = require "utils.mhsdutils".GetItemFirstType(nItemType)

        if nFirstType ~= eItemType_EQUIP then
            return true
        end

        local equipConfig
        if IsPointCardServer() then
            equipConfig = BeanConfigManager.getInstance():GetTableByName("item.cequipeffect"):getRecorder(baseid)
        else
            equipConfig = GameTable.item.GetCEquipEffectTableInstance():getRecorder(baseid)
        end

        local needSchool = {}
        local isDoubleSchool = false
        local isSchoolCorect = false
        local isSexCorect = false
        local selfSchool = gGetDataManager():GetMainCharacterSchoolID()
        local selfSex = gGetDataManager():GetMainCharacterSex()

        local career = equipConfig.needCareer
        if career == "0" then
            isSchoolCorect = true
        end

        if string.len(career) > 1 then
            if string.find(career, ";") then
                needSchool = StringBuilder.Split(career, ";")
                isDoubleSchool = true
            end
        end

        for _, v in pairs(needSchool) do
            if selfSchool == tonumber(v) then
                isSchoolCorect = true
                break
            end
        end

        if equipConfig.sexNeed == 0 or selfSex == equipConfig.sexNeed then
            isSexCorect = true
        end

        if isSchoolCorect and isSexCorect then
            return true
        end
    end

    return false
end

-- 创建进度条窗口.
function TeamRollMelondDialog:AppendProgressBar()
    local winMgr = CEGUI.WindowManager:getSingleton()
   
   if not self.mWndProgress then
        self.mWndProgress = winMgr:loadWindowLayout("teamrolldaojishi.layout")
        local bg = winMgr:getWindow("teamrolldialog/window")
        bg:addChildWindow(self.mWndProgress)

        self.progressBar = CEGUI.toProgressBar(winMgr:getWindow("teamrolldaojishi/window/daojishi"))
        self.progressBar:show()
        self.progressBar:setProgress(0)

        self.state = "wait roll"
        self.waitTime = maxWaitTime
    end

end

-- 增加ROLL点项
function TeamRollMelondDialog:AppendCell(index, melonid, itemid, itemnum, itemdata)
    local itemInfo = BeanConfigManager.getInstance():GetTableByName("item.citemattr"):getRecorder(itemid)
    if itemInfo then
        local nItemType = itemInfo.itemtypeid
        local nFirstType = require "utils.mhsdutils".GetItemFirstType(nItemType)

        if nFirstType == eItemType_EQUIP then
            GetChatManager():AddObjTips(0, 0, itemid, melonid, 0, itemdata) 
        end
    end

    local winMgr = CEGUI.WindowManager:getSingleton()
    local prefixName = tostring(index)
    local cellWnd = nil
	if winMgr:isWindowPresent(prefixName .. "teamrollcell") then
		cellWnd = winMgr:getWindow(prefixName .. "teamrollcell")
	else
		cellWnd = winMgr:loadWindowLayout("teamrollcell.layout", prefixName)
	end
    local iconWnd = CEGUI.toItemCell(winMgr:getWindow(prefixName .. "teamrollcell/window/tupian"))
    local imageId = gGetIconManager():GetImageByID(itemInfo.icon)
    iconWnd:SetImage(imageId)

    SetItemCellBoundColorByQulityItem(iconWnd, itemInfo.nquality)

    iconWnd:setUserString("ITEM_ID", tostring(itemid))
    iconWnd:setUserString("MELOND_ID", tostring(melonid))

    iconWnd:subscribeEvent("MouseButtonUp", TeamRollMelondDialog.HandleItemClicked, self)
    local nameWnd = winMgr:getWindow(prefixName .. "teamrollcell/window/name")
    nameWnd:setText(itemInfo.name)
    local okWnd = CEGUI.toPushButton(winMgr:getWindow(prefixName .. "teamrollcell/window/cell/toushai"))
    okWnd:setID(index)
    okWnd:subscribeEvent("MouseClick", self.HandleCellOkButton, self)
    local cancelWnd = CEGUI.toPushButton(winMgr:getWindow(prefixName .. "teamrollcell/window/dikuang"))
    cancelWnd:setID(index)
    cancelWnd:subscribeEvent("MouseClick", self.HandleCellCancelButton, self)
    local rollText = winMgr:getWindow(prefixName .. "teamrollcell/window/cell/wenbentishi")

    local bg = winMgr:getWindow("teamrolldialog/window")
    bg:addChildWindow(cellWnd)

    local couldRoll = self:checkCouldRoll(itemid)
    if not couldRoll then
        okWnd:setEnabled(false)
        cancelWnd:setEnabled(false)
        rollText:setVisible(true)
        self:SendMessage_TeamrollMelon(melonid, 0)
    end

end

function TeamRollMelondDialog.sendGetItemTips(rid)
    local msg = require "protodef.fire.pb.team.teammelon.crequestrollitemtips":new()
    msg.melonid = rid
    require "manager.luaprotocolmanager":send(msg)
end

function TeamRollMelondDialog:HandleItemClicked(args)
    if self.state == "wait quit" then return end

    local e = CEGUI.toMouseEventArgs(args)

    local baseid = tonumber(e.window:getUserString("ITEM_ID"))
    local molondid = tonumber(e.window:getUserString("MELOND_ID"))

    GetChatManager():ShowRollItemTips(baseid, molondid)

end

-- 刷新所有单元的位置.
function TeamRollMelondDialog:RefeshAllCellPos()
    if self.state == "wait quit" then return end

    local winMgr = CEGUI.WindowManager:getSingleton()
    -- 首先计算道具信息和进度条的高度
    local infoHeight = self.mWndProgress:getPixelSize().height

    for i, v in pairs(teamRollInfoList) do
        local cellName = tostring(i) .. "teamrollcell/window/cell"
        if winMgr:isWindowPresent(cellName) then
            local cellWnd = winMgr:getWindow(cellName)
            if cellWnd ~= nil then
                if cellWnd:isVisible() then
                    infoHeight = infoHeight + cellWnd:getPixelSize().height
                end
            end
        end
    end
    -- 然后计算背景面板高度
    local bg = winMgr:getWindow("teamrolldialog/window")
    local bgHeight = bg:getPixelSize().height
    -- 设置进度条位置
    local xPos = 1.0
    local yPos =(bgHeight - infoHeight) / 2
    self.mWndProgress:setPosition(CEGUI.UVector2(CEGUI.UDim(0.2, xPos), CEGUI.UDim(0.3, yPos)))
    yPos = yPos + self.mWndProgress:getPixelSize().height
    -- 设置道具信息位置
    for i, v in pairs(teamRollInfoList) do
        local cellName = tostring(i) .. "teamrollcell/window/cell"
        if winMgr:isWindowPresent(cellName) then
            local cellWnd = winMgr:getWindow(cellName)
            if cellWnd ~= nil then
                if cellWnd:isVisible() then
                    cellWnd:setPosition(CEGUI.UVector2(CEGUI.UDim(0.0, xPos), CEGUI.UDim(0.0, yPos)))
                    yPos = yPos + cellWnd:getPixelSize().height
                end
            end
        end
    end
end

-- 响应ROLL按钮
function TeamRollMelondDialog:HandleCellOkButton(e)
    if self.state == "wait quit" then return end

    local mouseArgs = CEGUI.toMouseEventArgs(e)
    local eventWindow = mouseArgs.window
    local melonid = teamRollInfoList[eventWindow:getID()].melonid
    self:SendMessage_TeamrollMelon(melonid, 1)

    local prefixName = tostring(eventWindow:getID())
    local winMgr = CEGUI.WindowManager:getSingleton()
    if winMgr:isWindowPresent(prefixName .. "teamrollcell") then
        local cellWnd = winMgr:getWindow(prefixName .. "teamrollcell")
        cellWnd:setVisible(false)
    end

    self:RefeshAllCellPos()
end

-- 响应Cancel按钮
function TeamRollMelondDialog:HandleCellCancelButton(e)
    if self.state == "wait quit" then return end

    local mouseArgs = CEGUI.toMouseEventArgs(e)
    local eventWindow = mouseArgs.window
    local melonid = teamRollInfoList[eventWindow:getID()].melonid
    self:SendMessage_TeamrollMelon(melonid, 0)

    local prefixName = tostring(eventWindow:getID())
    local winMgr = CEGUI.WindowManager:getSingleton()
    if winMgr:isWindowPresent(prefixName .. "teamrollcell") then
        local cellWnd = winMgr:getWindow(prefixName .. "teamrollcell")
        cellWnd:setVisible(false)
    end

    self:RefeshAllCellPos()
end

-- 发送ROLL点消息
function TeamRollMelondDialog:SendMessage_TeamrollMelon(melonId, msgStatus)
    local msg = require "protodef.fire.pb.team.teammelon.cteamrollmelon":new()
    msg.melonid = melonId
    msg.status = msgStatus
    require "manager.luaprotocolmanager":send(msg)
end

function TeamRollMelondDialog.ShowRollResult(melonid, grabroleid, roleinfolist, itemList, grabrolename)
    for i, v in ipairs(teamRollInfoList) do
        if v.melonid == melonid and grabroleid ~= 0 then
            local itemInfo = BeanConfigManager.getInstance():GetTableByName("item.citemattr"):getRecorder(v.itemid)
            if itemInfo then
                -- 写道具名字
                local winMgr = CEGUI.WindowManager:getSingleton()

                local itemKey = itemList[1].itemKey

                local title = "<P t=\"[" .. itemInfo.name .. "]\" roleid=\"" .. grabroleid .. "\" type=\"1\" key=\"" .. itemKey .. "\" baseid=\"" .. v.itemid .. "\" shopid=\"0\" counter=\"" .. v.itemnum .. "\" bind=\"0\" loseefftime=\"0\" TextColor=\"" .. itemInfo.colour .. "\"></P>"

                local xuqiuText = "<T t=\"" .. BeanConfigManager.getInstance():GetTableByName("message.cstringres"):getRecorder(11138).msg .. "\"" .. " c=\"fffff2df\"></T>"
                local touzhiText = "<T t=\"" .. BeanConfigManager.getInstance():GetTableByName("message.cstringres"):getRecorder(11136).msg .. "\"" .. " c=\"fffff2df\"></T>"
                local dianText = "<T t=\"" .. BeanConfigManager.getInstance():GetTableByName("message.cstringres"):getRecorder(11139).msg .. "\"" .. " c=\"fffff2df\"></T>"
                local huodeText = "<T t=\"" .. BeanConfigManager.getInstance():GetTableByName("message.cstringres"):getRecorder(11140).msg .. "\"" .. " c=\"fffff2df\"></T>"
                local fangqiText = "<T t=\"" .. BeanConfigManager.getInstance():GetTableByName("message.cstringres"):getRecorder(11137).msg .. "\"></T>"

                local nameText = "<T t=\"" .. grabrolename .. "\"" .. " c=\"ff00c6ff\" ></T>"
                text = nameText .. huodeText .. title
                if GetChatManager() then
                    local ids = BeanConfigManager.getInstance():GetTableByName("chat.cchatcolorconfig"):getAllID()
                    for j=1, #ids do
                        local colorConfig = BeanConfigManager.getInstance():GetTableByName("chat.cchatcolorconfig"):getRecorder(ids[j])
                        local color = colorConfig.color
                        local toReplace = colorConfig.notifylist[12]
                        if toReplace ~= "0" then
                            local strTable = StringBuilder.Split(toReplace, ",")
                            local doubleColor = false
                            if require "utils.tableutil".tablelength(strTable) == 2 then 
                                doubleColor = true
                            end
                        
                            local pos = string.find(text, "c=\""..color) 

                            if pos == nil then
                                pos = string.find(text, "c=\'"..color) 
                            end

                            if pos == nil then
                                pos = string.find(text, "TextColor=\""..color)
                            end

                            if pos ~= nil then
                                if doubleColor then
                                    if string.len(strTable[1]) > 1 then
                                        text = string.gsub(text, "(c=['\"])"..color.."['\"]", "%1"..strTable[1].."\" ob=\""..color.."\"")
                                        text = string.gsub(text, "(TextColor=['\"])"..color.."['\"]", "%1"..strTable[1].."\" ob=\""..color.."\"")
                                    end
                                else
                                        text = string.gsub(text, "(c=['\"])"..color.."['\"]", "%1"..toReplace.."\" ob=\""..color.."\"")
                                        text = string.gsub(text, "(TextColor=['\"])"..color.."['\"]", "%1"..toReplace.."\" ob=\""..color.."\"")
                                end
                            end

                        end
                    end

                    GetChatManager():AddMsg_Team(0, 0, 0, 0, "", text, true)
               end
            end
        end
    end
end


-- 处理消息
function TeamRollMelondDialog:AddRollResult(melonid, grabroleid, roleinfolist, itemList, grabrolename)

    TeamRollMelondDialog.ShowRollResult(melonid, grabroleid, roleinfolist, itemList, grabrolename)

    self.cellCount = self.cellCount - 1
    if self.cellCount == 0 then
        self:toWaitQuitState()
        GetBattleManager():SetDealBeforeBattleEnd(0)
    end
end


-- ROLL点通返回roll点结果
local p = require "protodef.fire.pb.team.teammelon.steamrollmeloninfo"
function p:process()
        local rollinfos = { }
        for i, v in ipairs(self.rollinfolist) do
            local index = v.roll * 100
            while rollinfos[index] ~= nil do
                index = index - 1
            end
            rollinfos[index] = { }
            rollinfos[index].roleid = v.roleid
            rollinfos[index].roll = v.roll
            rollinfos[index].rollName = v.rolename
        end
        table.sort(rollinfos)
        local rollinfos2 = { }
        for i, v in pairs(rollinfos) do
            rollinfos2[100 * 100 - i] = v
        end

        local itemInfoList = { }
        local infoIndex = 0
        for k, v in pairs(self.melonitemlist) do
            infoIndex = infoIndex + 1
            itemInfoList[infoIndex] = { }
            itemInfoList[infoIndex].itemKey = v.itemkey
            itemInfoList[infoIndex].bagId = v.bagid
        end

    if _instance ~= nil then
        TeamRollMelondDialog.getInstance():AddRollResult(self.melonid, self.grabroleid, rollinfos2, itemInfoList, self.grabrolename)
    else
        TeamRollMelondDialog.ShowRollResult(self.melonid, self.grabroleid, rollinfos2, itemInfoList, self.grabrolename)
    end
end
		
----------------------------------例行代码---------------------------------
function TeamRollMelondDialog.GetLayoutFileName()
    return "teamrolldialog.layout"
end

function TeamRollMelondDialog.getInstance()
    LogInfo("enter get TeamRollMelondDialog instance")
    if not _instance then
        _instance = TeamRollMelondDialog:new()
        _instance:OnCreate()
    end

    return _instance
end

function TeamRollMelondDialog.getInstanceAndShow()
    LogInfo("enter TeamRollMelondDialog instance show")
    if not _instance then
        _instance = TeamRollMelondDialog:new()
        _instance:OnCreate()
    else
        LogInfo("set TeamRollMelondDialog visible")
        _instance:SetVisible(true)
    end
    return _instance
end

function TeamRollMelondDialog.getInstanceNotCreate()
    return _instance
end

function TeamRollMelondDialog.ToggleOpenClose()
    if not _instance then
        _instance = TeamRollMelondDialog:new()
        _instance:OnCreate()
    else
        if _instance:IsVisible() then
            _instance:SetVisible(false)
        else
            _instance:SetVisible(true)
        end
    end
end

function TeamRollMelondDialog:new()
    local self = { }
    self = Dialog:new()
    setmetatable(self, TeamRollMelondDialog)
    return self
end

function TeamRollMelondDialog.DestroyDialog()
    if _instance then
        if not _instance.m_bCloseIsHide then
            _instance:OnClose()
            _instance = nil
        else
            _instance:ToggleOpenClose()
        end
    end
end

return TeamRollMelondDialog
