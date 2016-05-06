package com.realservice

import com.itextpdf.text.Document
import com.itextpdf.text.DocumentException
import com.itextpdf.text.Element
import com.itextpdf.text.Font
import com.itextpdf.text.FontFactory
import com.itextpdf.text.Image
import com.itextpdf.text.Paragraph
import com.itextpdf.text.Rectangle
import com.itextpdf.text.pdf.PdfPCell
import com.itextpdf.text.pdf.PdfPTable
import com.itextpdf.text.pdf.PdfWriter
import java.io.File
import java.io.FileOutputStream
import java.io.IOException
import java.util.List
import org.eclipse.xtend.lib.annotations.Accessors
import org.joda.time.LocalDate

import static com.google.common.base.Strings.*

class DocumentoDiTrasportoPdfWriter {
	File file
	PdfWriter writer
	Document document

	static val DEFAULT_FONT = FontFactory.getFont(FontFactory.HELVETICA, 8)

	new(File file) {
		this.file = file
		this.document = new Document()
		this.writer = PdfWriter::getInstance(document, new FileOutputStream(file))
	}

	def static void main(String[] args) throws IOException, DocumentException {
		val ddt = new DocumentoDiTrasporto()
		ddt.causale = 'Vendita'
		ddt.data = new LocalDate
		ddt.numero = '42/12345'

		ddt.ordineNumero = '12345'
		ddt.ordineData = new LocalDate

		ddt.addItem(new Item => [codice = '123' descrizione = 'asdasdasd' unitaMisura = 'latta' quantita = '2'])
		ddt.addItem(new Item => [codice = '123' descrizione = 'asdasdasd' unitaMisura = 'latta' quantita = '2'])
		ddt.addItem(new Item => [codice = '123' descrizione = 'asdasdasd' unitaMisura = 'latta' quantita = '2'])
		ddt.addItem(new Item => [codice = '123' descrizione = 'asdasdasd' unitaMisura = 'latta' quantita = '2'])

		ddt.mittente = new Societa => [
			ragioneSociale = "Metaltubi SNC"
			indirizzo = new Indirizzo => [
				via = "Via dei Carpazi, 55"
				cap = "001144"
				localita = "Roma"
				provincia = "RM"
			]
			partitaIva = "01530611001"
			email = "info@asdasd.com"
			fax = "1231231231231"
			telefono = "12342342"
		]

		ddt.destinatario = new Societa => [
			ragioneSociale = "BRIGANTE SRL"
			indirizzo = new Indirizzo => [
				via = "Via Mahatma Gandhi, 21"
				cap = "72100"
				localita = "Brindisi"
				provincia = "BR"
			]
		]
		
		ddt.deposito = new Societa => [
			ragioneSociale = "REAL SERVICE SOCIETA' COOP"
			indirizzo = new Indirizzo => [
				via = "Via Galatea, 106"
				cap = "00155"
				localita = "Roma"
			]
			partitaIva = "10575341002"
			telefono = "+39 06 22799703"
			fax = "+39 06 22799703"
		]
		new DocumentoDiTrasportoPdfWriter(new File("ddt.pdf")).createPdf(ddt)
	}

	def File createPdf(DocumentoDiTrasporto ddt) throws IOException, DocumentException {
		document.open()

		val PdfPTable header = new PdfPTable(3)
		header.setWidthPercentage(100)
		header.defaultCell.border = Rectangle.NO_BORDER
		header.widths = #{20, 30, 50} as int[]
		
		if (ddt.mittente.logo != null) {
			header.addCell(image(ddt.mittente.logo.absolutePath).asCell().border(Rectangle.NO_BORDER))
			header.addCell(paragraph(ddt.mittente.asIntestazione()).asCell().border(Rectangle.NO_BORDER).paddingBottom(10))
		}
		else 
			header.addCell(paragraph(ddt.mittente.asIntestazione()).asCell().border(Rectangle.NO_BORDER).paddingBottom(10).colSpan(2))
			
//		header.addCell(paragraph(ddt.mittente.asIntestazione()).asCell().border(Rectangle.NO_BORDER).paddingBottom(10))
		header.addCell(smallCapsHeader('destinatario').addElement(ddt.destinatario.asIntestazione()))
		
		if (ddt.deposito != null)
			header.addCell(smallCapsHeader('deposito c/o').addElement(ddt.deposito.asIntestazione()).border(Rectangle.NO_BORDER).paddingBottom(10).colSpan(2))
		else 
			header.addCell(paragraph(' ').asCell().border(Rectangle.NO_BORDER).colSpan(2))
			
		header.addCell(smallCapsHeader('luogo destinazione merce').addElement('''
			«IF ddt.destinazioneMerce == null || ddt.destinatario.indirizzo == ddt.destinazioneMerce»
				IDEM
			«ELSE»
				«ddt.destinazioneMerce.asIntestazione()»
			«ENDIF»
		'''))
		add(header)

		val PdfPTable table = new PdfPTable(2)
		table.setWidthPercentage(100)
		table.setHorizontalAlignment(Element::ALIGN_LEFT)
		table.setWidths((#[5, 1] as int[]))
		table.addCell(smallCapsHeader('tipo documento').addElement('Documento di trasporto'))
		table.addCell(smallCapsHeader('nr.pag.').addElement('1'))
		add(table)

		val PdfPTable table2 = new PdfPTable(5)
		table2.setWidthPercentage(100)
		table2.setHorizontalAlignment(Element::ALIGN_LEFT)
		table2.setWidths((#[1, 1, 1, 1, 1] as int[]))
		table2.addCell(smallCapsHeader('nr.ddt').addElement(ddt.numero))
		table2.addCell(smallCapsHeader('data').addElement(ddt.data))
		table2.addCell(smallCapsHeader('causale').addElement(ddt.causale))
		table2.addCell(smallCapsHeader('vostro ordine').addElement(ddt.ordineNumero))
		table2.addCell(smallCapsHeader('data ordine').addElement(ddt.ordineData))
		add(table2)

		val PdfPTable table3 = new PdfPTable(4)
		table3.setWidthPercentage(100)
		table3.setHorizontalAlignment(Element::ALIGN_LEFT)
		table3.setWidths((#[10, 20, 5, 10] as int[]))
		table3.addCell(bold().paragraph('COD.ARTICOLO').asCell())
		table3.addCell(bold().paragraph('DESCRIZIONE DEI BENI').asCell())
		table3.addCell(bold().paragraph('U.M.').asCellWithAlignment(Element.ALIGN_CENTER))
		table3.addCell(bold().paragraph('QUANTITA\'').asCellWithAlignment(Element.ALIGN_CENTER))
		ddt.items.forEach [
			table3.addCell(paragraph(codice).asCell())
			table3.addCell(paragraph(descrizione).asCell())
			table3.addCell(paragraph(unitaMisura).asCellWithAlignment(Element.ALIGN_CENTER))
			table3.addCell(paragraph(quantita).asCellWithAlignment(Element.ALIGN_CENTER))
		]
		table3.addCell(paragraph(' ').asCell().border(Rectangle.LEFT))
		table3.addCell(paragraph('').asCell().border(Rectangle.NO_BORDER))
		table3.addCell(paragraph('').asCell().border(Rectangle.NO_BORDER))
		table3.addCell(paragraph('').asCell().border(Rectangle.RIGHT))
		table3.extendLastRow = true
		add(table3)

		val PdfPTable table5 = new PdfPTable(3)
		table5.setWidthPercentage(100)
		table5.setHorizontalAlignment(Element::ALIGN_LEFT)
		table5.setWidths((#[1, 1, 1] as int[]))
		table5.addCell(smallCapsHeader('note').colSpan(3).minimumHeight(50))
		table5.addCell(smallCapsHeader('vettore'))
		table5.addCell(smallCapsHeader('data e ora del ritiro'))
		table5.addCell(smallCapsHeader('firma del vettore').heigth(50))
		table5.addCell(smallCapsHeader('aspetto dei beni'))
		table5.addCell(smallCapsHeader('colli'))
		table5.addCell(smallCapsHeader('peso'))
		table5.addCell(smallCapsHeader('contrassegno'))
		table5.addCell(smallCapsHeader('porto'))
		table5.addCell(smallCapsHeader('firma del destinatario').heigth(50))
		addAsFooter(table5)

		document.close()

		return file
	}
	
	def asIntestazione(Indirizzo indirizzo) {
		'''
			«indirizzo.via» «indirizzo.cap» - «indirizzo.localita» «indirizzo.provincia»
		'''		
	}
	
	def asIntestazione(Societa societa) {
		'''
			«societa.ragioneSociale»
			«societa.indirizzo.asIntestazione()»
			«IF !isNullOrEmpty(societa.partitaIva)»P.IVA «societa.partitaIva»«ENDIF» «IF !isNullOrEmpty(societa.email)»Email «societa.email»«ENDIF» 
			«IF !isNullOrEmpty(societa.fax)»Fax «societa.fax»«ENDIF» «IF !isNullOrEmpty(societa.telefono)»Tel «societa.telefono»«ENDIF»
		'''		
	}

	def minimumHeight(PdfPCell cell, int i) {
		cell.minimumHeight = i
		cell
	}

	def colSpan(PdfPCell cell, int i) {
		cell.colspan = i
		cell
	}

	def static image(String path) throws DocumentException, IOException {
		val img = Image.getInstance(path);
		img
	}

	def static add(PdfPCell cell, Element element) {
		cell.addElement(element)
		cell
	}

	def static paddingBottom(PdfPCell cell, int i) {
		cell.paddingBottom = i
		cell
	}

	def static border(PdfPCell cell, int border) {
		cell.border = border
		cell
	}

	def add(Element element) {
		document.add(element)
	}

	def addAsFooter(PdfPTable table) {
		writeFooterTable(writer, document, table)
	}

	// see http://stackoverflow.com/a/28951840/2862436
	def static void writeFooterTable(PdfWriter writer, Document document, PdfPTable table) {
		val FIRST_ROW = 0;
		val LAST_ROW = -1;
		// Table must have absolute width set.
		if (table.getTotalWidth() == 0)
			table.setTotalWidth((document.right() - document.left()) * table.getWidthPercentage() / 100f);
		table.writeSelectedRows(FIRST_ROW, LAST_ROW, document.left(), document.bottom() + table.getTotalHeight(),
			writer.getDirectContent());
	}

	def static heigth(PdfPCell cell, int heigth) {
		cell.fixedHeight = heigth
		cell
	}

	def static PdfPCell cell() {
		new PdfPCell()
	}

	def static bold() {
		FontFactory.getFont(FontFactory.HELVETICA_BOLD)
	}

	def static Paragraph paragraph(Font font, CharSequence text) {
		new Paragraph(text.toString, font)
	}

	def static Paragraph paragraph(CharSequence text) {
		paragraph(DEFAULT_FONT, text)
	}

	def static PdfPCell asCellWithAlignment(Paragraph par, int alignment) {
		val cell = cell()
		par.alignment = Element.ALIGN_CENTER
		cell.addElement(par)
		cell
	}

	def static PdfPCell asCell(Element element) {
		val cell = cell()
		cell.addElement(element)
		cell
	}

	def static PdfPCell addElement(PdfPCell cell, CharSequence text) {
		val par = paragraph(text)
		par.indentationLeft = 10
		cell.addElement(par)
		return cell
	}

	def static PdfPCell addElement(PdfPCell cell, LocalDate date) {
		val par = paragraph(date.toString("dd/MM/yyyy"))
		par.indentationLeft = 10
		cell.addElement(par)
		return cell
	}

	def static PdfPCell smallCapsHeader(String text) {
		val cell = cell()
		cell.addElement(new Paragraph(text.toUpperCase, FontFactory.getFont(FontFactory.COURIER, 8)))
		return cell
	}
}

@Accessors
public class DocumentoDiTrasporto {
	String numero
	LocalDate data
	String causale
	String ordineNumero
	LocalDate ordineData
	Societa mittente
	Societa destinatario
	Societa deposito
	Indirizzo destinazioneMerce
	private List<Item> items = newArrayList

	def addItem(Item item) {
		items.add(item)
	}

}

@Accessors
public class Societa {
	File logo
	String ragioneSociale
	Indirizzo indirizzo
	String partitaIva
	String email
	String fax
	String telefono
}

@Accessors
public class Indirizzo {
	String via
	String cap
	String localita
	String provincia
}

@Accessors
public class Item {
	String codice
	String descrizione
	String unitaMisura
	String quantita
}
