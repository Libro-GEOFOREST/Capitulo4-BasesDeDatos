# Capitulo4-BasesDeDatos

Se va a trabajar con el monte público Pinar de Yunquera, con código MA-30037-AY. Se trata de un monte de unas 2.000 ha de titularidad pública, perteneciente al Ayuntamiento de Yunquera y cuya gestión ha venido realizando la Consejería de Medio Ambiente de la Junta de Andalucía. Está localizado en el interior del Parque Nacional Sierra de las Nieves y contiene una variedad florística de incalculable valor.

## 1. ACCESO A BASES DE DATOS CARTOGRÁFICAS

### 1.1. Mapas

Primero, se va a proceder a descargar la capa de Montes Públicos de Málaga que contiene los límites del monte con el que se va a trabajar Pinar de Yunquera, con código MA-30037-AY. Para ello, es necesario establecer el directorio de trabajo donde se van a realizar las descargas. Para saber cuál es y cambiarlo si lo consideramos oportuno, es necesario ejecutar el código:

```r
#Consultar el directorio de trabajo
getwd()
```

Se establece un nuevo directorio de trabajo que va a involucrar únicamente a los archivos del presente capítulo:

```r
#Establecer el directorio de trabajo
setwd("D:/MOOC_BBDD")
```

Seguidamente, se descargan los límites del monte.

```{r eval=FALSE}
#Descarga de informacion geografica desde url
url<-"http://www.juntadeandalucia.es/medioambiente/portal_web/web/temas_ambientales/montes/gestion_forestal_sostenible/static_files/catmalaga.kml"
download.file(url,destfile="Montes_Publicos_Malaga.kml")
```

En el directorio de trabajo establecido deberá observarse un nuevo archivo con el nombre Montes_Publicos_Malaga.kml

Para visualizar el archivo, primero se necesita el paquete sf, que permite representar entidades simples como registros en un data.frame de R con una columna de lista de geometrías.

```{r warning=FALSE}
#Instalación y activación del paquete para la lectura de la capa kml
# install.packages("sf")
library(sf)
```

Para conocer qué contiene la capa kml que se ha descargado anteriormente, se emplea la siguiente función:

```{r warning=FALSE}
#Descripción de la capa kml
st_layers("Montes_Publicos_Malaga.kml")
```

El resultado está indicando que la capa la componen 564 entidades, es decir, 564 polígonos de montes públicos.

Seguidamente se va a leer la capa

```{r warning=FALSE}
#Lectura de la capa kml
Montes.Publicos<-st_read("Montes_Publicos_Malaga.kml")
Montes.Publicos
```

La capa recoge los códigos de los montes a través del campo *Name*. El monte sobre el que se está trabajando se conoce como **Pinar de Yunquera y Sierra Blanquilla** y recibe la codificación *MA-30037-AY*, con lo que podemos seleccionar la zona de estudio así:

```{r warning=FALSE}
MA.30037.AY<-Montes.Publicos[which(Montes.Publicos$Name=="MA-30037-AY"),1]
```

Y visualizarlo en un mapa de la siguiente forma:

```{r warning=FALSE}
plot(Montes.Publicos[which(Montes.Publicos$Name=="MA-30037-AY"),1],
     main="Monte Pinar de Yunquera y Sierra Blanquilla",
     axes=TRUE)
```

Como se puede apreciar en el mapa, la ordenación se compuso por dos montes: **Pinar de Yunquera** y **Sierra Blanquilla**. La práctica, sin embargo, se va a centrar en la zona donde se encuentran las poblaciones de *Abies pinsapo*, que se localizan en **Pinar de Yunquera** por lo que se selecciona únicamente dicho territorio:

```{r warning=FALSE}
Pinar.Yunquera<-MA.30037.AY[1,]
plot(Pinar.Yunquera[,1], main="Monte Pinar de Yunquera", axes=TRUE)
```

------------------------------------------------------------------------

### 1.2. Ortofotos e imágenes

Para comprender mejor la zona de estudio, es necesario tener una imagen de referencia.

Una de las opciones es el empleo de un servicio wms (web map service) de ortofotografías que evita tener que descargar las imágenes, con el consecuente ahorro de tiempo y espacio.

El servicio de ortofotos de máxima actualidad del Plan Nacional de Ortofotografía Aérea (PNOA) permite la visualización de imágenes en mosaicos de distinta fecha de adquisición y distinta resolución (50 y 25 cm). El servicio muestra esos mosaicos según el estilo por defecto definido en Inspire. Los datos se actualizan periódicamente y sus actualizaciones se anuncian en el canal RSS del IGN (<http://www.ign.es/ign/rss>). El acceso o conexión a este servicio para obtener las funcionalidades para las que está pensado es gratuito en cualquier caso, siempre que se mencione la autoría del IGN como propietario del servicio y de su contenido.

Para visualizar el resultado con los datos de trabajo se ejecuta el siguiente código. En él se emplea la función *st_zm()* para borrar los valores de coordenada z que la componente *geometry* de la forma espacial guarda. Además se centra la vista del mapa sobre las coordenadas centrales del monte con la función *setView()*. Y finalmente, se hace la llamada a las imágenes de las ortofotografías históricas del año 2008, año en el que se realizó la ordenación del monte.

```{r warning=FALSE}
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
```

Cuando en la zona de trabajo no se disponen de imágenes u ortofografías servidas a través de wms, se puede visualizar el monte empleando alguna capa de la lista de proveedores. En este caso, como ejemplo, se ha seleccionado la imaginería mundial proporcinada por la empresa ESRI y que contiene imágenes satelitales y aéreas en todo el mundo. Los mapas incluyen imágenes TerraColor de 15 m para las escalas medias e imágenes de los satélites SPOT de 2.5 m para escalas mayores. En muchas partes del mundo se muestran imágenes submétricas de Maxar. También, en otras partes del mundo, la comunidad de usuarios de SIG ha contribuido con imágenes en diferentes resoluciones.

```{r warning=FALSE}
m.esri = leaflet(st_zm(Pinar.Yunquera)) %>% 
  setView(-4.95,36.73,12) %>%
  addTiles()%>% 
  addProviderTiles("Esri.WorldImagery") %>%
  addPolygons()
m.esri
```

------------------------------------------------------------------------

### 1.3. Otras fuentes cartográficas

A veces se hace necesario utilizar otras fuentes cartográficas, como es el caso de los Modelos Digitales del Terreno o el Mapa Topográfico Nacional. Ambos productos están disponibles a través del [Centro de Descargas del Centro Nacional de Información Geográfica](https://centrodedescargas.cnig.es/CentroDescargas/index.jsp#). En [este video de youtube](https://www.youtube.com/watch?v=2u88We_Zyzg) se explica la descarga de las fuentes cartográficas en cuatro sencillos pasos. ![IGN](D:/MOOC_BBDD/IGN.jpg)

Una vez obtenidos los productos, se cargan como variables dentro del entorno de R utilizando la librería *raster*.

```{r }
library(raster)
MDT<-raster("PNOA_MDT05_ETRS89_HU30_1051_LID.asc")

```

Con la función *summary* se consigue un resumen de las estadísticas de la capa: valores mínimos, máximos, mediada, cuartiles y, si existen valores sin datos, número de NA's

```{r warning=FALSE}
summary(MDT)
```

Y además se puede echar un vistazo a los atributos de la capa.

```{r }
MDT
```

Como se puede apreciar con el atributo *crs* (Coordinate Reference System) la capa carece de sistema de coordenadas de referencia. El sistema manejado por el IGN permite conocer el sistema de coordenadas que emplea el archivo descargado a través del nombre del mismo. Así se puede conocer que el modelo que se está empleando pertene al sistema de coordenadas locales ETRS89 UTM en la zona 30 Norte. Ésto se introduce en los argumentos de la siguiente manera:

```{r }
crs(MDT)<-"+proj=utm +zone=30 +ellps=GRS80 +units=m +no_defs"
MDT
```

Como se puede apreciar, el sistema de referencia del modelo del terreno descargado no coincide con el sistema de referencia del monte según se ha extraído de la capa kml. De ahí que sea necesario reproyectar la capa de límites del monte al sistema de coordenadas del MDT. 

```{r }
Pinar.Yunquera.t<-st_transform(Pinar.Yunquera,crs=st_crs(MDT))

plot(MDT, main="Modelo Digital del Terreno")
plot(st_geometry(Pinar.Yunquera.t[,1]),add=TRUE)
```

Emplear el modelo completo implica utilizar unas 60.000 hectáreas, lo que ralentiza los procesos en los que se vea involucrada dicha capa. Para agilizarlos, es recomendable recortar el modelo del terreno por la extensión que ocupa los límites del monte con el que se está trabajando.

```{r warning=FALSE}
MDT.recorte<-crop(MDT,extent(Pinar.Yunquera.t[,1]))
plot(MDT.recorte)
plot(st_geometry(Pinar.Yunquera.t[,1]),add=TRUE)
```

Y finalmente, podemos visualizarlo sobre un mapa dinámico para orientarse sobre el terreno.

```{r warning=FALSE}

m.MDT = leaflet(st_zm(Pinar.Yunquera)) %>% 
  setView(-4.95,36.73,12) %>%
  addTiles()%>% 
  addPolygons()%>%
  addRasterImage(MDT.recorte, project = TRUE)
m.MDT
```
