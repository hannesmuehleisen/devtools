#' Build windows binary package.
#'
#' This function works by bundling source package, and then uploading to
#' \url{http://win-builder.r-project.org/}.  Once building is complete you'll
#' receive a link to the built package in the email address listed in the
#' maintainer field.  It usually takes around 30 minutes. As a side effect,
#' win-build also runs \code{R CMD check} on the package, so \code{build_win}
#' is also useful to check that your package is ok on windows.
#'
#' @param pkg package description, can be path or package name.  See
#'   \code{\link{as.package}} for more information
#' @param args Any additional arguments to pass to \code{\link[pkgbuild]{build}}
#' @param quiet If \code{TRUE}, suppresses outut.
#' @param version directory to upload to on the win-builder, controlling
#'   which version of R is used to build the package. Possible options are
#'   listed on \url{http://win-builder.r-project.org/}. Defaults to R-devel.
#' @export
#' @family build functions
build_win <- function(pkg = ".", version = c("R-release", "R-devel"),
                      args = NULL, quiet = FALSE) {
  pkg <- as.package(pkg)

  if (missing(version)) {
    version <- "R-devel"
  } else {
    version <- match.arg(version, several.ok = TRUE)
  }

  if (!quiet) {
    message("Building windows version of ", pkg$package,
            " for ", paste(version, collapse = ", "),
            " with win-builder.r-project.org.\n")
    if (interactive() && yesno("Email results to ", maintainer(pkg)$email, "?")) {
      return(invisible())
    }
  }

  built_path <- pkgbuild::build(pkg$path, tempdir(), args = args, quiet = quiet)
  on.exit(unlink(built_path))

  url <- paste0("ftp://win-builder.r-project.org/", version, "/",
                basename(built_path))
  lapply(url, upload_ftp, file = built_path)

  if (!quiet) {
    message("[", strftime(Sys.time(), "%I:%M %p (%Y-%m-%d)"), "] ",
            "Check ", maintainer(pkg)$email, " for a link to the built package",
            if (length(version) > 1) "s" else "",
            " in 15-30 mins.")
  }

  invisible()
}
