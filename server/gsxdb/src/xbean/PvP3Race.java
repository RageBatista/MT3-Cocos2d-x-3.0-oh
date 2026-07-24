
package xbean;

public interface PvP3Race extends mkdb.Bean {
	public PvP3Race copy(); // 深拷贝
	public PvP3Race toData(); // 一个 Data 实例
	public PvP3Race toBean(); // 一个 Bean 实例
	public PvP3Race toDataIf(); // 如果需要则返回一个 Data 实例，否则返回 this
	public PvP3Race toBeanIf(); // 如果需要则返回一个 Bean 实例，否则返回 this

	public java.util.List<xbean.PvP3RaceRole> getAllroles(); // 赛场中的角色的积分排行
	public java.util.List<xbean.PvP3RaceRole> getAllrolesAsData(); // 赛场中的角色的积分排行
	public java.util.List<Long> getAllrolesid(); // 赛场中的角色ID
	public java.util.List<Long> getAllrolesidAsData(); // 赛场中的角色ID
	public java.util.List<xbean.PvP3QueueRole> getWaitingqueue(); // 等待序列
	public java.util.List<xbean.PvP3QueueRole> getWaitingqueueAsData(); // 等待序列

}
