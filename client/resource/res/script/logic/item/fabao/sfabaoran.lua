require "utils.tableutil"
require "logic.item.fabao.fabaoinfo"
SFaBaoRan = {}
SFaBaoRan.__index = SFaBaoRan



SFaBaoRan.PROTOCOL_TYPE = 800094

function SFaBaoRan.Create()
	print("enter CChangeSchool create")
	return SFaBaoRan:new()
end
function SFaBaoRan:new()
	local self = {}
	setmetatable(self, SFaBaoRan)
	self.type = self.PROTOCOL_TYPE
	self.zuoqix = {}
	return self
end
function SFaBaoRan:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function SFaBaoRan:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()

	----------------marshal vector
	_os_:compact_uint32(TableUtil.tablelength(self.zuoqix))
	for k,v in ipairs(self.zuoqix) do
		----------------marshal bean
        _os_:marshal_int32(k)
		_os_:marshal_int32(v)
	end

	return _os_
end

function SFaBaoRan:unmarshal(_os_)
	----------------unmarshal vector
	local sizeof_maillist=0,_os_null_maillist
	_os_null_maillist, sizeof_maillist = _os_: uncompact_uint32(sizeof_maillist)
	for k = 1,sizeof_maillist do
		local newkey = _os_:unmarshal_int32()
		local newv = _os_:unmarshal_int32()
		self.zuoqix[newkey]=newv
	end
	return _os_
end
return SFaBaoRan
