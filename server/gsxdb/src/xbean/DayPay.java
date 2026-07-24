
package xbean;

public interface DayPay extends mkdb.Bean {
	public DayPay copy(); // 深拷贝
	public DayPay toData(); // 一个 Data 实例
	public DayPay toBean(); // 一个 Bean 实例
	public DayPay toDataIf(); // 如果需要则返回一个 Data 实例，否则返回 this
	public DayPay toBeanIf(); // 如果需要则返回一个 Bean 实例，否则返回 this

	public int getUserid(); // 
	public long getRoleid(); // 
	public long getExpiretime(); // 结束时间，作者 changhao
	public int getFirstprompt(); // 还没提示过就是0，作者 changhao

	public void setUserid(int _v_); // 
	public void setRoleid(long _v_); // 
	public void setExpiretime(long _v_); // 结束时间，作者 changhao
	public void setFirstprompt(int _v_); // 还没提示过就是0，作者 changhao
}
