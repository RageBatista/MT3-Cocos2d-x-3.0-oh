require "logic.dialog"
local xiulianguotipsdlg = require("logic.characterinfo.xiulianguotipsdlg")

CharacterXiulianguoDlg = { }
setmetatable(CharacterXiulianguoDlg, Dialog)
CharacterXiulianguoDlg.__index = CharacterXiulianguoDlg

local _instance

function CharacterXiulianguoDlg.DestroyDialog()
    if _instance then
        Dialog.OnClose(_instance)
        _instance = nil
    end
    XiulianguoTipsDlg.DestroyDialog()
end

function CharacterXiulianguoDlg.getInstance()
    if not _instance then
        _instance = CharacterXiulianguoDlg:new()
        _instance:OnCreate()
    end
    return _instance
end

function CharacterXiulianguoDlg.getInstanceAndShow()
    if not _instance then
        _instance = CharacterXiulianguoDlg:new()
        _instance:OnCreate()
    else
        _instance:SetVisible(true)
    end
    return _instance
end

function CharacterXiulianguoDlg.getInstanceNotCreate()
    return _instance
end



function CharacterXiulianguoDlg.ToggleOpenClose()
    if not _instance then
        _instance = CharacterXiulianguoDlg:new()
        _instance:OnCreate()
    else
        if _instance:IsVisible() then
            _instance:SetVisible(false)
        else
            _instance:SetVisible(true)
        end
    end
end

function CharacterXiulianguoDlg.GetLayoutFileName()
    return "characterxiulianguo.layout"
end

function CharacterXiulianguoDlg:new()
    local self = { }
    self = Dialog:new()
    setmetatable(self, CharacterXiulianguoDlg)
    self.fruits={}
    self.fruitimgs={}
    self.fruitdata={}
    self.jbconf=nil
    self.location=0
    self.openindex=0
    return self
end
function CharacterXiulianguoDlg:req()
	require "protodef.fire.pb.potentialfruit.cquerypotentialfruit"
	local req = CQueryPotentialFruit.Create()
	LuaProtocolManager.getInstance():send(req)
end 

function CharacterXiulianguoDlg:refreshHaveFruit(data)

    local roleItemManager = require("logic.item.roleitemmanager").getInstance()
	local numStr = CEGUI.PropertyHelper:int64_tToString(roleItemManager:GetGold())

	self.yongyou:setText(numStr);
   

    self.fruitdata=data.locations

    
self.openindex=0
    local count=0
    for i = 1, 79 do
        self.fruits[i]:setVisible(false)
        if self.fruitdata~=nil and self.fruitdata[i] then
            local fruit = BeanConfigManager.getInstance():GetTableByName("qiannengguo.CQiannengguo"):getRecorder(self.fruitdata[i])
            if fruit then
                self.fruitimgs[i]:setProperty("Image",fruit.image)
                self.fruits[i]:setVisible(true)
                count=count+1
            end
        else
            if self.openindex==0 then
                self.openindex=i
            end
        end
    end
   
    local t=BeanConfigManager.getInstance():GetTableByName("qiannengguo.CQiannengguoextra")
    local allids=t:getAllID()
 
    for _,id in pairs(allids) do
        local conf = t:getRecorder(id)

        if count>=conf.needcount then
            self.jbconf=conf
        end
    end
    if self.jbconf~=nil then
        self.xiaohao:setText(tostring(self.jbconf.costmoney))
    end

    self.shuliang:setText(tostring(count).."/79")
    local red = CEGUI.ColourRect(CEGUI.PropertyHelper:stringToColour("FF5653E0"))
    local green = CEGUI.ColourRect(CEGUI.PropertyHelper:stringToColour("FF991807"))
    local black = CEGUI.ColourRect(CEGUI.PropertyHelper:stringToColour("FF000000"))
    local pink = CEGUI.ColourRect(CEGUI.PropertyHelper:stringToColour("CA10C100"))
    
    self.propinfo:Clear()
    self.propinfo1:Clear()
     
    if data.props then
        
        self.propinfo:AppendText(CEGUI.String("增加属性"), red)
        self.propinfo:AppendBreak()
        self.propinfo:AppendBreak()
        for k,v in pairs(data.props) do
            local propertyCfg = BeanConfigManager.getInstance():GetTableByName("item.cattributedesconfig"):getRecorder(k)
            if propertyCfg then
                
                self.propinfo:AppendText(CEGUI.String("　"), black)
                self.propinfo:AppendBreak()
                 
                local str1="    "..propertyCfg.name.."  "
                local str2="  +"..tostring(v)
                self.propinfo:AppendText(CEGUI.String(str1), green)
                self.propinfo:AppendText(CEGUI.String(str2), black)
                self.propinfo:AppendBreak()
            end
        end
    end

    if data.extraprops then
        
        self.propinfo1:AppendBreak()
        self.propinfo1:AppendBreak()
        self.propinfo1:AppendText(CEGUI.String("额外增加属性"), red)
        self.propinfo1:AppendBreak()
        self.propinfo1:AppendBreak()
        for k,v in pairs(data.extraprops) do
            local propertyCfg = BeanConfigManager.getInstance():GetTableByName("item.cattributedesconfig"):getRecorder(k)
            if propertyCfg then
                self.propinfo1:AppendText(CEGUI.String("　"), black)
                self.propinfo1:AppendBreak()
                 
                local str1="    "..propertyCfg.name.."  "
                local str2="  +"..tostring(v)
                self.propinfo1:AppendText(CEGUI.String(str1), green)
                self.propinfo1:AppendText(CEGUI.String(str2), black)
                self.propinfo1:AppendBreak()
            end
        end
    end

    self.propinfo:AppendBreak()
    self.propinfo:Refresh()
    self.propinfo1:AppendBreak()
    self.propinfo1:Refresh()
end

function CharacterXiulianguoDlg:HandleFruitClick(args)
	local winargs = CEGUI.toWindowEventArgs(args)
	local btn = winargs.window
	local btnID = btn:getID()
    self.location=btnID
    if self.fruitdata~=nil and self.fruitdata[btnID] then
        xiulianguotipsdlg.ShowTip(btnID,self.fruitdata[btnID])
    end

  
end
function CharacterXiulianguoDlg:HandleResetExtraClicked(args)
    require "protodef.fire.pb.potentialfruit.cresetpotentialfruitextra"
	local req = CResetPotentialFruitExtra.Create()
	req.location = self.location
	LuaProtocolManager.getInstance():send(req)
end

function CharacterXiulianguoDlg:HandleOpenClicked(args)
    local function ClickYes(args)        
        gGetMessageManager():CloseConfirmBox(eConfirmOK, false)
        local location=self.openindex
        require "protodef.fire.pb.potentialfruit.COpenPotentialFruit"
        local req = COpenPotentialFruit.Create()
        req.location =location
        LuaProtocolManager.getInstance():send(req)
    end
    local function ClickNo(args)        
        gGetMessageManager():CloseConfirmBox(eConfirmOK, false)
    end
    if self.openindex~=0 then
        local fruit = BeanConfigManager.getInstance():GetTableByName("qiannengguo.CQiannengguoLevelUp"):getRecorder(self.openindex)
        local str="开启第"..tostring(self.openindex).."颗潜能果，需要消耗"..tostring(fruit.levelupvalue).."经验,您要开启吗?"
        gGetMessageManager():AddConfirmBox(eConfirmOK, str, ClickYes, 0, ClickNo, 0)
    
    end
end

function CharacterXiulianguoDlg:ShowExp()
    local data = gGetDataManager():GetMainCharacterData()

    if data.nexp == 0 then
    	self.m_pExp:setTooltipText("")
		self.m_pExp:setProgress(0.0)
        self.m_pExp:setText("0/0")
    else
        local exp = data.exp/data.nexp
        self.m_pExp:setTooltipText(tostring(data.exp).."/"..tostring(data.nexp))
        self.m_pExp:setText(tostring(data.exp).."/"..tostring(data.nexp))
        self.m_pExp:setProgress(exp)
    end
end


function CharacterXiulianguoDlg:HandlClickBg(e)
	XiulianguoTipsDlg.DestroyDialog()
end
function CharacterXiulianguoDlg:OnCreate()
    Dialog.OnCreate(self)
    SetPositionOfWindowWithLabel(self:GetWindow())
	local winMgr = CEGUI.WindowManager:getSingleton()
	local winbg = winMgr:getWindow("characterxiulianguodlg")
	winbg:subscribeEvent("MouseClick", CharacterXiulianguoDlg.HandlClickBg, self) 


    self.m_bg = CEGUI.toFrameWindow(winMgr:getWindow("characterxiulianguodlg"))
    for i=1,79 do
        self.fruits[i] = CEGUI.Window.toGroupButton(winMgr:getWindow("characterxiulianguodlg/main/xiulianguo_"..tostring(i)))
        self.fruits[i]:setID(i)
        self.fruits[i]:subscribeEvent("SelectStateChanged", CharacterXiulianguoDlg.HandleFruitClick, self)
        self.fruits[i]:setVisible(false)
    end

    
    for i=1,79 do
        self.fruitimgs[i] = winMgr:getWindow("characterxiulianguodlg/main/xiulianguo_"..tostring(i).."/img")
    end
    self.propinfo = CEGUI.toRichEditbox(winMgr:getWindow("characterxiulianguodlg/left/shuxinglan"))
    self.propinfo1 = CEGUI.toRichEditbox(winMgr:getWindow("characterxiulianguodlg/left/shuxinglan1"))
    
    self:GetCloseBtn():removeEvent("Clicked")
    self:GetCloseBtn():subscribeEvent("Clicked", CharacterXiulianguoDlg.DestroyDialog, nil)

    self.jichuBtn = CEGUI.toGroupButton(winMgr:getWindow("characterxiulianguodlg/jichu"))
    self.ewaiBtn = CEGUI.toGroupButton(winMgr:getWindow("characterxiulianguodlg/ewai"))
    self.jichuBtn:subscribeEvent("SelectStateChanged", self.HandleClikBtnJichu, self)
    self.ewaiBtn:subscribeEvent("SelectStateChanged", self.HandleClikBtnEWai, self)
    self.jichuBtn:setSelected(true)


    self.m_pBtnResetExtra = CEGUI.Window.toPushButton(winMgr:getWindow("characterxiulianguodlg/chongzhi"))
    self.m_pBtnResetExtra:subscribeEvent("Clicked", CharacterXiulianguoDlg.HandleResetExtraClicked, self)
    self.m_pBtnOpen = CEGUI.Window.toPushButton(winMgr:getWindow("characterxiulianguodlg/duihuan"))
    self.m_pBtnOpen:subscribeEvent("Clicked", CharacterXiulianguoDlg.HandleOpenClicked, self)

    self.m_pExp = CEGUI.Window.toProgressBar(winMgr:getWindow("characterxiulianguodlg/exp"))

    self.yongyou = winMgr:getWindow("characterxiulianguodlg/yuanbao2")
    self.xiaohao = winMgr:getWindow("characterxiulianguodlg/yuanbao21")
    

    local roleItemManager = require("logic.item.roleitemmanager").getInstance()
	local numStr = CEGUI.PropertyHelper:int64_tToString(roleItemManager:GetGold())

	self.yongyou:setText(numStr);
    

    self.shuliang=winMgr:getWindow("characterxiulianguodlg/jingyan11")
    self:ShowExp()
    self:req()
    self:HandleClikBtnJichu()
end

function CharacterXiulianguoDlg:HandleClikBtnJichu()


    self.propinfo:setVisible(true)
    self.propinfo1:setVisible(false)
end

function CharacterXiulianguoDlg:HandleClikBtnEWai()
    self.propinfo:setVisible(false)
    self.propinfo1:setVisible(true)
end

return CharacterXiulianguoDlg
