require "utils.tableutil"
SChangeGoodLockState = {}
SChangeGoodLockState.__index = SChangeGoodLockState



SChangeGoodLockState.PROTOCOL_TYPE = 786588

function SChangeGoodLockState.Create()
	print("enter SChangeGoodLockState create")
	return SChangeGoodLockState:new()
end
function SChangeGoodLockState:new()
	local self = {}
	setmetatable(self, SChangeGoodLockState)
	self.type = self.PROTOCOL_TYPE
	return self
end
function SChangeGoodLockState:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function SChangeGoodLockState:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	return _os_
end

function SChangeGoodLockState:unmarshal(_os_)
	return _os_
end

return SChangeGoodLockState
