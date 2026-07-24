
package xbean;

public interface AccusationInfo extends mkdb.Bean {
	public AccusationInfo copy(); // 深拷贝
	public AccusationInfo toData(); // 一个 Data 实例
	public AccusationInfo toBean(); // 一个 Bean 实例
	public AccusationInfo toDataIf(); // 如果需要则返回一个 Data 实例，否则返回 this
	public AccusationInfo toBeanIf(); // 如果需要则返回一个 Bean 实例，否则返回 this

	public long getRoleid(); // 被举报人ID
	public java.util.List<Long> getAccusationedroleids(); // 举报人IDs
	public java.util.List<Long> getAccusationedroleidsAsData(); // 举报人IDs
	public long getLasttime(); // 最后一次被举报时间

	public void setRoleid(long _v_); // 被举报人ID
	public void setLasttime(long _v_); // 最后一次被举报时间
}
