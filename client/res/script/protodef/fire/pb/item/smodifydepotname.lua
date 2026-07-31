require "utils.tableutil"
SModifyDepotName = {}
SModifyDepotName.__index = SModifyDepotName



SModifyDepotName.PROTOCOL_TYPE = 787772

function SModifyDepotName.Create()
	print("enter SModifyDepotName create")
	return SModifyDepotName:new()
end
function SModifyDepotName:new()
	local self = {}
	setmetatable(self, SModifyDepotName)
	self.type = self.PROTOCOL_TYPE
	self.errcode = 0
	self.depotindex = 0
	self.depotname = "" 

	return self
end
function SModifyDepotName:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function SModifyDepotName:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_int32(self.errcode)
	_os_:marshal_int32(self.depotindex)
	_os_:marshal_wstring(self.depotname)
	return _os_
end

function SModifyDepotName:unmarshal(_os_)
	self.errcode = _os_:unmarshal_int32()
	self.depotindex = _os_:unmarshal_int32()
	self.depotname = _os_:unmarshal_wstring(self.depotname)
	return _os_
end

return SModifyDepotName
