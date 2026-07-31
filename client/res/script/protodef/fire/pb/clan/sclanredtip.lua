require "utils.tableutil"
SClanRedTip = {}
SClanRedTip.__index = SClanRedTip



SClanRedTip.PROTOCOL_TYPE = 808517

function SClanRedTip.Create()
	print("enter SClanRedTip create")
	return SClanRedTip:new()
end
function SClanRedTip:new()
	local self = {}
	setmetatable(self, SClanRedTip)
	self.type = self.PROTOCOL_TYPE
	self.redtips = {}

	return self
end
function SClanRedTip:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function SClanRedTip:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()

	----------------marshal map
	_os_:compact_uint32(TableUtil.tablelength(self.redtips))
	for k,v in pairs(self.redtips) do
		_os_:marshal_int32(k)
		_os_:marshal_int32(v)
	end

	return _os_
end

function SClanRedTip:unmarshal(_os_)
	----------------unmarshal map
	local sizeof_redtips=0,_os_null_redtips
	_os_null_redtips, sizeof_redtips = _os_: uncompact_uint32(sizeof_redtips)
	for k = 1,sizeof_redtips do
		local newkey, newvalue
		newkey = _os_:unmarshal_int32()
		newvalue = _os_:unmarshal_int32()
		self.redtips[newkey] = newvalue
	end
	return _os_
end

return SClanRedTip
