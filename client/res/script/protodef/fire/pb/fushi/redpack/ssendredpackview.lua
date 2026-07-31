require "utils.tableutil"
require "protodef.rpcgen.fire.pb.fushi.redpack.redpackinfo"
require "protodef.rpcgen.fire.pb.fushi.redpack.srredpacknum"
SSendRedPackView = {}
SSendRedPackView.__index = SSendRedPackView



SSendRedPackView.PROTOCOL_TYPE = 812533

function SSendRedPackView.Create()
	print("enter SSendRedPackView create")
	return SSendRedPackView:new()
end
function SSendRedPackView:new()
	local self = {}
	setmetatable(self, SSendRedPackView)
	self.type = self.PROTOCOL_TYPE
	self.modeltype = 0
	self.firstpageflag = 0
	self.redpackinfolist = {}
	self.daysrnum = SRRedPackNum:new()

	return self
end
function SSendRedPackView:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function SSendRedPackView:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_int32(self.modeltype)
	_os_:marshal_int32(self.firstpageflag)

	----------------marshal vector
	_os_:compact_uint32(TableUtil.tablelength(self.redpackinfolist))
	for k,v in ipairs(self.redpackinfolist) do
		----------------marshal bean
		v:marshal(_os_) 
	end

	----------------marshal bean
	self.daysrnum:marshal(_os_) 
	return _os_
end

function SSendRedPackView:unmarshal(_os_)
	self.modeltype = _os_:unmarshal_int32()
	self.firstpageflag = _os_:unmarshal_int32()
	----------------unmarshal vector
	local sizeof_redpackinfolist=0,_os_null_redpackinfolist
	_os_null_redpackinfolist, sizeof_redpackinfolist = _os_: uncompact_uint32(sizeof_redpackinfolist)
	for k = 1,sizeof_redpackinfolist do
		----------------unmarshal bean
		self.redpackinfolist[k]=RedPackInfo:new()

		self.redpackinfolist[k]:unmarshal(_os_)

	end
	----------------unmarshal bean

	self.daysrnum:unmarshal(_os_)

	return _os_
end

return SSendRedPackView
