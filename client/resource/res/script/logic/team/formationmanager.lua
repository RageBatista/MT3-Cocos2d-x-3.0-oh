FormationManager = { }
FormationManager.__index = FormationManager

------------------- public: -----------------------------------
local _instance
function FormationManager.getInstance()
    LogInfo("enter get FormationManager instance")
    if not _instance then
        _instance = FormationManager:new()
    end

    return _instance
end

function FormationManager.Destroy()
    if _instance then
        LogInfo("destroy FormationManager")
        _instance = nil
    end
end

function FormationManager.InitFormation()
    LogInfo("FormationManager init formation")
    local instance = FormationManager.getInstance()
    instance.m_lFormaitonList = { }
    for i = 1, 10 do
        instance.m_lFormaitonList[i] = gGetDataManager():getFormation(i)
    end
end


------------------- private: -----------------------------------

function FormationManager:new()
    local self = { }
    setmetatable(self, FormationManager)
    self.m_lFormaitonList = { }
    self.m_iMyFormation = 0
    self.m_iTeamFormation = 0
    self.m_iTeamFormationLevel = 1
    return self
end

function FormationManager:updateFormations(formationmap)
    LogInfo("FormationManager update formation")
    for i, v in pairs(formationmap) do
        if not self.m_lFormaitonList[i] then
            self.m_lFormaitonList[i] = { }
            self.m_lFormaitonList[i].activetimes = 0
            self.m_lFormaitonList[i].level = 0
            self.m_lFormaitonList[i].exp = 0
        end

        if self.m_lFormaitonList[i].activetimes ~= v.activetimes or
            self.m_lFormaitonList[i].level ~= v.level or
            self.m_lFormaitonList[i].exp ~= v.exp then

            self.m_iLevelChange = nil
            self.m_iActiveChange = nil
            if self.m_lFormaitonList[i].level ~= v.level then
                self.m_iLevelChange = i
            else
                self.m_iActiveChange = i
            end
        end
        self.m_lFormaitonList[i].activetimes = v.activetimes
        self.m_lFormaitonList[i].level = v.level
        self.m_lFormaitonList[i].exp = v.exp
    end

    local dlg = ZhenFaDlg.getInstanceNotCreate()
    if dlg then
        dlg:recvZhenfaChanged()
    end

    dlg = TeamDialogNew.getInstanceNotCreate()
    if dlg then
        dlg:refreshZhenfaName()
    end

    dlg = require("logic.team.huobanzhuzhandialog").getInstanceNotCreate()
    if dlg then
        dlg:UpdataGuangHuan()
    end

    dlg = require("logic.zhenfa.zhenfabookchoosedlg").getInstanceNotCreate()
    if dlg then
        dlg:refresh()
    end
    YangChengListDlg.dealwithZhenfaUse()
end

function FormationManager:setMyFormation(formation, entersend)
    self.m_iMyFormation = formation
    if entersend == 0 then

    end
end

function FormationManager:setTeamFormation(formation, formationlevel, msg)
    LogInfo("FormationManager set team formation")
    self.m_iTeamFormation = formation
    self.m_iTeamFormationLevel = formationlevel

    local dlg = TeamDialogNew.getInstanceNotCreate()
    if dlg then
        dlg:refreshZhenfaName()
    end
end

function FormationManager:getFormationData(id)
    return self.m_lFormaitonList[id]
end

function FormationManager:getFormationLevel(id)
    if self.m_lFormaitonList[id] then
        return self.m_lFormaitonList[id].level
    end
    return 0
end

function FormationManager:getFormationExp(id)
    return self.m_lFormaitonList[id].exp
end

-- 是否有已学习的光环
function FormationManager:haveLearnedFormation()
    for _, v in pairs(self.m_lFormaitonList) do
        if v.level > 0 then
            return true
        end
    end
    return false
end

function FormationManager:loadZhenfaEffectTable()
    local ids = BeanConfigManager.getInstance():GetTableByName("team.czhenfaeffect"):getAllID()

    self.zhenfaEffectTable = { }
    for i = 1, #ids do
        local conf = BeanConfigManager.getInstance():GetTableByName("team.czhenfaeffect"):getRecorder(ids[i])
        if conf.zhenfaid > 0 then
            self.zhenfaEffectTable[conf.zhenfaid] = self.zhenfaEffectTable[conf.zhenfaid] or { }
            self.zhenfaEffectTable[conf.zhenfaid][conf.zhenfaLv] = conf
        end
    end
end

function FormationManager:getZhenfaEffectConf(id, level)
    if not self.zhenfaEffectTable then
        self:loadZhenfaEffectTable()
    end
    return self.zhenfaEffectTable[id][level]
end

function FormationManager:getUpgradeExp(id, level)
    if not self.zhenfaEffectTable then
        self:loadZhenfaEffectTable()
    end
    local nextEffectConf = self.zhenfaEffectTable[id][level + 1]
    return(nextEffectConf and nextEffectConf.needexp or 0)
end

return FormationManager
