require "logic.dialog"

ShengSiZhanGuiZeDlg1 = {}
setmetatable(ShengSiZhanGuiZeDlg1, Dialog)
ShengSiZhanGuiZeDlg1.__index = ShengSiZhanGuiZeDlg1

local _instance
function ShengSiZhanGuiZeDlg1.getInstance()
	if not _instance then
		_instance = ShengSiZhanGuiZeDlg1:new()
		_instance:OnCreate()
	end
	return _instance
end

function ShengSiZhanGuiZeDlg1.getInstanceAndShow()
	if not _instance then
		_instance = ShengSiZhanGuiZeDlg1:new()
		_instance:OnCreate()
	else
		_instance:SetVisible(true)
	end
	return _instance
end

function ShengSiZhanGuiZeDlg1.getInstanceNotCreate()
	return _instance
end

function ShengSiZhanGuiZeDlg1.DestroyDialog()
	if _instance then 
		if not _instance.m_bCloseIsHide then
			_instance:OnClose()
			_instance = nil
		else
			_instance:ToggleOpenClose()
		end
	end
end

function ShengSiZhanGuiZeDlg1.ToggleOpenClose()
	if not _instance then
		_instance = ShengSiZhanGuiZeDlg1:new()
		_instance:OnCreate()
	else
		if _instance:IsVisible() then
			_instance:SetVisible(false)
		else
			_instance:SetVisible(true)
		end
	end
end

function ShengSiZhanGuiZeDlg1.GetLayoutFileName()
	return "shengsizhanguize1_mtg.layout"
end

function ShengSiZhanGuiZeDlg1:new()
	local self = {}
	self = Dialog:new()
	setmetatable(self, ShengSiZhanGuiZeDlg1)
	return self
end

function ShengSiZhanGuiZeDlg1:OnCreate()
	Dialog.OnCreate(self)
end

function ShengSiZhanGuiZeDlg1:OnCreate()
    LogInfo("ShengSiZhanGuiZeDlg1 oncreate begin")
    Dialog.OnCreate(self)
	self:GetWindow():setRiseOnClickEnabled(false)
    local winMgr = CEGUI.WindowManager:getSingleton()
    -- get windows
 

    self.m_beijing = CEGUI.Window.toPushButton(winMgr:getWindow("EquipDialog/Back/Pattern/diban1"))
	-- 大唐
    self.m_dt1 = CEGUI.Window.toPushButton(winMgr:getWindow("ShengSiZhanGuiZe/dt1"))
	self.m_dt2 = CEGUI.Window.toPushButton(winMgr:getWindow("ShengSiZhanGuiZe/dt2"))
	self.m_dt3 = CEGUI.Window.toPushButton(winMgr:getWindow("ShengSiZhanGuiZe/dt3"))
	self.m_dt4 = CEGUI.Window.toPushButton(winMgr:getWindow("ShengSiZhanGuiZe/dt4"))
	self.m_dt5 = CEGUI.Window.toPushButton(winMgr:getWindow("ShengSiZhanGuiZe/dt5"))
	-- 地府
	self.m_df1 = CEGUI.Window.toPushButton(winMgr:getWindow("ShengSiZhanGuiZe/df1"))
	self.m_df2 = CEGUI.Window.toPushButton(winMgr:getWindow("ShengSiZhanGuiZe/df2"))
	self.m_df3 = CEGUI.Window.toPushButton(winMgr:getWindow("ShengSiZhanGuiZe/df3"))
	self.m_df4 = CEGUI.Window.toPushButton(winMgr:getWindow("ShengSiZhanGuiZe/df4"))
	self.m_df5 = CEGUI.Window.toPushButton(winMgr:getWindow("ShengSiZhanGuiZe/df5"))
	-- 方寸
	self.m_fc1 = CEGUI.Window.toPushButton(winMgr:getWindow("ShengSiZhanGuiZe/fc1"))
	self.m_fc2 = CEGUI.Window.toPushButton(winMgr:getWindow("ShengSiZhanGuiZe/fc2"))
	self.m_fc3 = CEGUI.Window.toPushButton(winMgr:getWindow("ShengSiZhanGuiZe/fc3"))
	self.m_fc4 = CEGUI.Window.toPushButton(winMgr:getWindow("ShengSiZhanGuiZe/fc4"))
	self.m_fc5 = CEGUI.Window.toPushButton(winMgr:getWindow("ShengSiZhanGuiZe/fc5"))
    -- 化生
	self.m_hs1 = CEGUI.Window.toPushButton(winMgr:getWindow("ShengSiZhanGuiZe/hs1"))
	self.m_hs2 = CEGUI.Window.toPushButton(winMgr:getWindow("ShengSiZhanGuiZe/hs2"))
	self.m_hs3 = CEGUI.Window.toPushButton(winMgr:getWindow("ShengSiZhanGuiZe/hs3"))
	self.m_hs4 = CEGUI.Window.toPushButton(winMgr:getWindow("ShengSiZhanGuiZe/hs4"))
	self.m_hs5 = CEGUI.Window.toPushButton(winMgr:getWindow("ShengSiZhanGuiZe/hs5"))
    -- 龙宫
	self.m_lg1 = CEGUI.Window.toPushButton(winMgr:getWindow("ShengSiZhanGuiZe/lg1"))
	self.m_lg2 = CEGUI.Window.toPushButton(winMgr:getWindow("ShengSiZhanGuiZe/lg2"))
	self.m_lg3 = CEGUI.Window.toPushButton(winMgr:getWindow("ShengSiZhanGuiZe/lg3"))
	self.m_lg4 = CEGUI.Window.toPushButton(winMgr:getWindow("ShengSiZhanGuiZe/lg4"))
	self.m_lg5 = CEGUI.Window.toPushButton(winMgr:getWindow("ShengSiZhanGuiZe/lg5"))
    -- 魔王
	self.m_mw1 = CEGUI.Window.toPushButton(winMgr:getWindow("ShengSiZhanGuiZe/mw1"))
	self.m_mw2 = CEGUI.Window.toPushButton(winMgr:getWindow("ShengSiZhanGuiZe/mw2"))
	self.m_mw3 = CEGUI.Window.toPushButton(winMgr:getWindow("ShengSiZhanGuiZe/mw3"))
	self.m_mw4 = CEGUI.Window.toPushButton(winMgr:getWindow("ShengSiZhanGuiZe/mw4"))
	self.m_mw5 = CEGUI.Window.toPushButton(winMgr:getWindow("ShengSiZhanGuiZe/mw5"))
    -- 女儿
	self.m_ne1 = CEGUI.Window.toPushButton(winMgr:getWindow("ShengSiZhanGuiZe/ne1"))
	self.m_ne2 = CEGUI.Window.toPushButton(winMgr:getWindow("ShengSiZhanGuiZe/ne2"))
	self.m_ne3 = CEGUI.Window.toPushButton(winMgr:getWindow("ShengSiZhanGuiZe/ne3"))
	self.m_ne4 = CEGUI.Window.toPushButton(winMgr:getWindow("ShengSiZhanGuiZe/ne4"))
	self.m_ne5 = CEGUI.Window.toPushButton(winMgr:getWindow("ShengSiZhanGuiZe/ne5"))
    -- 普陀
	self.m_pt1 = CEGUI.Window.toPushButton(winMgr:getWindow("ShengSiZhanGuiZe/pt1"))
	self.m_pt2 = CEGUI.Window.toPushButton(winMgr:getWindow("ShengSiZhanGuiZe/pt2"))
	self.m_pt3 = CEGUI.Window.toPushButton(winMgr:getWindow("ShengSiZhanGuiZe/pt3"))
	self.m_pt4 = CEGUI.Window.toPushButton(winMgr:getWindow("ShengSiZhanGuiZe/pt4"))
	self.m_pt5 = CEGUI.Window.toPushButton(winMgr:getWindow("ShengSiZhanGuiZe/pt5"))
    -- 狮驼
	self.m_st1 = CEGUI.Window.toPushButton(winMgr:getWindow("ShengSiZhanGuiZe/st1"))
	self.m_st2 = CEGUI.Window.toPushButton(winMgr:getWindow("ShengSiZhanGuiZe/st2"))
	self.m_st3 = CEGUI.Window.toPushButton(winMgr:getWindow("ShengSiZhanGuiZe/st3"))
	self.m_st4 = CEGUI.Window.toPushButton(winMgr:getWindow("ShengSiZhanGuiZe/st4"))
	self.m_st5 = CEGUI.Window.toPushButton(winMgr:getWindow("ShengSiZhanGuiZe/st5"))
    -- 月宫
	self.m_yg1 = CEGUI.Window.toPushButton(winMgr:getWindow("ShengSiZhanGuiZe/yg1"))
	self.m_yg2 = CEGUI.Window.toPushButton(winMgr:getWindow("ShengSiZhanGuiZe/yg2"))
	self.m_yg3 = CEGUI.Window.toPushButton(winMgr:getWindow("ShengSiZhanGuiZe/yg3"))
	self.m_yg4 = CEGUI.Window.toPushButton(winMgr:getWindow("ShengSiZhanGuiZe/yg4"))
	self.m_yg5 = CEGUI.Window.toPushButton(winMgr:getWindow("ShengSiZhanGuiZe/yg5"))
    -- 五庄
	self.m_wz1 = CEGUI.Window.toPushButton(winMgr:getWindow("ShengSiZhanGuiZe/wz1"))
	self.m_wz2 = CEGUI.Window.toPushButton(winMgr:getWindow("ShengSiZhanGuiZe/wz2"))
	self.m_wz3 = CEGUI.Window.toPushButton(winMgr:getWindow("ShengSiZhanGuiZe/wz3"))
	self.m_wz4 = CEGUI.Window.toPushButton(winMgr:getWindow("ShengSiZhanGuiZe/wz4"))
	self.m_wz5 = CEGUI.Window.toPushButton(winMgr:getWindow("ShengSiZhanGuiZe/wz5"))
    -- 天宫
	self.m_tg1 = CEGUI.Window.toPushButton(winMgr:getWindow("ShengSiZhanGuiZe/tg1"))
	self.m_tg2 = CEGUI.Window.toPushButton(winMgr:getWindow("ShengSiZhanGuiZe/tg2"))
	self.m_tg3 = CEGUI.Window.toPushButton(winMgr:getWindow("ShengSiZhanGuiZe/tg3"))
	self.m_tg4 = CEGUI.Window.toPushButton(winMgr:getWindow("ShengSiZhanGuiZe/tg4"))
	self.m_tg5 = CEGUI.Window.toPushButton(winMgr:getWindow("ShengSiZhanGuiZe/tg5"))
	
    --说明按钮
    self.m_TipsButton = CEGUI.Window.toPushButton(winMgr:getWindow("JingMai/tips"))
    self.m_TipsButton:subscribeEvent("Clicked", ShengSiZhanGuiZeDlg1.HandleTipsBtn, self)	

	-----------------------------------------------------------------------------------------
    -- 大唐
	self.m_dt1:subscribeEvent("Clicked", ShengSiZhanGuiZeDlg1.dt1, self)
	self.m_dt2:subscribeEvent("Clicked", ShengSiZhanGuiZeDlg1.dt2, self)
	self.m_dt3:subscribeEvent("Clicked", ShengSiZhanGuiZeDlg1.dt3, self)
	self.m_dt4:subscribeEvent("Clicked", ShengSiZhanGuiZeDlg1.dt4, self)
	self.m_dt5:subscribeEvent("Clicked", ShengSiZhanGuiZeDlg1.dt5, self)
    -- 地府
	self.m_df1:subscribeEvent("Clicked", ShengSiZhanGuiZeDlg1.df1, self)
	self.m_df2:subscribeEvent("Clicked", ShengSiZhanGuiZeDlg1.df2, self)
	self.m_df3:subscribeEvent("Clicked", ShengSiZhanGuiZeDlg1.df3, self)
	self.m_df4:subscribeEvent("Clicked", ShengSiZhanGuiZeDlg1.df4, self)
	self.m_df5:subscribeEvent("Clicked", ShengSiZhanGuiZeDlg1.df5, self)
	-- 方寸
	self.m_fc1:subscribeEvent("Clicked", ShengSiZhanGuiZeDlg1.fc1, self)
	self.m_fc2:subscribeEvent("Clicked", ShengSiZhanGuiZeDlg1.fc2, self)
	self.m_fc3:subscribeEvent("Clicked", ShengSiZhanGuiZeDlg1.fc3, self)
	self.m_fc4:subscribeEvent("Clicked", ShengSiZhanGuiZeDlg1.fc4, self)
	self.m_fc5:subscribeEvent("Clicked", ShengSiZhanGuiZeDlg1.fc5, self)
	-- 化生
	self.m_hs1:subscribeEvent("Clicked", ShengSiZhanGuiZeDlg1.hs1, self)
	self.m_hs2:subscribeEvent("Clicked", ShengSiZhanGuiZeDlg1.hs2, self)
	self.m_hs3:subscribeEvent("Clicked", ShengSiZhanGuiZeDlg1.hs3, self)
	self.m_hs4:subscribeEvent("Clicked", ShengSiZhanGuiZeDlg1.hs4, self)
	self.m_hs5:subscribeEvent("Clicked", ShengSiZhanGuiZeDlg1.hs5, self)
	-- 龙宫
	self.m_lg1:subscribeEvent("Clicked", ShengSiZhanGuiZeDlg1.lg1, self)
	self.m_lg2:subscribeEvent("Clicked", ShengSiZhanGuiZeDlg1.lg2, self)
	self.m_lg3:subscribeEvent("Clicked", ShengSiZhanGuiZeDlg1.lg3, self)
	self.m_lg4:subscribeEvent("Clicked", ShengSiZhanGuiZeDlg1.lg4, self)
	self.m_lg5:subscribeEvent("Clicked", ShengSiZhanGuiZeDlg1.lg5, self)
	-- 魔王
	self.m_mw1:subscribeEvent("Clicked", ShengSiZhanGuiZeDlg1.mw1, self)
	self.m_mw2:subscribeEvent("Clicked", ShengSiZhanGuiZeDlg1.mw2, self)
	self.m_mw3:subscribeEvent("Clicked", ShengSiZhanGuiZeDlg1.mw3, self)
	self.m_mw4:subscribeEvent("Clicked", ShengSiZhanGuiZeDlg1.mw4, self)
	self.m_mw5:subscribeEvent("Clicked", ShengSiZhanGuiZeDlg1.mw5, self)
	-- 女儿
	self.m_ne1:subscribeEvent("Clicked", ShengSiZhanGuiZeDlg1.ne1, self)
	self.m_ne2:subscribeEvent("Clicked", ShengSiZhanGuiZeDlg1.ne2, self)
	self.m_ne3:subscribeEvent("Clicked", ShengSiZhanGuiZeDlg1.ne3, self)
	self.m_ne4:subscribeEvent("Clicked", ShengSiZhanGuiZeDlg1.ne4, self)
	self.m_ne5:subscribeEvent("Clicked", ShengSiZhanGuiZeDlg1.ne5, self)
	-- 普陀
	self.m_pt1:subscribeEvent("Clicked", ShengSiZhanGuiZeDlg1.pt1, self)
	self.m_pt2:subscribeEvent("Clicked", ShengSiZhanGuiZeDlg1.pt2, self)
	self.m_pt3:subscribeEvent("Clicked", ShengSiZhanGuiZeDlg1.pt3, self)
	self.m_pt4:subscribeEvent("Clicked", ShengSiZhanGuiZeDlg1.pt4, self)
	self.m_pt5:subscribeEvent("Clicked", ShengSiZhanGuiZeDlg1.pt5, self)
	-- 狮驼
	self.m_st1:subscribeEvent("Clicked", ShengSiZhanGuiZeDlg1.st1, self)
	self.m_st2:subscribeEvent("Clicked", ShengSiZhanGuiZeDlg1.st2, self)
	self.m_st3:subscribeEvent("Clicked", ShengSiZhanGuiZeDlg1.st3, self)
	self.m_st4:subscribeEvent("Clicked", ShengSiZhanGuiZeDlg1.st4, self)
	self.m_st5:subscribeEvent("Clicked", ShengSiZhanGuiZeDlg1.st5, self)
	-- 月宫
	self.m_yg1:subscribeEvent("Clicked", ShengSiZhanGuiZeDlg1.yg1, self)
	self.m_yg2:subscribeEvent("Clicked", ShengSiZhanGuiZeDlg1.yg2, self)
	self.m_yg3:subscribeEvent("Clicked", ShengSiZhanGuiZeDlg1.yg3, self)
	self.m_yg4:subscribeEvent("Clicked", ShengSiZhanGuiZeDlg1.yg4, self)
	self.m_yg5:subscribeEvent("Clicked", ShengSiZhanGuiZeDlg1.yg5, self)
	-- 五庄
	self.m_wz1:subscribeEvent("Clicked", ShengSiZhanGuiZeDlg1.wz1, self)
	self.m_wz2:subscribeEvent("Clicked", ShengSiZhanGuiZeDlg1.wz2, self)
	self.m_wz3:subscribeEvent("Clicked", ShengSiZhanGuiZeDlg1.wz3, self)
	self.m_wz4:subscribeEvent("Clicked", ShengSiZhanGuiZeDlg1.wz4, self)
	self.m_wz5:subscribeEvent("Clicked", ShengSiZhanGuiZeDlg1.wz5, self)
	-- 天宫
	self.m_tg1:subscribeEvent("Clicked", ShengSiZhanGuiZeDlg1.tg1, self)
	self.m_tg2:subscribeEvent("Clicked", ShengSiZhanGuiZeDlg1.tg2, self)
	self.m_tg3:subscribeEvent("Clicked", ShengSiZhanGuiZeDlg1.tg3, self)
	self.m_tg4:subscribeEvent("Clicked", ShengSiZhanGuiZeDlg1.tg4, self)
	self.m_tg5:subscribeEvent("Clicked", ShengSiZhanGuiZeDlg1.tg5, self)




 
    self:GetWindow():setRiseOnClickEnabled(false)
    self:GetWindow():setAlwaysOnBottom(true)
end
------------------------------------------------------
--大唐1-5级经脉表
------------------------------------------------------
function ShengSiZhanGuiZeDlg1:HandleTipsBtn()

    local dlg = require "logic.shengsizhan.jingmaitips".getInstance()

    if dlg then
        dlg.getInstanceAndShow()
        dlg:RefreshData(self.m_OldSchoolList, self.m_OldClassList)
    end

end

function ShengSiZhanGuiZeDlg1:dt1(args)
   local dlg = require("logic.shengsizhan.jingmaihecheng_dt1").getInstanceAndShow()
	--local dlg = require("logic.pet.shenshouIncrease").getInstanceAndShow()

end
function ShengSiZhanGuiZeDlg1:dt2(args)
	local dlg = require("logic.shengsizhan.jingmaihecheng_dt2").getInstanceAndShow()
	 --local dlg = require("logic.pet.shenshouIncrease").getInstanceAndShow()
 
 end
 function ShengSiZhanGuiZeDlg1:dt3(args)
	local dlg = require("logic.shengsizhan.jingmaihecheng_dt3").getInstanceAndShow()
	 --local dlg = require("logic.pet.shenshouIncrease").getInstanceAndShow()
 
 end
 function ShengSiZhanGuiZeDlg1:dt4(args)
	local dlg = require("logic.shengsizhan.jingmaihecheng_dt4").getInstanceAndShow()
	 --local dlg = require("logic.pet.shenshouIncrease").getInstanceAndShow()
 
 end
 function ShengSiZhanGuiZeDlg1:dt5(args)
	local dlg = require("logic.shengsizhan.jingmaihecheng_dt5").getInstanceAndShow()
	 --local dlg = require("logic.pet.shenshouIncrease").getInstanceAndShow()
 
 end

--地府1-5级经脉表
 function ShengSiZhanGuiZeDlg1:df1(args)
	local dlg = require("logic.shengsizhan.jingmaihecheng_df1").getInstanceAndShow()
	 --local dlg = require("logic.pet.shenshouIncrease").getInstanceAndShow()
 
 end
 function ShengSiZhanGuiZeDlg1:df2(args)
	 local dlg = require("logic.shengsizhan.jingmaihecheng_df2").getInstanceAndShow()
	  --local dlg = require("logic.pet.shenshouIncrease").getInstanceAndShow()
  
  end
  function ShengSiZhanGuiZeDlg1:df3(args)
	 local dlg = require("logic.shengsizhan.jingmaihecheng_df3").getInstanceAndShow()
	  --local dlg = require("logic.pet.shenshouIncrease").getInstanceAndShow()
  
  end
  function ShengSiZhanGuiZeDlg1:df4(args)
	 local dlg = require("logic.shengsizhan.jingmaihecheng_df4").getInstanceAndShow()
	  --local dlg = require("logic.pet.shenshouIncrease").getInstanceAndShow()
  
  end
  function ShengSiZhanGuiZeDlg1:df5(args)
	 local dlg = require("logic.shengsizhan.jingmaihecheng_df5").getInstanceAndShow()
	  --local dlg = require("logic.pet.shenshouIncrease").getInstanceAndShow()
  
  end

	--方寸1-5级经脉表
	function ShengSiZhanGuiZeDlg1:fc1(args)
		local dlg = require("logic.shengsizhan.jingmaihecheng_fc1").getInstanceAndShow()
		 --local dlg = require("logic.pet.shenshouIncrease").getInstanceAndShow()
	 
	 end
	 function ShengSiZhanGuiZeDlg1:fc2(args)
		 local dlg = require("logic.shengsizhan.jingmaihecheng_fc2").getInstanceAndShow()
		  --local dlg = require("logic.pet.shenshouIncrease").getInstanceAndShow()
	  
	  end
	  function ShengSiZhanGuiZeDlg1:fc3(args)
		 local dlg = require("logic.shengsizhan.jingmaihecheng_fc3").getInstanceAndShow()
		  --local dlg = require("logic.pet.shenshouIncrease").getInstanceAndShow()
	  
	  end
	  function ShengSiZhanGuiZeDlg1:fc4(args)
		 local dlg = require("logic.shengsizhan.jingmaihecheng_fc4").getInstanceAndShow()
		  --local dlg = require("logic.pet.shenshouIncrease").getInstanceAndShow()
	  
	  end
	  function ShengSiZhanGuiZeDlg1:fc5(args)
		 local dlg = require("logic.shengsizhan.jingmaihecheng_fc5").getInstanceAndShow()
		  --local dlg = require("logic.pet.shenshouIncrease").getInstanceAndShow()
	  
	  end

	--化生1-5级经脉表
	function ShengSiZhanGuiZeDlg1:hs1(args)
		local dlg = require("logic.shengsizhan.jingmaihecheng_hs1").getInstanceAndShow()
		 --local dlg = require("logic.pet.shenshouIncrease").getInstanceAndShow()
	 
	 end
	 function ShengSiZhanGuiZeDlg1:hs2(args)
		 local dlg = require("logic.shengsizhan.jingmaihecheng_hs2").getInstanceAndShow()
		  --local dlg = require("logic.pet.shenshouIncrease").getInstanceAndShow()
	  
	  end
	  function ShengSiZhanGuiZeDlg1:hs3(args)
		 local dlg = require("logic.shengsizhan.jingmaihecheng_hs3").getInstanceAndShow()
		  --local dlg = require("logic.pet.shenshouIncrease").getInstanceAndShow()
	  
	  end
	  function ShengSiZhanGuiZeDlg1:hs4(args)
		 local dlg = require("logic.shengsizhan.jingmaihecheng_hs4").getInstanceAndShow()
		  --local dlg = require("logic.pet.shenshouIncrease").getInstanceAndShow()
	  
	  end
	  function ShengSiZhanGuiZeDlg1:hs5(args)
		 local dlg = require("logic.shengsizhan.jingmaihecheng_hs5").getInstanceAndShow()
		  --local dlg = require("logic.pet.shenshouIncrease").getInstanceAndShow()
	  
	  end

	--龙宫1-5级经脉表
	function ShengSiZhanGuiZeDlg1:lg1(args)
		local dlg = require("logic.shengsizhan.jingmaihecheng_lg1").getInstanceAndShow()
		 --local dlg = require("logic.pet.shenshouIncrease").getInstanceAndShow()
	 
	 end
	 function ShengSiZhanGuiZeDlg1:lg2(args)
		 local dlg = require("logic.shengsizhan.jingmaihecheng_lg2").getInstanceAndShow()
		  --local dlg = require("logic.pet.shenshouIncrease").getInstanceAndShow()
	  
	  end
	  function ShengSiZhanGuiZeDlg1:lg3(args)
		 local dlg = require("logic.shengsizhan.jingmaihecheng_lg3").getInstanceAndShow()
		  --local dlg = require("logic.pet.shenshouIncrease").getInstanceAndShow()
	  
	  end
	  function ShengSiZhanGuiZeDlg1:lg4(args)
		 local dlg = require("logic.shengsizhan.jingmaihecheng_lg4").getInstanceAndShow()
		  --local dlg = require("logic.pet.shenshouIncrease").getInstanceAndShow()
	  
	  end
	  function ShengSiZhanGuiZeDlg1:lg5(args)
		 local dlg = require("logic.shengsizhan.jingmaihecheng_lg5").getInstanceAndShow()
		  --local dlg = require("logic.pet.shenshouIncrease").getInstanceAndShow()
	  
	  end

	--魔王1-5级经脉表
	function ShengSiZhanGuiZeDlg1:mw1(args)
		local dmw = require("logic.shengsizhan.jingmaihecheng_mw1").getInstanceAndShow()
		 --local dmw = require("logic.pet.shenshouIncrease").getInstanceAndShow()
	 
	 end
	 function ShengSiZhanGuiZeDlg1:mw2(args)
		 local dmw = require("logic.shengsizhan.jingmaihecheng_mw2").getInstanceAndShow()
		  --local dmw = require("logic.pet.shenshouIncrease").getInstanceAndShow()
	  
	  end
	  function ShengSiZhanGuiZeDlg1:mw3(args)
		 local dmw = require("logic.shengsizhan.jingmaihecheng_mw3").getInstanceAndShow()
		  --local dmw = require("logic.pet.shenshouIncrease").getInstanceAndShow()
	  
	  end
	  function ShengSiZhanGuiZeDlg1:mw4(args)
		 local dmw = require("logic.shengsizhan.jingmaihecheng_mw4").getInstanceAndShow()
		  --local dmw = require("logic.pet.shenshouIncrease").getInstanceAndShow()
	  
	  end
	  function ShengSiZhanGuiZeDlg1:mw5(args)
		 local dmw = require("logic.shengsizhan.jingmaihecheng_mw5").getInstanceAndShow()
		  --local dmw = require("logic.pet.shenshouIncrease").getInstanceAndShow()
	  
	  end

	--女儿1-5级经脉表
	function ShengSiZhanGuiZeDlg1:ne1(args)
		local dne = require("logic.shengsizhan.jingmaihecheng_ne1").getInstanceAndShow()
		 --local dne = require("logic.pet.shenshouIncrease").getInstanceAndShow()
	 
	 end
	 function ShengSiZhanGuiZeDlg1:ne2(args)
		 local dne = require("logic.shengsizhan.jingmaihecheng_ne2").getInstanceAndShow()
		  --local dne = require("logic.pet.shenshouIncrease").getInstanceAndShow()
	  
	  end
	  function ShengSiZhanGuiZeDlg1:ne3(args)
		 local dne = require("logic.shengsizhan.jingmaihecheng_ne3").getInstanceAndShow()
		  --local dne = require("logic.pet.shenshouIncrease").getInstanceAndShow()
	  
	  end
	  function ShengSiZhanGuiZeDlg1:ne4(args)
		 local dne = require("logic.shengsizhan.jingmaihecheng_ne4").getInstanceAndShow()
		  --local dne = require("logic.pet.shenshouIncrease").getInstanceAndShow()
	  
	  end
	  function ShengSiZhanGuiZeDlg1:ne5(args)
		 local dne = require("logic.shengsizhan.jingmaihecheng_ne5").getInstanceAndShow()
		  --local dne = require("logic.pet.shenshouIncrease").getInstanceAndShow()
	  
	  end

	--普陀1-5级经脉表
	function ShengSiZhanGuiZeDlg1:pt1(args)
		local dpt = require("logic.shengsizhan.jingmaihecheng_pt1").getInstanceAndShow()
		 --local dpt = require("logic.pet.shenshouIncrease").getInstanceAndShow()
	 
	 end
	 function ShengSiZhanGuiZeDlg1:pt2(args)
		 local dpt = require("logic.shengsizhan.jingmaihecheng_pt2").getInstanceAndShow()
		  --local dpt = require("logic.pet.shenshouIncrease").getInstanceAndShow()
	  
	  end
	  function ShengSiZhanGuiZeDlg1:pt3(args)
		 local dpt = require("logic.shengsizhan.jingmaihecheng_pt3").getInstanceAndShow()
		  --local dpt = require("logic.pet.shenshouIncrease").getInstanceAndShow()
	  
	  end
	  function ShengSiZhanGuiZeDlg1:pt4(args)
		 local dpt = require("logic.shengsizhan.jingmaihecheng_pt4").getInstanceAndShow()
		  --local dpt = require("logic.pet.shenshouIncrease").getInstanceAndShow()
	  
	  end
	  function ShengSiZhanGuiZeDlg1:pt5(args)
		 local dpt = require("logic.shengsizhan.jingmaihecheng_pt5").getInstanceAndShow()
		  --local dpt = require("logic.pet.shenshouIncrease").getInstanceAndShow()
	  
	  end

	--狮驼1-5级经脉表
	function ShengSiZhanGuiZeDlg1:st1(args)
		local dst = require("logic.shengsizhan.jingmaihecheng_st1").getInstanceAndShow()
		 --local dst = require("logic.pet.shenshouIncrease").getInstanceAndShow()
	 
	 end
	 function ShengSiZhanGuiZeDlg1:st2(args)
		 local dst = require("logic.shengsizhan.jingmaihecheng_st2").getInstanceAndShow()
		  --local dst = require("logic.pet.shenshouIncrease").getInstanceAndShow()
	  
	  end
	  function ShengSiZhanGuiZeDlg1:st3(args)
		 local dst = require("logic.shengsizhan.jingmaihecheng_st3").getInstanceAndShow()
		  --local dst = require("logic.pet.shenshouIncrease").getInstanceAndShow()
	  
	  end
	  function ShengSiZhanGuiZeDlg1:st4(args)
		 local dst = require("logic.shengsizhan.jingmaihecheng_st4").getInstanceAndShow()
		  --local dst = require("logic.pet.shenshouIncrease").getInstanceAndShow()
	  
	  end
	  function ShengSiZhanGuiZeDlg1:st5(args)
		 local dst = require("logic.shengsizhan.jingmaihecheng_st5").getInstanceAndShow()
		  --local dst = require("logic.pet.shenshouIncrease").getInstanceAndShow()
	  
	  end

	--月宫1-5级经脉表
	function ShengSiZhanGuiZeDlg1:yg1(args)
		local dyg = require("logic.shengsizhan.jingmaihecheng_yg1").getInstanceAndShow()
		 --local dyg = require("logic.pet.shenshouIncrease").getInstanceAndShow()
	 
	 end
	 function ShengSiZhanGuiZeDlg1:yg2(args)
		 local dyg = require("logic.shengsizhan.jingmaihecheng_yg2").getInstanceAndShow()
		  --local dyg = require("logic.pet.shenshouIncrease").getInstanceAndShow()
	  
	  end
	  function ShengSiZhanGuiZeDlg1:yg3(args)
		 local dyg = require("logic.shengsizhan.jingmaihecheng_yg3").getInstanceAndShow()
		  --local dyg = require("logic.pet.shenshouIncrease").getInstanceAndShow()
	  
	  end
	  function ShengSiZhanGuiZeDlg1:yg4(args)
		 local dyg = require("logic.shengsizhan.jingmaihecheng_yg4").getInstanceAndShow()
		  --local dyg = require("logic.pet.shenshouIncrease").getInstanceAndShow()
	  
	  end
	  function ShengSiZhanGuiZeDlg1:yg5(args)
		 local dyg = require("logic.shengsizhan.jingmaihecheng_yg5").getInstanceAndShow()
		  --local dyg = require("logic.pet.shenshouIncrease").getInstanceAndShow()
	  
	  end

	--五庄1-5级经脉表
	function ShengSiZhanGuiZeDlg1:wz1(args)
		local dwz = require("logic.shengsizhan.jingmaihecheng_wz1").getInstanceAndShow()
		 --local dwz = require("logic.pet.shenshouIncrease").getInstanceAndShow()
	 
	 end
	 function ShengSiZhanGuiZeDlg1:wz2(args)
		 local dwz = require("logic.shengsizhan.jingmaihecheng_wz2").getInstanceAndShow()
		  --local dwz = require("logic.pet.shenshouIncrease").getInstanceAndShow()
	  
	  end
	  function ShengSiZhanGuiZeDlg1:wz3(args)
		 local dwz = require("logic.shengsizhan.jingmaihecheng_wz3").getInstanceAndShow()
		  --local dwz = require("logic.pet.shenshouIncrease").getInstanceAndShow()
	  
	  end
	  function ShengSiZhanGuiZeDlg1:wz4(args)
		 local dwz = require("logic.shengsizhan.jingmaihecheng_wz4").getInstanceAndShow()
		  --local dwz = require("logic.pet.shenshouIncrease").getInstanceAndShow()
	  
	  end
	  function ShengSiZhanGuiZeDlg1:wz5(args)
		 local dwz = require("logic.shengsizhan.jingmaihecheng_wz5").getInstanceAndShow()
		  --local dwz = require("logic.pet.shenshouIncrease").getInstanceAndShow()
	  
	  end

	--天宫1-5级经脉表
	function ShengSiZhanGuiZeDlg1:tg1(args)
		local dtg = require("logic.shengsizhan.jingmaihecheng_tg1").getInstanceAndShow()
		 --local dtg = require("logic.pet.shenshouIncrease").getInstanceAndShow()
	 
	 end
	 function ShengSiZhanGuiZeDlg1:tg2(args)
		 local dtg = require("logic.shengsizhan.jingmaihecheng_tg2").getInstanceAndShow()
		  --local dtg = require("logic.pet.shenshouIncrease").getInstanceAndShow()
	  
	  end
	  function ShengSiZhanGuiZeDlg1:tg3(args)
		 local dtg = require("logic.shengsizhan.jingmaihecheng_tg3").getInstanceAndShow()
		  --local dtg = require("logic.pet.shenshouIncrease").getInstanceAndShow()
	  
	  end
	  function ShengSiZhanGuiZeDlg1:tg4(args)
		 local dtg = require("logic.shengsizhan.jingmaihecheng_tg4").getInstanceAndShow()
		  --local dtg = require("logic.pet.shenshouIncrease").getInstanceAndShow()
	  
	  end
	  function ShengSiZhanGuiZeDlg1:tg5(args)
		 local dtg = require("logic.shengsizhan.jingmaihecheng_tg5").getInstanceAndShow()
		  --local dtg = require("logic.pet.shenshouIncrease").getInstanceAndShow()
	  
	  end
------------------------------------------------------


-- function ShengSiZhanGuiZeDlg1:HandleKuaijieBtnClicked(args)
--     require "logic.shengsizhan.jingmaihechengdt":new()
--     if CChatOutputDialog:getInstance() then
--         CChatOutputDialog:getInstance():OnClose()
--     end
-- end

-- function ShengSiZhanGuiZeDlg1:HandlePetIconClick(EventArgs)
--     require "logic.pet.petlabel".Show()
--     if CChatOutputDialog:getInstance() then
--         CChatOutputDialog:getInstance():OnClose()
--     end
-- end

-- function ShengSiZhanGuiZeDlg1.HandleKuaijieBtnClicked()
-- 	local nNpcKey = 0
-- 	local nServiceId = TaskHelper.nPingDingAnBangServiceId
-- 	require "manager.npcservicemanager".SendNpcService(nNpcKey,nServiceId)

-- end


return ShengSiZhanGuiZeDlg1
