require "utils.tableutil"
CReqAllNaiJiu = {}
CReqAllNaiJiu.__index = CReqAllNaiJiu



CReqAllNaiJiu.PROTOCOL_TYPE = 787654

function CReqAllNaiJiu.Create()
	print("enter CReqAllNaiJiu create")
	return CReqAllNaiJiu:new()
end
function CReqAllNaiJiu:new()
	local self = {}
	setmetatable(self, CReqAllNaiJiu)
	self.type = self.PROTOCOL_TYPE
	self.packid = 0

	return self
end
function CReqAllNaiJiu:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function CReqAllNaiJiu:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_int32(self.packid)
	return _os_
end

function CReqAllNaiJiu:unmarshal(_os_)
	self.packid = _os_:unmarshal_int32()
	return _os_
end

return CReqAllNaiJiu
