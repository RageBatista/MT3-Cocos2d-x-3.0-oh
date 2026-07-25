require "utils.tableutil"
CUpYingYongBaoInfo = {}
CUpYingYongBaoInfo.__index = CUpYingYongBaoInfo



CUpYingYongBaoInfo.PROTOCOL_TYPE = 812492

function CUpYingYongBaoInfo.Create()
	print("enter CUpYingYongBaoInfo create")
	return CUpYingYongBaoInfo:new()
end
function CUpYingYongBaoInfo:new()
	local self = {}
	setmetatable(self, CUpYingYongBaoInfo)
	self.type = self.PROTOCOL_TYPE
	self.openid = "" 
	self.openkey = "" 
	self.paytoken = "" 
	self.pf = "" 
	self.pfkey = "" 
	self.zoneid = "" 
	self.platformname = "" 

	return self
end
function CUpYingYongBaoInfo:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function CUpYingYongBaoInfo:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_wstring(self.openid)
	_os_:marshal_wstring(self.openkey)
	_os_:marshal_wstring(self.paytoken)
	_os_:marshal_wstring(self.pf)
	_os_:marshal_wstring(self.pfkey)
	_os_:marshal_wstring(self.zoneid)
	_os_:marshal_wstring(self.platformname)
	return _os_
end

function CUpYingYongBaoInfo:unmarshal(_os_)
	self.openid = _os_:unmarshal_wstring(self.openid)
	self.openkey = _os_:unmarshal_wstring(self.openkey)
	self.paytoken = _os_:unmarshal_wstring(self.paytoken)
	self.pf = _os_:unmarshal_wstring(self.pf)
	self.pfkey = _os_:unmarshal_wstring(self.pfkey)
	self.zoneid = _os_:unmarshal_wstring(self.zoneid)
	self.platformname = _os_:unmarshal_wstring(self.platformname)
	return _os_
end

return CUpYingYongBaoInfo
