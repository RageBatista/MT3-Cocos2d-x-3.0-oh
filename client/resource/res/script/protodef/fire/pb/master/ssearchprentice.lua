require "utils.tableutil"
require "protodef.rpcgen.fire.pb.master.prentice"
SSearchPrentice = {}
SSearchPrentice.__index = SSearchPrentice



SSearchPrentice.PROTOCOL_TYPE = 816447

function SSearchPrentice.Create()
	print("enter SSearchPrentice create")
	return SSearchPrentice:new()
end
function SSearchPrentice:new()
	local self = {}
	setmetatable(self, SSearchPrentice)
	self.type = self.PROTOCOL_TYPE
	self.pageid = 0
	self.totalpage = 0
	self.prentice = {}

	return self
end
function SSearchPrentice:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function SSearchPrentice:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_int32(self.pageid)
	_os_:marshal_int32(self.totalpage)

	----------------marshal vector
	_os_:compact_uint32(TableUtil.tablelength(self.prentice))
	for k,v in ipairs(self.prentice) do
		----------------marshal bean
		v:marshal(_os_) 
	end

	return _os_
end

function SSearchPrentice:unmarshal(_os_)
	self.pageid = _os_:unmarshal_int32()
	self.totalpage = _os_:unmarshal_int32()
	----------------unmarshal vector
	local sizeof_prentice=0,_os_null_prentice
	_os_null_prentice, sizeof_prentice = _os_: uncompact_uint32(sizeof_prentice)
	for k = 1,sizeof_prentice do
		----------------unmarshal bean
		self.prentice[k]=Prentice:new()

		self.prentice[k]:unmarshal(_os_)

	end
	return _os_
end

return SSearchPrentice
