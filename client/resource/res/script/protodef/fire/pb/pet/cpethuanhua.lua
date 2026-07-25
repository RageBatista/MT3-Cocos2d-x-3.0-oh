require "utils.tableutil"
CPetHuanHua = {}
CPetHuanHua.__index = CPetHuanHua



CPetHuanHua.PROTOCOL_TYPE = 817941

function CPetHuanHua.Create()
	print("enter CPetHuanHua create")
	return CPetHuanHua:new()
end
function CPetHuanHua:new()
	local self = {}
	setmetatable(self, CPetHuanHua)
	self.type = self.PROTOCOL_TYPE
	self.petkey = 0
	self.resultkey = 0
	return self
end
function CPetHuanHua:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function CPetHuanHua:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_int32(self.petkey)
	_os_:marshal_int32(self.resultkey)
	return _os_
end

function CPetHuanHua:unmarshal(_os_)
	self.petkey = _os_:unmarshal_int32()
	self.resultkey = _os_:unmarshal_int32()
	return _os_
end

return CPetHuanHua
