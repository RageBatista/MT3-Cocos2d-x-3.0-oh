require "utils.commonutil"

local single = require "logic.singletondialog"

local CCreateRoleDialog = {}
setmetatable(CCreateRoleDialog, single)
CCreateRoleDialog.__index = CCreateRoleDialog

local SCHOOL_BTN_NUM = 3
local ROLE_NUM = 17
local MOVE_LENGTH = 300
local FINAL_SCALE = 0.5

--enumCreateRoleMovingState
local eMovingLeft = 0
local eMovingRight = 1
local eStop = 2
----------
local MOVE_DURATION = 0.5
local randomNameColdTime = 0.5

local RE_CONNECT_DUR = 5 --s

local ZhaoMuVisibleRole = 1

-- ���ﶯ��
local ACT_NUM = 5
local ACT_TYPE = { eActionRun, eActionAttack, eActionRun, eActionMagic1, eActionStand }
local ACT_REPEAT = { 3, 1, 3, 1, 3 }
local ACT_DIR = { 4, 3, 4, 3, 4 }	--3:XPDIR_BOTTOMRIGHT  4:XPDIR_BOTTOM  5:XPDIR_BOTTOMLEFT
local _instance
function CCreateRoleDialog.new()
	local self = {}
	setmetatable(self, CCreateRoleDialog)
	function self.GetLayoutFileName()
		--return "charactercreateddlg.layout"
		return "createroledialog.layout"
	end
	require "logic.dialog".OnCreate(self)
	self.m_iSelectedSchool = 0
	self.roleSeqNum = os.time()%(ROLE_NUM-1)+1
	self.m_frandomNameColdTime = 0
	self.m_bChangedPic = false
	self.m_fSchoolInfoShowTime = 0
	self.m_bShowSchoolInfo = false
	self.m_eDialogType = {}
	self.m_eMovingState = eStop
    self.m_bIsClickStart = false

    self.m_RecruitCode = ""
	
	local winMgr = CEGUI.WindowManager:getSingleton()
	--����
    self.backImg = winMgr:getWindow("CharacterCreatedDlg/Back")

	--�������
    self.m_pRandomName = CEGUI.toPushButton(winMgr:getWindow("CharacterCreatedDlg/Back/Tube"))
    self.m_pRandomName:subscribeEvent("Clicked", CCreateRoleDialog.HandleRandomClicked,self)
    
	--��������
	self.nameBack = winMgr:getWindow("CharacterCreatedDlg/Back/NameBack")
    self.m_pNameEdit = CEGUI.toEditbox(winMgr:getWindow("CharacterCreatedDlg/Back/NameBack/Name"))
    self.m_pNameEdit:SetShieldSpace(true)
	--self.m_pNameEdit:setMaxTextLength(8)
	self.m_pNameEdit:SetFrameEnabled(false)
	--self.m_pNameEdit:SetNormalColourRect(0xFF000000)
	self.m_pNameEdit:subscribeEvent("TextChanged", CCreateRoleDialog.OnTextChanged, self)
    self.m_pNameEdit:subscribeEvent("KeyboardTargetWndChanged", CCreateRoleDialog.HandleNameKeyboardTargetWndChanged, self)
    --��ļ��
    self.m_recruitCodeRich = CEGUI.toEditbox(winMgr:getWindow("CharacterCreatedDlg/Back/NameBack/Name1"))
    self.m_recruitCodeRich:subscribeEvent("KeyboardTargetWndChanged", CCreateRoleDialog.HandleCodeKeyboardTargetWndChanged, self)
    self.m_recruitCodeRich:SetShieldSpace(true)
    self.m_recruitCodeRich:SetFrameEnabled(false)
    self.m_recruitCodeRich:setMaxTextLength(30)
    self.m_recruitCodeHolder = winMgr:getWindow("CharacterCreatedDlg/Back/NameBack/placeholder1")
	--��½
    self.m_pFinishBtn = CEGUI.toPushButton(winMgr:getWindow("CharacterCreatedDlg/Back/OK"))
    self.m_pFinishBtn:subscribeEvent("Clicked", CCreateRoleDialog.HandleFinishBtnClicked,self)
    
	--����
    self.m_pReturnBtn = CEGUI.toPushButton(winMgr:getWindow("CharacterCreatedDlg/Back/return"))
    self.m_pReturnBtn:subscribeEvent("Clicked", CCreateRoleDialog.HandleReturnBtnClicked,self)
    local platform = require "config".CUR_3RD_PLATFORM

	--if platform ==  "app" or platform == "kuaiyong" then
    if platform == "kuaiyong" then
	    self.m_pReturnBtn:setVisible(false)
	end

	--���ҷ�ҳ
    self.m_pLeftBtn = CEGUI.toPushButton(winMgr:getWindow("CharacterCreatedDlg/left"))
    self.m_pLeftBtn:subscribeEvent("Clicked", CCreateRoleDialog.HandleLeftClicked,self)
    
    self.m_pRightBtn = CEGUI.toPushButton(winMgr:getWindow("CharacterCreatedDlg/right"))
    self.m_pRightBtn:subscribeEvent("Clicked", CCreateRoleDialog.HandleRightClicked,self)
	
    self.m_zhantie = CEGUI.toPushButton(winMgr:getWindow("CharacterCreatedDlg/back1/zhaomu/zhantie"))
    self.m_zhantie:subscribeEvent("Clicked", CCreateRoleDialog.HandleZhantieClicked,self)

    self.m_zhaomu = winMgr:getWindow("CharacterCreatedDlg/back1/zhaomu")
    if ZhaoMuVisibleRole == 0 then
        self.m_zhaomu:setVisible(false)
    end
	--ְҵ��ť
    self.m_pSchoolBtn = {}
	self.oriSchoolBtnPos = {}
    for i = 0 , SCHOOL_BTN_NUM - 1 do
        self.m_pSchoolBtn[i] = CEGUI.toPushButton(winMgr:getWindow("CharacterCreatedDlg/Back/school"..(i + 1)))
        self.m_pSchoolBtn[i]:subscribeEvent("Clicked", CCreateRoleDialog.HandleSchoolSelected,self)
		self.m_pSchoolBtn[i]:setID(i)
		gGetGameUIManager():AddUIEffect(self.m_pSchoolBtn[i], "geffect/ui/mt_xuanzhong/xuanzhong", true)

		local p = self.m_pSchoolBtn[i]:getXPosition()
		self.oriSchoolBtnPos[i] = { scale = p.scale, offset = p.offset }
    end
	self.selectSchoolTip = winMgr:getWindow("CharacterCreatedDlg/Back/diban/selectschooltip")
    
	self:refreshSchoolIconAndName()

	--��ͷ��/����
    self.headImage = winMgr:getWindow('CharacterCreatedDlg/touxiang')
	self.diwenBg = winMgr:getWindow('CharacterCreatedDlg/Back/diban/diwenbg')
    self.diwenImage = winMgr:getWindow('CharacterCreatedDlg/Back/diban/diwen')
    self.diwenBg:setVisible(false)

--	self.schoolSelectbox = winMgr:getWindow("CharacterCreatedDlg/back1/schoolselectbox")
--	self.schoolSelectbox:setVisible(false) --Ĭ�ϲ�ѡ��ְҵ

	--ְҵ����
	self.schoolTip = CEGUI.toRichEditbox(winMgr:getWindow("CharacterCreatedDlg/Back/diban/schooltips"))

	--ְҵ��
    self.schoolName = winMgr:getWindow("CharacterCreatedDlg/back/schoolname")
	self.enSchoolName = winMgr:getWindow("CharacterCreatedDlg/back/enSchoolName")

	--��ɫ��
    self.roleName = winMgr:getWindow("CharacterCreatedDlg/back/rolename")
    self.enRoleName = winMgr:getWindow("CharacterCreatedDlg/back/enRoleName")

    self.schoolTip:SetLineSpace(17)
    self.schoolTip:setVisible(false)
	self.schoolName:setVisible(false)
	self.enSchoolName:setVisible(false)

    --�������������
    self.topFlag = winMgr:getWindow("CharacterCreatedDlg/back1/dikuang1")

	--С����
	self.smallFlag = winMgr:getWindow("CharacterCreatedDlg/back1/qizi1")
	self.schoolNameOnFlag = winMgr:getWindow("CharacterCreatedDlg/back1/qizi1/schoolname")
	self.smallFlag:setVisible(false)

	--����
	self.flagBg = winMgr:getWindow("CharacterCreatedDlg/Back/flagbg")

	--����
	self.smokeBg = winMgr:getWindow("CharacterCreatedDlg/Back/flagbg/smoke")
	local s = self.smokeBg:getPixelSize()
	local flagSmoke = gGetGameUIManager():AddUIEffect(self.smokeBg, "geffect/ui/mt_shengqishi/mt_shengqishi", true, s.width*0.5, s.height)
	
	--ҳ��
    self.pageDots = {}
    for i = 1, ROLE_NUM do
        self.pageDots[i] = winMgr:getWindow("CharacterCreatedDlg/light"..i)
        self.pageDots[i]:setVisible(true)
    end
	
	self.roleback = winMgr:getWindow("CharacterCreatedDlg/Back/roleback")
	self.rolebackSize = self.roleback:getPixelSize()
	self.rolePos = {}
	self.rolePos.center = self.rolebackSize.width*0.5
	self.MOVE_LENGTH = 500--rolebackSize.width*0.5

	self.rolePos.left = self.rolePos.center-self.MOVE_LENGTH
	self.rolePos.right = self.rolePos.center+self.MOVE_LENGTH

	--��ɫ����
	self.role1 = {}
	self.role1.img = winMgr:getWindow("CharacterCreatedDlg/rolearea/roleimg1")
    self.role1.img:setAlpha(0)

    self.roleEffectBg = winMgr:getWindow("CharacterCreatedDlg/Back/roleback/1")

	self.role2 = {}
	self.role2.img = winMgr:getWindow("CharacterCreatedDlg/rolearea/roleimg2")
	self.role2.img:setAlpha(0)

    self.role1IsOnFront = true
	
    --self.rolePos.y = self.backImg:getPixelSize().height-10

    self:changeRolePosY()
    self.roleImgHeight = self.backImg:getPixelSize().height-55
	
    
    self.m_pPane = winMgr:getWindow("CharacterCreatedDlg/slideregion")
    self.m_pPane:subscribeEvent("MouseMove", CCreateRoleDialog.HandleMouseMoved, self)
	self.m_pPane:subscribeEvent("MouseButtonDown", CCreateRoleDialog.HandleMouseDown, self)
    self.m_pPane:subscribeEvent("MouseButtonUp", CCreateRoleDialog.HandleMouseUp, self)
	
	self.nameplaceholder = winMgr:getWindow("CharacterCreatedDlg/Back/NameBack/placeholder")

	local roleconfig = BeanConfigManager.getInstance():GetTableByName("role.createroleconfig"):getRecorder(self.roleSeqNum)
	self.selectedSex = roleconfig.sex
    --self.role1.img:setProperty("Image", roleconfig.roleimage)
    --(unuse)  self:resizeImageByHeight(self.role1.img, roleconfig.roleimage, self.roleImgHeight)
    self:setImageOriginSize(self.role1.img, roleconfig.roleimage)
    SetPositionOffset(self.role1.img, self.rolePos.center, self.rolePos.y, 0.5, 1)
    if roleconfig.effectOnTop ~= "" then
        gGetGameUIManager():AddUIEffect(self.role1.img, roleconfig.effectOnTop, true)
    end
	if roleconfig.flageffect ~= "" then
		local flagEffect = gGetGameUIManager():AddUIEffect(self.flagBg, roleconfig.flageffect, true, 110, 490)
		if flagEffect then flagEffect:SetScale(0.65) end
	end

    self.topFlag:setProperty("Image", roleconfig.topflag)
    
    self:refreshCurrentRole()
	    
    self.m_pMainFrame:subscribeEvent("WindowUpdate", CCreateRoleDialog.HandleWindowUpdate, self)

	self.useCustomerName = true
	self.m_frandomNameColdTime = randomNameColdTime
	self.m_pRandomName:setEnabled(true)
	
    self.m_eDragState = eStop

	if gGetLoginManager() and gGetLoginManager():isShortcutLaunched() then
		gGetLoginManager():setShortcutItemHandled(true);
	end
    _instance = self
	return self
end

function CCreateRoleDialog.setZhaoMuOpenStatus(status)
    ZhaoMuVisibleRole = status
end

function CCreateRoleDialog:HandleZhantieClicked(e)
    local manager = gGetGameUIManager()
    if manager and  manager:getClipboard() then
        self.m_recruitCodeRich:setText(manager:getClipboard())
    end
end
function CCreateRoleDialog:RefreshPageDots(pathPrefix)
    for i = 1, ROLE_NUM do
        if (self.roleSeqNum == i) then
            self.pageDots[i]:setProperty("Image", pathPrefix ..i.."_".. 1) --"set:character image:character_img_deng0")
        else
            self.pageDots[i]:setProperty("Image", pathPrefix ..i.."_".. 2) --"set:character image:character_img_deng1")
        end
    end
end

function CCreateRoleDialog:setBtnStartState(btnState)
    self.m_bIsClickStart = btnState
end

--����ְҵ��ť״̬
function CCreateRoleDialog:SetSchoolSelected(pWnd)
	if self.selectedSchoolBtnIdx == pWnd:getID() then
        return
    end

    if not self.schoolTip:isVisible() then
        self.schoolTip:setVisible(true)
		self.schoolName:setVisible(true)
		self.enSchoolName:setVisible(true)
    end

	if not self.smallFlag:isVisible() then
		self.smallFlag:setVisible(true)
	end
	local x = pWnd:getXPosition():asAbsolute(pWnd:getParent():getPixelSize().width)+pWnd:getPixelSize().width*0.5-self.smallFlag:getPixelSize().width*0.5
	self.smallFlag:setXPosition(CEGUI.UDim(0, x))

    local config = BeanConfigManager.getInstance():GetTableByName("role.createroleconfig"):getRecorder(self.roleSeqNum)
    if self.selectedSchoolBtnIdx then
        local img = (self.selectedSchoolBtnIdx==0 and config.schoolimg1 or
					(self.selectedSchoolBtnIdx==1 and config.schoolimg2 or
					(self.selectedSchoolBtnIdx==2 and config.schoolimg3))) .. "1"
        self.m_pSchoolBtn[self.selectedSchoolBtnIdx]:setProperty("NormalImage", img)
        self.m_pSchoolBtn[self.selectedSchoolBtnIdx]:setProperty("PushedImage", img)
    end
    self.selectedSchoolBtnIdx = pWnd:getID()
    local img = (self.selectedSchoolBtnIdx==0 and config.schoolimg1 or
				(self.selectedSchoolBtnIdx==1 and config.schoolimg2 or
				(self.selectedSchoolBtnIdx==2 and config.schoolimg3))) .. "2"
    self.m_pSchoolBtn[self.selectedSchoolBtnIdx]:setProperty("NormalImage", img)
    self.m_pSchoolBtn[self.selectedSchoolBtnIdx]:setProperty("PushedImage", img)
	
	self.smallFlag:setProperty("Image", config.smallflag)

    self.topFlag:setProperty("Image", config.topflag)

	local centerpos = pWnd:GetScreenPosOfCenter()
	local parentpos = pWnd:getParent():GetScreenPos()

    if not self.diwenBg:isVisible() then
        self.diwenBg:setVisible(true)
    end
	local diwenimg = (self.selectedSchoolBtnIdx==0 and config.diwenimg1 or
					 (self.selectedSchoolBtnIdx==1 and config.diwenimg2 or
					 (self.selectedSchoolBtnIdx==2 and config.diwenimg3 or "")))
    self.diwenImage:setProperty("Image", diwenimg)
    --self:resizeImageByHeight(self.diwenImage, diwenimg, self.diwenImage:getPixelSize().height)
    --self.diwenImage:setXPosition(CEGUI.UDim(0,self.backImg:getPixelSize().width-self.diwenImage:getPixelSize().width))

    if (self.m_iSelectedSchool ~= config.schools[self.selectedSchoolBtnIdx]) then
        self.m_iSelectedSchool = config.schools[self.selectedSchoolBtnIdx]
        self.m_bShowSchoolInfo = true
        self.m_fSchoolInfoShowTime = 0
				
		local schoolconf = BeanConfigManager.getInstance():GetTableByName("role.schoolinfo"):getRecorder(self.m_iSelectedSchool)
		if schoolconf then
			local colour = string.match(schoolconf.englishName, "(%[.*%]).*") or ""
            self.schoolName:setText(colour .. schoolconf.name)
			self.schoolNameOnFlag:setText(schoolconf.name)
            self.enSchoolName:setText(schoolconf.englishName)
			--self.schoolTip:setText(schoolconf.describe)
			local str = "<T t='" .. schoolconf.describe .. "' c='FF00FF00'/>"
			self.schoolTip:Clear()
			self.schoolTip:AppendParseText(CEGUI.String(str))
			self.schoolTip:Refresh()
		end
    end    
    local weaponid = self.selectedSchoolBtnIdx;
    if not weaponid then        weaponid = 0    end
	self.sprite:SetSpriteComponent(eSprite_Weapon, config.weapons[weaponid])
end

function CCreateRoleDialog:GiveName(givename)
    self.nameplaceholder:setVisible(false)
	self.m_pNameEdit:setText(givename)
	self.m_pNameEdit:setCaratIndex(string.len(self.m_pNameEdit:getText()))
	self.useCustomerName = false
end

function CCreateRoleDialog:checkLoad()
	if not gCommon.selectedServerKey then
		return
	end
	gGetLoginManager():ClearConnections()
	local serverkey = gCommon.selectedServerKey
	local host = gGetLoginManager():GetHost()
    local port = gGetLoginManager():GetPort()
	gGetLoginManager():CheckLoad(host, port, serverkey)
end

function CCreateRoleDialog:SetServerLoad(serverKey, serverLoad)
	if not gCommon.selectedServerKey then
		return
	end
	if serverKey == gCommon.selectedServerKey and serverLoad > 0 then
		self.disconnect = false
		self:createConnection()
	end
end

function CCreateRoleDialog:createConnection()
    local account = gGetLoginManager():GetAccount()
    local key = gGetLoginManager():GetPassword()
	local servername = gGetLoginManager():GetSelectServer()
	local area = gGetLoginManager():GetSelectArea()
    local host = gGetLoginManager():GetHost()
    local port = gGetLoginManager():GetPort()
    local serverid = gGetLoginManager():getServerID()
    local channelid = gGetLoginManager():GetChannelId();
	gGetLoginManager():ClearConnections()
    gGetGameApplication():CreateConnection(account, key, host, port, true, servername, area, serverid, channelid)
    if gGetNetConnection() then
        gGetNetConnection():setSecurityType(FireNet.enumSECURITY_ARCFOUR, FireNet.enumSECURITY_ARCFOUR)
    end
end

function CCreateRoleDialog:HandleRandomClicked(e)
    --�����������
	if self.disconnect then
		gGetMessageManager():AddConfirmBox(eConfirmOK, MHSD_UTILS.get_resstring(1135),	--���ӷ�����ʧ��
            MessageManager.HandleDefaultCancelEvent, MessageManager,
            MessageManager.HandleDefaultCancelEvent, MessageManager
        )
        return
	end
    if not DeviceData:sIsNetworkConnected() then
        gGetMessageManager():AddConfirmBox(eConfirmOK, MHSD_UTILS.get_resstring(11310),	--������粻����������ȥ���һ�°ɣ�
            MessageManager.HandleDefaultCancelEvent, MessageManager,
            MessageManager.HandleDefaultCancelEvent, MessageManager
        )
        return
    end

    local givemename = require "protodef.fire.pb.crequestname":new()
    
    local config = BeanConfigManager.getInstance():GetTableByName("role.createroleconfig"):getRecorder(self.roleSeqNum)
    local RoleSex = require "protodef.rpcgen.fire.pb.rolesex":new()
    if (config.sex == 1) then
        givemename.sex = RoleSex.MALE
    elseif (config.sex == 2) then
        givemename.sex = RoleSex.FEMALE
    end

    require "manager.luaprotocolmanager":send(givemename)
    self.m_frandomNameColdTime = 0
    self.m_pRandomName:setEnabled(false)
    
    return true;
end

--�������
function CCreateRoleDialog:HandleFinishBtnClicked(e)
    if self.m_bIsClickStart == true then
        GetCTipsManager():AddMessageTipById(162169) -- ����������
        return true
    end

	if (self.m_iSelectedSchool == 0) then
		GetCTipsManager():AddMessageTipById(160020) --��ѡ��ְҵ
		return true
	end
    
	local editname = self.m_pNameEdit:getText()
	if (not editname or string.len(editname) == 0) then
        --�㻹ûΪ��Ľ�ɫȡ���أ������Ľ�ɫȡһ�����������ְɡ�
		GetCTipsManager():AddMessageTip(GameTable.message.GetCMessageTipTableInstance():getRecorder(141317).msg,false)
		return true;
	end
	
	--��ɫ�����޶���2-7�����֣�4-14��Ӣ������
	local cNum, eNum = GetCharCount(self.m_pNameEdit:getText())
	print('name char count:', cNum, eNum)
	local num = cNum*2+eNum
	if num < 4 or num > 14 then
		GetCTipsManager():AddMessageTipById(140403)	
		return
	end

    --�����������
	if self.disconnect then
		gGetMessageManager():AddConfirmBox(eConfirmOK, MHSD_UTILS.get_resstring(1135),	--���ӷ�����ʧ��
            MessageManager.HandleDefaultCancelEvent, MessageManager,
            MessageManager.HandleDefaultCancelEvent, MessageManager
        )
        return
	end
    if not DeviceData:sIsNetworkConnected() then
        self.offline = true
        gGetMessageManager():AddConfirmBox(eConfirmOK, MHSD_UTILS.get_resstring(11310),	--������粻����������ȥ���һ�°ɣ�
            MessageManager.HandleDefaultCancelEvent, MessageManager,
            MessageManager.HandleDefaultCancelEvent, MessageManager
        )
        return
    end
	self:CheckRecruit()
    --self.m_bIsClickStart = true
	return true;
end
function CCreateRoleDialog:CheckRecruit()
    local text = self.m_recruitCodeRich:getText()
    if text == "" then
        self.m_RecruitCode = ""
        --_instance:CreateRoleProcess()
        gGetMessageManager():AddConfirmBox(eConfirmOK, MHSD_UTILS.get_resstring(11711),MessageManager.HandleDefaultCancelEvent, MessageManager,MessageManager.HandleDefaultCancelEvent, MessageManager)
		return
    else
        -- self.m_RecruitCode = text
        -- local record = BeanConfigManager.getInstance():GetTableByName("friends.crecruitpath"):getRecorder(1)
        -- local strbuilder = StringBuilder:new()
        -- strbuilder:Set("parameter1", self.m_RecruitCode)
        -- local content = strbuilder:GetString(record.path3)
        -- strbuilder:delete()
        -- GetServerInfo():connetGetRecruitInfo(content,0)
        local Spaceprotocol = require("logic.space.spaceprotocol")
	    local nProtocolId = Spaceprotocol.eProId.getyqm
	    local strProtocolParam = tostring(nProtocolId)
	    local nHttpType = 0 
	    local nTimeout = Spaceprotocol.nTimeout
	    local key = gGetLoginManager():GetPassword()
	    local serverid = tostring(gGetLoginManager():getServerID())
	    gGetSpaceManager():SendRequest(strProtocolParam,GameTable.common.GetCCommonTableInstance():getRecorder(486).value.."/"..serverid.. "/"..text.."/"..Base64.Encode(key, string.len(key)),nHttpType,nTimeout)
	    self.m_bIsClickStart = true  
    end
end
function CCreateRoleDialog.CheckRecruitSuccess()
    if _instance then
        _instance:CreateRoleProcess()
    end

end
function CCreateRoleDialog:CreateRoleProcess()
    local editname = self.m_pNameEdit:getText()
	local CreateRoleCmd = require "protodef.fire.pb.ccreaterole":new()
	CreateRoleCmd.name = editname
	CreateRoleCmd.school = self.m_iSelectedSchool
	CreateRoleCmd.shape = self.roleSeqNum
    CreateRoleCmd.code = self.m_RecruitCode

	require "manager.luaprotocolmanager":send(CreateRoleCmd)
    print(">>>&&enter CCreateRole create >>> shape: "..tostring(self.roleSeqNum))

    if Config.MOBILE_ANDROID == 1 and Config.CUR_3RD_LOGIN_SUFFIX == "kuwo" then
        require "luaj"
        luaj.callStaticMethod("com.locojoy.mini.mt3.kuwo.PlatformKuwo", "roleCreated", {}, "()V")
    end
    if Config.MOBILE_ANDROID == 1 and Config.CUR_3RD_LOGIN_SUFFIX == "lngz" then
        require "luaj"
        luaj.callStaticMethod("com.locojoy.mini.mt3.longzhong.PlatformLongZhong", "createRole", {}, "()V")
    end

    GetServerInfo():connetCreateRoleInfo(gGetLoginManager():getServerID(), self.roleSeqNum)
	GetCTipsManager():clearMessages()
end
function CCreateRoleDialog.process(strData,vstrParam)
    local pJson_root = gGetSpaceManager():SpaceJson_create(strData)
    if not pJson_root then
        return
    end
    local Code = gGetSpaceManager():SpaceJson_getString(pJson_root,"code","")
    local Msg = tonumber(gGetSpaceManager():SpaceJson_getString(pJson_root,"msg",""))
    if (Code == "1")  then
         GetCTipsManager():AddMessageTipById(Msg)
		 require "logic.createroledialog":CheckRecruityqm()
    else
         GetCTipsManager():AddMessageTipById(Msg)
		 --require "logic.createroledialog":CheckRecruityqmfalse()
         require "logic.createroledialog":CheckRecruityqm()
		 return		 
    end
end
function CCreateRoleDialog.CheckRecruityqm()
    gGetMessageManager():CloseConfirmBox(eConfirmNormal, false)
    _instance.m_RecruitCode = ""
    _instance:CreateRoleProcess()
    return
end
function CCreateRoleDialog.CheckRecruityqmfalse()
    _instance.m_bIsClickStart = false
    return
end
function CCreateRoleDialog.CheckRecruitFail()
    if _instance then
        local function ClickYes(_instance, args)
            gGetMessageManager():CloseConfirmBox(eConfirmNormal, false)
            _instance.m_RecruitCode = ""
            _instance:CreateRoleProcess()
            return
        end
        local function ClickNo(_instance, args)
            _instance.m_bIsClickStart = false
            gGetMessageManager():CloseConfirmBox(eConfirmNormal, false)
            return
        end
        gGetMessageManager():AddConfirmBox(eConfirmNormal, MHSD_UTILS.get_msgtipstring(170050), ClickYes, 
        _instance, ClickNo, _instance,0,0,nil,MHSD_UTILS.get_resstring(2035),MHSD_UTILS.get_resstring(2036))
    end
end
function CCreateRoleDialog:HandleReturnBtnClicked(e)
	local trd_platform = require "config".TRD_PLATFORM
	if trd_platform==1 then
		MT3.ChannelManager:ChangeUserLogin()
	else
		SelectServerEntry.getInstanceAndShow()
	end
	if gGetLoginManager() then
		gGetLoginManager():Init()
	end
    local p = require("protodef.fire.pb.cuseroffline"):new()
	LuaProtocolManager:send(p)
	self:DestroyDialog()
end

function CCreateRoleDialog:DestroyDialog()
	if self._instance then
        if self.sprite then
            self.sprite:delete()
            self.sprite = nil
        end
        if self.spine then
            self.spine:delete()
            self.spine = nil
        end
		if self.spine2 then
			self.spine2:delete()
			self.spine2 = nil
		end
        if self.spriteBack then
            self.spriteBack:getGeometryBuffer():setRenderEffect(nil)
        end
        if self.role1 then
            gGetGameUIManager():RemoveUIEffect(self.role1.img)
        end
        if self.role2 then
            gGetGameUIManager():RemoveUIEffect(self.role2.img)
        end
        if self.flagBg then
            gGetGameUIManager():RemoveUIEffect(self.flagBg)
        end
		if self.smokeBg then
		    gGetGameUIManager():RemoveUIEffect(self.smokeBg)
		end
		if self.roleEffectBg then
		    gGetGameUIManager():RemoveUIEffect(self.roleEffectBg)
		end
		self:OnClose()
		getmetatable(self)._instance = nil
        _instance = nil
	end
end


function CCreateRoleDialog:HandleRightClicked(e)
    if self.m_eMovingState ~= eStop then
        return
    end
    if self.role1IsOnFront then
        self.role1, self.role2 = self.role2, self.role1
        self.role1IsOnFront = false
    end
    self.m_fMoveElapseTime = 0
    self.m_eMovingState = eMovingRight
    self.curRoleSeqNum = self.roleSeqNum

    do return end
    self.m_fMoveElapseTime = 0
    self.m_eMovingState = eMovingLeft
    self.m_bChangedPic = false
    
    return true
end

--������Ұ�ť
function CCreateRoleDialog:HandleLeftClicked(e)
    if self.m_eMovingState ~= eStop then
        return
    end
    if self.role1IsOnFront then
        self.role1, self.role2 = self.role2, self.role1
        self.role1IsOnFront = false
    end
    self.m_fMoveElapseTime = 0
    self.m_eMovingState = eMovingLeft
    self.curRoleSeqNum = self.roleSeqNum

    do return end
    self.m_fMoveElapseTime = 0
    self.m_eMovingState = eMovingRight
    self.m_bChangedPic = false
    
    return true
end

function CCreateRoleDialog:HandleSchoolSelected(e)
    local WndArgs = CEGUI.toWindowEventArgs(e)
    self:SetSchoolSelected(WndArgs.window)
	for i = 0 , SCHOOL_BTN_NUM - 1 do
		gGetGameUIManager():RemoveUIEffect(self.m_pSchoolBtn[i])
    end
	self.selectSchoolTip:setVisible(false)
    return true
end

--ˢ�µ�ǰ�����ϲ�չʾ�Ľ�ɫ��Ϣ
function CCreateRoleDialog:refreshCurrentRole()
    if self.roleSeqNum <= 0 or self.roleSeqNum > ROLE_NUM then
        return
    end

    local conf = BeanConfigManager.getInstance():GetTableByName("role.createroleconfig"):getRecorder(self.roleSeqNum)

    -- spine
    self:createSpineSprite()

    --school buttons
    self:refreshSchoolIconAndName()

    --sprite animation
    self:changeSpriteShape()

    --page dots
    self:RefreshPageDots(conf.pagedotimg)

    --backgroud image
    self.backImg:setProperty("Image", conf.bgimg)

    --top flag
    self.topFlag:setProperty("Image", conf.topflag)

    --head image
    self.headImage:setProperty("Image", conf.headimg)
    self:resizeImageByHeight(self.headImage, conf.headimg, self.headImage:getPixelSize().height)

    --left/right button
    self.m_pLeftBtn:setProperty("NormalImage", conf.leftbtnimg)
    self.m_pLeftBtn:setProperty("PushedImage", conf.leftbtnimg)
    self.m_pRightBtn:setProperty("NormalImage", conf.rightbtnimg)
    self.m_pRightBtn:setProperty("PushedImage", conf.rightbtnimg)

    --return button
    self.m_pReturnBtn:setProperty("NormalImage", conf.returnimg)
    self.m_pReturnBtn:setProperty("PushedImage", conf.returnimg)

    --finish button
    self.m_pFinishBtn:setProperty("NormalImage", conf.surebtnimg)
    self.m_pFinishBtn:setProperty("PushedImage", conf.surebtnimg)

	--role name
	local colour = string.match(conf.englishname, "(%[.*%]).*") or ""
	self.roleName:setText(colour .. conf.name)
	self.enRoleName:setText(conf.englishname)

	--flag effect
	if conf.flageffect ~= "" then
		local flagEffect = gGetGameUIManager():AddUIEffect(self.flagBg, conf.flageffect, true, 110, 700)
		--if flagEffect then flagEffect:SetScale(0.65) end
	end
end

function CCreateRoleDialog:countRoleSeqNum(isAdd)
    if isAdd then
        return self.roleSeqNum % ROLE_NUM + 1
    else
        return self.roleSeqNum==1 and ROLE_NUM or (self.roleSeqNum + ROLE_NUM - 1)%ROLE_NUM
    end
end

function CCreateRoleDialog:resizeImageByHeight(imgWnd, imagesetpath, height)
    height = height or imgWnd:getPixelSize().height
    local set, img = string.match(imagesetpath, "set:(.*) image:(.*)")
	if not set or not img then
		print("CCreateRoleDialog:resizeImageByHeight, imageset format error: " .. imagesetpath)
		return
	end
    local image = CEGUI.ImagesetManager:getSingleton():getImage(set, img)
    if not image then
		print("CCreateRoleDialog:resizeImageByHeight, " .. img .. " not defined in " .. set)
		return
	end
    local w = image:getWidth()
    local h = image:getHeight()
    imgWnd:setSize(CEGUI.UVector2(CEGUI.UDim(0,w*height/h), CEGUI.UDim(0,height)))
end

function CCreateRoleDialog:setImageOriginSize(imgWnd, imagesetpath)
    local set, img = string.match(imagesetpath, "set:(.*) image:(.*)")
	if not set or not img then
		print("CCreateRoleDialog:setImageOriginSize, imageset format error: " .. imagesetpath)
        print("wh")
        print(imagesetpath)
		return
	end
    local image =  CEGUI.ImagesetManager:getSingleton():getImage(set, img)
    if not image then
		print("CCreateRoleDialog:setImageOriginSize, " .. img .. " not defined in " .. set)
		return
	end
    local w = image:getWidth()
    local h = image:getHeight()
    imgWnd:setProperty("ImageSizeEnable", "True")
    imgWnd:setProperty("LimitWindowSize", "False")
    imgWnd:setSize(CEGUI.UVector2(CEGUI.UDim(0,w), CEGUI.UDim(0,h)))
    --print('image size:', w, h, imgWnd:getPixelSize().width, imgWnd:getPixelSize().height)
end

--���ϲ�����ͼ������x����Խ��չʾ�����ĵ�ʱ�л��²�����ͼƬ
function CCreateRoleDialog:isRoleChanged(roleImg, newPosX)
    return (roleImg:getXPosition().offset+roleImg:getPixelSize().width*0.5-self.rolePos.center)*(newPosX-self.rolePos.center) <= 0
end

function CCreateRoleDialog:changeRoleImage(roleImg, isToLeft)
    local nextRoleSeqNum = self:countRoleSeqNum(isToLeft)
    local conf = BeanConfigManager.getInstance():GetTableByName("role.createroleconfig"):getRecorder(nextRoleSeqNum)
    --roleImg:setProperty("Image", conf.roleimage)
    if nextRoleSeqNum == 2 then
        self.rolePos.y = self.backImg:getPixelSize().height + 15
    elseif nextRoleSeqNum == 4 then
        self.rolePos.y = self.backImg:getPixelSize().height   - 10
    elseif nextRoleSeqNum == 6 then
        self.rolePos.y = self.backImg:getPixelSize().height + 38
    else
        self.rolePos.y = self.backImg:getPixelSize().height - 10
    end
    self:setImageOriginSize(roleImg, conf.roleimage)
    SetPositionOffset(roleImg, self.rolePos.center, self.rolePos.y, 0.5, 1)
	
    gGetGameUIManager():RemoveUIEffect(roleImg)
    if conf.effectOnTop ~= "" then
        gGetGameUIManager():AddUIEffect(roleImg, conf.effectOnTop, true)
    end
end

function CCreateRoleDialog:setRole1XPosition(x1, isToLeft)

    local dis = x1 + self.role1.img:getPixelSize().width*0.5 - self.rolePos.center
    dis = math.min(dis, MOVE_LENGTH)
    local onleft = false
    if dis < 0 then
        onleft = true
        dis = -dis
    end

    local x2 = self.rolePos.center + (onleft and (MOVE_LENGTH - dis) or -(MOVE_LENGTH - dis)) - self.role2.img:getPixelSize().width*0.5

    self.roleEffectBg:setAlpha(255)
    --check whether need change role image
    if self.role1IsOnFront then
        if self:isRoleChanged(self.role1.img, x1+self.role1.img:getPixelSize().width*0.5) then
            self:changeRoleImage(self.role2.img, isToLeft)
        end
    elseif self:isRoleChanged(self.role2.img, x2+self.role2.img:getPixelSize().width*0.5) then
        self:changeRoleImage(self.role1.img, isToLeft)
    end

    local s = self.role1.img:getSize()
    self.role1.img:setXPosition(CEGUI.UDim(0,x1))
    self.role1.img:setSize(s)
    local pos = self.roleEffectBg:GetScreenPosOfCenter()
	local loc = Nuclear.NuclearPoint(x1,pos.y)
    if isToLeft then
        --self.spine:SetUILocation(loc)
    else
        loc = Nuclear.NuclearPoint(x1 + self.role2.img:getPixelSize().width, pos.y)
        --self.spine:SetUILocation(loc)
    end
    --role1
    --local scale = 1 - FINAL_SCALE * math.pow(dis/MOVE_LENGTH, 3)
    local scale = dis/MOVE_LENGTH*0.5+0.5;
    --local alpha1 = 1 - math.pow(dis/MOVE_LENGTH, 2)
    if scale > 1.0 then
        scale = 1.0
    end
    alpha1 = scale * 255;
    self.role1.img:setGeomScale(CEGUI.Vector3(scale, scale, 1))
    self.role1.img:setAlpha(alpha1)
	
	--self.spine:SetUIScale(scale)
	--self.spine:SetUIAlpha(alpha1)
    
    --role2
    dis = MOVE_LENGTH - dis
    s = self.role2.img:getSize()
    self.role2.img:setXPosition(CEGUI.UDim(0,x2))
    self.role2.img:setSize(s)
    if self.spine2 then
        local x3 = self.rolePos.center + (onleft and (MOVE_LENGTH - dis) or -(MOVE_LENGTH - dis))
        local loc2 = Nuclear.NuclearPoint(self.roleback:getPixelSize().width - x3,pos.y)
        self.spine2:SetUILocation(loc2)
    end
    --scale = 1 - FINAL_SCALE * math.pow(dis/MOVE_LENGTH, 3)
    scale = dis/MOVE_LENGTH*0.5+0.5;
    if scale > 1.0 then
        scale = 1.0
    end
    --local alpha2 = 1 - math.pow(dis/MOVE_LENGTH, 2)
    alpha2 = scale * 255;
    self.role2.img:setGeomScale(CEGUI.Vector3(scale, scale, 1))
    self.role2.img:setAlpha(alpha2)
    
    if self.spine2 then
        self.spine2:SetUIScale(scale)
        self.spine2:SetUIAlpha(alpha2)
    end
    
    local pageChanged = false
    if alpha1 > 0 then --change role
        if not self.role1IsOnFront then
            self.role1.img:moveToFront()
            self.role1IsOnFront = true
            pageChanged = true
        end
    else
        if self.role1IsOnFront then
            self.role2.img:moveToFront()
            self.role1IsOnFront = false
            pageChanged = true
        end
    end

    if self.m_eDragState == eMovingRight and isToLeft then
        pageChanged = true
    end

    if self.m_eDragState == eMovingLeft and not isToLeft then
        pageChanged = true
    end

    if isToLeft then
        self.m_eDragState = eMovingLeft
        if pageChanged then
            local newModelId = (isToLeft
							    and self.curRoleSeqNum % ROLE_NUM + 1
							    or (self.curRoleSeqNum==1 and ROLE_NUM or (self.curRoleSeqNum + ROLE_NUM - 1)%ROLE_NUM))
		    self.roleSeqNum = newModelId
            --nextRoleSeqNum
            self:refreshCurrentRole()
        end
    else
        self.m_eDragState = eMovingRight
        --self.roleSeqNum = self.curRoleSeqNum + 1
        if pageChanged then
            local newModelId = (isToLeft
							    and self.curRoleSeqNum % ROLE_NUM + 1
							    or (self.curRoleSeqNum==1 and ROLE_NUM or (self.curRoleSeqNum + ROLE_NUM - 1)%ROLE_NUM))
		    self.roleSeqNum = newModelId
            --nextRoleSeqNum
            self:refreshCurrentRole()
        end
    end
end

function CCreateRoleDialog:HandleMouseMoved(e)
	if not self.paneTouchDown then
		return
	end

	if self.m_eMovingState ~= eStop then
		return
	end

	if self.mouseMoved == false or self.mouseMoved == nil then
		self.moveOffset = self.rolePos.center
		self.role1, self.role2 = self.role2, self.role1
		self.role1IsOnFront = not self.role1IsOnFront
	end
	self.mouseMoved = true
	

	local moveEvent = CEGUI.toMouseEventArgs(e)
	local delta = moveEvent.moveDelta

	self.moveOffset = self.moveOffset + delta.x

	if self.moveOffset <= self.rolePos.center - self.role1.img:getPixelSize().width * 0.5 then
		self.moveOffset = self.rolePos.center - self.role1.img:getPixelSize().width * 0.5
	elseif self.moveOffset >= self.rolePos.center + self.role1.img:getPixelSize().width * 0.5 then
		self.moveOffset = self.rolePos.center + self.role1.img:getPixelSize().width * 0.5
	end

	if delta.x < 0 then
		self:setRole1XPosition(self.moveOffset, true)
	else
		self:setRole1XPosition(self.moveOffset - self.role1.img:getPixelSize().width, false)
	end

	self:HandleMouseUp(args)

	return true;
end

function CCreateRoleDialog:HandleMouseDown(args)
	self.paneTouchDown = true
    self.curRoleSeqNum = self.roleSeqNum
end

function CCreateRoleDialog:HandleMouseUp(args)
    if not self.mouseMoved or not self.paneTouchDown then
        return
    end

    self.mouseMoved = false
	self.paneTouchDown = false

    if not self.role1IsOnFront then
        self.role1, self.role2 = self.role2, self.role1
        self.role1IsOnFront = true
    end

    local delta = self.role1.img:getXPosition().offset + self.role1.img:getPixelSize().width*0.5 - self.rolePos.center
    if delta > 0 then
        self.m_eMovingState = eMovingLeft
    else
        self.m_eMovingState = eMovingRight
        delta = -delta
    end

    self.m_fMoveElapseTime = MOVE_DURATION * (1 - delta / MOVE_LENGTH)
end

function CCreateRoleDialog:refreshSchoolIconAndName()
	local visibleBtns = {}
	local conf = BeanConfigManager.getInstance():GetTableByName("role.createroleconfig"):getRecorder(self.roleSeqNum)
	if conf.schools[0] == 0 then
		self.m_pSchoolBtn[0]:setVisible(false)
	else
		table.insert(visibleBtns, self.m_pSchoolBtn[0])
		self.m_pSchoolBtn[0]:setVisible(true)
		self.m_pSchoolBtn[0]:setProperty("NormalImage", conf.schoolimg1 .. "1")
		self.m_pSchoolBtn[0]:setProperty("PushedImage", conf.schoolimg1 .. "1")
	end

	if conf.schools[1] == 0 then
		self.m_pSchoolBtn[1]:setVisible(false)
	else
		table.insert(visibleBtns, self.m_pSchoolBtn[1])
		self.m_pSchoolBtn[1]:setVisible(true)
		self.m_pSchoolBtn[1]:setProperty("NormalImage", conf.schoolimg2 .. "1")
		self.m_pSchoolBtn[1]:setProperty("PushedImage", conf.schoolimg2 .. "1")
	end

	if conf.schools[2] == 0 then
		self.m_pSchoolBtn[2]:setVisible(false)
	else
		table.insert(visibleBtns, self.m_pSchoolBtn[2])
		self.m_pSchoolBtn[2]:setVisible(true)
		self.m_pSchoolBtn[2]:setProperty("NormalImage", conf.schoolimg3 .. "1")
		self.m_pSchoolBtn[2]:setProperty("PushedImage", conf.schoolimg3 .. "1")
	end

	if #visibleBtns == 2 then
		local offset = self.m_pSchoolBtn[0]:getPixelSize().width*0.5
		local p = self.oriSchoolBtnPos[0]
		visibleBtns[1]:setXPosition(CEGUI.UDim(p.scale, p.offset+offset))
		p = self.oriSchoolBtnPos[2]
		visibleBtns[2]:setXPosition(CEGUI.UDim(p.scale, p.offset-offset))
	elseif #visibleBtns == 3 then
		local p = self.oriSchoolBtnPos[0]
		visibleBtns[1]:setXPosition(CEGUI.UDim(p.scale, p.offset))
		p = self.oriSchoolBtnPos[1]
		visibleBtns[2]:setXPosition(CEGUI.UDim(p.scale, p.offset))
		p = self.oriSchoolBtnPos[2]
		visibleBtns[3]:setXPosition(CEGUI.UDim(p.scale, p.offset))
	end
	
	if self.selectedSchoolBtnIdx then
		if not self.m_pSchoolBtn[self.selectedSchoolBtnIdx]:isVisible() then
			for i=0, SCHOOL_BTN_NUM do
				if self.m_pSchoolBtn[i]:isVisible() then
					self.selectedSchoolBtnIdx = i
					break
				end
			end
		end

		local btn = self.m_pSchoolBtn[self.selectedSchoolBtnIdx]
        self.selectedSchoolBtnIdx = nil
		self:SetSchoolSelected(btn)
	end
end

function CCreateRoleDialog:OnTextChanged(args)
	self.useCustomerName = true
	--self.nameBack:setText('')
end
function CCreateRoleDialog:HandleNameKeyboardTargetWndChanged(args)
    local wnd = CEGUI.toWindowEventArgs(args).window
    if wnd == self.m_pNameEdit then
        self.nameplaceholder:setVisible(false)
    else
        if self.m_pNameEdit:getText() == "" then
            self.nameplaceholder:setVisible(true)
        end
    end
end
function CCreateRoleDialog:HandleCodeKeyboardTargetWndChanged(args)
    local wnd = CEGUI.toWindowEventArgs(args).window
    if wnd == self.m_recruitCodeRich then
        self.m_recruitCodeHolder:setVisible(false)
    else
        if self.m_recruitCodeRich:getText() == "" then
            self.m_recruitCodeHolder:setVisible(true)
        end
    end
end
function CCreateRoleDialog:HandleWindowUpdate(e)

--    local text = self.m_pNameEdit:getText()
--    self.nameplaceholder:setVisible((text == "" and self.m_pNameEdit:hasInputFocus()))

--    text = self.m_recruitCodeRich:getText()
--    self.m_recruitCodeHolder:setVisible((text == "" and self.m_recruitCodeRich:hasInputFocus()))

	local updateArgs = CEGUI.toUpdateEventArgs(e)
	local elapsed = updateArgs.d_timeSinceLastFrame

    if self.disconnect then
        self.connectElapsed = self.connectElapsed + elapsed
        if self.connectElapsed >= RE_CONNECT_DUR then
            self.connectElapsed = 0
            self:checkLoad()
        end
    end
	
	--���ﶯ��
	if self.sprite then
		if self.actionelapsed == 0 then
			self.sprite:SetUIDirection(ACT_DIR[self.actionIdx])
			self.sprite:SetDefaultAction(ACT_TYPE[self.actionIdx])
			self.sprite:PlayAction(ACT_TYPE[self.actionIdx])
		end
		
		self.actionelapsed = self.actionelapsed+elapsed
		if self.actionelapsed*1000 >= self.sprite:GetCurActDuration() then
			self.actionelapsed = 0
			self.actionRepeatTimes = self.actionRepeatTimes+1
			if self.actionRepeatTimes == ACT_REPEAT[self.actionIdx] then
				self.actionRepeatTimes = 0
				self.actionIdx = (self.actionIdx==ACT_NUM and 1 or self.actionIdx+1)
			end
		end
	end
	
	
	--random name
	if (self.m_frandomNameColdTime < randomNameColdTime) then
        self.m_frandomNameColdTime = self.m_frandomNameColdTime + elapsed
        if (self.m_frandomNameColdTime >= randomNameColdTime) then
            self.m_pRandomName:setEnabled(true)
        end
    end
	
	if (self.m_eMovingState == eStop) then
        return true
    end

    --image move animate
    self.m_fMoveElapseTime = self.m_fMoveElapseTime + elapsed
    local s = self.role1.img:getSize()
    local x = self.role1.img:getXPosition().offset
    if self.m_fMoveElapseTime >= MOVE_DURATION then
        self.m_eMovingState = eStop
        x = self.rolePos.center - self.role1.img:getPixelSize().width*0.5
        self.role1.img:setXPosition(CEGUI.UDim(0,x))
        self.role1.img:setSize(s)

        --self.role1.img:setAlpha(1)
        self.role2.img:setAlpha(0)
        self.role1.img:setAlpha(0)

		if self.spine2 then
            local spine = self.spine
            self.spine = self.spine2
            self.spine2 = spine
			self.spine:SetUIAlpha(255)
            self.spine:SetUIScale(1)
            self.spine2:SetUIAlpha(0)
        else
           -- self.spine:SetUIAlpha(0)
		end
        
        self.roleEffectBg:setAlpha(1)

    else
        if self.m_eMovingState == eMovingLeft then
            x = self.rolePos.center + MOVE_LENGTH *(1- self.m_fMoveElapseTime/MOVE_DURATION) - self.role1.img:getPixelSize().width*0.5
        else
            x = self.rolePos.center - MOVE_LENGTH *(1- self.m_fMoveElapseTime/MOVE_DURATION) - self.role1.img:getPixelSize().width*0.5
        end

        self:setRole1XPosition(x, self.m_eMovingState==eMovingLeft)
	end
end

function CCreateRoleDialog:changeSpriteShape()	
	local conf = BeanConfigManager.getInstance():GetTableByName("role.createroleconfig"):getRecorder(self.roleSeqNum)
	if not conf then return end
		
	local shapeId = conf.model
	
	if not self.sprite then
		--����ģ�Ͷ���
		local winMgr = CEGUI.WindowManager:getSingleton()
		self.spriteBack = winMgr:getWindow("CharacterCreatedDlg/Back/spritebg/shadow")
		self.spriteBack:getGeometryBuffer():setRenderEffect(GameUImanager:createXPRenderEffect(0, CCreateRoleDialog.performPostRenderFunctions))
		
		local pos = self.spriteBack:GetScreenPosOfCenter()
		local loc = Nuclear.NuclearPoint(pos.x, pos.y)
		self.sprite = UISprite:new(shapeId)
		self.sprite:SetUILocation(loc)
        self.sprite:SetUIScale(1.3)
		
	elseif self.sprite:GetModelID() ~= shapeId then
		self.sprite:SetModel(shapeId)
	end
	
    local weaponid = self.selectedSchoolBtnIdx;
    if not weaponid then        weaponid = 0    end
	self.sprite:SetSpriteComponent(eSprite_Weapon, conf.weapons[weaponid])
	
	self.actionIdx = 1
	self.actionelapsed = 0
	self.actionRepeatTimes = 0
end

function CCreateRoleDialog.performPostRenderFunctions(id)
	local instance = CCreateRoleDialog:getInstanceOrNot()
	if not instance then
		return
	end

	if instance.sprite then
		instance.sprite:RenderUISprite()
	end
    if instance.role1IsOnFront then
        if instance.spine then
		    instance.spine:RenderUISprite()
	    end
	    if instance.spine2 then
		    instance.spine2:RenderUISprite()
	    end
    else
	    if instance.spine2 then
		    instance.spine2:RenderUISprite()
	    end
        if instance.spine then
		    instance.spine:RenderUISprite()
	    end
    end
end

function CCreateRoleDialog.OnDisconnect()
    local instance = CCreateRoleDialog:getInstanceOrNot()
    if not instance then
        return
    end
    instance.disconnect = true
    instance.connectElapsed = 0
end

function CCreateRoleDialog.OnConnected()
    local instance = CCreateRoleDialog:getInstanceOrNot()
    if not instance then
        return
    end
    instance.disconnect = false
end

function CCreateRoleDialog:createSpineSprite()
    local conf = BeanConfigManager.getInstance():GetTableByName("role.createroleconfig"):getRecorder(self.roleSeqNum)
    local pos = self.roleEffectBg:GetScreenPosOfCenter()
	local loc = Nuclear.NuclearPoint(pos.x, pos.y)
    if conf.effectOnTop ~= "" then
        gGetGameUIManager():AddUIEffect(self.roleEffectBg, conf.effectOnTop, true)
    end

    if not self.spine then
        --self.spine = UISpineSprite:new(conf.spine)
        --self.spine:SetUILocation(loc)
        --self.spine:PlayAction(eActionAttack)
	elseif not self.spine2 then
        --self.spine2 = self.spine
        --self.spine2 = UISpineSprite:new(conf.spine)
       -- self.spine2:SetUILocation(loc)
        --self.spine2:PlayAction(eActionAttack)
       -- self.spine2:SetUIScale(0)
        --self.spine2:SetUIAlpha(0)
    else
        --self.spine2:SetSpineModel(conf.spine, false)
        --self.spine2:SetDefaultAction(eActionStand)
        --self.spine2:PlayAction(eActionAttack)
        --self.spine2:SetUIScale(0)
        --self.spine2:SetUIAlpha(0)
	end
end

function CCreateRoleDialog:changeRolePosY()
    if self.roleSeqNum == 2 then 
        self.rolePos.y = self.backImg:getPixelSize().height +15
    elseif self.roleSeqNum == 4 then
        self.rolePos.y = self.backImg:getPixelSize().height  - 10
    elseif self.roleSeqNum == 6 then
        self.rolePos.y = self.backImg:getPixelSize().height + 38
    else
        self.rolePos.y = self.backImg:getPixelSize().height - 10
    end
end

return CCreateRoleDialog
