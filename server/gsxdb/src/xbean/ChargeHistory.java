
package xbean;

public interface ChargeHistory extends mkdb.Bean {
	public ChargeHistory copy(); // 深拷贝
	public ChargeHistory toData(); // 一个 Data 实例
	public ChargeHistory toBean(); // 一个 Bean 实例
	public ChargeHistory toDataIf(); // 如果需要则返回一个 Data 实例，否则返回 this
	public ChargeHistory toBeanIf(); // 如果需要则返回一个 Bean 实例，否则返回 this

	public java.util.Map<Long, xbean.ChargeOrder> getCharges(); // 
	public java.util.Map<Long, xbean.ChargeOrder> getChargesAsData(); // 

}
