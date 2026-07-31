require "utils.mhsdutils"
require "logic.dialog"
require "logic.LabelDlg"
require "logic.ranse.characterransedlg"
require "logic.ranse.petransedlg"
require "logic.ranse.yichudlg"

RanSeLabel = {}
setmetatable(RanSeLabel, Dialog)
RanSeLabel.__index = RanSeLabel

local _instance
local Dlgs =
{
	CharacterRanseDlg,
	YiChuDlg,
	PetRanseDlg
}

g_yclist = {}
g_getyc = false

function RanSeLabel.getInstance()
	if not _instance then
		_instance = RanSeLabel:new()
		_instance:OnCreate()
	end
	return _instance
end

function RanSeLabel.getInstanceNotCreate()
	return _instance
end

function RanSeLabel.GetLayoutFileName()
	return "lablers.layout"
end

function RanSeLabel:OnCreate()
	local prefix = enumLabel.enumRanSeLabel
	Dialog.OnCreate(self,nil, prefix)
	self:GetWindow():setRiseOnClickEnabled(false)
	
	self.curDialog = nil
	
	

	
	local winMgr = CEGUI.WindowManager:getSingleton()
	self.m_pButton1 = CEGUI.toPushButton(winMgr:getWindow(tostring(prefix) .. "Lable/button"))
    self.m_pButton1:SetMouseLeaveReleaseInput(false)
	self.m_pButton2 = CEGUI.toPushButton(winMgr:getWindow(tostring(prefix) .. "Lable/button1"))
    self.m_pButton2:SetMouseLeaveReleaseInput(false)
	self.m_pButton3 = CEGUI.toPushButton(winMgr:getWindow(tostring(prefix) .. "Lable/button2"))
    self.m_pButton3:SetMouseLeaveReleaseInput(false)
	self.m_pButton4 = CEGUI.toPushButton(winMgr:getWindow(tostring(prefix) .. "Lable/button3"))
    self.m_pButton4:SetMouseLeaveReleaseInput(false)
	self.m_pButton5 = CEGUI.toPushButton(winMgr:getWindow(tostring(prefix) .. "Lable/button4"))
    self.m_pButton5:SetMouseLeaveReleaseInput(false)
	
	self.m_pButton1:setText(MHSD_UTILS.get_resstring( 11402 ))
	self.m_pButton2:setText(MHSD_UTILS.get_resstring( 11403 ))
	self.m_pButton3:setText(MHSD_UTILS.get_resstring( 11404 ))
	self.m_pButton4:setVisible(false);
	self.m_pButton5:setVisible(false);
	
	self.m_pButton1:EnableClickAni(false)
	self.m_pButton2:EnableClickAni(false)
	self.m_pButton3:EnableClickAni(false)
	self.m_pButton4:EnableClickAni(false)
	self.m_pButton5:EnableClickAni(false)
	
	self.m_pButton1:subscribeEvent("Clicked", RanSeLabel.HandleLabel1BtnClicked, self);
	self.m_pButton2:subscribeEvent("Clicked", RanSeLabel.HandleLabel2BtnClicked, self);
	self.m_pButton3:subscribeEvent("Clicked", RanSeLabel.HandleLabel3BtnClicked, self);

    if g_getyc == false then
	    local p = require "protodef.fire.pb.creqcolorroomview":new()
        require "manager.luaprotocolmanager".getInstance():send(p)
    end
    self.m_pMainFrame:subscribeEvent("Activated", RanSeLabel.HandleActivate, self) 
end


function RanSeLabel:new()
	local self={}
	self = Dialog:new()
	setmetatable(self, RanSeLabel)
	return self
end

function RanSeLabel.DestroyDialog()
	LogInfo("RanSeLabel destroy dialog")
	
	if _instance then
		for _,v in pairs(Dlgs) do
			local dlg = v.getInstanceNotCreate()
			if dlg then
				_instance:removeEvent(dlg:GetWindow())
				dlg.DestroyDialog()
			end
		end
		
		_instance:OnClose()
		_instance = nil
	end
end

function RanSeLabel.Show(index)
	--在这里更新显示任务
	RanSeLabel.getInstance()
	index = index or  1
	_instance:ShowOnly(index)
end
--yc_jiajiesuju ={}
local p = require "protodef.fire.pb.sreqcolorroomview"
function p:process()
    g_getyc = true     
    g_yclist = {}
    local len = #self.rolecolortypelist    
    for i=1,len do
        g_yclist[i] = {}
        g_yclist[i].index = i
        g_yclist[i].colorA = self.rolecolortypelist[i].colorpos1
        g_yclist[i].colorB = self.rolecolortypelist[i].colorpos2
    end
	
	
--yc_jiajiesuju = g_yclist--嫁接数据 提取到人物时装界面 

    local dlg = YiChuDlg.getInstanceNotCreate()
    if dlg then
        dlg:setYCList(g_yclist)
    end
end


local p = require "protodef.fire.pb.srequsecolor"
function p:process()  

    local dlg = CharacterRanseDlg.getInstanceNotCreate()
    if dlg then
    dlg:Init(self.rolecolorinfo.colorpos1,self.rolecolorinfo.colorpos2)
    dlg:refreshItemShow()
    end

    local dlg = YiChuDlg.getInstanceNotCreate()
    if dlg then
        dlg:Init(self.rolecolorinfo.colorpos1,self.rolecolorinfo.colorpos2)
        dlg.m_ycSel = 0
        --[[for index = 1, 12 do        
        if dlg.m_ycList[index].cbtn then
            dlg.m_ycList[index].cbtn:setVisible(false)
        else
            LogWar("protodef.fire.pb.srequsecolor dlg.m_ycList[index].cbtn:setVisible")
        end
        end]]--
        dlg:refreshItemShow()
    end     
end

function RanSeLabel:setButtonPushed(idx)
	for i=1,4 do
		self["m_pButton" .. i]:SetPushState(i==idx)
	end
end

function RanSeLabel:ShowOnly(index)

	self:setButtonPushed(index)
	
	if self.curDialog then
		self.curDialog:SetVisible(false)
	end

	self.curIdx = index

	if index == 1 then
		self.curDialog = self:getDialog(CharacterRanseDlg)
		self.curDialog:refreshSelect()
	elseif index == 2 then
		self.curDialog = self:getDialog(YiChuDlg)        
        local pA = GetMainCharacter():GetSpriteComponent(eSprite_DyePartA)
        local pB = GetMainCharacter():GetSpriteComponent(eSprite_DyePartB)
        self.curDialog:Init(pA,pB);
        self.curDialog:setYCList(g_yclist)
        self.curDialog:setSelectYC(0)
		self.curDialog:refreshItemShow()
	elseif index == 3 then
		self.curDialog = self:getDialog(PetRanseDlg)
	end		

	self:SetVisible(true)
	self:GetWindow():getParent():bringWindowAbove(self:GetWindow(), self.curDialog:GetWindow())
end

function RanSeLabel:getDialog(Dlg)
	local dlg = Dlg.getInstanceNotCreate()
	if not dlg then
		dlg = Dlg.getInstanceAndShow()
		self:subscribeEvent(dlg:GetWindow())
	else
		dlg:SetVisible(true)
	end
	return dlg
end

function RanSeLabel:HandleLabel1BtnClicked(e)
	LogInfo("label 1 clicked")
	RanSeLabel.getInstance():ShowOnly(1)
	return true
end

function RanSeLabel:HandleLabel2BtnClicked(e)
	LogInfo("label 2 clicked")
	RanSeLabel.getInstance():ShowOnly(2)
	return true
end

function RanSeLabel:HandleLabel3BtnClicked(e)
	LogInfo("label 2 clicked")
	RanSeLabel.getInstance():ShowOnly(3)
	return true
end

function RanSeLabel:subscribeEvent(wnd)
	wnd:subscribeEvent("AlphaChanged", RanSeLabel.HandleDlgStateChange, self)
	wnd:subscribeEvent("Shown", RanSeLabel.HandleDlgStateChange, self)
	wnd:subscribeEvent("Hidden", RanSeLabel.HandleDlgStateChange, self)
	wnd:subscribeEvent("InheritAlphaChanged", RanSeLabel.HandleDlgStateChange, self)
end

function RanSeLabel:removeEvent(wnd)
	wnd:removeEvent("AlphaChanged")
	wnd:removeEvent("Shown")
	wnd:removeEvent("Hidden")
	wnd:removeEvent("InheritAlphaChanged")
end

function RanSeLabel:HandleDlgStateChange(args)
	if not self.curIdx or not Dlgs[self.curIdx] or not Dlgs[self.curIdx].getInstanceNotCreate() then
		return
	end
	local curWnd = Dlgs[self.curIdx].getInstanceNotCreate():GetWindow()
	for _,v in pairs(Dlgs) do
		local dlg = v.getInstanceNotCreate()
		if dlg and dlg:IsVisible() and dlg:GetWindow():getEffectiveAlpha() > 0.95 then
			self:SetVisible(true)
			self:GetWindow():getParent():bringWindowAbove(self:GetWindow(), curWnd)
			return true
		end
	end
	
	self:SetVisible(false)
end

function RanSeLabel:HandleActivate(args)
    self:refreshItemShow()
end
--购买成功后刷新染料的显示
function RanSeLabel:refreshItemShow()
      if self.curDialog then
          self.curDialog:refreshItemShow()
      end
end

return RanSeLabel
