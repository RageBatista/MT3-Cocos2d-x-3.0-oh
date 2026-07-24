
package xbean;

public interface Cacheb0 extends mkdb.Bean {
	public Cacheb0 copy(); // deep clone
	public Cacheb0 toData(); // a Data instance
	public Cacheb0 toBean(); // a Bean instance
	public Cacheb0 toDataIf(); // a Data instance If need. else return this
	public Cacheb0 toBeanIf(); // a Bean instance If need. else return this

	public int getI(); // 
	public long getL(); // 
	public <T extends com.locojoy.base.Marshal.Marshal> T getMarshal(T _v_); // binary
	public boolean isMarshalEmpty(); // binary
	public byte[] getMarshalCopy(); // binary
	public java.util.Set<Integer> getSeti(); // 
	public java.util.Set<Integer> getSetiAsData(); // 
	public xbean.Cacheb1 getCacheb1(); // 

	public void setI(int _v_); // 
	public void setL(long _v_); // 
	public void setMarshal(com.locojoy.base.Marshal.Marshal _v_); // binary
	public void setMarshalCopy(byte[] _v_); // binary
}
