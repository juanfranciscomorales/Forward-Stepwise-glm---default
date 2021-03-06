#####VOY A INTENTAR ARMAR UNA FUNCION PARA VER EL % DE BUENAS CLASIFICACIONES EN EL TEST SET POR EL ENSEMBLE VOTING

clasificaciones.test.set.ensemble.voting.glm <- function (test.set = "Dtest.xlsx",cant.modelos = 10, x = tabla.sensibilidad.ordenadas){
  
  is.installed <- function(mypkg) { is.element(mypkg, installed.packages()[,1]) }#creo funcion que se fija si me dice si mi paquete est� instalado o no
  
  if (is.installed("openxlsx") == FALSE) {install.packages("openxlsx")} #si openxlsx no est� instalado hago que me lo instale automaticamente
  
  library(openxlsx) # cargo el paquete que tiene la funcion read.xlsx
  
  df.test.set <- read.xlsx(xlsxFile=test.set, check.names = TRUE) #leo el archivo con el test set
  
  mejores.segun.sensibilidad <- as.numeric(x[c(1:cant.modelos),"modelo"])#extraigo los mejores "cant.modelos" modelos
  
  lista.mejores.modelos <-lista.modelos[mejores.segun.sensibilidad]#armo una lista con el numero de los mejores modelos
  
  lista.predicciones.test <- lapply(X = lista.mejores.modelos, FUN = predict, newdata = df.test.set, type ="response" ) #genero una lista que contenga todas las predicciones de todos los modelos en el test set
  
  secuencia.puntos.corte<-puntos.corte.ROC.glm[ , "cutoff"] # puntos de corte
  
  secuencia.puntos.corte2 <- secuencia.puntos.corte[mejores.segun.sensibilidad] # solo los puntos de corte de los mejores modelos
  
  predicciones.redondeadas.test<-list()
  
  for( i in 1: length(lista.predicciones.test)) {
    predicciones.redondeadas.test[[i]] <- ifelse( lista.predicciones.test[[i]] > secuencia.puntos.corte2[i], yes = 1,no = 0)
    predicciones.redondeadas.test
  }
  
  matriz.predicciones.redondeadas.test <- matrix(unlist(predicciones.redondeadas.test), nrow= length(predicciones.redondeadas.test[[1]]), byrow=FALSE) #armo una matriz don
  
  votos <- apply(X = matriz.predicciones.redondeadas.test, MARGIN = 1, sum, na.rm =TRUE)
  
  predicciones.ensemble.voto.mayoria.test <- ifelse(votos > cant.modelos/2, yes=1,no=0 )
  
  clase <-df.test.set[,"clase" ] #extraigo los valores de la columna clase
  
  bien.clasificados <- predicciones.ensemble.voto.mayoria.test == clase ## veo si el voto me clasifico bien
  
  porcentaje.bien.clasificados <- 100*sum(bien.clasificados)/length(bien.clasificados) #porcentaje de buenas clasificaciones en el training set
  
  tabla.bien.mal.clasificados <- table(predicciones.ensemble.voto.mayoria.test ,clase, dnn = c("clase predicha", "clase real")) #tabla para mostrar los bien y mal clasificados
  
  resultado.final <- list("% bien clasificados test set",porcentaje.bien.clasificados,"Classification Matrix", tabla.bien.mal.clasificados)
  
  resultado.final
  
}

########### ACA TERMINA LA FUNCION, PRIMERO LA CARGO Y LUEGO EJECUTO LO DE ABAJO 

clasificaciones.test.set.ensemble.voting.glm(test.set = "Dtest.xlsx",cant.modelos = 10, x = tabla.sensibilidad.ordenadas)
 