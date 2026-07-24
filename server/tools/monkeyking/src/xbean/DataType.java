
package xbean;

public interface DataType extends mkdb.Bean {
	public DataType copy(); // deep clone
	public DataType toData(); // a Data instance
	public DataType toBean(); // a Bean instance
	public DataType toDataIf(); // a Data instance If need. else return this
	public DataType toBeanIf(); // a Bean instance If need. else return this

	public int getId(); // int value
	public long getMax(); // long value
	public short getMshort(); // short value
	public float getMfloat(); // float value
	public String getName(); // string value
	public com.locojoy.base.Octets getNameOctets(); // string value
	public <T extends com.locojoy.base.Marshal.Marshal> T getMobject(T _v_); // object, binary
	public boolean isMobjectEmpty(); // object, binary
	public byte[] getMobjectCopy(); // object, binary
	public xbean.SubBean getSub(); // SubBean value
	public java.util.Set<xbean.SubBean> getSet(); // SubBean set
	public java.util.Set<xbean.SubBean> getSetAsData(); // SubBean set
	public java.util.List<xbean.SubBean> getList(); // SubBean list
	public java.util.List<xbean.SubBean> getListAsData(); // SubBean list
	public java.util.Map<String, xbean.SubBean> getMap(); // string-SubBean map
	public java.util.Map<String, xbean.SubBean> getMapAsData(); // string-SubBean map

	public void setId(int _v_); // int value
	public void setMax(long _v_); // long value
	public void setMshort(short _v_); // short value
	public void setMfloat(float _v_); // float value
	public void setName(String _v_); // string value
	public void setNameOctets(com.locojoy.base.Octets _v_); // string value
	public void setMobject(com.locojoy.base.Marshal.Marshal _v_); // object, binary
	public void setMobjectCopy(byte[] _v_); // object, binary
}
