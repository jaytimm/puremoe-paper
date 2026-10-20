# Build the puremoe preprint with the shared preprint style.
# Run from this directory: Rscript build-preprint.R

source("~/Dropbox/working-papers/preprint-style/preprint.R")

rjournal <- normalizePath("../rjournal")
src <- readLines(file.path(rjournal, "timm.Rmd"), warn = FALSE)

# Abstract from the R Journal YAML; body after the YAML.
yaml_end <- which(src == "---")[2]
a_start <- grep("^abstract:", src)[1]
a_end <- a_start
while (grepl("^  ", src[a_end + 1L])) a_end <- a_end + 1L
abstract <- trimws(src[(a_start + 1L):a_end])
body <- src[(yaml_end + 1L):length(src)]

# Route the article's journal_kable() calls to the shared table style:
# font sizes are ignored and cm widths become relative widths.
setup_end <- which(body == "```")[1]
override <- c(
  "",
  "```{r preprint-tables, include=FALSE}",
  'source("~/Dropbox/working-papers/preprint-style/preprint.R")',
  "journal_kable <- function(x, caption = NULL, align = NULL, widths = NULL,",
  "                          wide = FALSE, hold = FALSE, font_size = NULL) {",
  "  if (!is.null(widths)) widths <- as.numeric(sub(\"cm$\", \"\", widths))",
  "  preprint_kable(x, caption = caption, widths = widths, align = align)",
  "}",
  "```"
)
body <- append(body, override, after = setup_end)

render_preprint(
  body,
  output_file = "puremoe-preprint.pdf",
  title = "puremoe: A PMID-Centered R Interface to PubMed and NIH/NLM Literature Data",
  author = c("Jason Timm", "University of New Mexico Health Sciences",
             "Albuquerque, New Mexico, USA"),
  abstract = abstract,
  keywords = c("PubMed", "MeSH", "PubTator3", "citation networks",
               "literature retrieval", "R"),
  note = "*Preprint. Submitted to The R Journal.*",
  back_matter = list(
    "Software and Data Availability" = c(
      "puremoe 1.1.1 is available from CRAN",
      "(<https://CRAN.R-project.org/package=puremoe>); the source repository is",
      "<https://github.com/jaytimm/puremoe>. The article's reproduction",
      "materials comprise the dated retrieval snapshot (2026-09-11), the",
      "complete live-retrieval script, an endpoint return audit, and session",
      "information. All reported tables and figures render from the snapshot",
      "without contacting the upstream services. The article source and",
      "these materials are available at",
      "<https://github.com/jaytimm/puremoe-paper>."
    ),
    "Statement on the use of generative AI" = c(
      "Anthropic Claude Code was used to review and debug package and article",
      "code and to assist with manuscript revision and formatting. The author",
      "reviewed all generated output and takes full responsibility for the",
      "content."
    ),
    "Competing interests" = "The author has no competing interests to declare.",
    "Authors' contributions" = c(
      "The author developed the package, designed and conducted the worked",
      "example, and wrote and revised the manuscript."
    )
  ),
  bibliography = file.path(rjournal, "timm.bib"),
  knit_root_dir = rjournal
)
