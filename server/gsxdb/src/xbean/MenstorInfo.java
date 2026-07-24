
package xbean;

public interface MenstorInfo extends mkdb.Bean {
	public MenstorInfo copy(); // 深拷贝
	public MenstorInfo toData(); // 一个 Data 实例
	public MenstorInfo toBean(); // 一个 Bean 实例
	public MenstorInfo toDataIf(); // 如果需要则返回一个 Data 实例，否则返回 this
	public MenstorInfo toBeanIf(); // 如果需要则返回一个 Bean 实例，否则返回 this

	public java.util.List<xbean.CurrApprent> getCurrapprentices(); // 当前的所有的徒弟注意要有顺序性
	public java.util.List<xbean.CurrApprent> getCurrapprenticesAsData(); // 当前的所有的徒弟注意要有顺序性
	public java.util.List<xbean.HasApprent> getApprentices(); // 当前已经出徒的徒弟
	public java.util.List<xbean.HasApprent> getApprenticesAsData(); // 当前已经出徒的徒弟
	public long getUpdatetime(); // 每日上线的时候 只更新一次

	public void setUpdatetime(long _v_); // 每日上线的时候 只更新一次
}
