require "utils.tableutil"
require "logic.item.fabao.fabaoinfo"
SFaBaoShops = {}
SFaBaoShops.__index = SFaBaoShops



SFaBaoShops.PROTOCOL_TYPE = 800089

function SFaBaoShops.Create()
	return SFaBaoShops:new()
end
function SFaBaoShops:new()
	local self = {}
	setmetatable(self, SFaBaoShops)
	self.type = self.PROTOCOL_TYPE
	self.zuoqix = {}
	return self
end
function SFaBaoShops:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function SFaBaoShops:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()

	----------------marshal vector
	_os_:compact_uint32(TableUtil.tablelength(self.zuoqix))
	for k,v in ipairs(self.zuoqix) do
		----------------marshal bean
        _os_:marshal_int32(k)
		v:marshal(_os_)
	end

	return _os_
end

function SFaBaoShops:unmarshal(_os_)
	----------------unmarshal vector
	local sizeof_maillist=0,_os_null_maillist
	_os_null_maillist, sizeof_maillist = _os_: uncompact_uint32(sizeof_maillist)
	for k = 1,sizeof_maillist do
		local newkey = _os_:unmarshal_int32()
		self.zuoqix[newkey]=FaBaoInfo:new()

		self.zuoqix[newkey]:unmarshal(_os_)

	end
	return _os_
end
return SFaBaoShops
