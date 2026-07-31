
ZhenFaTip = {
	desc = {2877, 2878, 2879, 2880, 2881}
};

setmetatable(ZhenFaTip, Dialog);
ZhenFaTip.__index = ZhenFaTip;

local _instance;

function ZhenFaTip.getInstance()
	if _instance == nil then
		_instance = ZhenFaTip:new();
		_instance:OnCreate();
	end

	return _instance;
end

function ZhenFaTip.peekInstance()
	return _instance;
end

function ZhenFaTip.DestroyDialog()
	if _instance then
		if not _instance.m_bCloseIsHide then
			_instance:OnClose()
			_instance = nil
		else
			_instance:ToggleOpenClose()
		end
	end
end

function ZhenFaTip:new()
	local zf = {};
	zf = Dialog:new();
	setmetatable(zf, ZhenFaTip);

	return zf;
end

function ZhenFaTip.GetLayoutFileName()
	return "zhenfatipsdlg.layout";
end

function ZhenFaTip:OnCreate()
	Dialog.OnCreate(self);

	local winMgr = CEGUI.WindowManager:getSingleton();

	self.m_pDest = CEGUI.Window.toRichEditbox(winMgr:getWindow("zhenfatipsdlg/richeditbox"));
	self.m_pName = winMgr:getWindow("zhenfatipsdlg/name");
end

function ZhenFaTip:clipZhenfaIDs(str)
	local ret = {}
	local _,p,s = string.find(str, '(%d+)')
	table.insert(ret, tonumber(s))
	while p do
		_,p,s = string.find(str, '(%d+)', p+1)
		table.insert(ret, tonumber(s))
	end
	return ret
end

function ZhenFaTip:isContains(t, id)
	for _,v in pairs(t) do
		if v == id then
			return true
		end
	end
	return false
end

function ZhenFaTip:SetZhenfaConfig(myZhenfaId, myZhenfaLv, enemyZhenfaId)
	local conf = BeanConfigManager.getInstance():GetTableByName("battle.cformationbaseconfig"):getRecorder(myZhenfaId)
	local restrainConf = BeanConfigManager.getInstance():GetTableByName("battle.cformationrestrain"):getRecorder(myZhenfaId)
	
	local restrainStr = ""
	local ids = self:clipZhenfaIDs(restrainConf.restrain1)
	if self:isContains(ids, enemyZhenfaId) then
		restrainStr = "[colour='ff00ff00'](" .. MHSD_UTILS.get_resstring(11148) .. restrainConf.restrainArg1*100 .. "%)"
	end
	
	if #restrainStr == 0 then
		local ids = self:clipZhenfaIDs(restrainConf.restrain2)
		if self:isContains(ids, enemyZhenfaId) then
			restrainStr = "[colour='ff00ff00'](" .. MHSD_UTILS.get_resstring(11148) .. restrainConf.restrainArg2*100 .. "%)"
		end
	end
	
	if #restrainStr == 0 then
		local ids = self:clipZhenfaIDs(restrainConf.beRestrained1)
		if self:isContains(ids, enemyZhenfaId) then
			restrainStr = "[colour='ffff0000'](" .. MHSD_UTILS.get_resstring(11149) .. restrainConf.beRestrainedArg1*100 .. "%)"
		end
	end
	
	if #restrainStr == 0 then
		local ids = self:clipZhenfaIDs(restrainConf.beRestrained2)
		if self:isContains(ids, enemyZhenfaId) then
			restrainStr = "[colour='ffff0000'](" .. MHSD_UTILS.get_resstring(11149) .. restrainConf.beRestrainedArg2*100 .. "%)"
		end
	end
	
	local name = myZhenfaLv .. MHSD_UTILS.get_resstring(3) .. conf.name .. restrainStr
	self.m_pName:setText(name)
	
	local des = self.m_pDest
	
	local zhenfaEffect = FormationManager.getInstance():getZhenfaEffectConf(myZhenfaId, myZhenfaLv)
	for i=1, 5 do
		if zhenfaEffect.describe:size() < i then
			break
		end
		des:AppendText(CEGUI.String(i .. MHSD_UTILS.get_resstring(1736))) --XºÅÎ»
		
		local str = zhenfaEffect.describe[i-1]
		local text1,text2 = string.match(str, '.*%"(.*)%".*%"(.*)%".*')
		if not text1 then
			text1 = string.match(str, '.*%"(.*)%".*')
		end
		
		if text1 then
			if string.find(text1, "+") then
				text1 = "<T t='" .. text1 .. "' c='ff00ff00' />"
			end
			des:AppendParseText(CEGUI.String(text1))
		end
		
		if text2 then
			des:AppendParseText(CEGUI.String("<T t=', ' c='ffffffff'/>"))
			if string.find(text2, "-") then
				text2 = "<T t='" ..  text2 .. "' c='ffff0000' />"
			end
			des:AppendParseText(CEGUI.String(text2))
		end
		
		des:AppendBreak()
	end
	
	des:Refresh()
end
