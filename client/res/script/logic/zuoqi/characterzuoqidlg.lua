require "logic.dialog"

CharacterZuoQiDlg = {}
setmetatable(CharacterZuoQiDlg, Dialog)
CharacterZuoQiDlg.__index = CharacterZuoQiDlg

local _instance
function CharacterZuoQiDlg.getInstance()
    if not _instance then
        _instance = CharacterZuoQiDlg:new()
        _instance:OnCreate()
    end
    return _instance
end

function CharacterZuoQiDlg.getInstanceAndShow()
    if not _instance then
        _instance = CharacterZuoQiDlg:new()
        _instance:OnCreate()
    else
        _instance:SetVisible(true)
    end
    return _instance
end

function CharacterZuoQiDlg.getInstanceNotCreate()
    return _instance
end

function CharacterZuoQiDlg.DestroyDialog()
    if _instance then
        if not _instance.m_bCloseIsHide then
            _instance:OnClose()
            _instance = nil
        else
            _instance:ToggleOpenClose()
        end
		-- if _instance.ownMoneyText:isVisible() then
		-- CurrencyManager.unregisterTextWidget(_instance.ownMoneyText)	
		-- end
    end
end

function CharacterZuoQiDlg.ToggleOpenClose()
    if not _instance then
        _instance = CharacterZuoQiDlg:new()
        _instance:OnCreate()
    else
        if _instance:IsVisible() then
            _instance:SetVisible(false)
        else
            _instance:SetVisible(true)
        end
    end
end

function CharacterZuoQiDlg.GetLayoutFileName()
    return "juesezuoqi.layout"
end

function CharacterZuoQiDlg:new()
    local self = {}
    self = Dialog:new()
    setmetatable(self, CharacterZuoQiDlg)
    return self
end

function CharacterZuoQiDlg:OnCreate()
    Dialog.OnCreate(self)
    local winMgr = CEGUI.WindowManager:getSingleton()

    SetPositionOfWindowWithLabel(self:GetWindow())
    -- self:GetCloseBtn():removeEvent("Clicked")
    --self:GetCloseBtn():subscribeEvent("Clicked", RanSeLabel.DestroyDialog, nil)
		self.frameWindow = CEGUI.toFrameWindow(winMgr:getWindow("juesezuoqi/biaoti"))
	SetPositionScreenCenter(self.frameWindow)

    self.leftDown = false;
    self.rightDown = false;
    self.downTime = 0;
    self.state = 0;
    self.turnL = CEGUI.toPushButton(winMgr:getWindow("juesezuoqi/xuanniu"));
    self.turnR = CEGUI.toPushButton(winMgr:getWindow("juesezuoqi/xuanniu2"));
    self.m_btnguanbi = CEGUI.toPushButton(winMgr:getWindow("juesezuoqi/back"))
    self.huobi1 = winMgr:getWindow("juesezuoqi/textzong/yinbi2")
    self.huobi2 = winMgr:getWindow("juesezuoqi/textzong/yinbi21")
    self.jiage = winMgr:getWindow("juesezuoqi/textdan")
    self.ownMoneyText = winMgr:getWindow("juesezuoqi/textdan1")
	
	
	
	 self.text1 = winMgr:getWindow("juesezuoqi/title/text1")
	
	 self.text2 = winMgr:getWindow("juesezuoqi/title/text11")
	
	 self.text3 = winMgr:getWindow("juesezuoqi/xxtt")
	 self.text3:setVisible(false)
	
	self.ownMoneyText:setText((formatMoneyString(CurrencyManager.getOwnCurrencyMount(fire.pb.game.MoneyType.MoneyType_HearthStone))))
   -- CurrencyManager.registerTextWidget(2, self.ownMoneyText)
    self.turnL:subscribeEvent("MouseButtonDown", CharacterZuoQiDlg.handleLeftClicked, self)
    self.turnR:subscribeEvent("MouseButtonDown", CharacterZuoQiDlg.handleRightClicked, self)
    self.turnL:subscribeEvent("MouseButtonUp", CharacterZuoQiDlg.handleLeftUp, self)
    self.turnR:subscribeEvent("MouseButtonUp", CharacterZuoQiDlg.handleRightUp, self)
    self.turnL:subscribeEvent("MouseLeave", CharacterZuoQiDlg.handleLeftUp, self)
    self.turnR:subscribeEvent("MouseLeave", CharacterZuoQiDlg.handleRightUp, self)
    self.m_btnguanbi:subscribeEvent("Clicked", CharacterZuoQiDlg.handleQuitBtnClicked, self)

    self.shiyongBtn = CEGUI.toPushButton(winMgr:getWindow("juesezuoqi/huanyuan111"))
    self.shiyongBtn1 = CEGUI.toPushButton(winMgr:getWindow("juesezuoqi/huanyuan112"))  --骑乘
    self.shiyongBtn2 = CEGUI.toPushButton(winMgr:getWindow("juesezuoqi/huanyuan113"))
	
    self.shiyongBtn:subscribeEvent("Clicked", CharacterZuoQiDlg.handletsClicked, self)
    self.shiyongBtn1:subscribeEvent("Clicked", CharacterZuoQiDlg.handleShiYongClicked, self)
    self.shiyongBtn2:subscribeEvent("Clicked", CharacterZuoQiDlg.handleShiYongClicked, self)
	
    self.goumaiBtn = CEGUI.toPushButton(winMgr:getWindow("juesezuoqi/huanyuan11"))--购  买
    self.goumaiBtn:subscribeEvent("Clicked", CharacterZuoQiDlg.handleGouMaiClicked, self)


    self.mt_TiShi = CEGUI.toPushButton(winMgr:getWindow("juesezuoqi/tishi"))
    self.mt_XuanCai = CEGUI.toPushButton(winMgr:getWindow("juesezuoqi/xuancai"))
    self.mt_RanSe = CEGUI.toPushButton(winMgr:getWindow("juesezuoqi/ranse"))
    self.mt_GengDduo = CEGUI.toPushButton(winMgr:getWindow("juesezuoqi/gengduo"))
	self.mt_TiShi:subscribeEvent("Clicked", CharacterZuoQiDlg.handleTiShiClicked, self)
	self.mt_XuanCai:subscribeEvent("Clicked", CharacterZuoQiDlg.handleXuanCaiClicked, self)
	self.mt_RanSe:subscribeEvent("Clicked", CharacterZuoQiDlg.handleRanSeClicked, self)
	self.mt_GengDduo:subscribeEvent("Clicked", CharacterZuoQiDlg.handleGengDduoClicked, self)



    local data = gGetDataManager():GetMainCharacterData()
    self.dir = Nuclear.XPDIR_BOTTOMRIGHT;
    self.canvas = winMgr:getWindow("juesezuoqi/moxing")


    self.zuoqis = {};
	
	
  local shapeConf = BeanConfigManager.getInstance():GetTableByName("npc.cnpcshape"):getRecorder(data.shape)
  local weapon = 0
	if shapeConf then
		weapon = shapeConf.showWeaponId
	end
  
    
  
    self.sprite = gGetGameUIManager():AddWindowSprite(self.canvas, data.shape, self.dir, 0, 0, true)
		self.sprite:SetSpriteComponent(eSprite_Weapon,weapon)
    local rideItemId = RoleItemManager.getInstance():getRideItemId()
	 self.sprite:SetUIDirection(Nuclear.XPDIR_BOTTOMRIGHT)
    local pA = GetMainCharacter():GetSpriteComponent(eSprite_DyePartA)
    local pB = GetMainCharacter():GetSpriteComponent(eSprite_DyePartB)
    self.sprite:SetSpriteComponent(eSprite_DyePartA, pA)
    self.sprite:SetSpriteComponent(eSprite_DyePartB, pB)
    if rideItemId~=0 then
        local zuoqi =BeanConfigManager.getInstance():GetTableByName("npc.crideitem"):getRecorder(rideItemId)
        local zuoqis = BeanConfigManager.getInstance():GetTableByName("npc.cride"):getRecorder(zuoqi.rideid)
        -- local yanse = GetMainCharacter():GetSpriteComponent(203)
        -- if yanse then
            -- local record = BeanConfigManager.getInstance():GetTableByName("item.czuoqicolour"):getRecorder(yanse)
            -- self.sprite:SetSpriteComponent(eSprite_Horse, zuoqis.ridemodel)
        -- else
            -- self.sprite:SetSpriteComponent(eSprite_Horse, zuoqis.ridemodel)
        -- end
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


    self.neeItemNameText1 = winMgr:getWindow("juesezuoqi/ranliaoming1")
	self.xinxi = CEGUI.toRichEditbox(winMgr:getWindow("juesezuoqi/jieshao"))
    self.xinxi:setReadOnly(true)
	
	
    self.neeItemNameText1:setText("")
    self.select = 0;
    self.selectitem = 0;
    self.selectye = 0;
    self.m_szList2 = {}
	self.m_szList = {}
	self.huobi=0
		self.dangqianmoney=0
    --self.ItemCellNeedItem1:setVisible(false)
    self.neeItemNameText1:setVisible(true)
    --self.neeItemCountText1:setVisible(false)
    -- local ids =BeanConfigManager.getInstance():GetTableByName("item.cshizhuangyichu"):getAllID()
    self.szlistWnd = CEGUI.toScrollablePane(winMgr:getWindow("juesezuoqi/biaoti/shizhuang/szs"));
    self.szlistWnd:EnableHorzScrollBar(false)
    local cmd = require "logic.zuoqi.czuoqiyongyou".Create()
    LuaProtocolManager.getInstance():send(cmd)
    self.szlistWnd2 = CEGUI.toScrollablePane(winMgr:getWindow("juesezuoqi/biaoti/shizhuang/szs1"));
    self.szlistWnd2:EnableHorzScrollBar(false)
    self.yongyou={}
end


function CharacterZuoQiDlg:handleTiShiClicked(args)
GetCTipsManager():AddMessageTipById(168000)
end
function CharacterZuoQiDlg:handleXuanCaiClicked(args)
require"logic.zuoqi.zuoqity".getInstanceAndShow()
end
function CharacterZuoQiDlg:handleRanSeClicked(args)
GetCTipsManager():AddMessageTipById(168000)
end
function CharacterZuoQiDlg:handleGengDduoClicked(args)
require"logic.zuoqi.zuoqity".getInstanceAndShow()
end

function CharacterZuoQiDlg:handletsClicked(args)
GetCTipsManager():AddMessageTipById(194242)
end
function CharacterZuoQiDlg:handleShiYongClicked(args)
    if self.select~=0 then
        --local data = gGetDataManager():GetMainCharacterData()
        local cmd = require "logic.zuoqi.czuoqishiyong":new()
        cmd.zuoqiid = self.select
        LuaProtocolManager.getInstance():send(cmd)
        self:DestroyDialog()
    end
end
function CharacterZuoQiDlg:handleGouMaiClicked(args)
     if self.selectitem~=0 then
	 local curStone = CurrencyManager.getOwnCurrencyMount(self.huobi)
	 if self.huobi==0 then
	 return
	 end
	  if self.dangqianmoney>curStone then
	    if self.huobi==1 then
		GetCTipsManager():AddMessageTipById(142686)
		

		elseif self.huobi==2 then
		GetCTipsManager():AddMessageTipById(142686)
		
		
		elseif self.huobi==3 then
		GetCTipsManager():AddMessageTipById(142686)
		
		end
         return
	  end
	  
     local cmd = require "logic.zuoqi.czuoqigoumai":new()
     cmd.zuoqiid = self.selectitem
     LuaProtocolManager.getInstance():send(cmd)
     end
	 -- CharacterZuoQiDlg.DestroyDialog()
end
function CharacterZuoQiDlg:refreshSzTable()
    for index  = 1, #self.m_szList do
        local lyout = self.m_szList[1]
        lyout.addclick = nil
        lyout.LevelText = nil
        self.szlistWnd:removeChildWindow(lyout)
        CEGUI.WindowManager:getSingleton():destroyWindow(lyout)
        table.remove(self.m_szList,1)
    end
    local winMgr = CEGUI.WindowManager:getSingleton()
    local sx = 2.0;
    local sy = 2.0;
    self.m_szList = {}
    local index = 0
    local index2 = 0
    local ids =BeanConfigManager.getInstance():GetTableByName("npc.crideitem"):getAllID()
    for _, v in pairs(ids) do
        local zuoqi =BeanConfigManager.getInstance():GetTableByName("npc.crideitem"):getRecorder(v)
        local itemattr = BeanConfigManager.getInstance():GetTableByName("item.citemattr"):getRecorder(v)
        -- local zuoqis = BeanConfigManager.getInstance():GetTableByName("npc.cride"):getRecorder(zuoqi.rideid)
        local sID = "CharacterZuoQiDlg1" .. tostring(index)
        local lyout = winMgr:loadWindowLayout("juesezuoqicell1.layout",sID);
        self.szlistWnd:addChildWindow(lyout)
        if index2>=3 then
            index2=0
        end
        lyout:setPosition(CEGUI.UVector2(CEGUI.UDim(0.0, sx + index2 * (lyout:getWidth().offset-5)), CEGUI.UDim(0.0, sy + math.floor(index/3) * (lyout:getHeight().offset))))
        index2=index2+1

        lyout.addclick =  CEGUI.toGroupButton(winMgr:getWindow(sID.."juesezuoqicell1"));
        lyout.addclick:setID(v)
        lyout.addclick:subscribeEvent("MouseButtonUp", CharacterZuoQiDlg.handleSzSelected, self)
        lyout.szCell = CEGUI.toItemCell(winMgr:getWindow(sID.."juesezuoqicell1/touxiang"))
        lyout.name = winMgr:getWindow(sID.."juesezuoqicell1/name")
        lyout.image = winMgr:getWindow(sID.."juesezuoqicell1/touxiang/jiahao")--已拥有标签
		
		for x,y in ipairs(self.yongyou) do
		  if y==v then
		     lyout.image:setVisible(true)
		  end
		end
        local image = gGetIconManager():GetImageByID(itemattr.icon)
      --  lyout.szCell:SetLockState(false)
        lyout.szCell:SetImage(image)
        lyout.name:setText(itemattr.name)
      --  lyout.szCell:ClearCornerImage(0)
     --   lyout.szCell:ClearCornerImage(1)

        table.insert(self.m_szList, lyout)
        index = index + 1
    end
end

function CharacterZuoQiDlg:refreshSzTable2(szList)
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
	self.yongyou={}
    self.m_szList2 = {}
    for k,v in pairs(szList) do
         self.zuoqis[k]=v
	   table.insert(self.yongyou,k)
        local zuoqi =BeanConfigManager.getInstance():GetTableByName("npc.crideitem"):getRecorder(k)
        local itemattr = BeanConfigManager.getInstance():GetTableByName("item.citemattr"):getRecorder(k)
        --local zuoqis = BeanConfigManager.getInstance():GetTableByName("npc.cride"):getRecorder(zuoqi.rideid)
        local sID = "CharacterZuoQiDlg2" .. tostring(index)
        local lyout = winMgr:loadWindowLayout("juesezuoqicell2.layout",index);
        self.szlistWnd2:addChildWindow(lyout)
        if index2>=3 then
            index2=0
        end
        lyout:setPosition(CEGUI.UVector2(CEGUI.UDim(0.0, sx + index2 * (lyout:getWidth().offset-1)), CEGUI.UDim(0.0, sy + math.floor(index/3) * (lyout:getHeight().offset))))
        index2=index2+1

        lyout.addclick =  CEGUI.toGroupButton(winMgr:getWindow(index.."juesezuoqicell2"));
        lyout.addclick:setID(k)
        lyout.addclick:subscribeEvent("MouseButtonUp", CharacterZuoQiDlg.handleSzSelected2, self)
        lyout.szCell = CEGUI.toItemCell(winMgr:getWindow(index.."juesezuoqicell2/touxiang"))
        lyout.name = winMgr:getWindow(index.."juesezuoqicell2/name")
        lyout.image = winMgr:getWindow(index.."juesezuoqicell2/jiahao")--骑乘图标
        local image = gGetIconManager():GetImageByID(itemattr.icon)
		lyout.szCell:SetImage(image)
      --  lyout.szCell:SetLockState(false)
        lyout.name:setText(itemattr.name)
      --  lyout.szCell:ClearCornerImage(0)
      --  lyout.szCell:ClearCornerImage(1)
		
    local idx = itemattr.id
    local rideItemId = RoleItemManager.getInstance():getRideItemId()
    if idx==rideItemId then
	lyout.image:setVisible(true)
	lyout.name:setProperty("TextColours", "FFFFFFFF")
	lyout.name:setProperty("BorderEnable", "True")
	else
	lyout.image:setVisible(false)
    end

        table.insert(self.m_szList2, lyout)
        index = index + 1
    end
	    self:refreshSzTable()
end
function CharacterZuoQiDlg:handleSzSelected(args)
  local data = gGetDataManager():GetMainCharacterData()
    local wnd = CEGUI.toWindowEventArgs(args).window
    local cell = CEGUI.toItemCell(wnd)
    local idx = cell:getID()
    --local ids =BeanConfigManager.getInstance():GetTableByName("npc.crideitem"):getAllID()
    local itemattr = BeanConfigManager.getInstance():GetTableByName("item.citemattr"):getRecorder(idx)
    local zuoqi =BeanConfigManager.getInstance():GetTableByName("npc.crideitem"):getRecorder(idx)
    local zuoqis = BeanConfigManager.getInstance():GetTableByName("npc.cride"):getRecorder(zuoqi.rideid)
    local shapeid = gGetDataManager():GetMainCharacterShape();
	local shapeConf = BeanConfigManager.getInstance():GetTableByName("npc.cnpcshape"):getRecorder(data.shape)
  local weapon = 0
	if shapeConf then
		weapon = shapeConf.showWeaponId
	end
  
    self.sprite = gGetGameUIManager():AddWindowSprite(self.canvas, shapeid, self.dir, 0, 0, true)


    local bi=0
	if zuoqi.huobi==0 then
		 self.jiage:setVisible(false)
         self.ownMoneyText:setVisible(false)
	     self.text1:setVisible(false)
	     self.text2:setVisible(false)
	     self.goumaiBtn:setVisible(false)
	     self.text3:setVisible(true)
          bi=0
    else
		 self.jiage:setVisible(true)
         self.ownMoneyText:setVisible(true)
	     self.text1:setVisible(true)
	     self.text2:setVisible(true)
	     self.goumaiBtn:setVisible(true)
	     self.text3:setVisible(false)
	

		if zuoqi.huobi==1 then
          self.huobi1:setProperty("Image", "set:ccui1 image:common_jinb")
          self.huobi2:setProperty("Image", "set:ccui1 image:common_jinb")
          bi=1
       elseif zuoqi.huobi==2 then
          self.huobi1:setProperty("Image", "set:common image:common_jinb")
          self.huobi2:setProperty("Image", "set:common image:common_jinb")
          bi=2
       elseif zuoqi.huobi==3 then
          self.huobi1:setProperty("Image", "set:ccui1 image:hbc12")
          self.huobi2:setProperty("Image", "set:ccui1 image:hbc12")
          bi=3
       end
	    self.jiage:setText(zuoqi.money)

	    self.dangqianmoney=zuoqi.money
	end

		    self.huobi=bi

	-- if zuoqi.money > (bi, self.ownMoneyText) then
	-- self.jiage:setProperty("TextColours", "ffd63235")
	
	-- else 
		-- self.jiage:setProperty("TextColours", "ffd63235")
    -- end
	
self.sprite:SetSpriteComponent(eSprite_Weapon,weapon)
	
  --  CurrencyManager.registerTextWidget(bi, self.ownMoneyText)
	self.ownMoneyText:setText((formatMoneyString(CurrencyManager.getOwnCurrencyMount(bi))))
    self.selectitem=idx

    self.sprite:SetSpriteComponent(eSprite_Horse, zuoqis.ridemodel)

    self.neeItemNameText1:setText(itemattr.name)
	self.xinxi:Clear()
	self.xinxi:AppendText(CEGUI.String(itemattr.destribe),CEGUI.ColourRect(CEGUI.PropertyHelper:stringToColour("FF56361D")))
	self.xinxi:Refresh()
	
end

function CharacterZuoQiDlg:handleSzSelected2(args)
  local data = gGetDataManager():GetMainCharacterData()
    local wnd = CEGUI.toWindowEventArgs(args).window
    local cell = CEGUI.toItemCell(wnd)
    local idx = cell:getID()
    local rideItemId = RoleItemManager.getInstance():getRideItemId()
    if idx==rideItemId then
        self.shiyongBtn:setVisible(true)
        --self.shiyongBtn:setText("下 骑")
	    self.shiyongBtn:setVisible(false)
        self.shiyongBtn1:setVisible(false)
        self.shiyongBtn2:setVisible(true)
	
		
        self.state = 1
    else
        --self.shiyongBtn:setVisible(true)
		
		self.shiyongBtn:setVisible(false)
        self.shiyongBtn1:setVisible(true)
        self.shiyongBtn2:setVisible(false)
	
        --self.shiyongBtn:setText("骑 乘")
        self.state = 0
    end
    local itemattr = BeanConfigManager.getInstance():GetTableByName("item.citemattr"):getRecorder(idx)
    --local ids =BeanConfigManager.getInstance():GetTableByName("npc.crideitem"):getAllID()
    local zuoqi =BeanConfigManager.getInstance():GetTableByName("npc.crideitem"):getRecorder(idx)
    local zuoqis = BeanConfigManager.getInstance():GetTableByName("npc.cride"):getRecorder(zuoqi.rideid)
    local shapeid = gGetDataManager():GetMainCharacterShape();
	local shapeConf = BeanConfigManager.getInstance():GetTableByName("npc.cnpcshape"):getRecorder(data.shape)
    local weapon = 0
	if shapeConf then
		weapon = shapeConf.showWeaponId
	end
    self.sprite = gGetGameUIManager():AddWindowSprite(self.canvas, shapeid, self.dir, 0, 0, true)
    local record = BeanConfigManager.getInstance():GetTableByName("item.czuoqicolour"):getRecorder(self.zuoqis[idx])
		self.sprite:SetSpriteComponent(eSprite_Weapon,weapon)
    self.sprite:SetSpriteComponent(eSprite_Horse, zuoqis.ridemodel)
    self.select=idx
    self.neeItemNameText1:setText(itemattr.name)
	
	self.xinxi:Clear()
    self.xinxi:AppendText(CEGUI.String(itemattr.destribe), CEGUI.ColourRect(CEGUI.PropertyHelper:stringToColour("FF56361D")))
    self.xinxi:Refresh()
end
function CharacterZuoQiDlg:handleQuitBtnClicked(e)
    if _instance then
        if not _instance.m_bCloseIsHide then
            _instance:OnClose()
            _instance = nil
        else
            _instance:ToggleOpenClose()
        end
    end
end
--function CharacterZuoQiDlg:handleCombineTipClicked1()--????
--          self.DestroyDialog();
--	 require("logic.ranse.ranselabel").Show(2)--yi
--end
--function CharacterZuoQiDlg:handleCombineTipClicked2()--????
--          self.DestroyDialog();
--	 require("logic.ranse.ranselabel").Show(1)--ren
--end
--function CharacterZuoQiDlg:handleCombineTipClicked3()--????
--          self.DestroyDialog();
--	 require("logic.ranse.ranselabel").Show(3)--chong
--end
--function CharacterZuoQiDlg:handleCombineTipClicked4()--????
--          self.DestroyDialog();
--require"logic.ranse.charactershizhuangdlg".getInstanceAndShow()
--end


function CharacterZuoQiDlg:handleLeftClicked(args)
    self.dir = self.dir + 2;
    if self.dir > 7 then
        self.dir = 1;
    end
    self.sprite:SetUIDirection(self.dir)
    self.leftDown = true;
    self.downTime = 0;
end

function CharacterZuoQiDlg:handleRightClicked(args)
    self.dir = self.dir - 2;
    if self.dir < 0 then
        self.dir = 7;
    end
    self.sprite:SetUIDirection(self.dir)
    self.rightDown = true;
    self.downTime = 0;
end
function CharacterZuoQiDlg:handleLeftUp(args)
    self.leftDown = false;
end
function CharacterZuoQiDlg:handleRightUp(args)
    self.rightDown = false;
end
return CharacterZuoQiDlg
