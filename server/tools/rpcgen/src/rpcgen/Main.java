package rpcgen;

import javax.xml.parsers.DocumentBuilderFactory;
import org.w3c.dom.Document;
import org.w3c.dom.Element;

public class Main {
    public static boolean isJava = true;
    public static boolean isAs = false;
    public static boolean isJs = false;
    public static boolean isAIO = false;
    public static boolean overwriteAll = false;
    public static boolean validateMarshal = false;
    public static boolean validateUnmarshal = false;
    public static boolean wOstream = false;
    public static boolean cxxTrace = false;
    public static String inputEncoding = "UTF-8";
    public static String outputEncoding = "UTF-8";
    public static final Ranges globalProviderIds = new Ranges();
    public static final Ranges globalProtocolTypes = new Ranges();
    public static String asSrcDir;
    public static String asBeansDir;
    public static String precompiledHeader;

    private static java.io.File currentXmlDir;
    private static java.util.Set<String> imported = new java.util.HashSet<String>();

    public static void debug(String s) {
        System.out.println(s);
    }

    public static String quote(String s) {
        return "'" + s + "'";
    }

    public static void appendChild(org.w3c.dom.Element parent, org.w3c.dom.Element child, int deep) {
        parent.appendChild(child);
    }

    public static void finishAppendChild(org.w3c.dom.Element parent, int deep) {
    }

    public static void importProject(String file) {
        try {
            java.io.File f = currentXmlDir == null ? new java.io.File(file) : new java.io.File(currentXmlDir, file);
            String key = f.getCanonicalPath();
            if (imported.contains(key))
                return;
            imported.add(key);
            Document doc = DocumentBuilderFactory.newInstance().newDocumentBuilder().parse(f);
            Element root = doc.getDocumentElement();
            new Project(root);
        } catch (Exception e) {
            throw new RuntimeException(e);
        }
    }

    private static void usage() {
        System.out.println("rpcgen usage: java -jar rpcgen.jar [options] <xml-file>");
        System.out.println("options: -h|--help  -validateMarshal  -validateUnmarshal  -java|-as|-js|-cxx  -aio  -overwrite  -inenc=<enc>  -outenc=<enc>");
    }

    public static void main(String[] args) throws Exception {
        if (args.length == 0) {
            usage();
            return;
        }
        int i = 0;
        while (i < args.length && args[i].startsWith("-")) {
            String opt = args[i++];
            if (opt.equals("-h") || opt.equals("--help")) {
                usage();
                return;
            } else if (opt.equals("-validateMarshal")) {
                validateMarshal = true;
            } else if (opt.equals("-validateUnmarshal")) {
                validateUnmarshal = true;
            } else if (opt.equals("-java")) {
                isJava = true;
                isAs = false;
                isJs = false;
            } else if (opt.equals("-as")) {
                isJava = false;
                isAs = true;
                isJs = false;
            } else if (opt.equals("-js")) {
                isJava = false;
                isAs = false;
                isJs = true;
            } else if (opt.equals("-cxx")) {
                isJava = false;
                isAs = false;
                isJs = false;
            } else if (opt.equals("-aio")) {
                isAIO = true;
            } else if (opt.equals("-overwrite")) {
                overwriteAll = true;
            } else if (opt.startsWith("-inenc=")) {
                inputEncoding = opt.substring("-inenc=".length());
            } else if (opt.startsWith("-outenc=")) {
                outputEncoding = opt.substring("-outenc=".length());
            }
        }
        if (i >= args.length) {
            usage();
            return;
        }
        java.io.File xml = new java.io.File(args[i]);
        currentXmlDir = xml.getParentFile();
        Document doc = DocumentBuilderFactory.newInstance().newDocumentBuilder().parse(xml);
        Element root = doc.getDocumentElement();
        Project project = new Project(root);
        project.compile();
        project.make();
    }
}
