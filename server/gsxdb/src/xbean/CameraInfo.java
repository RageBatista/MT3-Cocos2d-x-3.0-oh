
package xbean;

public interface CameraInfo extends mkdb.Bean {
	public CameraInfo copy(); // 深拷贝
	public CameraInfo toData(); // 一个 Data 实例
	public CameraInfo toBean(); // 一个 Bean 实例
	public CameraInfo toDataIf(); // 如果需要则返回一个 Data 实例，否则返回 this
	public CameraInfo toBeanIf(); // 如果需要则返回一个 Bean 实例，否则返回 this

	public long getEndtime(); // 
	public int getSizebeforezip(); // 
	public int getSizeafterzip(); // 
	public String getCamerafileurl(); // 
	public com.locojoy.base.Octets getCamerafileurlOctets(); // 

	public void setEndtime(long _v_); // 
	public void setSizebeforezip(int _v_); // 
	public void setSizeafterzip(int _v_); // 
	public void setCamerafileurl(String _v_); // 
	public void setCamerafileurlOctets(com.locojoy.base.Octets _v_); // 
}
