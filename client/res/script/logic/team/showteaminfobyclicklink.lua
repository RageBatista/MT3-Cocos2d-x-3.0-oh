-- 点击超链接打开的队伍信息界面

require "logic.dialog"

ShowTeamInfoByClickLink = {}
setmetatable(ShowTeamInfoByClickLink, Dialog)
ShowTeamInfoByClickLink.__index = ShowTeamInfoByClickLink

local _instance
function ShowTeamInfoByClickLink.getInstance()
	if not _instance then
		_instance = ShowTeamInfoByClickLink:new()
		_instance:OnCreate()
	end
	return _instance
end

function ShowTeamInfoByClickLink.getInstanceAndShow()
	if not _instance then
		_instance = ShowTeamInfoByClickLink:new()
		_instance:OnCreate()
	else
		_instance:SetVisible(true)
	end
	return _instance
end

function ShowTeamInfoByClickLink.getInstanceNotCreate()
	return _instance
end

function ShowTeamInfoByClickLink.DestroyDialog()
	if _instance then 
		if not _instance.m_bCloseIsHide then
			_instance:OnClose()
			_instance = nil
		else
			_instance:ToggleOpenClose()
		end
	end
end

function ShowTeamInfoByClickLink.ToggleOpenClose()
	if not _instance then
		_instance = ShowTeamInfoByClickLink:new()
		_instance:OnCreate()
	else
		if _instance:IsVisible() then
			_instance:SetVisible(false)
		else
			_instance:SetVisible(true)
		end
	end
end

function ShowTeamInfoByClickLink.GetLayoutFileName()
	return "duiwuxinxi.layout"
end

function ShowTeamInfoByClickLink:new()
	local self = {}
	self = Dialog:new()
	setmetatable(self, ShowTeamInfoByClickLink)
	return self
end

function ShowTeamInfoByClickLink:OnCreate()
	Dialog.OnCreate(self)
	local winMgr = CEGUI.WindowManager:getSingleton()

	self.m_touxiang_1 = CEGUI.toItemCell(winMgr:getWindow("duiwuwuxinxi_mtg/dikuang/touxiang"))
	self.m_name_1 = winMgr:getWindow("duiwuxinxi_mtg/dikuang/mingzi")
	self.m_zhiye_1 = winMgr:getWindow("duiwuxinxi_mtg/dikuang/zhiye")

	self.m_touxiang_2 = CEGUI.toItemCell(winMgr:getWindow("duiwuxinxi_mtg/dikuang/touxiang1"))
	self.m_name_2 = winMgr:getWindow("duiwuxinxi_mtg/dikuang/mingzi1")
	self.m_zhiye_2 = winMgr:getWindow("duiwuxinxi_mtg/dikuang/zhiye1")

	self.m_touxiang_3 = CEGUI.toItemCell(winMgr:getWindow("duiwuxinxi_mtg/dikuang/touxiang2"))
	self.m_name_3 = winMgr:getWindow("duiwuxinxi_mtg/dikuang/mingzi2")
	self.m_zhiye_3 = winMgr:getWindow("duiwuxinxi_mtg/dikuang/zhiye2")

	self.m_touxiang_4 = CEGUI.toItemCell(winMgr:getWindow("duiwuxinxi_mtg/dikuang/touxiang3"))
	self.m_name_4 = winMgr:getWindow("duiwuxinxi_mtg/dikuang/mingzi3")
	self.m_zhiye_4 = winMgr:getWindow("duiwuxinxi_mtg/dikuang/zhiye3")

	self.m_touxiang_5 = CEGUI.toItemCell(winMgr:getWindow("duiwuxinxi_mtg/dikuang/touxiang4"))
	self.m_name_5 = winMgr:getWindow("duiwuxinxi_mtg/dikuang/mingzi4")
	self.m_zhiye_5 = winMgr:getWindow("duiwuxinxi_mtg/dikuang/zhiye4")

    self.m_name_1:setVisible(false)
    self.m_zhiye_1:setVisible(false)

    self.m_name_2:setVisible(false)
    self.m_zhiye_2:setVisible(false)

    self.m_name_3:setVisible(false)
    self.m_zhiye_3:setVisible(false)

    self.m_name_4:setVisible(false)
    self.m_zhiye_4:setVisible(false)

    self.m_name_5:setVisible(false)
    self.m_zhiye_5:setVisible(false)

end

function ShowTeamInfoByClickLink:RefreshUI(memberlist)
    for i = 1, #memberlist do
        local member = memberlist[i]

        -- 头像
        local shapeData = BeanConfigManager.getInstance():GetTableByName("npc.cnpcshape"):getRecorder(member.shape)
	    local image = gGetIconManager():GetImageByID(shapeData.littleheadID)

        -- 等级
        local level = member.level

        -- 名称
        local name = member.rolename

        -- 职业
        local zhiye = BeanConfigManager.getInstance():GetTableByName("role.schoolinfo"):getRecorder(member.school).name

        if i == 1 then
            self.m_name_1:setVisible(true)
            self.m_zhiye_1:setVisible(true)

		    self.m_touxiang_1:SetImage(image)
            self.m_touxiang_1:SetTextUnit(level)
	        self.m_name_1:setText(name)
	        self.m_zhiye_1:setText(zhiye)
        elseif i == 2 then
            self.m_name_2:setVisible(true)
            self.m_zhiye_2:setVisible(true)

		    self.m_touxiang_2:SetImage(image)
            self.m_touxiang_2:SetTextUnit(level)
	        self.m_name_2:setText(name)
	        self.m_zhiye_2:setText(zhiye)
        elseif i == 3 then
            self.m_name_3:setVisible(true)
            self.m_zhiye_3:setVisible(true)

		    self.m_touxiang_3:SetImage(image)
            self.m_touxiang_3:SetTextUnit(level)
	        self.m_name_3:setText(name)
	        self.m_zhiye_3:setText(zhiye)
        elseif i == 4 then
            self.m_name_4:setVisible(true)
            self.m_zhiye_4:setVisible(true)

		    self.m_touxiang_4:SetImage(image)
            self.m_touxiang_4:SetTextUnit(level)
	        self.m_name_4:setText(name)
	        self.m_zhiye_4:setText(zhiye)
        elseif i == 5 then
            self.m_name_5:setVisible(true)
            self.m_zhiye_5:setVisible(true)

		    self.m_touxiang_5:SetImage(image)
            self.m_touxiang_5:SetTextUnit(level)
	        self.m_name_5:setText(name)
	        self.m_zhiye_5:setText(zhiye)
        end

    end
end

return ShowTeamInfoByClickLink