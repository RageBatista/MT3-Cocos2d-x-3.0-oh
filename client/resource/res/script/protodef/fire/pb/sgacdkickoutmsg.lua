require "utils.tableutil"
SGACDKickoutMsg = {}
SGACDKickoutMsg.__index = SGACDKickoutMsg



SGACDKickoutMsg.PROTOCOL_TYPE = 786501

function SGACDKickoutMsg.Create()
	print("enter SGACDKickoutMsg create")
	return SGACDKickoutMsg:new()
end
function SGACDKickoutMsg:new()
	local self = {}
	setmetatable(self, SGACDKickoutMsg)
	self.type = self.PROTOCOL_TYPE
	self.reason = "" 
	self.endtime = 0

	return self
end
function SGACDKickoutMsg:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function SGACDKickoutMsg:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_wstring(self.reason)
	_os_:marshal_int64(self.endtime)
	return _os_
end

function SGACDKickoutMsg:unmarshal(_os_)
	self.reason = _os_:unmarshal_wstring(self.reason)
	self.endtime = _os_:unmarshal_int64()
	return _os_
end

return SGACDKickoutMsg
