
package xbean;

public interface AUUserInfo extends mkdb.Bean {
	public AUUserInfo copy(); // 深拷贝
	public AUUserInfo toData(); // 一个 Data 实例
	public AUUserInfo toBean(); // 一个 Bean 实例
	public AUUserInfo toDataIf(); // 如果需要则返回一个 Data 实例，否则返回 this
	public AUUserInfo toBeanIf(); // 如果需要则返回一个 Bean 实例，否则返回 this

	public int getRetcode(); // 
	public int getFunc(); // 
	public int getFuncparm(); // 
	public int getLoginip(); // 
	public int getBlisgm(); // 
	public java.util.List<Integer> getAuth(); // 
	public java.util.List<Integer> getAuthAsData(); // 
	public int getAlgorithm(); // 
	public String getNickname(); // 
	public com.locojoy.base.Octets getNicknameOctets(); // 
	public String getUsername(); // 
	public com.locojoy.base.Octets getUsernameOctets(); // 
	public String getMac(); // 
	public com.locojoy.base.Octets getMacOctets(); // 
	public String getOs(); // 
	public com.locojoy.base.Octets getOsOctets(); // 
	public String getPlatform(); // 
	public com.locojoy.base.Octets getPlatformOctets(); // 
	public String getPlatname(); // 平台名称 yingyongbao,360 等
	public com.locojoy.base.Octets getPlatnameOctets(); // 平台名称 yingyongbao,360 等
	public String getClientsource(); // 
	public com.locojoy.base.Octets getClientsourceOctets(); // 
	public String getIdfa(); // 
	public com.locojoy.base.Octets getIdfaOctets(); // 

	public void setRetcode(int _v_); // 
	public void setFunc(int _v_); // 
	public void setFuncparm(int _v_); // 
	public void setLoginip(int _v_); // 
	public void setBlisgm(int _v_); // 
	public void setAlgorithm(int _v_); // 
	public void setNickname(String _v_); // 
	public void setNicknameOctets(com.locojoy.base.Octets _v_); // 
	public void setUsername(String _v_); // 
	public void setUsernameOctets(com.locojoy.base.Octets _v_); // 
	public void setMac(String _v_); // 
	public void setMacOctets(com.locojoy.base.Octets _v_); // 
	public void setOs(String _v_); // 
	public void setOsOctets(com.locojoy.base.Octets _v_); // 
	public void setPlatform(String _v_); // 
	public void setPlatformOctets(com.locojoy.base.Octets _v_); // 
	public void setPlatname(String _v_); // 平台名称 yingyongbao,360 等
	public void setPlatnameOctets(com.locojoy.base.Octets _v_); // 平台名称 yingyongbao,360 等
	public void setClientsource(String _v_); // 
	public void setClientsourceOctets(com.locojoy.base.Octets _v_); // 
	public void setIdfa(String _v_); // 
	public void setIdfaOctets(com.locojoy.base.Octets _v_); // 
}
