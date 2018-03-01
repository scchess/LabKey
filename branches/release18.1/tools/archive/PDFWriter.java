package org.fhcrc.edi.data;

import com.lowagie.text.Document;
import com.lowagie.text.Paragraph;
import com.lowagie.text.DocumentException;
import com.lowagie.text.pdf.PdfWriter;
import com.lowagie.text.pdf.PdfPTable;

import java.io.IOException;
import java.io.FileOutputStream;

/**
 * User: arauch
 * Date: Nov 6, 2004
 * Time: 8:04:53 PM
 */
public class PDFWriter
{
    public PDFWriter()
    {
    }

    public void write()
    {
        Document document = new Document();

        try
        {
            PdfWriter.getInstance(document, new FileOutputStream("c:\\Chap0101.pdf"));
            document.open();
            document.add(new Paragraph("Hello World"));
            PdfPTable outside = new PdfPTable(1);

            for (int row=0; row<15; row++)
            {
                PdfPTable protein = new PdfPTable(4);
                protein.addCell("Protein");
                protein.addCell("15,539");
                protein.addCell("Peptides: 5");
                protein.addCell("Unique: 4");
                outside.addCell(protein);

                PdfPTable peptide = new PdfPTable(8);

                for (int j=0; j<5; j++)
                {
                    peptide.addCell(String.valueOf(row*5 + j));
                    peptide.addCell("235");
                    peptide.addCell("4.532");
                    peptide.addCell("0.234");
                    peptide.addCell("45%");
                    peptide.addCell("1245.456");
                    peptide.addCell("R.GFCGGGSVT.P");
                    peptide.addCell("5");
                }

                outside.addCell(peptide);
            }

            document.add(outside);
        }
        catch(DocumentException de)
        {
            System.err.println(de.getMessage());
        }
        catch(IOException ioe)
        {
            System.err.println(ioe.getMessage());
        }

        document.close();
    }
}
