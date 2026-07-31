require "logic.dialog"

XinGongNengOpenDLG = { }
setmetatable(XinGongNengOpenDLG, Dialog)
XinGongNengOpenDLG.__index = XinGongNengOpenDLG

local petOpened = 0

local _instance
function XinGongNengOpenDLG.getInstance()
    if not _instance then
        _instance = XinGongNengOpenDLG:new()
        _instance:OnCreate()
    end
    return _instance
end

function XinGongNengOpenDLG.getInstanceAndShow()
    if not _instance then
        _instance = XinGongNengOpenDLG:new()
        _instance:OnCreate()
    else
        _instance:SetVisible(true)
    end
    return _instance
end

function XinGongNengOpenDLG.getInstanceNotCreate()
    return _instance
end

function XinGongNengOpenDLG.DestroyDialog()
    if _instance then
        _instance:OnClose()
        _instance = nil
    end
end

function XinGongNengOpenDLG.ToggleOpenClose()
    if not _instance then
        _instance = XinGongNengOpenDLG:new()
        _instance:OnCreate()
    else
        if _instance:IsVisible() then
            _instance:SetVisible(false)
        else
            _instance:SetVisible(true)
        end
    end
end

function XinGongNengOpenDLG.GetLayoutFileName()
    return "xingongnengkaiqi_mtg.layout"
end

function XinGongNengOpenDLG:new()
    local self = { }
    self = Dialog:new()
    setmetatable(self, XinGongNengOpenDLG)
    return self
end

function XinGongNengOpenDLG:OnCreate()
    Dialog.OnCreate(self)

    local winMgr = CEGUI.WindowManager:getSingleton()
    self.m_pImage = winMgr:getWindow("kaiqixingongneng_mtg/image")
    self.spos = self.m_pImage:GetScreenPosOfCenter()
    self.tpos = CEGUI.Vector2(0.0, 0.0)
    self.waittime = 1500
    self.passtime = 0
    self.xSpeed = 0
    self.ySpeed = 0
    self.flySite = 0
    self.toOpenIndex = -1
    self.toOpenID = -1
    self.flyType = 0


end

function XinGongNengOpenDLG.CheckNewFeatureByLevel()
    local data = gGetDataManager():GetMainCharacterData()
    local curLevel = data:GetValue(fire.pb.attr.AttrType.LEVEL)

    local tableAllId = BeanConfigManager.getInstance():GetTableByName("mission.cnewfunctionopen"):getAllID()
    for _, v in pairs(tableAllId) do
        local record = BeanConfigManager.getInstance():GetTableByName("mission.cnewfunctionopen"):getRecorder(v)
        if record.needlevel ~= 0 and record.needlevel == curLevel then
              if record.iseffect == 2 then --只链接引导，不做功能
                NewRoleGuideManager.getInstance():GuideStartFunction(record.id)
                return
              end

              --判断大功能模块是否已经开启
              local already = XinGongNengOpenDLG.checkFeatureOpened(record.id)
              if already and record.iseffect ~= 0 then return end
             XinGongNengOpenDLG.DestroyDialog()
             XinGongNengOpenDLG.getInstanceAndShow():setNewFeature(record.id, record.icon, record.site, record.index, record.iseffect)
             break
        end
    end
end

function XinGongNengOpenDLG.CheckOpenXingGongNengByTaskComplete(taskid)
    local tableAllId = BeanConfigManager.getInstance():GetTableByName("mission.cnewfunctionopen"):getAllID()
    for _, v in pairs(tableAllId) do
        local record = BeanConfigManager.getInstance():GetTableByName("mission.cnewfunctionopen"):getRecorder(v)
        local taskStr = record.taskfinish

        if taskStr ~= "0" then
            local strTable = StringBuilder.Split(taskStr, ",")
            for _, v in pairs(strTable) do
                if v == tostring(taskid) then
                    if record.iseffect == 2 then
                        NewRoleGuideManager.getInstance():GuideStartFunction(record.id)
                        return
                    end

                     --判断大功能模块是否已经开启
                    local already = XinGongNengOpenDLG.checkFeatureOpened(record.id)
                    if already and record.iseffect ~= 0 then return end
                    if taskid == 180133 then  -- 宠物
                        if CMainPackDlg:GetSingleton() then
                            CMainPackDlg:GetSingleton():DestroyDialog()
                        end
                    end
                    XinGongNengOpenDLG.DestroyDialog()
                    XinGongNengOpenDLG.getInstanceAndShow():setNewFeature(record.id, record.icon, record.site, record.index, record.iseffect)
                    break
                end
            end
        end
    end
end

function XinGongNengOpenDLG:setNewFeature(id, resStr, site, index, playType)
    local logoinfo = require "logic.logo.logoinfodlg".getInstanceNotCreate()
    if logoinfo then
        logoinfo:checkBtnShow()
    end

    local maincontrol = require "logic.maincontrol".getInstanceNotCreate()
    if maincontrol then
        maincontrol:checkBtnShow()
    end

    self.toOpenID = id
    self.flySite = site
    self.toOpenIndex = index
    self.flyType = playType
    self.m_pImage:setProperty("Image", resStr)

    if self.flyType == 0 then return end

    if self.flySite == 1 then
		if maincontrol then
            local SettingEnum = require "protodef.rpcgen.fire.pb.sysconfigtype":new()
            local record = GameTable.SysConfig.GetCGameconfigTableInstance():getRecorder(SettingEnum.framesimplify)
            if record.id ~= -1 then
                local strKey = record.key
                local value = gGetGameConfigManager():GetConfigValue(strKey)
                if value == 0 then 
                    self.tpos = maincontrol:getBtnScreenPos(self.toOpenIndex)
                else
                    self.tpos = maincontrol:getBtnForRightDow()
                end
            end
		end
    elseif self.flySite == 2 then
		if logoinfo then
            local SettingEnum = require "protodef.rpcgen.fire.pb.sysconfigtype":new()
            local record = GameTable.SysConfig.GetCGameconfigTableInstance():getRecorder(SettingEnum.framesimplify)
            if record.id ~= -1 then
                local strKey = record.key
                local value = gGetGameConfigManager():GetConfigValue(strKey)
                if value == 0 then 
                    self.tpos = logoinfo:getBtnScreenPos(self.toOpenIndex)
                else
                    if maincontrol then
                        self.tpos = maincontrol:getBtnForRightDow()
                    end
                end
            end
			
		end
    elseif self.flySite == 3 then
        local winMgr = CEGUI.WindowManager:getSingleton()
        local petIcon = winMgr:getWindow("UserPeticon/PetBack")
        self.tpos = petIcon:GetScreenPosOfCenter()
    elseif self.flySite == 4 then
		if logoinfo then
			self.tpos = logoinfo:getSiteFLpos()
		end
    end

    local dis = self.tpos - self.spos
    local angle = math.atan2(dis.y, dis.x) * 57.29577951
    local radians = angle * 0.017453292519943295769236907684886
    self.xSpeed = math.cos(radians) * 200
    self.ySpeed = math.sin(radians) * 200
end

function XinGongNengOpenDLG.checkFeatureOpened(tid)
	if tid == 0 then
		return true
	end

    if tid == 1 then
        return isPetOpen() == 1
    end

    local beanTabel = BeanConfigManager.getInstance():GetTableByName("mission.cnewfunctionopen")
    local record = beanTabel:getRecorder(tid)
    local recordSite = record.site
    local tBtnStr = record.btn
    local tLevel = record.needlevel
    local tEffect = record.iseffect
    local tTaskFinish = record.taskfinish

    if tTaskFinish == "0" and tEffect ~= 1 and tLevel ~= 0 then --多个功能在一个icon内靠等级判断是否开启功能
            local data = gGetDataManager():GetMainCharacterData()
            local curLevel = data:GetValue(fire.pb.attr.AttrType.LEVEL)
            if curLevel >= tLevel then return true end
            return false
    end

    local winMgr = CEGUI.WindowManager:getSingleton()

    if winMgr:isWindowPresent(tBtnStr) then
        local wnd = winMgr:getWindow(tBtnStr)
        if recordSite == 1 then
            return MainControl.getInstanceNotCreate():isCurrentBtnShown(wnd)
        elseif recordSite == 2 then
            return LogoInfoDialog.getInstanceNotCreate():isCurrentBtnShown(wnd)
        end
    end

    return false
end

function XinGongNengOpenDLG:run(delta)
    if _instance == nil then
        return
    end

    self.passtime = self.passtime + delta
    if self.passtime < self.waittime then
        return
    end

    if self.flyType == 0 then
        NewRoleGuideManager.getInstance():GuideStartFunction(self.toOpenID)
        self:DestroyDialog()
        return
    end

    local curpos = self.m_pImage:getPosition()
    local cursize = self.m_pImage:getSize()
    curpos.x.offset = curpos.x.offset + self.xSpeed * 0.1
    curpos.y.offset = curpos.y.offset + self.ySpeed * 0.1
    self.m_pImage:setPosition(curpos)
    self.m_pImage:setSize(cursize)

    local dis = self.tpos - self.m_pImage:GetScreenPosOfCenter()
    
    local fs = math.sqrt(dis.x * dis.x + dis.y * dis.y)
    if fs < 20  then
        if self.flySite == 1 then
        local SettingEnum = require "protodef.rpcgen.fire.pb.sysconfigtype":new()
        local record = GameTable.SysConfig.GetCGameconfigTableInstance():getRecorder(SettingEnum.framesimplify)
        if record.id ~= -1 then
            local strKey = record.key
            local value = gGetGameConfigManager():GetConfigValue(strKey)
            if value == 0 then 
                MainControl.getInstanceNotCreate():addBtnResetPos(self.toOpenIndex)
            end
        end
            
        elseif self.flySite == 2 then
            local SettingEnum = require "protodef.rpcgen.fire.pb.sysconfigtype":new()
            local record = GameTable.SysConfig.GetCGameconfigTableInstance():getRecorder(SettingEnum.framesimplify)
            if record.id ~= -1 then
                local strKey = record.key
                local value = gGetGameConfigManager():GetConfigValue(strKey)
                if value == 0 then 
                    LogoInfoDialog.getInstanceNotCreate():addBtnResetPos(self.toOpenIndex)
                end
            end
            
        end

		if YinCang.getInstanceNotCreate() ~= nil then
            YinCang.getInstanceNotCreate():CShowAllEx()
		end

        NewRoleGuideManager.getInstance():GuideStartFunction(self.toOpenID)
        self:DestroyDialog()
    end
end

function XinGongNengOpenDLG.setPetOpen(value)
    petOpened = value
end

return XinGongNengOpenDLG
