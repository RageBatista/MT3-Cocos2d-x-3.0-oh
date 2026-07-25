require "utils.tableutil"
SExpMessageTips = {}
SExpMessageTips.__index = SExpMessageTips



SExpMessageTips.PROTOCOL_TYPE = 792447

function SExpMessageTips.Create()
	print("enter SExpMessageTips create")
	return SExpMessageTips:new()
end
function SExpMessageTips:new()
	local self = {}
	setmetatable(self, SExpMessageTips)
	self.type = self.PROTOCOL_TYPE
	self.messageid = 0
	self.expvalue = 0
	self.messageinfo = {}

	return self
end
function SExpMessageTips:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function SExpMessageTips:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_int32(self.messageid)
	_os_:marshal_int64(self.expvalue)

	----------------marshal map
	_os_:compact_uint32(TableUtil.tablelength(self.messageinfo))
	for k,v in pairs(self.messageinfo) do
		_os_:marshal_int32(k)
		_os_:marshal_int64(v)
	end

	return _os_
end

function SExpMessageTips:unmarshal(_os_)
	self.messageid = _os_:unmarshal_int32()
	self.expvalue = _os_:unmarshal_int64()
	----------------unmarshal map
	local sizeof_messageinfo=0,_os_null_messageinfo
	_os_null_messageinfo, sizeof_messageinfo = _os_: uncompact_uint32(sizeof_messageinfo)
	for k = 1,sizeof_messageinfo do
		local newkey, newvalue
		newkey = _os_:unmarshal_int32()
		newvalue = _os_:unmarshal_int64()
		self.messageinfo[newkey] = newvalue
	end
	return _os_
end

return SExpMessageTips
