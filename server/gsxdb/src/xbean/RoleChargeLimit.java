
package xbean;

public interface RoleChargeLimit extends mkdb.Bean {
	public RoleChargeLimit copy(); // 深拷贝
	public RoleChargeLimit toData(); // 一个 Data 实例
	public RoleChargeLimit toBean(); // 一个 Bean 实例
	public RoleChargeLimit toDataIf(); // 如果需要则返回一个 Data 实例，否则返回 this
	public RoleChargeLimit toBeanIf(); // 如果需要则返回一个 Bean 实例，否则返回 this

	public java.util.Map<Integer, xbean.ChargeRecord> getChargeslimit(); // key为商品id,value为充值次数记录
	public java.util.Map<Integer, xbean.ChargeRecord> getChargeslimitAsData(); // key为商品id,value为充值次数记录

}
