
package xbean;

public interface OfflineMsg extends mkdb.Bean {
	public OfflineMsg copy(); // 深拷贝
	public OfflineMsg toData(); // 一个 Data 实例
	public OfflineMsg toBean(); // 一个 Bean 实例
	public OfflineMsg toDataIf(); // 如果需要则返回一个 Data 实例，否则返回 this
	public OfflineMsg toBeanIf(); // 如果需要则返回一个 Bean 实例，否则返回 this

	public long getRoleid(); // 
	public String getContent(); // 
	public com.locojoy.base.Octets getContentOctets(); // 
	public java.util.List<byte []> getDetails(); // 展示品信息
	public java.util.List<byte []> getDetailsAsData(); // 展示品信息
	public java.util.List<xbean.ShowInfoBean> getShowinfos(); // 展示品信息
	public java.util.List<xbean.ShowInfoBean> getShowinfosAsData(); // 展示品信息
	public String getSendtime(); // 
	public com.locojoy.base.Octets getSendtimeOctets(); // 

	public void setRoleid(long _v_); // 
	public void setContent(String _v_); // 
	public void setContentOctets(com.locojoy.base.Octets _v_); // 
	public void setSendtime(String _v_); // 
	public void setSendtimeOctets(com.locojoy.base.Octets _v_); // 
}
