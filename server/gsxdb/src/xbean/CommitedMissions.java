
package xbean;

public interface CommitedMissions extends mkdb.Bean {
	public CommitedMissions copy(); // 深拷贝
	public CommitedMissions toData(); // 一个 Data 实例
	public CommitedMissions toBean(); // 一个 Bean 实例
	public CommitedMissions toDataIf(); // 如果需要则返回一个 Data 实例，否则返回 this
	public CommitedMissions toBeanIf(); // 如果需要则返回一个 Bean 实例，否则返回 this

	public java.util.List<Integer> getCommitted(); // 
	public java.util.List<Integer> getCommittedAsData(); // 

}
