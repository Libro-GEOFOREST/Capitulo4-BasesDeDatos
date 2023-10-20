library(shiny)
library(shinydashboard)
library(mapview)
library(leaflet)
library(sf)

Pinar.Yunquera<-st_read("C:/DESCARGA/Pinar.Yunquera.shp")

pinsapo<-st_read("C:/DESCARGA/pinsapo.shp")

resumen.pinsapo<-st_read("C:/DESCARGA/resumen.pinsapo.shp")

ui <- dashboardPage(
  dashboardHeader(title = "Análisis de datos del IFN en Pinar de Yunquera",
                  titleWidth =500),
  dashboardSidebar(disable = TRUE),
  dashboardBody(
    #Gráficos del dashboard
    box(title = "Distribución de crecimiento en DN",
        solidHeader = TRUE,status = "primary",
        leafletOutput("mapa", height = 380)),
    box(title = "Distribución de crecimiento en H",
        solidHeader = TRUE,status = "primary",
        leafletOutput("mapa2", height = 380)),
    box(title = "Distribución de densidades",
        solidHeader = TRUE,status = "primary",
        leafletOutput("mapa3", height = 380)),
    box(title = "Relaciones alométricas DN/H según densidad",
        solidHeader = TRUE,status = "primary",
        plotOutput("plot1", height = 380)),
  )
)

server <- function(input, output) {

  output$mapa <- renderLeaflet({
    a<-mapview(Pinar.Yunquera)+mapview(resumen.pinsapo,zcol = "Dif_DN")
    a@map
    
  })
  output$mapa2 <- renderLeaflet({
    b<-mapview(Pinar.Yunquera)+mapview(resumen.pinsapo,zcol = "Dif_H")
    b@map
    
  })
  output$mapa3 <- renderLeaflet({
    c<-mapview(Pinar.Yunquera)+mapview(resumen.pinsapo,zcol = "Nps_prc")
    c@map
    
  })
  output$plot1 <- renderPlot({
    plot(0,0,col = "white",
         xlim=c(80,900),ylim=c(0,21),main="Crecimientos.Pinsapo",
         xlab="dap (mm)", ylab="altura (m)")
    segments(pinsapo$DN_IFN3[which(pinsapo$Dif_DN<20)],
             pinsapo$HT[which(pinsapo$Dif_DN<20)],
             pinsapo$DN_IF2[which(pinsapo$Dif_DN<20)],
             pinsapo$HT_IFN2[which(pinsapo$Dif_DN<20)],
             col="orange")
    segments(pinsapo$DN_IFN3[which(pinsapo$Dif_DN>=20&pinsapo$Dif_DN<50)],
             pinsapo$HT[which(pinsapo$Dif_DN>=20&pinsapo$Dif_DN<50)],
             pinsapo$DN_IF2[which(pinsapo$Dif_DN>=20&pinsapo$Dif_DN<50)],
             pinsapo$HT_IFN2[which(pinsapo$Dif_DN>=20&pinsapo$Dif_DN<50)],
             col="red")
    segments(pinsapo$DN_IFN3[which(pinsapo$Dif_DN>=50)],
             pinsapo$HT[which(pinsapo$Dif_DN>=50)],
             pinsapo$DN_IF2[which(pinsapo$Dif_DN>=50)],
             pinsapo$HT_IFN2[which(pinsapo$Dif_DN>=50)],
             col="brown")
    legend("bottomright",legend=c("Crecimiento DN < 20 mm","20 mm < Crecimiento DN < 50 mm",
                                  "Crecimiento DN > 50 mm"),
           col=c("orange","red","brown"),lty=c(1,1,1),cex=0.75,
           box.lty=0)
  })
}



# Run the application 
shinyApp(ui = ui, server = server)
