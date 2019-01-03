library(dplyr)
library(urltools)
library(xml2)
library(httr)

get_domain <- function(baseDomain, link)
{
  linkDomain <- urltools::url_parse(link)$domain;
  ifelse (is.na(linkDomain),baseDomain,linkDomain)
}

get_scheme <- function(baseScheme, link)
{
  linkScheme<- urltools::url_parse(link)$scheme;
  ifelse(is.na(linkScheme), baseScheme, linkScheme)
}

get_port <- function(basePort, link)
{
  linkPort<- urltools::url_parse(link)$port;
  ifelse (is.na(linkPort),basePort,linkPort)
}

clean_and_transform_links_dataframe <- function(uri, level, linksDataFrame)
{
  #clean links and trasform to absolute uris
  baseUri <- urltools::url_parse(uri)

  linksDataFrame <- linksDataFrame %>%
    filter(!is.na(link)) %>%
    filter(!startsWith(link, "#")) %>%
    mutate(level = level) %>%
    mutate(
      scheme = get_scheme(baseUri$scheme, link),
      domain = get_domain(baseUri$domain, link),
      port = get_port(baseUri$port, link),
      path = urltools::url_parse(link)$path,
      parameter = urltools::url_parse(link)$parameter,
      fragment = urltools::url_parse(link)$fragment
    ) %>%
    mutate(
      link = urltools::url_compose(data.frame(scheme = scheme,
                                              domain= domain,
                                              port = port,
                                              path = path,
                                              parameter = parameter,
                                              fragment = fragment))
    )

  return(linksDataFrame)
}

get_links <- function(uri, page, level)
{

  names <- xml2::xml_text(xml2::xml_find_all(page, "//a"))
  links <- xml2::xml_attr(xml2::xml_find_all(page, "//a"), "href")

  if (length(links) == 0)
  {
    return(data.frame(name= character(), link= character()))
  }

  df <- data.frame(name = names, link = links, stringsAsFactors = FALSE)

  clean_and_transform_links_dataframe(uri, level, df)
}

#' This function download the html
#'
#' @details The function download the html.
#' SSL errors are ignored using the httr configuration ssl_verifypeer
#' Error downloading webpages due timeouts, incorrect uris our website nor available temporary are ingored and parsed as empty websites
#' @param uri uri to parse as XML
#' @return The uri parse as XML
load_page <- function (uri)
{
  #We ignore SSL errors, using httr config ssl
  tryCatch({
    response <- httr::GET(uri, config = config(ssl_verifypeer = 0L))
    xml2::read_html(response$content)
  }, error = function(e) {xml2::read_html("<html></html>")})
}

update_domain_count <- function(currentDomain, currentDomainCount)
{
  if (is.null(currentDomainCount[[currentDomain]]))
  {
    currentDomainCount[[currentDomain]] <- 1
  }
  else
  {
    currentDomainCount[[currentDomain]] <- currentDomainCount[[currentDomain]] +1
  }

  return(currentDomainCount)
}
empty_link_response <- function(domainCount)
{
  return(list(links = list(), domainCount = domainCount))
}

analize_link <- function(uri, level, max_deepth, max_internal_links, domainCount = list())
{
  if (level > max_deepth) { return(empty_link_response(domainCount)) }

  currentDomain <- urltools::url_parse(uri)$domain
  domainCount <- update_domain_count(currentDomain, domainCount)
  if (domainCount[[currentDomain]] > max_internal_links) { return(empty_link_response(domainCount)) }

  page <- load_page(uri)
  links <- get_links(uri, page, level)
  if (nrow(links) == 0) { return(empty_link_response(domainCount)) }

  linksToAnalyse <- links$link
  for (link in linksToAnalyse) {
    next_links <- analize_link(link, level + 1, max_deepth, max_internal_links, domainCount)
    domainCount <- next_links$domainCount
    if (length(next_links$links) > 0)
    {
      links <- rbind(links, next_links$links)
    }
  }

  return(list(links = links, domainCount = domainCount))
}


#' The function analize the given domain and domains accesible from them
#'
#' @details This are the details
#' @param uri uri to analize
#' @param max_internal_links maximun links to follown on the same domain, this is just to avoid the crawler take many time on domains with many links
#' @param max_deepth maximun number of links levels to follow
#' @return
#' @export
#'
#' @examples
load_domain <- function(uri, max_deepth = 5, max_internal_links = 10)
{
  analize_link(uri,1,max_deepth, max_internal_links)
}


