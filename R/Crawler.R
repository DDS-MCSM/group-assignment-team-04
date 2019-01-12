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
    response <- httr::GET(uri, config = httr::config(ssl_verifypeer = 0L))
    xml2::read_html(response$content)
  }, error = function(e) {xml2::read_html("<html></html>")})
}

#' Clean the links data frame removing NA values and adding more information to the data from the link
#'
#' The added information is the level, scheme, domain, path and parameters
#' @param uri uri where the links was found
#' @param linksDataFrame Original data frames with the links
#' @return The clean and extended data frame
clean_and_transform_links_dataframe <- function(uri, linksDataFrame)
{
  #clean links and trasform to absolute uris
  linksDataFrame <- linksDataFrame %>%
    filter(!is.na(link)) %>%
    filter(!startsWith(link, "#"))

  parseLink <- urltools::url_parse(linksDataFrame$link)
  baseUri <- urltools::url_parse(uri)

  linksDataFrame <- linksDataFrame %>%
    mutate(
      scheme = ifelse(is.na(parseLink$scheme),baseUri$scheme, parseLink$scheme),
      domain = ifelse(is.na(parseLink$domain),baseUri$domain, parseLink$domain),
      port = ifelse(is.na(parseLink$port),baseUri$port, parseLink$port),
      path = parseLink$path,
      parameter = parseLink$parameter,
      fragment = parseLink$fragment,
      originDomain = baseUri$domain,
      originLink = uri
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

#' Extract the links from the current page and creates a data frame from the links
#'
#' @param uri uri where the links was found
#' @param page the xml parsed website
#' @param level current analize level to be included on the data frame
#' @return Data frame with the link information
get_links <- function(uri, page, level)
{
  names <- xml2::xml_text(xml2::xml_find_all(page, "//a"))
  links <- xml2::xml_attr(xml2::xml_find_all(page, "//a"), "href")

  if (length(links) == 0)
  {
    return(data.frame(name = character(), link = character()))
  }

  df <- data.frame(name = names, link = links, level = level, stringsAsFactors = FALSE)
  clean_and_transform_links_dataframe(uri, df)
}

#' Counts how many times a domain has been analize to be able to stop the internal search inside the same domain
#'
#' @param currentDomain the current domain analized
#' @param currentDomainCount the number of times the domains has been found
#' @return Data frame with the link information
update_domain_count <- function(currentDomain, currentDomainCount)
{
  if (is.null(currentDomainCount[[currentDomain]]))
  {
    currentDomainCount[[currentDomain]] <- 1
  }
  else
  {
    currentDomainCount[[currentDomain]] <- currentDomainCount[[currentDomain]] + 1
  }

  return(currentDomainCount)
}

empty_link_response <- function(domainCount)
{
  return(list(links = list(), domainCount = domainCount))
}

#' Analize the uri  and all the links found on it
#'
#' @param uri the uri to be analized
#' @param level current analisis level
#' @param max_deepth The maximum level to stop the analisis
#' @param max_internal_links The maximun number of links to be analized inside the same domain
#' @param domainCount How many times a domain has been analized
#' @return Data frame with the link information
analize_link <- function(uri, level, max_deepth, max_internal_links, domainCount = list())
{
  if (level > max_deepth) {
    return(empty_link_response(domainCount))
  }

  currentDomain <- urltools::url_parse(uri)$domain
  domainCount <- update_domain_count(currentDomain, domainCount)
  if (domainCount[[currentDomain]] > max_internal_links) {
    return(empty_link_response(domainCount))
  }

  page <- load_page(uri)
  links <- get_links(uri, page, level)
  if (nrow(links) == 0) { return(empty_link_response(domainCount)) }

  linksToAnalyse <- links$link
  for (link in linksToAnalyse) {
    next_links <- analize_link(link, level + 1, max_deepth, max_internal_links, domainCount)
    domainCount <- next_links$domainCount
    if (length(next_links$links) > 0) {
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


