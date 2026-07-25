require"logic.recruit.recruitjianglicell"

RecruitJiangLi = {}

setmetatable(RecruitJiangLi, Dialog)
RecruitJiangLi.__index = RecruitJiangLi

function RecruitJiangLi.CreateNewDlg(parent)
	local newDlg = RecruitJiangLi:new()
	newDlg:OnCreate(parent)
	return newDlg
end

function RecruitJiangLi.GetLayoutFileName()
	return "recruitjiangli.layout"
end

function RecruitJiangLi:new()
	local self = {}
	self = Dialog:new()
	setmetatable(self, RecruitJiangLi)
	return self
end

function RecruitJiangLi:OnCreate(parent)
	Dialog.OnCreate(self, parent)
	local winMgr = CEGUI.WindowManager:getSingleton()
    self.m_bg = winMgr:getWindow("recruitjiangli/bg")
    self.m_num = 0
    self.m_items = ""
    self.effectWnd = winMgr:getWindow("recruitjiangli/qingqiuzhong")
    gGetGameUIManager():AddUIEffect(self.effectWnd,  MHSD_UTILS.get_effectpath(11081), true)
    self.m_bg:setVisible(false)
    self.effectWnd:setVisible(true)
    self.m_btnBg =winMgr:getWindow("recruitjiangli/qingqiushibai")
    self.m_btnBg:setVisible(false)
    self.m_btnTry = CEGUI.toPushButton(winMgr:getWindow("recruitjiangli/qingqiushibai/btn"))
    self.m_btnTry:subscribeEvent("MouseClick", RecruitJiangLi.HandleTryClick, self)
    
    self:getRecruitData()
    --self:InitCell()
end
function RecruitJiangLi:HandleTryClick(e)
    self.effectWnd:setVisible(true)
    self.m_btnBg:setVisible(false)
    self.m_bg:setVisible(false)
    self:getRecruitData()
end
function RecruitJiangLi:getData()
    self.effectWnd:setVisible(true)
    self.m_btnBg:setVisible(false)
    self.m_bg:setVisible(false)
    self:getRecruitData()
end
function RecruitJiangLi:getRecruitData()
    local record = BeanConfigManager.getInstance():GetTableByName("friends.crecruitpath"):getRecorder(1)
    local strbuilder = StringBuilder:new()
    
    strbuilder:Set("parameter1", gGetLoginManager():getServerID())
    strbuilder:Set("parameter2", gGetDataManager():GetMainCharacterID())
    strbuilder:Set("parameter3", GameTable.common.GetCCommonTableInstance():getRecorder(423).value)
    
    local content = strbuilder:GetString(record.path10)
    strbuilder:delete()
    GetServerInfo():connetGetRecruitInfo(content,5)
end
function RecruitJiangLi:getRecruitSuccess()
    self.effectWnd:setVisible(false)
    self.m_bg:setVisible(true)
    self.m_btnBg:setVisible(false)
    local data = GetServerInfo():getRecruitData()
    self.m_num = data.total
    self.m_items = data.times_item
    self:InitCell()
end
function RecruitJiangLi:getRecruitFail()
    self.effectWnd:setVisible(false)
    self.m_bg:setVisible(false)
    self.m_btnBg:setVisible(true)    
end
function RecruitJiangLi:setData()

end
function RecruitJiangLi:InitCell()
    
    self.m_bg:setVisible(true)
    local count = 0
    local tableAllId = BeanConfigManager.getInstance():GetTableByName("friends.crecruitreward"):getAllID()
    for _, v in pairs(tableAllId) do
		local record = BeanConfigManager.getInstance():GetTableByName("friends.crecruitreward"):getRecorder(v)
        count = count + 1
    end

    local s = self.m_bg:getPixelSize()
    if not self.m_TableView then
	    self.m_TableView = TableView.create(self.m_bg)
	    self.m_TableView:setViewSize(s.width-20, s.height-20)
	    self.m_TableView:setPosition(5, 5)
	    self.m_TableView:setColumCount(1)
        self.m_TableView:setDataSourceFunc(self, RecruitJiangLi.tableViewGetCellAtIndex)
        self.m_TableView:setCellCountAndSize(count, 600, 127)
	    self.m_TableView:reloadData()
    else
        self.m_TableView:reloadData()
    end

end

function RecruitJiangLi:tableViewGetCellAtIndex(tableView, idx, cell)
	if not cell then
		cell = RecruitJiangliCell.CreateNewDlg(tableView.container)
	end
	cell.window:setID(idx)
    cell.m_num = self.m_num
    cell.m_items = self.m_items   
    cell:setData(idx + 1)
	return cell
end
return RecruitJiangLi