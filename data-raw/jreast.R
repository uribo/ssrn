library(dplyr)
if (!dir.exists("data-raw/mlit_transport12")) {
  dir.create("data-raw/mlit_transport12", recursive = TRUE)
  if (!identical(list.files("data-raw/mlit_transport12/"),
                 c("001179095.xlsx", "001179689.xlsx"))) {
    domain_url <- "https://www.mlit.go.jp"
    x <-
      xml2::read_html(paste0(domain_url,
                             "/sogoseisaku/transport/sosei_transport_tk_000035.html"))
    df_list <-
      tibble::tibble(
        url = paste0(domain_url,
                     x %>%
                       rvest::html_nodes(css = "#contentsColumnWrapL > div:nth-child(2) > table > tbody > tr > td:nth-child(3) > a") %>%
                       rvest::html_attr("href")),
        title = x %>%
          rvest::html_nodes(css = "#contentsColumnWrapL > div:nth-child(2) > table > tbody > tr > td:nth-child(2)") %>%
          rvest::html_text(trim = TRUE))
    df_list %>%
      dplyr::filter(grepl("鉄道駅コード|線別駅間移動人員", title)) %>%
      dplyr::pull(url) %>%
      purrr::walk(
        ~ download.file(url = .x,
                        destfile = paste0("data-raw/mlit_transport12/",
                                          basename(.x)))
      )
    usethis::use_git_ignore("data-raw/mlit_transport12/")
  }
}

df_station_code <-
  readxl::read_xlsx("data-raw/mlit_transport12/001179689.xlsx",
                    skip = 1,
                    col_names = c("st_code",
                                  "oc_name",
                                  "rw_name",
                                  "st_name",
                                  "oc_code",
                                  "rw_code")) %>%
  as_tibble()

df_passenger <-
  readxl::read_xlsx("data-raw/mlit_transport12/001179095.xlsx",
                    col_types = c("text", "text", "numeric", "text", "numeric", "numeric"),
                    skip = 1,
                    col_names = c("rw_code",
                                  "departure_st_code", "departure_status",
                                  "arrive_st_code", "arrive_status",
                                  "volume")) %>%
  as_tibble() %>%
  mutate(rw_code = stringr::str_pad(rw_code, width = 3, pad = "0"),
         across(ends_with("st_code"), ~stringr::str_pad(.x, width = 5, pad = "0"))) %>%
  select(rw_code, departure_st_code, arrive_st_code, volume) %>%
  group_by(rw_code, departure_st_code, arrive_st_code) %>%
  summarise(volume = sum(volume), .groups = "drop")

jreast_jt <-
  df_station_code %>%
  filter(oc_code == "01", rw_code == "001") %>%
  select(st_code, st_name_jp = st_name) %>%
  mutate(st_name = recode(st_name_jp,
                          `東京` = "Tokyo",
                          `新橋` = "Shimbashi",
                          `品川` = "Shinagawa",
                          `川崎` = "Kawasaki",
                          `横浜` = "Yokohama",
                          `戸塚` = "Totsuka",
                          `大船` = "Ofuna",
                          `藤沢` = "Fujisawa",
                          `辻堂` = "Tsujido",
                          `茅ヶ崎` = "Chigasaki",
                          `平塚` = "Hiratsuka",
                          `大磯` = "Oiso",
                          `二宮` = "Ninomiya",
                          `国府津` = "Kozu",
                          `鴨宮` = "Kamonomiya",
                          `小田原` = "Odawara",
                          `早川` = "Hayakawa",
                          `根府川` = "Nebukawa",
                          `真鶴` = "Manazuru",
                          `湯河原` = "Yugawara")) %>%
  select(st_code, st_name)

jreast_jt_od <-
  df_passenger %>%
  filter(rw_code == "001") %>%
  select(-rw_code)

usethis::use_data(jreast_jt, jreast_jt_od, overwrite = TRUE)
