#Consultar el directorio de trabajo
getwd()

#Establecer el directorio de trabajo
setwd("C:/DESCARGA/") #Adaptar a la ruta que se vaya a emplear en el equipo

#Descarga de informacion geografica desde url
url<-"http://www.juntadeandalucia.es/medioambiente/portal_web/web/temas_ambientales/montes/gestion_forestal_sostenible/static_files/catmalaga.kml"
download.file(url,destfile="Montes_Publicos_Malaga.kml")

#Instalación y activación del paquete para la lectura de la capa kml
# install.packages("sf")
library(sf)

#Descripción de la capa kml
st_layers("Montes_Publicos_Malaga.kml")

#Lectura de la capa kml
Montes.Publicos<-st_read("Montes_Publicos_Malaga.kml")
Montes.Publicos

plot(Montes.Publicos[which(Montes.Publicos$Name=="MA-30037-AY"),1],
     main="Monte Pinar de Yunquera y Sierra Blanquilla",
     axes=TRUE)

Pinar.Yunquera<-MA.30037.AY[1,]
plot(Pinar.Yunquera[,1], main="Monte Pinar de Yunquera", axes=TRUE)

MA.30037.AY<-Montes.Publicos[which(Montes.Publicos$Name=="MA-30037-AY"),1]

#Dirección wms
wms_orto<-"http://www.ign.es/wms/pnoa-historico?"

#Instalación y activación del paquete para realizar mapas interactivos 
# install.packages("leaflet")
library(leaflet)

m.orto = leaflet(st_zm(Pinar.Yunquera)) %>% 
  setView(-4.95,36.73,12) %>%
  addWMSTiles(wms_orto,
              layers="PNOA2008",
              options=WMSTileOptions(format="image/png",transparent = TRUE)) %>%
    addPolygons()
m.orto 

m.esri = leaflet(st_zm(Pinar.Yunquera)) %>% 
  setView(-4.95,36.73,12) %>%
  addTiles()%>% 
  addProviderTiles("Esri.WorldImagery") %>%
  addPolygons()
m.esri

library(raster)
MDT<-raster("PNOA_MDT05_ETRS89_HU30_1051_LID.asc")

summary(MDT)

MDT

crs(MDT)<-"+proj=utm +zone=30 +ellps=GRS80 +units=m +no_defs"
MDT

Pinar.Yunquera.t<-st_transform(Pinar.Yunquera,crs=st_crs(MDT))

plot(MDT, main="Modelo Digital del Terreno")
plot(st_geometry(Pinar.Yunquera.t[,1]),add=TRUE)

MDT.recorte<-crop(MDT,extent(Pinar.Yunquera.t[,1]))
plot(MDT.recorte)
plot(st_geometry(Pinar.Yunquera.t[,1]),add=TRUE)

m.MDT = leaflet(st_zm(Pinar.Yunquera)) %>% 
  setView(-4.95,36.73,12) %>%
  addTiles()%>% 
  addPolygons()%>%
  addRasterImage(MDT.recorte, project = TRUE)
m.MDT
