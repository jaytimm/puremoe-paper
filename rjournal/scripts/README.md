# Reproducing the article

The article renders from the archived retrieval snapshot by default, so the
reported counts do not depend on the current state of PubMed, iCite,
PubTator3, or PMC.

1. Install the packages listed in `_Rpackages.txt`.
2. From this directory, run
   `rmarkdown::render("timm.Rmd", output_format = "all")`.
3. To replace the dated snapshot with a current live retrieval, first run
   `Rscript scripts/retrieve-data.R`, then render the article again. To execute
   remote retrieval inside the article itself, render with the environment
   variable `PUREMOE_LIVE_RETRIEVAL=true`.

The retrieval script records the package and R versions, platform, retrieval
date, worker count, API-key status, endpoint return counts, and retrieval-session
information in `data/retrieval-sessionInfo.txt`. The submitted archive also
contains `data/render-sessionInfo.txt`, which records the environment used for
the final local workflows and render. A fresh live retrieval can legitimately
differ from the archived article because the upstream indexes and annotations
change over time.
