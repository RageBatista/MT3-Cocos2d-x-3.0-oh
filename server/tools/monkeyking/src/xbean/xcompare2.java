
package xbean;

import com.locojoy.base.Marshal.Marshal;
import com.locojoy.base.Marshal.MarshalException;
import com.locojoy.base.Marshal.OctetsStream;

public class xcompare2 implements Marshal, Comparable<xcompare2> {

	private xbean.xcompare xc1; // text

	public final static int eX = 1; // 

	public xcompare2() {
		xc1 = new xbean.xcompare();
	}

	public xcompare2(xbean.xcompare xc1) {
		this.xc1 = xc1;
	}

	public xbean.xcompare getXc1() { // text
		return xc1;
	}

	@Override
	public final OctetsStream marshal(OctetsStream _os_) {
		xc1.marshal(_os_);
		return _os_;
	}

	@Override
	public final OctetsStream unmarshal(OctetsStream _os_) throws MarshalException {
		xc1.unmarshal(_os_);
		return _os_;
	}

	@Override
	public int compareTo(xcompare2 _o_) {
		if (_o_ == this)
			return 0;
		int _c_ = 0;
		_c_ = xc1.compareTo(_o_.xc1);
		if (0 != _c_) return _c_;
		return _c_;
	}

	@Override
	public boolean equals(Object _o_) {
		if (_o_ instanceof xcompare2)
			return 0 == this.compareTo((xcompare2)_o_);
		return false;
	}

	@Override
	public int hashCode() {
		int _h_ = 0;
		_h_ += xc1.hashCode();
		return _h_;
	}

}
