require "logic.dialog"

KejuXiangshi = {}
setmetatable(KejuXiangshi, Dialog)
KejuXiangshi.__index = KejuXiangshi

local _instance
function KejuXiangshi.getInstance()
	if not _instance then
		_instance = KejuXiangshi:new()
		_instance:OnCreate()
	end
	return _instance
end

function KejuXiangshi.getInstanceAndShow()
	if not _instance then
		_instance = KejuXiangshi:new()
		_instance:OnCreate()
	else
		_instance:SetVisible(true)
	end
	return _instance
end

function KejuXiangshi.getInstanceNotCreate()
	return _instance
end

function KejuXiangshi.DestroyDialog()
	if _instance then 
		if not _instance.m_bCloseIsHide then
			_instance:OnClose()
			_instance = nil
		else
			_instance:ToggleOpenClose()
		end
	end
end

function KejuXiangshi.ToggleOpenClose()
	if not _instance then
		_instance = KejuXiangshi:new()
		_instance:OnCreate()
	else
		if _instance:IsVisible() then
			_instance:SetVisible(false)
		else
			_instance:SetVisible(true)
		end
	end
end

function KejuXiangshi.GetLayoutFileName()
	return "keju.layout"
end

function KejuXiangshi:new()
	local self = {}
	self = Dialog:new()
	setmetatable(self, KejuXiangshi)
	return self
end

function KejuXiangshi:OnCreate()
	Dialog.OnCreate(self)
	local winMgr = CEGUI.WindowManager:getSingleton()

    self.m_TimeText=winMgr:getWindow("keju/di1/")
    self.m_textTitle=winMgr:getWindow("keju/di/di/biaoti")
    self.m_object1=winMgr:getWindow("keju/di/di/xuan1/zi")
    self.m_object1:setID(1)
    self.m_object2=winMgr:getWindow("keju/di/di/xuan2/zi")
    self.m_object2:setID(2)
    self.m_object3=winMgr:getWindow("keju/di/di/xuan3/zi")
    self.m_object3:setID(3)
    self.m_object4=winMgr:getWindow("keju/di/di/xuan4/zi")
    self.m_object4:setID(4)
    self.m_ExpAll=winMgr:getWindow("keju/jingyan1")
    self.m_ExpCur=winMgr:getWindow("keju/jingyan2")
    self.m_moneyAll=winMgr:getWindow("keju/yinbi1")
    self.m_moneyCur=winMgr:getWindow("keju/yinbi2")
    self.m_numTitle=winMgr:getWindow("keju/wenben2")
    self.m_indextimu=winMgr:getWindow("keju/di/wenben1")
    self.m_timeEnd = 0
    

    self.m_cuowudi = winMgr:getWindow("keju/cuowudi")
    self.m_tureAnswerChar = winMgr:getWindow("keju/cuowudi/zimu")
    self.m_tureAnswerTxt = winMgr:getWindow("keju/cuowudi/zhengque")
    self.m_cuowudi:setVisible(false)
end



function KejuXiangshi:UpdateTime(delta)
    local time = StringCover.getTimeStruct(gGetServerTime() / 1000)  
    local actnowAll  = time.tm_hour * 3600 + time.tm_min * 60 + time.tm_sec

    local disTime = self.m_timeEnd - actnowAll
    
    --时间到了答题结束
    if disTime<=0 or self.m_Questionid ==0  then
        --self:AnswerQuestionEnd()
        
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

--    if self.m_status == 1 then
--        self.m_timeDaojishi = self.m_timeDaojishi -  delta / 1000

--        if self.m_timeDaojishi<= 0 then
--            self.m_status = 0
--            self:refreshUITime()
--        end

--    end
end
function KejuXiangshi:initTime()
    local tableName = ""
    if IsPointCardServer() then
        tableName = "mission.cactivitynewpay"
    else
        tableName = "mission.cactivitynew"
    end
    local record = BeanConfigManager.getInstance():GetTableByName(tableName):getRecorder(214)
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
return KejuXiangshi
