require "utils.tableutil"
require "protodef.rpcgen.fire.pb.fushi.chargereturnprofit"
SRequestChargeReturnProfit = {}
SRequestChargeReturnProfit.__index = SRequestChargeReturnProfit



SRequestChargeReturnProfit.PROTOCOL_TYPE = 812480

function SRequestChargeReturnProfit.Create()
	print("enter SRequestChargeReturnProfit create")
	return SRequestChargeReturnProfit:new()
end
function SRequestChargeReturnProfit:new()
	local self = {}
	setmetatable(self, SRequestChargeReturnProfit)
	self.type = self.PROTOCOL_TYPE
	self.listchargereturnprofit = {}

	return self
end
function SRequestChargeReturnProfit:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function SRequestChargeReturnProfit:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()

	----------------marshal vector
	_os_:compact_uint32(TableUtil.tablelength(self.listchargereturnprofit))
	for k,v in ipairs(self.listchargereturnprofit) do
		----------------marshal bean
		v:marshal(_os_) 
	end

	return _os_
end

function SRequestChargeReturnProfit:unmarshal(_os_)
	----------------unmarshal vector
	local sizeof_listchargereturnprofit=0,_os_null_listchargereturnprofit
	_os_null_listchargereturnprofit, sizeof_listchargereturnprofit = _os_: uncompact_uint32(sizeof_listchargereturnprofit)
	for k = 1,sizeof_listchargereturnprofit do
		----------------unmarshal bean
		self.listchargereturnprofit[k]=ChargeReturnProfit:new()

		self.listchargereturnprofit[k]:unmarshal(_os_)

	end
	return _os_
end

return SRequestChargeReturnProfit
