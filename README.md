# puremoe paper

Source and reproduction materials for *puremoe: A PMID-Centered R Interface
to PubMed and NIH/NLM Literature Data*, submitted to The R Journal.

The package: [CRAN](https://CRAN.R-project.org/package=puremoe) ·
[GitHub](https://github.com/jaytimm/puremoe). The article uses puremoe 1.1.1.

## Contents

- `rjournal/`: the R Journal article.
  - `timm.Rmd`: article source; `timm.tex`, `timm.pdf`: built article.
  - `data/puremoe-example.rds`: dated retrieval snapshot (2026-09-11).
  - `data/retrieval-audit.csv`: endpoint return counts for that snapshot.
  - `data/retrieval-sessionInfo.txt`, `data/render-sessionInfo.txt`: session
    information for the retrieval and for the article build.
  - `scripts/retrieve-data.R`: the complete live-retrieval script.
- `preprint/puremoe-preprint.pdf`: the same article in a generic preprint
  format.

## Reproducing the article

From `rjournal/`, run `rmarkdown::render("timm.Rmd", output_format = "all")`.
The article renders from the archived snapshot, so the reported counts do not
depend on the current state of PubMed, iCite, PubTator3, or PMC. See
`rjournal/scripts/README.md` for a fresh live retrieval, which can
legitimately differ because the upstream indexes change over time.
