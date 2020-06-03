#' Convert station data to adjacency matrix
#'
#' @param stations data.frame which set of stopping points recorded in order of stopping.
#' @param depart Column name of a stop.
#' @param arrive Give the name of the column indicating the next stop at the target stop.
#' @export
#' @rdname make_adjacency_matrix
make_adjacency_matrix <- function(stations, depart, arrive) {
  distance <- NULL
  d01 <-
    transit_table(stations) %>%
    df_to_adjacency_distance({{ depart }}, {{ arrive }})
  d02 <-
    transit_table(stations, reverse = TRUE) %>%
    df_to_adjacency_distance({{ depart }}, {{ arrive }})
  d <-
    rbind(d01, d02) %>%
    dplyr::distinct({{ depart }}, {{ arrive }}, .keep_all = TRUE)
  d %>%
    od_wider({{ depart }}, {{ arrive }}, distance) %>%
    as.matrix()
}

#' Convert passenger and station data to origin-destination matrix
#' @inheritParams make_adjacency_matrix
#' @param passenger passenger data
#' @param value origin-destination value name
#' @importFrom rlang `:=`
#' @export
#' @rdname make_passenger_matrix
make_passenger_matrix <- function(passenger, stations,
                                  depart, arrive, value) {
  d01 <-
    passenger %>%
    make_pass_volume(transit_table(stations)) %>%
    dplyr::filter(!is.na({{ arrive }})) %>%
    dplyr::group_by({{ depart }}, {{ arrive }}) %>%
    dplyr::summarise({{ value }} := sum({{ value }}, na.rm = TRUE), .groups = "drop")
  d02 <-
    passenger %>%
    make_pass_volume(transit_table(stations, reverse = TRUE)) %>%
    dplyr::filter(!is.na({{ arrive }})) %>%
    dplyr::group_by({{ depart }}, {{ arrive }}) %>%
    dplyr::summarise({{ value }} := sum({{ value }}, na.rm = TRUE), .groups = "drop")
  d_tmp <-
    rbind(d01, d02)
  d <-
    passenger %>%
    dplyr::group_by({{ depart }}, {{ arrive }}) %>%
    dplyr::summarise({{ value }} := sum({{ value }}, na.rm = TRUE), .groups = "drop") %>%
    dplyr::filter(!is.na({{ arrive }})) %>%
    dplyr::right_join(tidyr::expand_grid(
      st_name = unique(c(unique(d_tmp$st_name), unique(d_tmp$next_st_name))),
      next_st_name = unique(c(unique(d_tmp$st_name), unique(d_tmp$next_st_name)))
    ),
    by = c("st_name", "next_st_name"))
  d %>%
    dplyr::mutate({{ value }} := tidyr::replace_na({{ value }}, 0)) %>%
    od_wider({{ depart }}, {{ arrive }}, {{ value }}) %>%
    as.matrix()
}
