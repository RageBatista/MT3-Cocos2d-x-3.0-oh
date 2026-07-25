require "utils.tableutil"
require "protodef.rpcgen.fire.pb.master.masterprenticebasedata"
SPrenticeList = {}
SPrenticeList.__index = SPrenticeList



SPrenticeList.PROTOCOL_TYPE = 816453

function SPrenticeList.Create()
	print("enter SPrenticeList create")
	return SPrenticeList:new()
end
function SPrenticeList:new()
	local self = {}
	setmetatable(self, SPrenticeList)
	self.type = self.PROTOCOL_TYPE
	self.prentice = {}
	self.itemkey = 0

	return self
end
function SPrenticeList:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function SPrenticeList:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()

	----------------marshal vector
	_os_:compact_uint32(TableUtil.tablelength(self.prentice))
	for k,v in ipairs(self.prentice) do
		----------------marshal bean
		v:marshal(_os_) 
	end

	_os_:marshal_int32(self.itemkey)
	return _os_
end

function SPrenticeList:unmarshal(_os_)
	----------------unmarshal vector
	local sizeof_prentice=0,_os_null_prentice
	_os_null_prentice, sizeof_prentice = _os_: uncompact_uint32(sizeof_prentice)
	for k = 1,sizeof_prentice do
		----------------unmarshal bean
		self.prentice[k]=MasterPrenticeBaseData:new()

		self.prentice[k]:unmarshal(_os_)

	end
	self.itemkey = _os_:unmarshal_int32()
	return _os_
end

return SPrenticeList
