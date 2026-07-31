require "logic.dialog"

WenShiHc = {}
setmetatable(WenShiHc, Dialog)
WenShiHc.__index = WenShiHc

local _instance
function WenShiHc.getInstance()
    if not _instance then
        _instance = WenShiHc:new()
        _instance:OnCreate()
    end
    return _instance
end

function WenShiHc.getInstanceAndShow()
    if not _instance then
        _instance = WenShiHc:new()
        _instance:OnCreate()
    else
        _instance:SetVisible(true)
    end
    return _instance
end

function WenShiHc.getInstanceNotCreate()
    return _instance
end

function WenShiHc.DestroyDialog()
    if _instance then
        if not _instance.m_bCloseIsHide then
            _instance:OnClose()
            _instance = nil
        else
            _instance:ToggleOpenClose()
        end
    end
end

function WenShiHc.ToggleOpenClose()
    if not _instance then
        _instance = WenShiHc:new()
        _instance:OnCreate()
    else
        if _instance:IsVisible() then
            _instance:SetVisible(false)
        else
            _instance:SetVisible(true)
        end
    end
end

function WenShiHc.GetLayoutFileName()
    return "wenshihc.layout"
end

function WenShiHc:new()
    local self = {}
    self = Dialog:new()
    setmetatable(self, WenShiHc)
    return self
end

function WenShiHc:OnCreate()
    Dialog.OnCreate(self)
    local winMgr = CEGUI.WindowManager:getSingleton()
    SetPositionOfWindowWithLabel(self:GetWindow())

    self.items={}
    for index=1,3 do
        self.items[index]=CEGUI.toItemCell(winMgr:getWindow("wenshihc/biaoti/item"..index))
        self.items[index]:SetIndex(index)
        self.items[index]:setID(0)
        self.items[index]:subscribeEvent(CEGUI.ItemCell.EventCellClick, WenShiHc.HandleTableClick2, self);
    end

    self.itemname1 = winMgr:getWindow("wenshihc/biaoti/itemname1")
    self.itemname2 = winMgr:getWindow("wenshihc/biaoti/itemname2")
    self.itemname3 = winMgr:getWindow("wenshihc/biaoti/itemname3")

    self.text1 = winMgr:getWindow("wenshihc/biaoti/text11")
    self.text2 = winMgr:getWindow("wenshihc/biaoti/text111")
    self.text3 = winMgr:getWindow("wenshihc/biaoti/text")
    self.text4= winMgr:getWindow("wenshihc/biaoti/text12")

    self.btn1 = CEGUI.toPushButton(winMgr:getWindow("wenshihc/biaoti/btn"));
    self.btn2 = CEGUI.toPushButton(winMgr:getWindow("wenshihc/biaoti/btn1"));
    self.itembtn1 = CEGUI.toPushButton(winMgr:getWindow("wenshihc/biaoti/item1/btn"));
    self.itembtn2 = CEGUI.toPushButton(winMgr:getWindow("wenshihc/biaoti/item2/btn"));


    self.itembtn1:setVisible(false)
    self.itembtn2:setVisible(false)

    self.itembtn1:subscribeEvent("MouseButtonDown", WenShiHc.handleitembtn1Clicked, self)
    self.itembtn2:subscribeEvent("MouseButtonDown", WenShiHc.handleitembtn2Clicked, self)

    self.editbox1 = CEGUI.toRichEditbox(winMgr:getWindow("wenshihc/biaoti/wenshibg/box1"))
    self.editbox2 = CEGUI.toRichEditbox(winMgr:getWindow("wenshihc/biaoti/wenshibg/box2"))
    self.editbox3 = CEGUI.toRichEditbox(winMgr:getWindow("wenshihc/biaoti/wenshibg/box3"))

    self.editbox1:setReadOnly(true)
    self.editbox2:setReadOnly(true)
    self.editbox3:setReadOnly(true)
    self.editbox1:setMousePassThroughEnabled(true)
    self.editbox2:setMousePassThroughEnabled(true)
    self.editbox3:setMousePassThroughEnabled(true)

    self.btn1:subscribeEvent("MouseButtonDown", WenShiHc.handleBtn1Clicked, self)
    self.btn2:subscribeEvent("MouseButtonDown", WenShiHc.handleBtn2Clicked, self)

    self.itemkey1=0
    self.itemkey2=0
	
	
	--关闭按钮
	self.close = winMgr:getWindow("wenshihc/biaoti/x")
	self.close:subscribeEvent("Clicked", self.DestroyDialog, nil)

	
end
function WenShiHc:handleitembtn1Clicked(args)
    self.editbox1:Clear()
    self.editbox1:Refresh()
    self.editbox2:Clear()
    self.editbox2:Refresh()

    --self.editbox3:Clear()
    self.items[1]:Clear()
    self.items[2]:Clear()

    self.items[1]:setID(0)
    self.items[2]:setID(0)

    self.itemname1:setText("")
    self.itemname2:setText("")
    self.itembtn1:setVisible(false)
    self.itembtn2:setVisible(false)
    self.itemkey1=0
    self.itemkey2=0
end
function WenShiHc:handleitembtn2Clicked(args)

    self.editbox2:Clear()
    self.editbox2:Refresh()
    self.items[2]:Clear()
    self.items[2]:setID(0)
    self.itemname2:setText("")
    self.itembtn2:setVisible(false)
    self.itemkey2=0
end
function WenShiHc:UpdateWenShi(key,shuxing,id)
    self.itembtn1:setVisible(false)
    self.itembtn2:setVisible(false)
    if id ==1 then
        --self.text4:setText("合成成功")
		GetCTipsManager():AddMessageTip("合成成功")

		
    elseif id==2 then
        --self.text4:setText("合成失败")
		GetCTipsManager():AddMessageTip("合成失败")

    end
    self.editbox1:Clear()
    self.editbox1:Refresh()
    self.editbox2:Clear()
    self.editbox2:Refresh()
    --self.editbox3:Clear()
    self.items[1]:Clear()
    self.items[2]:Clear()
    self.items[1]:setID(0)
    self.items[2]:setID(0)
    self.itemname1:setText("")
    self.itemname2:setText("")
    self.text1:setVisible(false)
    self.text2:setVisible(false)
    self.text3:setVisible(true)
    self.btn1:setVisible(false)
    self.btn2:setVisible(true)
    local ItemCfg = BeanConfigManager.getInstance():GetTableByName("item.citemattr"):getRecorder(key)

    if ItemCfg then
        self.editbox3:Clear()
        self.items[3]:SetImage(gGetIconManager():GetItemIconByID(ItemCfg.icon))

        self.items[3]:setID(key)
        self.itemname3:setText(ItemCfg.name)
			local ItemCfg2 = BeanConfigManager.getInstance():GetTableByName("item.cwenshiitemshuxing"):getRecorder(ItemCfg.id)
            local vcItemId1 = ItemCfg2.shuxingid1
            local propertyCfg1 = BeanConfigManager.getInstance():GetTableByName("item.cattributedesconfig"):getRecorder(vcItemId1)
            local strTitleName = propertyCfg1.name
			local number = ItemCfg2.shuxingzhi1
            strTitleName = strTitleName .. " " .. "+" .. number
			strTitleName = CEGUI.String(strTitleName)
			self.editbox3:AppendText(strTitleName, CEGUI.ColourRect(CEGUI.PropertyHelper:stringToColour("fffff2df")))
			self.editbox3:AppendBreak()
        -- for k,v in pairs(shuxing) do

            -- local nBaseId = k
            -- local nBaseValue = v
            -- local propertyCfg = BeanConfigManager.getInstance():GetTableByName("item.cattributedesconfig"):getRecorder(math.floor(nBaseId/10)*10)
            -- if nBaseValue ~= 0 then
                -- if propertyCfg ~=nil then
                    -- if propertyCfg and propertyCfg.id ~= -1 then
                        -- local strTitleName = propertyCfg.name
                        -- local nValue = math.abs(nBaseValue)
                        -- local formatted_number = string.format("%.2f", nValue)
                        -- strTitleName = strTitleName .. " " .. "+" .. tostring(formatted_number)
                        -- strTitleName = "  " .. strTitleName
                        -- strTitleName = CEGUI.String(strTitleName)
                        -- self.editbox3:AppendText(strTitleName, CEGUI.ColourRect(CEGUI.PropertyHelper:stringToColour("FF815636")))
                    -- end
                -- end
                -- self.editbox3:AppendBreak()
            -- end
        -- end
        self.editbox3:Refresh()
    end
end
function WenShiHc:UpdateWenShi1(index,key)
    local roleItemManager = require("logic.item.roleitemmanager").getInstance()
    local pItem = roleItemManager:getItem(key, 1)
    if index==1 then
        local ItemCfg = BeanConfigManager.getInstance():GetTableByName("item.citemattr"):getRecorder(pItem:GetBaseObject().id)
        if ItemCfg then
            self.editbox1:Clear()
            self.items[1]:SetImage(gGetIconManager():GetItemIconByID(ItemCfg.icon))
            self.items[1]:setID(key)
            self.itemkey1=key
            self.itemname1:setText(ItemCfg.name)
			local ItemCfg2 = BeanConfigManager.getInstance():GetTableByName("item.cwenshiitemshuxing"):getRecorder(ItemCfg.id)
            local vcItemId1 = ItemCfg2.shuxingid1
            local propertyCfg1 = BeanConfigManager.getInstance():GetTableByName("item.cattributedesconfig"):getRecorder(vcItemId1)
            local strTitleName = propertyCfg1.name
			local number = ItemCfg2.shuxingzhi1
            strTitleName = strTitleName .. " " .. "+" .. number
			strTitleName = CEGUI.String(strTitleName)
			self.editbox1:AppendText(strTitleName, CEGUI.ColourRect(CEGUI.PropertyHelper:stringToColour("fffff2df")))
			self.editbox1:AppendBreak()
			
            local vcItemId2 = ItemCfg2.shuxingid2
            local propertyCfg2 = BeanConfigManager.getInstance():GetTableByName("item.cattributedesconfig"):getRecorder(vcItemId2)
            local strTitleName2 = propertyCfg2.name
			local number2 = ItemCfg2.shuxingzhi2
            strTitleName2 = strTitleName2 .. " " .. "+" .. number2
			strTitleName2 = CEGUI.String(strTitleName2)
			self.editbox1:AppendText(strTitleName2, CEGUI.ColourRect(CEGUI.PropertyHelper:stringToColour("fffff2df")))
			self.editbox1:AppendBreak()
			
            local vcItemId3 = ItemCfg2.shuxingid3
            local propertyCfg3 = BeanConfigManager.getInstance():GetTableByName("item.cattributedesconfig"):getRecorder(vcItemId3)
            local strTitleName3 = propertyCfg3.name
			local number3 = ItemCfg2.shuxingzhi3
            strTitleName3 = strTitleName3 .. " " .. "+" .. number3
			strTitleName3 = CEGUI.String(strTitleName3)
			self.editbox1:AppendText(strTitleName3, CEGUI.ColourRect(CEGUI.PropertyHelper:stringToColour("fffff2df")))
			self.editbox1:AppendBreak()
            self.editbox1:Refresh()
            self.itembtn1:setVisible(true)
        end
    elseif index==2 then
        local ItemCfg = BeanConfigManager.getInstance():GetTableByName("item.citemattr"):getRecorder(pItem:GetBaseObject().id)
        if ItemCfg then
            self.editbox2:Clear()
            self.items[2]:SetImage(gGetIconManager():GetItemIconByID(ItemCfg.icon))
            self.items[2]:setID(key)
            self.itemkey2=key
            self.itemname2:setText(ItemCfg.name)
			local ItemCfg2 = BeanConfigManager.getInstance():GetTableByName("item.cwenshiitemshuxing"):getRecorder(ItemCfg.id)
            local vcItemId1 = ItemCfg2.shuxingid1
            local propertyCfg1 = BeanConfigManager.getInstance():GetTableByName("item.cattributedesconfig"):getRecorder(vcItemId1)
            local strTitleName = propertyCfg1.name
			local number = ItemCfg2.shuxingzhi1
            strTitleName = strTitleName .. " " .. "+" .. number
			strTitleName = CEGUI.String(strTitleName)
			self.editbox2:AppendText(strTitleName, CEGUI.ColourRect(CEGUI.PropertyHelper:stringToColour("fffff2df")))
			self.editbox2:AppendBreak()
			
            local vcItemId2 = ItemCfg2.shuxingid2
            local propertyCfg2 = BeanConfigManager.getInstance():GetTableByName("item.cattributedesconfig"):getRecorder(vcItemId2)
            local strTitleName2 = propertyCfg2.name
			local number2 = ItemCfg2.shuxingzhi2
            strTitleName2 = strTitleName2 .. " " .. "+" .. number2
			strTitleName2 = CEGUI.String(strTitleName2)
			self.editbox2:AppendText(strTitleName2, CEGUI.ColourRect(CEGUI.PropertyHelper:stringToColour("fffff2df")))
			self.editbox2:AppendBreak()
			
            local vcItemId3 = ItemCfg2.shuxingid3
            local propertyCfg3 = BeanConfigManager.getInstance():GetTableByName("item.cattributedesconfig"):getRecorder(vcItemId3)
            local strTitleName3 = propertyCfg3.name
			local number3 = ItemCfg2.shuxingzhi3
            strTitleName3 = strTitleName3 .. " " .. "+" .. number3
			strTitleName3 = CEGUI.String(strTitleName3)
			self.editbox2:AppendText(strTitleName3, CEGUI.ColourRect(CEGUI.PropertyHelper:stringToColour("fffff2df")))
			self.editbox2:AppendBreak()
			
            self.editbox2:Refresh()
            self.itembtn2:setVisible(true)
        end
    -- local ItemCfg = BeanConfigManager.getInstance():GetTableByName("item.citemattr"):getRecorder(pItem:GetBaseObject().id+3)
    -- self.itemname3:setText(ItemCfg.name)
    end
end


function WenShiHc:HandleTableClick2(e)
    local MouseArgs = CEGUI.toMouseEventArgs(e);

    local pCell = CEGUI.toItemCell(MouseArgs.window);

    if (pCell == nil) then

        return true;
    end
    local idx=pCell:getID()
    local index=pCell:GetIndex()
    if index==1 and idx==0 and self.items[3]:getID()==0 then
        require "logic.zuoqi.zuoqicell3":GetSingletonDialogAndShowIt(index)
    elseif index==2 and idx==0 and self.items[1]:getID()~=0 and self.items[3]:getID()==0 then
        require "logic.zuoqi.zuoqicell3":GetSingletonDialogAndShowIt(index,self.items[1]:getID())
    end

    --if idx==0 then
    --	require "logic.item.fabao.fabaoshop".getInstanceAndShow()
    --end


    local pTable = CEGUI.toItemTable(pCell:getParent());
    if (pTable == nil) then
        return true;
    end
    return true;
end

function WenShiHc:handleBtn1Clicked(args)
    if  self.itemkey1==0 or  self.itemkey2==0 then
        return
    end
    local p = require "logic.zuoqi.czuoqizyshiyong":new()
    p.idx = 8--normal
    p.index = self.itemkey1--normal
    p.key = self.itemkey2--normal
    require "manager.luaprotocolmanager":send(p)
end
function WenShiHc:handleBtn2Clicked(args)
    self.editbox1:Clear()
    self.editbox1:Refresh()
    self.editbox2:Clear()
    self.editbox2:Refresh()
    self.editbox3:Clear()
    self.editbox3:Refresh()
    --self.editbox3:Clear()
    self.items[1]:Clear()
    self.items[2]:Clear()
    self.items[3]:Clear()
    self.items[1]:setID(0)
    self.items[2]:setID(0)
    self.items[3]:setID(0)
    self.itemname1:setText("")
    self.itemname2:setText("")
    self.itemname3:setText("")
    self.text4:setText("")
    self.text1:setVisible(true)
    self.text2:setVisible(true)
    self.text3:setVisible(false)
    self.btn1:setVisible(true)
    self.btn2:setVisible(false)
    self.itemkey1=0
    self.itemkey2=0
end
return WenShiHc
