require "logic.dialog"
require "logic.family.familychengyuandiacell"
require "logic.family.familyshenqingdiacell"
require "logic.family.familyqunfaxiaoxidialog"    -- 公会群发消息UI
require "logic.family.familyshijiandiacell"

Familychengyuandialog = { }
setmetatable(Familychengyuandialog, Dialog)
Familychengyuandialog.__index = Familychengyuandialog

local _instance
function Familychengyuandialog.getInstance()
    if not _instance then
        _instance = Familychengyuandialog:new()
        _instance:OnCreate()
    end
    return _instance
end

function Familychengyuandialog.getInstanceAndShow()
    if not _instance then
        _instance = Familychengyuandialog:new()
        _instance:OnCreate()
    else
        _instance:SetVisible(true)
    end
    return _instance
end

function Familychengyuandialog.getInstanceNotCreate()
    return _instance
end

function Familychengyuandialog.DestroyDialog(IsDestroyPage)
    -- 关闭本dialog
    if IsDestroyPage == nil then
        IsDestroyPage = true
    end
    if IsDestroyPage then
        if Familylabelframe.getInstanceNotCreate() then
            Familylabelframe.getInstanceNotCreate().DestroyDialog()
        end
    end
    if _instance then
        if not _instance.m_bCloseIsHide then
            -- 关闭tableview
            if _instance.m_Entrys then
                _instance.m_Entrys:destroyCells()
            end
            if _instance.m_Entrys2 then
                _instance.m_Entrys2:destroyCells()
            end
            if _instance.m_Entrys3 then
                _instance.m_Entrys3:destroyCells()
            end
            _instance:OnClose()
            _instance = nil
        else
            _instance:ToggleOpenClose()
        end
    end
end

function Familychengyuandialog.ToggleOpenClose()
    if not _instance then
        _instance = Familychengyuandialog:new()
        _instance:OnCreate()
    else
        if _instance:IsVisible() then
            _instance:SetVisible(false)
        else
            _instance:SetVisible(true)
        end
    end
end

function Familychengyuandialog.GetLayoutFileName()
    return "familychengyuandialog.layout"
end

function Familychengyuandialog:new()
    local self = { }
    self = Dialog:new()
    setmetatable(self, Familychengyuandialog)
    return self
end

function Familychengyuandialog:OnCreate()
    Dialog.OnCreate(self)
    local winMgr = CEGUI.WindowManager:getSingleton()

    -- 自动接收申请人
    self.m_AutoRecv = CEGUI.toCheckbox(winMgr:getWindow("familychengyuandialog/xuetu"))
    self.m_AutoRecv:subscribeEvent("MouseButtonUp", self.AutoRecvStateChanged, self)

    -- 自动接收申请人模式
    self.m_AutoRecvMode = 0
    self.m_AutoRecvLevel = 1

    -- 选择自动接收申请人的等级
    self.m_Level_Bg = winMgr:getWindow("familychengyuandialog/shurudi")
    self.m_Desc = winMgr:getWindow("familychengyuandialog/shenqin")
	self.m_AutoRecv_Level = winMgr:getWindow("familychengyuandialog/shurudi/rich")
	self.m_AutoRecv_Level:subscribeEvent("MouseClick", Familychengyuandialog.onLevelClicked, self)

    -- 当前选择的工会成员
    self.m_SelectEntryIndex = 0

    -- 成员列表的排序
    self.m_CurSort = 0
    self.m_LastSort = -1
    -- 1 升序 -1 降序 0 重置
    self.m_Sort1Type = 1
    self.m_Sort2Type = 1
    self.m_Sort3Type = 1
    self.m_Sort4Type = 1
    self.m_Sort5Type = 1
    self.m_Sort6Type = 1
    self.m_Sort7Type = 1
    self.m_Sort8Type = 1
    self.m_Sort9Type = 1
    self.m_Sort10Type = 1
    self.m_Sort11Type = 1
    self.m_Sort12Type = 1
    self.m_Sort13Type = 1
	self.m_Sort14Type = 1

    -- 成员列表的标题栏
    -- 工会成员（标题、排序图标）
    self.BtnTextgonghuichengyuan = winMgr:getWindow("familychengyuandialog/familychengyuandialogMember/biaoti/gonghuichengyuan")
    self.chengyuanup = winMgr:getWindow("familychengyuandialog/familychengyuandialogMember/biaoti/gonghuichengyuan/up")
    self.chengyuandown = winMgr:getWindow("familychengyuandialog/familychengyuandialogMember/biaoti/gonghuichengyuan/down")
    self.BtnTextgonghuichengyuan:subscribeEvent("MouseButtonDown", Familychengyuandialog.Sort1, self)
    -- 工会等级（标题、排序图标）
    self.m_Title_1_1 = winMgr:getWindow("familychengyuandialog/familychengyuandialogMember/biaoti/lev")
    self.BtnDengjiUp = winMgr:getWindow("familychengyuandialog/familychengyuandialogMember/biaoti/lev/up")
    self.BtnDengjiDown = winMgr:getWindow("familychengyuandialog/familychengyuandialogMember/biaoti/lev/down")
    self.m_Title_1_1:subscribeEvent("MouseButtonDown", Familychengyuandialog.Sort2, self)
    -- 职业（标题、排序图标）
    self.m_Title_1_2 = winMgr:getWindow("familychengyuandialog/familychengyuandialogMember/biaoti/zhiye")
    self.m_BtnZhiyeUp = winMgr:getWindow("familychengyuandialog/familychengyuandialogMember/biaoti/zhiye/up")
    self.m_BtnZhiyeDown = winMgr:getWindow("familychengyuandialog/familychengyuandialogMember/biaoti/zhiye/down")
    self.m_Title_1_2:subscribeEvent("MouseButtonDown", Familychengyuandialog.Sort3, self)
    -- 职务（标题、排序图标）
    self.m_Title_1_4 = winMgr:getWindow("familychengyuandialog/familychengyuandialogMember/biaoti/zhiwu")
    self.m_ZhiWuUp = winMgr:getWindow("familychengyuandialog/familychengyuandialogMember/biaoti/zhiwu/up")
    self.m_ZhiWuDown = winMgr:getWindow("familychengyuandialog/familychengyuandialogMember/biaoti/zhiwu/down")
    self.m_Title_1_4:subscribeEvent("MouseButtonDown", Familychengyuandialog.Sort4, self)
    -- 上周贡献（标题、排序图标）
    self.m_Title_1_3 = winMgr:getWindow("familychengyuandialog/familychengyuandialogMember/biaoti/benzhougongxian")
    self.m_BenZhouGongXianUp = winMgr:getWindow("familychengyuandialog/familychengyuandialogMember/biaoti/benzhougongxian/up")
    self.m_BenZhouGongXianDown = winMgr:getWindow("familychengyuandialog/familychengyuandialogMember/biaoti/benzhougongxian/down")
    self.m_Title_1_3:subscribeEvent("MouseButtonDown", Familychengyuandialog.Sort5, self)
    -- 本周贡献（标题、排序图标）
    self.m_Title_1_5 = winMgr:getWindow("familychengyuandialog/familychengyuandialogMember/biaoti/xianyougongxian")
    self.m_XianYouGongXianUp = winMgr:getWindow("familychengyuandialog/familychengyuandialogMember/biaoti/xianyougongxian/up")
    self.m_XianYouGongXianDown = winMgr:getWindow("familychengyuandialog/familychengyuandialogMember/biaoti/xianyougongxian/down")
    self.m_Title_1_5:subscribeEvent("MouseButtonDown", Familychengyuandialog.Sort6, self)
    -- 现有贡献/历史贡献（标题、排序图标）
    self.m_Title_1_6 = winMgr:getWindow("familychengyuandialog/familychengyuandialogMember/biaoti/lishigongxian")
    self.m_LiShiGongXianUp = winMgr:getWindow("familychengyuandialog/familychengyuandialogMember/biaoti/lishigongxian/up")
    self.m_LiShiGongXianDown = winMgr:getWindow("familychengyuandialog/familychengyuandialogMember/biaoti/lishigongxian/down")
    self.m_Title_1_6:subscribeEvent("MouseButtonDown", Familychengyuandialog.Sort7, self)
    -- 本周援助（标题、排序图标）
    self.m_Title_2_1 = winMgr:getWindow("familychengyuandialog/familychengyuandialogMember/biaoti/benzhouyuanzhu")
    self.m_BenZhouYuanZhuUp = winMgr:getWindow("familychengyuandialog/familychengyuandialogMember/biaoti/benzhouyuanzhu/up")
    self.m_BenZhouYuanZhuDown = winMgr:getWindow("familychengyuandialog/familychengyuandialogMember/biaoti/benzhouyuanzhu/down")
    self.m_Title_2_1:subscribeEvent("MouseButtonDown", Familychengyuandialog.Sort8, self)
    -- 历史援助（标题、排序图标）
    self.m_Title_2_2 = winMgr:getWindow("familychengyuandialog/familychengyuandialogMember/biaoti/lishiyuanzhu")
    self.m_LiShiYuanZhuUp = winMgr:getWindow("familychengyuandialog/familychengyuandialogMember/biaoti/lishiyuanzhu/up")
    self.m_LiShiYuanZhuDown = winMgr:getWindow("familychengyuandialog/familychengyuandialogMember/biaoti/lishiyuanzhu/down")
    self.m_Title_2_2:subscribeEvent("MouseButtonDown", Familychengyuandialog.Sort9, self)
    -- 参加公会副本次数（标题、排序图标）
    self.m_Title_2_3 = winMgr:getWindow("familychengyuandialog/familychengyuandialogMember/biaoti/benlunjingsai")
    self.m_BenLunJingSaiUp = winMgr:getWindow("familychengyuandialog/familychengyuandialogMember/biaoti/benlunjingsai/up")
    self.m_BenLunJingSaiDown = winMgr:getWindow("familychengyuandialog/familychengyuandialogMember/biaoti/benlunjingsai/down")
    self.m_Title_2_3:subscribeEvent("MouseButtonDown", Familychengyuandialog.Sort10, self)
    -- 参加公会战次数（标题、排序图标）
    self.m_Title_2_4 = winMgr:getWindow("familychengyuandialog/familychengyuandialogMember/biaoti/lishijingsai")
    self.m_LiShiJingSaiUp = winMgr:getWindow("familychengyuandialog/familychengyuandialogMember/biaoti/lishijingsai/up")
    self.m_LiShiJingSaiDown = winMgr:getWindow("familychengyuandialog/familychengyuandialogMember/biaoti/lishijingsai/down")
    self.m_Title_2_4:subscribeEvent("MouseButtonDown", Familychengyuandialog.Sort11, self)
    -- 入会（标题、排序图标）
    self.m_Title_2_5 = winMgr:getWindow("familychengyuandialog/familychengyuandialogMember/biaoti/ruhui")
    self.m_RuHuiUp = winMgr:getWindow("familychengyuandialog/familychengyuandialogMember/biaoti/ruhui/up")
    self.m_RuHuiDown = winMgr:getWindow("familychengyuandialog/familychengyuandialogMember/biaoti/ruhui/down")
    self.m_Title_2_5:subscribeEvent("MouseButtonDown", Familychengyuandialog.Sort12, self)
    -- 离线时间（标题、排序图标）
    self.m_Title_2_6 = winMgr:getWindow("familychengyuandialog/familychengyuandialogMember/biaoti/lixianshijian")
	self.m_LiXianUp = winMgr:getWindow("familychengyuandialog/familychengyuandialogMember/biaoti/lixianshijian/up")
    self.m_LiXianDown = winMgr:getWindow("familychengyuandialog/familychengyuandialogMember/biaoti/lixianshijian/down")
    self.m_Title_2_6:subscribeEvent("MouseButtonDown", Familychengyuandialog.Sort13, self)
	
	
	-- 综合战力（标题、排序图标）
    self.m_Title_3_1 = winMgr:getWindow("familychengyuandialog/familychengyuandialogMember/biaoti/zonghe")
	self.m_FightValueUp = winMgr:getWindow("familychengyuandialog/familychengyuandialogMember/biaoti/zonghe/up")
    self.m_FightValueDown = winMgr:getWindow("familychengyuandialog/familychengyuandialogMember/biaoti/zonghe/down")
    self.m_Title_3_1:subscribeEvent("MouseButtonDown", Familychengyuandialog.Sort14, self)
	
     
	
	

    -- 当前选择的申请人员
    self.m_SelectEntryIndex2 = 0

    -- 申请列表的排序
    self.m_CurShenqingSort = 0
    self.m_LastShenqingSort = -1
    -- 1 升序 -1 降序 0 重置
    self.m_ShenqingSort1Type = 1
    self.m_ShenqingSort2Type = 1
    self.m_ShenqingSort3Type = 1
    self.m_ShenqingSort4Type = 1
	self.m_ShenqingSort5Type = 1
	 

    -- 申请列表的标题栏
    self.m_TitleApplyer = winMgr:getWindow("familychengyuandialog/Back2/shenqing/biaoti")
    -- 名称（标题、排序图标）
    self.BtnTextshenqingname = winMgr:getWindow("familychengyuandialog/Back2/shenqing/biaoti/name")
    self.shenqingnameup = winMgr:getWindow("familychengyuandialog/Back2/shenqing/biaoti/name/up")
    self.shenqingnamedown = winMgr:getWindow("familychengyuandialog/Back2/shenqing/biaoti/name/down")
    self.BtnTextshenqingname:subscribeEvent("MouseButtonDown", Familychengyuandialog.ShenqingSort1, self)
    -- 等级（标题、排序图标）
    self.BtnTextshenqinglevel = winMgr:getWindow("familychengyuandialog/Back2/shenqing/biaoti/lev")
    self.shenqinglevelup = winMgr:getWindow("familychengyuandialog/Back2/shenqing/biaoti/lev/up")
    self.shenqingleveldown = winMgr:getWindow("familychengyuandialog/Back2/shenqing/biaoti/lev/down")
    self.BtnTextshenqinglevel:subscribeEvent("MouseButtonDown", Familychengyuandialog.ShenqingSort2, self)
    -- 职业（标题、排序图标）
    self.BtnTextshenqingzhiye = winMgr:getWindow("familychengyuandialog/Back2/shenqing/biaoti/zhiye")
    self.shenqingzhiyeup = winMgr:getWindow("familychengyuandialog/Back2/shenqing/biaoti/zhiye/up")
    self.shenqingzhiyedown = winMgr:getWindow("familychengyuandialog/Back2/shenqing/biaoti/zhiye/down")
    self.BtnTextshenqingzhiye:subscribeEvent("MouseButtonDown", Familychengyuandialog.ShenqingSort3, self)
    -- ID（标题、排序图标）
    self.BtnTextshenqingid = winMgr:getWindow("familychengyuandialog/Back2/shenqing/biaoti/ID")
    self.shenqingidup = winMgr:getWindow("familychengyuandialog/Back2/shenqing/biaoti/ID/up")
    self.shenqingiddown = winMgr:getWindow("familychengyuandialog/Back2/shenqing/biaoti/ID/down")
    self.BtnTextshenqingid:subscribeEvent("MouseButtonDown", Familychengyuandialog.ShenqingSort4, self)
	
	-- 综合战力（标题、排序图标）
    self.BtnTextshenqingFightvalue = winMgr:getWindow("familychengyuandialog/Back2/shenqing/biaoti/zonghe")
    self.shenqingFightvalueup = winMgr:getWindow("familychengyuandialog/Back2/shenqing/biaoti/zonghe/up1")
    self.shenqingFightvaluedown = winMgr:getWindow("familychengyuandialog/Back2/shenqing/biaoti/zonghe/down1")
    self.BtnTextshenqingFightvalue:subscribeEvent("MouseButtonDown", Familychengyuandialog.ShenqingSort5, self)
	
	
	
	

    self.m_SwitchMode = 1
    -- 默认分组
    -- 默认为空值后边刷新会赋值
    -- int[1,2]
    self.m_Mode = 1
    self.m_FactionData = require "logic.faction.factiondatamanager"
    -- 引导员图片(没有申请列表时出现)
    self.m_PersonImage = winMgr:getWindow("familychengyuandialog/Back2/shenqing/yindaoyuan")
    -- 申请列表提示(没有申请列表时出现)
    self.m_ApplyTips = winMgr:getWindow("familychengyuandialog/Back2/shenqing/tishi")
    -- 成员列表左右切换按钮
    self.m_Switchbutton2 = CEGUI.toPushButton(winMgr:getWindow("familychengyuandialog/Back2/zuo"))
    self.m_Switchbutton1 = CEGUI.toPushButton(winMgr:getWindow("familychengyuandialog/Back2/you"))
    self.m_Switchbutton2:subscribeEvent("Clicked", Familychengyuandialog.SwitchButtonClicked, self)
    self.m_Switchbutton1:subscribeEvent("Clicked", Familychengyuandialog.SwitchButtonClicked, self)

    -- 弹劾会长按钮
    self.m_TanHeBtn = CEGUI.toPushButton(winMgr:getWindow("familychengyuandialog/gonghuiliebiao/tanhe"))
    self.m_TanHeBtn:subscribeEvent("Clicked", Familychengyuandialog.OnClickTanHeBtn, self)

    -- 公会列表按钮
    self.m_FamilyListBtn = CEGUI.toPushButton(winMgr:getWindow("familychengyuandialog/gonghuiliebiao"))
    -- 界面帮助按钮
    self.m_UIHelpButton = CEGUI.toPushButton(winMgr:getWindow("familychengyuandialog/jiemianshuoming"))
    self.m_UIHelpButton:subscribeEvent("Clicked", Familychengyuandialog.OnClickShuoMing, self)
    -- 刷新按钮
    self.m_RefreshListButton = CEGUI.toPushButton(winMgr:getWindow("familychengyuandialog/shuaxin"))
    -- 清空按钮
    self.m_ClearButton = CEGUI.toPushButton(winMgr:getWindow("familychengyuandialog/qingkong"))
    -- 群发消息
    self.m_SendAllButton = CEGUI.toPushButton(winMgr:getWindow("familychengyuandialog/qunfaxiaoxi"))
    self.m_SendAllButton:subscribeEvent("Clicked", Familychengyuandialog.OnSendAllBtnHandler, self)
    -- 离开公会按钮
    self.m_LeaveFamilyBtn = CEGUI.toPushButton(winMgr:getWindow("familychengyuandialog/leave"))
    self.m_LeaveFamilyBtn:subscribeEvent("Clicked", Familychengyuandialog.LeaveFamilyBtnClicked, self)
    -- 按钮上消息个数提示
    self.m_TipImage1 = winMgr:getWindow("familychengyuandialog/chengyuanliebiao/mark")
    self.m_TipImage2 = winMgr:getWindow("familychengyuandialog/StartChat2/mark")
    self.m_TipImage3 = winMgr:getWindow("familychengyuandialog/shijian/mark")
    -- 横向标签页按钮
    self.m_TabButton1 = CEGUI.toGroupButton(winMgr:getWindow("familychengyuandialog/chengyuanliebiao"))
    self.m_TabButton2 = CEGUI.toGroupButton(winMgr:getWindow("familychengyuandialog/StartChat2"))
    self.m_TabButton3 = CEGUI.toGroupButton(winMgr:getWindow("familychengyuandialog/shijian"))
    self.m_TabButton1:setID(1)
    self.m_TabButton2:setID(2)
    self.m_TabButton3:setID(3)
    self.m_TabButton1:subscribeEvent("SelectStateChanged", Familychengyuandialog.HandleSelectChanged, self)
    self.m_TabButton2:subscribeEvent("SelectStateChanged", Familychengyuandialog.HandleSelectChanged, self)
    self.m_TabButton3:subscribeEvent("SelectStateChanged", Familychengyuandialog.HandleSelectChanged, self)
    -- 公会邀请按钮独立
    self.m_BtnYaoQing = CEGUI.toPushButton(winMgr:getWindow("familychengyuandialog/gonghuiyaoqing"))
    self.m_BtnYaoQing:subscribeEvent("Clicked", Familychengyuandialog.OnYaoQingBtnHandler, self)
    -- 分组
    self.m_ChengyuanGroup = CEGUI.toMultiColumnList(winMgr:getWindow("familychengyuandialog/familychengyuandialogMember"))
    self.m_ApplyGroup = CEGUI.toMultiColumnList(winMgr:getWindow("familychengyuandialog/Back2/shenqing"))
    self.m_EventGroup = CEGUI.toMultiColumnList(winMgr:getWindow("familychengyuandialog/Back2/shijian"))
    self.m_ClearButton:subscribeEvent("Clicked", Familychengyuandialog.OnClearButtonHandler, self)
    self.m_RefreshListButton:subscribeEvent("Clicked", Familychengyuandialog.OnRefreshListButtonHandler, self)
    self.m_FamilyListBtn:subscribeEvent("Clicked", Familychengyuandialog.OnClickfamilychengyuandialogListBtn, self)
    self:retTip()
    self.m_TabButton1:setSelected(true)

    self:RefreshQunFa()
    self:RefreshAutoRecvVisible()
    self:RefreshYaoQingVisible() -- 刷新“公会邀请”是否显示
    self:RefreshAutoRecvState()
    self:InitTitle()
    SetPositionOfWindowWithLabelbp(self:GetWindow())
    local datamanager = require "logic.faction.factiondatamanager"
    if datamanager then
        if datamanager.m_FactionTips then
            self.m_TipImage2:setVisible(datamanager.m_FactionTips[1] == 1)
        end
    end
end

-------------------------------------------------------------------------------------------------------

-- 选择自动接收申请人的等级
function Familychengyuandialog:onLevelClicked(args)
	if NumKeyboardDlg.getInstanceNotCreate() then
		NumKeyboardDlg.getInstanceNotCreate():SetVisible(true) --保持键盘在最上面
		return
	end
	
	local dlg = NumKeyboardDlg.getInstanceAndShow()
	if dlg then
		dlg:setTriggerBtn(self.m_AutoRecv_Level)
		dlg:setMaxValue(149)
		dlg:setInputChangeCallFunc(Familychengyuandialog.onNumInputChanged, self)
		dlg:setCloseCallFunc(Familychengyuandialog.onNumInputClose, self)
		
		local p = self.m_AutoRecv_Level:GetScreenPos()
		SetPositionOffset(dlg:GetWindow(), p.x+30, p.y-10, 0.5, 1)
	end
end

-- 等级输入发生变化的回调
function Familychengyuandialog:onNumInputChanged(num)
	if num < 1 then
        self.m_AutoRecv_Level:setText(1)
        self.m_AutoRecvLevel = 1
    else
        self.m_AutoRecv_Level:setText(num)
        self.m_AutoRecvLevel = num
	end
end

-- 等级输入完成的回调
function Familychengyuandialog:onNumInputClose()
    local send = require "protodef.fire.pb.clan.copenautojoinclan":new()
    send.autostate = self.m_AutoRecvMode
    send.requestlevel = self.m_AutoRecvLevel
    require "manager.luaprotocolmanager":send(send)
end

-------------------------------------------------------------------------------------------------------

-- 刷新“自动接收申请人”是否显示
function Familychengyuandialog:RefreshAutoRecvVisible()
    if not self.m_FactionData then
        return
    end
    local MyZhiwu = self.m_FactionData.GetMyZhiWuInfor()
    if not MyZhiwu then
        return
    end
    self.m_AutoRecv:setVisible(MyZhiwu.isrecvxuetu == 1 and self.m_Mode == 2)
    self.m_Level_Bg:setVisible(MyZhiwu.isrecvxuetu == 1 and self.m_Mode == 2)
    self.m_Desc:setVisible(MyZhiwu.isrecvxuetu == 1 and self.m_Mode == 2)
end

-- 刷新“自动接收申请人”的状态
function Familychengyuandialog:RefreshAutoRecvState()
    if not self.m_FactionData then
        return
    end
    self.m_AutoRecvMode = self.m_FactionData.autostate
    self.m_AutoRecvLevel = self.m_FactionData.requestlevel
    if self.m_AutoRecv then
        self.m_AutoRecv:setSelected(self.m_AutoRecvMode == 1)
    end
    if self.m_AutoRecv_Level then
        self.m_AutoRecv_Level:setText(self.m_AutoRecvLevel)
    end
end

-- 检测“自动接收申请人”状态的改变
function Familychengyuandialog:AutoRecvStateChanged(args)
    if not self.m_FactionData then
        return
    end
    local MyZhiwu = self.m_FactionData.GetMyZhiWuInfor()
    if not MyZhiwu or MyZhiwu.id == -1 then
        return
    end
    if MyZhiwu.isrecvxuetu ~= 1 then
        return
    end

    local send = require "protodef.fire.pb.clan.copenautojoinclan":new()
    send.autostate = self.m_AutoRecvMode == 1 and 0 or 1
    send.requestlevel = self.m_AutoRecvLevel
    require "manager.luaprotocolmanager":send(send)
end

-- 刷新“公会邀请”是否显示
function Familychengyuandialog:RefreshYaoQingVisible()
    local infor = self.m_FactionData.GetMyZhiWuInfor()
    if infor then
        self.m_BtnYaoQing:setEnabled(infor.yaoqing == 1)
    end
end

function Familychengyuandialog:ResetSortShow(CurSort)
    self.m_CurSort = CurSort
    if self.m_CurSort ~= self.m_LastSort then
        self.BtnDengjiUp:setVisible(false)
        self.BtnDengjiDown:setVisible(false)
        self.chengyuanup:setVisible(false)
        self.chengyuandown:setVisible(false)
        self.m_BtnZhiyeUp:setVisible(false)
        self.m_BtnZhiyeDown:setVisible(false)
        self.m_ZhiWuUp:setVisible(false)
        self.m_ZhiWuDown:setVisible(false)
        self.m_BenZhouGongXianUp:setVisible(false)
        self.m_BenZhouGongXianDown:setVisible(false)
        self.m_XianYouGongXianUp:setVisible(false)
        self.m_XianYouGongXianDown:setVisible(false)
        self.m_LiShiGongXianUp:setVisible(false)
        self.m_LiShiGongXianDown:setVisible(false)
        self.m_BenZhouYuanZhuUp:setVisible(false)
        self.m_BenZhouYuanZhuDown:setVisible(false)
        self.m_LiShiYuanZhuUp:setVisible(false)
        self.m_LiShiYuanZhuDown:setVisible(false)
        self.m_BenLunJingSaiUp:setVisible(false)
        self.m_BenLunJingSaiDown:setVisible(false)
        self.m_LiShiJingSaiUp:setVisible(false)
        self.m_LiShiJingSaiDown:setVisible(false)
        self.m_RuHuiUp:setVisible(false)
        self.m_RuHuiDown:setVisible(false)
        self.m_LiXianUp:setVisible(false)
        self.m_LiXianDown:setVisible(false)
    end
    self.m_LastSort = self.m_CurSort
end

function Familychengyuandialog:ResetShenqingSortShow(CurShenqingSort)
    self.m_CurShenqingSort = CurShenqingSort
    if self.m_CurShenqingSort ~= self.m_LastShenqingSort then
        self.shenqingnameup:setVisible(false)
        self.shenqingnamedown:setVisible(false)
        self.shenqinglevelup:setVisible(false)
        self.shenqingleveldown:setVisible(false)
        self.shenqingzhiyeup:setVisible(false)
        self.shenqingzhiyedown:setVisible(false)
        self.shenqingidup:setVisible(false)
        self.shenqingiddown:setVisible(false)
		self.shenqingFightvalueup:setVisible(false)
        self.shenqingFightvaluedown:setVisible(false)
    end
    self.m_LastShenqingSort = self.m_CurShenqingSort
end


 
-- （成员列表排序）按离线时间排序
function Familychengyuandialog:Sort14(args)
    self:ResetSortShow(14)
    self.m_Sort14Type = -1 * self.m_Sort14Type
    self.m_FightValueUp:setVisible(self.m_Sort14Type == 1)
    self.m_FightValueDown:setVisible(self.m_Sort14Type == -1)
    if self.m_Sort14Type == 0 then
        return
    end
    -- 刷新
    local datamanager = require "logic.faction.factiondatamanager"
    datamanager.SortByFightValue(self.m_Sort14Type)
    self:RefreshMemberListView()
end


-- （成员列表排序）按离线时间排序
function Familychengyuandialog:Sort13(args)
    self:ResetSortShow(13)
    self.m_Sort13Type = -1 * self.m_Sort13Type
    self.m_LiXianUp:setVisible(self.m_Sort13Type == 1)
    self.m_LiXianDown:setVisible(self.m_Sort13Type == -1)
    if self.m_Sort13Type == 0 then
        return
    end
    -- 刷新
    local datamanager = require "logic.faction.factiondatamanager"
    datamanager.SortByLiXian(self.m_Sort13Type)
    self:RefreshMemberListView()
end
-- （成员列表排序）按入会时间排序
function Familychengyuandialog:Sort12(args)
    self:ResetSortShow(12)
    self.m_Sort12Type = -1 * self.m_Sort12Type
    self.m_RuHuiUp:setVisible(self.m_Sort12Type == 1)
    self.m_RuHuiDown:setVisible(self.m_Sort12Type == -1)
    if self.m_Sort12Type == 0 then
        return
    end
    -- 刷新
    local datamanager = require "logic.faction.factiondatamanager"
    datamanager.SortByRuHui(self.m_Sort12Type)
    self:RefreshMemberListView()
end
-- （成员列表排序）按参加公会战次数 排序  
function Familychengyuandialog:Sort11(args)
    self:ResetSortShow(11)
    self.m_Sort11Type = -1 * self.m_Sort11Type
    self.m_LiShiJingSaiUp:setVisible(self.m_Sort11Type == 1)
    self.m_LiShiJingSaiDown:setVisible(self.m_Sort11Type == -1)
    if self.m_Sort11Type == 0 then
        return
    end
    -- 刷新
    local datamanager = require "logic.faction.factiondatamanager"
    datamanager.SortByLiShiJingSai(self.m_Sort11Type)
    self:RefreshMemberListView()
end
-- （成员列表排序）按参加公会副本次数排序
function Familychengyuandialog:Sort10(args)
    self:ResetSortShow(10)
    self.m_Sort10Type = -1 * self.m_Sort10Type
    self.m_BenLunJingSaiUp:setVisible(self.m_Sort10Type == 1)
    self.m_BenLunJingSaiDown:setVisible(self.m_Sort10Type == -1)
    if self.m_Sort10Type == 0 then
        return
    end
    -- 刷新
    local datamanager = require "logic.faction.factiondatamanager"
    datamanager.SortByBenLunJingSai(self.m_Sort10Type)
    self:RefreshMemberListView()
end
-- （成员列表排序）按历史援助排序
function Familychengyuandialog:Sort9(args)
    self:ResetSortShow(9)
    self.m_Sort9Type = -1 * self.m_Sort9Type
    self.m_LiShiYuanZhuUp:setVisible(self.m_Sort9Type == 1)
    self.m_LiShiYuanZhuDown:setVisible(self.m_Sort9Type == -1)
    if self.m_Sort9Type == 0 then
        return
    end
    -- 刷新
    local datamanager = require "logic.faction.factiondatamanager"
    datamanager.SortByLiShiYuanZhu(self.m_Sort9Type)
    self:RefreshMemberListView()
end
-- （成员列表排序）按本周援助排序
function Familychengyuandialog:Sort8(args)
    self:ResetSortShow(8)
    self.m_Sort8Type = -1 * self.m_Sort8Type
    self.m_BenZhouYuanZhuUp:setVisible(self.m_Sort8Type == 1)
    self.m_BenZhouYuanZhuDown:setVisible(self.m_Sort8Type == -1)
    if self.m_Sort8Type == 0 then
        return
    end
    -- 刷新
    local datamanager = require "logic.faction.factiondatamanager"
    datamanager.SortByBenZhouYuanZhu(self.m_Sort8Type)
    self:RefreshMemberListView()
end
-- （成员列表排序）按历史贡献排序
function Familychengyuandialog:Sort7(args)
    self:ResetSortShow(7)
    self.m_Sort7Type = -1 * self.m_Sort7Type
    self.m_LiShiGongXianUp:setVisible(self.m_Sort7Type == 1)
    self.m_LiShiGongXianDown:setVisible(self.m_Sort7Type == -1)
    if self.m_Sort7Type == 0 then
        return
    end
    -- 刷新
    local datamanager = require "logic.faction.factiondatamanager"
    datamanager.SortByXianYouGongXian(self.m_Sort7Type)
    self:RefreshMemberListView()
end
-- （成员列表排序）按本周贡献排序
function Familychengyuandialog:Sort6(args)
    self:ResetSortShow(6)
    self.m_Sort6Type = -1 * self.m_Sort6Type
    self.m_XianYouGongXianUp:setVisible(self.m_Sort6Type == 1)
    self.m_XianYouGongXianDown:setVisible(self.m_Sort6Type == -1)
    if self.m_Sort6Type == 0 then
        return
    end
    -- 刷新
    local datamanager = require "logic.faction.factiondatamanager"
    datamanager.SortByBenZhouGongXian(self.m_Sort6Type)
    self:RefreshMemberListView()
end
-- （成员列表排序）按上周贡献排序
function Familychengyuandialog:Sort5(args)
    self:ResetSortShow(5)
    self.m_Sort5Type = -1 * self.m_Sort5Type
    self.m_BenZhouGongXianUp:setVisible(self.m_Sort5Type == 1)
    self.m_BenZhouGongXianDown:setVisible(self.m_Sort5Type == -1)
    if self.m_Sort5Type == 0 then
        return
    end
    -- 刷新
    local datamanager = require "logic.faction.factiondatamanager"
    datamanager.SortByShangZhouGongXian(self.m_Sort5Type)
    self:RefreshMemberListView()
end
-- （成员列表排序）按职务排序
function Familychengyuandialog:Sort4(args)
    self:ResetSortShow(4)
    self.m_Sort4Type = -1 * self.m_Sort4Type
    self.m_ZhiWuUp:setVisible(self.m_Sort4Type == 1)
    self.m_ZhiWuDown:setVisible(self.m_Sort4Type == -1)
    if self.m_Sort4Type == 0 then
        return
    end
    -- 刷新
    local datamanager = require "logic.faction.factiondatamanager"
    datamanager.SortByZhiWu(self.m_Sort4Type)
    self:RefreshMemberListView()
end
-- （成员列表排序）按职业排序
function Familychengyuandialog:Sort3(args)
    self:ResetSortShow(3)
    self.m_Sort3Type = -1 * self.m_Sort3Type
    self.m_BtnZhiyeUp:setVisible(self.m_Sort3Type == 1)
    self.m_BtnZhiyeDown:setVisible(self.m_Sort3Type == -1)
    if self.m_Sort3Type == 0 then
        return
    end
    -- 刷新
    local datamanager = require "logic.faction.factiondatamanager"
    datamanager.SortByZhiYe(self.m_Sort3Type)
    self:RefreshMemberListView()
end
-- （成员列表排序）按等级排序
function Familychengyuandialog:Sort2(args)
    self:ResetSortShow(2)
    self.m_Sort2Type = -1 * self.m_Sort2Type
    self.BtnDengjiUp:setVisible(self.m_Sort2Type == 1)
    self.BtnDengjiDown:setVisible(self.m_Sort2Type == -1)
    if self.m_Sort2Type == 0 then
        return
    end
    -- 刷新
    local datamanager = require "logic.faction.factiondatamanager"
    datamanager.SortByLevel(self.m_Sort2Type)
    self:RefreshMemberListView()
end
-- （成员列表排序）按公会成员排序
function Familychengyuandialog:Sort1(args)
    self:ResetSortShow(1)
    self.m_Sort1Type = -1 * self.m_Sort1Type
    self.chengyuanup:setVisible(self.m_Sort1Type == 1)
    self.chengyuandown:setVisible(self.m_Sort1Type == -1)
    if self.m_Sort1Type == 0 then
        return
    end
    -- 刷新
    local datamanager = require "logic.faction.factiondatamanager"
    datamanager.SortByID(self.m_Sort1Type)
    self:RefreshMemberListView()
end


-- （申请列表排序）按名称排序
function Familychengyuandialog:ShenqingSort1(args)
    self:ResetShenqingSortShow(1)
    self.m_ShenqingSort1Type = -1 * self.m_ShenqingSort1Type
    self.shenqingnameup:setVisible(self.m_ShenqingSort1Type == 1)
    self.shenqingnamedown:setVisible(self.m_ShenqingSort1Type == -1)
    if self.m_ShenqingSort1Type == 0 then
        return
    end
    -- 刷新
    local datamanager = require "logic.faction.factiondatamanager"
    datamanager.ShenqingSortByID(self.m_ShenqingSort1Type)
    self:RefreshApplyListListView()
end

-- （申请列表排序）按等级排序
function Familychengyuandialog:ShenqingSort2(args)
    self:ResetShenqingSortShow(2)
    self.m_ShenqingSort2Type = -1 * self.m_ShenqingSort2Type
    self.shenqinglevelup:setVisible(self.m_ShenqingSort2Type == 1)
    self.shenqingleveldown:setVisible(self.m_ShenqingSort2Type == -1)
    if self.m_ShenqingSort2Type == 0 then
        return
    end
    -- 刷新
    local datamanager = require "logic.faction.factiondatamanager"
    datamanager.ShenqingSortByLevel(self.m_ShenqingSort2Type)
    self:RefreshApplyListListView()
end

-- （申请列表排序）按职业排序
function Familychengyuandialog:ShenqingSort3(args)
    self:ResetShenqingSortShow(3)
    self.m_ShenqingSort3Type = -1 * self.m_ShenqingSort3Type
    self.shenqingzhiyeup:setVisible(self.m_ShenqingSort3Type == 1)
    self.shenqingzhiyedown:setVisible(self.m_ShenqingSort3Type == -1)
    if self.m_ShenqingSort3Type == 0 then
        return
    end
    -- 刷新
    local datamanager = require "logic.faction.factiondatamanager"
    datamanager.ShenqingSortByZhiYe(self.m_ShenqingSort3Type)
    self:RefreshApplyListListView()
end

-- （申请列表排序）按ID排序
function Familychengyuandialog:ShenqingSort4(args)
    self:ResetShenqingSortShow(4)
    self.m_ShenqingSort4Type = -1 * self.m_ShenqingSort4Type
    self.shenqingidup:setVisible(self.m_ShenqingSort4Type == 1)
    self.shenqingiddown:setVisible(self.m_ShenqingSort4Type == -1)
    if self.m_ShenqingSort4Type == 0 then
        return
    end
    -- 刷新
    local datamanager = require "logic.faction.factiondatamanager"
    datamanager.ShenqingSortByID(self.m_ShenqingSort4Type)
    self:RefreshApplyListListView()
end

-- （申请列表排序）按综合战力排序
function Familychengyuandialog:ShenqingSort5(args)
    self:ResetShenqingSortShow(5)
    self.m_ShenqingSort5Type = -1 * self.m_ShenqingSort5Type
    self.shenqingFightvalueup:setVisible(self.m_ShenqingSort5Type == 1)
    self.shenqingFightvaluedown:setVisible(self.m_ShenqingSort5Type == -1)
    if self.m_ShenqingSort5Type == 0 then
        return
    end
    -- 刷新
    local datamanager = require "logic.faction.factiondatamanager"
    datamanager.ShenqingSortByFightvalue(self.m_ShenqingSort5Type)
    self:RefreshApplyListListView()
end



-- 刷新群发消息按钮权限显示
function Familychengyuandialog:RefreshQunFa()
    local infor = self.m_FactionData.GetMyZhiWuInfor()
    if infor and infor.id ~= -1 then
        self.m_SendAllButton:setEnabled(infor.qunfa == 1)
    end
end

-- 弹劾会长
function Familychengyuandialog:OnClickTanHeBtn(args)
    local datamanager = require "logic.faction.factiondatamanager"
    datamanager.m_bClickToShowImpeachUI = true
    datamanager.RequestImpeach(0)
end

-- 界面说名
function Familychengyuandialog:OnClickShuoMing(args)
    if not self.m_FactionData then
        return
    end
    self.tips1 = require "logic.workshop.tips1"
    local strTitle = MHSD_UTILS.get_resstring(11285)
    local strContent = MHSD_UTILS.get_resstring(11176)
    local roleid = gGetDataManager():GetMainCharacterID()
    local roleInfor = self.m_FactionData.getMember(roleid)
    local money = self.m_FactionData.GetMyDongJieMoney()
    strContent = string.gsub(strContent, "%$parameter1%$", math.floor(money))
    local dlg = self.tips1.getInstanceAndShow(strContent, strTitle)
    local winMgr = CEGUI.WindowManager:getSingleton()

    self.bg = winMgr:getWindow("tips1")
    self.richBox = CEGUI.toRichEditbox(winMgr:getWindow("tips1/RichEditbox"))
    self.bg:setWidth(CEGUI.UDim(0, 900))
    self.richBox:setWidth(CEGUI.UDim(0, 880))
    self.bg:setHeight(CEGUI.UDim(0, 580))
    self.richBox:setHeight(CEGUI.UDim(0, 630))
    SetPositionXOffset(dlg.title_st, 450, 0.5)

    SetPositionScreenCenter(self.bg)
end

-- 刷新title
function Familychengyuandialog:TitleApplyer()
    local len = #(self.m_FactionData.m_ApplyerList)
    self.m_TitleApplyer:setVisible(len ~= 0)
end

-- 标题初始化
function Familychengyuandialog:InitTitle()
    self.m_Title_1_1:setVisible(false)
    self.m_Title_1_2:setVisible(false)
    self.m_Title_1_3:setVisible(false)
    self.m_Title_1_4:setVisible(false)
    self.m_Title_1_5:setVisible(false)
    self.m_Title_1_6:setVisible(false)

    self.m_Title_2_1:setVisible(false)
    self.m_Title_2_2:setVisible(false)
    self.m_Title_2_3:setVisible(false)
    self.m_Title_2_4:setVisible(false)
    self.m_Title_2_5:setVisible(false)
    self.m_Title_2_6:setVisible(false)
	self.m_Title_3_1:setVisible(false)
end

-- 刷新标题
function Familychengyuandialog:RefreshTitle(Mode)
    self.m_Title_1_1:setVisible(Mode == 1)
    self.m_Title_1_2:setVisible(Mode == 1)
    self.m_Title_1_3:setVisible(Mode == 1)
    self.m_Title_1_4:setVisible(Mode == 1)
    self.m_Title_1_5:setVisible(Mode == 1)
    self.m_Title_1_6:setVisible(Mode == 1)

    self.m_Title_2_1:setVisible(Mode == 2)
    self.m_Title_2_2:setVisible(Mode == 2)
    self.m_Title_2_3:setVisible(Mode == 2)
    self.m_Title_2_4:setVisible(Mode == 2)
    self.m_Title_2_5:setVisible(Mode == 2)
    self.m_Title_2_6:setVisible(Mode == 2)
	self.m_Title_3_1:setVisible(Mode == 3)
end

-- 点击清除列表按钮
function Familychengyuandialog:OnClearButtonHandler(args)
    local send = require "protodef.fire.pb.clan.cclearapplylist":new()
    require "manager.luaprotocolmanager":send(send)
end

-- 刷新列表回调
function Familychengyuandialog:OnRefreshListButtonHandler(args)
    local p = require "protodef.fire.pb.clan.crequestapplylist":new()
    require "manager.luaprotocolmanager":send(p)
end
-- ColumnList头改变
-- 1,2 state
function Familychengyuandialog:MultiColumnListHeaderChanged(args)
    if args == 0 then

    elseif args == 1 then

    end
end
-- 申请列表提示显隐性
function Familychengyuandialog:ApplyListTipsVisible(visible)
    self.m_PersonImage:setVisible(visible)
    self.m_ApplyTips:setVisible(visible)
end
-- 切换按钮回调
function Familychengyuandialog:SwitchButtonClicked(args)
    if self.m_SwitchMode == 1 then
        self.m_SwitchMode = 2
	elseif self.m_SwitchMode == 2 then
	    if  self.m_Switchbutton1:isVisible() then
			self.m_SwitchMode = 3		
		else
			self.m_SwitchMode = 1
		end 
    elseif self.m_SwitchMode == 3 then
        self.m_SwitchMode = 2
    end
    self:SetSwitchbuttonState(self.m_SwitchMode)
    -- 刷新成员列表cell Mode
    self:ReFreshSwitchMode()
end

-- 点击公会邀请
function Familychengyuandialog:OnYaoQingBtnHandler(args)
    require("logic.family.familyyaoqingdialog").getInstanceAndShow()
   -- self.DestroyDialog(true)
end

-- 刷新左右按钮模式
function Familychengyuandialog:ReFreshSwitchMode()
    if self.m_Entrys then
        for _, v in pairs(self.m_Entrys.visibleCells) do
            if v then
                v:SetMode(self.m_SwitchMode)
            end
        end
    end
end
-- 成员列表左右切换按钮(1 → 2 ← 3 不显示)
function Familychengyuandialog:SetSwitchbuttonState(state)
    if state == 1 then
        self.m_Switchbutton1:setVisible(true)
        self.m_Switchbutton2:setVisible(false)
        self:MultiColumnListHeaderChanged(state)
    elseif state == 2 then
	    if  self.m_Switchbutton1:isVisible() then
			self.m_Switchbutton1:setVisible(true)
			self.m_Switchbutton2:setVisible(false)
		else
			self.m_Switchbutton1:setVisible(false)
			self.m_Switchbutton2:setVisible(true)
		end 
        self:MultiColumnListHeaderChanged(state)	
	elseif state == 3 then
        self.m_Switchbutton1:setVisible(false)
        self.m_Switchbutton2:setVisible(true)
        self:MultiColumnListHeaderChanged(state)	
    else
        self.m_Switchbutton1:setVisible(false)
        self.m_Switchbutton2:setVisible(false)
    end
    -- 刷新title
    self:RefreshTitle(state)
end

-- 刷新职位
-- id 角色ID
-- pos 职务
function Familychengyuandialog:RefreshPosition(id, pos)
    if self.m_Entrys then
        for _, v in pairs(self.m_Entrys.visibleCells) do
            if v.m_ID == id then
                local conf = BeanConfigManager.getInstance():GetTableByName("clan.cfactionposition"):getRecorder(pos)
                if conf then
                    v.m_ZhiWu:setText(conf.posname)
                end
            end
        end
    end
end

--------------------------------------------------------------------------------------------------------------
-- 成员列表
--------------------------------------------------------------------------------------------------------------

-- 刷新成员列表
function Familychengyuandialog:RefreshMemberListView()
    if self.m_ChengyuanGroup then
        self.m_ChengyuanGroup:setVisible(true)
    end
    local len = #(self.m_FactionData.members)
    if not self.m_Entrys then

        if self.m_FactionData then

            if self.m_Entrys then

            else
                local s = self.m_ChengyuanGroup:getPixelSize()
                self.m_Entrys = TableView.create(self.m_ChengyuanGroup)
                self.m_Entrys:setViewSize(1000, 480)
                self.m_Entrys:setPosition(0, 51)
                self.m_Entrys:setDataSourceFunc(self, Familychengyuandialog.tableViewGetCellAtIndex)

            end
        end
    end
    self.m_Entrys:setCellCountAndSize(len, 550, 45)
    self.m_Entrys:reloadData()
    self:ReFreshSwitchMode()
end

function Familychengyuandialog:tableViewGetCellAtIndex(tableView, idx, cell)
    if idx == nil then
        return
    end
    if tableView == nil then
        return
    end
    idx = idx + 1
    if not cell then
        cell = Familychengyuandiacell.CreateNewDlg(tableView.container, tableView:genCellPrefix())
        cell.m_Btn:setGroupID(56)
        cell.m_Btn:subscribeEvent("MouseButtonUp", Familychengyuandialog.HandleMemberEntryCellClicked, self)
        cell.m_Btn:subscribeEvent("MouseButtonDown", Familychengyuandialog.HandleMemberEntryCellClicked2, self)
    end
    -- 获得成员cell数据,此数据必定要从缓存中娶
    local SingleMem = self.m_FactionData.members[idx]
    -- 设置成员cell信息
    cell:SetInfor(SingleMem)
    if idx % 2 == 1 then
        cell.m_Btn:SetStateImageExtendID(1)
    else
        cell.m_Btn:SetStateImageExtendID(0)
    end
    cell.m_Btn:setID(idx)
    cell:SetMode(self.m_SwitchMode)
    return cell
end

-- 成员列表项触摸事件回调（触摸按下）
function Familychengyuandialog:HandleMemberEntryCellClicked2(args)
    local e = CEGUI.toWindowEventArgs(args)
    self.m_SelectButtonBtn = e.window:getID()
    self:ResetClick1()
end

-- 成员列表项触摸事件回调（触摸抬起）
function Familychengyuandialog:HandleMemberEntryCellClicked(args)
    local e = CEGUI.toWindowEventArgs(args)
    self.m_SelectEntryIndex = e.window:getID()
    if self.m_SelectButtonBtn ~= nil then
        if self.m_SelectButtonBtn ~= self.m_SelectEntryIndex then
            return
        end
    end
    self.m_Entrys.visibleCells[self.m_SelectEntryIndex - 1].m_Btn:setSelected(true)
    self.SingleMember = self.m_FactionData.members[self.m_SelectEntryIndex]
    local data = gGetDataManager():GetMainCharacterData()
    if self.SingleMember.roleid == data.roleid then
        return
    end
    -- 发送申请组队信息
    if self.SingleMember.roleid == nil then
        return
    end
    if Familycaidan.getInstanceNotCreate() then
        return
    end
    local send = require "protodef.fire.pb.team.crequesthaveteam":new()
    send.roleid = self.SingleMember.roleid
    require "manager.luaprotocolmanager":send(send)
end

--------------------------------------------------------------------------------------------------------------

-- 点击cell上的聊天选项按钮
function Familychengyuandialog:OnClickCellChatBtn(args)
    local e = CEGUI.toWindowEventArgs(args)
    local memberid = e.window:getID()
    if not memberid then
        return true
    end
    if gGetFriendsManager() then
        gGetFriendsManager():RequestSetChatRoleID(memberid)
    end
end

-- 重置所有点选
function Familychengyuandialog:ResetClick1()
    self.m_SelectEntryIndex = 0
    if not self.m_Entrys then
        return
    end
    if not self.m_Entrys.visibleCells then
        return
    end
    for _, v in pairs(self.m_Entrys.visibleCells) do
        v.m_Btn:setSelected(false)
    end
end

function Familychengyuandialog:ResetClick2()
    self.m_SelectEntryIndex2 = 0
    if not self.m_Entrys2 then
        return
    end
    if not self.m_Entrys2.visibleCells then
        return
    end
    for _, v in pairs(self.m_Entrys2.visibleCells) do
        v.m_Btn:setSelected(false)
    end
end

-- 刷新时间列表
function Familychengyuandialog:RefreshEventListView()
    if self.m_EventGroup then
        self.m_EventGroup:setVisible(true)
    end
    local len = #(self.m_FactionData.m_FamilyEventList)
    if not self.m_Entrys3 then
        if self.m_FactionData then

            if self.m_Entrys3 then

            else
                local s = self.m_EventGroup:getPixelSize()
                self.m_Entrys3 = TableView.create(self.m_EventGroup)
                self.m_Entrys3:setViewSize(1000, 480)
                self.m_Entrys3:setPosition(0, 2)
                self.m_Entrys3:setDataSourceFunc(self, Familychengyuandialog.tableViewGetCellAtIndex3)
            end
        end
    end
    self.m_Entrys3:setCellCountAndSize(len, 1000, 45)
    self.m_Entrys3:reloadData()
end
-- 创建控件
function Familychengyuandialog:tableViewGetCellAtIndex3(tableView, idx, cell)
    idx = idx + 1
    if not cell then
        cell = Familyshijiandiacell.CreateNewDlg(tableView.container)
        cell.m_Btn:subscribeEvent("MouseButtonDown", Familychengyuandialog.OnClickCellShiJianDown, self)
        cell.m_Btn:subscribeEvent("MouseButtonUp", Familychengyuandialog.OnClickCellShiJian, self)
    end
    cell.m_Btn:setGroupID(36)
    if idx % 2 == 1 then
        cell.m_Btn:SetStateImageExtendID(1)
    else
        cell.m_Btn:SetStateImageExtendID(0)
    end
    cell.m_Btn:setID(idx)
    cell.m_Btn:EnableClickAni(false)
    local infor = self.m_FactionData.m_FamilyEventList[idx]
    cell:SetInfor(infor)
    return cell
end
function Familychengyuandialog:OnClickCellShiJianDown(args)
    self:ResetClicked3()
end
function Familychengyuandialog:OnClickCellShiJian(args)
    local e = CEGUI.toWindowEventArgs(args)
    local idx = e.window:getID()
    local temp = self.m_FactionData.m_FamilyEventList[idx]
    if temp then
        if temp.eventvalue ~= 0 then
            local send = require "protodef.fire.pb.clan.crequestroleinfo":new()
            send.roleid = temp.eventvalue
            send.moduletype = 1
            require "manager.luaprotocolmanager":send(send)
        end
    end
end

function Familychengyuandialog:ResetClicked3()
    if not self.m_Entrys3 then
        return
    end
    for k, v in pairs(self.m_Entrys3.visibleCells) do
        if v then
            v.m_Btn:setSelected(false)
        end
    end
end
-- 刷新申请列表
function Familychengyuandialog:RefreshApplyListListView()
    if self.m_ApplyGroup then
        self.m_ApplyGroup:setVisible(true)
    end
    local len = #(self.m_FactionData.m_ApplyerList)
    if not self.m_Entrys2 then
        if self.m_FactionData then

            if self.m_Entrys2 then

            else
                local s = self.m_ApplyGroup:getPixelSize()
                self.m_Entrys2 = TableView.create(self.m_ApplyGroup)
                self.m_Entrys2:setViewSize(994, 370)
                self.m_Entrys2:setPosition(1, 51)
                self.m_Entrys2:setDataSourceFunc(self, Familychengyuandialog.tableViewGetCellAtIndex2)
            end
        end
    end
    self.m_Entrys2:setCellCountAndSize(len, 774, 58)
    self.m_Entrys2:reloadData()
    -- 刷新Title显示
    self:TitleApplyer()
end
function Familychengyuandialog:tableViewGetCellAtIndex2(tableView, idx, cell)
    idx = idx + 1
    if not cell then
        cell = Familyshenqingdiacell.CreateNewDlg(tableView.container)

        cell.m_Btn:subscribeEvent("MouseButtonUp", Familychengyuandialog.HandleApplyerEntryCellClicked, self)
        cell.m_YesBtn:subscribeEvent("Clicked", Familychengyuandialog.YesBtnHandler, self)
        cell.m_NoBtn:subscribeEvent("Clicked", Familychengyuandialog.NoBtnHandler, self)
        cell.m_ChatBtn:subscribeEvent("Clicked", Familychengyuandialog.OnClickCellChatBtn, self)
    end
    cell.m_Btn:setGroupID(35)
    cell.m_Btn:setID(idx)
    if idx % 2 == 1 then
        cell.m_Btn:SetStateImageExtendID(1)
    else
        cell.m_Btn:SetStateImageExtendID(0)
    end
    local SingleApply = self.m_FactionData.m_ApplyerList[idx]
    cell:SetInfor(SingleApply)
    return cell
end
-- 点击回调
function Familychengyuandialog:HandleApplyerEntryCellClicked(args)
    self:ResetClick2()
    local e = CEGUI.toWindowEventArgs(args)
    self.m_SelectEntryIndex2 = e.window:getID()

    self.m_Entrys2.visibleCells[self.m_SelectEntryIndex2 - 1].m_Btn:setSelected(true)
end

-- 点击接受申请请求
function Familychengyuandialog:YesBtnHandler(args)
    if self.m_FactionData then
        local zhiwudetails = self.m_FactionData.GetMyZhiWuInfor()
        if zhiwudetails.clearapplylist == 0 and zhiwudetails.id ~= -1 then
            local strContent = MHSD_UTILS.get_msgtipstring(150127)
            GetCTipsManager():AddMessageTip(strContent)
            return
        end
    end
    local e = CEGUI.toWindowEventArgs(args)
    self.roleID = e.window:getID()
    local send = require "protodef.fire.pb.clan.cacceptorrefuseapply":new()
    send.applyroleid = self.roleID
    send.accept = 1
    require "manager.luaprotocolmanager":send(send)
end
-- 点击取消申请请求
function Familychengyuandialog:NoBtnHandler(args)
    if self.m_FactionData then
        local zhiwudetails = self.m_FactionData.GetMyZhiWuInfor()
        if zhiwudetails.clearapplylist == 0 and zhiwudetails.id ~= -1 then
            local strContent = MHSD_UTILS.get_msgtipstring(150127)
            GetCTipsManager():AddMessageTip(strContent)
            return
        end
    end
    local e = CEGUI.toWindowEventArgs(args)
    self.roleID = e.window:getID()
    local send = require "protodef.fire.pb.clan.cacceptorrefuseapply":new()
    send.applyroleid = self.roleID
    send.accept = 0
    require "manager.luaprotocolmanager":send(send)
end
-- 群发消息
function Familychengyuandialog:OnSendAllBtnHandler(args)
    Familyqunfaxiaoxidialog.getInstanceAndShow()
end

function Familychengyuandialog:HandleSelectChanged(args)
    local selectID = CEGUI.toWindowEventArgs(args).window:getID()
    self.m_ChengyuanGroup:setVisible(false)
    self.m_ApplyGroup:setVisible(false)
    self.m_EventGroup:setVisible(false)
    self.m_UIHelpButton:setVisible(false)
    self.m_RefreshListButton:setVisible(false)
    self.m_ClearButton:setVisible(false)
    self.m_SendAllButton:setVisible(false)
    self.m_FamilyListBtn:setVisible(false)
    self.m_LeaveFamilyBtn:setVisible(false)
    self.m_TanHeBtn:setVisible(false)
    self.m_AutoRecv:setVisible(false)
    self.m_Level_Bg:setVisible(false)
    self.m_Desc:setVisible(false)
    if selectID == 1 then
        local p = require "protodef.fire.pb.clan.crefreshmemberlist":new()
        require "manager.luaprotocolmanager":send(p)
    elseif selectID == 2 then
        -- 发送申请“申请入会列表”信息
        local p = require "protodef.fire.pb.clan.crequestapplylist":new()
        require "manager.luaprotocolmanager":send(p)
        self.m_SwitchMode = 1
    elseif selectID == 3 then
        -- 发送申请事件请求
        local p = require "protodef.fire.pb.clan.crequesteventinfo":new()
        require "manager.luaprotocolmanager":send(p)
    end
    self.m_Mode = selectID
end

function Familychengyuandialog:retTip()
    for i = 1, 3 do
        self:setTip(i, false)
    end
end

-- 设置tip显隐性
function Familychengyuandialog:setTip(index, visible)
    if index == 1 then self.m_TipImage1:setVisible(visible) end
    if index == 2 then self.m_TipImage2:setVisible(visible) end
    if index == 3 then self.m_TipImage3:setVisible(visible) end
end

-- 刷新成员后重新排序
function Familychengyuandialog:reSort()
    local datamanager = require "logic.faction.factiondatamanager"
    if self.m_CurSort == 1 then
        datamanager.SortByID(self.m_Sort1Type)
    elseif self.m_CurSort == 2 then
        datamanager.SortByLevel(self.m_Sort2Type)
    elseif self.m_CurSort == 3 then
		datamanager.SortByZhiYe(self.m_Sort3Type)
    elseif self.m_CurSort == 4 then
		datamanager.SortByZhiWu(self.m_Sort4Type)
    elseif self.m_CurSort == 5 then
		datamanager.SortByShangZhouGongXian(self.m_Sort5Type)
    elseif self.m_CurSort == 6 then
		datamanager.SortByBenZhouGongXian(self.m_Sort6Type)
    elseif self.m_CurSort == 7 then
		datamanager.SortByXianYouGongXian(self.m_Sort7Type)
    elseif self.m_CurSort == 8 then
		datamanager.SortByBenZhouYuanZhu(self.m_Sort8Type)
    elseif self.m_CurSort == 9 then
		datamanager.SortByLiShiYuanZhu(self.m_Sort9Type)
    elseif self.m_CurSort == 10 then
		datamanager.SortByBenLunJingSai(self.m_Sort10Type)
    elseif self.m_CurSort == 11 then
		datamanager.SortByLiShiJingSai(self.m_Sort11Type)
    elseif self.m_CurSort == 12 then
		datamanager.SortByRuHui(self.m_Sort12Type)
    elseif self.m_CurSort == 13 then
		datamanager.SortByLiXian(self.m_Sort13Type)
    elseif self.m_CurSort == 14 then
        datamanager.SortByFightValue(self.m_Sort14Type)
    else
        datamanager.SortByLiXian(-1)
    end
end

function Familychengyuandialog:RefreshTab1()
    if self.m_Mode ~= 1 then
        return
    end
    self.m_UIHelpButton:setVisible(true)
    self.m_SendAllButton:setVisible(true)
    self.m_ChengyuanGroup:setVisible(true)
    self.m_FamilyListBtn:setVisible(true)
    self.m_LeaveFamilyBtn:setVisible(true)
    self.m_TanHeBtn:setVisible(true)
    self:RefreshMemberListView()
    self:SetSwitchbuttonState(1)
end

-- 刷新申请者UI
function Familychengyuandialog:RefreshTab2()
    if self.m_Mode ~= 2 then
        return
    end
    self:ResetClick2()
    -- 刷新是否提示显隐性
    if self.m_FactionData then
        local len = #self.m_FactionData.m_ApplyerList
        self:ApplyListTipsVisible((len == 0 and self.m_Mode == 2))
    end

    self.m_RefreshListButton:setVisible(true)
    local infor = self.m_FactionData.GetMyZhiWuInfor()
    if infor and infor.id ~= -1 then
        self.m_ClearButton:setEnabled(infor.clearapplylist == 1)
    end
    self.m_ClearButton:setVisible(true)
    self.m_Level_Bg:setVisible(true)
    self.m_Desc:setVisible(true)
    self.m_ApplyGroup:setVisible(true)
    self.m_AutoRecv:setVisible(true)
    self.m_LeaveFamilyBtn:setVisible(false)
    self.m_TanHeBtn:setVisible(false)
    if self.m_MemberCollection then
        self.m_MemberCollection:setVisible(false)
    end
    self:SetSwitchbuttonState(4)
    self:RefreshApplyListListView()
    self:RefreshAutoRecvVisible()
    self:RefreshYaoQingVisible() -- 刷新“公会邀请”是否显示
end

function Familychengyuandialog:RefreshTab3()
    if self.m_Mode ~= 3 then
        return
    end
    self.m_EventGroup:setVisible(true)
    self.m_LeaveFamilyBtn:setVisible(false)
    self.m_TanHeBtn:setVisible(false)
    self:SetSwitchbuttonState(4)
    self:ResetClicked3()
    self:RefreshEventListView()
end
-- 离开公会按钮
function Familychengyuandialog:LeaveFamilyBtnClicked(args)
    local strContent = MHSD_UTILS.get_msgtipstring(150140)
    local strContent2 = MHSD_UTILS.get_msgtipstring(160181)
    if strContent and strContent2 then
        local mapId = gGetScene():GetMapID()
        -- 在公会场景内
        if mapId == 1613 then
            MessageBoxSimple.show(strContent2, Familychengyuandialog.SpecialFamilychengyuandialogLeaveFamilyCallback, self, nil, nil, nil, nil)
        else
            MessageBoxSimple.show(strContent, Familychengyuandialog.FamilychengyuandialogLeaveFamilyCallback, self, nil, nil, nil, nil)
        end
    end
end
-- 确定离开公会场景吗
function Familychengyuandialog.SpecialFamilychengyuandialogLeaveFamilyCallback(args)
    local strContent = MHSD_UTILS.get_msgtipstring(150140)
    MessageBoxSimple.show(strContent, Familychengyuandialog.FamilychengyuandialogLeaveFamilyCallback, self, nil, nil, nil, nil)
end
-- 点击离开公会确认回调
function Familychengyuandialog:FamilychengyuandialogLeaveFamilyCallback(args)
    local datamanager = require "logic.faction.factiondatamanager"
    -- 是会长
    if datamanager:GetMyZhiWu() == 1 and datamanager.GetPersonNumber() ~= 1 and(not datamanager.IsExistFuHuiZhang()) then
        local strContent = MHSD_UTILS.get_msgtipstring(150141)
        GetCTipsManager():AddMessageTip(strContent)
    else
        -- 发送脱离公会
        local send = require "protodef.fire.pb.clan.cleaveclan":new()
        require "manager.luaprotocolmanager":send(send)
    end
end
-- 点击工会列表
function Familychengyuandialog:OnClickfamilychengyuandialogListBtn(args)
    Familyjiarudialog.getInstanceAndShow()
   -- self.DestroyDialog(true)
end
return Familychengyuandialog
