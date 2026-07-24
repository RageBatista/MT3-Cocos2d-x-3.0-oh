
package xbean;

public interface ChargeReturnProfit extends mkdb.Bean {
	public ChargeReturnProfit copy(); // 深拷贝
	public ChargeReturnProfit toData(); // 一个 Data 实例
	public ChargeReturnProfit toBean(); // 一个 Bean 实例
	public ChargeReturnProfit toDataIf(); // 如果需要则返回一个 Data 实例，否则返回 this
	public ChargeReturnProfit toBeanIf(); // 如果需要则返回一个 Bean 实例，否则返回 this

	public int getId(); // 
	public int getValue(); // 
	public int getMaxvalue(); // 
	public int getStatus(); // 0是领取了1是未领取2是未到达，作者 changhao

	public void setId(int _v_); // 
	public void setValue(int _v_); // 
	public void setMaxvalue(int _v_); // 
	public void setStatus(int _v_); // 0是领取了1是未领取2是未到达，作者 changhao
}
