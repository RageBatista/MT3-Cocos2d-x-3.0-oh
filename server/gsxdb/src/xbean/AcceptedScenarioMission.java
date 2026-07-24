
package xbean;

public interface AcceptedScenarioMission extends mkdb.Bean {
	public AcceptedScenarioMission copy(); // 深拷贝
	public AcceptedScenarioMission toData(); // 一个 Data 实例
	public AcceptedScenarioMission toBean(); // 一个 Bean 实例
	public AcceptedScenarioMission toDataIf(); // 如果需要则返回一个 Data 实例，否则返回 this
	public AcceptedScenarioMission toBeanIf(); // 如果需要则返回一个 Bean 实例，否则返回 this

	public java.util.Map<Integer, xbean.Mission> getAccepted(); // 支线任务
	public java.util.Map<Integer, xbean.Mission> getAcceptedAsData(); // 支线任务

}
