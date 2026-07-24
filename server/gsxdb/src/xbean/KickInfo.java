
package xbean;

public interface KickInfo extends mkdb.Bean {
	public KickInfo copy(); // 深拷贝
	public KickInfo toData(); // 一个 Data 实例
	public KickInfo toBean(); // 一个 Bean 实例
	public KickInfo toDataIf(); // 如果需要则返回一个 Data 实例，否则返回 this
	public KickInfo toBeanIf(); // 如果需要则返回一个 Bean 实例，否则返回 this

	public java.util.List<Long> getKicktime(); // 踢人信息，作者 changhao
	public java.util.List<Long> getKicktimeAsData(); // 踢人信息，作者 changhao
	public long getExpire(); // 10分钟内不让登陆，作者 changhao

	public void setExpire(long _v_); // 10分钟内不让登陆，作者 changhao
}
