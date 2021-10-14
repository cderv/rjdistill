#' @export
rjournal_web_article <- function(...) {
  args <- c()

  rmd_path <- NULL

  post_knit <- function(metadata, input_file, runtime, ...) {
    rmd_path <<- input_file
    NULL
  }

  post_processor <- function(metadata, input_file, output_file, clean, verbose) {
    if (!is.null(metadata$type)) {
      callr::r(function(input){
        rmarkdown::render(
          input,
          # output_format = "rticles::rjournal_article",
          output_format = "rjdistill::rjournal_pdf_article"
        )
      }, args = list(input = rmd_path))
    }
    # return output file unchanged
    output_file
  }

  rmarkdown::output_format(
    knitr = NULL, # use base one
    pandoc = list(
      args = args,
      lua_filters = system.file("latex-pkg.lua", package = "rjdistill")
    ),
    keep_md = NULL, # use base one
    clean_supporting = NULL, # use base one
    post_knit = post_knit,
    post_processor = post_processor,
    base_format = distill::distill_article(theme = theme, ...)
  )
}
