
package xbean;

public interface PlayActiveData extends mkdb.Bean {
	public PlayActiveData copy(); // 深拷贝
	public PlayActiveData toData(); // 一个 Data 实例
	public PlayActiveData toBean(); // 一个 Bean 实例
	public PlayActiveData toDataIf(); // 如果需要则返回一个 Data 实例，否则返回 this
	public PlayActiveData toBeanIf(); // 如果需要则返回一个 Bean 实例，否则返回 this

	public int getId(); // 
	public int getCount(); // 完成次数
	public int getCount2(); // 完成次数2
	public float getActiveness(); // 完成共获得的活跃度

	public void setId(int _v_); // 
	public void setCount(int _v_); // 完成次数
	public void setCount2(int _v_); // 完成次数2
	public void setActiveness(float _v_); // 完成共获得的活跃度
}
