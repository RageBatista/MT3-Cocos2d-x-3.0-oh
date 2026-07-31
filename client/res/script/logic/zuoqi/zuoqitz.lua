require "logic.dialog"

ZuoQiTz = {}
setmetatable(ZuoQiTz, Dialog)
ZuoQiTz.__index = ZuoQiTz

local _instance
function ZuoQiTz.getInstance()
    if not _instance then
        _instance = ZuoQiTz:new()
        _instance:OnCreate()
    end
    return _instance
end

function ZuoQiTz.getInstanceAndShow()
    if not _instance then
        _instance = ZuoQiTz:new()
        _instance:OnCreate()
    else
        _instance:SetVisible(true)
    end
    return _instance
end

function ZuoQiTz.getInstanceNotCreate()
    return _instance
end

function ZuoQiTz.DestroyDialog()
    if _instance then
        if not _instance.m_bCloseIsHide then
            _instance:OnClose()
            _instance = nil
        else
            _instance:ToggleOpenClose()
        end
    end
end

function ZuoQiTz.ToggleOpenClose()
    if not _instance then
        _instance = ZuoQiTz:new()
        _instance:OnCreate()
    else
        if _instance:IsVisible() then
            _instance:SetVisible(false)
        else
            _instance:SetVisible(true)
        end
    end
end

function ZuoQiTz.GetLayoutFileName()
    return "zuoqitz.layout"
end

function ZuoQiTz:new()
    local self = {}
    self = Dialog:new()
    setmetatable(self, ZuoQiTz)
    return self
end

function ZuoQiTz:OnCreate()
    Dialog.OnCreate(self)
    local winMgr = CEGUI.WindowManager:getSingleton()
    --SetPositionOfWindowWithLabel(self:GetWindow())

    self.pane = CEGUI.toScrollablePane(winMgr:getWindow("zuoqitz/scrolllabelpane"));
    self.pane:EnableHorzScrollBar(false)

    self.name = winMgr:getWindow("zuoqitz/1231/name")
    self.tu1 = winMgr:getWindow("zuoqitz/1231/tu1")
    self.tu2 = winMgr:getWindow("zuoqitz/1231/tu2")
    self.tu3 = winMgr:getWindow("zuoqitz/1231/tu3")
    self.editbox = CEGUI.toRichEditbox(winMgr:getWindow("zuoqitz/1231/box"))

    self.editbox:Clear()
    local zuoqitzs = BeanConfigManager.getInstance():GetTableByName("item.cwenshitaozhuang"):getAllID()
    local sx = 2.0;
    local sy = 2.0;
    local indes=0.1
    for k,v in pairs(zuoqitzs) do
        local zuoqitz = BeanConfigManager.getInstance():GetTableByName("item.cwenshitaozhuang"):getRecorder(v)
        local sID = "zuoqitzcell" .. tostring(indes)
        local lyout = winMgr:loadWindowLayout("zuoqitzcell.layout",sID);
        self.pane:addChildWindow(lyout)
        lyout:setPosition(CEGUI.UVector2(CEGUI.UDim(0.0, sx), CEGUI.UDim(0.0, sy + indes * (lyout:getHeight().offset))))
        --lyout:setID(index)
        --lyout.key = petData.key
        local skillxx = BeanConfigManager.getInstance():GetTableByName("skill.cpetskillconfig"):getRecorder(zuoqitz.jinengid)
        lyout.addclick =  CEGUI.toGroupButton(winMgr:getWindow(sID.."zuoqitzcell"));
        lyout.addclick:setID(v)
        lyout.addclick:subscribeEvent("MouseButtonUp", ZuoQiTz.handleIconSelected, self)

        lyout.NameText = winMgr:getWindow(sID.."zuoqitzcell/name")
        lyout.NameText:setText(skillxx.skillname)

        lyout.skillCell = CEGUI.toItemCell(winMgr:getWindow(sID.."zuoqitzcell/touxiang"))
        lyout.skillCell:SetImage(gGetIconManager():GetItemIconByID(skillxx.icon))
		lyout.skillCell:SetCornerImageAtPos("my_zuoqi", "kuang", 0.85, 0.85,-1,-1.5) --数值型 参数一   二:大小  三: x值  四: y值

		

        local wenshis = BeanConfigManager.getInstance():GetTableByName("item.cwenshiitemshuxing"):getAllID()
        for key,value in pairs(wenshis) do
            local wenshi = BeanConfigManager.getInstance():GetTableByName("item.cwenshiitemshuxing"):getRecorder(value)

			
            if wenshi.wenshitype==zuoqitz.zuhes[0] then

                lyout.Tu1 = winMgr:getWindow(sID.."zuoqitzcell/tu1")
                lyout.Tu1:setProperty("Image",  gGetIconManager():GetImagePathByID(wenshi.icon):c_str())
            end
            if wenshi.wenshitype==zuoqitz.zuhes[1] then
                lyout.Tu2 = winMgr:getWindow(sID.."zuoqitzcell/tu2")
                lyout.Tu2:setProperty("Image",  gGetIconManager():GetImagePathByID(wenshi.icon):c_str())
            end
            if wenshi.wenshitype==zuoqitz.zuhes[2] then
                lyout.Tu3 = winMgr:getWindow(sID.."zuoqitzcell/tu3")
                lyout.Tu3:setProperty("Image",  gGetIconManager():GetImagePathByID(wenshi.icon):c_str())
            end
        end

    --    iconPath = gGetIconManager():GetImagePathByID(BeanConfigManager.getInstance():GetTableByName("npc.cnpcshape"):getRecorder(gGetDataManager():GetMainCharacterShape()).headID)
    --
    --
    --self.m_pNpcIcon:setProperty("Image", iconPath:c_str())



        indes = indes + 1
    end
    local zuoqitz = BeanConfigManager.getInstance():GetTableByName("item.cwenshitaozhuang"):getRecorder(1)
    local skillxx = BeanConfigManager.getInstance():GetTableByName("skill.cpetskillconfig"):getRecorder(zuoqitz.jinengid)
    self.name:setText(skillxx.skillname)
    local wenshis = BeanConfigManager.getInstance():GetTableByName("item.cwenshiitemshuxing"):getAllID()
    for key,value in pairs(wenshis) do
        local wenshi = BeanConfigManager.getInstance():GetTableByName("item.cwenshiitemshuxing"):getRecorder(value)
        if wenshi.wenshitype==zuoqitz.zuhes[0] then


            self.tu1:setProperty("Image",  gGetIconManager():GetImagePathByID(wenshi.icon):c_str())
        end
        if wenshi.wenshitype==zuoqitz.zuhes[1] then

            self.tu2:setProperty("Image",  gGetIconManager():GetImagePathByID(wenshi.icon):c_str())
        end
        if wenshi.wenshitype==zuoqitz.zuhes[2] then

            self.tu3:setProperty("Image",  gGetIconManager():GetImagePathByID(wenshi.icon):c_str())
        end
    end
    self.editbox:Clear()
    --self.editbox:AppendParseText(CEGUI.String(skillxx.skilldescribe))
	
	local xml = skillxx.skilldescribe
	local start_pos = string.find(xml, 't="')
	local t_content = ""
	
	if start_pos then
		local end_pos = string.find(xml, '"', start_pos + 3)
		if end_pos then
			t_content = string.sub(xml, start_pos + 3, end_pos - 1)
		end
	end
	self.editbox:AppendText(CEGUI.String(t_content), CEGUI.ColourRect(CEGUI.PropertyHelper:stringToColour("FF815636")))

	
	
    self.editbox:Refresh()
	
	--关闭按钮
	self.close = winMgr:getWindow("zuoqitz/biaoti/x")
	self.close:subscribeEvent("Clicked", self.DestroyDialog, nil)

end
function ZuoQiTz:handleIconSelected(args)
    local wnd = CEGUI.toWindowEventArgs(args).window
    local cell = CEGUI.toItemCell(wnd)
    --local idx = cell:GetIndex()
    local idx = wnd:getID()
    local zuoqitz = BeanConfigManager.getInstance():GetTableByName("item.cwenshitaozhuang"):getRecorder(idx)
    local skillxx = BeanConfigManager.getInstance():GetTableByName("skill.cpetskillconfig"):getRecorder(zuoqitz.jinengid)
    self.name:setText(skillxx.skillname)
    local wenshis = BeanConfigManager.getInstance():GetTableByName("item.cwenshiitemshuxing"):getAllID()
    for key,value in pairs(wenshis) do
        local wenshi = BeanConfigManager.getInstance():GetTableByName("item.cwenshiitemshuxing"):getRecorder(value)
        if wenshi.wenshitype==zuoqitz.zuhes[0] then


            self.tu1:setProperty("Image",  gGetIconManager():GetImagePathByID(wenshi.icon):c_str())
        end
        if wenshi.wenshitype==zuoqitz.zuhes[1] then

            self.tu2:setProperty("Image",  gGetIconManager():GetImagePathByID(wenshi.icon):c_str())
        end
        if wenshi.wenshitype==zuoqitz.zuhes[2] then

            self.tu3:setProperty("Image",  gGetIconManager():GetImagePathByID(wenshi.icon):c_str())
        end
    end
    self.editbox:Clear()
    --self.editbox:AppendParseText(CEGUI.String(skillxx.skilldescribe))
	
	
	local xml = skillxx.skilldescribe
	local start_pos = string.find(xml, 't="')
	local t_content = ""
	
	if start_pos then
		local end_pos = string.find(xml, '"', start_pos + 3)
		if end_pos then
			t_content = string.sub(xml, start_pos + 3, end_pos - 1)
		end
	end
	self.editbox:AppendText(CEGUI.String(t_content), CEGUI.ColourRect(CEGUI.PropertyHelper:stringToColour("FF815636")))
    --self.editbox:AppendText(CEGUI.String(skillxx.describe),CEGUI.ColourRect(CEGUI.PropertyHelper:stringToColour("ff6b4b29")))


    self.editbox:Refresh()
end
return ZuoQiTz
