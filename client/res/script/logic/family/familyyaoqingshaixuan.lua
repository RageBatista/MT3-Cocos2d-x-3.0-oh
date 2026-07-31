require "logic.dialog"
require "logic.family.familyyaoqingcommon"

local bPushed = false
local bUnPushed = true

FamilyYaoQingShaiXuan = {}
setmetatable(FamilyYaoQingShaiXuan, Dialog)
FamilyYaoQingShaiXuan.__index = FamilyYaoQingShaiXuan

local _instance
function FamilyYaoQingShaiXuan.getInstance()
	if not _instance then
		_instance = FamilyYaoQingShaiXuan:new()
		_instance:OnCreate()
	end
	return _instance
end

function FamilyYaoQingShaiXuan.getInstanceAndShow()
	if not _instance then
		_instance = FamilyYaoQingShaiXuan:new()
		_instance:OnCreate()
	else
		_instance:SetVisible(true)
	end
	return _instance
end

function FamilyYaoQingShaiXuan.getInstanceNotCreate()
	return _instance
end

function FamilyYaoQingShaiXuan.DestroyDialog()
	if _instance then 
		if not _instance.m_bCloseIsHide then
			_instance:OnClose()
			_instance = nil
		else
			_instance:ToggleOpenClose()
		end
	end
end

function FamilyYaoQingShaiXuan.ToggleOpenClose()
	if not _instance then
		_instance = FamilyYaoQingShaiXuan:new()
		_instance:OnCreate()
	else
		if _instance:IsVisible() then
			_instance:SetVisible(false)
		else
			_instance:SetVisible(true)
		end
	end
end

function FamilyYaoQingShaiXuan.GetLayoutFileName()
	return "familyyaodingshaixuancell.layout"
end

function FamilyYaoQingShaiXuan:new()
	local self = {}
	self = Dialog:new()
	setmetatable(self, FamilyYaoQingShaiXuan)
	return self
end

function FamilyYaoQingShaiXuan:OnCreate()
	Dialog.OnCreate(self)
    SetPositionScreenCenter(self:GetWindow())
	local winMgr = CEGUI.WindowManager:getSingleton()

    -- 选择等级
	self.m_Text_Level = winMgr:getWindow("familyyaoqingshaixuandiban/shurudi/wenzi")
	self.m_Text_Level:subscribeEvent("MouseClick", FamilyYaoQingShaiXuan.onTextLevelClicked, self)

    -- 选择战士
	self.m_ImgBtn_ZhanShi = CEGUI.toPushButton(winMgr:getWindow("familyyaoqingshaixuandiban/ceng/btn1"))
	self.m_ImgBtn_ZhanShi:subscribeEvent("Clicked", FamilyYaoQingShaiXuan.onImgBtnZhanShiClicked, self)
    self.m_ImgBtn_ZhanShi:EnableClickAni(false)

    -- 选择法师
	self.m_ImgBtn_FaShi = CEGUI.toPushButton(winMgr:getWindow("familyyaoqingshaixuandiban/ceng/btn11"))
	self.m_ImgBtn_FaShi:subscribeEvent("Clicked", FamilyYaoQingShaiXuan.onImgBtnFaShiClicked, self)
    self.m_ImgBtn_FaShi:EnableClickAni(false)

    -- 选择术士
	self.m_ImgBtn_ShuShi = CEGUI.toPushButton(winMgr:getWindow("familyyaoqingshaixuandiban/ceng/btn12"))
	self.m_ImgBtn_ShuShi:subscribeEvent("Clicked", FamilyYaoQingShaiXuan.onImgBtnShuShiClicked, self)
    self.m_ImgBtn_ShuShi:EnableClickAni(false)

    -- 选择萨满
	self.m_ImgBtn_SaMan = CEGUI.toPushButton(winMgr:getWindow("familyyaoqingshaixuandiban/ceng/btn13"))
	self.m_ImgBtn_SaMan:subscribeEvent("Clicked", FamilyYaoQingShaiXuan.onImgBtnSaManClicked, self)
    self.m_ImgBtn_SaMan:EnableClickAni(false)

    -- 选择牧师
	self.m_ImgBtn_MuShi = CEGUI.toPushButton(winMgr:getWindow("familyyaoqingshaixuandiban/ceng/btn14"))
	self.m_ImgBtn_MuShi:subscribeEvent("Clicked", FamilyYaoQingShaiXuan.onImgBtnMuShiClicked, self)
    self.m_ImgBtn_MuShi:EnableClickAni(false)

    -- 选择骑士
	self.m_ImgBtn_QiShi = CEGUI.toPushButton(winMgr:getWindow("familyyaoqingshaixuandiban/ceng/btn15"))
	self.m_ImgBtn_QiShi:subscribeEvent("Clicked", FamilyYaoQingShaiXuan.onImgBtnQiShiClicked, self)
    self.m_ImgBtn_QiShi:EnableClickAni(false)

    -- 选择猎人
	self.m_ImgBtn_LieRen = CEGUI.toPushButton(winMgr:getWindow("familyyaoqingshaixuandiban/ceng/btn111"))
	self.m_ImgBtn_LieRen:subscribeEvent("Clicked", FamilyYaoQingShaiXuan.onImgBtnLieRenClicked, self)
    self.m_ImgBtn_LieRen:EnableClickAni(false)

    -- 选择德鲁伊
	self.m_ImgBtn_DeLuYi = CEGUI.toPushButton(winMgr:getWindow("familyyaoqingshaixuandiban/ceng/btn1111"))
	self.m_ImgBtn_DeLuYi:subscribeEvent("Clicked", FamilyYaoQingShaiXuan.onImgBtnDeLuYiClicked, self)
    self.m_ImgBtn_DeLuYi:EnableClickAni(false)

    -- 选择盗贼
	self.m_ImgBtn_DaoZei = CEGUI.toPushButton(winMgr:getWindow("familyyaoqingshaixuandiban/ceng/btn11111"))
	self.m_ImgBtn_DaoZei:subscribeEvent("Clicked", FamilyYaoQingShaiXuan.onImgBtnDaoZeiClicked, self)
    self.m_ImgBtn_DaoZei:EnableClickAni(false)

    -- 选择性别男
	self.m_CheckBox_Man = CEGUI.toCheckbox(winMgr:getWindow("familyyaoqingshaixuandiban/checkbox"))
	self.m_CheckBox_Man:setID(eSex_Man)
	self.m_CheckBox_Man:subscribeEvent("CheckStateChanged", FamilyYaoQingShaiXuan.onCheckStateChanged, self)

    -- 选择性别女
	self.m_CheckBox_Woman = CEGUI.toCheckbox(winMgr:getWindow("familyyaoqingshaixuandiban/checkbox1"))
	self.m_CheckBox_Woman:setID(eSex_Woman)
	self.m_CheckBox_Woman:subscribeEvent("CheckStateChanged", FamilyYaoQingShaiXuan.onCheckStateChanged, self)

    -- 确认按钮
	self.m_Btn_Confirm = CEGUI.toPushButton(winMgr:getWindow("familyyaoqingshaixuanqudinqueding"))
	self.m_Btn_Confirm:subscribeEvent("Clicked", FamilyYaoQingShaiXuan.onBtnConfirmClicked, self)
end

-- 刷新界面
function FamilyYaoQingShaiXuan:RefreshYaoQingUI()
    self.m_Text_Level:setText(FamilyYaoQingCommon.m_tmp_type_level)
    self:RefreshZhiYe()
    self:RefreshSex()
end

-- 刷新职业筛选
function FamilyYaoQingShaiXuan:RefreshZhiYe()
    self.m_ImgBtn_ZhanShi:SetPushState(bUnPushed)
    self.m_ImgBtn_FaShi:SetPushState(bUnPushed)
    self.m_ImgBtn_ShuShi:SetPushState(bUnPushed)
    self.m_ImgBtn_SaMan:SetPushState(bUnPushed)
    self.m_ImgBtn_MuShi:SetPushState(bUnPushed)
    self.m_ImgBtn_QiShi:SetPushState(bUnPushed)
    self.m_ImgBtn_LieRen:SetPushState(bUnPushed)
    self.m_ImgBtn_DeLuYi:SetPushState(bUnPushed)
    self.m_ImgBtn_DaoZei:SetPushState(bUnPushed)
    for _, zhiye in pairs(FamilyYaoQingCommon.m_tmp_vec_type_school) do
        if zhiye == eZhiYe_ZhanShi then
            self.m_ImgBtn_ZhanShi:SetPushState(bPushed)
        elseif zhiye == eZhiYe_QiShi then
            self.m_ImgBtn_QiShi:SetPushState(bPushed)
        elseif zhiye == eZhiYe_LieRen then
            self.m_ImgBtn_LieRen:SetPushState(bPushed)
        elseif zhiye == eZhiYe_DeLuYi then
            self.m_ImgBtn_DeLuYi:SetPushState(bPushed)
        elseif zhiye == eZhiYe_FaShi then
            self.m_ImgBtn_FaShi:SetPushState(bPushed)
        elseif zhiye == eZhiYe_MuShi then
            self.m_ImgBtn_MuShi:SetPushState(bPushed)
        elseif zhiye == eZhiYe_SaMan then
            self.m_ImgBtn_SaMan:SetPushState(bPushed)
        elseif zhiye == eZhiYe_DaoZei then
            self.m_ImgBtn_DaoZei:SetPushState(bPushed)
        elseif zhiye == eZhiYe_ShuShi then
            self.m_ImgBtn_ShuShi:SetPushState(bPushed)
        end
    end
end

-- 刷新性别筛选
function FamilyYaoQingShaiXuan:RefreshSex()
    self.m_CheckBox_Man:setSelectedNoEvent(false)
    self.m_CheckBox_Woman:setSelectedNoEvent(false)
    if FamilyYaoQingCommon.m_tmp_type_sex == eSex_Man then
        self.m_CheckBox_Man:setSelectedNoEvent(true)
    elseif FamilyYaoQingCommon.m_tmp_type_sex == eSex_Woman then
        self.m_CheckBox_Woman:setSelectedNoEvent(true)
    end
end

-------------------------------------------------------------------------------------------------------

-- 选择等级
function FamilyYaoQingShaiXuan:onTextLevelClicked(args)
	if NumKeyboardDlg.getInstanceNotCreate() then
		NumKeyboardDlg.getInstanceNotCreate():SetVisible(true) --保持键盘在最上面
		return
	end
	
	local dlg = NumKeyboardDlg.getInstanceAndShow()
	if dlg then
        self:GetWindow():addChildWindow(dlg:GetWindow())
		dlg:setTriggerBtn(self.m_Text_Level)
		dlg:setMaxValue(149)
		dlg:setInputChangeCallFunc(FamilyYaoQingShaiXuan.onNumInputChanged, self)
		
		SetPositionOffset(dlg:GetWindow(), 252, 69, 0.5, 0)
	end
end

-- 等级输入发生变化的回调
function FamilyYaoQingShaiXuan:onNumInputChanged(num)
	if num == 0 then
        self.m_Text_Level:setText(1)
        FamilyYaoQingCommon.SetTmpTypeLevel(1)
    else
        self.m_Text_Level:setText(num)
        FamilyYaoQingCommon.SetTmpTypeLevel(num)
	end
end

-------------------------------------------------------------------------------------------------------

-- 选择战士
function FamilyYaoQingShaiXuan:onImgBtnZhanShiClicked(args)
    FamilyYaoQingCommon.SetTmpTypeSchool(eZhiYe_ZhanShi)
    self:RefreshZhiYe()
end

-- 选择法师
function FamilyYaoQingShaiXuan:onImgBtnFaShiClicked(args)
    FamilyYaoQingCommon.SetTmpTypeSchool(eZhiYe_FaShi)
    self:RefreshZhiYe()
end

-- 选择术士
function FamilyYaoQingShaiXuan:onImgBtnShuShiClicked(args)
    FamilyYaoQingCommon.SetTmpTypeSchool(eZhiYe_ShuShi)
    self:RefreshZhiYe()
end

-- 选择萨满
function FamilyYaoQingShaiXuan:onImgBtnSaManClicked(args)
    FamilyYaoQingCommon.SetTmpTypeSchool(eZhiYe_SaMan)
    self:RefreshZhiYe()
end

-- 选择牧师
function FamilyYaoQingShaiXuan:onImgBtnMuShiClicked(args)
    FamilyYaoQingCommon.SetTmpTypeSchool(eZhiYe_MuShi)
    self:RefreshZhiYe()
end

-- 选择骑士
function FamilyYaoQingShaiXuan:onImgBtnQiShiClicked(args)
    FamilyYaoQingCommon.SetTmpTypeSchool(eZhiYe_QiShi)
    self:RefreshZhiYe()
end

-- 选择猎人
function FamilyYaoQingShaiXuan:onImgBtnLieRenClicked(args)
    FamilyYaoQingCommon.SetTmpTypeSchool(eZhiYe_LieRen)
    self:RefreshZhiYe()
end

-- 选择德鲁伊
function FamilyYaoQingShaiXuan:onImgBtnDeLuYiClicked(args)
    FamilyYaoQingCommon.SetTmpTypeSchool(eZhiYe_DeLuYi)
    self:RefreshZhiYe()
end

-- 选择盗贼
function FamilyYaoQingShaiXuan:onImgBtnDaoZeiClicked(args)
    FamilyYaoQingCommon.SetTmpTypeSchool(eZhiYe_DaoZei)
    self:RefreshZhiYe()
end

-------------------------------------------------------------------------------------------------------

-- 性别的选择框事件
function FamilyYaoQingShaiXuan:onCheckStateChanged(args)
	local windowEventArgs = CEGUI.toWindowEventArgs(args)
    if windowEventArgs then
	    local wnd = windowEventArgs.window
        if wnd then
	        local sex = wnd:getID()
            FamilyYaoQingCommon.SetTmpTypeSex(sex)
            self:RefreshSex()
        end
    end
end

-------------------------------------------------------------------------------------------------------

-- 点击确认按钮
function FamilyYaoQingShaiXuan.onBtnConfirmClicked(args)
    -- 确认临时筛选
    FamilyYaoQingCommon.ConfirmTmpShaiXuan()
    -- 请求邀请列表
    FamilyYaoQingCommon.RequestYaoQingList()
    -- 关闭自身
    FamilyYaoQingShaiXuan.DestroyDialog()
end

return FamilyYaoQingShaiXuan