#' Standardise scientific names across datasets
#'
#' The functions takes a vector of scientific names and converts them to
#' scientific names from the master list for easy dataset joining.
#'
#' @param name Character vector of scientific names.
#'
#' @returns Character vector of standardised scientific names
#'
standardise_scientific_names <- function(name) {

  case_when(

    ### Mismatches from Tobias et al. (2016) -> master list

    name == "Amazona mercenaria"           ~ "Amazona mercenarius",
    name == "Aratinga acuticaudata"        ~ "Thectocercus acuticaudatus",
    name == "Aratinga aurea"               ~ "Eupsittula aurea",
    name == "Aratinga brevipes"            ~ "Psittacara brevipes",
    name == "Aratinga cactorum"            ~ "Eupsittula cactorum",
    name == "Aratinga canicularis"         ~ "Eupsittula canicularis",
    name == "Aratinga chloroptera"         ~ "Psittacara chloropterus",
    name == "Aratinga erythrogenys"        ~ "Psittacara erythrogenys",
    name == "Aratinga euops"               ~ "Psittacara euops",
    name == "Aratinga finschi"             ~ "Psittacara finschi",
    name == "Aratinga holochlora"          ~ "Psittacara holochlorus",
    name == "Aratinga leucophthalma"       ~ "Psittacara leucophthalmus",
    name == "Aratinga mitrata"             ~ "Psittacara mitratus",
    name == "Aratinga nana"                ~ "Eupsittula nana",
    name == "Aratinga pertinax"            ~ "Eupsittula pertinax",
    name == "Aratinga pintoi"              ~ "Aratinga maculata",
    name == "Aratinga strenua"             ~ "Psittacara strenuus",
    name == "Aratinga wagleri"             ~ "Psittacara wagleri",
    name == "Calyptorhynchus baudinii"     ~ "Zanda baudinii",
    name == "Calyptorhynchus funereus"     ~ "Zanda funerea",
    name == "Calyptorhynchus latirostris"  ~ "Zanda latirostris",
    name == "Chalcopsitta cardinalis"      ~ "Pseudeos cardinalis",
    name == "Charmosyna amabilis"          ~ "Vini amabilis",
    name == "Charmosyna diadema"           ~ "Vini diadema",
    name == "Charmosyna margarethae"       ~ "Charmosynoides margarethae",
    name == "Charmosyna meeki"             ~ "Vini meeki",
    name == "Charmosyna multistriata"      ~ "Synorhacma multistriata",
    name == "Charmosyna palmarum"          ~ "Vini palmarum",
    name == "Charmosyna placentis"         ~ "Hypocharmosyna placentis",
    name == "Charmosyna pulchella"         ~ "Charmosynopsis pulchella",
    name == "Charmosyna rubrigularis"      ~ "Vini rubrigularis",
    name == "Charmosyna rubronotata"       ~ "Hypocharmosyna rubronotata",
    name == "Charmosyna toxopei"           ~ "Charmosynopsis toxopei",
    name == "Charmosyna wilhelminae"       ~ "Charminetta wilhelminae",
    name == "Eos rubra"                    ~ "Eos bornea",
    name == "Glossopsitta porphyrocephala" ~ "Parvipsitta porphyrocephala",
    name == "Glossopsitta pusilla"         ~ "Parvipsitta pusilla",
    name == "Guarouba guarouba"            ~ "Guaruba guarouba",
    name == "Lophochroa leadbeateri"       ~ "Cacatua leadbeateri",
    name == "Nandayus nenday"              ~ "Aratinga nenday",
    name == "Orthopsittaca manilata"       ~ "Orthopsittaca manilatus",
    name == "Phigys solitarius"            ~ "Vini solitaria",
    name == "Psephotus chrysopterygius"    ~ "Psephotellus chrysopterygius",
    name == "Psephotus dissimilis"         ~ "Psephotellus dissimilis",
    name == "Psephotus varius"             ~ "Psephotellus varius",
    name == "Psittacula calthropae"        ~ "Psittacula calthrapae",
    name == "Psitteuteles goldiei"         ~ "Glossoptilus goldiei",
    name == "Psitteuteles iris"            ~ "Saudareos iris",
    name == "Strigops habroptila"          ~ "Strigops habroptilus",
    name == "Trichoglossus flavoviridis"   ~ "Saudareos flavoviridis",
    name == "Trichoglossus johnstoniae"    ~ "Saudareos johnstoniae",
    name == "Trichoglossus ornatus"        ~ "Saudareos ornata",

    ### Additional mismatches from Beauchamp (2024) -> master list

    name == "Alexandrinus eques"           ~ "Psittacula eques",
    name == "Alexandrinus krameri"         ~ "Psittacula krameri",
    name == "Belocercus longicaudus"       ~ "Psittacula longicauda",
    name == "Himalayapsitta cyanocephala"  ~ "Psittacula cyanocephala",
    name == "Himalayapsitta finschii"      ~ "Psittacula finschii",
    name == "Himalayapsitta himalayana"    ~ "Psittacula himalayana",
    name == "Himalayapsitta roseata"       ~ "Psittacula roseata",
    name == "Nicopsitta columboides"       ~ "Psittacula columboides",
    name == "Palaeornis eupatria"          ~ "Psittacula eupatria",
    name == "Trichoglossus iris"           ~ "Saudareos iris",

    ### Additional mismatches in Krasheninnikova et al. (2024) -> master list

    name == "Psittacara acuticaudatus"     ~ "Thectocercus acuticaudatus",
    name == "Trichoglossus meyeri"         ~ "Saudareos meyeri",

    ### Additional mismatches in Carballo et al. (2020) -> master list

    name == "Ara chloroptera"              ~ "Ara chloropterus",

    ### Additional mismatches in Hooper et al. (2022) -> master list

    name == "Agapornis pullaria"           ~ "Agapornis pullarius",
    name == "Agapornis swinderiana"        ~ "Agapornis swindernianus",
    name == "Anodorhynchus hyacinthus"     ~ "Anodorhynchus hyacinthinus",
    name == "Ara ambigua"                  ~ "Ara ambiguus",
    name == "Ara severa"                   ~ "Ara severus",
    name == "Aratinga leucopthalmus"       ~ "Psittacara leucophthalmus",
    name == "Brotogeris chrysopterus"      ~ "Brotogeris chrysoptera",
    name == "Cacatua roseicapilla"         ~ "Eolophus roseicapilla",
    name == "Calyptorhynchus lathamii"     ~ "Calyptorhynchus lathami",
    name == "Graydidasculus brachyurus"    ~ "Graydidascalus brachyurus",
    name == "Pionites melanocephala"       ~ "Pionites melanocephalus",
    name == "Pionopsitta barrabandi"       ~ "Pyrilia barrabandi",
    name == "Pionopsitta caica"            ~ "Pyrilia caica",
    name == "Pionopsitta haematotis"       ~ "Pyrilia haematotis",
    name == "Pionus maximilliani"          ~ "Pionus maximiliani",
    name == "Poicephalus guliemi"          ~ "Poicephalus gulielmi",
    name == "Propyrrhura auricollis"       ~ "Primolius auricollis",
    name == "Propyrrhura maracana"         ~ "Primolius maracana",
    name == "Purpuriecephalus varius"      ~ "Purpureicephalus spurius",
    name == "Tanygnathus megalorhynchus"   ~ "Tanygnathus megalorynchos",
    name == "Touit purpurata"              ~ "Touit purpuratus",

    ### Additional mismatches in Tsuboi et al. (2018) -> master list

    name == "Chalcopsitta sintillata"      ~ "Chalcopsitta scintillata",
    name == "Trichoglossus rubritorquatus" ~ "Trichoglossus rubritorquis",

    ### If none of the above, fall back to original name

    TRUE ~ name

  )

}
