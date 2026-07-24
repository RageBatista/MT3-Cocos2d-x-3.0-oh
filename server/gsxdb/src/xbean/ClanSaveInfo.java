
package xbean;

public interface ClanSaveInfo extends mkdb.Bean {
	public ClanSaveInfo copy(); // 深拷贝
	public ClanSaveInfo toData(); // 一个 Data 实例
	public ClanSaveInfo toBean(); // 一个 Bean 实例
	public ClanSaveInfo toDataIf(); // 如果需要则返回一个 Data 实例，否则返回 this
	public ClanSaveInfo toBeanIf(); // 如果需要则返回一个 Bean 实例，否则返回 this

	public java.util.Map<Integer, Long> getSavestate(); // key为进度id; value为进度使用的时间
	public java.util.Map<Integer, Long> getSavestateAsData(); // key为进度id; value为进度使用的时间
	public long getRefreshtime(); // 刷新时间

	public void setRefreshtime(long _v_); // 刷新时间
}
