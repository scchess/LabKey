import java.awt.geom.Rectangle2D;
import java.awt.image.BufferedImage;
import java.io.*;
import java.util.*;
import javax.xml.namespace.*;
import javax.xml.stream.*;
import javax.xml.stream.events.*;
import javax.imageio.*;

public class SliceLayout
{
    public static void main(String[] args)
        throws Exception
    {
        if (args.length < 4) {
            System.out.println("SliceLayout [--dry-run] image.png workspace.xml layout-name out-dir");
            return;
        }

        List<String> largs = new ArrayList<String>(Arrays.asList(args));

        boolean dryRun = false;
        if (largs.get(0).equals("--dry-run")) {
            dryRun = true;
            largs = largs.subList(1, largs.size());
        }

        String image = largs.get(0);
        String workspace = largs.get(1);
        String layoutName = largs.get(2);
        String outDir = largs.get(3);
        SliceLayout slicer = new SliceLayout();
        slicer.slice(dryRun, image, workspace, layoutName, outDir);
    }

    public static class Rect
    {
        public int top, left, bottom, right;

        public Rect(int top, int left, int bottom, int right)
        {
            this.top = top;
            this.left = left;
            this.bottom = bottom;
            this.right = right;
        }

        public Rect union(Rect other)
        {
            return new Rect(
                    Math.min(top, other.top),
                    Math.min(left, other.left),
                    Math.max(bottom, other.bottom),
                    Math.max(right, other.right));
        }

        public Rect grow(int amount)
        {
            return new Rect(
                    top - amount,
                    left - amount,
                    bottom + amount,
                    right + amount);
        }

        public Rect shift(int topBottom, int leftRight)
        {
            return new Rect(
                    top + topBottom,
                    left + leftRight,
                    bottom + topBottom,
                    right + leftRight);
        }
    }

    public Rect Rect(String coords)
    {
        String[] parts = coords.split(",");
        if (parts.length != 4)
            throw new RuntimeException("need four coordinates");

        try {
            return new Rect(
                    Integer.valueOf(parts[0]),
                    Integer.valueOf(parts[1]),
                    Integer.valueOf(parts[2]),
                    Integer.valueOf(parts[3]));
        }
        catch (NumberFormatException nfe) {
            throw new RuntimeException("bad coordinate");
        }
    }

    public Rect Rect(int top, int left, int bottom, int right)
    {
        return new Rect(top, left, bottom, right);
    }


    public static class LayoutGraph
    {
        public Rect rect;
        public String name, xAxis, yAxis;

        // Corresponds to AnalysisSerializer.generateFriendlyName()
        public String getFileName()
        {
            StringBuilder sb = new StringBuilder();
            if ("".equals(name))
                name = "Ungated";
            sb.append(name.replaceAll("/", "~"));
            if (xAxis != null)
            {
                sb.append(" (");
                sb.append(compName(xAxis));

                if (yAxis != null && yAxis.length() > 0)
                {
                    sb.append(", ");
                    sb.append(compName(yAxis));
                }

                sb.append(")");
            }

            sb.append(".png");
            return sb.toString();
        }

        private String compName(String param)
        {
            if (param.startsWith("<") && param.endsWith(">"))
                return "comp-" + param.substring(1, param.length()-1);
            else
                return param;
        }
    }

    public void slice(boolean dryRun, String image, String workspace, String layoutName, String out) throws Exception
    {
        List<LayoutGraph> graphs = layoutGraphs(workspace, layoutName);
        if (graphs == null || graphs.size() == 0)
            throw new RuntimeException("No layout graphs found");
        System.out.println("Found " + graphs.size() + " graphs in layout '" + layoutName + "'");

        BufferedImage img = loadImage(new File(image));
        if (img == null)
            throw new RuntimeException("Failed to open image: " + image);

        File outDir = new File(out);
        if (!dryRun && !outDir.exists())
            if (!outDir.mkdirs())
                throw new RuntimeException("Failed to create output directory: " + outDir);

        for (LayoutGraph graph : graphs)
        {
            String filename = graph.getFileName();
            System.out.println("Writing: " + filename);
            if (!dryRun) {
                BufferedImage sub = crop(img, graph.rect);
                saveImage(sub, new File(outDir, filename));
            }
        }
    }

    public BufferedImage loadImage(File file) throws IOException
    {
        return ImageIO.read(file);
    }

    public void saveImage(BufferedImage img, File file) throws IOException
    {
        String format = file.getName().endsWith(".png") ? "png" : "jpg";
        ImageIO.write(img, format, file);
    }

    public BufferedImage crop(BufferedImage img, Rect r)
    {
        int x = r.left < 0 ? 0 : r.left;
        int y = r.top < 0 ? 0 : r.top;
        int w = r.right - r.left;
        if (x + w > img.getWidth())
            w = img.getWidth() - x;
        int h = r.bottom - r.top;
        if (y + h > img.getHeight())
            h = img.getHeight() - y;
        //System.out.println("  cropping x=" + r.left + ",y=" + r.top + ", w=" + w + ", h=" + h);
        return img.getSubimage(x, y, w, h);
    }

    public XMLEventReader createEventReader(String workspace, String layoutName) throws Exception
    {
        XMLInputFactory factory = XMLInputFactory.newInstance();
        XMLEventReader reader = factory.createXMLEventReader(new FileInputStream(workspace));
        reader = factory.createFilteredReader(reader, new LayoutFilter(layoutName));
        return reader;
    }

    public List<LayoutGraph> layoutGraphs(String workspace, String layoutName)
        throws Exception
    {
        if (workspace.endsWith(".xml"))
            return macLayoutGraphs(workspace, layoutName);
        else
            return pcLayoutGraphs(workspace, layoutName);
    }

    public List<LayoutGraph> macLayoutGraphs(String workspace, String layoutName)
        throws Exception
    {
        Map<String, LayoutGraph> graphs = new LinkedHashMap<String, LayoutGraph>();
        LayoutGraph curr = null;

        XMLEventReader reader = null;
        Location loc = null;
        try
        {
            reader = createEventReader(workspace, layoutName);
            while (reader.hasNext()) {
                XMLEvent e = reader.nextEvent();
                loc = e.getLocation();
                if (e.isStartElement()) {
                    StartElement se = e.asStartElement();
                    QName name = se.getName();

                    if ("Layout".equals(name.getLocalPart())) {
                        Attribute nameAttr = se.getAttributeByName(new QName("name"));
                        if (!nameAttr.getValue().equals(layoutName))
                            System.out.println("Did not filter out other <Layout> elements");
                    }

                    if ("Annotation".equals(name.getLocalPart())) {
                        Attribute ownerIdAttr = se.getAttributeByName(new QName("ownerStreamIdentifier"));
                        String ownerId = ownerIdAttr.getValue();

                        LayoutGraph g = graphs.get(ownerId);
                        if (g == null)
                            graphs.put(ownerId, g = new LayoutGraph());

                        Attribute boundsAttr = se.getAttributeByName(new QName("bounds"));
                        String bounds = boundsAttr.getValue();

                        Rect r = Rect(bounds);
                        g.rect = g.rect == null ? r : g.rect.union(r);
                    }

                    if ("LayoutGraph".equals(name.getLocalPart())) {
                        Attribute idAttr = se.getAttributeByName(new QName("streamID"));
                        String id = idAttr.getValue();

                        curr = graphs.get(id);
                        if (curr == null)
                            graphs.put(id, curr = new LayoutGraph());

                        Attribute boundsAttr = se.getAttributeByName(new QName("bounds"));
                        String bounds = boundsAttr.getValue();
                        Rect r = Rect(bounds);
                        // adjust for axis labels
                        //r = r.grow(16);
                        // shift to left by 16. and top by 16
                        r = r.shift(-16, -16);
                        curr.rect = curr.rect == null ? r : curr.rect.union(r);
                    }

                    // Sometimes <LayoutGraph> and <Layer> name attributes aren't equivalent.  I think the
                    // population the graph is looking at is the in <Layer>'s name attribute.
                    if ("Layer".equals(name.getLocalPart())) {
                        Attribute nameAttr = se.getAttributeByName(new QName("name"));
                        curr.name = nameAttr.getValue();
                    }

                    // Axis is under Graph element
                    if ("Axis".equals(name.getLocalPart()) && curr != null) {
                        Attribute nameAttr = se.getAttributeByName(new QName("name"));
                        if (curr.xAxis == null)
                            curr.xAxis = nameAttr.getValue();
                        else if (curr.yAxis == null)
                            curr.yAxis = nameAttr.getValue();
                    }
                }

                if (e.isEndElement()) {
                    EndElement se = e.asEndElement();
                    QName name = se.getName();
                    if ("LayoutGraph".equals(name.getLocalPart())) {
                        //graphs.add(curr);
                        curr = null;
                    }
                }
            }
        }
        catch (Exception e)
        {
            if (loc == null)
                throw e;

            throw new RuntimeException("Error parsing layout on line " + loc.getLineNumber(), e);
        }
        finally
        {
            reader.close();
        }
        return new ArrayList<LayoutGraph>(graphs.values());
    }

    public List<LayoutGraph> pcLayoutGraphs(String workspace, String layoutName)
        throws Exception
    {
        List<LayoutGraph> graphs = new LinkedList<LayoutGraph>();
        LayoutGraph curr = null;

        XMLEventReader reader = null;
        Location loc = null;
        try
        {
            reader = createEventReader(workspace, layoutName);
            while (reader.hasNext()) {
                XMLEvent e = reader.nextEvent();
                loc = e.getLocation();
                if (e.isStartElement()) {
                    StartElement se = e.asStartElement();
                    QName name = se.getName();

                    if ("Layout".equals(name.getLocalPart())) {
                        Attribute nameAttr = se.getAttributeByName(new QName("name"));
                        if (!nameAttr.getValue().equals(layoutName))
                            System.out.println("Did not filter out other <Layout> elements");
                    }

                    if ("ChartData".equals(name.getLocalPart())) {
                        Attribute xAttr = se.getAttributeByName(new QName("x"));
                        Attribute yAttr = se.getAttributeByName(new QName("y"));

                        int x = Integer.parseInt(xAttr.getValue());
                        int y = Integer.parseInt(yAttr.getValue());

                        // hardcoded offsets for now
                        x -= 64;
                        y -= 8;
                        Rect r = Rect(y, x, y+424, x+330);

                        curr = new LayoutGraph();
                        curr.rect = r;
                    }

                    if ("DataLayer".equals(name.getLocalPart())) {
                        Attribute pathAttr = se.getAttributeByName(new QName("path"));
                        curr.name = pathAttr.getValue();
                    }

                    // Axis is under Graph element
                    if ("Axis".equals(name.getLocalPart()) && curr != null) {
                        Attribute nameAttr = se.getAttributeByName(new QName("name"));
                        Attribute dimensionAttr = se.getAttributeByName(new QName("dimension"));
                        String dim = dimensionAttr.getValue();
                        if ("x".equals(dim))
                            curr.xAxis = nameAttr.getValue();
                        else
                            curr.yAxis = nameAttr.getValue();
                    }
                }

                if (e.isEndElement()) {
                    EndElement se = e.asEndElement();
                    QName name = se.getName();
                    if ("ChartData".equals(name.getLocalPart())) {
                        graphs.add(curr);
                        curr = null;
                    }
                }
            }
        }
        catch (Exception e)
        {
            if (loc == null)
                throw e;

            throw new RuntimeException("Error parsing layout on line " + loc.getLineNumber(), e);
        }
        finally
        {
            reader.close();
        }
        return graphs;
    }
    public static class LayoutFilter implements EventFilter
    {
        public static final Set<String> ALLOWED;
        static {
            ALLOWED = new HashSet<String>();
            ALLOWED.add("Workspace");
            ALLOWED.add("LayoutEditor");
            ALLOWED.add("Layout");
            ALLOWED.add("Annotation");
            ALLOWED.add("LayoutGraph");
            ALLOWED.add("Layer");
            ALLOWED.add("Graph");
            ALLOWED.add("Axis");

            // PC workspace elements
            ALLOWED.add("ChartData");
            ALLOWED.add("DataLayer");
            ALLOWED.add("WindowPosition");
            ALLOWED.add("Legend");
            ALLOWED.add("PopModelList");
        }

        public String layoutName;
        public boolean withinLayout;

        public LayoutFilter(String layoutName)
        {
            this.layoutName = layoutName;
        }

        public boolean accept(XMLEvent e)
        {
            switch (e.getEventType())
            {
                case XMLStreamConstants.START_DOCUMENT:
                case XMLStreamConstants.END_DOCUMENT:
                case XMLStreamConstants.ATTRIBUTE:
                    return true;

                case XMLStreamConstants.START_ELEMENT:
                {
                    StartElement se = e.asStartElement();
                    QName name = se.getName();
                    if (name.getLocalPart().equals("Layout")) {
                        Attribute attr = se.getAttributeByName(new QName("name"));
                        if (attr != null) {
                            withinLayout = attr.getValue().equals(layoutName);
                        }
                        return withinLayout;

                    }
                    else {
                        return withinLayout && ALLOWED.contains(name.getLocalPart());
                    }
                }

                case XMLStreamConstants.END_ELEMENT:
                {
                    EndElement ee = e.asEndElement();
                    QName name = ee.getName();
                    if (name.getLocalPart().equals("Layout")) {
                        if (withinLayout) {
                            withinLayout = false;
                            return true;
                        }
                        else {
                            return false;
                        }
                    }
                    else {
                        return withinLayout && ALLOWED.contains(name.getLocalPart());
                    }
                }

                default:
                    return false;
            }
        }
    }

}
