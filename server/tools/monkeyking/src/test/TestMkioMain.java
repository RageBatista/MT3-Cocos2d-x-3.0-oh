package test;

import javax.xml.parsers.DocumentBuilderFactory;
import org.w3c.dom.Document;
import org.w3c.dom.Element;
import org.w3c.dom.Node;
import org.w3c.dom.NodeList;
import mkio.Engine;
import mkio.MkioConf;
import mkdb.Mkdb;
import mkdb.MkdbConf;

public class TestMkioMain {
    public static void main(String[] args) throws Exception {
        Document doc = DocumentBuilderFactory.newInstance().newDocumentBuilder().parse("mkdb.xml");
        Element root = doc.getDocumentElement();
        Element uniq = null;
        NodeList childnodes = root.getChildNodes();
        for (int i = 0; i < childnodes.getLength(); ++i) {
            Node node = childnodes.item(i);
            if (Node.ELEMENT_NODE != node.getNodeType())
                continue;
            Element e = (Element) node;
            if (e.getNodeName().equals("UniqNameConf")) {
                uniq = e;
                break;
            }
        }
        if (uniq == null) throw new IllegalStateException("UniqNameConf not found");
        Mkdb.getInstance().setConf(new MkdbConf("mkdb.xml"));
        Mkdb.getInstance().start();
        try {
            MkioConf.loadAndRegisterInChildNodes(uniq);
            Engine.getInstance().open(2);
            Thread.sleep(1000);
            Engine.getInstance().close();
        } finally {
            Mkdb.getInstance().stop();
        }
    }
}
