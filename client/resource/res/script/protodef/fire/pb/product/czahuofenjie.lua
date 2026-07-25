require "utils.tableutil"
CZahuoFenJie = {}
CZahuoFenJie.__index = CZahuoFenJie



CZahuoFenJie.PROTOCOL_TYPE = 800017

function CZahuoFenJie.Create()
	print("enter CZahuoFenJie create")
	return CZahuoFenJie:new()
end
function CZahuoFenJie:new()
	local self = {}
	setmetatable(self, CZahuoFenJie)
	self.type = self.PROTOCOL_TYPE
	self.itemkey = 0

	return self
end
function CZahuoFenJie:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function CZahuoFenJie:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_int32(self.itemkey)
	return _os_
end

function CZahuoFenJie:unmarshal(_os_)
	self.itemkey = _os_:unmarshal_int32()
	return _os_
end

return CZahuoFenJie
