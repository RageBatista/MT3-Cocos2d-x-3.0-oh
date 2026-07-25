require "utils.tableutil"
CQueryLimit = {}
CQueryLimit.__index = CQueryLimit



CQueryLimit.PROTOCOL_TYPE = 810637

function CQueryLimit.Create()
	print("enter CQueryLimit create")
	return CQueryLimit:new()
end
function CQueryLimit:new()
	local self = {}
	setmetatable(self, CQueryLimit)
	self.type = self.PROTOCOL_TYPE
	self.querytype = 0
	self.goodsids = {}

	return self
end
function CQueryLimit:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function CQueryLimit:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_int32(self.querytype)

	----------------marshal vector
	_os_:compact_uint32(TableUtil.tablelength(self.goodsids))
	for k,v in ipairs(self.goodsids) do
		_os_:marshal_int32(v)
	end

	return _os_
end

function CQueryLimit:unmarshal(_os_)
	self.querytype = _os_:unmarshal_int32()
	----------------unmarshal vector
	local sizeof_goodsids=0,_os_null_goodsids
	_os_null_goodsids, sizeof_goodsids = _os_: uncompact_uint32(sizeof_goodsids)
	for k = 1,sizeof_goodsids do
		self.goodsids[k] = _os_:unmarshal_int32()
	end
	return _os_
end

return CQueryLimit
