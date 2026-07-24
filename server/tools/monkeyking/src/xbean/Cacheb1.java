
package xbean;

public interface Cacheb1 extends mkdb.Bean {
	public Cacheb1 copy(); // deep clone
	public Cacheb1 toData(); // a Data instance
	public Cacheb1 toBean(); // a Bean instance
	public Cacheb1 toDataIf(); // a Data instance If need. else return this
	public Cacheb1 toBeanIf(); // a Bean instance If need. else return this

	public int getI(); // 
	public long getL(); // 
	public <T extends com.locojoy.base.Marshal.Marshal> T getMarshal(T _v_); // binary
	public boolean isMarshalEmpty(); // binary
	public byte[] getMarshalCopy(); // binary
	public java.util.Set<Integer> getSeti(); // 
	public java.util.Set<Integer> getSetiAsData(); // 
	public xbean.Cacheb2 getCacheb2(); // 

	public void setI(int _v_); // 
	public void setL(long _v_); // 
	public void setMarshal(com.locojoy.base.Marshal.Marshal _v_); // binary
	public void setMarshalCopy(byte[] _v_); // binary
}
