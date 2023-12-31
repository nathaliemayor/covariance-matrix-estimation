% Copyright (2007) Jens Oehlschlägel
% GPL licence, no warranty, use at your own risk
% Copyright (2007-2010) Martin Maechler
\name{nearcor}
\alias{nearcor}
\title{Find the Nearest Proper Correlation Matrix}
\description{
  This function \dQuote{smoothes} an improper correlation matrix as it can result
  from \code{\link{cor}} with \code{use="pairwise.complete.obs"} or
  \code{\link[polycor]{hetcor}}.

  It is \emph{deprecated} now, in favor of
  \code{\link[Matrix]{nearPD}()} from package \CRANpkg{Matrix}.% 2013-01-16
}
\usage{
nearcor(R, eig.tol = 1e-6, conv.tol = 1e-07, posd.tol = 1e-8,
        maxits = 100, verbose = FALSE)
}
\arguments{
  \item{R}{a square symmetric approximate correlation matrix}
  \item{eig.tol}{defines relative positiveness of eigenvalues compared
  to largest, default=1e-6.}
  \item{conv.tol}{convergence tolerance for algorithm, default=1.0e-7  }
  \item{posd.tol}{tolerance for enforcing positive definiteness, default=1.0e-8}
  \item{maxits}{maximum number of iterations}
  \item{verbose}{logical specifying if convergence monitoring should be
  verbose.}
}
\details{
  This implements the algorithm of Higham (2002), then forces symmetry,
  then forces positive definiteness using code from
  \code{\link[sfsmisc]{posdefify}}.  This implementation does not make
  use of direct LAPACK access for tuning purposes as in the MATLAB code
  of Lucas (2001).  The algorithm of Knol DL and ten Berge (1989) (not
  implemented here) is more general in (1) that it allows contraints to
  fix some rows (and columns) of the matrix and (2) to force the
  smallest eigenvalue to have a certain value.
}
\value{
  A \code{\link{list}}, with components
  \item{cor}{resulting correlation matrix}
  \item{fnorm}{Froebenius norm of difference of input and output}
  \item{iterations}{number of iterations used}
  \item{converged}{logical}
}
\references{See those in \code{\link[sfsmisc]{posdefify}}.
}
\author{ Jens Oehlschlägel }
\seealso{the slightly more flexible \code{\link[Matrix]{nearPD}} which also
  returns a \emph{classed} matrix (class \code{dpoMatrix}).
  For new code, \code{nearPD()} is really preferred to \code{nearcor()},
  which hence is considered deprecated.

  \code{\link[polycor]{hetcor}}, \code{\link{eigen}};
  \code{\link[sfsmisc]{posdefify}} for a simpler algorithm.
}
\examples{
 cat("pr is the example matrix used in Knol DL, ten Berge (1989)\n")
 pr <- matrix(c(1,     0.477, 0.644, 0.478, 0.651, 0.826,
		0.477, 1,     0.516, 0.233, 0.682, 0.75,
		0.644, 0.516, 1,     0.599, 0.581, 0.742,
		0.478, 0.233, 0.599, 1,     0.741, 0.8,
		0.651, 0.682, 0.581, 0.741, 1,     0.798,
		0.826, 0.75,  0.742, 0.8,   0.798, 1),
	      nrow = 6, ncol = 6)

 ncr <- nearcor(pr)
 nr <- ncr$cor
 \dontshow{
  stopifnot(all.equal(nr[lower.tri(nr)],
            c(0.487968018215891, 0.642651880010905, 0.490638670907082, 0.64409905308119,
              0.808711184549399, 0.514114729435273, 0.250668810831206, 0.672351311297071,
              0.725832055882792, 0.596827778712155, 0.582191779051908, 0.744963163381413,
              0.729882058012398, 0.772150225146827, 0.813191720191943)))
 }
 plot(pr[lower.tri(pr)],
      nr[lower.tri(nr)]); abline(0,1, lty=2)
 round(cbind(eigen(pr)$values, eigen(nr)$values), 8)

 cat("The following will fail:\n")
 try(factanal(cov=pr, factors=2))
 cat("and this should work\n")
 try(factanal(cov=nr, factors=2))

 if(require("polycor")) {

    n <- 400
    x <- rnorm(n)
    y <- rnorm(n)

    x1 <- (x + rnorm(n))/2
    x2 <- (x + rnorm(n))/2
    x3 <- (x + rnorm(n))/2
    x4 <- (x + rnorm(n))/2

    y1 <- (y + rnorm(n))/2
    y2 <- (y + rnorm(n))/2
    y3 <- (y + rnorm(n))/2
    y4 <- (y + rnorm(n))/2

    dat <- data.frame(x1, x2, x3, x4, y1, y2, y3, y4)

    x1 <- ordered(as.integer(x1 > 0))
    x2 <- ordered(as.integer(x2 > 0))
    x3 <- ordered(as.integer(x3 > 1))
    x4 <- ordered(as.integer(x4 > -1))

    y1 <- ordered(as.integer(y1 > 0))
    y2 <- ordered(as.integer(y2 > 0))
    y3 <- ordered(as.integer(y3 > 1))
    y4 <- ordered(as.integer(y4 > -1))

    odat <- data.frame(x1, x2, x3, x4, y1, y2, y3, y4)

    xcor <- cor(dat)
    pcor <- cor(data.matrix(odat)) # cor() no longer works for factors
    hcor <- hetcor(odat, ML=TRUE, std.err=FALSE)$correlations
    ncor <- nearcor(hcor)$cor

    try(factanal(covmat=xcor, factors=2, n.obs=n))
    try(factanal(covmat=pcor, factors=2, n.obs=n))
    try(factanal(covmat=hcor, factors=2, n.obs=n))
    try(factanal(covmat=ncor, factors=2, n.obs=n))
  }
}
\keyword{algebra}
\keyword{array}
