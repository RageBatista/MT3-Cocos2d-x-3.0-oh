require "utils.tableutil"
require "protodef.rpcgen.fire.pb.fushi.redpack.redpackrolehisinfo"
SSendRedPackHisView = {}
SSendRedPackHisView.__index = SSendRedPackHisView



SSendRedPackHisView.PROTOCOL_TYPE = 812539

function SSendRedPackHisView.Create()
	print("enter SSendRedPackHisView create")
	return SSendRedPackHisView:new()
end
function SSendRedPackHisView:new()
	local self = {}
	setmetatable(self, SSendRedPackHisView)
	self.type = self.PROTOCOL_TYPE
	self.modeltype = 0
	self.redpackid = "" 
	self.redpackdes = "" 
	self.redpackallnum = 0
	self.redpackallmoney = 0
	self.time = 0
	self.redpackrolehisinfolist = {}

	return self
end
function SSendRedPackHisView:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function SSendRedPackHisView:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_int32(self.modeltype)
	_os_:marshal_wstring(self.redpackid)
	_os_:marshal_wstring(self.redpackdes)
	_os_:marshal_int32(self.redpackallnum)
	_os_:marshal_int32(self.redpackallmoney)
	_os_:marshal_int64(self.time)

	----------------marshal vector
	_os_:compact_uint32(TableUtil.tablelength(self.redpackrolehisinfolist))
	for k,v in ipairs(self.redpackrolehisinfolist) do
		----------------marshal bean
		v:marshal(_os_) 
	end

	return _os_
end

function SSendRedPackHisView:unmarshal(_os_)
	self.modeltype = _os_:unmarshal_int32()
	self.redpackid = _os_:unmarshal_wstring(self.redpackid)
	self.redpackdes = _os_:unmarshal_wstring(self.redpackdes)
	self.redpackallnum = _os_:unmarshal_int32()
	self.redpackallmoney = _os_:unmarshal_int32()
	self.time = _os_:unmarshal_int64()
	----------------unmarshal vector
	local sizeof_redpackrolehisinfolist=0,_os_null_redpackrolehisinfolist
	_os_null_redpackrolehisinfolist, sizeof_redpackrolehisinfolist = _os_: uncompact_uint32(sizeof_redpackrolehisinfolist)
	for k = 1,sizeof_redpackrolehisinfolist do
		----------------unmarshal bean
		self.redpackrolehisinfolist[k]=RedPackRoleHisInfo:new()

		self.redpackrolehisinfolist[k]:unmarshal(_os_)

	end
	return _os_
end

return SSendRedPackHisView
