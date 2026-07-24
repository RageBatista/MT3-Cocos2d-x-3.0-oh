
package xbean;

public interface PvP1Race extends mkdb.Bean {
	public PvP1Race copy(); // 深拷贝
	public PvP1Race toData(); // 一个 Data 实例
	public PvP1Race toBean(); // 一个 Bean 实例
	public PvP1Race toDataIf(); // 如果需要则返回一个 Data 实例，否则返回 this
	public PvP1Race toBeanIf(); // 如果需要则返回一个 Bean 实例，否则返回 this

	public java.util.List<xbean.PvP1RaceRole> getAllroles(); // 赛场中的角色的积分排行
	public java.util.List<xbean.PvP1RaceRole> getAllrolesAsData(); // 赛场中的角色的积分排行
	public java.util.List<Long> getAllrolesid(); // 赛场中的角色ID
	public java.util.List<Long> getAllrolesidAsData(); // 赛场中的角色ID
	public java.util.List<xbean.PvP1QueueRole> getWaitingqueue(); // 等待序列
	public java.util.List<xbean.PvP1QueueRole> getWaitingqueueAsData(); // 等待序列

}
