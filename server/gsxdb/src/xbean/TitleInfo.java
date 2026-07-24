
package xbean;

public interface TitleInfo extends mkdb.Bean {
	public TitleInfo copy(); // 深拷贝
	public TitleInfo toData(); // 一个 Data 实例
	public TitleInfo toBean(); // 一个 Bean 实例
	public TitleInfo toDataIf(); // 如果需要则返回一个 Data 实例，否则返回 this
	public TitleInfo toBeanIf(); // 如果需要则返回一个 Bean 实例，否则返回 this

	public int getTitleid(); // 称谓id
	public String getTitlename(); // 称谓名
	public com.locojoy.base.Octets getTitlenameOctets(); // 称谓名
	public long getAvailtime(); // 剩余有效时间

	public void setTitleid(int _v_); // 称谓id
	public void setTitlename(String _v_); // 称谓名
	public void setTitlenameOctets(com.locojoy.base.Octets _v_); // 称谓名
	public void setAvailtime(long _v_); // 剩余有效时间
}
