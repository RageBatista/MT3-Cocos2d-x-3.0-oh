
package xbean;

public interface First extends mkdb.Bean {
	public First copy(); // deep clone
	public First toData(); // a Data instance
	public First toBean(); // a Bean instance
	public First toDataIf(); // a Data instance If need. else return this
	public First toBeanIf(); // a Bean instance If need. else return this

	public short getS(); // short test
	public int getI(); // int test
	public long getL(); // long test
	public String getText(); // text
	public com.locojoy.base.Octets getTextOctets(); // text
	public <T extends com.locojoy.base.Marshal.Marshal> T getMarshal(T _v_); // binary
	public boolean isMarshalEmpty(); // binary
	public byte[] getMarshalCopy(); // binary
	public java.util.Set<String> getSets(); // comment
	public java.util.Set<String> getSetsAsData(); // comment
	public java.util.Set<Integer> getSeti(); // comment
	public java.util.Set<Integer> getSetiAsData(); // comment
	public java.util.Set<Long> getSetl(); // comment
	public java.util.Set<Long> getSetlAsData(); // comment

	public void setS(short _v_); // short test
	public void setI(int _v_); // int test
	public void setL(long _v_); // long test
	public void setText(String _v_); // text
	public void setTextOctets(com.locojoy.base.Octets _v_); // text
	public void setMarshal(com.locojoy.base.Marshal.Marshal _v_); // binary
	public void setMarshalCopy(byte[] _v_); // binary
}
