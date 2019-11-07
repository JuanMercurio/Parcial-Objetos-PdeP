
class Linea{
	var numero 
	var property packs = []
	var property consumos = []
	var property tipoDeLinea = simple
	
	method costoPromedioEntre(fechaInicial, fechaFinal){
		return self.promedioConsumido(self.consumidosEntre(fechaInicial, fechaFinal))
	}
	
	method costoDelUltimoMes() {
		return self.consumosDelUltimoMes().sum({consumo => consumo.costo()})
	}
	
	method agregarPack(pack) {
		packs.add(pack)
	}
	
	method puedeConsumir(consumo){
		return packs.any({pack => pack.satisface(consumo)})
	}
	
	method consumir(consumo){
		if(self.puedeConsumir(consumo)){
			self.agregarConsumo(consumo)
			self.producirGasto(consumo)
		} else {
			tipoDeLinea.realizarIgual(consumo, self)
		}
	}
		
	method producirGasto(consumo) {
		self.encontrarPackQueSatisface(consumo).gastar(consumo)
	}
	
	method encontrarPackQueSatisface(consumo) = packs.reverse().find({pack => pack.satistace(consumo)})
	
	method agregarConsumo(consumo){
		consumos.add(consumo)
	}	
	
	method limpiarPacks(){
		packs.removeAllSuchThat({pack => !pack.estaVigente()})
	}
	
	method consumosDelUltimoMes() = consumos.filter({consumo => consumo.esDelUltimoMes()})
	method consumidosEntre(inicio, fin) = consumos.filter({consumo => consumo.consumioEntre(inicio, fin)})
	
	method promedioConsumido(consumoss) {	
		return consumos.sum({consu => consu.costo()}) / consumoss.size()
	}
}

class Pack {
	var vencimiento = null
	var mb = 0
	var segundos = 0
	
	method satisface(consumo) {
		return self.estaVigente() and self.criterio(consumo)
	}
	
	method criterio(consumo) 
	
	
	method estaVigente() {
		if (vencimiento == null) {
			return true
		} else 
			return vencimiento < new Date()
	}
	method tieneMasMBQue(consumo) = consumo.mb() < mb
	method tieneMasSegundosQue(consumo) = consumo.segundos() < segundos
	
	
	method reducirMB(megas){
		mb -= megas
	}
	
	method reducirSegundos(segundosAReducir){
		segundos -= segundosAReducir
	}
}

class InternetIlimitado inherits Pack{
	var dias = []
	
	override method criterio(consumo){
		var hoy = new Date()
		if (dias.contains(hoy.dayOfTheWeek())){
 			return true
		}
		else {
			return self.tieneMasMBQue(consumo)
		}
	}
	
	method gastar(consumo){
		if (!self.esDiaGratis()){
			self.reducirMB(consumo)
		}
	}
	
	method esDiaGratis() {
		var hoy = new Date() 
		return dias.contains(hoy.dayOfTheWeek())
	}
}


class MBLibres inherits Pack{
	var MBLibres
	
	var verdaderosMB = MBLibres + mb
	
	override method criterio(consumo){
		return consumo.mb() < verdaderosMB 
	}
	
	method gastar(consumo){
		verdaderosMB -= consumo.mb()
		MBLibres = 0.min(MBLibres-consumo.mb())
	}
}

class AgregarCredito inherits Pack{
	var credito
	
	override method criterio(consumo){
		return consumo.costo() < credito
	}
	
	method gastar(consumo){
		credito =- consumo.costo()
	}
}

class LlamadasGratis inherits Pack{
	
	override method criterio(consumo) {
		return self.tieneMasMBQue(consumo)
	}
	
	method gastar(){
		
	}
}

class Consumo{
	var fechaDeConsumo
	
	method esDelUltimoMes() {
		var hoy = new Date()
		self.consumioEntre(hoy, hoy.minusDays(30))
	}
	
	method consumioEntre(inicio, fin) {
		fechaDeConsumo.between(inicio, fin)
	}
	

}

class ConsumoSegundos inherits Consumo{
	var segundos 
	
	 method costo() = empresa.precioFijo( )+ empresa.precioPorSegundo()*(30-segundos)
	 
	
}

class ConsumoInternet inherits Consumo{
	var mb
	
	method costo() = empresa.precioPorMB() * mb
	
	
}

object simple {
	method realizarIgual(consumo, linea){
		self.error("no se puede consumir")
	}
}

object black {
	method realizarIgual(consumo, linea){
		linea.agregarADeuda(consumo.costo())
		linea.agregarConsumo(consumo)
	}
}

object platinum{
		method realizarIgual(consumo, linea){
			linea.agregarConsumo(consumo)
	}
}

object empresa{
	var property precioFijo = 1
	var property precioPorSegundo = 0.1
	var property precioPorMB = 1
}