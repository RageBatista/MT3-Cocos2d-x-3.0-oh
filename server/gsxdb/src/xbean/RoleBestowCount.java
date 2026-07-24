
package xbean;

public interface RoleBestowCount extends mkdb.Bean {
	public RoleBestowCount copy(); // 深拷贝
	public RoleBestowCount toData(); // 一个 Data 实例
	public RoleBestowCount toBean(); // 一个 Bean 实例
	public RoleBestowCount toDataIf(); // 如果需要则返回一个 Data 实例，否则返回 this
	public RoleBestowCount toBeanIf(); // 如果需要则返回一个 Bean 实例，否则返回 this

	public int getOpentimes(); // 拾取次数
	public long getLastopentime(); // 上次拾取时间

	public void setOpentimes(int _v_); // 拾取次数
	public void setLastopentime(long _v_); // 上次拾取时间
}
