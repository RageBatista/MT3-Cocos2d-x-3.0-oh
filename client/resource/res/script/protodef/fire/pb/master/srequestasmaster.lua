require "utils.tableutil"
SRequestAsMaster = {}
SRequestAsMaster.__index = SRequestAsMaster



SRequestAsMaster.PROTOCOL_TYPE = 816459

function SRequestAsMaster.Create()
	print("enter SRequestAsMaster create")
	return SRequestAsMaster:new()
end
function SRequestAsMaster:new()
	local self = {}
	setmetatable(self, SRequestAsMaster)
	self.type = self.PROTOCOL_TYPE
	self.masterid = 0
	self.prenticename = "" 
	self.school = 0
	self.level = 0
	self.requestword = "" 

	return self
end
function SRequestAsMaster:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function SRequestAsMaster:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_int64(self.masterid)
	_os_:marshal_wstring(self.prenticename)
	_os_:marshal_int32(self.school)
	_os_:marshal_int32(self.level)
	_os_:marshal_wstring(self.requestword)
	return _os_
end

function SRequestAsMaster:unmarshal(_os_)
	self.masterid = _os_:unmarshal_int64()
	self.prenticename = _os_:unmarshal_wstring(self.prenticename)
	self.school = _os_:unmarshal_int32()
	self.level = _os_:unmarshal_int32()
	self.requestword = _os_:unmarshal_wstring(self.requestword)
	return _os_
end

return SRequestAsMaster
