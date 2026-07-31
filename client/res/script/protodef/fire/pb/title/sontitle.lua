require "utils.tableutil"
SOnTitle = {}
SOnTitle.__index = SOnTitle



SOnTitle.PROTOCOL_TYPE = 798436

function SOnTitle.Create()
	print("enter SOnTitle create")
	return SOnTitle:new()
end
function SOnTitle:new()
	local self = {}
	setmetatable(self, SOnTitle)
	self.type = self.PROTOCOL_TYPE
	self.roleid = 0
	self.titleid = 0
	self.titlename = "" 

	return self
end
function SOnTitle:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function SOnTitle:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_int64(self.roleid)
	_os_:marshal_int32(self.titleid)
	_os_:marshal_wstring(self.titlename)
	return _os_
end

function SOnTitle:unmarshal(_os_)
	self.roleid = _os_:unmarshal_int64()
	self.titleid = _os_:unmarshal_int32()
	self.titlename = _os_:unmarshal_wstring(self.titlename)
	return _os_
end

return SOnTitle
