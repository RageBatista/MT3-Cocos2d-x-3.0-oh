require "utils.tableutil"
SSignList = {}
SSignList.__index = SSignList



SSignList.PROTOCOL_TYPE = 806683

function SSignList.Create()
	print("enter SSignList create")
	return SSignList:new()
end
function SSignList:new()
	local self = {}
	setmetatable(self, SSignList)
	self.type = self.PROTOCOL_TYPE
	self.signcontentmap = {}

	return self
end
function SSignList:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function SSignList:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()

	----------------marshal map
	_os_:compact_uint32(TableUtil.tablelength(self.signcontentmap))
	for k,v in pairs(self.signcontentmap) do
		_os_:marshal_int64(k)
		_os_:marshal_wstring(v)
	end

	return _os_
end

function SSignList:unmarshal(_os_)
	----------------unmarshal map
	local sizeof_signcontentmap=0,_os_null_signcontentmap
	_os_null_signcontentmap, sizeof_signcontentmap = _os_: uncompact_uint32(sizeof_signcontentmap)
	for k = 1,sizeof_signcontentmap do
		local newkey, newvalue
		newkey = _os_:unmarshal_int64()
		newvalue = _os_:unmarshal_wstring(newvalue)
		self.signcontentmap[newkey] = newvalue
	end
	return _os_
end

return SSignList
