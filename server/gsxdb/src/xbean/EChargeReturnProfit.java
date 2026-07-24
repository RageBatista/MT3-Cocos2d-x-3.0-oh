
package xbean;

public interface EChargeReturnProfit extends mkdb.Bean {
	public EChargeReturnProfit copy(); // 深拷贝
	public EChargeReturnProfit toData(); // 一个 Data 实例
	public EChargeReturnProfit toBean(); // 一个 Bean 实例
	public EChargeReturnProfit toDataIf(); // 如果需要则返回一个 Data 实例，否则返回 this
	public EChargeReturnProfit toBeanIf(); // 如果需要则返回一个 Bean 实例，否则返回 this

	public java.util.Map<Integer, xbean.ChargeReturnProfit> getReturnprofitmap(); // 
	public java.util.Map<Integer, xbean.ChargeReturnProfit> getReturnprofitmapAsData(); // 

}
