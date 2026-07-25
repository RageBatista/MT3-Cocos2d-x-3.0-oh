require "utils.tableutil"
SRequestUsedNameData = {}
SRequestUsedNameData.__index = SRequestUsedNameData



SRequestUsedNameData.PROTOCOL_TYPE = 786505

function SRequestUsedNameData.Create()
	print("enter SRequestUsedNameData create")
	return SRequestUsedNameData:new()
end
function SRequestUsedNameData:new()
	local self = {}
	setmetatable(self, SRequestUsedNameData)
	self.type = self.PROTOCOL_TYPE
	self.usednames = {}
	self.itemkey = 0

	return self
end
function SRequestUsedNameData:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function SRequestUsedNameData:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()

	----------------marshal list
	_os_:compact_uint32(TableUtil.tablelength(self.usednames))
	for k,v in ipairs(self.usednames) do
		_os_:marshal_wstring(v)
	end

	_os_:marshal_int32(self.itemkey)
	return _os_
end

function SRequestUsedNameData:unmarshal(_os_)
	----------------unmarshal list
	local sizeof_usednames=0 ,_os_null_usednames
	_os_null_usednames, sizeof_usednames = _os_: uncompact_uint32(sizeof_usednames)
	for k = 1,sizeof_usednames do
		self.usednames[k] = _os_:unmarshal_wstring(self.usednames[k])
	end
	self.itemkey = _os_:unmarshal_int32()
	return _os_
end

return SRequestUsedNameData
