package fire.pb.gm;

import fire.pb.tel.utils.TelBindUtils;

/**
 * 解除手机绑定
 * 
 * @作者阳涛
 * @dateTime 2016年8月18日 下午1:46:48
 * @版本1.0
 */
public class GM_addunbindtel extends GMCommand {

	@Override
	boolean exec(String[] args) {
		if (args.length < 1) {
			sendToGM("参数格式错误：" + usage());
		}
		final long roleId = Long.parseLong(args[0]);
		TelBindUtils.unBindTelByGM(roleId);
		return true;
	}

	@Override
	String usage() {
		return "//addunbindtel $roleId$";
	}
}
