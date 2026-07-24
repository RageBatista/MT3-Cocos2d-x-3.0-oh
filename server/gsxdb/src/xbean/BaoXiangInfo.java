
package xbean;

public interface BaoXiangInfo extends mkdb.Bean {
	public BaoXiangInfo copy(); // 深拷贝
	public BaoXiangInfo toData(); // 一个 Data 实例
	public BaoXiangInfo toBean(); // 一个 Bean 实例
	public BaoXiangInfo toDataIf(); // 如果需要则返回一个 Data 实例，否则返回 this
	public BaoXiangInfo toBeanIf(); // 如果需要则返回一个 Bean 实例，否则返回 this

	public int getOpentimes(); // 拾取次数
	public long getLastopentime(); // 上次拾取时间

	public void setOpentimes(int _v_); // 拾取次数
	public void setLastopentime(long _v_); // 上次拾取时间
}
