require "utils.tableutil"
NpcExecuteTaskTypes = {
	NPC_TALK = 10,
	GIVE_MONEY = 11,
	GIVE_ITEM = 12,
	GIVE_PET = 13,
	ANSWER_QUESTION = 17,
	START_BATTLE = 40
}
NpcExecuteTaskTypes.__index = NpcExecuteTaskTypes


function NpcExecuteTaskTypes:new()
	local self = {}
	setmetatable(self, NpcExecuteTaskTypes)
	return self
end
function NpcExecuteTaskTypes:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	return _os_
end

function NpcExecuteTaskTypes:unmarshal(_os_)
	return _os_
end

return NpcExecuteTaskTypes
