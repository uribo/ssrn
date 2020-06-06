#' Convert station data to adjacency matrix
#'
#' @param stations data.frame which set of stopping points recorded in order of
#' stopping.
#' @param depart Column name of a stop.
#' @param arrive Give the name of the column indicating the next stop at the
#' target stop.
#' @examples
#' make_adjacency_matrix(jreast_jt, st_code, next_st_code)
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
  rbind(d01, d02) %>%
    dplyr::distinct({{ depart }}, {{ arrive }}, .keep_all = TRUE) %>%
    od_wider({{ depart }}, {{ arrive }}, distance) %>%
    as.matrix() %>%
    tweak_matrix_names()
}

#' Convert passenger and station data to origin-destination matrix
#' @inheritParams make_adjacency_matrix
#' @param passenger passenger data
#' @inheritParams make_passenger_od
#' @param value origin-destination value name
#' @importFrom rlang `:=`
#' @examples
#' jreast_jt_od %>%
#'   make_passenger_matrix(jreast_jt,
#'                         departure_st_code,
#'                         arrive_st_code,
#'                         st_code,
#'                         volume)
#' @export
#' @rdname make_passenger_matrix
make_passenger_matrix <- function(passenger, stations,
                                  depart, arrive, location, value) {
  by_1 <-  rlang::set_names(rlang::quo_name(rlang::enquo(location)),
                            rlang::quo_name(rlang::enquo(depart)))
  by_2 <-  rlang::set_names(rlang::quo_name(rlang::enquo(location)),
                            rlang::quo_name(rlang::enquo(arrive)))
  d01 <-
    passenger %>%
    make_pass_volume(transit_table(stations),
                     by = by_1) %>%
    dplyr::filter(!is.na({{ arrive }})) %>%
    dplyr::group_by({{ depart }}, {{ arrive }}) %>%
    dplyr::summarise({{ value }} := sum({{ value }}, na.rm = TRUE),
                     .groups = "drop")
  d02 <-
    passenger %>%
    make_pass_volume(transit_table(stations, reverse = TRUE),
                     by = by_2) %>%
    dplyr::filter(!is.na({{ arrive }})) %>%
    dplyr::group_by({{ depart }}, {{ arrive }}) %>%
    dplyr::summarise({{ value }} := sum({{ value }}, na.rm = TRUE),
                     .groups = "drop")
  d_tmp <-
    rbind(d01, d02)
  stations_vec <-
    unique(c(stats::na.omit(c(d_tmp %>%
                         dplyr::pull({{ depart }}),
                       d_tmp %>%
                         dplyr::pull({{ arrive }})))))
  d <-
    passenger %>%
    dplyr::group_by({{ depart }}, {{ arrive }}) %>%
    dplyr::summarise({{ value }} := sum({{ value }}, na.rm = TRUE),
                     .groups = "drop") %>%
    dplyr::filter(!is.na({{ arrive }})) %>%
    dplyr::right_join(tidyr::expand_grid(
      {{ depart }} := stations_vec,
      {{ arrive }} := stations_vec),
    by = c(rlang::quo_name(rlang::enquo(depart)),
           rlang::quo_name(rlang::enquo(arrive))))
  d %>%
    dplyr::mutate({{ value }} := tidyr::replace_na({{ value }}, 0)) %>%
    od_wider({{ depart }}, {{ arrive }}, {{ value }}) %>%
    as.matrix() %>%
    tweak_matrix_names()
}

tweak_matrix_names <- function(x) {
  x <- x[rownames(x), ]
  x <- x[, rownames(x)]
  x
}
