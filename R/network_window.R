#' Create network window zones
#'
#' @param adjacency_matrix A boolean matrix, with element (*i*,*j*) set
#' to TRUE if location *j* is adjacent to location *i*.
#' @param dist_matrix Distance matrix
#' @param type Currently, "connected_B" only.
#' @param cluster_max Maximum cluster size.
#' Zone If this value is reached, the area will not be expanded any further.
#' It's a good idea to keep it to the number of stops on the line you're
#' dealing with.
#' @export
network_window <- function(adjacency_matrix, dist_matrix, type, cluster_max) {
  rlang::arg_match(type,
                   c("connected_B"))
  # nolint start
  Zs <- list()
  stations <- seq.int(nrow(adjacency_matrix))
  for (i in stations) {
    print(rownames(adjacency_matrix)[i])
    print(i)
    Zi <- i
    if (type == "connected_B") {
      while(TRUE) {
        dist_mod <-  dist_matrix[, ] * adjacency_matrix[, ]
        dist_mod[dist_mod == 0] <- NA
        dist_mod[, Zi] <- NA
        dist_mod[setdiff(seq.int(nrow(dist_mod)), Zi), ] <- NA
        # if no adjacency_matrix station exist, stop.
        if(sum(!is.na(dist_mod)) == 0) break
        shortest <- min(dist_mod, na.rm = TRUE)
        here <- which(dist_mod == shortest, arr.ind = TRUE)
        koko <- unique(here[, "col"])
        koko <- setdiff(koko, Zi)
        Zi <- c(Zi, koko)
        ## if #Zi reached to the cluster_max, stop
        if(length(Zi) >= cluster_max) break
      }
    }
    for (j in seq.int(length(Zi))) {
      Zs <- c(Zs, list(Zi[seq.int(j)]))
    }
  }
  return(Zs)
  # nolint end
}
