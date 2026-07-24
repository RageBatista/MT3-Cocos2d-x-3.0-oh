
package xbean;

public interface WeiBoNotify extends mkdb.Bean {
	public WeiBoNotify copy(); // 深拷贝
	public WeiBoNotify toData(); // 一个 Data 实例
	public WeiBoNotify toBean(); // 一个 Bean 实例
	public WeiBoNotify toDataIf(); // 如果需要则返回一个 Data 实例，否则返回 this
	public WeiBoNotify toBeanIf(); // 如果需要则返回一个 Bean 实例，否则返回 this

	public java.util.Map<Integer, xbean.WeiBoChoice> getWeibo(); // key=类型 value=微博相关数据
	public java.util.Map<Integer, xbean.WeiBoChoice> getWeiboAsData(); // key=类型 value=微博相关数据
	public int getTakeawardflag(); // 1=可以领奖  2=领取过了

	public void setTakeawardflag(int _v_); // 1=可以领奖  2=领取过了
}
