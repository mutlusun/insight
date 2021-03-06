% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/get_auxiliary.R
\name{get_auxiliary}
\alias{get_auxiliary}
\title{Get auxiliary parameters from models}
\usage{
get_auxiliary(x, type = c("sigma", "dispersion", "beta"), verbose = TRUE, ...)
}
\arguments{
\item{x}{A model.}

\item{type}{The name of the auxiliary parameter that should be retrieved.
\code{"sigma"} is available for most models, \code{"dispersion"} for models
of class \code{glm}, \code{glmerMod} or \code{glmmTMB} as well as \code{brmsfit}.
\code{"beta"} is currently only returned for \code{brmsfit} models.}

\item{verbose}{Toggle warnings.}

\item{...}{Currently not used.}
}
\value{
The requested auxiliary parameter, or \code{NULL} if this information
could not be accessed.
}
\description{
Returns the requested auxiliary parameters from models, like
dispersion, sigma, or beta...
}
\details{
Currently, only sigma and the dispersion parameter are returned, and
only for a limited set of models.
\subsection{Sigma Parameter}{
See \code{\link{get_sigma}}.
}
\subsection{Dispersion Parameter}{
There are many different definitions of "dispersion", depending on the context.
\code{get_auxiliary()} returns the dispersion parameters that usually can
be considered as variance-to-mean ratio for generalized (linear) mixed
models. Exceptions are models of class \code{glmmTMB} and \code{brmsfit},
where the dispersion equals \ifelse{html}{\out{&sigma;<sup>2</sup>}}{\eqn{\sigma^2}}.
In detail, the computation of the dispersion parameter for generalized linear
models is the ratio of the sum of the squared working-residuals and the
residual degrees of freedom. For mixed models of class \code{glmer}, the
dispersion parameter is also called \ifelse{html}{\out{&phi;}}{\eqn{\phi}}
and is the ratio of the sum of the squared Pearson-residuals and the residual
degrees of freedom. For models of class \code{glmmTMB}, dispersion is
\ifelse{html}{\out{&sigma;<sup>2</sup>}}{\eqn{\sigma^2}}.
}
}
\examples{
# from ?glm
clotting <- data.frame(
  u = c(5, 10, 15, 20, 30, 40, 60, 80, 100),
  lot1 = c(118, 58, 42, 35, 27, 25, 21, 19, 18),
  lot2 = c(69, 35, 26, 21, 18, 16, 13, 12, 12)
)
model <- glm(lot1 ~ log(u), data = clotting, family = Gamma())
get_auxiliary(model, type = "dispersion") # same as summary(model)$dispersion
}
