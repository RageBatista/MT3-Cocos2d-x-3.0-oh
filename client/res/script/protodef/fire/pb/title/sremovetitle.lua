require "utils.tableutil"
SRemoveTitle = {}
SRemoveTitle.__index = SRemoveTitle



SRemoveTitle.PROTOCOL_TYPE = 798434

function SRemoveTitle.Create()
	print("enter SRemoveTitle create")
	return SRemoveTitle:new()
end
function SRemoveTitle:new()
	local self = {}
	setmetatable(self, SRemoveTitle)
	self.type = self.PROTOCOL_TYPE
	self.titleid = 0

	return self
end
function SRemoveTitle:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function SRemoveTitle:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_int32(self.titleid)
	return _os_
end

function SRemoveTitle:unmarshal(_os_)
	self.titleid = _os_:unmarshal_int32()
	return _os_
end

return SRemoveTitle
