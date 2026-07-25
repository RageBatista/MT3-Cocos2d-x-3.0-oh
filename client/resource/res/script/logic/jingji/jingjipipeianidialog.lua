
Jingjipipeianidialog = {}
Jingjipipeianidialog.__index = Jingjipipeianidialog

local nPrefix = 0

function Jingjipipeianidialog.create(parent,nSpaceX,strColor)
    local newDlg = Jingjipipeianidialog:new()
    newDlg:clearData()
    newDlg:OnCreate(parent,nSpaceX,strColor)
    
    return newDlg
end

function Jingjipipeianidialog:clearData()
    self.vText = {}
    self.vAnimation = {}
end
--//===============================
function Jingjipipeianidialog:OnCreate(parent,nSpaceX,strColor)
    
    if not strColor then
        strColor = "FFFAD05F"
    end
  local winMgr = CEGUI.WindowManager:getSingleton()
    
  local nWidth = 30
  local nHeight = 30
  --11463
  local strPipeizhongzi = require("utils.mhsdutils").get_resstring(11463)
  local vTextzi = require("utils.stringbuilder").Split(strPipeizhongzi, ";")
        

   for nIndex=1,6 do
        local strText = vTextzi[nIndex]
        local t = winMgr:createWindow("TaharezLook/StaticText")
        t:setSize(CEGUI.UVector2(CEGUI.UDim(0, nWidth), CEGUI.UDim(0, nHeight)))
        local nPosX = (nWidth+nSpaceX) * (nIndex-1)
        t:setPosition(CEGUI.UVector2(CEGUI.UDim(0,nPosX), CEGUI.UDim(0,0 )))
	    t:setProperty("HorzFormatting", "HorzCentred")
	    t:setProperty("VertFormatting", "VertCentred")
	    t:setProperty("TextColours", strColor) --"FF003454"
	    t:setProperty("Font", "simhei-12")
	    t:setText(strText)
        t:setClippedByParent(false)
        if parent then
            parent:addChildWindow(t) 
        end
        self.vText[nIndex] = t
  end
      
  self:startTimer()
    
end

function Jingjipipeianidialog:setTextBorderColor(strColor)  
    strColor = CEGUI.ColourRect(CEGUI.PropertyHelper:stringToColour(strColor))
    for k,labelText in pairs(self.vText) do
        labelText:SetTextBoder(true)
        labelText:SetTextBorderColour(strColor)
    end
end


function Jingjipipeianidialog:startTimer()
    local timerData = {}
    require("logic.task.schedulermanager").getInstance():getTimerDataInit(timerData)
    local  Schedulermanager = require("logic.task.schedulermanager")
	--//=======================================
	timerData.eType = Schedulermanager.eTimerType.repeatCount
	timerData.fDurTime = 0.1
	timerData.nRepeatCount = 6
	--timerData.nParam1 = nTaskTypeId
    timerData.pTarget = self
    timerData.callback= Jingjipipeianidialog.timerCallBack
	--//=======================================
	require("logic.task.schedulermanager").getInstance():addTimer(timerData)

   
end

function Jingjipipeianidialog:timerCallBack(timerData)
    local nIndex = timerData.nRepeatCountDt
    local label = self.vText[nIndex]
    if not label then
        return
    end

    
    local aniMan = CEGUI.AnimationManager:getSingleton()
    local animationOpen = aniMan:getAnimation("Pet_egg1")
    local aniopen = aniMan:instantiateAnimation(animationOpen)
    if aniopen ~= nil then
        aniopen:setTargetWindow(label)
        aniopen:unpause()   
        self.vAnimation[nIndex] = aniopen
    end
end




function Jingjipipeianidialog:new()
    local self = {}
    setmetatable(self, Jingjipipeianidialog)
    return self
end

function Jingjipipeianidialog:DestroyDialog()
	require("logic.task.schedulermanager").getInstance():deleteTimerWithTarget(self)

    local aniMan = CEGUI.AnimationManager:getSingleton()

    for k,ani in pairs(self.vAnimation) do
         aniMan:destroyAnimationInstance(ani)
    end
   

	--CEGUI.WindowManager:getSingleton():destroyWindow(self.m_pMainFrame)
end


return Jingjipipeianidialog
