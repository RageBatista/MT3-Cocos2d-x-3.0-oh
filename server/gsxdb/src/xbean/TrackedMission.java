
package xbean;

public interface TrackedMission extends mkdb.Bean {
	public TrackedMission copy(); // 深拷贝
	public TrackedMission toData(); // 一个 Data 实例
	public TrackedMission toBean(); // 一个 Bean 实例
	public TrackedMission toDataIf(); // 如果需要则返回一个 Data 实例，否则返回 this
	public TrackedMission toBeanIf(); // 如果需要则返回一个 Bean 实例，否则返回 this

	public java.util.Map<Integer, xbean.Track> getQuestids(); // 
	public java.util.Map<Integer, xbean.Track> getQuestidsAsData(); // 

}
