
package xbean;

public interface BingFengInfo extends mkdb.Bean {
	public BingFengInfo copy(); // 深拷贝
	public BingFengInfo toData(); // 一个 Data 实例
	public BingFengInfo toBean(); // 一个 Bean 实例
	public BingFengInfo toDataIf(); // 如果需要则返回一个 Data 实例，否则返回 this
	public BingFengInfo toBeanIf(); // 如果需要则返回一个 Bean 实例，否则返回 this

	public int getInstzoneid(); // 
	public java.util.Map<Integer, Integer> getStagetime(); // 记录每个关卡最快通关的时间
	public java.util.Map<Integer, Integer> getStagetimeAsData(); // 记录每个关卡最快通关的时间
	public java.util.Map<Integer, Integer> getStageround(); // 记录每个关卡最快通关的回合数
	public java.util.Map<Integer, Integer> getStageroundAsData(); // 记录每个关卡最快通关的回合数
	public java.util.Map<Integer, Long> getStagebest(); // 记录每个关卡最快通关的角色的id
	public java.util.Map<Integer, Long> getStagebestAsData(); // 记录每个关卡最快通关的角色的id
	public java.util.Map<Integer, xbean.SchoolStageTime> getSchoolstage(); // key 职业id
	public java.util.Map<Integer, xbean.SchoolStageTime> getSchoolstageAsData(); // key 职业id

	public void setInstzoneid(int _v_); // 
}
