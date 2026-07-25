require "utils.tableutil"
SSendSystemMessageToRole = {}
SSendSystemMessageToRole.__index = SSendSystemMessageToRole



SSendSystemMessageToRole.PROTOCOL_TYPE = 806555

function SSendSystemMessageToRole.Create()
	print("enter SSendSystemMessageToRole create")
	return SSendSystemMessageToRole:new()
end
function SSendSystemMessageToRole:new()
	local self = {}
	setmetatable(self, SSendSystemMessageToRole)
	self.type = self.PROTOCOL_TYPE
	self.systemroleid = 0
	self.contentid = 0
	self.contentparam = {}
	self.time = "" 

	return self
end
function SSendSystemMessageToRole:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function SSendSystemMessageToRole:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_int64(self.systemroleid)
	_os_:marshal_int32(self.contentid)

	----------------marshal vector
	_os_:compact_uint32(TableUtil.tablelength(self.contentparam))
	for k,v in ipairs(self.contentparam) do
		_os_: marshal_octets(v)
	end

	_os_:marshal_wstring(self.time)
	return _os_
end

function SSendSystemMessageToRole:unmarshal(_os_)
	self.systemroleid = _os_:unmarshal_int64()
	self.contentid = _os_:unmarshal_int32()
	----------------unmarshal vector
	local sizeof_contentparam=0,_os_null_contentparam
	_os_null_contentparam, sizeof_contentparam = _os_: uncompact_uint32(sizeof_contentparam)
	for k = 1,sizeof_contentparam do
		self.contentparam[k] = FireNet.Octets()
		_os_:unmarshal_octets(self.contentparam[k])
	end
	self.time = _os_:unmarshal_wstring(self.time)
	return _os_
end

return SSendSystemMessageToRole
