rjournal_web_article <- function(...) {
  args <- c()

  rmarkdown::output_format(
    knitr = NULL, # use base one
    pandoc = list(
      args = args,
      lua_filters = system.file("latex-pkg.lua", package = "rjdistill")
    ),
    keep_md = NULL, # use base one
    clean_supporting = NULL, # use base one
    base_format = distill::distill_article(...)
  )
}
