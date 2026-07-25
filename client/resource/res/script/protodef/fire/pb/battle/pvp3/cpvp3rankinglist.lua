require "utils.tableutil"
CPvP3RankingList = {}
CPvP3RankingList.__index = CPvP3RankingList



CPvP3RankingList.PROTOCOL_TYPE = 793635

function CPvP3RankingList.Create()
	print("enter CPvP3RankingList create")
	return CPvP3RankingList:new()
end
function CPvP3RankingList:new()
	local self = {}
	setmetatable(self, CPvP3RankingList)
	self.type = self.PROTOCOL_TYPE
	self.history = 0

	return self
end
function CPvP3RankingList:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function CPvP3RankingList:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_char(self.history)
	return _os_
end

function CPvP3RankingList:unmarshal(_os_)
	self.history = _os_:unmarshal_char()
	return _os_
end

return CPvP3RankingList
