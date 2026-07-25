RecruitMineCell = {}

setmetatable(RecruitMineCell, Dialog)
RecruitMineCell.__index = RecruitMineCell
local prefix = 0

function RecruitMineCell.CreateNewDlg(parent)
	local newDlg = RecruitMineCell:new()
	newDlg:OnCreate(parent)
	return newDlg
end

function RecruitMineCell.GetLayoutFileName()
	return "recruitminecell.layout"
end

function RecruitMineCell:new()
	local self = {}
	self = Dialog:new()
	setmetatable(self, RecruitMineCell)
	return self
end

function RecruitMineCell:OnCreate(parent)
	prefix = prefix + 1
	Dialog.OnCreate(self, parent, prefix)

	local winMgr = CEGUI.WindowManager:getSingleton()
	local prefixstr = tostring(prefix)

    self.window = winMgr:getWindow(prefixstr.."recruitminecell")

    self.m_itemWnd = {}
    self.m_itemWnd[1] = CEGUI.Window.toItemCell(winMgr:getWindow(prefixstr.."recruitminecell/jiangli1"))
    self.m_itemWnd[2] = CEGUI.Window.toItemCell(winMgr:getWindow(prefixstr.."recruitminecell/jiangli12"))
    self.m_itemWnd[3] = CEGUI.Window.toItemCell(winMgr:getWindow(prefixstr.."recruitminecell/jiangli13"))

    for i = 1, 3 do 
        self.m_itemWnd[i]:subscribeEvent("MouseClick", RecruitMineCell.HandleItemClicked, self)
    end
    self.m_getBtn = CEGUI.toPushButton(winMgr:getWindow(prefixstr.."recruitminecell/lingqu"))
    self.m_getBtn:subscribeEvent("MouseClick", RecruitMineCell.HandleGetClicked, self)
    self.m_text = winMgr:getWindow(prefixstr.."recruitminecell/text")
    self.m_id = 1
    self.m_Data = nil
end
function RecruitMineCell:HandleGetClicked(e)
    local p = require("protodef.fire.pb.friends.cgetrecruitaward"):new()
    p.awardtype = 3
    p.awardid = self.m_id
    p.recruitrole = self.m_Data.roleid
    p.recruitserver = self.m_Data.serverid
    LuaProtocolManager:send(p)    
end
function RecruitMineCell:HandleItemClicked(args)
	local e = CEGUI.toMouseEventArgs(args)
	local touchPos = e.position
	local nPosX = touchPos.x
	local nPosY = touchPos.y
	
	local index = e.window:getID()
	
	local Commontipdlg = require "logic.tips.commontipdlg"
	local commontipdlg = Commontipdlg.getInstanceAndShow()
	local nType = Commontipdlg.eNormal
	local nItemId = index
	
	commontipdlg:RefreshItem(nType,nItemId,nPosX,nPosY)
	
	
end
function RecruitMineCell:setData(id, data)
    self.m_Data = data
    self.m_id = id
    local record = BeanConfigManager.getInstance():GetTableByName("friends.cmyrecruit"):getRecorder(id)
    local items = StringBuilder.Split(record.items, ";")
    for i,v in pairs(items) do
        local itemAttrCfg = BeanConfigManager.getInstance():GetTableByName("item.citemattr"):getRecorder(tonumber(v))
        if itemAttrCfg then
            local iconManager = gGetIconManager()
            self.m_itemWnd[i]:SetImage(iconManager:GetItemIconByID(itemAttrCfg.icon))
            self.m_itemWnd[i]:setID(tonumber(v))
            SetItemCellBoundColorByQulityItemWithId(self.m_itemWnd[i], tonumber(v))
        end
    end
    self.m_text:setText(record.text)
    if tonumber(self.m_Data.level) >= record.level then
        self.m_getBtn:setText(MHSD_UTILS.get_resstring(2939))
        self.m_getBtn:setEnabled(true)   
        local list = std.vector_int_()
        list = GetServerInfo():getRecruitOneRole()
        local vSize = list:size()
        for i = 0, vSize - 1 do
            if tonumber(list[i].amount) == record.level then
                self.m_getBtn:setText(MHSD_UTILS.get_resstring(2940))
                self.m_getBtn:setEnabled(false)
                break
            end
        end
    else
        self.m_getBtn:setText(MHSD_UTILS.get_resstring(2939))
        self.m_getBtn:setEnabled(false) 
    end
end
return recruit