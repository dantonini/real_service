package com.realservice

import com.fhoster.livebase.CloudletEventHandler
import com.fhoster.livebase.cloudlet.FileInfo
import com.fhoster.livebase.cloudlet.HandlerException
import com.fhoster.livebase.cloudlet.OrdinediscaricoFormActionContext
import com.fhoster.livebase.cloudlet.OrdinediscaricoFormObject
import com.fhoster.livebase.cloudlet.PluginActionResult
import com.fhoster.livebase.cloudlet.SpiOrdinediscaricoFormActionHandlerCrea_e_salva_ddt
import java.io.File
import org.joda.time.LocalDate

@CloudletEventHandler
class GeneraDocumentoDiTrasporto implements SpiOrdinediscaricoFormActionHandlerCrea_e_salva_ddt{
	
	override doAction(OrdinediscaricoFormActionContext ctx) throws HandlerException {
		val ddt = convert(ctx.form)
		val pdf = generaPdf(ddt)
		ctx.form.setdocumento_di_trasporto( new FileInfo(pdf,pdf.name, 'application/pdf') )
		ctx.form.setnumero_ddt(computeNumeroDdt())
		return PluginActionResult.responseDownloadFile(pdf)
	}
	
	def computeNumeroDdt() {
		return "DA COMPLETARE"
	}
	
	def generaPdf(DocumentoDiTrasporto ddt) {
		val pdf = new DocumentoDiTrasportoPdfWriter(File.createTempFile('ddt','.pdf')).createPdf(ddt)
		pdf
	}
	
	def DocumentoDiTrasporto convert(OrdinediscaricoFormObject object) {
		val ddt = new DocumentoDiTrasporto

		ddt.numero = computeNumeroDdt
		
		if (object.getnecessario_creare_documento_di_trasporto())
			ddt.deposito = realService
			
		ddt.causale = 'DA COMPLETARE'
		ddt.data = new LocalDate
		ddt.numero = computeNumeroDdt()

		ddt.ordineNumero = 'DA COMPLETARE'
		ddt.ordineData = new LocalDate

		ddt.addItem(new Item => [codice = '123' descrizione = 'asdasdasd' unitaMisura = 'latta' quantita = '2'])
		ddt.addItem(new Item => [codice = '123' descrizione = 'asdasdasd' unitaMisura = 'latta' quantita = '2'])
		ddt.addItem(new Item => [codice = '123' descrizione = 'asdasdasd' unitaMisura = 'latta' quantita = '2'])
		ddt.addItem(new Item => [codice = '123' descrizione = 'asdasdasd' unitaMisura = 'latta' quantita = '2'])

		ddt.mittente = new Societa => [
			ragioneSociale = "DA COMPLETARE es: Metaltubi SNC"
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
			ragioneSociale = "DA COMPLETARE es: BRIGANTE SRL"
			indirizzo = new Indirizzo => [
				via = "Via Mahatma Gandhi, 21"
				cap = "72100"
				localita = "Brindisi"
				provincia = "BR"
			]
		]
		return ddt
	}
	
	def realService() {
		new Societa => [
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
	}
	
}