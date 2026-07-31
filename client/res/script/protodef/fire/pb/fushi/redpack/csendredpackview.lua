require "utils.tableutil"
CSendRedPackView = {}
CSendRedPackView.__index = CSendRedPackView



CSendRedPackView.PROTOCOL_TYPE = 812532

function CSendRedPackView.Create()
	print("enter CSendRedPackView create")
	return CSendRedPackView:new()
end
function CSendRedPackView:new()
	local self = {}
	setmetatable(self, CSendRedPackView)
	self.type = self.PROTOCOL_TYPE
	self.modeltype = 0
	self.redpackid = "" 

	return self
end
function CSendRedPackView:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function CSendRedPackView:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_int32(self.modeltype)
	_os_:marshal_wstring(self.redpackid)
	return _os_
end

function CSendRedPackView:unmarshal(_os_)
	self.modeltype = _os_:unmarshal_int32()
	self.redpackid = _os_:unmarshal_wstring(self.redpackid)
	return _os_
end

return CSendRedPackView
