require "utils.tableutil"
SRequestPrenticeSuccess = {}
SRequestPrenticeSuccess.__index = SRequestPrenticeSuccess



SRequestPrenticeSuccess.PROTOCOL_TYPE = 816442

function SRequestPrenticeSuccess.Create()
	print("enter SRequestPrenticeSuccess create")
	return SRequestPrenticeSuccess:new()
end
function SRequestPrenticeSuccess:new()
	local self = {}
	setmetatable(self, SRequestPrenticeSuccess)
	self.type = self.PROTOCOL_TYPE
	self.masterid = 0
	self.mastername = "" 
	self.binitiative = 0

	return self
end
function SRequestPrenticeSuccess:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function SRequestPrenticeSuccess:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_int64(self.masterid)
	_os_:marshal_wstring(self.mastername)
	_os_:marshal_int32(self.binitiative)
	return _os_
end

function SRequestPrenticeSuccess:unmarshal(_os_)
	self.masterid = _os_:unmarshal_int64()
	self.mastername = _os_:unmarshal_wstring(self.mastername)
	self.binitiative = _os_:unmarshal_int32()
	return _os_
end

return SRequestPrenticeSuccess
