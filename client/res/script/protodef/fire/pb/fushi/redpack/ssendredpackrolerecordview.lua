require "utils.tableutil"
require "protodef.rpcgen.fire.pb.fushi.redpack.redpackrolerecord"
SSendRedPackRoleRecordView = {}
SSendRedPackRoleRecordView.__index = SSendRedPackRoleRecordView



SSendRedPackRoleRecordView.PROTOCOL_TYPE = 812541

function SSendRedPackRoleRecordView.Create()
	print("enter SSendRedPackRoleRecordView create")
	return SSendRedPackRoleRecordView:new()
end
function SSendRedPackRoleRecordView:new()
	local self = {}
	setmetatable(self, SSendRedPackRoleRecordView)
	self.type = self.PROTOCOL_TYPE
	self.modeltype = 0
	self.firstpageflag = 0
	self.redpackallnum = 0
	self.redpackallmoney = 0
	self.redpackallfushi = 0
	self.redpackrolerecord = {}

	return self
end
function SSendRedPackRoleRecordView:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function SSendRedPackRoleRecordView:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_int32(self.modeltype)
	_os_:marshal_int32(self.firstpageflag)
	_os_:marshal_int32(self.redpackallnum)
	_os_:marshal_int64(self.redpackallmoney)
	_os_:marshal_int64(self.redpackallfushi)

	----------------marshal vector
	_os_:compact_uint32(TableUtil.tablelength(self.redpackrolerecord))
	for k,v in ipairs(self.redpackrolerecord) do
		----------------marshal bean
		v:marshal(_os_) 
	end

	return _os_
end

function SSendRedPackRoleRecordView:unmarshal(_os_)
	self.modeltype = _os_:unmarshal_int32()
	self.firstpageflag = _os_:unmarshal_int32()
	self.redpackallnum = _os_:unmarshal_int32()
	self.redpackallmoney = _os_:unmarshal_int64()
	self.redpackallfushi = _os_:unmarshal_int64()
	----------------unmarshal vector
	local sizeof_redpackrolerecord=0,_os_null_redpackrolerecord
	_os_null_redpackrolerecord, sizeof_redpackrolerecord = _os_: uncompact_uint32(sizeof_redpackrolerecord)
	for k = 1,sizeof_redpackrolerecord do
		----------------unmarshal bean
		self.redpackrolerecord[k]=RedPackRoleRecord:new()

		self.redpackrolerecord[k]:unmarshal(_os_)

	end
	return _os_
end

return SSendRedPackRoleRecordView
