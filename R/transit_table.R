#' Create transit table
#'
#' @inheritParams make_adjacency_matrix
#' @inheritDotParams dplyr::across -.fns -.names
#' @param reverse Option to swap the order of the stopping points.
#' @examples
#' # The next stop is stored in the variable of column next_.
#' jreast_jt %>%
#'   transit_table()
#' # Switch between inbound and outbound lines.
#' jreast_jt %>%
#'   transit_table(reverse = TRUE)
#' @export
transit_table <- function(stations, ..., reverse = FALSE) {
  if (reverse == TRUE) {
    stations <-
      stations %>%
      purrr::map_df(rev)
  }
  stations %>%
    dplyr::mutate(dplyr::across(...,
                                .fns = ~dplyr::lead(.x, n = 1L),
                                .names = "next_{col}"))

}
