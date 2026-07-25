require "utils.tableutil"
CAbandonAnYe = {}
CAbandonAnYe.__index = CAbandonAnYe



CAbandonAnYe.PROTOCOL_TYPE = 807460

function CAbandonAnYe.Create()
	print("enter CAbandonAnYe create")
	return CAbandonAnYe:new()
end
function CAbandonAnYe:new()
	local self = {}
	setmetatable(self, CAbandonAnYe)
	self.type = self.PROTOCOL_TYPE
	self.questid = 0

	return self
end
function CAbandonAnYe:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function CAbandonAnYe:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_int32(self.questid)
	return _os_
end

function CAbandonAnYe:unmarshal(_os_)
	self.questid = _os_:unmarshal_int32()
	return _os_
end

return CAbandonAnYe
