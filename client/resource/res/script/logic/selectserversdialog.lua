require "logic.dialog"
require "logic.selectserversdialogcell"
require "config"
require "logic.newswarndlg"
require "logic.loginwaitingdialog"
require "logic.selectserversareacell"
require "utils.commonutil"

SelectServersDialog = {}
setmetatable(SelectServersDialog, Dialog)
SelectServersDialog.__index = SelectServersDialog

SERVER_STATUS_TUIJIAN = "0"  --在服务器 NS字段
SERVER_STATUS_NEW = "1"    
SERVER_STATUS_BOUTH = "2"  --同时推荐 新开

SERVER_STATUS_BAOMAN = "3" --在服务器 S字段 爆满
SERVER_STATUS_YONGDU = "1" --繁忙/拥堵

local CHECK_LOAD_DUR = 5 --second
local _serverLoadStateMap = {}

local lastServerID = -1

local threePvpServerID = "1101011999"

------------------- public: -----------------------------------
---- singleton /////////////////////////////////////////------
local _instance;
function SelectServersDialog.getInstance()
    if not _instance then
        _instance = SelectServersDialog:new()
        _instance:OnCreate()
    end
    
    return _instance
end

function SelectServersDialog.getInstanceAndShow()
    if not _instance then
        _instance = SelectServersDialog:new()
        _instance:OnCreate()
	else
		_instance:SetVisible(true)
    end
    return _instance
end

function SelectServersDialog.getInstanceNotCreate()
    return _instance
end

function SelectServersDialog.DestroyDialog()
	if _instance then
		_serverLoadStateMap = {}
		if not _instance.m_bCloseIsHide then
            if gGetLoginManager() then 
			    gGetLoginManager():ClearConnections()
            end
			_instance:ClearAllServerCells()
			_instance:ClearAllAreaCells()
			_instance:OnClose() 
			_instance = nil
		else
			_instance:ToggleOpenClose()
		end
	end
end

function SelectServersDialog.ToggleOpenClose()
	if not _instance then 
		_instance = SelectServersDialog:new() 
		_instance:OnCreate()
	else
		if _instance:IsVisible() then
			_instance:SetVisible(false)
		else
			_instance:SetVisible(true)
		end
	end
end

function SelectServersDialog.GetLayoutFileName()
    return "selectserversnew.layout"
end

local function SelectServersDialogHasVisibleServers(areaInfo)
    if not areaInfo or not areaInfo.servers then
        return false
    end

    for _, _ in pairs(areaInfo.servers) do
        return true
    end

    return false
end

local function SelectServersDialogTableCount(t)
    local count = 0
    if t then
        for _, _ in pairs(t) do
            count = count + 1
        end
    end
    return count
end

local function SelectServersDialogServerCount(areaInfo)
    if not areaInfo then
        return 0
    end
    return SelectServersDialogTableCount(areaInfo.servers)
end

local function SelectServersDialogDiag(msg)
    msg = "[SelectServerDiag] " .. tostring(msg)
    if LogInfo then
        LogInfo(msg)
    end
    print(msg)
end

local DEFAULT_RECOMMEND_AREA_NAME = string.char(230, 142, 168, 232, 141, 144, 230, 156, 141, 229, 138, 161, 229, 153, 168)

local function SelectServersDialogGetRecommendAreaName()
    if MHSD_UTILS and MHSD_UTILS.get_resstring then
        local ok, area = pcall(MHSD_UTILS.get_resstring, 11550)
        if ok and area and area ~= "" then
            return area
        end
        SelectServersDialogDiag("GetRecommendAreaName fallback area=" .. tostring(area) .. " ok=" .. tostring(ok))
    end
    return DEFAULT_RECOMMEND_AREA_NAME
end

local function SelectServersDialogGetAreaNameByID(areaMap, areaID)
    local targetID = tonumber(areaID)
    if not areaMap or not targetID then
        return nil
    end

    for areaName, areaInfo in pairs(areaMap) do
        if areaInfo and tonumber(areaInfo.id) == targetID then
            return areaName
        end
    end

    return nil
end

function SelectServersDialog:OnCreate()
    SelectServersDialogDiag("OnCreate begin")
    Dialog.OnCreate(self)

    local winMgr = CEGUI.WindowManager:getSingleton()

    self.m_OKBtn = CEGUI.Window.toPushButton(winMgr:getWindow("selectserversnew/gotogame") )
    self.m_ReturnBtn = CEGUI.Window.toPushButton(winMgr:getWindow("selectserversnew/backtolog") )
    self.m_ServerListBack = CEGUI.Window.toScrollablePane(winMgr:getWindow("selectserversnew/back/Bot") )
	self.m_AreaListBack = CEGUI.Window.toScrollablePane(winMgr:getWindow("selectserversnew/back/xuanqu") )
    self.m_AreaListBack:EnablePageScrollMode(true)
    SelectServersDialogDiag(string.format("OnCreate windows ok okBtn=%s returnBtn=%s serverPane=%s areaPane=%s", tostring(self.m_OKBtn ~= nil), tostring(self.m_ReturnBtn ~= nil), tostring(self.m_ServerListBack ~= nil), tostring(self.m_AreaListBack ~= nil)))
	--self.m_AreaListBack:EnableHorzScrollBar(true)

    self:GetCloseBtn():removeEvent("Clicked")
	self:GetCloseBtn():subscribeEvent("Clicked", SelectServersDialog.HandleReturnBtnClicked, self)

    -- subscribe event
    self.m_OKBtn:subscribeEvent("Clicked",  SelectServersDialog.HandleOKBtnClicked, self) 
    self.m_ReturnBtn:subscribeEvent("Clicked", SelectServersDialog.HandleReturnBtnClicked, self)

--    self.m_SelectArea = gGetLoginManager():GetSelectArea()

	-- init settings
	self:OnInit()  --读取所有服务器信息
    SelectServersDialogDiag(string.format("OnCreate after OnInit areaMapCount=%d selectArea=%s", SelectServersDialogTableCount(self.m_AreaServersMap), tostring(self.m_SelectArea)))
	self:InitAreaList() --大区栏
    SelectServersDialogDiag(string.format("OnCreate after InitAreaList areaCells=%d selectArea=%s", SelectServersDialogTableCount(self.m_Area), tostring(self.m_SelectArea)))
	self:ClearAllServerCells()
	self:RefreshServerCells(self.m_SelectArea)
    SelectServersDialogDiag(string.format("OnCreate after RefreshServerCells serverCells=%d selectArea=%s", SelectServersDialogTableCount(self.m_ArrayServerCells), tostring(self.m_SelectArea)))
    self:SelectCurrentAreaBtn() --高亮大区栏按钮
	self:DeselectOtherServerBtn()   --高亮服务器按钮

end

function SelectServersDialog.setLastSelect(sid)
    lastServerID = sid
end

function SelectServersDialog:new()
    local self = {}
    self = Dialog:new()
    setmetatable(self, SelectServersDialog)

    return self
end

function SelectServersDialog:GetDefaultSelectAreaName(areaSort)
    if not self.m_AreaServersMap then
        SelectServersDialogDiag("GetDefaultSelectAreaName areaMap=nil")
        return nil
    end

    local selectArea = self.m_SelectArea
    SelectServersDialogDiag(string.format("GetDefaultSelectAreaName begin selfSelect=%s areaSortCount=%d", tostring(selectArea), SelectServersDialogTableCount(areaSort)))
    if (not selectArea or selectArea == "") and gGetLoginManager then
        local loginManager = gGetLoginManager()
        if loginManager then
            selectArea = loginManager:GetSelectArea()
            SelectServersDialogDiag("GetDefaultSelectAreaName loginManagerSelect=" .. tostring(selectArea))
        end
    end

    if selectArea and selectArea ~= "" then
        local areaInfo = self.m_AreaServersMap[selectArea]
        if SelectServersDialogHasVisibleServers(areaInfo) then
            SelectServersDialogDiag(string.format("GetDefaultSelectAreaName keep selectArea=%s serverCount=%d", tostring(selectArea), SelectServersDialogServerCount(areaInfo)))
            return selectArea
        end
        SelectServersDialogDiag("GetDefaultSelectAreaName invalid selectArea=" .. tostring(selectArea))
    end

    if areaSort then
        for _, areaInfo in ipairs(areaSort) do
            local areaName = areaInfo.name
            if areaName and SelectServersDialogHasVisibleServers(self.m_AreaServersMap[areaName]) then
                SelectServersDialogDiag(string.format("GetDefaultSelectAreaName fallback sorted area=%s serverCount=%d", tostring(areaName), SelectServersDialogServerCount(self.m_AreaServersMap[areaName])))
                return areaName
            end
        end
    end

    for areaName, areaInfo in pairs(self.m_AreaServersMap) do
        if SelectServersDialogHasVisibleServers(areaInfo) then
            SelectServersDialogDiag(string.format("GetDefaultSelectAreaName fallback pairs area=%s serverCount=%d", tostring(areaName), SelectServersDialogServerCount(areaInfo)))
            return areaName
        end
    end

    SelectServersDialogDiag("GetDefaultSelectAreaName return empty selectArea=" .. tostring(selectArea))
    return selectArea
end

function SelectServersDialog:HandleOKBtnClicked(args)
     if self.m_AreaServersMap[self.m_SelectArea].lastSelectID == -1 then
       gGetMessageManager():AddConfirmBox(eConfirmOK, MHSD_UTILS.get_msgtipstring(160479),
            MessageManager.HandleDefaultCancelEvent, MessageManager,
            MessageManager.HandleDefaultCancelEvent, MessageManager
        )
        return
     end
    local roleSeq = GetServerInfo():getRoleHeadInfoByServerID(self.m_AreaServersMap[self.m_SelectArea].lastSelectID)
    if roleSeq  == -1 then
        if self.m_AreaServersMap[self.m_SelectArea].servers[tostring(self.m_AreaServersMap[self.m_SelectArea].lastSelectID)]["type"]== "1" then
            require"logic.pointcardserver.firstenterpointmsgdlg".getInstanceAndShow()
            return
        end
    end
    
    local area = self.m_AreaServersMap[self.m_SelectArea]
    local serverid = tostring(area.lastSelectID)
	local server = area.servers[serverid]
    if DeviceInfo:sGetDeviceType()==4 then --WIN7_32
        local serverName = server.servername
        local pos = string.find(serverName, "-")
        if pos then
            serverName = string.sub(serverName, 1, pos - 1)
        end
        gGetGameApplication():SetGameMainWindowTitle(Config.GetGameName(server["type"]) .. "---" .. serverName)
    end

    self:SelectServerFinish()
    
    return true
end
function SelectServersDialog:SelectServerFinish()
    --检查网络连接
    if not DeviceData:sIsNetworkConnected() then
        gGetMessageManager():AddConfirmBox(eConfirmOK, MHSD_UTILS.get_resstring(11310),	--你的网络不给力啊，快去检查一下吧！
            MessageManager.HandleDefaultCancelEvent, MessageManager,
            MessageManager.HandleDefaultCancelEvent, MessageManager
        )
        return
    end

    local area = self.m_AreaServersMap[self.m_SelectArea]
    local serverid = tostring(area.lastSelectID)
	local server = area.servers[serverid]

    if DeviceInfo:sGetDeviceType()==4 then --WIN7_32
        local serverName = server.servername
        local pos = string.find(serverName, "-")
        if pos then
            serverName = string.sub(serverName, 1, pos - 1)
        end
        gGetGameApplication():SetGameMainWindowTitle(Config.GetGameName(server["type"]) .. "---" .. serverName)
    end

    local couldEntry = SelectServersDialog.CheckCouldEnterThreePvp(serverid)

    if couldEntry then
        local lowport = tonumber(server.port)
        local highport = lowport + tonumber(server.standby) - 1
        highport = math.max(lowport, highport)
        local port = StringCover.randBetween(lowport, highport)

        gGetLoginManager():SetSelectServerInfo(self.m_SelectArea, server.servername, server.ip, tostring(port), 0)
        gGetLoginManager():Init()

        self:DestroyDialog()
        SelectServerEntry.getInstanceAndShow()
    else
        local strMsg = MHSD_UTILS.get_msgtipstring(172039)
        gGetMessageManager():AddConfirmBox(eConfirmOK, strMsg,
            MessageManager.HandleDefaultCancelEvent, MessageManager,
            MessageManager.HandleDefaultCancelEvent, MessageManager)
    end
end

function SelectServersDialog.CheckCouldEnterThreePvp(sServerID)
    local couldEntry = false

    if sServerID == threePvpServerID then
        local account = gGetLoginManager():GetAccount()
        local pos = string.find(account, ",")
        if pos then
            account = string.sub(account, 1, pos - 1)
        end

        local tableAllId = BeanConfigManager.getInstance():GetTableByName("game.threepvpwhitemenu"):getAllID()
        for _, v in pairs(tableAllId) do
            local record = BeanConfigManager.getInstance():GetTableByName("game.threepvpwhitemenu"):getRecorder(v)
            if account and record then
                if account == record.username then
                    couldEntry = true
                    break
                end
            end
        end

    else
        couldEntry = true
    end

    return couldEntry
end


function SelectServersDialog:HandleReturnBtnClicked(args)
	SelectServersDialog.DestroyDialog()
	SelectServerEntry.getInstanceAndShow()
    return true
end

function SelectServersDialog:HandleSelectServerStateChanged(args)
	local eventargs = CEGUI.toWindowEventArgs(args)

    self.m_AreaServersMap[self.m_SelectArea].lastSelectID = eventargs.window:getID()
    lastServerID = eventargs.window:getID()

	self:DeselectOtherServerBtn()

    return true
end

function SelectServersDialog:HandleSelectAreaStateChanged(args)
	local eventargs = CEGUI.toWindowEventArgs(args)
    local areaID = eventargs.window:getID()
	
	if self.m_SelectAreaID == areaID then
		return true
	end

    local areaName = SelectServersDialogGetAreaNameByID(self.m_AreaServersMap, areaID)
    if not areaName then
        SelectServersDialogDiag("HandleSelectAreaStateChanged missing areaName areaID=" .. tostring(areaID))
        return true
    end

    self.m_SelectAreaID = areaID
    lastServerID = -1
	self.m_SelectArea = areaName
	self:ClearAllServerCells()
	self:RefreshServerCells(self.m_SelectArea)
    return true
end

function SelectServersDialog:OnInit()
    self.m_AreaServersMap = {}

    local servers = GetServerInfo():getAllServers()
    SelectServersDialogDiag("OnInit begin serverCount=" .. tostring(servers:size()))
    local areaIndex = 1
    local tuijianT = {}
    for index = 0, servers:size() - 1 do
        local nServerInfo = servers[index]
        local nAreaID = nServerInfo.areaID  --"I"
        local nServerid = nServerInfo.serverid   --"D"
        local nServerArea = nServerInfo.serverArea  --"A"
        local nServerName = nServerInfo.serverName --"N"
        local nServerIp = nServerInfo.serverIp --"P"
        local nServerPort = nServerInfo.serverPort --"T"
        local nServerState = nServerInfo.serverState --"S"
        local nServerStandby = nServerInfo.serverStandby --"B"   --配置多端口
        local nServerType = nServerInfo.serverType   --"C"
        local nServerOpenTime = nServerInfo.serverOpenTime  --"KS"
        local nServerFlag = nServerInfo.serverFlag --"NS"
        if nServerStandby == "" then
            nServerStandby = "1" 
        end

        if self.m_AreaServersMap[nServerArea] == nil then --初始化大区
            self.m_AreaServersMap[nServerArea] = {}
            self.m_AreaServersMap[nServerArea].id = areaIndex
            self.m_AreaServersMap[nServerArea].name = nServerArea
            self.m_AreaServersMap[nServerArea].lastSelectID = -1
            self.m_AreaServersMap[nServerArea].servers = {}
            areaIndex = areaIndex + 1
        end

        local groupKey = nServerid
        local otS, otE
        otS, otE = string.find(nServerName, "-(%d+)-")
        if otS and otE then
            groupKey = string.sub(nServerName, otE+1, string.len(nServerName))
        end

        self.m_AreaServersMap[nServerArea].servers[groupKey] = {}
        self.m_AreaServersMap[nServerArea].servers[groupKey]["serverid"] = nServerid
        self.m_AreaServersMap[nServerArea].servers[groupKey]["servername"] = nServerName
        self.m_AreaServersMap[nServerArea].servers[groupKey]["ip"] = nServerIp
        self.m_AreaServersMap[nServerArea].servers[groupKey]["port"] = nServerPort
        self.m_AreaServersMap[nServerArea].servers[groupKey]["status"] = nServerState
        self.m_AreaServersMap[nServerArea].servers[groupKey]["standby"] = nServerStandby
        self.m_AreaServersMap[nServerArea].servers[groupKey]["type"] = nServerType
        self.m_AreaServersMap[nServerArea].servers[groupKey]["opentime"] = nServerOpenTime
        self.m_AreaServersMap[nServerArea].servers[groupKey]["flag"] = nServerFlag   --"0" 推荐  "1"新开
        self.m_AreaServersMap[nServerArea].servers[groupKey]["exist"] = 0
        self.m_AreaServersMap[nServerArea].servers[groupKey]["orgid"] = groupKey  --合服前id
        SelectServersDialogDiag(string.format("OnInit server index=%s area=%s name=%s serverid=%s groupKey=%s ip=%s port=%s flag=%s status=%s", tostring(index), tostring(nServerArea), tostring(nServerName), tostring(nServerid), tostring(groupKey), tostring(nServerIp), tostring(nServerPort), tostring(nServerFlag), tostring(nServerState)))

        local stS, stE
        stS, stE = string.find(nServerName, "-%d+")
        if stS and stE then
            self.m_AreaServersMap[nServerArea].servers[groupKey]["sort"] = tonumber(string.sub(nServerName, stS + 1, stE))
        else
            self.m_AreaServersMap[nServerArea].servers[groupKey]["sort"] = 999999
        end

        if nServerFlag == SERVER_STATUS_TUIJIAN or nServerFlag == SERVER_STATUS_BOUTH then
            table.insert(tuijianT, self.m_AreaServersMap[nServerArea].servers[groupKey])
        end
    end

    --增加推荐大区 遍历所有服务器找到推荐状态的然后新建大区扔到大区里
    local area = SelectServersDialogGetRecommendAreaName()
    self.m_AreaServersMap[area] = {}
    self.m_AreaServersMap[area].id = 0
    self.m_AreaServersMap[area].name = area
    self.m_AreaServersMap[area].lastSelectID = -1
    self.m_AreaServersMap[area].servers = {}
    for k, v in pairs(tuijianT) do
        self.m_AreaServersMap[area].servers[v.serverid] = v
    end
    SelectServersDialogDiag(string.format("OnInit end areaMapCount=%d recommendArea=%s recommendCount=%d", SelectServersDialogTableCount(self.m_AreaServersMap), tostring(area), SelectServersDialogServerCount(self.m_AreaServersMap[area])))
end

--清除所有服务器cell显示
function SelectServersDialog:ClearAllServerCells()
    SelectServersDialogDiag("ClearAllServerCells count=" .. tostring(SelectServersDialogTableCount(self.m_ArrayServerCells)))
	if self.m_ArrayServerCells then
		for k,v in pairs(self.m_ArrayServerCells) do
			v:OnClose()
			v = nil
		end
	end
	self.m_ArrayServerCells = nil
end

function SelectServersDialog:ClearAllAreaCells()
    SelectServersDialogDiag("ClearAllAreaCells count=" .. tostring(SelectServersDialogTableCount(self.m_Area)))
	if self.m_Area then
		for k,v in pairs(self.m_Area) do
			v:OnClose()
			v = nil
		end
	end
	self.m_Area = nil
end

----/////////////////////////////////////////------
--刷新当前选中大区的服务器列表
function SelectServersDialog:RefreshServerCells(selectedAreaName)
    SelectServersDialogDiag(string.format("RefreshServerCells begin selectedArg=%s selfSelect=%s areaMapCount=%d", tostring(selectedAreaName), tostring(self.m_SelectArea), SelectServersDialogTableCount(self.m_AreaServersMap)))
	if self.m_AreaServersMap == nil then
        SelectServersDialogDiag("RefreshServerCells abort areaMap=nil")
        return
    end

	local selectedArea = self.m_AreaServersMap[selectedAreaName]
	if not selectedArea then
		for k,v in pairs(self.m_AreaServersMap) do
			if v.name == selectedAreaName then
				selectedArea = v
			end
		end
	end

    SelectServersDialogDiag(string.format("RefreshServerCells selectedAreaFound=%s selectedAreaName=%s serverCount=%d lastSelectID=%s", tostring(selectedArea ~= nil), tostring(selectedAreaName), SelectServersDialogServerCount(selectedArea), tostring(selectedArea and selectedArea.lastSelectID)))
	self:CheckServersLoad()

	if selectedArea then
		self.m_ArrayServerCells = {}

		local username = gGetLoginManager():GetAccount()
        local selectedSeverID = selectedArea.lastSelectID
		local col = 0
		local row = 0
		local index = 0

        local serversTable = {}
        local count = 1
        if selectedSeverID ~= -1 and selectedArea.servers[selectedSeverID] and selectedArea.servers[selectedSeverID].exist ~= -1 then
            selectedArea.servers[selectedSeverID].exist = 10 --大于人物数量 
        end
        for _, v in pairs(selectedArea.servers) do
            serversTable[count] = v
            count = count + 1
        end

        SelectServersDialogDiag(string.format("RefreshServerCells before sort serverTableCount=%d selectedLast=%s", count - 1, tostring(selectedSeverID)))
        table.sort(serversTable, function (a, b)
		    return a.sort < b.sort
	    end)

		for k,v in ipairs(serversTable) do
			col = index%2
			row = math.floor(index/2)
			index = index+1
            local curServerID = tonumber(v.serverid)
            SelectServersDialogDiag(string.format("RefreshServerCells create serverCell index=%d serverid=%s name=%s orgid=%s sort=%s", index, tostring(v.serverid), tostring(v.servername), tostring(v.orgid), tostring(v.sort)))
			self.m_ArrayServerCells[index] = SelectServersDialogCell.CreateNewDlg(self.m_ServerListBack)
			local mainFrame = self.m_ArrayServerCells[index]:GetWindow()
			local woffset = col*(mainFrame:getPixelSize().width - 15)
			local hoffset = row*(mainFrame:getPixelSize().height+1)
			mainFrame:setPosition(CEGUI.UVector2(CEGUI.UDim(0.0, woffset), CEGUI.UDim(0.0, hoffset)))

            local cellServerKey = curServerID
            if v.orgid ~= v.serverid then
                cellServerKey = tonumber(v.orgid)
            end

			if index == 1 and selectedSeverID == -1 then
                if lastServerID == -1 then --没有默认的取第一个服务器id
                    selectedSeverID = cellServerKey
                    lastServerID = cellServerKey
                    selectedArea.lastSelectID = cellServerKey
                else
                    selectedSeverID = lastServerID 
                    selectedArea.lastSelectID = lastServerID
                end
			end

 
			self.m_ArrayServerCells[index]:SetCellInfo(cellServerKey, v, selectedSeverID, nil)

			if _serverLoadStateMap[curServerID] then
				self.m_ArrayServerCells[index]:setServerStatus(_serverLoadStateMap[curServerID].serverLoad)
			end

		end
		
        SelectServersDialogDiag(string.format("RefreshServerCells created serverCells=%d finalSelected=%s", SelectServersDialogTableCount(self.m_ArrayServerCells), tostring(selectedArea.lastSelectID)))
		self:DeselectOtherServerBtn()
		self.m_ServerListBack:setVisible(true)

    else
        SelectServersDialogDiag("RefreshServerCells no selectedArea; no server cells created")
	end
end

function SelectServersDialog:DeselectOtherServerBtn()
    SelectServersDialogDiag(string.format("DeselectOtherServerBtn selectArea=%s serverCells=%d", tostring(self.m_SelectArea), SelectServersDialogTableCount(self.m_ArrayServerCells)))
	if self.m_SelectArea and self.m_AreaServersMap and self.m_AreaServersMap[self.m_SelectArea] then
		local selectServerID = tonumber(self.m_AreaServersMap[self.m_SelectArea].lastSelectID)
		for _,v in pairs(self.m_ArrayServerCells) do
			v:SetSelectedState(selectServerID)
		end
	end
end

function SelectServersDialog:SelectCurrentAreaBtn()
    SelectServersDialogDiag(string.format("SelectCurrentAreaBtn selectArea=%s areaCells=%d", tostring(self.m_SelectArea), SelectServersDialogTableCount(self.m_Area)))
	if self.m_AreaServersMap[self.m_SelectArea] then
		local selectAreaID = tonumber(self.m_AreaServersMap[self.m_SelectArea].id)
		for k,v in pairs(self.m_Area) do
			v:SetSelectedState(selectAreaID)
		end
	end
end

function SelectServersDialog:CheckServersLoad()
	if self.m_AreaServersMap == nil then return end
	local selectedArea = self.m_AreaServersMap[self.m_SelectArea]
	if not selectedArea then
		for k,v in pairs(self.m_AreaServersMap) do
			if v.name == self.m_SelectArea then
				selectedArea = v
			end
		end
	end

	local timestamp = os.time() --second
	if selectedArea then
		for k,v in pairs(selectedArea.servers) do
			local key = tonumber(v.serverid)
			local serverLoad = _serverLoadStateMap[key]
             v.exist = GetServerInfo():getRoleHeadInfoByServerID(key)

			if not serverLoad or timestamp - serverLoad.timestamp >= CHECK_LOAD_DUR then
				gGetLoginManager():ClearConnectionByKey(key)

                local lowport = tonumber(v.port)
		        local highport = lowport + tonumber(v.standby) - 1
		        highport = math.max(lowport, highport)
		        local port = StringCover.randBetween(lowport, highport)
				local ip = v.ip

				gGetLoginManager():CheckLoad(ip, tostring(port), key)

				if not serverLoad then
					_serverLoadStateMap[key] = { serverLoad = 0 }
				end
				_serverLoadStateMap[key].timestamp = timestamp
			end

		end	
	end
end

function SelectServersDialog.SetServerLoad(serverKey, serverLoad)
	if _instance then
		if not _serverLoadStateMap[serverKey] then
			_serverLoadStateMap[serverKey] = {
				serverLoad = serverLoad,
				timestamp = os.time()
			}
		else
			_serverLoadStateMap[serverKey].serverLoad = serverLoad
		end

		if serverLoad == 1 or serverLoad == 2 or serverLoad == 3 then   --good 
			if _instance.m_ArrayServerCells then
				for k,v in pairs(_instance.m_ArrayServerCells) do
					if tonumber(v.serverid) == serverKey then
						v:setServerStatus(serverLoad)
					end
				end
			end
		elseif serverLoad == -1 then  --maintain
			if _instance.m_ArrayServerCells then
				for k,v in pairs(_instance.m_ArrayServerCells) do
					if tonumber(v.serverid) == serverKey then
						v:setServerStatus(serverLoad)
					end
				end
			end
		end

	elseif SelectServerEntry.getInstanceNotCreate() then --如果当前是快捷登录界面的逻辑
		SelectServerEntry.getInstance():SetServerLoad(serverKey, serverLoad)
	elseif require("logic.createroledialog"):getInstanceOrNot() then  --如果当前是人物创建界面的逻辑
		require("logic.createroledialog"):getInstanceOrNot():SetServerLoad(serverKey, serverLoad)
	end
end

----/////////////////////////////////////////------
--新界面初始化大区列表
function SelectServersDialog:InitAreaList()
	LogInfo("SelectServersDialog InitAreaList")
    SelectServersDialogDiag(string.format("InitAreaList begin areaMapCount=%d currentSelect=%s", SelectServersDialogTableCount(self.m_AreaServersMap), tostring(self.m_SelectArea)))
	local AreaServerSort = {}
	local indexArea = 0
	for k,v in pairs(self.m_AreaServersMap) do  
		indexArea = indexArea + 1
		AreaServerSort[indexArea] = {}
		AreaServerSort[indexArea].id = v.id
		AreaServerSort[indexArea].name = k
	end
    --对大区进行排序（标题）
	local sortFunc = function(a, b) return a.id < b.id end
	table.sort(AreaServerSort, sortFunc)

    for _, areaInfo in ipairs(AreaServerSort) do
        SelectServersDialogDiag(string.format("InitAreaList sorted area id=%s name=%s serverCount=%d", tostring(areaInfo.id), tostring(areaInfo.name), SelectServersDialogServerCount(self.m_AreaServersMap[areaInfo.name])))
    end
    self.m_SelectArea = self:GetDefaultSelectAreaName(AreaServerSort)
    if self.m_AreaServersMap[self.m_SelectArea] then
        self.m_SelectAreaID = tonumber(self.m_AreaServersMap[self.m_SelectArea].id)
    end
    SelectServersDialogDiag("InitAreaList selectedArea=" .. tostring(self.m_SelectArea))

	self.m_Area = {}
	local index = 0
	for k,v in ipairs(AreaServerSort)do-----登录选区
	    col = index%1
	    row = math.floor(index/1)
		index = index + 1
        SelectServersDialogDiag(string.format("InitAreaList create areaCell index=%d id=%s name=%s selected=%s serverCount=%d", index, tostring(v.id), tostring(v.name), tostring(self.m_SelectArea), SelectServersDialogServerCount(self.m_AreaServersMap[v.name])))
		self.m_Area[index] =  SelectServersAreaCell.CreateNewDlg(self.m_AreaListBack) --上面大区cell
		local mainFrame = self.m_Area[index]:GetWindow()
		local woffset = col*(mainFrame:getPixelSize().width - 15)
		local hoffset = row*(mainFrame:getPixelSize().height+1)
		mainFrame:setPosition(CEGUI.UVector2(CEGUI.UDim(0.0, woffset), CEGUI.UDim(0.0, hoffset)))
		self.m_Area[index]:SetCellInfo(v.id, v.name, self.m_SelectArea)
		self.m_Area[index].name = v.name
		self.m_Area[index].id = v.id
	end

    SelectServersDialogDiag(string.format("InitAreaList end createdAreaCells=%d selected=%s", SelectServersDialogTableCount(self.m_Area), tostring(self.m_SelectArea)))
	self.m_AreaListBack:setVisible(true)
end

return SelectServersDialog
