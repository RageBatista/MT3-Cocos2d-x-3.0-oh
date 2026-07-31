LuaNewRoleGuide = {}

function LuaNewRoleGuide.PreGuide()
	--LogInfo("luanewroleguide preguide")
  	local winMgr = CEGUI.WindowManager:getSingleton()
	if winMgr then	
		if winMgr:isWindowPresent("npcsceneaniback") then
			return 0
		end
	end

	if NewRoleGuideManager.getInstance() then
		local guideID = NewRoleGuideManager.getInstance():getPreGuideID()
		local record = BeanConfigManager.getInstance():GetTableByName("mission.carroweffect"):getRecorder(guideID)
		local pClickWnd = NewRoleGuideManager.getInstance():GetGuideClickWnd(guideID)
		if pClickWnd and record then
			if record.screen == 1 then
				if (not pClickWnd:isVisible()) and MainControl.getInstanceNotCreate() and MainControl.getInstanceNotCreate():IsInMainControl(pClickWnd) then
       	   			MainControl.getInstanceNotCreate():ShowAllBtns(guideID)
       	   			NewRoleGuideManager.getInstance():RemoveFromWaitingList(guideID)
					return 0
				end	
			elseif	record.screen == 0 then
				if not pClickWnd:isVisible() then 
					if MainControl.getInstanceNotCreate() and MainControl.getInstanceNotCreate():IsInMainControl(pClickWnd) then
       	    			if MainControl.getInstanceNotCreate():IsBtnShown(pClickWnd)then
       	    				MainControl.getInstanceNotCreate():ShowAllBtns(guideID)
       	    				NewRoleGuideManager.getInstance():RemoveFromWaitingList(guideID)
							return 0
       	    			else
       	        			NewRoleGuideManager.getInstance():SendGuideFinish(guideID)
       	        			MainControl.getInstanceNotCreate():GuideBtn(guideID)
       	        			NewRoleGuideManager.getInstance():RemoveFromWaitingList(guideID);
							return 0
						end
					end
				end
			end	
		end
	end	
	return 1
end

return LuaNewRoleGuide
