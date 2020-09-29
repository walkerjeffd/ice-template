library(sf)
library(tidyverse)
library(jsonlite)
library(glue)

tpp_albers <- read_sf("tpp/tpp.shp")
tpp_wgs84 <- st_transform(tpp_albers, crs = 4326)

tpp_01 <- tpp_wgs84 %>% 
  filter(str_sub(HUC_12, 1, 2) %in% c("01")) %>% 
  select(id = HUC_12)
tpp_17 <- tpp_wgs84 %>% 
  filter(str_sub(HUC_12, 1, 2) %in% c("17")) %>% 
  select(id = HUC_12)

st_write(tpp_01, "../northeast/layer.json", driver = "GeoJSON", layer_options = "ID_FIELD=id", append = FALSE)
st_write(tpp_17, "../northwest/layer.json", driver = "GeoJSON", layer_options = "ID_FIELD=id", append = FALSE)

df_01 <- tibble(
  id = tpp_01$id
) %>% 
  mutate(
    variable1 = runif(n = nrow(tpp_01)),
    variable2 = rnorm(n = nrow(tpp_01)),
    variable3 = sample(c("A", "B", "C"), size = nrow(tpp_01), replace = TRUE)
  )
df_17 <- tibble(
  id = tpp_17$id
) %>% 
  mutate(
    variable1 = runif(n = nrow(tpp_17)),
    variable2 = rnorm(n = nrow(tpp_17)),
    variable3 = sample(c("A", "B", "C"), size = nrow(tpp_17), replace = TRUE)
  )

write_csv(df_01, "../northeast/data.csv")
write_csv(df_17, "../northwest/data.csv")

for (i in 1:nrow(df_01)) {
  df_01[i, ] %>%
    as.list() %>% 
    write_json(glue("../northeast/features/{df_01$id[i]}.json"), auto_unbox = TRUE, pretty = TRUE, null = "null")
}
for (i in 1:nrow(df_17)) {
  df_17[i, ] %>%
    as.list() %>% 
    write_json(glue("../northwest/features/{df_17$id[i]}.json"), auto_unbox = TRUE, pretty = TRUE, null = "null")
}

theme_01 <- list(
  id = "northeast",
  label = "Northeast Example",
  description = "Example dataset of the northeast U.S.",
  variables = list(
    list(
      id = "variable1",
      label = "Variable 1",
      description = "A dummy variable from 0 to 1",
      units = NULL,
      type = "num",
      group = "Variable Group",
      map = TRUE,
      filter = TRUE,
      formats = list(
        value = ".1%", 
        map = ".1%",
        filter = ".1%"
      ),
      scale = list(
        domain = c(0, 1),
        transform = "linear"
      )
    ),
    list(
      id = "variable2",
      label = "Variable 2",
      description = "A normally distributed variable (mean = 0, sd = 1)",
      units = "km",
      type = "num",
      group = "Variable Group",
      map = TRUE,
      filter = TRUE,
      formats = list(
        value = ".1f", 
        map = ".1f",
        filter = ".1f"
      ),
      scale = list(
        domain = c(-3, 3),
        transform = "linear"
      )
    ),
    list(
      id = "variable3",
      label = "Variable 3",
      description = "A categorical variable",
      units = NULL,
      type = "cat",
      group = "Variable Group",
      map = TRUE,
      filter = TRUE,
      formats = list(
        value = NULL, 
        map = NULL,
        filter = NULL
      ),
      scale = list(
        domain = list(
          list(
            value = "A",
            label = "Value A"
          ),
          list(
            value = "B",
            label = "Value B"
          ),
          list(
            value = "C",
            label = "Value C"
          )
        )
      )
    )
  )
)


theme_17 <- list(
  id = "northwest",
  label = "Northwest Example",
  description = "Example dataset of the northwest U.S.",
  variables = list(
    list(
      id = "variable1",
      label = "Variable 1",
      description = "A dummy variable from 0 to 1",
      units = NULL,
      type = "num",
      group = "Variable Group",
      map = TRUE,
      filter = TRUE,
      formats = list(
        value = ".1%", 
        map = ".1%",
        filter = ".1%"
      ),
      scale = list(
        domain = c(0, 1),
        transform = "linear"
      )
    ),
    list(
      id = "variable2",
      label = "Variable 2",
      description = "A normally distributed variable (mean = 0, sd = 1)",
      units = "km",
      type = "num",
      group = "Variable Group",
      map = TRUE,
      filter = TRUE,
      formats = list(
        value = ".1f", 
        map = ".1f",
        filter = ".1f"
      ),
      scale = list(
        domain = c(-3, 3),
        transform = "linear"
      )
    ),
    list(
      id = "variable3",
      label = "Variable 3",
      description = "A categorical variable",
      units = NULL,
      type = "cat",
      group = "Variable Group",
      map = TRUE,
      filter = TRUE,
      formats = list(
        value = NULL, 
        map = NULL,
        filter = NULL
      ),
      scale = list(
        domain = list(
          list(
            value = "A",
            label = "Value A"
          ),
          list(
            value = "B",
            label = "Value B"
          ),
          list(
            value = "C",
            label = "Value C"
          )
        )
      )
    )
  )
)

write_json(theme_01, "../northeast/theme.json", auto_unbox = TRUE, pretty = TRUE, null = "null")
write_json(theme_17, "../northwest/theme.json", auto_unbox = TRUE, pretty = TRUE, null = "null")
