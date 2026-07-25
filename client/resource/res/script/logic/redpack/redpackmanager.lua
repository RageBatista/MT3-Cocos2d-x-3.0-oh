RedPackManager = {}
RedPackManager.__index = RedPackManager

------------------- public: -----------------------------------

local _instance;
function RedPackManager.getInstance()
	--LogInfo("enter get RedPackManager instance")
	if not _instance then
		_instance = RedPackManager:new()
	end
	
	return _instance
end

function RedPackManager.getInstanceNotCreate()
	return _instance
end

function RedPackManager.Destroy()
	if _instance then
		_instance = nil
	end
end
function RedPackManager:new()
	local self = {}
	setmetatable(self, RedPackManager)
    self.m_RedPacks = {}

    -- 1世界红包  2公会红包 3队伍红包
    self.m_RedPackNums = {}

    self.m_HistoryRedPack = {}

    self.m_Notice = nil

	return self
    
end
function RedPackManager:setNotice(data)
    local scale = 1
    local manager = require "logic.pointcardserver.pointcardservermanager".getInstanceNotCreate()
    if manager then
        if manager.m_isPointCardServer then
            scale = 100
        end
    end
    local realsize = 1
    realsize = realsize - tonumber(GameTable.common.GetCCommonTableInstance():getRecorder(365).value) / 100
    local dlg = require"logic.petandusericon.userandpeticon".getInstanceNotCreate()
    if data.modeltype == 1 then
        if dlg then
            --dlg:AddRedPackEffectForAll(data.fushi)
            if data.fushi == 2000 * scale * realsize then
                require"logic.redpack.topeffectdlg".DestroyDialog()
                local effectdlg = require"logic.redpack.topeffectdlg".getInstanceAndShow()
                if effectdlg then
                    effectdlg:startRedPackAll()
                end
            end

        end
    end

    if self.m_Notice == nil then
        self.m_Notice = data
    else 
        local level = 0
        if self.m_Notice.fushi >= 20 * scale * realsize and self.m_Notice.fushi < 1000 * scale * realsize then
            level = 1
        elseif self.m_Notice.fushi >=1000 * scale * realsize and self.m_Notice.fushi < 2000 * scale * realsize then
            level = 2
        elseif self.m_Notice.fushi >=2000 * scale * realsize then
            level = 3
        end
        local datalevel = 0
        if data.fushi >= 20 * scale * realsize and data.fushi < 1000 * scale * realsize then
            datalevel = 1
        elseif data.fushi >=1000 * scale * realsize and data.fushi < 2000 * scale * realsize then
            datalevel = 2
        elseif data.fushi >=2000 * scale * realsize then
            datalevel = 3
        end

        if datalevel >= level then
            self.m_Notice = data
        else    
            return
        end
    end
    local dlg = require"logic.petandusericon.userandpeticon".getInstanceNotCreate()
    if dlg then
        dlg.m_RedPackId = self.m_Notice.redpackid
        dlg.m_RedPackType = self.m_Notice.modeltype
        dlg.m_RedPackBg:setVisible(true)
        if self.m_Notice.fushi < 1000 * scale * realsize then
            dlg.m_RedPackNormal:setVisible(true)
            dlg.m_RedPackGold:setVisible(false)
        else
            dlg.m_RedPackNormal:setVisible(false)
            dlg.m_RedPackGold:setVisible(true)
        end
        dlg.m_RedPackName:setText(self.m_Notice.rolename)
    end
    local UserMiniIconDlg = require "logic.battle.userminiicondlg"
    dlg = UserMiniIconDlg:getInstanceOrNot()
    if dlg then
        dlg.m_RedPackId = self.m_Notice.redpackid
        dlg.m_RedPackType = self.m_Notice.modeltype
        dlg.m_RedPackBg:setVisible(true)
        if self.m_Notice.fushi < 1000 * scale * realsize then
            dlg.m_RedPackNormal:setVisible(true)
            dlg.m_RedPackGold:setVisible(false)
        else
            dlg.m_RedPackNormal:setVisible(false)
            dlg.m_RedPackGold:setVisible(true)
        end
        dlg.m_RedPackName:setText(self.m_Notice.rolename)
    end
end
function RedPackManager.GetRedPack(temp,redpackid,redpacktype,temp1)
    local p = require("protodef.fire.pb.fushi.redpack.cgetredpack"):new()
    p.modeltype = redpacktype
    p.redpackid = redpackid
    LuaProtocolManager:send(p)
end
function RedPackManager:UpdateData(data)
    if self.m_Notice ~= nil then
        if self.m_Notice.redpackid == data.redpackid then
            local dlg = require"logic.petandusericon.userandpeticon".getInstanceNotCreate()
            if dlg then
                dlg.m_RedPackBg:setVisible(false)
            end
            local UserMiniIconDlg = require "logic.battle.userminiicondlg"
            dlg = UserMiniIconDlg:getInstanceOrNot()
            if dlg then
                dlg.m_RedPackBg:setVisible(false)
            end
            self.m_Notice = nil
        end
    end
    for n = 1, 3 do
        local redpacks = self.m_RedPacks[n]
        if redpacks then
            for i,v in pairs (redpacks) do
                if v.redpackid == data.redpackid then
                    redpacks[i].redpackstate = data.state
                    local dlg = require"logic.redpack.redpackdlg".getInstanceNotCreate()
                    if dlg then
                        if dlg.m_index == data.modeltype then
                            dlg:InitTable()
                        end
                    end
                end
            end
        end

    end

end
return RedPackManager
