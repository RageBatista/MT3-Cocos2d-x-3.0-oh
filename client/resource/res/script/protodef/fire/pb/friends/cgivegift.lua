require "utils.tableutil"
CGiveGift = {}
CGiveGift.__index = CGiveGift



CGiveGift.PROTOCOL_TYPE = 806637

function CGiveGift.Create()
	print("enter CGiveGift create")
	return CGiveGift:new()
end
function CGiveGift:new()
	local self = {}
	setmetatable(self, CGiveGift)
	self.type = self.PROTOCOL_TYPE
	self.roleid = 0
	self.itemid = 0
	self.itemnum = 0
	self.content = "" 
	self.force = 0

	return self
end
function CGiveGift:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function CGiveGift:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_int64(self.roleid)
	_os_:marshal_int32(self.itemid)
	_os_:marshal_char(self.itemnum)
	_os_:marshal_wstring(self.content)
	_os_:marshal_char(self.force)
	return _os_
end

function CGiveGift:unmarshal(_os_)
	self.roleid = _os_:unmarshal_int64()
	self.itemid = _os_:unmarshal_int32()
	self.itemnum = _os_:unmarshal_char()
	self.content = _os_:unmarshal_wstring(self.content)
	self.force = _os_:unmarshal_char()
	return _os_
end

return CGiveGift
