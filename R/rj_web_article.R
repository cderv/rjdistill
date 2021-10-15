#' @export
rjournal_web_article <- function(toc = FALSE, self_contained = FALSE, ...) {
  args <- c()

  rmd_path <- NULL

  post_knit <- function(metadata, input_file, runtime, ...) {
    # save Rmd path for later use
    rmd_path <<- input_file

    NULL
  }

  pre_processor <- function(metadata, input_file, runtime, knit_meta, files_dir,
                            output_dir) {

    # Add custom appendix
    data <- list()
    if (!is.null(metadata$supplementary_materials)) {
      data <- c(data, list(supp = metadata$supplementary_materials))
    }
    if (!is.null(metadata$CTV)) {
      CTV <- sprintf("[%s](https://cran.r-project.org/view=%s)", metadata$CTV, metadata$CTV)
      CTV <- paste(CTV, collapse = ", ")
      data <- c(data, list(CTV = CTV))
    }
    if (!is.null(metadata$packages)) {
      if (!is.null(metadata$packages$cran)) {
        CRAN <- sprintf("[%s](https://cran.r-project.org/package=%s)", metadata$packages$cran, metadata$packages$cran)
        CRAN <- paste(CRAN, collapse = ", ")
        data <- c(data, list(CRAN = CRAN))
      }
      if (!is.null(metadata$packages$bioc)) {
        BIOC <- sprintf("[%s](https://www.bioconductor.org/packages/%s)", metadata$packages$bioc, metadata$packages$bioc)
        BIOC <- paste(BIOC, collapse = ", ")
        data <- c(data, list(BIOC = BIOC))
      }
    }

    template <- xfun::read_utf8(system.file("appendix.md", package = "rjdistill"))
    appendix <- whisker::whisker.render(template, data)

    input <- xfun::read_utf8(input_file)
    xfun::write_utf8(c(input, "", appendix), input_file)
    # Custom args
    args <- rmarkdown::pandoc_include_args(in_header = system.file("rjdistill.html", package = "rjdistill"))

    args
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
    pre_processor = pre_processor,
    post_processor = post_processor,
    base_format = distill::distill_article(
      self_contained = self_contained,
      toc = toc,
      ...)
  )
}
