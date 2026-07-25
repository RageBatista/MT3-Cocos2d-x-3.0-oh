require"logic.recruit.recruitminecell"
RecruitMine = {}

setmetatable(RecruitMine, Dialog)
RecruitMine.__index = RecruitMine
local prefix = 0

function RecruitMine.CreateNewDlg(parent)
	local newDlg = RecruitMine:new()
	newDlg:OnCreate(parent)
	return newDlg
end

function RecruitMine.GetLayoutFileName()
	return "recruitmine.layout"
end

function RecruitMine:new()
	local self = {}
	self = Dialog:new()
	setmetatable(self, RecruitMine)
	return self
end

function RecruitMine:OnCreate(parent)
	Dialog.OnCreate(self, parent)

	local winMgr = CEGUI.WindowManager:getSingleton()

    self.m_list = winMgr:getWindow("recruitmine/list")
    self.m_winEffect = winMgr:getWindow("recruitmine/qingqiuzhong")
    self.m_getFail = winMgr:getWindow("recruitmine/qingqiushibai")
    self.m_getFailOneRole = winMgr:getWindow("recruitmine/qingqiushibai1")
    self.m_void = winMgr:getWindow("recruitmine/kong")
    self.m_void:setVisible(false)
    gGetGameUIManager():AddUIEffect(self.m_winEffect,  MHSD_UTILS.get_effectpath(11081), true)
    self.m_list:setVisible(false)
    self.m_winEffect:setVisible(true)
    self.m_getFail:setVisible(false)
    self.m_btnTry = CEGUI.toPushButton(winMgr:getWindow("recruitmine/qingqiushibai/btn"))
    self.m_btnTry:subscribeEvent("MouseClick", RecruitMine.HandleTryClick, self)
    self.m_btnTryOneRole = CEGUI.toPushButton(winMgr:getWindow("recruitmine/qingqiushibai/btn1"))
    self.m_btnTryOneRole:subscribeEvent("MouseClick", RecruitMine.HandleTryOneRoleClick, self)
    self.m_Data = nil
    self.m_school = winMgr:getWindow("recruitmine/zhiye")
    self.m_level = winMgr:getWindow("recruitmine/level")
    self.m_servername = winMgr:getWindow("recruitmine/zhiye2")
    self.m_addfriend = CEGUI.toPushButton(winMgr:getWindow("recruitmine/add"))
    self.m_addfriend:subscribeEvent("MouseClick", RecruitMine.HandleAddFriendClick, self)

    self.m_RoleList = winMgr:getWindow("recruitmine/bg")
end
function RecruitMine:HandleAddFriendClick(e)
    if tonumber(self.m_Data.serverid) == gGetLoginManager():getServerID() then
        gGetFriendsManager():RequestAddFriend(tonumber(self.m_Data.roleid))
        self.m_addfriend:setVisible(false)
    else
        GetCTipsManager():AddMessageTipById(170040)
    end

end
function RecruitMine:setData(data)
    self.m_Data = data
    if data.avatar then
        local school = BeanConfigManager.getInstance():GetTableByName("role.schoolinfo"):getRecorder(tonumber(data.avatar))
        if school then
            self.m_school:setText(school.name)
        end
    end
    if data.level then
        self.m_level:setText(tostring(data.level))
    end
    if data.servername then
        self.m_servername:setText(data.servername)
    end
    if data.roleid then
        if gGetFriendsManager():isMyFriend(tonumber(data.roleid)) then
            self.m_addfriend:setVisible(false)
        else
            self.m_addfriend:setVisible(true)
        end
    end
    self:getOneRoleData()
end
function RecruitMine:getOneRoleData()
    local record = BeanConfigManager.getInstance():GetTableByName("friends.crecruitpath"):getRecorder(1)
    local strbuilder = StringBuilder:new()
    
    strbuilder:Set("parameter1", gGetLoginManager():getServerID())
    strbuilder:Set("parameter2", gGetDataManager():GetMainCharacterID())
    strbuilder:Set("parameter3", self.m_Data.serverid)
    strbuilder:Set("parameter4", self.m_Data.roleid)
    local content = strbuilder:GetString(record.path8)
    strbuilder:delete()
    GetServerInfo():connetGetRecruitInfo(content,4)
end
function RecruitMine:getData()
    self.m_RoleList:setVisible(false)
    self.m_winEffect:setVisible(true)
    self.m_getFail:setVisible(false)
    self.m_getFailOneRole:setVisible(false)  
    self:getOneRoleData() 
end
function RecruitMine:HandleTryClick(e)
    self.m_list:setVisible(false)
    self.m_winEffect:setVisible(true)
    self.m_getFail:setVisible(false)
    self.m_getFailOneRole:setVisible(false) 
    self.m_void:setVisible(false)

    self:getRecruitList()
end
function RecruitMine:HandleTryOneRoleClick(e)
    self.m_RoleList:setVisible(false)
    self.m_winEffect:setVisible(true)
    self.m_getFail:setVisible(false)
    self.m_getFailOneRole:setVisible(false)  

    self:getOneRoleData() 
end
function RecruitMine:getRecruitList()
    local record = BeanConfigManager.getInstance():GetTableByName("friends.crecruitpath"):getRecorder(1)
    local strbuilder = StringBuilder:new()
    
    strbuilder:Set("parameter1", gGetLoginManager():getServerID())
    strbuilder:Set("parameter2", gGetDataManager():GetMainCharacterID())
    if IsPointCardServer() then
        strbuilder:Set("parameter3", BeanConfigManager.getInstance():GetTableByName("fushi.ccommondaypay"):getRecorder(13).value)
    else
        strbuilder:Set("parameter3", GameTable.common.GetCCommonTableInstance():getRecorder(424).value)
    end
    
    local content = strbuilder:GetString(record.path6)
    strbuilder:delete()
    GetServerInfo():connetGetRecruitInfo(content,3)
end
function RecruitMine:getRecruitSuccess()
    self.m_winEffect:setVisible(false)
    self.m_list:setVisible(true)
    self.m_getFail:setVisible(false)
    self.m_getFailOneRole:setVisible(false) 
    self.m_void:setVisible(false)
end
function RecruitMine:getRecruitSuccessVoid()
    self.m_void:setVisible(true)
    self.m_winEffect:setVisible(false)
    self.m_list:setVisible(false)
    self.m_getFail:setVisible(false)
    self.m_getFailOneRole:setVisible(false) 
end
function RecruitMine:getRecruitFail()
    self.m_winEffect:setVisible(false)
    self.m_list:setVisible(false)
    self.m_getFail:setVisible(true)
    self.m_getFailOneRole:setVisible(false)   
    self.m_void:setVisible(false)
end

function RecruitMine:getOneRoleSuccess()
    self.m_RoleList:setVisible(true)
    self.m_winEffect:setVisible(false)
    self.m_getFail:setVisible(false)
    self.m_getFailOneRole:setVisible(false) 
    self:InitCell()
end
function RecruitMine:getOneRoleFail()
    self.m_RoleList:setVisible(false)
    self.m_winEffect:setVisible(false)
    self.m_getFail:setVisible(false)
    self.m_getFailOneRole:setVisible(true)  
end
function RecruitMine:InitCell()
    
    self.m_RoleList:setVisible(true)
    local count = 0
    local tableAllId = BeanConfigManager.getInstance():GetTableByName("friends.cmyrecruit"):getAllID()
    for _, v in pairs(tableAllId) do
		local record = BeanConfigManager.getInstance():GetTableByName("friends.cmyrecruit"):getRecorder(v)
        count = count + 1
    end
    if not self.m_TableView then
        local s = self.m_RoleList:getPixelSize()
	    self.m_TableView = TableView.create(self.m_RoleList)
	    self.m_TableView:setViewSize(s.width-20, s.height-20)
	    self.m_TableView:setPosition(5, 5)
	    self.m_TableView:setColumCount(1)
        self.m_TableView:setDataSourceFunc(self, RecruitMine.tableViewGetCellAtIndex)
        self.m_TableView:setCellCountAndSize(count, 555, 145)
	    self.m_TableView:reloadData()
    else
        self.m_TableView:reloadData()
    end 

end
function RecruitMine:tableViewGetCellAtIndex(tableView, idx, cell)
	if not cell then
		cell = RecruitMineCell.CreateNewDlg(tableView.container)
	end
	cell.window:setID(idx)
    cell:setData(idx + 1, self.m_Data)
	return cell
end
return RecruitMine