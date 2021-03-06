#' @title Find all model terms
#' @name find_terms
#'
#' @description Returns a list with the names of all terms, including
#'   response value and random effects, "as is". This means, on-the-fly
#'   tranformations or arithmetic expressions like \code{log()}, \code{I()},
#'   \code{as.factor()} etc. are preserved.
#'
#' @inheritParams find_formula
#' @inheritParams find_predictors
#'
#' @return A list with (depending on the model) following elements (character
#'    vectors):
#'    \itemize{
#'      \item \code{response}, the name of the response variable
#'      \item \code{conditional}, the names of the predictor variables from the \emph{conditional} model (as opposed to the zero-inflated part of a model)
#'      \item \code{random}, the names of the random effects (grouping factors)
#'      \item \code{zero_inflated}, the names of the predictor variables from the \emph{zero-inflated} part of the model
#'      \item \code{zero_inflated_random}, the names of the random effects (grouping factors)
#'      \item \code{dispersion}, the name of the dispersion terms
#'      \item \code{instruments}, the names of instrumental variables
#'    }
#'    Returns \code{NULL} if no terms could be found (for instance, due to
#'    problems in accessing the formula).
#'
#' @note The difference to \code{\link{find_variables}} is that \code{find_terms()}
#'   may return a variable multiple times in case of multiple transformations
#'   (see examples below), while \code{find_variables()} returns each variable
#'   name only once.
#'
#' @examples
#' if (require("lme4")) {
#'   data(sleepstudy)
#'   m <- lmer(
#'     log(Reaction) ~ Days + I(Days^2) + (1 + Days + exp(Days) | Subject),
#'     data = sleepstudy
#'   )
#'
#'   find_terms(m)
#' }
#' @export
find_terms <- function(x, flatten = FALSE, ...) {
  f <- find_formula(x)

  if (is.null(f)) {
    return(NULL)
  }

  if (is_multivariate(f)) {
    l <- lapply(f, .get_variables_list)
  } else {
    l <- .get_variables_list(f)
  }

  if (flatten) {
    unique(unlist(l))
  } else {
    l
  }
}



.get_variables_list <- function(f) {
  f$response <- sub("(.*)::(.*)", "\\2", .safe_deparse(f$conditional[[2L]]))
  f$conditional <- .safe_deparse(f$conditional[[3L]])

  f <- lapply(f, function(.x) {
    if (is.list(.x)) {
      .x <- sapply(.x, .formula_to_string)
    } else {
      if (!is.character(.x)) .x <- .safe_deparse(.x)
    }
    .x
  })

  # protect "-1"
  f$conditional <- gsub("(-1|- 1)(?![^(]*\\))", "#1", f$conditional, perl = TRUE)

  f <- lapply(f, function(.x) {
    f_parts <- gsub("~", "", .trim(unlist(strsplit(split = "[\\*\\+\\:\\-\\|](?![^(]*\\))", x = .x, perl = TRUE))))
    # if user has used namespace in formula-functions, these are returned
    # as empty elements. remove those here
    if (any(nchar(f_parts) == 0)) {
      f_parts <- f_parts[-which(nchar(f_parts) == 0)]
    }
    .remove_backticks_from_string(unique(f_parts))
  })


  # remove "1" and "0" from variables in random effects

  if (.obj_has_name(f, "random")) {
    pos <- which(f$random %in% c("1", "0"))
    if (length(pos)) f$random <- f$random[-pos]
  }

  if (.obj_has_name(f, "zero_inflated_random")) {
    pos <- which(f$zero_inflated_random %in% c("1", "0"))
    if (length(pos)) f$zero_inflated_random <- f$zero_inflated_random[-pos]
  }

  # restore -1
  need_split <- grepl("#1$", f$conditional)
  if (any(need_split)) {
    f$conditional <- c(
      f$conditional[!need_split],
      .trim(unlist(strsplit(f$conditional[need_split], " ", fixed = TRUE)))
    )
  }
  f$conditional <- gsub("#1", "-1", f$conditional, fixed = TRUE)

  # reorder, so response is first
  .compact_list(f[c(length(f), 1:(length(f) - 1))])
}



.formula_to_string <- function(f) {
  if (!is.character(f)) f <- .safe_deparse(f)
  f
}
