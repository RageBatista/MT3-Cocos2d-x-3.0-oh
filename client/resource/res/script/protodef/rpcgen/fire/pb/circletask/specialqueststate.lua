require "utils.tableutil"
SpecialQuestState = {
	SUCCESS = 1,
	FAIL = 2,
	DONE = 3,
	UNDONE = 4,
	ABANDONED = 5,
	RECYCLE = 6,
	INSTANCE_ABANDONED = 7
}
SpecialQuestState.__index = SpecialQuestState


function SpecialQuestState:new()
	local self = {}
	setmetatable(self, SpecialQuestState)
	return self
end
function SpecialQuestState:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	return _os_
end

function SpecialQuestState:unmarshal(_os_)
	return _os_
end

return SpecialQuestState
