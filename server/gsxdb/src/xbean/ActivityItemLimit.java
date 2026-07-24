
package xbean;

public interface ActivityItemLimit extends mkdb.Bean {
	public ActivityItemLimit copy(); // 深拷贝
	public ActivityItemLimit toData(); // 一个 Data 实例
	public ActivityItemLimit toBean(); // 一个 Bean 实例
	public ActivityItemLimit toDataIf(); // 如果需要则返回一个 Data 实例，否则返回 this
	public ActivityItemLimit toBeanIf(); // 如果需要则返回一个 Bean 实例，否则返回 this

	public java.util.Map<Integer, xbean.LimitItemInfo> getLimititemmap(); // key为itemid
	public java.util.Map<Integer, xbean.LimitItemInfo> getLimititemmapAsData(); // key为itemid

}
