
package xbean;

public interface NumberAndTime extends mkdb.Bean {
	public NumberAndTime copy(); // 深拷贝
	public NumberAndTime toData(); // 一个 Data 实例
	public NumberAndTime toBean(); // 一个 Bean 实例
	public NumberAndTime toDataIf(); // 如果需要则返回一个 Data 实例，否则返回 this
	public NumberAndTime toBeanIf(); // 如果需要则返回一个 Bean 实例，否则返回 this

	public int getNumber(); // 购买或售卖次数
	public long getTime(); // 最后购买或售卖时间

	public void setNumber(int _v_); // 购买或售卖次数
	public void setTime(long _v_); // 最后购买或售卖时间
}
