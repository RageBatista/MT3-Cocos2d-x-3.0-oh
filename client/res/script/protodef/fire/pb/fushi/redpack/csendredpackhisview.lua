require "utils.tableutil"
CSendRedPackHisView = {}
CSendRedPackHisView.__index = CSendRedPackHisView



CSendRedPackHisView.PROTOCOL_TYPE = 812538

function CSendRedPackHisView.Create()
	print("enter CSendRedPackHisView create")
	return CSendRedPackHisView:new()
end
function CSendRedPackHisView:new()
	local self = {}
	setmetatable(self, CSendRedPackHisView)
	self.type = self.PROTOCOL_TYPE
	self.modeltype = 0
	self.redpackid = "" 

	return self
end
function CSendRedPackHisView:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function CSendRedPackHisView:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_int32(self.modeltype)
	_os_:marshal_wstring(self.redpackid)
	return _os_
end

function CSendRedPackHisView:unmarshal(_os_)
	self.modeltype = _os_:unmarshal_int32()
	self.redpackid = _os_:unmarshal_wstring(self.redpackid)
	return _os_
end

return CSendRedPackHisView
