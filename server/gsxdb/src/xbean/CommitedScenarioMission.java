
package xbean;

public interface CommitedScenarioMission extends mkdb.Bean {
	public CommitedScenarioMission copy(); // 深拷贝
	public CommitedScenarioMission toData(); // 一个 Data 实例
	public CommitedScenarioMission toBean(); // 一个 Bean 实例
	public CommitedScenarioMission toDataIf(); // 如果需要则返回一个 Data 实例，否则返回 this
	public CommitedScenarioMission toBeanIf(); // 如果需要则返回一个 Bean 实例，否则返回 this

	public java.util.List<Integer> getCommitted(); // 
	public java.util.List<Integer> getCommittedAsData(); // 

}
