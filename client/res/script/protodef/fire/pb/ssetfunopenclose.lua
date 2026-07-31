require "utils.tableutil"
require "protodef.rpcgen.fire.pb.funopenclose"
SSetFunOpenClose = {}
SSetFunOpenClose.__index = SSetFunOpenClose



SSetFunOpenClose.PROTOCOL_TYPE = 786546

function SSetFunOpenClose.Create()
	print("enter SSetFunOpenClose create")
	return SSetFunOpenClose:new()
end
function SSetFunOpenClose:new()
	local self = {}
	setmetatable(self, SSetFunOpenClose)
	self.type = self.PROTOCOL_TYPE
	self.info = {}

	return self
end
function SSetFunOpenClose:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function SSetFunOpenClose:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()

	----------------marshal vector
	_os_:compact_uint32(TableUtil.tablelength(self.info))
	for k,v in ipairs(self.info) do
		----------------marshal bean
		v:marshal(_os_) 
	end

	return _os_
end

function SSetFunOpenClose:unmarshal(_os_)
	----------------unmarshal vector
	local sizeof_info=0,_os_null_info
	_os_null_info, sizeof_info = _os_: uncompact_uint32(sizeof_info)
	for k = 1,sizeof_info do
		----------------unmarshal bean
		self.info[k]=FunOpenClose:new()

		self.info[k]:unmarshal(_os_)

	end
	return _os_
end

return SSetFunOpenClose
