require "logic.dialog"

ShengSiZhanTeamPanel = {}
setmetatable(ShengSiZhanTeamPanel, Dialog)
ShengSiZhanTeamPanel.__index = ShengSiZhanTeamPanel

local _instance
function ShengSiZhanTeamPanel.getInstance()
	if not _instance then
		_instance = ShengSiZhanTeamPanel:new()
		_instance:OnCreate()
	end
	return _instance
end

function ShengSiZhanTeamPanel.getInstanceAndShow()
	if not _instance then
		_instance = ShengSiZhanTeamPanel:new()
		_instance:OnCreate()
	else
		_instance:SetVisible(true)
	end
	return _instance
end

function ShengSiZhanTeamPanel.getInstanceNotCreate()
	return _instance
end

function ShengSiZhanTeamPanel.DestroyDialog()
	if _instance then 
		if not _instance.m_bCloseIsHide then
			_instance:OnClose()
			_instance = nil
		else
			_instance:ToggleOpenClose()
		end
	end
end

function ShengSiZhanTeamPanel.ToggleOpenClose()
	if not _instance then
		_instance = ShengSiZhanTeamPanel:new()
		_instance:OnCreate()
	else
		if _instance:IsVisible() then
			_instance:SetVisible(false)
		else
			_instance:SetVisible(true)
		end
	end
end

function ShengSiZhanTeamPanel.GetLayoutFileName()
	return "shengsizhanduizhan_mtg.layout"
end

function ShengSiZhanTeamPanel:new()
	local self = {}
	self = Dialog:new()
	setmetatable(self, ShengSiZhanTeamPanel)
	return self
end

function ShengSiZhanTeamPanel:OnCreate()
	Dialog.OnCreate(self)
	local winMgr = CEGUI.WindowManager:getSingleton()
    
    self.iconlist = {}

    for i=1,5 do
        local info = {}

        local sid = ""
        if i > 1 then
            sid = tostring(i-1)
        end
        info.headicon = CEGUI.Window.toItemCell(winMgr:getWindow("shengsizhanduizhan_mtg/dikuang/touxiang" .. sid)) 
        info.mingzi = CEGUI.Window.toItemCell(winMgr:getWindow("shengsizhanduizhan_mtg/dikuang/mingzi" .. sid)) 
        info.zhiye = CEGUI.Window.toItemCell(winMgr:getWindow("shengsizhanduizhan_mtg/dikuang/zhiye" .. sid)) 

        info.headicon:setVisible(false)
        info.mingzi:setVisible(false)
        info.zhiye:setVisible(false)

        table.insert(self.iconlist,info)
    end
end
function ShengSiZhanTeamPanel.SetTeamList(datalist)
    local dlg = ShengSiZhanTeamPanel.getInstanceAndShow();

    for i=1,#dlg.iconlist do
        if datalist[i] ~= nil then
            dlg.iconlist[i].mingzi:setText(datalist[i].rolename)
            local schoolinfo = BeanConfigManager.getInstance():GetTableByName("role.schoolinfo"):getRecorder(datalist[i].school)
            dlg.iconlist[i].zhiye:setText(schoolinfo.name)
            local shapeDataA = BeanConfigManager.getInstance():GetTableByName("npc.cnpcshape"):getRecorder(datalist[i].shape)
	        local imageA = gGetIconManager():GetImageByID(shapeDataA.littleheadID)
	        dlg.iconlist[i].headicon:SetImage(imageA)
            dlg.iconlist[i].headicon:SetTextUnitText(CEGUI.String(tostring(datalist[i].level)))

            dlg.iconlist[i].headicon:setVisible(true)
            dlg.iconlist[i].mingzi:setVisible(true)
            dlg.iconlist[i].zhiye:setVisible(true)
        else
            dlg.iconlist[i].headicon:setVisible(false)
            dlg.iconlist[i].mingzi:setVisible(false)
            dlg.iconlist[i].zhiye:setVisible(false)
        end
    end

end
return ShengSiZhanTeamPanel
