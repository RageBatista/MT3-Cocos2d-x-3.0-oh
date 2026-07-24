
package xbean;

public interface TotalInfo extends mkdb.Bean {
	public TotalInfo copy(); // 深拷贝
	public TotalInfo toData(); // 一个 Data 实例
	public TotalInfo toBean(); // 一个 Bean 实例
	public TotalInfo toDataIf(); // 如果需要则返回一个 Data 实例，否则返回 this
	public TotalInfo toBeanIf(); // 如果需要则返回一个 Bean 实例，否则返回 this

	public long getTotal(); // 累计充值
	public java.util.Map<Integer, Long> getTotalrewardmap(); // 
	public java.util.Map<Integer, Long> getTotalrewardmapAsData(); // 

	public void setTotal(long _v_); // 累计充值
}
