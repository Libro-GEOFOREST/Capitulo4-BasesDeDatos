#Librería ODBC que permite la conectividad ODBC con Bases de Datos
# install.packages("odbc")
library(odbc)
# Librería DBI que permite comunicación con BD relacional
# install.packages("DBI")
library(DBI)

#Listar drivers
odbc::odbcListDrivers()

#Ruta a la Base de datos de Access
IFN3 = "C:/DESCARGA//IFN3/Malaga/Ifn3p29.accdb" #Adaptar a la ruta que se vaya a emplear en el equipo

#Conexión a BD Access. Indicamos encoding
con <- dbConnect(odbc::odbc(), 
                 .connection_string = paste0("Driver={Microsoft Access Driver (*.mdb, *.accdb)};DBQ=",IFN3,";"),
                 encoding = "latin1")

#Listado de tablas de la base de datos
dbListTables(con) 

#Leer tabla
PCParcelas <- dbReadTable(con, "PCParcelas")

#Ver datos de las 2 primeras filas
head(PCParcelas,2)

#Convertir la matriz en un data frame para poder trabajar mejor con ella en R
PCParcelas<-as.data.frame(PCParcelas)
names(PCParcelas)

summary(PCParcelas$CoorX)

summary(PCParcelas$Coory)

PCParcelas<-PCParcelas[which(PCParcelas$CoorX>0),]
PCParcelas<-PCParcelas[which(PCParcelas$CoorX<500000),]
PCParcelas<-PCParcelas[which(PCParcelas$Coory>4000000),]

#Activar la librería sf necesaria para datos espaciales
# install.packages("sf")
library(sf)
#Convertir data frame a SpatialPointsDataFrame
IFN3.sp <- st_as_sf(x=PCParcelas,coords=c("CoorX","Coory"), crs=23030) #EPSG:32630 ED50 UTM30N
plot(st_geometry(IFN3.sp), axes=TRUE,main="Parcelas IFN3 en la provincia de Málaga")

library(sf)
#Proyección de la capa del monte al mismo crs que los puntos
Pinar.Yunquera<-st_transform(Pinar.Yunquera, crs=32630) #EPSG:32630 WGS84 UTM30N

#Convertir los datos a coordenadas geograficas en wgs84
IFN3.sp.WGS84.geograf<-st_transform(IFN3.sp,4326) #EPSG:4326 WGS84 geográficas (latitud,longitud)

#Convertir los datos a coordenadas cartograficas en wgs84
IFN3.sp.WGS84.UTM30N<-st_transform(IFN3.sp.WGS84.geograf,crs=st_crs(32630))

plot(st_geometry(IFN3.sp.WGS84.UTM30N),axes=TRUE,main="Parcelas IFN3 en la provincia de Málaga")
plot(st_geometry(Pinar.Yunquera), border="red", add=TRUE)

#Selección de parcelas
IFN3.monte<-IFN3.sp.WGS84.UTM30N[which(st_within(IFN3.sp.WGS84.UTM30N,
                                            st_geometry(Pinar.Yunquera),
                                            sparse=FALSE)==TRUE),]

length(unique(IFN3.monte$Estadillo))

#Leer tabla de pies mayores
PCMayores <- dbReadTable(con, "PCMayores")

#Nombre de los campos de la tabla
names(PCMayores)

#Unión de tablas por el concepto común Estadillo
Pies.IFN3.monte<-merge(IFN3.monte,PCMayores,by="Estadillo",all.x=TRUE)

#IFN2
#Librería que permite la lectura de archivos .dbf
library(foreign)

#Leer tabla de pies mayores
Pies.Mayores.IFN2<-read.dbf("E:/MAVARO/clases/Centro_Competencias_Digitales/DESCARGAS_IFN/IFN2/Malaga/PIESMA29.dbf")

#Leer tabla de valores agrupados por estadillo
resumen.parcela.IFN2<-read.dbf("E:/MAVARO/clases/Centro_Competencias_Digitales/DESCARGAS_IFN/IFN2/Malaga/IIFL03BD.dbf")

#Nombres de los campos de la tabla del IFN2
names(Pies.Mayores.IFN2)

#Nombres de los campos de la tabla del IFN3
names(Pies.IFN3.monte)

#Conversión a mayúsculas
names(Pies.IFN3.monte)<-toupper(names(Pies.IFN3.monte))

#Recuperación del nombre del campo de geometría
names(Pies.IFN3.monte)[86]<-"geometry"

#Cambiar nombre del campo que marca el orden del número de pie en el IFN2
names(Pies.Mayores.IFN2)[3]<-"ORDENIF2"

#Comprobación de la clase del objeto en la tabla IFN2
is.numeric(Pies.Mayores.IFN2$ESTADILLO)

#Comprobación de la clase del objeto en la tabla IFN3
is.numeric(Pies.IFN3.monte$ESTADILLO)

#Conversión en valor numérico
Pies.IFN3.monte$ESTADILLO<-as.numeric(as.character(Pies.IFN3.monte$ESTADILLO))

#Comprobación de la clase del objeto en la tabla IFN2
is.numeric(Pies.IFN3.monte$ORDENIF2)

#Comprobación de la clase del objeto en la tabla IFN3
is.numeric(Pies.Mayores.IFN2$ORDENIF2)

#Conversión en valor numérico
Pies.IFN3.monte$ORDENIF2<-as.numeric(as.character(Pies.IFN3.monte$ORDENIF2))

#Comprobación de la clase del objeto DIAMETRO1
is.numeric(Pies.Mayores.IFN2$DIAMETRO1)

#Conversión en valor numérico
Pies.Mayores.IFN2$DN1.IFN2<-as.numeric(as.character(Pies.Mayores.IFN2$DIAMETRO1))

#Conversión en valor numérico
Pies.Mayores.IFN2$DN2.IFN2<-as.numeric(as.character(Pies.Mayores.IFN2$DIAMETRO2))

#Comprobación de la clase del objeto ALTURA
is.numeric(Pies.Mayores.IFN2$ALTURA)

#Conversión en valor numérico
Pies.Mayores.IFN2$HT.IFN2<-as.numeric(as.character(Pies.Mayores.IFN2$ALTURA))

#Selección de pies comunes entre ambos inventarios
Pies.IFN3.monte.com<-Pies.IFN3.monte[which(Pies.IFN3.monte$ORDENIF2!=0),]

#Unión de tablas del IFN2 y IFN3
Pies.monte.IFN<-merge(Pies.IFN3.monte.com,Pies.Mayores.IFN2,
                      by=c("ESTADILLO","ORDENIF2"))

resumen.parcela<-aggregate(resumen.parcela.IFN2$NARBOLES,
                           by=list(resumen.parcela.IFN2$CESTADILLO),FUN=sum,
                           na.rm=TRUE)

#Primeros 6 valores de la tabla
head(resumen.parcela)

#Nombre de los campos de la tabla
names(resumen.parcela)

#Cambio de nombre de los campos de la tabla
names(resumen.parcela)<-c("ESTADILLO","Npies_parc")

#Comprobación de la clase del objeto ESTADILLO
is.numeric(resumen.parcela$ESTADILLO)

#Analisis de datos
#Cálculo de valor medio del diámetro normal en IFN2
Pies.monte.IFN$DN.IF2<-(Pies.monte.IFN$DN1.IFN2+Pies.monte.IFN$DN2.IFN2)/2

#Cálculo de valor medio del diámetro normal en IFN3
Pies.monte.IFN$DN.IFN3<-(Pies.monte.IFN$DN1+Pies.monte.IFN$DN2)/2

#Diferencias de diámetros entre los 2 tiempos
Pies.monte.IFN$Dif.DN<-Pies.monte.IFN$DN.IFN3-Pies.monte.IFN$DN.IF2

#Diferencias de alturas entre los 2 tiempos
Pies.monte.IFN$Dif.H<-Pies.monte.IFN$HT-Pies.monte.IFN$HT.IFN2

#Eliminación de errores de medición
Pies.monte.IFN<-Pies.monte.IFN[which(Pies.monte.IFN$Dif.DN>0&
                                       Pies.monte.IFN$Dif.H>0),]

#Pies de pinsapo
pinsapo<-Pies.monte.IFN[which(Pies.monte.IFN$ESPECIE.x=="032"),]

#Parcelas de pinsapo
parcelas.pinsapo<-unique(pinsapo[,c('ESTADILLO', 'geometry')])

#Valores medios de crecimientos por ESTADILLO
resumen.pinsapo<-aggregate(cbind(Dif.DN,Dif.H)~ESTADILLO,
                     data=pinsapo,FUN=mean,na.rm=TRUE)

#Añadir valores de densidad de las parcelas
resumen.pinsapo<-merge(resumen.pinsapo,resumen.parcela,by="ESTADILLO")

#Añadir geometría
resumen.pinsapo<-merge(resumen.pinsapo,parcelas.pinsapo,by="ESTADILLO")

#Conversión de la tabla en datos geográficos
resumen.pinsapo<-st_as_sf(resumen.pinsapo)

#Histograma de los datos de altura
hist(resumen.pinsapo$Dif.H)

#Histograma de los datos de dap
hist(resumen.pinsapo$Dif.DN)

#Histograma de los datos de dap
hist(resumen.pinsapo$Npies_parc)

#Test de correlación entre las alturas y las densidades
correlacion.alturas<-cor.test(resumen.pinsapo$Dif.H,
                              resumen.pinsapo$Npies_parc,
                              method="spearman")

#Correlación entre las alturas y las densidades
correlacion.alturas$estimate

#Significancia de la correlación entre las alturas y las densidades
correlacion.alturas$p.value

#Test de correlación entre los diámetros y las densidades
correlacion.diametros<-cor.test(resumen.pinsapo$Dif.DN,
                                resumen.pinsapo$Npies_parc,
                                method="spearman")

#Correlación entre los diámetros y las densidades
correlacion.diametros$estimate

#Significancia de la correlación entre las alturas y las densidades
correlacion.diametros$p.value

#Visualizacion de los datos
plot(0,0,col = "white",
     xlim=c(80,900),ylim=c(0,21),main="Crecimientos.Todas las especies",
     xlab="dap (mm)", ylab="altura (m)")
segments(Pies.monte.IFN$DN.IFN3,Pies.monte.IFN$HT,
         Pies.monte.IFN$DN.IF2,Pies.monte.IFN$HT.IFN2,
         col=rgb(0,0,0,0.35))

plot(0,0,col = "white",
     xlim=c(80,900),ylim=c(0,21),main="Crecimientos.Todas las especies",
     xlab="dap (mm)", ylab="altura (m)")
#Especie 021="Pinus sylvestris"
segments(Pies.monte.IFN$DN.IFN3[which(Pies.monte.IFN$ESPECIE.x=="021")], 
         Pies.monte.IFN$HT[which(Pies.monte.IFN$ESPECIE.x=="021")],
         Pies.monte.IFN$DN.IF2[which(Pies.monte.IFN$ESPECIE.x=="021")],
         Pies.monte.IFN$HT.IFN2[which(Pies.monte.IFN$ESPECIE.x=="021")],
         col="red")
#Especie 024="Pinus halepensis"
segments(Pies.monte.IFN$DN.IFN3[which(Pies.monte.IFN$ESPECIE.x=="024")], 
         Pies.monte.IFN$HT[which(Pies.monte.IFN$ESPECIE.x=="024")],
         Pies.monte.IFN$DN.IF2[which(Pies.monte.IFN$ESPECIE.x=="024")],
         Pies.monte.IFN$HT.IFN2[which(Pies.monte.IFN$ESPECIE.x=="024")],
         col="green")
#Especie 026="Pinus pinaster"
segments(Pies.monte.IFN$DN.IFN3[which(Pies.monte.IFN$ESPECIE.x=="026")],
         Pies.monte.IFN$HT[which(Pies.monte.IFN$ESPECIE.x=="026")],
         Pies.monte.IFN$DN.IF2[which(Pies.monte.IFN$ESPECIE.x=="026")],
         Pies.monte.IFN$HT.IFN2[which(Pies.monte.IFN$ESPECIE.x=="026")],
         col="black")
#Especie 032="Abies pinsapo"
segments(Pies.monte.IFN$DN.IFN3[which(Pies.monte.IFN$ESPECIE.x=="032")],
         Pies.monte.IFN$HT[which(Pies.monte.IFN$ESPECIE.x=="032")],
         Pies.monte.IFN$DN.IF2[which(Pies.monte.IFN$ESPECIE.x=="032")],
         Pies.monte.IFN$HT.IFN2[which(Pies.monte.IFN$ESPECIE.x=="032")],
         col="blue")
legend("bottomright",legend=c("Pinus sylvestris","Pinus halepensis",
                              "Pinus pinaster","Abies pinsapo"),
       col=c("red","green","black","blue"),lty=c(1,1,1,1),cex=0.75,
       box.lty=0)

plot(0,0,col = "white",
     xlim=c(80,900),ylim=c(0,21),main="Crecimientos.Pinsapo",
     xlab="dap (mm)", ylab="altura (m)")
segments(pinsapo$DN.IFN3,pinsapo$HT,
         pinsapo$DN.IF2,pinsapo$HT.IFN2,
         col=rgb(0,0,0,0.35))

#Los datos contando historias
st_write(st_zm(Pinar.Yunquera),"C:/DESCARGA/Pinar.Yunquera.shp") #Adaptar a la ruta que se vaya a emplear en el equipo

pinsapo<-pinsapo[,c(1,2,70:105)]

st_write(pinsapo,"C:/DESCARGA/pinsapo.shp") #Adaptar a la ruta que se vaya a emplear en el equipo

st_write(resumen.pinsapo,"C:/DESCARGA/resumen.pinsapo.shp") #Adaptar a la ruta que se vaya a emplear en el equipo
