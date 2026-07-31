require "utils.tableutil"
require "protodef.rpcgen.fire.pb.team.useformbook"
CUseFormBook = {}
CUseFormBook.__index = CUseFormBook



CUseFormBook.PROTOCOL_TYPE = 794553

function CUseFormBook.Create()
	print("enter CUseFormBook create")
	return CUseFormBook:new()
end
function CUseFormBook:new()
	local self = {}
	setmetatable(self, CUseFormBook)
	self.type = self.PROTOCOL_TYPE
	self.formationid = 0
	self.listbook = {}

	return self
end
function CUseFormBook:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function CUseFormBook:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_int32(self.formationid)

	----------------marshal list
	_os_:compact_uint32(TableUtil.tablelength(self.listbook))
	for k,v in ipairs(self.listbook) do
		----------------marshal bean
		v:marshal(_os_) 
	end

	return _os_
end

function CUseFormBook:unmarshal(_os_)
	self.formationid = _os_:unmarshal_int32()
	----------------unmarshal list
	local sizeof_listbook=0 ,_os_null_listbook
	_os_null_listbook, sizeof_listbook = _os_: uncompact_uint32(sizeof_listbook)
	for k = 1,sizeof_listbook do
		----------------unmarshal bean
		self.listbook[k]=UseFormBook:new()

		self.listbook[k]:unmarshal(_os_)

	end
	return _os_
end

return CUseFormBook
