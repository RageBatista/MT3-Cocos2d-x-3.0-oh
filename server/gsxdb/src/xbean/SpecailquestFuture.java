
package xbean;

public interface SpecailquestFuture extends mkdb.Bean {
	public SpecailquestFuture copy(); // 深拷贝
	public SpecailquestFuture toData(); // 一个 Data 实例
	public SpecailquestFuture toBean(); // 一个 Bean 实例
	public SpecailquestFuture toDataIf(); // 如果需要则返回一个 Data 实例，否则返回 this
	public SpecailquestFuture toBeanIf(); // 如果需要则返回一个 Bean 实例，否则返回 this

	public java.util.Map<Integer, java.util.concurrent.ScheduledFuture<?>> getQuestfuture(); // 

}
