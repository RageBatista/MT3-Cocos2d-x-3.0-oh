
package xbean;

public interface TransfromInfo extends mkdb.Bean {
	public TransfromInfo copy(); // 深拷贝
	public TransfromInfo toData(); // 一个 Data 实例
	public TransfromInfo toBean(); // 一个 Bean 实例
	public TransfromInfo toDataIf(); // 如果需要则返回一个 Data 实例，否则返回 this
	public TransfromInfo toBeanIf(); // 如果需要则返回一个 Bean 实例，否则返回 this

	public int getTransformid(); // 人物变身时的shape
	public int getQuestid(); // 
	public long getValiddate(); // 人物变身时的时限
	public int getRide(); // 人物变身时的坐骑

	public void setTransformid(int _v_); // 人物变身时的shape
	public void setQuestid(int _v_); // 
	public void setValiddate(long _v_); // 人物变身时的时限
	public void setRide(int _v_); // 人物变身时的坐骑
}
