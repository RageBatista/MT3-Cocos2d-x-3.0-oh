package fire.pb.callback;

import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;
import fire.util.ExceptionHandler;

/**
 * 安全加密工具类（已升级）
 *
 * 安全改进：
 * 1. 新增SHA-256/SHA-512哈希方法（替代不安全的MD5）
 * 2. MD5方法已废弃，仅保留向后兼容
 * 3. 支持加盐哈希（防止彩虹表攻击）
 *
 * 推荐使用：
 * - SHA-256：适用于一般哈希需求
 * - SHA-512：适用于高安全性场景
 * - SHA-256 with salt：适用于密码存储
 *
 * @author dc (original)
 * @author MT3 Security Team (security enhancements)
 * @版本2.0
 */
public class Encrypter {

	/**
	 * SHA-256哈希（推荐）
	 *
	 * @param source 待哈希的字符串
	 * @return 十六进制哈希值
	 */
	public static String SHA256(String source) {
		return SHA256(source, "UTF-8");
	}

	/**
	 * SHA-256哈希（指定编码）
	 *
	 * @param source 待哈希的字符串
	 * @param encoding 字符编码
	 * @return 十六进制哈希值
	 */
	public static String SHA256(String source, String encoding) {
		return hash(source, encoding, "SHA-256");
	}

	/**
	 * SHA-512哈希（更高安全性）
	 *
	 * @param source 待哈希的字符串
	 * @return 十六进制哈希值
	 */
	public static String SHA512(String source) {
		return SHA512(source, "UTF-8");
	}

	/**
	 * SHA-512哈希（指定编码）
	 *
	 * @param source 待哈希的字符串
	 * @param encoding 字符编码
	 * @return 十六进制哈希值
	 */
	public static String SHA512(String source, String encoding) {
		return hash(source, encoding, "SHA-512");
	}

	/**
	 * SHA-256加盐哈希（推荐用于密码存储）
	 *
	 * @param source 待哈希的字符串
	 * @param salt 盐值（建议随机生成并存储）
	 * @return 十六进制哈希值
	 */
	public static String SHA256WithSalt(String source, String salt) {
		return SHA256(source + salt);
	}

	/**
	 * 通用哈希方法
	 *
	 * @param source 待哈希的字符串
	 * @param encoding 字符编码
	 * @param algorithm 哈希算法（SHA-256, SHA-512）
	 * @return 十六进制哈希值
	 */
	private static String hash(String source, String encoding, String algorithm) {
		char hexDigits[] = {'0', '1', '2', '3', '4', '5', '6', '7', '8', '9', 'A', 'B', 'C', 'D', 'E', 'F'};
		try {
			byte[] btInput = source.getBytes(encoding);
			MessageDigest mdInst = MessageDigest.getInstance(algorithm);
			mdInst.update(btInput);
			byte[] md = mdInst.digest();
			int j = md.length;
			char str[] = new char[j * 2];
			int k = 0;
			for (int i = 0; i < j; i++) {
				byte byte0 = md[i];
				str[k++] = hexDigits[byte0 >>> 4 & 0xf];
				str[k++] = hexDigits[byte0 & 0xf];
			}
			return new String(str);
		} catch (Exception e) {
			ExceptionHandler.handleException(e, "fire.pb.callback.Encrypter");
			return null;
		}
	}

	/**
	 * MD5哈希（已废弃，不推荐使用）
	 *
	 * 安全警告：MD5已不再安全，易受碰撞攻击。
	 * 请使用SHA-256或SHA-512替代。
	 *
	 * 此方法仅保留用于向后兼容旧系统。
	 *
	 * @param source 待哈希的字符串
	 * @param encoding 字符编码
	 * @return 十六进制哈希值
	 * @deprecated 使用SHA-256替代
	 */
	@Deprecated
	public final static String MD5(String source, String encoding) {
		char hexDigits[] = {'0', '1', '2', '3', '4', '5', '6', '7', '8', '9', 'A', 'B', 'C', 'D', 'E', 'F'};
		try {
			byte[] btInput = source.getBytes(encoding);
			MessageDigest mdInst = MessageDigest.getInstance("MD5");
			mdInst.update(btInput);
			byte[] md = mdInst.digest();
			int j = md.length;
			char str[] = new char[j * 2];
			int k = 0;
			for (int i = 0; i < j; i++) {
				byte byte0 = md[i];
				str[k++] = hexDigits[byte0 >>> 4 & 0xf];
				str[k++] = hexDigits[byte0 & 0xf];
			}
			return new String(str);
		} catch (Exception e) {
			ExceptionHandler.handleException(e, "fire.pb.callback.Encrypter");
			return null;
		}
	}

	/**
	 * MD5哈希（已废弃，不推荐使用）
	 *
	 * @param source 待哈希的字符串
	 * @return 十六进制哈希值
	 * @deprecated 使用SHA256替代
	 */
	@Deprecated
	public final static String MD5(String source) {
		return MD5(source, "UTF-8");
	}
}
