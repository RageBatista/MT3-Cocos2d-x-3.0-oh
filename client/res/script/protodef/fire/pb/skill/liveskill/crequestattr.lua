require "utils.tableutil"
CRequestAttr = {}
CRequestAttr.__index = CRequestAttr



CRequestAttr.PROTOCOL_TYPE = 800530

function CRequestAttr.Create()
	print("enter CRequestAttr create")
	return CRequestAttr:new()
end
function CRequestAttr:new()
	local self = {}
	setmetatable(self, CRequestAttr)
	self.type = self.PROTOCOL_TYPE
	self.attrid = {}

	return self
end
function CRequestAttr:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function CRequestAttr:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()

	----------------marshal list
	_os_:compact_uint32(TableUtil.tablelength(self.attrid))
	for k,v in ipairs(self.attrid) do
		_os_:marshal_int32(v)
	end

	return _os_
end

function CRequestAttr:unmarshal(_os_)
	----------------unmarshal list
	local sizeof_attrid=0 ,_os_null_attrid
	_os_null_attrid, sizeof_attrid = _os_: uncompact_uint32(sizeof_attrid)
	for k = 1,sizeof_attrid do
		self.attrid[k] = _os_:unmarshal_int32()
	end
	return _os_
end

return CRequestAttr
