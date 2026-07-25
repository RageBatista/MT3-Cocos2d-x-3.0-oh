require "utils.tableutil"
ReadTimeType = {
	TREASE_MAP = 1,
	USE_TASK_ITEM = 2,
	FOSSICK = 3,
	OPEN_BOX = 4,
	END_TALK_QUEST = 5,
	BEGIN_BATTLE_QUEST = 6,
	END_AREA_QUEST = 7
}
ReadTimeType.__index = ReadTimeType


function ReadTimeType:new()
	local self = {}
	setmetatable(self, ReadTimeType)
	return self
end
function ReadTimeType:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	return _os_
end

function ReadTimeType:unmarshal(_os_)
	return _os_
end

return ReadTimeType
