#' Verify the domains analized and verifies if contains malware
#'
#' @return  dataframe including if contains malware information
#' @export
analizy_domains <- function(df_domains, malware_domain_list)
{
  df_domains <- df_domains %>%
    mutate(contains_malware = domain %in% malware_domain_list)

  return(df_domains)
}
