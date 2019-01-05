library(dplyr)


#' Build a graph from the dataframe links
#'
#' @param domainLinksDf Links of the domain analized
#' @param max_number_domains maximun number of domain to display to avoid many noise on the graph
#' @return
#' @export
build_domain_graph <- function(domainLinksDf, max_number_domains = 10)
{
  top_domains <- (domainLinksDf %>%
    group_by(domain) %>%
    count() %>%
    arrange(desc(n)) %>%
    head(max_number_domains))$domain

  domainLinksDf <- domainLinksDf %>%
    filter(domain %in% top_domains & originDomain %in% top_domains) %>%
    group_by(originDomain, domain) %>%
    count()


  edges_list <- data.frame(from=domainLinksDf$originDomain, to = domainLinksDf$domain)
  graph <- igraph::graph_from_data_frame(edges_list, directed = T)
  graph <- igraph::simplify(graph, remove.loops = TRUE)

  igraph::plot.igraph(graph, edge.label = domainLinksDf$n, edge.arrow.size = 0.5, asp = 0)
}
