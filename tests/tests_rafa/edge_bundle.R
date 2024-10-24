library(flightsbr)
library(geobr)
library(edgebundle) # https://github.com/schochastics/edgebundle
library(igraph)
library(data.table)
# library(ggforce)
library(ggplot2)
library(janitor)
# https://mwallinger-tu.github.io/edge-path-bundling/


# Download data -----------------

# flight and airport data
airports <- flightsbr::read_airports(type = 'public')
flights <- flightsbr::read_flights(date = 2023)

# clean names
airports <- janitor::clean_names(airports)
flights <- janitor::clean_names(flights)

# Brazilian national borders
br <- geobr::read_country()


# Filter data -----------------

# Keep flights to and from airports in Brazil
flights2 <- subset(flights, nm_pais_origem   =="BRASIL")
flights2 <- subset(flights2, nm_pais_destino =="BRASIL")


# # flights from and to public airports
# flights2 <- subset(flights2, sg_icao_origem %in% airports$codigo_oaci |
#                              sg_icao_destino %in% airports$codigo_oaci)


# year of flight arrival
flights2[, year := nr_ano_chegada_real ]


# Summary number of flights and passengers by origin-destination pair -----------------

edges <- flights2[, .(n_flights = .N,
                      weight = .N,
                      n_passengers = sum(as.numeric(nr_passag_pagos))),
                  by = .(sg_icao_origem, sg_icao_destino)]



# Add spatial coordinates do edges -----------------

# airport at origins
edges[ airports,
       on=c('sg_icao_origem'='codigo_oaci'),
       c('lat_orig', 'lon_orig') := list(i.latitude , i.longitude) ]

# airport at destinations
edges[ airports, on=c('sg_icao_destino'='codigo_oaci'),
       c('lat_dest', 'lon_dest') := list(i.latitude , i.longitude) ]

head(edges)


# drop flights with airport missing info
edges <- subset(edges, sg_icao_origem != '' | sg_icao_destino  != '')
edges <- na.omit(edges)



### Build network -----------------

# vertices: all airports with trips
vert <- airports[,.(codigo_oaci, longitude, latitude)]
vert <- subset(vert, codigo_oaci %in% c(edges$sg_icao_origem, edges$sg_icao_destino))
vert <- unique(vert)


# build igraph network
g <- igraph::graph_from_data_frame(d = edges, directed = T, vertices = vert)

# coordinates of vertices
xy <- cbind(V(g)$longitude, V(g)$latitude)



### Edge undling -----------------
d = 16 # how much bending / max_distortion
w = 4
s = 20
# 12 4 20

# Edge-Path Bundling
pbundle <- edgebundle::edge_bundle_path(g, xy,
                                        max_distortion = d,
                                        weight_fac = w, #   E(g)$weight,
                                        segments = s)

### Figure -----------------
p <-
  ggplot() +
  geom_sf(data=br , fill='gray10', color=NA) +
  geom_path(data = pbundle, aes(x, y, group = group),
            col = "#9d0191", linewidth = 0.5, alpha=.1) +
  geom_path(data = pbundle, aes(x, y, group = group),
            col = "white", linewidth = 0.05, alpha=.1) +
  # ggraph::theme_graph(background = "gray")
  theme_classic() +
  theme(axis.line=element_blank(),
        axis.text=element_blank(),
        axis.ticks=element_blank(),
        axis.title=element_blank())
#p
ggsave(p, file=paste0('path-d',d,'-w',w,'-s',s ,'jan.png'), dpi=300)
beepr::beep()


