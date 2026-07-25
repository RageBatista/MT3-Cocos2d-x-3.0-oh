require "utils.tableutil"
SRequestJoinSucc = {}
SRequestJoinSucc.__index = SRequestJoinSucc



SRequestJoinSucc.PROTOCOL_TYPE = 794469

function SRequestJoinSucc.Create()
	print("enter SRequestJoinSucc create")
	return SRequestJoinSucc:new()
end
function SRequestJoinSucc:new()
	local self = {}
	setmetatable(self, SRequestJoinSucc)
	self.type = self.PROTOCOL_TYPE
	self.rolename = "" 

	return self
end
function SRequestJoinSucc:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function SRequestJoinSucc:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_wstring(self.rolename)
	return _os_
end

function SRequestJoinSucc:unmarshal(_os_)
	self.rolename = _os_:unmarshal_wstring(self.rolename)
	return _os_
end

return SRequestJoinSucc
