require "utils.tableutil"
SRequestImpeachMentView = {}
SRequestImpeachMentView.__index = SRequestImpeachMentView



SRequestImpeachMentView.PROTOCOL_TYPE = 808527

function SRequestImpeachMentView.Create()
	print("enter SRequestImpeachMentView create")
	return SRequestImpeachMentView:new()
end
function SRequestImpeachMentView:new()
	local self = {}
	setmetatable(self, SRequestImpeachMentView)
	self.type = self.PROTOCOL_TYPE
	self.impeachstate = 0
	self.maxnum = 0
	self.impeachname = "" 
	self.impeachtime = 0
	self.curnum = 0

	return self
end
function SRequestImpeachMentView:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function SRequestImpeachMentView:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_char(self.impeachstate)
	_os_:marshal_short(self.maxnum)
	_os_:marshal_wstring(self.impeachname)
	_os_:marshal_int64(self.impeachtime)
	_os_:marshal_short(self.curnum)
	return _os_
end

function SRequestImpeachMentView:unmarshal(_os_)
	self.impeachstate = _os_:unmarshal_char()
	self.maxnum = _os_:unmarshal_short()
	self.impeachname = _os_:unmarshal_wstring(self.impeachname)
	self.impeachtime = _os_:unmarshal_int64()
	self.curnum = _os_:unmarshal_short()
	return _os_
end

return SRequestImpeachMentView
