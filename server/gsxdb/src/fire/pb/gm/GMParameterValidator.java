//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb.gm;

import java.util.regex.Pattern;
import org.apache.log4j.Logger;

public class GMParameterValidator {
    private static final Logger logger = Logger.getLogger("GM_SECURITY");
    private static final Pattern ROLE_ID_PATTERN = Pattern.compile("^[1-9]\\d{0,18}$");
    private static final Pattern USER_ID_PATTERN = Pattern.compile("^[1-9]\\d{0,9}$");
    private static final Pattern ITEM_ID_PATTERN = Pattern.compile("^[1-9]\\d{0,9}$");
    private static final Pattern SAFE_STRING_PATTERN = Pattern.compile("^[\\w\\u4e00-\\u9fa5\\s\\-_.,!?]{0,200}$");
    private static final String[] SQL_INJECTION_KEYWORDS = new String[]{"select", "insert", "update", "delete", "drop", "truncate", "alter", "create", "union", "where", "order", "group", "having", "exec", "execute", "sp_", "xp_", "cmdshell", "--", "/*", "*/", ";", "'"};
    private static final String[] DANGEROUS_CHARS = new String[]{"<", ">", "\"", "'", "&", "%", "$", "#", "@", "`", "\\", "|", "^"};

    public static boolean validateLong(String value, long min, long max) {
        if (value != null && !value.trim().isEmpty()) {
            try {
                long longValue = Long.parseLong(value.trim());
                return longValue >= min && longValue <= max;
            } catch (NumberFormatException var7) {
                logger.warn("数值格式错误: " + value);
                return false;
            }
        } else {
            return false;
        }
    }

    public static long parseLong(String value, long min, long max) {
        return !validateLong(value, min, max) ? -1L : Long.parseLong(value.trim());
    }

    public static boolean validateInt(String value, int min, int max) {
        if (value != null && !value.trim().isEmpty()) {
            try {
                int intValue = Integer.parseInt(value.trim());
                return intValue >= min && intValue <= max;
            } catch (NumberFormatException var4) {
                logger.warn("整数格式错误: " + value);
                return false;
            }
        } else {
            return false;
        }
    }

    public static int parseInt(String value, int min, int max) {
        return !validateInt(value, min, max) ? -1 : Integer.parseInt(value.trim());
    }

    public static boolean validateRoleId(String roleId) {
        return roleId == null ? false : ROLE_ID_PATTERN.matcher(roleId.trim()).matches();
    }

    public static boolean validateUserId(String userId) {
        return userId == null ? false : USER_ID_PATTERN.matcher(userId.trim()).matches();
    }

    public static boolean validateItemId(String itemId) {
        return itemId == null ? false : ITEM_ID_PATTERN.matcher(itemId.trim()).matches();
    }

    public static String sanitizeInput(String input) {
        if (input == null) {
            return "";
        } else {
            String sanitized = input.trim();

            for(String dangerousChar : DANGEROUS_CHARS) {
                sanitized = sanitized.replace(dangerousChar, "");
            }

            if (sanitized.length() > 500) {
                sanitized = sanitized.substring(0, 500);
                logger.warn("输入字符串被截断，原长度: " + input.length());
            }

            return sanitized;
        }
    }

    public static boolean validateSafeString(String input) {
        return input == null ? false : SAFE_STRING_PATTERN.matcher(input).matches();
    }

    public static boolean hasSQLInjection(String input) {
        if (input == null) {
            return false;
        } else {
            String lowerInput = input.toLowerCase();

            for(String keyword : SQL_INJECTION_KEYWORDS) {
                if (lowerInput.contains(keyword)) {
                    logger.warn("检测到潜在SQL注入: " + input);
                    return true;
                }
            }

            return false;
        }
    }

    public static boolean hasCommandInjection(String input) {
        if (input == null) {
            return false;
        } else {
            String[] commandPatterns = new String[]{"../", "./", "rm ", "del ", "format", "shutdown", "reboot", "$(", "${", "`", "&", "|", ";", "&&", "||", ">", "<", "exec", "system", "eval", "script", "cat ", "ls ", "ps ", "kill ", "chmod ", "chown ", "wget ", "curl ", "nc "};
            String lowerInput = input.toLowerCase();

            for(String pattern : commandPatterns) {
                if (lowerInput.contains(pattern)) {
                    logger.warn("检测到潜在命令注入: " + input);
                    return true;
                }
            }

            return false;
        }
    }

    public static boolean validateArgsLength(String[] args, int minLength, int maxLength) {
        if (args == null) {
            return false;
        } else {
            int length = args.length;
            boolean valid = length >= minLength && (maxLength <= 0 || length <= maxLength);
            if (!valid) {
                logger.warn(String.format("参数数量错误: 实际=%d, 要求=%d-%d", length, minLength, maxLength > 0 ? maxLength : Integer.MAX_VALUE));
            }

            return valid;
        }
    }

    public static boolean isSecureInput(String input) {
        if (input == null) {
            return true;
        } else if (hasSQLInjection(input)) {
            return false;
        } else if (hasCommandInjection(input)) {
            return false;
        } else if (input.length() > 1000) {
            logger.warn("输入过长，可能的攻击尝试: " + input.length() + " 字符");
            return false;
        } else {
            return true;
        }
    }

    public static String validateMailContent(String content) {
        if (content == null) {
            return "";
        } else {
            String cleaned = sanitizeInput(content);
            if (!isSecureInput(cleaned)) {
                logger.warn("邮件内容包含危险字符，已清理");
                cleaned = cleaned.replaceAll("[^\\w\\u4e00-\\u9fa5\\s\\-_.,!?()\\[\\]]", "");
            }

            if (cleaned.length() > 200) {
                cleaned = cleaned.substring(0, 200);
            }

            return cleaned;
        }
    }

    public static boolean validateGoldAmount(long amount) {
        return amount >= 1L && amount <= 10000000L;
    }

    public static boolean validateExpAmount(long exp) {
        return exp >= 1L && exp <= 1000000L;
    }

    public static boolean validateLevel(int level) {
        return level >= 1 && level <= 150;
    }

    public static String getValidationStats() {
        return String.format("GMParameterValidator统计 - SQL注入关键字: %d个, 危险字符: %d个", SQL_INJECTION_KEYWORDS.length, DANGEROUS_CHARS.length);
    }
}
