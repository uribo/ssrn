#' Summaries a passenger volume
#'
#' @inheritParams make_passenger_matrix
#' @inheritParams make_adjacency_matrix
#' @param location Name of the variable to use for the join, indicating
#' its location.
#' @param .all Make a join that contains rows of two datasets.
#' The default value is *FALSE*.
#' @examples
#' jreast_jt_od %>%
#'   make_passenger_od(jreast_jt,
#'                     depart = departure_st_code,
#'                     arrive_st_code,
#'                     location = st_code,
#'                     value = volume) %>%
#'  dplyr::left_join(jreast_jt %>%
#'                     dplyr::select(arrive_st_code = st_code,
#'                                   next_st_name = st_name),
#'                    by = "arrive_st_code")
#' @export
make_passenger_od <- function(passenger, stations, depart, arrive, location, value, .all = FALSE) { # nolint
  volume <- NULL
  by_1 <-  rlang::set_names(rlang::quo_name(rlang::enquo(location)),
                            rlang::quo_name(rlang::enquo(depart)))
  by_2 <-  rlang::set_names(rlang::quo_name(rlang::enquo(location)),
                            rlang::quo_name(rlang::enquo(arrive)))
  d <- sum_od_volume(passenger = passenger,
                     departure = {{ depart }},
                     arrive = {{ arrive }},
                     volume = {{ value }})
  if (.all == TRUE) {
    d <-
      d %>%
      dplyr::full_join(stations,
                       by = by_1) %>%
      dplyr::full_join(stations[c(rlang::quo_name(rlang::enquo(location)))],
                       by = by_2)
  } else {
    d <-
      d %>%
      dplyr::left_join(stations,
                       by = by_1) %>%
      dplyr::left_join(stations[c(rlang::quo_name(rlang::enquo(location)))],
                       by = by_2)
  }

  summary_vars <- rlang::syms(c(stringr::str_subset(names(d),
                                                    "volume",
                                                    negate = TRUE)))
  d %>%
    dplyr::group_by(!!!summary_vars) %>%
    dplyr::summarise(volume = sum(volume),
                     .groups = "drop")
}

df_to_adjacency_distance <- function(data, depart, arrive) {
  depart <- rlang::enquo(depart)
  arrive <- rlang::enquo(arrive)
  data %>%
    dplyr::distinct(!!depart, !!arrive) %>%
    dplyr::filter(!is.na(!!arrive)) %>%
    dplyr::mutate(distance = 1)
}

od_wider <- function(data, depart, arrive, value) {
  d <-
    data %>%
    tidyr::pivot_wider(names_from = {{ arrive }},
                       values_from = {{ value }},
                       values_fill = 0)
  d %>%
    dplyr::select({{ depart }},
                  d %>%
                    dplyr::pull(1)) %>%
    tibble::column_to_rownames(var = names(d)[1])
}

make_pass_volume <- function(data, st_data, ...) {
  data %>%
    dplyr::right_join(st_data,
                      by = ...)
}

sum_od_volume <- function(passenger, departure, arrive, volume) {
  passenger %>%
    dplyr::group_by({{ departure }}, {{ arrive }}) %>%
    dplyr::summarise(volume := sum(!!rlang::enquo(volume)),
                     .groups = "drop")
}
