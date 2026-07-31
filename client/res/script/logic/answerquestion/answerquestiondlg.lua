require "logic.dialog"

AnswerQuestionDlg = {}
setmetatable(AnswerQuestionDlg, Dialog)
AnswerQuestionDlg.__index = AnswerQuestionDlg
local _instance
local aqhelpMaxNum = 3 --求助总次数


function AnswerQuestionDlg.getInstance()
	if not _instance then
		_instance = AnswerQuestionDlg:new()
		_instance:OnCreate()
	end
	return _instance
end

function AnswerQuestionDlg.getInstanceAndShow()
	if not _instance then
		_instance = AnswerQuestionDlg:new()
		_instance:OnCreate()
	else
		_instance:SetVisible(true)
	end
	return _instance
end

function AnswerQuestionDlg.getInstanceNotCreate()
	return _instance
end

function AnswerQuestionDlg.DestroyDialog()
	if _instance then 
		if not _instance.m_bCloseIsHide then
            _instance:CloseDialogReward()
			_instance:OnClose()
			_instance = nil
		else
			_instance:ToggleOpenClose()
		end
	end
end

function AnswerQuestionDlg.ToggleOpenClose()
	if not _instance then
		_instance = AnswerQuestionDlg:new()
		_instance:OnCreate()
	else
		if _instance:IsVisible() then
			_instance:SetVisible(false)
		else
			_instance:SetVisible(true)
		end
	end
end

function AnswerQuestionDlg.GetLayoutFileName()
	return "dati.layout"
end

function AnswerQuestionDlg:new()
	local self = {}
	self = Dialog:new()
	setmetatable(self, AnswerQuestionDlg)
	return self
end

function AnswerQuestionDlg:OnCreate()
	Dialog.OnCreate(self)
	local winMgr = CEGUI.WindowManager:getSingleton()

    self.m_numTitle=winMgr:getWindow("dati/zhi1")
    self.m_textTitle=winMgr:getWindow("dati/di/wenben1")
    self.m_TimeText=winMgr:getWindow("dati/wenben2/wenben2")
    
    self.m_reward = CEGUI.Window.toPushButton(winMgr:getWindow("dati/jiangli"))
    self.m_rewardnot =winMgr:getWindow("dati/jiangli1")

    self.m_true1 = winMgr:getWindow("dati/di/di/tu1/dui")
    self.m_true2 = winMgr:getWindow("dati/di/di/tu2/dui")
    self.m_true3 = winMgr:getWindow("dati/di/di/tu3/dui")

    self.m_answerbg1 = CEGUI.Window.toPushButton(winMgr:getWindow("dati/di/di/tu1"))
    self.m_answerbg1:subscribeEvent("MouseClick",AnswerQuestionDlg.HandleAnswerClicked,self)
    self.m_answerbg1:setID(1)
    self.m_answerbg1:EnableClickAni(false)
    self.m_answerbg2 =  CEGUI.Window.toPushButton(winMgr:getWindow("dati/di/di/tu2"))
    self.m_answerbg2:subscribeEvent("MouseClick",AnswerQuestionDlg.HandleAnswerClicked,self)
    self.m_answerbg2:setID(2)
    self.m_answerbg2:EnableClickAni(false)
    self.m_answerbg3 =  CEGUI.Window.toPushButton(winMgr:getWindow("dati/di/di/tu3"))
    self.m_answerbg3:subscribeEvent("MouseClick",AnswerQuestionDlg.HandleAnswerClicked,self)
    self.m_answerbg3:setID(3)
    self.m_answerbg3:EnableClickAni(false)

    self.m_false1 = winMgr:getWindow("dati/di/di/tu1/cuo")
    self.m_false2 = winMgr:getWindow("dati/di/di/tu2/cuo")
    self.m_false3 = winMgr:getWindow("dati/di/di/tu3/cuo")
    self.m_true1:setVisible(false)
    self.m_true2:setVisible(false)
    self.m_true3:setVisible(false)
    self.m_false1:setVisible(false)
    self.m_false2:setVisible(false)
    self.m_false3:setVisible(false)
    self.m_reward:subscribeEvent("MouseClick",AnswerQuestionDlg.HandleRewardClick,self)
    self.m_rewardnot:subscribeEvent("MouseClick",AnswerQuestionDlg.HandleRewardClick,self)
    self.m_image1 = winMgr:getWindow("dati/di/di/tu1/tu")
    self.m_image2 = winMgr:getWindow("dati/di/di/tu2/tu")
    self.m_image3 = winMgr:getWindow("dati/di/di/tu3/tu")

    self.m_name1 = winMgr:getWindow("dati/di/di/tu1/mingzi")
    self.m_name2 = winMgr:getWindow("dati/di/di/tu2/mingzi")
    self.m_name3 = winMgr:getWindow("dati/di/di/tu3/mingzi")

    self.m_head1 = CEGUI.Window.toItemCell(winMgr:getWindow("dati/di/touxiang1")) 
    self.m_head2 = CEGUI.Window.toItemCell(winMgr:getWindow("dati/di/touxiang2"))  
    self.m_head3 = CEGUI.Window.toItemCell(winMgr:getWindow("dati/di/touxiang3")) 

    self.m_headName1 =(winMgr:getWindow("dati/di/mingzidi1/wenben")) 
    self.m_headName2 =(winMgr:getWindow("dati/di/mingzidi2/wenben"))  
    self.m_headName3 =(winMgr:getWindow("dati/di/mingzidi3/wenben")) 


    self.m_helpBtn = CEGUI.Window.toPushButton(winMgr:getWindow("dati/di/qiuzhu")) 
    self.m_helpBtn:subscribeEvent("MouseClick",AnswerQuestionDlg.HandleHelpClick,self)
    self.m_helpBtn:setVisible(true)
    self.m_nEndtime = 0
    self.m_nExpAll = 0
    self.m_nMoneyAll = 0

    self.back = winMgr:getWindow("dati/di/di")
    self.textfinish = winMgr:getWindow("dati/di/ban")
    self.imagefinish = winMgr:getWindow("dati/di/wanchengtu")

    self.mingzi1 = winMgr:getWindow("dati/di/mingzidi1")
    self.mingzi2 = winMgr:getWindow("dati/di/mingzidi2")
    self.mingzi3 = winMgr:getWindow("dati/di/mingzidi3")
	
    self.datixian = winMgr:getWindow("dati/xian1")
    self.datiwenben2 = winMgr:getWindow("dati/di/wenben2")

    self.m_Questionid = 0
    self.m_int = 0
    self.m_rewardid = 0
    self.m_timeEnd = 0
    self.m_helpTimes = 0

    self:initTime()


    -- 0 为可以答题 1为 不可以，延迟状态
    self.m_status = 0

    --倒计时
    self.m_timeDaojishi = 0

   
    -- 0  可以答题状态，  1答对状态， 2打错状态
     self.m_index = 0

     self.m_cur = 0
     self.m_num = 0
     self.m_totalexp = 0
     self.m_totalmoney = 0
     self.m_helptimes = 0
     self.m_grab = 0

     self.m_first = true

     self.m_Finish =false

end
 

function AnswerQuestionDlg:initTime()
    local tableName = ""
    if IsPointCardServer() then
        tableName = "mission.cactivitynewpay"
    else
        tableName = "mission.cactivitynew"
    end
    local record = BeanConfigManager.getInstance():GetTableByName(tableName):getRecorder(213)
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
function AnswerQuestionDlg.UpdateOpen()
end
function AnswerQuestionDlg:AnswerQuestionProcess(saskquestion)  
   

    if self.m_num > 0 and saskquestion.num == 0 then
        return
    end
    --0 = 没有上一道题，1 = 正确，-1 = 错误   0 为第一次进入
    
    self.m_cur =  saskquestion.cur
    self.m_num = saskquestion.num
    self.m_totalexp = saskquestion.totalexp
    self.m_totalmoney = saskquestion.totalmoney
    self.m_helptimes = saskquestion.helptimes
    self.m_grab = saskquestion.grab
    
    self.m_lastresult = saskquestion.lastresult
    local record = BeanConfigManager.getInstance():GetTableByName("mission.answerquestion"):getRecorder(saskquestion.questionid)
    if record == nil then
        LogErr("AnswerQuestionDlg.AnswerQuestionProcess lastresult:"..tostring(saskquestion.lastresult))
        LogErr("AnswerQuestionDlg.AnswerQuestionProcess id:"..tostring(saskquestion.questionid))
    end
    local aqmanager = require "logic.answerquestion.answerquestionmanager".getInstance()
    if record ~= nil then
        for k,onerightanswer in pairs(saskquestion.rightanswer) do
            if k == 1 then
                local tableAllId = BeanConfigManager.getInstance():GetTableByName("mission.answerquestion"):getAllID()
                for _, v in pairs(tableAllId) do
                    local recorda = BeanConfigManager.getInstance():GetTableByName("mission.answerquestion"):getRecorder(v)

                    if recorda.topic == record.topic and recorda.step == 0 then
                        if saskquestion.rightanswer[k] == 1 then
                            aqmanager.m_answerid1= recorda.object1
                            aqmanager.m_icon1= recorda.icon1
                        elseif saskquestion.rightanswer[k] == 2 then
                            aqmanager.m_answerid1= recorda.object2
                            aqmanager.m_icon1= recorda.icon2
                        elseif saskquestion.rightanswer[k] == 3 then
                            aqmanager.m_answerid1= recorda.object3
                            aqmanager.m_icon1= recorda.icon3
                        end
                    end
                end

            elseif k == 2 then
                local tableAllId = BeanConfigManager.getInstance():GetTableByName("mission.answerquestion"):getAllID()
                for _, v in pairs(tableAllId) do
                    local recorda = BeanConfigManager.getInstance():GetTableByName("mission.answerquestion"):getRecorder(v)

                    if recorda.topic == record.topic and recorda.step == 1 then
                        if saskquestion.rightanswer[k] == 1 then
                            aqmanager.m_answerid2= recorda.object1
                            aqmanager.m_icon2= recorda.icon1
                        elseif saskquestion.rightanswer[k] == 2 then
                            aqmanager.m_answerid2= recorda.object2
                            aqmanager.m_icon2= recorda.icon2
                        elseif saskquestion.rightanswer[k] == 3 then
                            aqmanager.m_answerid2= recorda.object3
                            aqmanager.m_icon2= recorda.icon3
                        end
                    end
                end
            end
        end
    end
    if self.m_first then
        aqmanager.m_xiangguanid = record.step
        self:refreshUI(saskquestion)
        self.m_first = false
        if record ~= nil then
            aqmanager.m_xiangguanid = record.step
        else
            aqmanager.m_xiangguanid = 0
        end
        self.m_Questionid = saskquestion.questionid
    else
        if saskquestion.lastresult == 0 then
            self:refreshUI(saskquestion)
        elseif saskquestion.lastresult == 1 then
            self:refreshUITrue(self.m_Questionid)
        else
            self:refreshUIError(self.m_Questionid)
        end
        if record ~= nil then
            aqmanager.m_xiangguanid = record.step
        else
            aqmanager.m_xiangguanid = 0
        end
        self.m_Questionid = saskquestion.questionid
        if self.m_timeDaojishi<= 0 or self.m_timeDaojishi > 1 then
            self.m_status = 0
            self:refreshUITime()
        end
    end

    

end
function AnswerQuestionDlg:AnswerQuestionEnd()

    self.back:setVisible(false)
    self.textfinish:setVisible(true)
    self.imagefinish:setVisible(true)
    self.m_helpBtn:setVisible(false)
    self.m_TimeText:setText("00:00:00")
    self.m_head1:setVisible(false)
    self.m_head2:setVisible(false)
    self.m_head3:setVisible(false)
    self.m_headName1:setVisible(false)
    self.m_headName2:setVisible(false)
    self.m_headName3:setVisible(false)
    self.mingzi1:setVisible(false)
    self.mingzi2:setVisible(false)
    self.mingzi3:setVisible(false)
    self.m_textTitle:setVisible(false)
    self.m_nExpAll = self.m_totalexp
    self.m_nMoneyAll = self.m_totalmoney
    self.m_numTitle:setText(self.m_cur .."/".. self.m_num)
    self.datixian:setVisible(false)
    self.datiwenben2:setVisible(false)
end
function AnswerQuestionDlg:refreshUIError(id)
    print("AnswerQuestionDlg.refreshUIError"..tostring(id))
    local record = BeanConfigManager.getInstance():GetTableByName("mission.answerquestion"):getRecorder(id)
	local msg = require "utils.mhsdutils".get_msgtipstring(160415)
	GetCTipsManager():AddMessageTip(msg)
    self.m_true1:setVisible(false)
    self.m_true2:setVisible(false)
    self.m_true3:setVisible(false)

    if self.m_index == 1 then
        self.m_false1:setVisible(true)
        self.m_false2:setVisible(false)
        self.m_false3:setVisible(false)
    elseif  self.m_index == 2 then
        self.m_false1:setVisible(false)
        self.m_false2:setVisible(true)
        self.m_false3:setVisible(false)
    elseif  self.m_index == 3 then
        self.m_false1:setVisible(false)
        self.m_false2:setVisible(false)
        self.m_false3:setVisible(true)
    end
end
function AnswerQuestionDlg:refreshUITrue(id)
    local record = BeanConfigManager.getInstance():GetTableByName("mission.answerquestion"):getRecorder(id)
	local msg = require "utils.mhsdutils".get_msgtipstring(160414)
	GetCTipsManager():AddMessageTip(msg)
    self.m_false1:setVisible(false)
    self.m_false2:setVisible(false)
    self.m_false3:setVisible(false)
    local aqmanager = require "logic.answerquestion.answerquestionmanager".getInstance()
    if aqmanager.m_xiangguanid == 0 then
        if self.m_index == 1 then
            aqmanager.m_answerid1= record.object1
            aqmanager.m_icon1= record.icon1
        elseif self.m_index == 2 then
            aqmanager.m_answerid1= record.object2
            aqmanager.m_icon1= record.icon2
        elseif self.m_index == 3 then
            aqmanager.m_answerid1= record.object3
            aqmanager.m_icon1= record.icon3
            
        end
        self.m_headName1:setText(aqmanager.m_answerid1)
        self.m_head1:SetImage(gGetIconManager():GetItemIconByID(aqmanager.m_icon1))
        self.m_headName2:setText("")
        self.m_headName3:setText("")
        self.m_head2:SetImage(nil)
        self.m_head3:SetImage(nil)
    elseif aqmanager.m_xiangguanid == 1 then
        if self.m_index == 1 then
            aqmanager.m_answerid2= record.object1
            aqmanager.m_icon2 = record.icon1
        elseif self.m_index == 2 then
            aqmanager.m_answerid2= record.object2
            aqmanager.m_icon2 = record.icon2
        elseif self.m_index == 3 then
            aqmanager.m_answerid2= record.object3
            aqmanager.m_icon2 = record.icon3
        end
        self.m_head2:SetImage(gGetIconManager():GetItemIconByID(aqmanager.m_icon2))
        self.m_headName2:setText(aqmanager.m_answerid2)
        self.m_headName3:setText("")
    elseif aqmanager.m_xiangguanid == 2 then
        if self.m_index == 1 then
            aqmanager.m_answerid3= record.object1
            aqmanager.m_icon3 = record.icon1
        elseif self.m_index == 2 then
            aqmanager.m_answerid3= record.object2
            aqmanager.m_icon3 = record.icon2
        elseif self.m_index == 3 then
            aqmanager.m_answerid3= record.object3
            aqmanager.m_icon3 = record.icon3
            
        end
        self.m_head3:SetImage(gGetIconManager():GetItemIconByID(aqmanager.m_icon3))
        self.m_headName3:setText(aqmanager.m_answerid3)
    end

    if  self.m_index == 1 then
        self.m_true1:setVisible(true)
        self.m_true2:setVisible(false)
        self.m_true3:setVisible(false)
    elseif  self.m_index == 2 then
        self.m_true1:setVisible(false)
        self.m_true2:setVisible(true)
        self.m_true3:setVisible(false)
    elseif  self.m_index == 3 then
        self.m_true1:setVisible(false)
        self.m_true2:setVisible(false)
        self.m_true3:setVisible(true)
    end


end

function AnswerQuestionDlg:UpdateTime(delta)
    local time = StringCover.getTimeStruct(gGetServerTime() / 1000)  
    local actnowAll  = time.tm_hour * 3600 + time.tm_min * 60 + time.tm_sec

    local disTime = self.m_timeEnd - actnowAll
    
    --时间到了答题结束
    if disTime<=0 and self.m_status~=2 then
        self.m_reward:setText("")
        self.m_reward:setVisible(false)
        self.m_rewardnot:setVisible(true)
        self.m_rewardid = 4
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
function AnswerQuestionDlg:refreshUITime()
    if self.m_Questionid == 0 then
        self:AnswerQuestionEnd()
        return
    end
    self.m_true1:setVisible(false)
    self.m_true2:setVisible(false)
    self.m_true3:setVisible(false)
    self.m_false1:setVisible(false)
    self.m_false2:setVisible(false)
    self.m_false3:setVisible(false)

    local record = BeanConfigManager.getInstance():GetTableByName("mission.answerquestion"):getRecorder(self.m_Questionid)
    self.m_name1:setText(record.object1)
    self.m_name2:setText(record.object2)
    self.m_name3:setText(record.object3)
    self.m_nExpAll = self.m_totalexp
    self.m_nMoneyAll = self.m_totalmoney

    self.mingzi2:setVisible(false)
    self.mingzi3:setVisible(false)
    self.m_head2:setVisible(false)
    self.m_head3:setVisible(false)
    local i = 0
    local msgdi = require "utils.mhsdutils".get_resstring(11361)
    local msgti = require "utils.mhsdutils".get_resstring(11362)
    self.m_textTitle:setText(msgdi..tostring(self.m_num+1)..msgti..record.title)
    local aqmanager = require "logic.answerquestion.answerquestionmanager".getInstance()
    local tableAllId = BeanConfigManager.getInstance():GetTableByName("mission.answerquestion"):getAllID()
    local nTitleCount = 1
    for _, v in pairs(tableAllId) do
        local recorda = BeanConfigManager.getInstance():GetTableByName("mission.answerquestion"):getRecorder(v)

        if recorda.topic == record.topic and recorda.id ~=record.id then
            nTitleCount  = nTitleCount + 1
        end
    end

    --步骤
    if nTitleCount == 1 then

    elseif nTitleCount == 2 then
        self.mingzi2:setVisible(true)
        self.m_head2:setVisible(true)
        self.m_textTitle:setText(msgdi..tostring(self.m_num+1)..msgti..record.title.."("..tostring(aqmanager.m_xiangguanid).."/2)")
    elseif nTitleCount == 3 then
        self.mingzi2:setVisible(true)
        self.mingzi3:setVisible(true)
        self.m_head2:setVisible(true)
        self.m_head3:setVisible(true)
        self.m_textTitle:setText(msgdi..tostring(self.m_num+1)..msgti..record.title.."("..tostring(aqmanager.m_xiangguanid).."/3)")
    end

    local aqmanager = require "logic.answerquestion.answerquestionmanager".getInstance()
    if self.m_lastresult == -1 then
        self.m_head1:SetImage(nil)
        self.m_headName1:setText("")
        self.m_head2:SetImage(nil)
        self.m_head3:SetImage(nil)
        self.m_headName2:setText("")
        self.m_headName3:setText("")
        aqmanager.m_answerid1 = 0
        aqmanager.m_answerid2 = 0
        aqmanager.m_answerid3 = 0
        aqmanager.m_icon1 = ""
        aqmanager.m_icon2 = ""
        aqmanager.m_icon3 = ""
    else 
        if aqmanager.m_xiangguanid == 0 then
            self.m_head1:SetImage(nil)
            self.m_head2:SetImage(nil)
            self.m_head3:SetImage(nil)
            self.m_headName1:setText("")
            self.m_headName2:setText("")
            self.m_headName3:setText("")
            aqmanager.m_answerid1 = 0
            aqmanager.m_answerid2 = 0
            aqmanager.m_answerid3 = 0
            aqmanager.m_icon1 = ""
            aqmanager.m_icon2 = ""
            aqmanager.m_icon3 = ""
        end
    end
    self.m_numTitle:setText(self.m_cur .."/".. self.m_num)

    
    self.m_image1:setProperty("Image",gGetIconManager():GetImagePathByID(record.image1):c_str())
    self.m_image2:setProperty("Image",gGetIconManager():GetImagePathByID(record.image2):c_str())
    self.m_image3:setProperty("Image",gGetIconManager():GetImagePathByID(record.image3):c_str())
    self.m_rewardid = self.m_grab
    gGetGameUIManager():RemoveUIEffect(self.m_reward)
    if self.m_rewardid == 1 then
        NewRoleGuideManager.getInstance():AddParticalEffect(self.m_reward)
        self.m_rewardnot:setVisible(false)
        self.m_reward:setVisible(true)
        self.m_reward:setText("")
    elseif self.m_rewardid == 2 then
        local msgyilingqu = require "utils.mhsdutils".get_resstring(11369)
        self.m_reward:setVisible(false)
        self.m_rewardnot:setVisible(true)
        self.m_reward:setText(msgyilingqu)
    elseif self.m_rewardid == 3 then
        self.m_reward:setText("")
        self.m_reward:setVisible(false)
        self.m_rewardnot:setVisible(true)
    end
end
function AnswerQuestionDlg:refreshUI(saskquestion)

    self.m_true1:setVisible(false)
    self.m_true2:setVisible(false)
    self.m_true3:setVisible(false)
    self.m_false1:setVisible(false)
    self.m_false2:setVisible(false)
    self.m_false3:setVisible(false)
    self.m_numTitle:setText(saskquestion.cur .."/".. saskquestion.num)
    local record = BeanConfigManager.getInstance():GetTableByName("mission.answerquestion"):getRecorder(saskquestion.questionid)
    self.m_name1:setText(record.object1)
    self.m_name2:setText(record.object2)
    self.m_name3:setText(record.object3)
    
    self.mingzi2:setVisible(false)
    self.mingzi3:setVisible(false)
    self.m_head2:setVisible(false)
    self.m_head3:setVisible(false)
    local i = 0
    local msgdi = require "utils.mhsdutils".get_resstring(11361)
    local msgti = require "utils.mhsdutils".get_resstring(11362)
    self.m_textTitle:setText(msgdi..tostring(saskquestion.num+1)..msgti..record.title)
    local tableAllId = BeanConfigManager.getInstance():GetTableByName("mission.answerquestion"):getAllID()
    local nTitleCount = 1
    for _, v in pairs(tableAllId) do
    	local recorda = BeanConfigManager.getInstance():GetTableByName("mission.answerquestion"):getRecorder(v)
        if recorda.topic == record.topic and recorda.id ~=record.id then
            nTitleCount  = nTitleCount + 1
        end
    end
    

    --步骤
    if nTitleCount == 1 then

    elseif nTitleCount == 2 then
        self.mingzi2:setVisible(true)
        self.m_head2:setVisible(true)
        self.m_textTitle:setText(msgdi..tostring(saskquestion.num+1)..msgti..record.title.."("..tostring(record.step).."/2)")
    elseif nTitleCount == 3 then
        self.mingzi2:setVisible(true)
        self.mingzi3:setVisible(true)
        self.m_head2:setVisible(true)
        self.m_head3:setVisible(true)
        self.m_textTitle:setText(msgdi..tostring(saskquestion.num+1)..msgti..record.title.."("..tostring(record.step).."/3)")
    end
    local aqmanager = require "logic.answerquestion.answerquestionmanager".getInstance()
    if aqmanager.m_xiangguanid == 0 then
        self.m_head1:SetImage(nil)
        self.m_head2:SetImage(nil)
        self.m_head3:SetImage(nil)
        self.m_headName1:setText("")
        self.m_headName2:setText("")
        self.m_headName3:setText("")
        aqmanager.m_answerid1 = 0
        aqmanager.m_answerid2 = 0
        aqmanager.m_answerid3 = 0
        aqmanager.m_icon1 = ""
        aqmanager.m_icon2 = ""
        aqmanager.m_icon3 = ""
    elseif aqmanager.m_xiangguanid == 1 then
        if self.m_index == 1 then
            aqmanager.m_answerid1= record.object1
            aqmanager.m_icon1= record.icon1
        elseif self.m_index == 2 then
            aqmanager.m_answerid1= record.object2
            aqmanager.m_icon1= record.icon2
        elseif self.m_index == 3 then
            aqmanager.m_answerid1= record.object3
            aqmanager.m_icon1= record.icon3
        end
        self.m_headName1:setText(aqmanager.m_answerid1)
        self.m_head1:SetImage(gGetIconManager():GetItemIconByID(aqmanager.m_icon1))
        self.m_headName2:setText("")
        self.m_headName3:setText("")
    elseif aqmanager.m_xiangguanid == 2 then

        if self.m_index == 1 then
            aqmanager.m_answerid1= record.object1
            aqmanager.m_icon1= record.icon1
        elseif self.m_index == 2 then
            aqmanager.m_answerid1= record.object2
            aqmanager.m_icon1= record.icon2
        elseif self.m_index == 3 then
            aqmanager.m_answerid1= record.object3
            aqmanager.m_icon1= record.icon3
            
        end
        self.m_headName1:setText(aqmanager.m_answerid1)
        self.m_head1:SetImage(gGetIconManager():GetItemIconByID(aqmanager.m_icon1))
        if self.m_index == 1 then
            aqmanager.m_answerid2= record.object1
            aqmanager.m_icon2= record.icon1
        elseif self.m_index == 2 then
            aqmanager.m_answerid2= record.object2
            aqmanager.m_icon2= record.icon2
        elseif self.m_index == 3 then
            aqmanager.m_answerid2= record.object3
            aqmanager.m_icon2= record.icon3
        end
        self.m_headName2:setText(aqmanager.m_answerid2)
        self.m_head2:SetImage(gGetIconManager():GetItemIconByID(aqmanager.m_icon2))
        self.m_headName3:setText("")
    end
    self.m_nExpAll = saskquestion.totalexp
    self.m_nMoneyAll = saskquestion.totalmoney
    

    --self.m_head1:SetImage("Image",gGetIconManager():GetImagePathByID(record.icon1):c_str())
    self.m_image1:setProperty("Image",gGetIconManager():GetImagePathByID(record.image1):c_str())
    self.m_image2:setProperty("Image",gGetIconManager():GetImagePathByID(record.image2):c_str())
    self.m_image3:setProperty("Image",gGetIconManager():GetImagePathByID(record.image3):c_str())

    --求助次数
    self.m_helpBtn:setText(require "utils.mhsdutils".get_resstring(11507)..tostring(saskquestion.helptimes) .. "/"..tostring(aqhelpMaxNum))
    self.m_helpTimes = saskquestion.helptimes
    self.m_rewardid = saskquestion.grab

    gGetGameUIManager():RemoveUIEffect(self.m_reward)
    if self.m_rewardid == 1 then
        NewRoleGuideManager.getInstance():AddParticalEffect(self.m_reward)
        self.m_rewardnot:setVisible(false)
        self.m_reward:setVisible(true)
        self.m_reward:setText("")
    elseif self.m_rewardid == 2 then
        local msgyilingqu = require "utils.mhsdutils".get_resstring(11369)
        self.m_reward:setVisible(false)
        self.m_rewardnot:setVisible(true)
        self.m_reward:setText(msgyilingqu)
    elseif self.m_rewardid == 3 then
        self.m_reward:setText("")
        self.m_reward:setVisible(false)
        self.m_rewardnot:setVisible(true)
    end
end
--回答问题
function AnswerQuestionDlg:HandleAnswerClicked(args)
    if self.m_status == 1 then
        return
    else
        self.m_status = 1
        self.m_timeDaojishi = 1.0
	    local eventargs = CEGUI.toWindowEventArgs(args)
	    local id = eventargs.window:getID()
        local p = require("protodef.fire.pb.npc.cansweractivityquestion"):new()
        p.answerid = id
        self.m_index = id
	    LuaProtocolManager:send(p)
    end


end
--领奖
function AnswerQuestionDlg:HandleRewardClick(args)
    if self.m_status == 1 then
        return
    end
    -- 1是可以领取2是已经领取3是不能领取
    if self.m_rewardid == 1 then
        local p = require("protodef.fire.pb.npc.cgrabactivityreward"):new()
	    LuaProtocolManager:send(p)  
    elseif self.m_rewardid == 2 then
        local msg = require "utils.mhsdutils".get_msgtipstring(160418)
		GetCTipsManager():AddMessageTip(msg)   
    elseif self.m_rewardid == 3 then
        local msg = require "utils.mhsdutils".get_msgtipstring(160416)
		GetCTipsManager():AddMessageTip(msg)   
    elseif self.m_rewardid == 4 then
        local msg = require "utils.mhsdutils".get_msgtipstring(160406)
		GetCTipsManager():AddMessageTip(msg)  
    end
end
function AnswerQuestionDlg:CloseDialogReward()
    if self.m_rewardid == 1 then
        local p = require("protodef.fire.pb.npc.cgrabactivityreward"):new()
	    LuaProtocolManager:send(p)
    end  
end
function AnswerQuestionDlg:rewardFinish()
    self.m_reward:setText("")
    self.m_reward:setVisible(false)
    self.m_rewardnot:setVisible(true)
    self.m_rewardid = 2     
end

function AnswerQuestionDlg:refreshHelp(num)
    self.m_helpTimes = num
    self.m_helpBtn:setText(require "utils.mhsdutils".get_resstring(11507)..tostring(num) .. "/"..tostring(aqhelpMaxNum))
end
--求助
function AnswerQuestionDlg:HandleHelpClick(args)
    if self.m_status == 1 then
        return
    end
    local datamanager = require "logic.faction.factiondatamanager"
    if datamanager:IsHasFaction() then
        if self.m_helpTimes < aqhelpMaxNum then
            require("logic.openui").OpenUI(44)
            CChatOutputDialog:getInstance():ChangeOutChannel(4)
            CChatOutputDialog:getInstance():RefreshOpenedDlgChannel()
        
            local p = require("protodef.fire.pb.npc.cactivityanswerquestionhelp"):new()
            p.questionid = self.m_Questionid
            LuaProtocolManager:send(p)
            AnswerQuestionDlg.DestroyDialog()
        else
            --超过次数
        end
    else
        local msg = require "utils.mhsdutils".get_msgtipstring(150027)
		GetCTipsManager():AddMessageTip(msg)    
        --没有工会
    end

end
return AnswerQuestionDlg
