require "logic.dialog"

WisdomTrialDlg = {}
setmetatable(WisdomTrialDlg, Dialog)
WisdomTrialDlg.__index = WisdomTrialDlg

local _instance
local _helpmaxnum = 3
function WisdomTrialDlg.getInstance()
	if not _instance then
		_instance = WisdomTrialDlg:new()
		_instance:OnCreate()
	end
	return _instance
end

function WisdomTrialDlg.getInstanceAndShow()
	if not _instance then
		_instance = WisdomTrialDlg:new()
		_instance:OnCreate()
	else
		_instance:SetVisible(true)
	end
	return _instance
end

function WisdomTrialDlg.getInstanceNotCreate()
	return _instance
end

function WisdomTrialDlg.DestroyDialog()
	if _instance then 
		if not _instance.m_bCloseIsHide then
			_instance:OnClose()
			_instance = nil
		else
			_instance:ToggleOpenClose()
		end
	end
end

function WisdomTrialDlg.ToggleOpenClose()
	if not _instance then
		_instance = WisdomTrialDlg:new()
		_instance:OnCreate()
	else
		if _instance:IsVisible() then
			_instance:SetVisible(false)
		else
			_instance:SetVisible(true)
		end
	end
end

function WisdomTrialDlg.GetLayoutFileName()
	return "keju.layout"
end

function WisdomTrialDlg:new()
	local self = {}
	self = Dialog:new()
	setmetatable(self, WisdomTrialDlg)
	return self
end

function WisdomTrialDlg:OnCreate()
	Dialog.OnCreate(self)
	local winMgr = CEGUI.WindowManager:getSingleton()

    self.m_bigTitle=winMgr:getWindow("keju") --大标题

    self.m_numTitle=winMgr:getWindow("keju/wenben2")--题目数量  正确/总数量
    self.m_TimeText=winMgr:getWindow("keju/di1/") --时间
    --self.m_instruction=winMgr:getWindow("keju/shuoming") --说明
--    self.m_curExp=winMgr:getWindow("keju/jingyan2")
--    self.m_allExp=winMgr:getWindow("keju/jingyan1")
--    self.m_curMoney=winMgr:getWindow("keju/yinbi2")
--    self.m_allMoney=winMgr:getWindow("keju/yinbi1")
--    self.m_curExp:setVisible(false)
--    self.m_curMoney:setVisible(false)
    self.m_tittleNumText=winMgr:getWindow("keju/di/wenben1")
    self.m_tittleText=winMgr:getWindow("keju/di/di/biaoti")
    self.m_trueMsg=winMgr:getWindow("keju/di/di/zhengque")
    self.m_trueMsg:setVisible(false)
    self.m_errorMsg=winMgr:getWindow("keju/di/di/cuo")
    self.m_errorMsg:setVisible(false)

    self.m_text1Answer=winMgr:getWindow("keju/di/di/xuan1/zi")
    self.m_text2Answer=winMgr:getWindow("keju/di/di/xuan2/zi")
    self.m_text3Answer=winMgr:getWindow("keju/di/di/xuan3/zi")
    self.m_text4Answer=winMgr:getWindow("keju/di/di/xuan4/zi")

    self.m_answer1Btn = CEGUI.Window.toPushButton(winMgr:getWindow("keju/di/di/xuan1"))
    self.m_answer1Btn:subscribeEvent("MouseClick",WisdomTrialDlg.HandleAnswerClicked,self)
    self.m_answer1Btn:setID(1)
    self.m_answer1Btn:EnableClickAni(false)
    self.m_answer2Btn = CEGUI.Window.toPushButton(winMgr:getWindow("keju/di/di/xuan2"))
    self.m_answer2Btn:subscribeEvent("MouseClick",WisdomTrialDlg.HandleAnswerClicked,self)
    self.m_answer2Btn:setID(2)
    self.m_answer2Btn:EnableClickAni(false)
    self.m_answer3Btn = CEGUI.Window.toPushButton(winMgr:getWindow("keju/di/di/xuan3"))
    self.m_answer3Btn:subscribeEvent("MouseClick",WisdomTrialDlg.HandleAnswerClicked,self)
    self.m_answer3Btn:setID(3)
    self.m_answer3Btn:EnableClickAni(false)
    self.m_answer4Btn = CEGUI.Window.toPushButton(winMgr:getWindow("keju/di/di/xuan4"))
    self.m_answer4Btn:subscribeEvent("MouseClick",WisdomTrialDlg.HandleAnswerClicked,self)
    self.m_answer4Btn:setID(4)
    self.m_answer4Btn:EnableClickAni(false)
    self.m_helpBtn = CEGUI.Window.toPushButton(winMgr:getWindow("keju/di/help"))
    self.m_helpBtn:subscribeEvent("MouseClick",WisdomTrialDlg.HandleHelpClicked,self)
    self.m_leftItem = CEGUI.Window.toPushButton(winMgr:getWindow("keju/di/wupinanniu1")) 
    self.m_rightItem = CEGUI.Window.toPushButton(winMgr:getWindow("keju/di/wupinanniu2")) 
    self.m_leftItem:subscribeEvent("MouseClick",WisdomTrialDlg.HandleLeftItemClicked,self)
    self.m_rightItem:subscribeEvent("MouseClick",WisdomTrialDlg.HandleRightItemClicked,self)

    self.m_left1 = winMgr:getWindow("keju/di/wupin1")
    self.m_left1:subscribeEvent("MouseClick",WisdomTrialDlg.HandleLeftTipClicked,self)
    self.m_left2 = winMgr:getWindow("keju/di/wupin1/fazhu")
    self.m_right1 = winMgr:getWindow("keju/di/wupin2")
    self.m_right1:subscribeEvent("MouseClick",WisdomTrialDlg.HandleRightTipClicked,self)
    self.m_right2 = winMgr:getWindow("keju/di/wupin2/yan")

    self.m_di = winMgr:getWindow("keju/di/di")
    --self.m_ditu = winMgr:getWindow("keju/di/tu")
    --self.m_tidi = winMgr:getWindow("keju/di/tidi")

    self.m_end = winMgr:getWindow("keju/jieshutu")
    self.m_end1 = winMgr:getWindow("keju/jieshuban")

    self.m_ImpExamType = 0
    self.m_timeEnd = 99999
    self.m_status = 0 --0可以答题，1正在答题，2答题结束
    self.m_nExpAll = 0
    self.m_nMoneyAll = 0
    self.m_Questionid = 0
    self.m_cur = 0
    self.m_num = 0
    self.m_AnswerEnd = 0
    self.m_first = true
    self.m_timeDaojishi = 0
    self.m_helpTimes = 0

    
    self.m_LeftNum = winMgr:getWindow("keju/di/shuliang1")
    self.m_RightNum = winMgr:getWindow("keju/di/shuliang2")
    self.m_textleft = winMgr:getWindow("keju/di/wupin1name")
    self.m_text1left = winMgr:getWindow("keju/di/shengyu1")
    self.m_text2left = winMgr:getWindow("keju/di/wupin1text")
    self.m_textright = winMgr:getWindow("keju/di/wupin2name")
    self.m_text1right = winMgr:getWindow("keju/di/shengyu2")
    self.m_text2right = winMgr:getWindow("keju/di/wupin2text")
    self.m_Left = 0
    self.m_Right = 0
    local msginstruction = require "utils.mhsdutils".get_resstring(11405)
    
    self.m_tipsBtn = CEGUI.Window.toPushButton(winMgr:getWindow("keju/btn"))
    self.m_tipsBtn:subscribeEvent("MouseClick",WisdomTrialDlg.HandleTipClicked,self)
    --self.m_instruction:setText(msginstruction)
end
function WisdomTrialDlg:HandleTipClicked(args)
    local tipsid = 1
    local title =MHSD_UTILS.get_resstring(11624)
    if self.m_ImpExamType == 1 then
        tipsid = 11405
    elseif self.m_ImpExamType == 2 then
        tipsid = 11436
    elseif self.m_ImpExamType == 3 then
        tipsid = 11437
    end
    local strAllString = MHSD_UTILS.get_resstring(tipsid)
    local tipdlg = require "logic.workshop.tips1".getInstanceAndShow(strAllString, title)
    SetPositionScreenCenter(tipdlg:GetWindow())
end
function WisdomTrialDlg:HandleLeftTipClicked(args)
	local e = CEGUI.toMouseEventArgs(args)
	local touchPos = e.position
	local nPosX = touchPos.x
	local nPosY = touchPos.y
	
	local index = e.window:getID()
	
	local Commontipdlg = require "logic.tips.commontipdlg"
	local commontipdlg = Commontipdlg.getInstanceAndShow()
	local nType = Commontipdlg.eNormal
	local nItemId = 339100
	
	commontipdlg:RefreshItem(nType,nItemId,nPosX,nPosY)
end
function WisdomTrialDlg:HandleRightTipClicked(args)
	local e = CEGUI.toMouseEventArgs(args)
	local touchPos = e.position
	local nPosX = touchPos.x
	local nPosY = touchPos.y
	
	local index = e.window:getID()
	
	local Commontipdlg = require "logic.tips.commontipdlg"
	local commontipdlg = Commontipdlg.getInstanceAndShow()
	local nType = Commontipdlg.eNormal
	local nItemId = 339101
	
	commontipdlg:RefreshItem(nType,nItemId,nPosX,nPosY)
end
function WisdomTrialDlg:HandleHelpClicked(args)
    if self.m_status == 1 then
        return
    end
    local datamanager = require "logic.faction.factiondatamanager"
    if datamanager:IsHasFaction() then
        if self.m_helpTimes < _helpmaxnum then
            require("logic.openui").OpenUI(44)
            CChatOutputDialog:getInstance():ChangeOutChannel(4)
            CChatOutputDialog:getInstance():RefreshOpenedDlgChannel()
        
            local p = require("protodef.fire.pb.npc.cimpexamhelp"):new()
            p.impexamtype = self.m_ImpExamType
            LuaProtocolManager:send(p)
            WisdomTrialDlg.DestroyDialog()
        else
            --超过次数
        end
    else
        local msg = require "utils.mhsdutils".get_msgtipstring(150027)
		GetCTipsManager():AddMessageTip(msg)    
        --没有工会
    end
end
function WisdomTrialDlg:HandleLeftItemClicked(args)
    if self.m_ImpExamType == 1 then
        return true
    end
    if self.m_status == 1 then
        return true
    else
        local num = 0
        if self.m_answer1Btn:isVisible() == false then
            num = num + 1
        end
        if self.m_answer2Btn:isVisible() == false then
            num = num + 1
        end
        if self.m_answer3Btn:isVisible() == false then
            num = num + 1
        end
        if self.m_answer4Btn:isVisible() == false then
            num = num + 1
        end
        if num >= 3 then
            GetCTipsManager():AddMessageTipById(190063)
            return true
        end
        if self.m_Left > 0 then
            local p = require("protodef.fire.pb.npc.csendimpexamanswer"):new()
            p.impexamtype = self.m_ImpExamType
            p.answerid = 0
            p.assisttype = 1
	        LuaProtocolManager:send(p)
        else
            GetCTipsManager():AddMessageTipById(190030)
        end

    end
end
function WisdomTrialDlg:HandleRightItemClicked(args)
    if self.m_ImpExamType == 1 then
        return
    end
    if self.m_status == 1 then
        return
    else
        if self.m_Right > 0 then
            local p = require("protodef.fire.pb.npc.csendimpexamanswer"):new()
            p.impexamtype = self.m_ImpExamType
            p.answerid = 0
            p.assisttype = 2
            self.m_status = 1
            self.m_timeDaojishi = 1.0
	        LuaProtocolManager:send(p)
        else
            GetCTipsManager():AddMessageTipById(190031)
        end
    end
end
function WisdomTrialDlg:AnswerQuestionDelect(data)
    
    if data.assisttype == 1 then
        self.m_Left = self.m_Left - 1
        self.m_LeftNum:setText(self.m_Left)
        if self.m_answer1Btn:getID() == data.answerid then
            self.m_answer1Btn:setVisible(false)
        end
        if self.m_answer2Btn:getID() == data.answerid then
            self.m_answer2Btn:setVisible(false)
        end
        if self.m_answer3Btn:getID() == data.answerid then
            self.m_answer3Btn:setVisible(false)
        end
        if self.m_answer4Btn:getID() == data.answerid then
            self.m_answer4Btn:setVisible(false)
        end
    end
end
function WisdomTrialDlg:HandleAnswerClicked(args)
    if self.m_status == 1 then
        return
    else
        self.m_status = 1
        self.m_timeDaojishi = 1.0
	    local eventargs = CEGUI.toWindowEventArgs(args)
	    local id = eventargs.window:getID()
        local p = require("protodef.fire.pb.npc.csendimpexamanswer"):new()
        p.impexamtype = self.m_ImpExamType
        p.answerid = id
        p.assisttype = 0
        self.m_index = id
	    LuaProtocolManager:send(p)
    end
end
function WisdomTrialDlg:AnswerQuestionEnd()
    self.m_di:setVisible(false)
    --self.m_ditu:setVisible(false)
    --self.m_tidi:setVisible(false)
    self.m_tittleNumText:setVisible(false)
    self.m_end:setVisible(true)
    self.m_end1:setVisible(true)
    --self.m_TimeText:setVisible(false)
    --self.m_allExp:setText(tostring(self.m_totalexp))
    --self.m_allMoney:setText(tostring(self.m_totalmoney))
    self.m_TimeText:setText("00:00:00")
    --self.m_curExp:setVisible(false)
    --self.m_curMoney:setVisible(false)
    self.m_numTitle:setText(self.m_cur .."/".. self.m_num)
    self.m_helpBtn:setVisible(false)
end
--智慧试炼1--
function WisdomTrialDlg:AnswerQuestionvillProcess(ssendimpexamvill)
    self.m_ImpExamType = 1
    self:refreshUI(ssendimpexamvill.impexamdata)
    self.m_AnswerEnd = ssendimpexamvill.isover
end
--智慧试炼2--
function WisdomTrialDlg:AnswerQuestionprovProcess(ssendImpexamprov)
    self.m_ImpExamType = 2
    self:refreshUI(ssendImpexamprov.impexamdata)
    self.m_AnswerEnd = ssendImpexamprov.lost
end
function WisdomTrialDlg:AnswerQuestionstateProcess(ssendimpexamstate)
    self.m_ImpExamType = 3
    self:refreshUI(ssendimpexamstate.impexamdata)
    self.m_AnswerEnd = ssendimpexamstate.lost
    self.m_LeftNum:setVisible(false)
    self.m_RightNum:setVisible(false)
    self.m_textleft:setVisible(false)
    self.m_text1left:setVisible(false)
    self.m_text2left:setVisible(false)
    self.m_textright:setVisible(false)
    self.m_text1right:setVisible(false)
    self.m_text2right:setVisible(false)
    self.m_leftItem:setVisible(false)
    self.m_rightItem:setVisible(false)
end
function WisdomTrialDlg:refreshUI(impexamdata)
    self.m_cur = impexamdata.righttimes
    self.m_num = impexamdata.questionnum
    self.m_totalexp = impexamdata.accuexp
    self.m_totalmoney = impexamdata.accumoney
    self.m_answer1Btn:setVisible(true)
    self.m_answer2Btn:setVisible(true)
    self.m_answer3Btn:setVisible(true)
    self.m_answer4Btn:setVisible(true)
     --答对

    if self.m_first then
        self:refreshFirst(impexamdata)
        self.m_first = false
        self:initTime(self.m_ImpExamType)
        --self.m_timeEnd = impexamdata.remaintime
    else
        if impexamdata.lastright == 1 then
            self:refreshTrue(impexamdata.questionid)
            if self.m_timeDaojishi<= 0 or self.m_timeDaojishi > 1 then
                self.m_LeftNum:setText(impexamdata.delwrongval)
                self.m_Left = impexamdata.delwrongval
                self.m_RightNum:setText(impexamdata.chorightval)
                self.m_Right = impexamdata.chorightval
                self.m_Questionid = impexamdata.questionid
                self.m_status = 0
                self:refreshUITime()

            end
        --打错
        elseif impexamdata.lastright == 0 then
            self:refreshError(impexamdata.questionid)
            if self.m_timeDaojishi<= 0 or self.m_timeDaojishi > 1 then
                self.m_LeftNum:setText(impexamdata.delwrongval)
                self.m_Left = impexamdata.delwrongval
                self.m_RightNum:setText(impexamdata.chorightval)
                self.m_Right = impexamdata.chorightval
                self.m_Questionid = impexamdata.questionid
                self.m_status = 0
                self:refreshUITime()
            end
        --第一题
        else 
            
            self:refreshFirst(impexamdata)
        end

    end
    self.m_LeftNum:setText(impexamdata.delwrongval)
    self.m_Left = impexamdata.delwrongval
    self.m_RightNum:setText(impexamdata.chorightval)
    self.m_Right = impexamdata.chorightval
    self.m_Questionid = impexamdata.questionid
end
function WisdomTrialDlg:refreshUITime()
    if self.m_AnswerEnd == 1 or self.m_status == 2 then
        self:AnswerQuestionEnd()
        return
    end
    self.m_trueMsg:setVisible(false)
    self.m_errorMsg:setVisible(false)
    local msgdi = require "utils.mhsdutils".get_resstring(11361)
    local msgti = require "utils.mhsdutils".get_resstring(11362)
    self.m_numTitle:setText(self.m_cur .."/".. self.m_num- 1)
    self.m_tittleNumText:setText(msgdi..tostring(self.m_num)..msgti)
    if self.m_ImpExamType == 1 then
        strTableName = "wisdomtrialvill"
        strBigTitle = require "utils.mhsdutils".get_resstring(11406)
    elseif self.m_ImpExamType == 2 then
        strTableName = "wisdomtrialprov"
        strBigTitle = require "utils.mhsdutils".get_resstring(11407)
    elseif self.m_ImpExamType == 3 then
        strTableName = "wisdomtrialstate"
        strBigTitle = require "utils.mhsdutils".get_resstring(11408)
    end
    local record = BeanConfigManager.getInstance():GetTableByName("game."..strTableName):getRecorder(self.m_Questionid)
    self.m_tittleText:setText(record.name)
    self.m_text1Answer:setText(record.options[0])
    self.m_text2Answer:setText(record.options[1])
    self.m_text3Answer:setText(record.options[2])
    self.m_text4Answer:setText(record.options[3])
    self.m_answer1Btn:setID(1)
    self.m_answer2Btn:setID(2)
    self.m_answer3Btn:setID(3)
    self.m_answer4Btn:setID(4)
    local random = math.random(1, 4)
    if random == 2 then
        self.m_text1Answer:setText(record.options[1])
        self.m_text2Answer:setText(record.options[0])
        self.m_answer1Btn:setID(2)
        self.m_answer2Btn:setID(1)
    elseif random == 3 then
        self.m_text1Answer:setText(record.options[2])
        self.m_text3Answer:setText(record.options[0])
        self.m_answer1Btn:setID(3)
        self.m_answer3Btn:setID(1)
    elseif random == 4 then
        self.m_text1Answer:setText(record.options[3])
        self.m_text4Answer:setText(record.options[0])
        self.m_answer1Btn:setID(4)
        self.m_answer4Btn:setID(1)
    end
    --self.m_nExpAll = self.m_totalexp
    --self.m_nMoneyAll = self.m_totalmoney
    --self.m_allExp:setText(tostring(self.m_nExpAll))
    --self.m_allMoney:setText(tostring(self.m_nMoneyAll))

    --self.m_curExp:setVisible(false)
    --self.m_curMoney:setVisible(false)


end
function WisdomTrialDlg:refreshFirst(impexamdata)
    self.m_trueMsg:setVisible(false)
    self.m_errorMsg:setVisible(false)
    local msgdi = require "utils.mhsdutils".get_resstring(11361)
    local msgti = require "utils.mhsdutils".get_resstring(11362)
    self.m_numTitle:setText(impexamdata.righttimes .."/".. impexamdata.questionnum - 1)
    self.m_tittleNumText:setText(msgdi..tostring(impexamdata.questionnum)..msgti)
    local strTableName = ""
    local strBigTitle = ""
    if self.m_ImpExamType == 1 then
        strTableName = "wisdomtrialvill"
        strBigTitle = require "utils.mhsdutils".get_resstring(11406)
        self.m_helpBtn:setVisible(true)
        self.m_leftItem:setVisible(false)
        self.m_rightItem:setVisible(false)
    elseif self.m_ImpExamType == 2 then
        strTableName = "wisdomtrialprov"
        strBigTitle = require "utils.mhsdutils".get_resstring(11407)
        self.m_helpBtn:setVisible(false)
        self.m_leftItem:setVisible(true)
        self.m_rightItem:setVisible(true)
    elseif self.m_ImpExamType == 3 then
        strTableName = "wisdomtrialstate"
        strBigTitle = require "utils.mhsdutils".get_resstring(11408)
        self.m_helpBtn:setVisible(false)
        self.m_leftItem:setVisible(false)
        self.m_rightItem:setVisible(false)
        self.m_left1:setVisible(false)
        self.m_left2:setVisible(false)
        self.m_right1:setVisible(false)
        self.m_right2:setVisible(false)
        end
    self.m_bigTitle:setText(strBigTitle)
    local record = BeanConfigManager.getInstance():GetTableByName("game."..strTableName):getRecorder(impexamdata.questionid)
    self.m_tittleText:setText(record.name)
    self.m_text1Answer:setText(record.options[0])
    self.m_text2Answer:setText(record.options[1])
    self.m_text3Answer:setText(record.options[2])
    self.m_text4Answer:setText(record.options[3])
    self.m_answer1Btn:setID(1)
    self.m_answer2Btn:setID(2)
    self.m_answer3Btn:setID(3)
    self.m_answer4Btn:setID(4)
    local random = math.random(1, 4)
    if random == 2 then
        self.m_text1Answer:setText(record.options[1])
        self.m_text2Answer:setText(record.options[0])
        self.m_answer1Btn:setID(2)
        self.m_answer2Btn:setID(1)
    elseif random == 3 then
        self.m_text1Answer:setText(record.options[2])
        self.m_text3Answer:setText(record.options[0])
        self.m_answer1Btn:setID(3)
        self.m_answer3Btn:setID(1)
    elseif random == 4 then
        self.m_text1Answer:setText(record.options[3])
        self.m_text4Answer:setText(record.options[0])
        self.m_answer1Btn:setID(4)
        self.m_answer4Btn:setID(1)
    end

    
    self.m_helpTimes = impexamdata.helpcnt
    self.m_helpBtn:setText(require "utils.mhsdutils".get_resstring(11507)..tostring(self.m_helpTimes) .. "/"..tostring(_helpmaxnum))
    --self.m_nExpAll = impexamdata.accuexp
    --self.m_nMoneyAll = impexamdata.accumoney
    --self.m_allExp:setText(tostring(impexamdata.accuexp))
    --self.m_allMoney:setText(tostring(impexamdata.accumoney))

end
function WisdomTrialDlg:refreshHelp(num)
    self.m_helpTimes = num
    self.m_helpBtn:setText(require "utils.mhsdutils".get_resstring(11507)..tostring(num) .. "/"..tostring(_helpmaxnum))
end
function WisdomTrialDlg:refreshTrue(id)
    self.m_trueMsg:setVisible(true)
    self.m_errorMsg:setVisible(false)
    local msg = require "utils.mhsdutils".get_msgtipstring(160414)
	GetCTipsManager():AddMessageTip(msg)
    if self.m_totalexp-self.m_nExpAll == 0 then
        --self.m_curExp:setVisible(false)
        --self.m_curMoney:setVisible(false)
    else
        --self.m_curExp:setVisible(true)
        --self.m_curExp:setText("+"..tostring(self.m_totalexp-self.m_nExpAll))
        --self.m_curMoney:setVisible(true)
        --self.m_curMoney:setText("+"..tostring(self.m_totalmoney-self.m_nMoneyAll))
    end
end
function WisdomTrialDlg:refreshError(id)
    self.m_trueMsg:setVisible(false)
    self.m_errorMsg:setVisible(true)
    local msg = require "utils.mhsdutils".get_msgtipstring(160415)
	GetCTipsManager():AddMessageTip(msg)
    if self.m_totalexp-self.m_nExpAll == 0 then
        --self.m_curExp:setVisible(false)
        --self.m_curMoney:setVisible(false)
    else
        --self.m_curExp:setVisible(true)
        --self.m_curExp:setText("+"..tostring(self.m_totalexp-self.m_nExpAll))
        --self.m_curMoney:setVisible(true)
        --self.m_curMoney:setText("+"..tostring(self.m_totalmoney-self.m_nMoneyAll))
    end

end

function WisdomTrialDlg:UpdateTime(delta)
    if self.m_status == 2 then
        return
    end
    local time = StringCover.getTimeStruct(gGetServerTime() / 1000)  
    local actnowAll  = time.tm_hour * 3600 + time.tm_min * 60 + time.tm_sec

    local disTime = self.m_timeEnd - actnowAll
    if disTime<=0 and self.m_status~=2 then
        self:AnswerQuestionEnd()
        self.m_status = 2
        return
    end
    --计算倒计时时间
    local hour = math.floor(disTime / 3600)
    local strhour = ""
    
    if hour < 10 then
        strhour = "0"..tostring(hour)
    else
        strhour = tostring(hour)
    end
    local min = math.floor((disTime - hour * 3600) / 60)
    local strmin = ""
    if min < 10 then
        strmin = "0"..tostring(min)
    else
        strmin = tostring(min)
    end
    
    local sec = math.floor((disTime - hour * 3600 -  min * 60))
    local strsec = ""
    if sec < 10 then
        strsec = "0"..tostring(sec)
    else
        strsec = tostring(sec)
    end
    self.m_TimeText:setText(tostring(strhour..":"..strmin..":"..strsec))

    if self.m_status == 1 then
        if self.m_timeDaojishi<= 0 or self.m_timeDaojishi > 1 then
            self.m_status = 0
            self:refreshUITime()
        else
            self.m_timeDaojishi = self.m_timeDaojishi -  delta / 1000
        end

    end
end
function WisdomTrialDlg:initTime(index)
    local recordid = 0
    if index == 1 then
        recordid = 214
    elseif index == 2 then
        recordid = 215
    elseif index == 3 then
        recordid = 216
    end
    local tableName = ""
    if IsPointCardServer() then
        tableName = "mission.cactivitynewpay"
    else
        tableName = "mission.cactivitynew"
    end
    local record = BeanConfigManager.getInstance():GetTableByName(tableName):getRecorder(recordid)
    local time = StringCover.getTimeStruct(gGetServerTime() / 1000)  
    local curWeekDay = time.tm_wday
	if curWeekDay == 0 then
		curWeekDay = 7
	end
    if IsPointCardServer() then
        tableName = "timer.cscheculedactivitypay"
    else
        tableName = "timer.cscheculedactivity"
    end
    local tableAllId = BeanConfigManager.getInstance():GetTableByName(tableName):getAllID()
	for _, v in pairs(tableAllId) do
		local actScheculed = BeanConfigManager.getInstance():GetTableByName(tableName):getRecorder(v)
		--去定时活动表找对应活动
		if actScheculed.activityid == tonumber(record.actid) then
            strStartTime = actScheculed.startTime
			--如果该活动为固定日期开放
			if actScheculed.weekrepeat == curWeekDay then
				blntoday = true
				local actstarttimehour, actstarttimemin, actstarttimesec = string.match(actScheculed.startTime, "(%d+):(%d+):(%d+)")
				local actendtimehour, actendtimemin, actendtimesec = string.match(actScheculed.endTime, "(%d+):(%d+):(%d+)")
                local actnowAll  = time.tm_hour * 3600 + time.tm_min * 60 + time.tm_sec
                self.m_timeEnd = actendtimehour * 3600 + actendtimemin * 60 + actendtimesec
				break
			end
		end
	end
end
return WisdomTrialDlg