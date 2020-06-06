#' East Japan Railway's Tokaido Line Data
#'
#' @docType data
#' @name jreast_jt
#' @return - jreast_jt a tibble
#' @details
#' Includes the names of stations between
#' Tokyo and Yugawara as of June 2020.
#'
#' * `st_code`: A unique number to identify the station.
#' * `st_name`: Romanization of station names.
NULL

#' JR-East Tokaido Line OD Data
#'
#' @docType data
#' @name jreast_jt_od
#' @return - jreast_jt_od a tibble
#' @details
#' Census values made in 2015. The number of passengers between stations
#' on the Tokaido Line. These values are those of commuter pass users.
#'
#' * `departure_st_code`: Departing station identification number.
#' * `arrive_st_code`: The identification number of the station you are arriving at.
#' * `volume` Number of people getting on and off the train.
#' @seealso [https://www.mlit.go.jp/sogoseisaku/transport/sosei_transport_tk_000035.html](https://www.mlit.go.jp/sogoseisaku/transport/sosei_transport_tk_000035.html)
NULL
