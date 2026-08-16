
# GitHub release process
#
# Run this file line by line from the package root. Commands after the marked
# stops publish externally, so inspect their output before continuing.
#
# One-time setup:
# - List santoku in hughjonesd/universe/packages.json with
#   `"branch": "*release"`. This makes R-universe track GitHub releases
#   directly, without relying on its CRAN-based package discovery.
# - Keep santoku registered in r-multiverse/contributions. A GitHub release
#   will then be picked up by the R-multiverse Community repository.
#
# Before starting:
# - Set a release version in DESCRIPTION (not a .9000 development version).
# - Change the first NEWS heading to `# santoku <version>`.
# - Commit all package, documentation, README and website changes.

branch <- system2("git", c("branch", "--show-current"), stdout = TRUE)
changes <- system2("git", c("status", "--porcelain"), stdout = TRUE)
stopifnot(identical(branch, "master"), length(changes) == 0L)

description <- read.dcf("DESCRIPTION", fields = c("Package", "Version"))
package_name <- description[1, "Package"]
version <- description[1, "Version"]
stopifnot(! grepl("\\.9000$", version))

news <- readLines("NEWS.md")
news_heading <- paste("#", package_name, version)
news_start <- match(news_heading, news)
stopifnot(! is.na(news_start))

# Regenerate everything committed to the repository, then require a clean tree.
devtools::document()
devtools::build_readme()
pkgdown::build_site()

generated_changes <- system2("git", c("status", "--porcelain"), stdout = TRUE)
if (length(generated_changes) > 0L) {
  print(generated_changes)
  stop("Commit the regenerated files, then restart the release process.")
}

# Local checks. Fail on any R CMD check note, warning or error.
spelling <- devtools::spell_check()
stopifnot(NROW(spelling) == 0L)

urls <- urlchecker::url_check()
stopifnot(NROW(urls) == 0L)

devtools::test()
devtools::check(
  manual = TRUE,
  cran = TRUE,
  remote = FALSE,
  error_on = "note"
)

# Build the standalone tutorials in the GitHub Pages repository.
my_home <- path.expand("~/hughjonesd.github.io")
stopifnot(dir.exists(file.path(my_home, ".git")))

rmarkdown::render(
  "vignettes/tutorials/visual-introduction.Rmd",
  output_dir = my_home
)
stopifnot(file.copy(
  "vignettes/tutorials/chopping-dates-with-santoku.Rmd",
  my_home,
  overwrite = TRUE
))
stopifnot(file.copy(
  "vignettes/tutorials/figures",
  my_home,
  recursive = TRUE
))
withr::with_dir(
  my_home,
  rmarkdown::render("chopping-dates-with-santoku.Rmd")
)

# Inspect and commit the GitHub Pages changes, but do not push them yet.

# Push master, then require both GitHub Actions workflows to have succeeded for
# this exact commit before creating a tag.
stopifnot(system2("git", c("fetch", "origin")) == 0L)
sha <- system2("git", c("rev-parse", "HEAD"), stdout = TRUE)
remote_sha <- system2(
  "git",
  c("rev-parse", "origin/master"),
  stdout = TRUE
)
stopifnot(identical(sha, remote_sha))

check_run <- system2(
  "gh",
  c(
    "run", "list",
    "--workflow=R-CMD-check.yaml",
    paste0("--commit=", sha),
    "--status=success",
    "--limit=1",
    "--json=databaseId",
    "--jq=.[0].databaseId"
  ),
  stdout = TRUE
)
coverage_run <- system2(
  "gh",
  c(
    "run", "list",
    "--workflow=test-coverage.yaml",
    paste0("--commit=", sha),
    "--status=success",
    "--limit=1",
    "--json=databaseId",
    "--jq=.[0].databaseId"
  ),
  stdout = TRUE
)
stopifnot(
  length(check_run) == 1L,
  nzchar(check_run),
  length(coverage_run) == 1L,
  nzchar(coverage_run)
)

# STOP: this publishes the GitHub release.
usethis::use_github_release()

# Push the already-reviewed GitHub Pages commit.

# Check the GitHub release, R-universe and R-multiverse Community pages by eye.

# Finally, start the next development version and commit it on master.
usethis::use_dev_version()
