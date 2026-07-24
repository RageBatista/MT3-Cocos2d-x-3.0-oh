
package xbean;

public interface WeiBoChoice extends mkdb.Bean {
	public WeiBoChoice copy(); // 深拷贝
	public WeiBoChoice toData(); // 一个 Data 实例
	public WeiBoChoice toBean(); // 一个 Bean 实例
	public WeiBoChoice toDataIf(); // 如果需要则返回一个 Data 实例，否则返回 this
	public WeiBoChoice toBeanIf(); // 如果需要则返回一个 Bean 实例，否则返回 this

	public int getTimes(); // 次数
	public int getSetting(); // 设定

	public void setTimes(int _v_); // 次数
	public void setSetting(int _v_); // 设定
}
