require "utils.tableutil"
SRefreshMaxNaiJiu = {}
SRefreshMaxNaiJiu.__index = SRefreshMaxNaiJiu



SRefreshMaxNaiJiu.PROTOCOL_TYPE = 787476

function SRefreshMaxNaiJiu.Create()
	print("enter SRefreshMaxNaiJiu create")
	return SRefreshMaxNaiJiu:new()
end
function SRefreshMaxNaiJiu:new()
	local self = {}
	setmetatable(self, SRefreshMaxNaiJiu)
	self.type = self.PROTOCOL_TYPE
	self.packid = 0
	self.keyinpack = 0
	self.maxendure = 0

	return self
end
function SRefreshMaxNaiJiu:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function SRefreshMaxNaiJiu:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_int32(self.packid)
	_os_:marshal_int32(self.keyinpack)
	_os_:marshal_int32(self.maxendure)
	return _os_
end

function SRefreshMaxNaiJiu:unmarshal(_os_)
	self.packid = _os_:unmarshal_int32()
	self.keyinpack = _os_:unmarshal_int32()
	self.maxendure = _os_:unmarshal_int32()
	return _os_
end

return SRefreshMaxNaiJiu
