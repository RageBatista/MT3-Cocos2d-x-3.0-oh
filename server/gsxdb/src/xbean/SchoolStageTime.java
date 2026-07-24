
package xbean;

public interface SchoolStageTime extends mkdb.Bean {
	public SchoolStageTime copy(); // 深拷贝
	public SchoolStageTime toData(); // 一个 Data 实例
	public SchoolStageTime toBean(); // 一个 Bean 实例
	public SchoolStageTime toDataIf(); // 如果需要则返回一个 Data 实例，否则返回 this
	public SchoolStageTime toBeanIf(); // 如果需要则返回一个 Bean 实例，否则返回 this

	public java.util.Map<Integer, Integer> getStagetime(); // 按职业区分的每关时间
	public java.util.Map<Integer, Integer> getStagetimeAsData(); // 按职业区分的每关时间
	public java.util.Map<Integer, Integer> getStageround(); // 记录每个关卡最快通关的回合数
	public java.util.Map<Integer, Integer> getStageroundAsData(); // 记录每个关卡最快通关的回合数
	public java.util.Map<Integer, Long> getStagebest(); // 记录每个关卡最快通关的角色的id
	public java.util.Map<Integer, Long> getStagebestAsData(); // 记录每个关卡最快通关的角色的id

}
