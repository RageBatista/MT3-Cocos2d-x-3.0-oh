
package xbean;

public interface TaskEventInfo extends mkdb.Bean {
	public TaskEventInfo copy(); // 深拷贝
	public TaskEventInfo toData(); // 一个 Data 实例
	public TaskEventInfo toBean(); // 一个 Bean 实例
	public TaskEventInfo toDataIf(); // 如果需要则返回一个 Data 实例，否则返回 this
	public TaskEventInfo toBeanIf(); // 如果需要则返回一个 Bean 实例，否则返回 this

	public java.util.Map<Integer, Long> getEventindexs(); // key为taskid,value为eventidx
	public java.util.Map<Integer, Long> getEventindexsAsData(); // key为taskid,value为eventidx

}
