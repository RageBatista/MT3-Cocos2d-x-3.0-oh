require "utils.tableutil"
ChannelType = {
	CHANNEL_CURRENT = 1,
	CHANNEL_TEAM = 2,
	CHANNEL_PROFESSION = 3,
	CHANNEL_CLAN = 4,
	CHANNEL_WORLD = 5,
	CHANNEL_SYSTEM = 6,
	CHANNEL_MESSAGE = 7,
	CHANNEL_BUBBLE = 8,
	CHANNEL_SLIDE = 9,
	CHANNEL_TEAM_APPLY = 14
}
ChannelType.__index = ChannelType


function ChannelType:new()
	local self = {}
	setmetatable(self, ChannelType)
	return self
end
function ChannelType:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	return _os_
end

function ChannelType:unmarshal(_os_)
	return _os_
end

return ChannelType
