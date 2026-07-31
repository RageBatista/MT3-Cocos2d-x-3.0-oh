require "utils.tableutil"
require "protodef.rpcgen.fire.pb.cross.tabledata"
SendRoleData = {}
SendRoleData.__index = SendRoleData



SendRoleData.PROTOCOL_TYPE = 819066

function SendRoleData.Create()
	print("enter SendRoleData create")
	return SendRoleData:new()
end
function SendRoleData:new()
	local self = {}
	setmetatable(self, SendRoleData)
	self.type = self.PROTOCOL_TYPE
	self.roleid = 0
	self.tablename = "" 
	self.valuedata = FireNet.Octets() 
	self.keydata = FireNet.Octets() 
	self.isemptytable = 0
	self.relationdata = {}

	return self
end
function SendRoleData:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function SendRoleData:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_int64(self.roleid)
	_os_:marshal_wstring(self.tablename)
	_os_: marshal_octets(self.valuedata)
	_os_: marshal_octets(self.keydata)
	_os_:marshal_char(self.isemptytable)

	----------------marshal list
	_os_:compact_uint32(TableUtil.tablelength(self.relationdata))
	for k,v in ipairs(self.relationdata) do
		----------------marshal bean
		v:marshal(_os_) 
	end

	return _os_
end

function SendRoleData:unmarshal(_os_)
	self.roleid = _os_:unmarshal_int64()
	self.tablename = _os_:unmarshal_wstring(self.tablename)
	_os_:unmarshal_octets(self.valuedata)
	_os_:unmarshal_octets(self.keydata)
	self.isemptytable = _os_:unmarshal_char()
	----------------unmarshal list
	local sizeof_relationdata=0 ,_os_null_relationdata
	_os_null_relationdata, sizeof_relationdata = _os_: uncompact_uint32(sizeof_relationdata)
	for k = 1,sizeof_relationdata do
		----------------unmarshal bean
		self.relationdata[k]=TableData:new()

		self.relationdata[k]:unmarshal(_os_)

	end
	return _os_
end

return SendRoleData
