RecruitJiangliCell = {}

setmetatable(RecruitJiangliCell, Dialog)
RecruitJiangliCell.__index = RecruitJiangliCell
local prefix = 0

function RecruitJiangliCell.CreateNewDlg(parent)
	local newDlg = RecruitJiangliCell:new()
	newDlg:OnCreate(parent)
	return newDlg
end

function RecruitJiangliCell.GetLayoutFileName()
	return "recruitjianglicell.layout"
end

function RecruitJiangliCell:new()
	local self = {}
	self = Dialog:new()
	setmetatable(self, RecruitJiangliCell)
	return self
end

function RecruitJiangliCell:OnCreate(parent)
	prefix = prefix + 1
	Dialog.OnCreate(self, parent, prefix)

	local winMgr = CEGUI.WindowManager:getSingleton()
	local prefixstr = tostring(prefix)

    self.window = winMgr:getWindow(prefixstr.."recruitjianglicell")

    self.m_itemWnd = {}
    self.m_itemWnd[1] = CEGUI.Window.toItemCell(winMgr:getWindow(prefixstr.."recruitjianglicell/jiangli1"))
    self.m_itemWnd[2] = CEGUI.Window.toItemCell(winMgr:getWindow(prefixstr.."recruitjianglicell/jiangli12"))
    self.m_itemWnd[3] = CEGUI.Window.toItemCell(winMgr:getWindow(prefixstr.."recruitjianglicell/jiangli13"))

    for i = 1, 3 do 
        self.m_itemWnd[i]:subscribeEvent("MouseClick", RecruitJiangliCell.HandleItemClicked, self)
    end


    self.m_getBtn = CEGUI.toPushButton(winMgr:getWindow(prefixstr.."recruitjianglicell/lingqu"))
    self.m_getBtn:subscribeEvent("MouseClick", RecruitJiangliCell.HandleGetClicked, self)
    self.m_text = winMgr:getWindow(prefixstr.."recruitjianglicell/text")

    self.m_id = 0

    self.m_num = 0

    self.m_items = ""

end
function RecruitJiangliCell:HandleGetClicked(e)
    local p = require("protodef.fire.pb.friends.cgetrecruitaward"):new()
    p.awardtype = 1
    p.awardid = self.m_id
    p.recruitrole = 0
    p.recruitserver = 0
    LuaProtocolManager:send(p)
end
function RecruitJiangliCell:HandleItemClicked(args)
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
function RecruitJiangliCell:setData(id)
    self.m_id = id
    local record = BeanConfigManager.getInstance():GetTableByName("friends.crecruitreward"):getRecorder(id)
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
    if record.friendnum <= self.m_num then
        self.m_getBtn:setText(MHSD_UTILS.get_resstring(2939))
        self.m_getBtn:setEnabled(true)
        local strTable = StringBuilder.Split(self.m_items, ",")
        for _ ,v in pairs(strTable) do
            if tonumber(v) == record.friendnum then
                self.m_getBtn:setText(MHSD_UTILS.get_resstring(2940))
                self.m_getBtn:setEnabled(false)
                break
            end
        end
    else
        self.m_getBtn:setEnabled(false)
    end
end
return RecruitJiangliCell