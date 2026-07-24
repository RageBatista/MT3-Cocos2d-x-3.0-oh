
package xbean;

import com.locojoy.base.Marshal.Marshal;
import com.locojoy.base.Marshal.MarshalException;
import com.locojoy.base.Marshal.OctetsStream;

public class xcompare implements Marshal, Comparable<xcompare> {

	private boolean b; // boolean test
	private short s; // short test
	private int i; // int test
	private long l; // long test
	private String text; // text

	public xcompare() {
		b = true;
		s = 1;
		i = 1;
		l = 1;
		text = "123";
	}

	public xcompare(boolean b, short s, int i, long l, String text) {
		this.b = b;
		this.s = s;
		this.i = i;
		this.l = l;
		this.text = text;
	}

	public boolean getB() { // boolean test
		return b;
	}

	public short getS() { // short test
		return s;
	}

	public int getI() { // int test
		return i;
	}

	public long getL() { // long test
		return l;
	}

	public String getText() { // text
		return text;
	}

	public com.locojoy.base.Octets getTextOctets() { // text
		return com.locojoy.base.Octets.wrap(getText(), mkdb.Const.IO_CHARSET);
	}

	@Override
	public final OctetsStream marshal(OctetsStream _os_) {
		_os_.marshal(b);
		_os_.marshal(s);
		_os_.marshal(i);
		_os_.marshal(l);
		_os_.marshal(text, mkdb.Const.IO_CHARSET);
		return _os_;
	}

	@Override
	public final OctetsStream unmarshal(OctetsStream _os_) throws MarshalException {
		b = _os_.unmarshal_boolean();
		s = _os_.unmarshal_short();
		i = _os_.unmarshal_int();
		l = _os_.unmarshal_long();
		text = _os_.unmarshal_String(mkdb.Const.IO_CHARSET);
		return _os_;
	}

	@Override
	public int compareTo(xcompare _o_) {
		if (_o_ == this)
			return 0;
		int _c_ = 0;
		_c_ = Boolean.valueOf(b).compareTo(_o_.b);
		if (0 != _c_) return _c_;
		_c_ = Short.valueOf(s).compareTo(_o_.s);
		if (0 != _c_) return _c_;
		_c_ = Integer.signum(i - _o_.i);
		if (0 != _c_) return _c_;
		_c_ = Long.signum(l - _o_.l);
		if (0 != _c_) return _c_;
		_c_ = text.compareTo(_o_.text);
		if (0 != _c_) return _c_;
		return _c_;
	}

	@Override
	public boolean equals(Object _o_) {
		if (_o_ instanceof xcompare)
			return 0 == this.compareTo((xcompare)_o_);
		return false;
	}

	@Override
	public int hashCode() {
		int _h_ = 0;
		_h_ += b ? 1231 : 1237;
		_h_ += s;
		_h_ += i;
		_h_ += l;
		_h_ += text.hashCode();
		return _h_;
	}

}
