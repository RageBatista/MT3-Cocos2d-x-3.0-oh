
package xbean;

public interface ChargeRecord extends mkdb.Bean {
	public ChargeRecord copy(); // 深拷贝
	public ChargeRecord toData(); // 一个 Data 实例
	public ChargeRecord toBean(); // 一个 Bean 实例
	public ChargeRecord toDataIf(); // 如果需要则返回一个 Data 实例，否则返回 this
	public ChargeRecord toBeanIf(); // 如果需要则返回一个 Bean 实例，否则返回 this

	public int getChargecount(); // 已经充值次数
	public long getChargetime(); // 上次的时间

	public void setChargecount(int _v_); // 已经充值次数
	public void setChargetime(long _v_); // 上次的时间
}
