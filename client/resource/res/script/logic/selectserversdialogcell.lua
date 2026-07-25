require "logic.dialog"

SelectServersDialogCell = {}
setmetatable(SelectServersDialogCell, Dialog)
SelectServersDialogCell.__index = SelectServersDialogCell

SUniqueID = 0

local function SelectServersDialogCellGetOpenTimeFormat()
    if MHSD_UTILS and MHSD_UTILS.get_resstring then
        local ok, formatstr = pcall(MHSD_UTILS.get_resstring, 11576)
        if ok and formatstr and formatstr ~= "" then
            return formatstr
        end
        if LogErr then
            LogErr("[SelectServerDiag] GetOpenTimeFormat fallback format=" .. tostring(formatstr) .. " ok=" .. tostring(ok))
        end
    end

    return "$parameter1$"
end


function SelectServersDialogCell.CreateNewDlg(pParentDlg)
	local newDlg = SelectServersDialogCell:new()
	newDlg:OnCreate(pParentDlg)

    return newDlg
end

----/////////////////////////////////////////------

function SelectServersDialogCell.GetLayoutFileName()
    return "selectserversbotcell.layout"
end

function SelectServersDialogCell:OnCreate(pParentDlg)
	SUniqueID = SUniqueID + 1
	local namePrefix = tostring(SUniqueID)

    Dialog.OnCreate(self, pParentDlg, namePrefix)

    local winMgr = CEGUI.WindowManager:getSingleton()
    -- get windows
	self.m_CellBack = winMgr:getWindow(namePrefix .. "SelectServers/back/Bot/back1")
	self.m_Status = winMgr:getWindow(namePrefix .. "selectserversbotcell/state")
    self.m_CellGBtn = CEGUI.Window.toGroupButton(winMgr:getWindow(namePrefix ..  "SelectServers/server1") )
	self.m_Name = winMgr:getWindow(namePrefix .. "SelectServers/servername")
	self.m_Desc = winMgr:getWindow(namePrefix .. "SelectServers/serverinfo")
	self.m_RoleName = winMgr:getWindow(namePrefix .. "SelectServers/server1/rolename")
	self.m_Level = winMgr:getWindow(namePrefix .. "SelectServers/server1/level")
	self.m_Icon  = winMgr:getWindow(namePrefix .. "SelectServers/back/Bot/back1/role")
    self.m_IconBg = winMgr:getWindow(namePrefix .. "SelectServers/dikuang")
    self.m_DianKaServer = winMgr:getWindow(namePrefix.. "SelectServers/server1/dianka")
    self.m_TuijianServer = winMgr:getWindow(namePrefix.. "SelectServers/server1/dianka1")
    self.m_newServer = winMgr:getWindow(namePrefix.. "SelectServers/back/Bot/back1/xinfubiaoji")
    self.m_serverTime = winMgr:getWindow(namePrefix.. "SelectServers/servername1")

	self.m_RoleName:setVisible(false)
	self.m_Level:setVisible(false)
	self.m_Icon:setVisible(false)
    self.m_IconBg:setVisible(false)

    -- subscribe event
	self.m_CellGBtn:subscribeEvent("SelectStateChanged", SelectServersDialog.HandleSelectServerStateChanged, SelectServersDialog.getInstance()) 
	self.m_CellGBtn:EnableClickAni(false)
	
	self:setServerStatus(0)
end

function SelectServersDialogCell:new()
    local self = {}
    self = Dialog:new()
    setmetatable(self, SelectServersDialogCell)

    return self
end

function SelectServersDialogCell:SetCellVisible(bVisible)
	self.m_CellBack:setVisible(bVisible)
end

function SelectServersDialogCell:SetSelectedState(selectedid)
	LogInfo("select servers setselectedstate id " .. selectedid)
	local gbtnselstate =  (self.m_CellBack:getID() == selectedid)
	self.m_CellGBtn:setSelected(gbtnselstate)
end

function SelectServersDialogCell:SetCellInfo(serverkey, serverinfo, selectedname, serverroleinfo)
	if serverinfo then
        local sName = serverinfo["servername"]

        local pos = string.find(sName, "-")
        if pos then
            self.m_Name:setText(string.sub(sName, 1, pos - 1))
        else
            self.m_Name:setText(sName)
        end
		self.status = serverinfo["status"]
		self:setServerStatus(0)
		self.m_CellBack:setID(serverkey)
		self.m_CellGBtn:setID(serverkey)
		self:SetCellVisible(true)
        self.serverid = serverinfo["serverid"]

        local roleSeq = GetServerInfo():getRoleHeadInfoByServerID(serverkey)
        
        if roleSeq ~= -1 then
                local roleCreateCfg = BeanConfigManager.getInstance():GetTableByName("role.createroleconfig"):getRecorder(roleSeq)
                local shapeConfig = BeanConfigManager.getInstance():GetTableByName("npc.cnpcshape"):getRecorder(roleCreateCfg.model)
                local littleheadID = shapeConfig.littleheadID
                if littleheadID then
                    self.m_Icon:setProperty("Image", gGetIconManager():GetImagePathByID(littleheadID):c_str())
                    self.m_IconBg:setVisible(true)
                    self.m_Icon:setVisible(true)
                end
        end

--        self.m_Type = tonumber(serverinfo["type"])
--        if self.m_Type == 1 then
--            self.m_DianKaServer:setVisible(true)
--        else
        self.m_DianKaServer:setVisible(false)
--        end

        if serverinfo["flag"] == SERVER_STATUS_TUIJIAN or serverinfo["flag"] == SERVER_STATUS_BOUTH then --平台返回的服务器状态  --0 推荐 1 新开
            self.m_TuijianServer:setVisible(true)
        else
            self.m_TuijianServer:setVisible(false)
        end

        if serverinfo["flag"] == SERVER_STATUS_NEW or serverinfo["flag"] == SERVER_STATUS_BOUTH then --平台返回的服务器状态   --0 推荐 1 新开
            self.m_newServer:setVisible(true)
        else
            self.m_newServer:setVisible(false)
        end

        if not serverinfo["opentime"] or string.find(serverinfo["opentime"], "0000") then
            self.m_serverTime:setVisible(false)
        else
            self.m_serverTime:setVisible(true)
            local sb = require "utils.stringbuilder":new()
            local formatstr = SelectServersDialogCellGetOpenTimeFormat()
            sb:Set("parameter1", serverinfo["opentime"])
            sb:delete()
            local msg = sb:GetString(formatstr)
            self.m_serverTime:setText(msg)
        end
	end
end


function SelectServersDialogCell:setServerStatus(state)
	if state == 1 or state == 2 then	--畅通
		self.m_Status:setProperty("Image", "set:ccui1 image:lvsecc1")
	elseif state == 3 then  --爆满
		self.m_Status:setProperty("Image", "set:ccui1 image:hongsecc1")
	else  --维护
		self.m_Status:setProperty("Image", "set:ccui1 image:huisecc1")
	end


    --优先平台的数据  
    if state > 0 and self.status == SERVER_STATUS_BAOMAN then
        self.m_Status:setProperty("Image", "set:ccback image:tuijian")
    elseif state > 0 and self.status == SERVER_STATUS_YONGDU then
        self.m_Status:setProperty("Image", "set:ccback image:tuijian")
    end
end
------------------- end -----------------------------------

return SelectServersDialogCell
