require "logic.dialog"

Zuoqity = {}
setmetatable(Zuoqity, Dialog)
Zuoqity.__index = Zuoqity

local _instance
function Zuoqity.getInstance()
    if not _instance then
        _instance = Zuoqity:new()
        _instance:OnCreate()
    end
    return _instance
end

function Zuoqity.getInstanceAndShow()
    if not _instance then
        _instance = Zuoqity:new()
        _instance:OnCreate()
    else
        _instance:SetVisible(true)
    end
    return _instance
end

function Zuoqity.getInstanceNotCreate()
    return _instance
end

function Zuoqity.DestroyDialog()
    if _instance then
        if not _instance.m_bCloseIsHide then
            _instance:OnClose()
            _instance = nil
        else
            _instance:ToggleOpenClose()
        end
    end
end

function Zuoqity.ToggleOpenClose()
    if not _instance then
        _instance = Zuoqity:new()
        _instance:OnCreate()
    else
        if _instance:IsVisible() then
            _instance:SetVisible(false)
        else
            _instance:SetVisible(true)
        end
    end
end

function Zuoqity.GetLayoutFileName()
    return "zuoqity.layout"
end

function Zuoqity:new()
    local self = {}
    self = Dialog:new()
    setmetatable(self, Zuoqity)
    return self
end

function Zuoqity:OnCreate()
    Dialog.OnCreate(self)
    local winMgr = CEGUI.WindowManager:getSingleton()

    --SetPositionOfWindowWithLabel(self:GetWindow())
    -- self:GetCloseBtn():removeEvent("Clicked")
    --self:GetCloseBtn():subscribeEvent("Clicked", RanSeLabel.DestroyDialog, nil)

    self.leftDown = false;
    self.rightDown = false;
    self.downTime = 0;
    self.state = 0;
    self.turnL = CEGUI.toPushButton(winMgr:getWindow("zuoqity/xuanniu"));
    self.turnR = CEGUI.toPushButton(winMgr:getWindow("zuoqity/xuanniu2"));
    self.m_btnguanbi = CEGUI.toPushButton(winMgr:getWindow("zuoqity/back"))
    self.GetMounts = winMgr:getWindow("zuoqity/diban/getmount")



    self.turnL:subscribeEvent("MouseButtonDown", Zuoqity.handleLeftClicked, self)
    self.turnR:subscribeEvent("MouseButtonDown", Zuoqity.handleRightClicked, self)
    self.turnL:subscribeEvent("MouseButtonUp", Zuoqity.handleLeftUp, self)
    self.turnR:subscribeEvent("MouseButtonUp", Zuoqity.handleRightUp, self)
    self.turnL:subscribeEvent("MouseLeave", Zuoqity.handleLeftUp, self)
    self.turnR:subscribeEvent("MouseLeave", Zuoqity.handleRightUp, self)
    self.m_btnguanbi:subscribeEvent("Clicked", Zuoqity.handleQuitBtnClicked, self)
    self.GetMounts:subscribeEvent("Clicked", Zuoqity.HandleGetMountsBtnClicked, self)

    self.shiyongBtn = CEGUI.toPushButton(winMgr:getWindow("zuoqity/huanyuan111"))--宠物染色
    self.shiyongBtn:subscribeEvent("Clicked", Zuoqity.handleShiYongClicked, self)
    --self.goumaiBtn = CEGUI.toPushButton(winMgr:getWindow("zuoqity/huanyuan11"))--宠物染色
    --self.goumaiBtn:subscribeEvent("Clicked", Zuoqity.handleGouMaiClicked, self)
    --self.shiyongBtn:setVisible(false)
    --self.goumaiBtn:setVisible(false)

    --self.cbTipBtn1 = CEGUI.toPushButton(winMgr:getWindow("zuoqity/yichu1"))--????
    --self.cbTipBtn1:subscribeEvent("Clicked", self.handleCombineTipClicked1, self)
    --
    --self.cbTipBtn2 = CEGUI.toPushButton(winMgr:getWindow("zuoqity/yichu2"))--????
    --self.cbTipBtn2:subscribeEvent("Clicked", self.handleCombineTipClicked2, self)
    --
    --self.cbTipBtn3 = CEGUI.toPushButton(winMgr:getWindow("zuoqity/yichu3"))--????
    --self.cbTipBtn3:subscribeEvent("Clicked", self.handleCombineTipClicked3, self)
    --
    --self.cbTipBtn4 = CEGUI.toPushButton(winMgr:getWindow("zuoqity/yichu4"))--????
    --self.cbTipBtn4:subscribeEvent("Clicked", self.handleCombineTipClicked4, self)



    --self.shichuan = CEGUI.toPushButton(winMgr:getWindow("zuoqity/biaoti/qiehuan"));
    --self.shichuan:subscribeEvent("Clicked", Zuoqity.handleShiChuanClicked, self)
    --self.shichuan:EnableClickAni(false)

---------------------------------------------------------------------------------
    self.wenshiopen1 = winMgr:getWindow("zuoqity/biaoti/wenshiopen")
    self.wenshiopen2 = winMgr:getWindow("zuoqity/biaoti/wenshibg")
    self.wenshiopen1:setVisible(false)
    self.wenshiopen2:setVisible(false)


    self.kaiqi = CEGUI.toPushButton(winMgr:getWindow("zuoqity/huanyuan112"));
    self.kaiqi:subscribeEvent("Clicked", Zuoqity.handlekaiqiClicked, self)
    self.kaiqi:EnableClickAni(false)


    --self.huobi1 = winMgr:getWindow("zuoqity/textzong/yinbi2")
    --self.huobi2 = winMgr:getWindow("zuoqity/textzong/yinbi21")
    self.jiage = winMgr:getWindow("zuoqity/textdan2")
    self.ownMoneyText = winMgr:getWindow("zuoqity/textdan11")



    self.petname1 = winMgr:getWindow("zuoqity/biaoti/btnjichu/petname1")
    self.petname1:setMousePassThroughEnabled(true)
    self.petname2 = winMgr:getWindow("zuoqity/biaoti/btnjichu/petname2")
    self.petname2:setMousePassThroughEnabled(true)


    self.jichu = winMgr:getWindow("zuoqity/biaoti/btnjichu")
    self.jiacheng = winMgr:getWindow("zuoqity/biaoti/btnjiacheng")
    self.wushuxing = winMgr:getWindow("zuoqity/biaoti/btnjiacheng/wu")
    self.mapSysBtn={}
    for index=1,2 do
        self.mapSysBtn[index] = CEGUI.toGroupButton(winMgr:getWindow("zuoqity/biaoti/wenshibg/btn"..index))
        self.mapSysBtn[index]:setID(index)
        self.mapSysBtn[index]:subscribeEvent("SelectStateChanged", Zuoqity.handleGroupBtnClicked, self)
    end
    self.mapSysBtn[1]:setSelected(true)
    self.wenshiitems={}
    for index=1,3 do
        self.wenshiitems[index]=CEGUI.toItemCell(winMgr:getWindow("zuoqity/biaoti/btnjichu/item"..index))
        self.wenshiitems[index]:SetIndex(index)
        self.wenshiitems[index]:setID(0)
        self.wenshiitems[index]:subscribeEvent(CEGUI.ItemCell.EventCellClick, Zuoqity.HandleTableClick2, self);
    end


    self.editbox = CEGUI.toRichEditbox(winMgr:getWindow("zuoqity/biaoti/btnjiacheng/shuxing"))

    self.tongyuBtn={}
    self.peticon={}
    self.petname={}
    for index=1,2 do
        self.tongyuBtn[index] = CEGUI.toGroupButton(winMgr:getWindow("zuoqity/biaoti/btnjichu/tongyu"..index))
        self.peticon[index]=CEGUI.toItemCell(winMgr:getWindow("zuoqity/biaoti/btnjichu/peticon"..index))
        self.petname[index]=winMgr:getWindow("zuoqity/biaoti/btnjichu/petname"..index)
        self.peticon[index]:setID(0)
        self.peticon[index]:SetIndex(index)
        self.tongyuBtn[index]:setID(index)
        self.tongyuBtn[index]:subscribeEvent("MouseButtonUp", Zuoqity.handlePetGroupBtnClicked, self)
    end

    self.tzskill= CEGUI.toSkillBox(winMgr:getWindow("zuoqity/biaoti/btnjichu/skill"))
    self.tzskill:subscribeEvent("MouseClick", Zuoqity.handleSkillClicked, self)




    self.tzs = CEGUI.toPushButton(winMgr:getWindow("zuoqity/textdan11/huoqu1"));
    self.tzs:subscribeEvent("Clicked", Zuoqity.handletzsClicked, self)


-----------------------------------------------------------------------------------
    local data = gGetDataManager():GetMainCharacterData()
    self.dir = Nuclear.XPDIR_BOTTOMRIGHT;
    self.canvas = winMgr:getWindow("zuoqity/beijing/moxing")


    self.zuoqis = {};

		local data = gGetDataManager():GetMainCharacterData()
	local shapeConf = BeanConfigManager.getInstance():GetTableByName("npc.cnpcshape"):getRecorder(data.shape)
	local weapon = 0
	if shapeConf then
		weapon = shapeConf.showWeaponId
	end

	
	
	
	
	
	
	
	
	
    self.sprite = gGetGameUIManager():AddWindowSprite(self.canvas, data.shape, self.dir, 0, 0, true)
    local rideItemId = RoleItemManager.getInstance():getRideItemId()
    if rideItemId~=0 then
        local zuoqi =BeanConfigManager.getInstance():GetTableByName("npc.crideitem"):getRecorder(rideItemId)
        local zuoqis = BeanConfigManager.getInstance():GetTableByName("npc.cride"):getRecorder(zuoqi.rideid)
        -- local yanse = GetMainCharacter():GetSpriteComponent(102)
        -- if yanse then
            -- local record = BeanConfigManager.getInstance():GetTableByName("item.czuoqicolour"):getRecorder(yanse)
            -- self.sprite:SetSpriteComponent(eSprite_Horse, zuoqis.ridemodel,Nuclear.NuclearColor(tonumber("0x"..record.yanse)))
        -- else
          
        local wuqi = GetMainCharacter():GetSpriteComponent(eSprite_Weapon)
					self.sprite:SetSpriteComponent(eSprite_Weapon,wuqi)
    local pA = GetMainCharacter():GetSpriteComponent(eSprite_DyePartA)
    local pB = GetMainCharacter():GetSpriteComponent(eSprite_DyePartB)
    self.sprite:SetDyePartIndex(0, pA)
    self.sprite:SetDyePartIndex(1, pB)
    self.sprite:SetSpriteComponent(eSprite_Horse, zuoqis.ridemodel)
	self.sprite:SetUIDirection(Nuclear.XPDIR_BOTTOMRIGHT)
        --end


    end

    self.partList = {};
    self.partList[1] = {}
    self.partList[2] = {}
    self.colorList = {};
    self.colorList[1] = {}
    self.colorList[2] = {}
    local ids = BeanConfigManager.getInstance():GetTableByName("role.crolercolorconfig"):getAllID()
    local num = table.getn(ids)
    for i = 1, num do
        if ids[i] < 1000 then
            local record = BeanConfigManager.getInstance():GetTableByName("role.crolercolorconfig"):getRecorder(ids[i])
            table.insert(self.partList[record.rolepos], record.id)
            --colorlist 角色1颜色图,角色2颜色图...
            local clr = record.colorlist[data.shape - 1010101]
            --rolepos 部位
            table.insert(self.colorList[record.rolepos], clr)
        end
    end
    self.currentIDA = 1;
    self.currentIDB = 1;

    self.ItemCellNeedItem1 = CEGUI.toItemCell(winMgr:getWindow("zuoqity/ranliao1"))

    self.ItemCellNeedItem1:setVisible(false)


    self.neeItemCountText1 = winMgr:getWindow("zuoqity/ranliaoshu1")

    self.neeItemCountText1:setText("")

    self.neeItemNameText1 = winMgr:getWindow("zuoqity/ranliaoming1")

    self.neeItemNameText1:setText("")
    self.select = 0;
    self.selectye = 0;
    self.data=nil
    self.m_szList2 = {}
    self.ItemCellNeedItem1:setVisible(false)
    self.neeItemNameText1:setVisible(true)
    self.neeItemCountText1:setVisible(false)
    -- local ids =BeanConfigManager.getInstance():GetTableByName("item.cshizhuangyichu"):getAllID()
    self.szlistWnd = CEGUI.toScrollablePane(winMgr:getWindow("zuoqity/biaoti/shizhuang/szs"));
    self.szlistWnd:EnableHorzScrollBar(false)
    local cmd = require "logic.zuoqi.czuoqizyyongyou".Create()
    LuaProtocolManager.getInstance():send(cmd)
    self.szlistWnd2 = CEGUI.toScrollablePane(winMgr:getWindow("zuoqity/biaoti/shizhuang/szs1"));
    self.szlistWnd2:EnableHorzScrollBar(false)
    self:refreshSzTable()
end

function Zuoqity:handletzsClicked(args)
    require "logic.zuoqi.zuoqitz".getInstanceAndShow()
end
function Zuoqity:handleSkillClicked(args)
    local wnd = CEGUI.toWindowEventArgs(args).window
    local idx = wnd:getID()

    local cell = CEGUI.toSkillBox(CEGUI.toWindowEventArgs(args).window)

    if cell:GetSkillID() ~= 0 then
        local tip = PetSkillTipsDlg.ShowTip(cell:GetSkillID())

        PetSkillTipsDlg.GetPetData(self.selectedPetKey,idx)
        local s = GetScreenSize()
        SetPositionOffset(tip:GetWindow(), s.width*0.5, s.height*0.5, 1, 0.5)
    end

end
function Zuoqity:HandleTableClick2(e)
    local MouseArgs = CEGUI.toMouseEventArgs(e);

    local pCell = CEGUI.toItemCell(MouseArgs.window);

    if (pCell == nil) then

        return true;
    end
    local idx=pCell:getID()
    local index=pCell:GetIndex()
	
	
	-- self.wenshiitems[1]:SetSelected(false)
	-- self.wenshiitems[2]:SetSelected(false)
	-- self.wenshiitems[3]:SetSelected(false)
	-- self.wenshiitems[index]:SetSelected(true)
	self.wenshiitems[1]:SetCornerImageAtPos(nil, 2, 1)
	self.wenshiitems[2]:SetCornerImageAtPos(nil, 2, 1)
	self.wenshiitems[3]:SetCornerImageAtPos(nil, 2, 1)
	self.wenshiitems[index]:SetCornerImageAtPos("my_xinpan1", "xz_1",2, 1,-6,-6) --数值型 参数一   二:大小  三: x值  四: y值

	

    if idx==0 then
        require "logic.zuoqi.zuoqicell1":GetSingletonDialogAndShowIt(index,self.select,self.data)
    else
        local tip =  require "logic.zuoqi.wenshitips".ShowTip(self.data,index,self.select)
        local pos = pCell:GetScreenPosOfCenter()

        SetPositionOffset(tip:GetWindow(),400, 163, 0.1, 0.1)
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



function Zuoqity:handlePetGroupBtnClicked(args)
    local index = CEGUI.toWindowEventArgs(args).window:getID()
    --self:showSysIdFromBtn(nSysId)
    for nSysId, pBtn in pairs(self.tongyuBtn) do
        if nSysId == index then
            pBtn:setSelected(true)
        else
            pBtn:setSelected(false)
        end
    end
    if  self.peticon[index]:getID()==0 then
        require "logic.zuoqi.zuoqicell2":GetSingletonDialogAndShowIt(index,self.select,self.data)
    else
        local tip =  require "logic.zuoqi.zuoqipettips".ShowTip(self.data,index,self.select)

        SetPositionOffset(tip:GetWindow(),800, 263, 0.1, 0.1)
    end

end
function Zuoqity:handleGroupBtnClicked(args)
    local index = CEGUI.toWindowEventArgs(args).window:getID()
    --self:showSysIdFromBtn(nSysId)
    for nSysId, pBtn in pairs(self.mapSysBtn) do
        if nSysId == index then
            pBtn:setSelected(true)
        else
            pBtn:setSelected(false)
        end
    end
    self.jichu:setVisible(false)
    self.jiacheng:setVisible(false)
    if index==1 then
        self.jichu:setVisible(true)
    else

        self.jiacheng:setVisible(true)
    end
end

function Zuoqity:handlekaiqiClicked(args)

    local cmd = require "logic.zuoqi.czuoqizyyongyou".Create()
    cmd.idx = 2
    cmd.index = self.select
    LuaProtocolManager.getInstance():send(cmd)
end
function Zuoqity:handleShiYongClicked(args)
    if self.select~=0 then
        --local data = gGetDataManager():GetMainCharacterData()
        local cmd = require "logic.zuoqi.czuoqizyshiyong":new()
        cmd.zuoqiid = self.select
        cmd.idx=1
        LuaProtocolManager.getInstance():send(cmd)
        self.DestroyDialog()
    end
end
--function Zuoqity:handleGouMaiClicked(args)
--     if self.selectitem~=0 then
--     local cmd = require "logic.zuoqi.czuoqigoumai":new()
--     cmd.zuoqiid = self.selectitem
--     LuaProtocolManager.getInstance():send(cmd)
--     end
--end
function Zuoqity:HandleGetMountsBtnClicked(args)
    require("logic.zuoqi.lingqixvyuanchiDlg").getInstanceAndShow()
    self:DestroyDialog()
end

function Zuoqity:refreshSzTable(data)
    if not data then
        return
    end
    for index=1,3 do
        self.wenshiitems[index]:setID(0)
        --self.wenshiitems[index]:SetImage(nil)
        self.wenshiitems[index]:SetImage("my_zuoqi", "jia")
		self.wenshiitems[index]:SetCornerImageAtPos(nil, 1, 0.5)
    end
    for index=1,2 do
        self.peticon[index]:setID(0)
        self.peticon[index]:SetImage(nil)
        self.petname[index]:setText("点击统御召唤灵")
    end

    self.data=data
    self.wenshiopen1:setVisible(false)
    self.wenshiopen2:setVisible(false)
    if data.weishiopen==0 then
        self.wenshiopen1:setVisible(true)
        self.jiage:setText(GameTable.common.GetCCommonTableInstance():getRecorder(591).value)
        self.ownMoneyText:setText(gGetDataManager():GetYuanBaoNumber())
    else
        ------------------------------------------------------------------------------
        self.wushuxing:setVisible(false)
        self.wenshiopen2:setVisible(true)
        self.shuxings={}
        local shuxingnum=0
        for k,v in pairs(data.wenshiitems) do
            self.wenshiitems[k]:setID(v.id)
            local needItemCfg = BeanConfigManager.getInstance():GetTableByName("item.citemattr"):getRecorder(v.id)
            self.wenshiitems[k]:SetImage(gGetIconManager():GetItemIconByID(needItemCfg.icon))
			self.wenshiitems[k]:SetCornerImageAtPos("my_zuoqi", "lan", 1, 1,1,1) --数值型 参数一   二:大小  三: x值  四: y值

            for key,value in pairs(v.shuxing) do
                shuxingnum=shuxingnum+1
                if self.shuxings[key] then
                    self.shuxings[key] = self.shuxings[key]+value
                else
                    self.shuxings[key]=value
                end
            end
        end

        self.tzskill:Clear()
        self.editbox:Clear()
        if shuxingnum<=0 then
            self.wushuxing:setVisible(true)
        else
            self.tzskill:Clear()
            for k,v in pairs(self.shuxings) do
                local nBaseId = k
                local nBaseValue = v
                local propertyCfg = BeanConfigManager.getInstance():GetTableByName("item.cattributedesconfig"):getRecorder(math.floor(nBaseId/10)*10)
                if nBaseValue ~= 0 then
                    if propertyCfg ~=nil then
                        if propertyCfg and propertyCfg.id ~= -1 then
                            local strTitleName = propertyCfg.name
                            local nValue = math.abs(nBaseValue)
                            --local nValue = pEquipData.petequipprovalue
                            local formatted_number = string.format("%.2f", nValue)
                            strTitleName = strTitleName .. " " .. "+" .. tostring(formatted_number)
                            strTitleName = "  " .. strTitleName
                            strTitleName = CEGUI.String(strTitleName)
                            self.editbox:AppendText(strTitleName, CEGUI.ColourRect(CEGUI.PropertyHelper:stringToColour("FF815636")))
                        end
                    end
                    self.editbox:AppendBreak()
                end
            end
            SetPetSkillBoxInfo(self.tzskill, data.tzid)
			self.tzskill:SetBackGroundImage(CEGUI.String("chongwuui3"), CEGUI.String("cwtesu"))


        end
        self.editbox:Refresh()
        ------------------------------------------------------------------------------------
        for k,v in pairs(data.petkey) do
            self.peticon[k]:setID(v)
            local petData = MainPetDataManager.getInstance():FindMyPetByID(v)
            --local conf = BeanConfigManager.getInstance():GetTableByName("pet.cpetattr"):getRecorder(petData.baseid)
            SetPetItemCellInfo3(self.peticon[k], petData)
            self.petname[k]:setText(petData.name)
        end

    end

end

function Zuoqity:refreshSzTable2(szList)
    local sz = #self.m_szList2
    for index  = 1, sz do
        local lyout = self.m_szList2[1]
        lyout.addclick = nil
        lyout.LevelText = nil
        self.szlistWnd2:removeChildWindow(lyout)
        CEGUI.WindowManager:getSingleton():destroyWindow(lyout)
        table.remove(self.m_szList2,1)
    end
    local winMgr = CEGUI.WindowManager:getSingleton()
    local sx = 2.0;
    local sy = 2.0;
    local index = 0
    local index2 = 0
    self.m_szList2 = {}
    for k,v in pairs(szList) do
        self.zuoqis[k]=v
        local zuoqi =BeanConfigManager.getInstance():GetTableByName("npc.crideitem"):getRecorder(k)
        local itemattr = BeanConfigManager.getInstance():GetTableByName("item.citemattr"):getRecorder(k)
        --local zuoqis = BeanConfigManager.getInstance():GetTableByName("npc.cride"):getRecorder(zuoqi.rideid)
        local sID = "Zuoqity2" .. tostring(index)
        local lyout = winMgr:loadWindowLayout("zuoqitycell2.layout",index);
        self.szlistWnd2:addChildWindow(lyout)
        if index2>=3 then
            index2=0
        end
        lyout:setPosition(CEGUI.UVector2(CEGUI.UDim(0.0, sx + index2 * (lyout:getWidth().offset-13)), CEGUI.UDim(0.0, sy + math.floor(index/3) * (lyout:getHeight().offset-13))))
        index2=index2+1

        lyout.addclick =  CEGUI.toGroupButton(winMgr:getWindow(index.."zuoqitycell2"));
        lyout.addclick:setID(k)
        lyout.addclick:subscribeEvent("MouseButtonUp", Zuoqity.handleSzSelected2, self)
        lyout.szCell = CEGUI.toItemCell(winMgr:getWindow(index.."zuoqitycell2/touxiang"))
        --local shapeData = BeanConfigManager.getInstance():GetTableByName("npc.cnpcshape"):getRecorder(shizhuang.moxing)
        local image = gGetIconManager():GetImageByID(itemattr.icon)
        --lyout.szCell:SetLockState(false)
        lyout.szCell:SetImage(image)
        lyout.szCell:ClearCornerImage(0)
        lyout.szCell:ClearCornerImage(1)


        table.insert(self.m_szList2, lyout)
        index = index + 1
    end
	
	self.zuoqishu = index


end

function Zuoqity:handleSzSelected2(args)
    local wnd = CEGUI.toWindowEventArgs(args).window
    local cell = CEGUI.toItemCell(wnd)
    local idx = cell:getID()
    local rideItemId = RoleItemManager.getInstance():getRideItemId()
	
	local winMgr = CEGUI.WindowManager:getSingleton()	
	
	--GetCTipsManager():AddMessageTip(self.zuoqishu)

	 for A1=1, self.zuoqishu do
		local A2 = A1 - 1
		local pCell = CEGUI.toItemCell(winMgr:getWindow(A2.."zuoqitycell2/touxiang"));
		pCell:SetSelected(false);
	 end
	local pCell = CEGUI.toItemCell(winMgr:getWindow(cell:getName().."/touxiang"));
    pCell:SetSelected(true);
--GetCTipsManager():AddMessageTip(cell:getName())


	
    if idx==rideItemId then
        self.shiyongBtn:setVisible(true)
        self.shiyongBtn:setText("下 骑")
        self.state = 1
    else
        self.shiyongBtn:setVisible(true)
        self.shiyongBtn:setText("骑 乘")
        self.state = 0
    end
    local itemattr = BeanConfigManager.getInstance():GetTableByName("item.citemattr"):getRecorder(idx)
    --local ids =BeanConfigManager.getInstance():GetTableByName("npc.crideitem"):getAllID()
    local zuoqi =BeanConfigManager.getInstance():GetTableByName("npc.crideitem"):getRecorder(idx)
    local zuoqis = BeanConfigManager.getInstance():GetTableByName("npc.cride"):getRecorder(zuoqi.rideid)
    local shapeid = gGetDataManager():GetMainCharacterShape();
	local data = gGetDataManager():GetMainCharacterData()
	local shapeConf = BeanConfigManager.getInstance():GetTableByName("npc.cnpcshape"):getRecorder(data.shape)
	local weapon = 0
	if shapeConf then
		weapon = shapeConf.showWeaponId
	end
    self.sprite = gGetGameUIManager():AddWindowSprite(self.canvas, shapeid, self.dir, 0, 0, true)
    --local record = BeanConfigManager.getInstance():GetTableByName("item.czuoqicolour"):getRecorder(self.zuoqis[idx])
        local wuqi = GetMainCharacter():GetSpriteComponent(eSprite_Weapon)
		self.sprite:SetSpriteComponent(eSprite_Weapon,wuqi)
    local pA = GetMainCharacter():GetSpriteComponent(eSprite_DyePartA)
    local pB = GetMainCharacter():GetSpriteComponent(eSprite_DyePartB)
    self.sprite:SetDyePartIndex(0, pA)
    self.sprite:SetDyePartIndex(1, pB)
    self.sprite:SetSpriteComponent(eSprite_Horse, zuoqis.ridemodel)
	self.sprite:SetUIDirection(Nuclear.XPDIR_BOTTOMRIGHT)
    self.select=idx
    self.neeItemNameText1:setText(itemattr.name)
    local cmd = require "logic.zuoqi.czuoqizyyongyou".Create()
    cmd.idx = 1
    cmd.index = idx
    LuaProtocolManager.getInstance():send(cmd)

end
function Zuoqity:handleQuitBtnClicked(e)
    if _instance then
        if not _instance.m_bCloseIsHide then
            _instance:OnClose()
            _instance = nil
        else
            _instance:ToggleOpenClose()
        end
    end
end
--function Zuoqity:handleCombineTipClicked1()--????
--          self.DestroyDialog();
--	 require("logic.ranse.ranselabel").Show(2)--yi
--end
--function Zuoqity:handleCombineTipClicked2()--????
--          self.DestroyDialog();
--	 require("logic.ranse.ranselabel").Show(1)--ren
--end
--function Zuoqity:handleCombineTipClicked3()--????
--          self.DestroyDialog();
--	 require("logic.ranse.ranselabel").Show(3)--chong
--end
--function Zuoqity:handleCombineTipClicked4()--????
--          self.DestroyDialog();
--require"logic.ranse.charactershizhuangdlg".getInstanceAndShow()
--end


function Zuoqity:handleLeftClicked(args)
    self.dir = self.dir + 2;
    if self.dir > 7 then
        self.dir = 1;
    end
    self.sprite:SetUIDirection(self.dir)
    self.leftDown = true;
    self.downTime = 0;
end

function Zuoqity:handleRightClicked(args)
    self.dir = self.dir - 2;
    if self.dir < 0 then
        self.dir = 7;
    end
    self.sprite:SetUIDirection(self.dir)
    self.rightDown = true;
    self.downTime = 0;
end
function Zuoqity:handleLeftUp(args)
    self.leftDown = false;
end
function Zuoqity:handleRightUp(args)
    self.rightDown = false;
end
return Zuoqity
