require "utils.stringbuilder"
GetDataInfoMsg = {}

local time = 0
function GetDataInfoMsg.run(delta)
	time = time + delta
end

function GetDataInfoMsg.AddNewInfo(roleid, rolename)
	LogInfo("GetDataInfoMsg AddNewInfo")
	local strBuild = StringBuilder:new()	
	strBuild:Set("parameter1", rolename)
	local str = strBuild:GetString(MHSD_UTILS.get_msgtipstring(140740))
	strBuild:delete()
	if time > 10000 then
		time = 0
		GetCTipsManager():AddMessageTip(str)
	else
		if GetChatManager() then
			GetChatManager():AddMsg_Message(str,true)
		end
	end
end

return GetDataInfoMsg
