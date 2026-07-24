
package xbean;

public interface Mission extends mkdb.Bean {
	public Mission copy(); // 深拷贝
	public Mission toData(); // 一个 Data 实例
	public Mission toBean(); // 一个 Bean 实例
	public Mission toDataIf(); // 如果需要则返回一个 Data 实例，否则返回 this
	public Mission toBeanIf(); // 如果需要则返回一个 Bean 实例，否则返回 this

	public int getId(); // 
	public int getStatus(); // -2放弃 -1未接受 1已提交 2执行失败 3完成 4进行中
	public java.util.List<Integer> getPath(); // 
	public java.util.List<Integer> getPathAsData(); // 
	public int getTaskvalue(); // 
	public long getDeadline(); // 
	public int getRound(); // 剧情任务和主线任务用默认的0就可以了

	public void setId(int _v_); // 
	public void setStatus(int _v_); // -2放弃 -1未接受 1已提交 2执行失败 3完成 4进行中
	public void setTaskvalue(int _v_); // 
	public void setDeadline(long _v_); // 
	public void setRound(int _v_); // 剧情任务和主线任务用默认的0就可以了
}
