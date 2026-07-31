require "utils.tableutil"
require "protodef.rpcgen.fire.pb.item.equipnaijiu"
SRefreshNaiJiu = {}
SRefreshNaiJiu.__index = SRefreshNaiJiu



SRefreshNaiJiu.PROTOCOL_TYPE = 787474

function SRefreshNaiJiu.Create()
	print("enter SRefreshNaiJiu create")
	return SRefreshNaiJiu:new()
end
function SRefreshNaiJiu:new()
	local self = {}
	setmetatable(self, SRefreshNaiJiu)
	self.type = self.PROTOCOL_TYPE
	self.packid = 0
	self.data = {}

	return self
end
function SRefreshNaiJiu:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function SRefreshNaiJiu:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_int32(self.packid)

	----------------marshal vector
	_os_:compact_uint32(TableUtil.tablelength(self.data))
	for k,v in ipairs(self.data) do
		----------------marshal bean
		v:marshal(_os_) 
	end

	return _os_
end

function SRefreshNaiJiu:unmarshal(_os_)
	self.packid = _os_:unmarshal_int32()
	----------------unmarshal vector
	local sizeof_data=0,_os_null_data
	_os_null_data, sizeof_data = _os_: uncompact_uint32(sizeof_data)
	for k = 1,sizeof_data do
		----------------unmarshal bean
		self.data[k]=EquipNaiJiu:new()

		self.data[k]:unmarshal(_os_)

	end
	return _os_
end

return SRefreshNaiJiu
