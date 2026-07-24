package fire.util;

import javax.crypto.Cipher;
import javax.crypto.spec.GCMParameterSpec;
import javax.crypto.spec.SecretKeySpec;
import java.nio.ByteBuffer;
import java.nio.charset.StandardCharsets;
import java.security.MessageDigest;
import java.security.SecureRandom;
import java.util.Base64;

/**
 * 配置加密工具类（AES-256-GCM 安全加固版）
 *
 * 安全改进：
 * 1. 从弱XOR加密升级到AES-256-GCM
 * 2. 使用GCM模式提供认证加密（AEAD）
 * 3. 每次加密使用唯一IV（初始化向量）
 * 4. 密钥通过SHA-256派生
 * 5. 支持密钥长度规范化
 *
 * 使用方法：
 * 1. 加密: java fire.util.ConfigEncryptor encrypt "原文"
 * 2. 解密: java fire.util.ConfigEncryptor decrypt "密文"
 * 3. 配置文件中使用: sys.mysql.pass=ENC(加密后的密文)
 *
 * 注意事项：
 * - 加密密钥应从环境变量 CONFIG_ENCRYPTION_KEY 获取
 * - 生产环境密钥应存储在安全的密钥管理服务中（如Vault）
 * - 不要将加密密钥硬编码在代码中
 *
 * @author MT3 安全团队
 * @版本2.0.0
 * @日期 2026-03-04
 */
public class ConfigEncryptor {

    private static final String ALGORITHM = "AES";
    private static final String TRANSFORMATION = "AES/GCM/NoPadding";
    private static final int GCM_TAG_LENGTH = 128;
    private static final int GCM_IV_LENGTH = 12;
    private static final int KEY_SIZE = 256;

    private static final byte[] ENCRYPTION_KEY = deriveEncryptionKey(getEncryptionKey());

    private static String getEncryptionKey() {
        String key = System.getenv("CONFIG_ENCRYPTION_KEY");
        if (key != null && !key.isEmpty()) {
            return key;
        }

        key = System.getProperty("CONFIG_ENCRYPTION_KEY");
        if (key != null && !key.isEmpty()) {
            return key;
        }

        try {
            org.apache.log4j.Logger.getLogger("CONFIG_SECURITY").warn(
                "[SECURITY WARNING] Using default encryption key! " +
                "Please set CONFIG_ENCRYPTION_KEY in production! " +
                "Example: export CONFIG_ENCRYPTION_KEY=\"your-32-byte-secret-key-here\""
            );
        } catch (Exception e) {
            System.err.println("[SECURITY WARNING] Using default encryption key!");
            System.err.println("[SECURITY WARNING] Please set CONFIG_ENCRYPTION_KEY in production!");
        }
        return "MT3_GameServer_Default_Key_2025_Please_Change";
    }

    private static byte[] deriveEncryptionKey(String userKey) {
        try {
            MessageDigest sha256 = MessageDigest.getInstance("SHA-256");
            byte[] hash = sha256.digest(userKey.getBytes(StandardCharsets.UTF_8));
            return hash;
        } catch (Exception e) {
            throw new RuntimeException("密钥派生失败", e);
        }
    }

    public static String encrypt(String plainText) {
        if (plainText == null || plainText.isEmpty()) {
            return plainText;
        }

        try {
            byte[] iv = new byte[GCM_IV_LENGTH];
            SecureRandom random = new SecureRandom();
            random.nextBytes(iv);

            SecretKeySpec keySpec = new SecretKeySpec(ENCRYPTION_KEY, ALGORITHM);
            GCMParameterSpec gcmSpec = new GCMParameterSpec(GCM_TAG_LENGTH, iv);
            Cipher cipher = Cipher.getInstance(TRANSFORMATION);
            cipher.init(Cipher.ENCRYPT_MODE, keySpec, gcmSpec);

            byte[] ciphertext = cipher.doFinal(plainText.getBytes(StandardCharsets.UTF_8));

            ByteBuffer byteBuffer = ByteBuffer.allocate(iv.length + ciphertext.length);
            byteBuffer.put(iv);
            byteBuffer.put(ciphertext);

            return Base64.getEncoder().encodeToString(byteBuffer.array());
        } catch (Exception e) {
            throw new RuntimeException("AES加密失败: " + e.getMessage(), e);
        }
    }

    public static String decrypt(String encryptedText) {
        if (encryptedText == null || encryptedText.isEmpty()) {
            return encryptedText;
        }

        try {
            byte[] decoded = Base64.getDecoder().decode(encryptedText);

            ByteBuffer byteBuffer = ByteBuffer.wrap(decoded);
            byte[] iv = new byte[GCM_IV_LENGTH];
            byteBuffer.get(iv);
            byte[] ciphertext = new byte[byteBuffer.remaining()];
            byteBuffer.get(ciphertext);

            SecretKeySpec keySpec = new SecretKeySpec(ENCRYPTION_KEY, ALGORITHM);
            GCMParameterSpec gcmSpec = new GCMParameterSpec(GCM_TAG_LENGTH, iv);
            Cipher cipher = Cipher.getInstance(TRANSFORMATION);
            cipher.init(Cipher.DECRYPT_MODE, keySpec, gcmSpec);

            byte[] plaintext = cipher.doFinal(ciphertext);
            return new String(plaintext, StandardCharsets.UTF_8);
        } catch (Exception e) {
            throw new RuntimeException("AES解密失败: " + e.getMessage(), e);
        }
    }

    public static String processConfigValue(String value) {
        if (value == null || value.isEmpty()) {
            return value;
        }

        if (value.startsWith("ENC(") && value.endsWith(")")) {
            String encrypted = value.substring(4, value.length() - 1);
            return decrypt(encrypted);
        }

        return value;
    }

    public static void main(String[] args) {
        if (args.length < 2) {
            printUsage();
            System.exit(1);
        }

        String operation = args[0].toLowerCase();
        String input = args[1];

        try {
            switch (operation) {
                case "encrypt":
                    String encrypted = encrypt(input);
                    System.out.println("加密结果（请复制到配置文件中）:");
                    System.out.println("ENC(" + encrypted + ")");
                    break;

                case "decrypt":
                    String decrypted = decrypt(input);
                    System.out.println("解密结果:");
                    System.out.println(decrypted);
                    break;

                default:
                    System.err.println("错误: 未知的操作 '" + operation + "'");
                    printUsage();
                    System.exit(1);
            }
        } catch (Exception e) {
            System.err.println("操作失败: " + e.getMessage());
            e.printStackTrace();
            System.exit(1);
        }
    }

    private static void printUsage() {
        System.out.println("用法:");
        System.out.println("  java fire.util.ConfigEncryptor encrypt \"明文\"");
        System.out.println("  java fire.util.ConfigEncryptor decrypt \"密文\"");
        System.out.println();
        System.out.println("示例:");
        System.out.println("  加密: java fire.util.ConfigEncryptor encrypt \"myDatabasePassword\"");
        System.out.println("  解密: java fire.util.ConfigEncryptor decrypt \"AES_BASE64_STRING\"");
        System.out.println();
        System.out.println("配置文件使用:");
        System.out.println("  sys.mysql.pass=ENC(加密后的Base64字符串)");
    }
}
