RecruitCell1DiankaDg = {}

setmetatable(RecruitCell1DiankaDg, Dialog)
RecruitCell1DiankaDg.__index = RecruitCell1DiankaDg

function RecruitCell1DiankaDg.CreateNewDlg(parent)
	local newDlg = RecruitCell1DiankaDg:new()
	newDlg:OnCreate(parent)
	return newDlg
end

function RecruitCell1DiankaDg.GetLayoutFileName()
	return "recruitcell1diankadlg.layout"
end

function RecruitCell1DiankaDg:new()
	local self = {}
	self = Dialog:new()
	setmetatable(self, RecruitCell1DiankaDg)
	return self
end

function RecruitCell1DiankaDg:OnCreate(parent)
	Dialog.OnCreate(self, parent)
	local winMgr = CEGUI.WindowManager:getSingleton()
    self.m_roleidText = winMgr:getWindow("recruitcell1diankadlg/wendizi2/")
    self.m_richNomalText = winMgr:getWindow("recruitcell1diankadlg/richedit/text11")
    self.m_richText = CEGUI.toRichEditbox(winMgr:getWindow("recruitcell1diankadlg/richedit1"))
    self.m_richText:subscribeEvent("CaratMoved", RecruitCell1DiankaDg.HandleTextChange, self)
    self.m_richText:subscribeEvent("KeyboardTargetWndChanged", RecruitCell1Dg.HandleKeyboardTargetWndChanged, self)
    self.m_richText:setMaxTextLength(50)
    self.m_tipBtn = CEGUI.toPushButton(winMgr:getWindow("recruitcell1diankadlg/"))
    self.m_tipBtn:subscribeEvent("MouseClick", RecruitCell1DiankaDg.HandleTipClick, self)
    self.m_shareBtn = CEGUI.toPushButton(winMgr:getWindow("recruitcell1diankadlg/share"))
    self.m_shareBtn:subscribeEvent("MouseClick", RecruitCell1DiankaDg.HandleShareClick, self)
    -- windows 版本屏蔽分享
    if DeviceInfo:sGetDeviceType()==4 then --WIN7_32
        self.m_shareBtn:setVisible(false)
    end
    self.m_richText:SetColourRect(CEGUI.PropertyHelper:stringToColour(self.m_richText:getProperty("NormalTextColour")))
    self:setRoleId()
end
function RecruitCell1DiankaDg:HandleShareClick()
    if gGetDataManager():GetMainCharacterLevel() >= tonumber(GameTable.common.GetCCommonTableInstance():getRecorder(427).value) then
        require "logic.share.sharedlg".SetShareFunc(3)
        local dlg = require "logic.share.sharedlg".getInstanceAndShow()
        if self.m_richText:GetPureText() == "" then
            dlg:SetRecruitData(self.m_roleidText:getText(),MHSD_UTILS.get_resstring(11652))
        else
            dlg:SetRecruitData(self.m_roleidText:getText(),self.m_richText:GetPureText())
        end
        
    else
        GetCTipsManager():AddMessageTipById(170052)
    end

end
function RecruitCell1DiankaDg:setRoleId()
    local strServerid = gGetLoginManager():getServerID()
    local length = string.len(strServerid)
    local strLastFour = string.sub(strServerid,length-3,length)
    self.m_roleidText:setText(tostring(gGetDataManager():GetMainCharacterID()) .. strLastFour)
end
function RecruitCell1DiankaDg:HandleTipClick(e)
    local tips1 = require "logic.workshop.tips1"
    local tips_instance = tips1.getInstanceAndShow(MHSD_UTILS.get_resstring(11636), MHSD_UTILS.get_resstring(11635))
end
function RecruitCell1DiankaDg:HandleTextChange(e)
    local str = self.m_richText:GetPureText()
    local ret,strNew = RecruitCell1Dg.ShiedText(str)
    if ret then
        str = strNew
        self.m_richText:Clear()
        self.m_richText:AppendText(CEGUI.String(str))
        
        self.m_richText:Refresh()
        self.m_richText:SetCaratEnd()
    end
    local splited = false
    str, splited = SliptStrByCharCount(str, 50)
    if splited then
        self.m_richText:Clear()
        self.m_richText:AppendText(CEGUI.String(str))
        
        self.m_richText:Refresh() 
        self.m_richText:SetCaratEnd() 
    end
end
function RecruitCell1DiankaDg:HandleKeyboardTargetWndChanged(args)
    local wnd = CEGUI.toWindowEventArgs(args).window
    if wnd == self.m_richText then
        self.m_richNomalText:setVisible(false)
    else
        if self.m_richText:GetPureText() == "" then
            self.m_richNomalText:setVisible(true)
        end
    end
end
function RecruitCell1DiankaDg:Update()
    --local text = self.m_richText:GetPureText()
    --self.m_richNomalText:setVisible((text == "" and self.m_richText:hasInputFocus()))
end
local function getShieldStr(str)
	assert(str)
	--local len = string.len(str)
    --汉字和英文分开处理
    local cNum, eNum = GetCharCount(str)
	local size = {}
	for i = 1, cNum do
		size[i] = '*'
	end
    for j = 1, eNum do
		size[#size + 1] = '*'
	end
	return table.concat(size)
end
function RecruitCell1DiankaDg.ShiedText(inText)
    inText = MHSD_UTILS.trim(inText)
	local shied = false
	if string.len(inText)>0 then
		local configtable = BeanConfigManager.getInstance():GetTableByName("chat.cbanwords")
		local banwordids = configtable:getAllID()
		for _,id in pairs(banwordids) do
			local word = configtable:getRecorder(id).BanWords
			word = MHSD_UTILS.trim(word)
			if string.match(inText, word) then
				shied = true
			end
            if shied then
                inText = string.gsub(inText, word, getShieldStr(word))
            end
		end
	end
	return shied, inText
end
return RecruitCell1DiankaDg