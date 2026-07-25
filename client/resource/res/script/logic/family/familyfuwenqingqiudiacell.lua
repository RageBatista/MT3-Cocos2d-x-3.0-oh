Familyfuwenqingqiudiacell = { }

setmetatable(Familyfuwenqingqiudiacell, Dialog)
Familyfuwenqingqiudiacell.__index = Familyfuwenqingqiudiacell
local prefix = 0

function Familyfuwenqingqiudiacell.CreateNewDlg(parent)
    local newDlg = Familyfuwenqingqiudiacell:new()
    newDlg:OnCreate(parent)
    return newDlg
end

function Familyfuwenqingqiudiacell.GetLayoutFileName()
    return "familyfuwenqingqiudiacell.layout"
end

function Familyfuwenqingqiudiacell:new()
    local self = { }
    self = Dialog:new()
    setmetatable(self, Familyfuwenqingqiudiacell)
    return self
end

function Familyfuwenqingqiudiacell:OnCreate(parent)
    prefix = prefix + 1
    Dialog.OnCreate(self, parent, prefix)

    local winMgr = CEGUI.WindowManager:getSingleton()
    local prefixstr = tostring(prefix)
    -- icon
    self.m_Icon = winMgr:getWindow(prefixstr .. "familyfuwenqingqiudiacell/dikuang/icon")
    -- 描述
    self.m_Desc = winMgr:getWindow(prefixstr .. "familyfuwenqingqiudiacell/time")
    -- 捐赠按钮
    self.m_JuanZengBtn = CEGUI.toPushButton(winMgr:getWindow(prefixstr .. "familyfuwenqingqiudiacell/diban/btn"))
    -- 名字文本
    self.m_NameText = CEGUI.toRichEditbox(winMgr:getWindow(prefixstr .. "familyfuwenqingqiudiacell/xinxi"))
    -- 职业图标
    self.m_ZhiyeIcon = winMgr:getWindow(prefixstr .. "familyfuwenqingqiudiacell/diban/renwu/icon")
    -- 描述
    self.m_RoleInfor = CEGUI.toRichEditbox(winMgr:getWindow(prefixstr .. "familyfuwenqingqiudiacell/diban/renwu/text"))
    self.m_RoleInfor:setWordWrapping(false)
end
function Familyfuwenqingqiudiacell:SetInfor(infor)
    self.m_JuanZengBtn:setVisible(true)
    -- 设置图片显示
    local shape = BeanConfigManager.getInstance():GetTableByName("npc.cnpcshape"):getRecorder(infor.shape)
    local iconPath = gGetIconManager():GetImagePathByID(shape.littleheadID):c_str()
    self.m_Icon:setProperty("Image", iconPath)
    -- 设置文本
    local temp = math.ceil(infor.requesttime / 60 / 1000)
    local tt = MHSD_UTILS.get_resstring(11333)
    tt = string.gsub(tt, "%$parameter1%$", tostring(temp))
    self.m_Desc:setText(tostring(tt))
    -- 设置名字文本
    -- 动作类型  0 请求符文    1捐献符文
    self.m_Type = infor.actiontype
    self.m_ZhiyeIcon:setVisible(self.m_Type == 1)
    self.m_RoleInfor:setVisible(self.m_Type == 1)
    self.m_Desc:setVisible(self.m_Type == 0)
    local text = ""
    local data = BeanConfigManager.getInstance():GetTableByName("clan.cruneset"):getRecorder(infor.itemid)
    if self.m_Type == 0 then
        local Mydata = gGetDataManager():GetMainCharacterData()
        text = MHSD_UTILS.get_resstring(11323)
        local name = ""
        if Mydata.roleid == infor.roleid then
            name = MHSD_UTILS.get_resstring(1760)
            local itemAttrCfg = BeanConfigManager.getInstance():GetTableByName("item.citemattr"):getRecorder(infor.itemid)
            if itemAttrCfg then
                local icon = gGetIconManager():GetItemIconPathByID(itemAttrCfg.icon)
                self.m_Icon:setProperty("Image", icon:c_str())
            end
        else
            name = infor.rolename
        end
        text = string.gsub(text, "%$parameter1%$", tostring(name))
        if data then
            text = string.gsub(text, "%$parameter2%$", data.name .. data.desc)
        end
        if Mydata.roleid == infor.roleid then
            self.m_JuanZengBtn:setVisible(false)
        end
    else
        local datamanager = require "logic.faction.factiondatamanager"
        local schoolName = BeanConfigManager.getInstance():GetTableByName("role.schoolinfo"):getRecorder(infor.school)
        if schoolName then
            -- 职业图标
            self.m_ZhiyeIcon:setProperty("Image", schoolName.schooliconpath)
            local text = MHSD_UTILS.get_resstring(11348)
            text = string.gsub(text, "%$parameter1%$", tostring(infor.level))
            text = string.gsub(text, "%$parameter2%$", tostring(infor.givenum))
            text = string.gsub(text, "%$parameter3%$", tostring(infor.acceptnum))
            text = string.gsub(text, "%$parameter4%$", tostring(temp))
            self.m_RoleInfor:Clear()
            self.m_RoleInfor:AppendParseText(CEGUI.String(text))
            self.m_RoleInfor:Refresh()
        end


        self.m_JuanZengBtn:setVisible(false)
        text = MHSD_UTILS.get_resstring(11324)
        text = string.gsub(text, "%$parameter1%$", tostring(infor.rolename))
        text = string.gsub(text, "%$parameter2%$", infor.targetrolename)
        if data then
            text = string.gsub(text, "%$parameter3%$", data.name)
        end

    end
    self.m_NameText:Clear()
    self.m_NameText:AppendParseText(CEGUI.String(text))
    self.m_NameText:AppendBreak()
    self.m_NameText:Refresh()
end

return Familyfuwenqingqiudiacell
