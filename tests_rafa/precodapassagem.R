library(data.table)
library(flightsbr)
library(janitor)

# get latest month available
latest_date <- flightsbr::latest_airfares_date()
last_two_monts <- (latest_date-1):latest_date

# download data
df_dom <- flightsbr::read_airfares(date = last_two_monts) |>
  janitor::clean_names()

# head(df_dom)

# fix numeric columns
df_dom[, tarifa := gsub(',', '.', tarifa)]
df_dom[, tarifa := as.numeric(tarifa)]
df_dom[, assentos := as.numeric(assentos)]

        # # create unique id for each OD pair
        # df_dom[, id := .GRP, by = .(origem, destino)]
# create unique id for each OD pair
# so that A-B has the same id as B-A
# Sort each pair so that the smaller value is always the first
df_dom[, od_pair := paste0(pmin(origem, destino), "-", pmax(origem, destino))]
df_dom[, id := .GRP, by = od_pair]


# determine top 100 OD pairs
od_rank <- df_dom[, .(total_demand = sum(assentos)),
                  by = .(id, od_pair)][order(-total_demand)]

od_rank <- od_rank |>
  dplyr::slice_max(order_by = total_demand, n = 100) |>
  mutate( ranking = 1:100)

# filter raw data only for top 100 and bring raking column
df_dom_100 <- df_dom[ id %in% od_rank$id]
df_dom_100[od_rank, on='id', ranking := i.ranking]

# calculate reference values
df <- df_dom_100[, .(passageiros = sum(assentos),
                 minima = min(tarifa),
                 q25 = Hmisc::wtd.quantile(x = tarifa, weights=assentos,probs = 0.25),
                 media = weighted.mean(x = tarifa, w=assentos),
                 q75 = Hmisc::wtd.quantile(x = tarifa, weights=assentos,probs = 0.75),
                 maxima = max(tarifa)
                 ),
             by = .(id, ranking, origem, destino)][order(ranking)]


df100 <- df[, .(passageiros = sum(passageiros),
                 # minima = sum(minima),
                 q25 = sum(q25),
                 media = sum(media),
                 q75 = sum(q75)
                  #, maxima = sum(maxima)
                 ),
             by = .(id, ranking)][order(ranking)]


# bring OD pair info back
df100[df_dom_100, on='id', od_pair := i.od_pair ]
df100[, origem := substring(od_pair, 1, 4)]
df100[, destino := substring(od_pair, 6, 9)]

# add airport information
airports <- flightsbr::read_airports(type = 'public') |>
  janitor::clean_names() |>
  dplyr::select(c('codigo_oaci','municipio_atendido'))

head(airports)


df_airport_codes <- dplyr::tribble(
  ~oaci, ~iata,
  "SBAM",	"MCP",
  "SWYN",	NA,
  "SNAL",	"APQ",
  "SWBC",	"BAZ",
  "SWBI",	NA,
  "SBBE",	"BEL",
  "SBCF",	"CNF",
  "SBBH",	"PLU",
  "SBBV",	"BVB",
  "SWBR",	NA,
  "SWBS",	NA,
  "SBBR",	"BSB",
  "SBCD",	"CFC",
  "SNCC",	NA,
  "SBKP",	"VCP",
  "SDAM",	"CPQ",
  "SBMT",	NA,
  "SNRU",	"CAU",
  "SWCA",	"CAF",
  "SBCA",	"CAC",
  "SILQ",	NA,
  "SWKO",	"CIZ",
  "SBAA",	"CDJ",
  "SBCZ",	"CZS",
  "SBBI",	"BFH",
  "SBCT",	"CWB",
  "SWFJ",	"FEJ",
  "SWFN",	NA,
  "SBFL",	"FLN",
  "SBFZ",	"FOR",
  "SBFI",	"IGU",
  "SBZM",	"IZA",
  "SBGO",	"GYN",
  "SBGR",	"GRU",
  "SBIZ",	"IMP",
  "SBJE",	"JJD",
  "SBJV",	"JOI",
  "SBJP",	"JPA",
  "SBJF",	"JDF",
  "SBJD",	"QDV",
  "SBMQ",	"MCP",
  "SBEG",	"MAO",
  "SNML",	NA,
  "SBMO",	"MCZ",
  "SBMS",	"MVF",
  "SBNF",	"NVT",
  "SBSG",	"NAT",
  "SWNK",	NA,
  "SBOI",	NA,
  "SNOZ",	NA,
  "SWJV",	NA,
  "SBPB",	"PHB",
  "SNPE",	NA,
  "SSZW",	"PGZ",
  "SBPA",	"POA",
  "SNPG",	NA,
  "SBPV",	"PVH",
  "SBRF",	"REC",
  "SBRP",	"RAO",
  "SBRB",	"RBR",
  "SBRJ",	"SDU",
  "SBGL",	"GIG",
  "SBJR",	NA,
  "SBRD",	"ROO",
  "SBSM",	"RIA",
  "SDOE",	NA,
  "SBST",	"SSZ",
  "SBSV",	"SSA",
  "SDSC",	"QSC",
  "SBSL",	"SLZ",
  "SBSP",	"CGH",
  "SWSN",	"ZMD",
  "SDCO",	"SOD",
  "SWMU",	NA,
  "SBTT",	"TBT",
  "SBTK",	"TRQ",
  "SBTF",	"TFF",
  "SBTE",	"THE",
  "SBCY", "CGB", # cuiaba
  "SBPL", "PNZ", # petrolina
  "SBVT", "VIX", # vitoria
  "SBVC", "VDC", # vitoria da consquista
  "SBJU", "JDO", # juazeiro do norte
  "SBAR", "AJU", # aracaju
  "SBTS",	NA,
  "SNUN",	NA,
  "SWXU",	NA)

data.table::setDT(df_airport_codes)

airports[df_airport_codes, on=c('codigo_oaci'='oaci'), iata:= i.iata]


df100[airports,
   on=c('origem'='codigo_oaci'),
   c('orig_iata', 'orig_muni') := list(i.iata, i.municipio_atendido )]

df100[airports,
   on=c('destino'='codigo_oaci'),
   c('dest_iata', 'dest_muni') := list(i.iata, i.municipio_atendido )]

# reorganize origem and destino columns
df100[, De := paste0(orig_muni," (",orig_iata,")")]
df100[, Para := paste0(dest_muni," (",dest_iata,")")]

# round values
cols <- c('q25', 'media', 'q75')
df100 <- df100 |> mutate_at(cols, ~round(.,1))


# rename and reorder columns
df_output <- df100 |>
  select(ranking,
         De,
         Para,
         total_passageiros = passageiros,
         q25,
         media,
         q75
         )


quak::quak(df_output)

# proximos passos
- logo no começo, identificar pares de ida e volta
- gerar valor total de ida + volta
- gerar grafico da distribuiçao do valor

library(data.table)

dt <- data.table::CJ(letters[1:4], letters[1:4])
setnames(dt, c('origin', 'destination'))





