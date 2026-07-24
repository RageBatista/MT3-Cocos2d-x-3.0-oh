
package xbean;

public interface RoleRankNotifyTimeInfo extends mkdb.Bean {
	public RoleRankNotifyTimeInfo copy(); // 深拷贝
	public RoleRankNotifyTimeInfo toData(); // 一个 Data 实例
	public RoleRankNotifyTimeInfo toBean(); // 一个 Bean 实例
	public RoleRankNotifyTimeInfo toDataIf(); // 如果需要则返回一个 Data 实例，否则返回 this
	public RoleRankNotifyTimeInfo toBeanIf(); // 如果需要则返回一个 Bean 实例，否则返回 this

	public java.util.Map<Integer, Long> getLasttime(); // 上次各个排行榜变化通知时间
	public java.util.Map<Integer, Long> getLasttimeAsData(); // 上次各个排行榜变化通知时间

}
