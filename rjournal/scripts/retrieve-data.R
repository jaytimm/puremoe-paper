#!/usr/bin/env Rscript

# Retrieve the changing upstream records used by the article and save one
# dated, inspectable snapshot. The article renders from this file by default;
# set PUREMOE_LIVE_RETRIEVAL=true to exercise the same calls during rendering.

library(puremoe)

retrieval_date <- Sys.Date()
query <- 'buprenorphine[Title] AND "opioid use disorder"[Title]'
pmids <- puremoe::search_pubmed(query)

abstracts <- puremoe::get_records(
  pmids,
  endpoint = "pubmed_abstracts",
  cores = 3L,
  sleep = 1.05
)
icites <- puremoe::get_records(
  pmids,
  endpoint = "icites",
  cores = 3L,
  sleep = 0.25
)
pubtator <- puremoe::get_records(
  pmids,
  endpoint = "pubtator",
  cores = 3L,
  sleep = 0.34
)

mesh_thesaurus <- puremoe::data_mesh_thesaurus()
mesh_trees <- puremoe::data_mesh_trees()

# The article needs the complete term records only for MeSH identifiers present
# in this PubTator corpus, plus the two descriptors used in the vocabulary
# example. Keeping that dated subset makes the submission self-contained while
# avoiding a redundant copy of the full package data in the article archive.
mesh_examples <- c("Buprenorphine", "Opioid-Related Disorders")
corpus_mesh_ui <- unique(sub(
  "^MESH:", "",
  as.character(pubtator$entities$identifier)
))
corpus_mesh_ui <- corpus_mesh_ui[grepl("^[CD][0-9]+$", corpus_mesh_ui)]
mesh_thesaurus <- mesh_thesaurus[
  mesh_thesaurus$DescriptorUI %in% corpus_mesh_ui |
    mesh_thesaurus$DescriptorName %in% mesh_examples,
  , drop = FALSE
]
mesh_trees <- mesh_trees[
  mesh_trees$DescriptorName %in% mesh_examples,
  , drop = FALSE
]

snowball <- puremoe::citation_snowball(
  icites,
  direction = "both",
  min_links = 2L,
  max_nodes = 2000L
)
expansion_metadata <- puremoe::get_records(
  snowball$pmid,
  endpoint = "pubmed_abstracts",
  cores = 3L,
  sleep = 1.05
)

pmc_probe_pmids <- head(pmids, 20L)
pmc_map <- puremoe::pmid_to_ftp(pmc_probe_pmids, verbose = FALSE)
fulltext_urls <- head(pmc_map$url, 3L)
fulltext <- puremoe::get_records(
  fulltext_urls,
  endpoint = "pmc_fulltext",
  cores = 1L
)

returned_pubtator_pmids <- unique(c(
  as.character(pubtator$entities$pmid),
  as.character(pubtator$relations$pmid)
))
retrieval_audit <- data.frame(
  endpoint = c("pubmed_abstracts", "icites", "pubtator"),
  requested = length(pmids),
  returned = c(
    length(unique(as.character(abstracts$pmid))),
    length(unique(as.character(icites$pmid))),
    length(returned_pubtator_pmids)
  ),
  stringsAsFactors = FALSE
)
retrieval_audit$missing <- retrieval_audit$requested - retrieval_audit$returned

snapshot_metadata <- list(
  retrieval_date = retrieval_date,
  created_at = Sys.time(),
  r_version = R.version.string,
  platform = R.version$platform,
  puremoe_version = as.character(utils::packageVersion("puremoe")),
  cores = 3L,
  ncbi_api_key_used = nzchar(Sys.getenv("ENTREZ_KEY")),
  options = options()[intersect(
    names(options()),
    c("puremoe.icite_timeout", "timeout")
  )],
  session_info = utils::sessionInfo()
)

snapshot <- list(
  retrieval_date = retrieval_date,
  query = query,
  pmids = pmids,
  abstracts = abstracts,
  icites = icites,
  pubtator = pubtator,
  mesh_thesaurus = mesh_thesaurus,
  mesh_trees = mesh_trees,
  snowball = snowball,
  expansion_metadata = expansion_metadata,
  pmc_probe_pmids = pmc_probe_pmids,
  pmc_map = pmc_map,
  fulltext_urls = fulltext_urls,
  fulltext = fulltext,
  retrieval_audit = retrieval_audit,
  snapshot_metadata = snapshot_metadata
)

dir.create("data", showWarnings = FALSE, recursive = TRUE)
saveRDS(snapshot, "data/puremoe-example.rds", compress = "xz")
writeLines(
  capture.output(snapshot_metadata$session_info),
  "data/retrieval-sessionInfo.txt"
)
utils::write.csv(retrieval_audit, "data/retrieval-audit.csv", row.names = FALSE)

print(retrieval_audit)
message("Saved data/puremoe-example.rds using puremoe ",
        snapshot_metadata$puremoe_version, " on ", retrieval_date, ".")
