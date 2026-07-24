
package xbean;

public interface PvP5Race extends mkdb.Bean {
	public PvP5Race copy(); // 深拷贝
	public PvP5Race toData(); // 一个 Data 实例
	public PvP5Race toBean(); // 一个 Bean 实例
	public PvP5Race toDataIf(); // 如果需要则返回一个 Data 实例，否则返回 this
	public PvP5Race toBeanIf(); // 如果需要则返回一个 Bean 实例，否则返回 this

	public java.util.List<xbean.PvP5RaceRole> getAllrolescampa(); // 赛场中A阵营的角色的积分排行
	public java.util.List<xbean.PvP5RaceRole> getAllrolescampaAsData(); // 赛场中A阵营的角色的积分排行
	public java.util.List<xbean.PvP5RaceRole> getAllrolescampb(); // 赛场中B阵营的角色的积分排行
	public java.util.List<xbean.PvP5RaceRole> getAllrolescampbAsData(); // 赛场中B阵营的角色的积分排行
	public java.util.List<Long> getAllrolesidcampa(); // 赛场中A阵营的角色ID
	public java.util.List<Long> getAllrolesidcampaAsData(); // 赛场中A阵营的角色ID
	public java.util.List<Long> getAllrolesidcampb(); // 赛场中B阵营的角色ID
	public java.util.List<Long> getAllrolesidcampbAsData(); // 赛场中B阵营的角色ID
	public java.util.List<xbean.PvP5QueueRole> getWaitingqueue(); // 等待序列
	public java.util.List<xbean.PvP5QueueRole> getWaitingqueueAsData(); // 等待序列
	public int getIsend(); // 是否已经决出胜负

	public void setIsend(int _v_); // 是否已经决出胜负
}
