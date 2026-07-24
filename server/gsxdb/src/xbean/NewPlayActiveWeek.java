
package xbean;

public interface NewPlayActiveWeek extends mkdb.Bean {
	public NewPlayActiveWeek copy(); // 深拷贝
	public NewPlayActiveWeek toData(); // 一个 Data 实例
	public NewPlayActiveWeek toBean(); // 一个 Bean 实例
	public NewPlayActiveWeek toDataIf(); // 如果需要则返回一个 Data 实例，否则返回 this
	public NewPlayActiveWeek toBeanIf(); // 如果需要则返回一个 Bean 实例，否则返回 this

	public long getTime(); // 活动记录时间
	public java.util.Map<Integer, xbean.PlayActiveData> getActives(); // key为活动id,一周的计次数据
	public java.util.Map<Integer, xbean.PlayActiveData> getActivesAsData(); // key为活动id,一周的计次数据

	public void setTime(long _v_); // 活动记录时间
}
