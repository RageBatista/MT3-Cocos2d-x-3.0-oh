require "utils.tableutil"
CPvP5RankingList = {}
CPvP5RankingList.__index = CPvP5RankingList



CPvP5RankingList.PROTOCOL_TYPE = 793665

function CPvP5RankingList.Create()
	print("enter CPvP5RankingList create")
	return CPvP5RankingList:new()
end
function CPvP5RankingList:new()
	local self = {}
	setmetatable(self, CPvP5RankingList)
	self.type = self.PROTOCOL_TYPE
	return self
end
function CPvP5RankingList:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function CPvP5RankingList:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	return _os_
end

function CPvP5RankingList:unmarshal(_os_)
	return _os_
end

return CPvP5RankingList
