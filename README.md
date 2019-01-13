# Group Assignment - Data Driven Security

Group Assignment base repository for the Data Driven Security subject of the [CyberSecurity Management Msc](https://www.talent.upc.edu/ing/professionals/presentacio/codi/221101/cybersecurity-management/).

## Project Title

Domain graph malware analisys.


### Project Description

The project attempts to analyze the domain introduced by the user in order to create a graph with its sites and links. The purpose is searching malware in the domain and its related sites. 

1. **Crawler.R**: 
The domain is read and analyzed to search for links and new domains.
Afterwards, links are cleaned and formated so as to analyse the information

2. **ExpositionCrawlingData.R**: 
Graph and summaries about collected data are generated, e.g common external domains, ... 

3. **MalwareData.R**: 
Malware domain information is downloaded from several sources.

4. **AnalyzeDomains.R**: 
Links, which where extracted from the Crawler, are analyzed and compared with the malware information collected.

5. **ExpositionMalwareData.R**: 
Graphs are generated to show malware information about the domain analyzed.


### Goals
The goal of the project is detect whether it is possible to reach a domain with malware or spam from a given domain.  

### Data acquisition

Malware information can be found on the following sources:

  - **www.malwaredomainlist.com**: 
Malware domain list and host ips
  - https://github.com/mitchellkrogza/Ultimate.Hosts.Blacklist: 
Github with daily update of malware domains

### Data analysis
We can found a complete domain analysis on the youtube.com domain under vignettes. However, a complete inform about other domains can be created changing the url parameter.

### Results / Conclusions.
After performing different analysis, we found it is very easy to reach a potentially dangerous domain from any kind of domain. Nevertheless, the most difficult task is getting a valid source of malware domain, with the current sources there are many false positives. Consequently, it is needed to add a whitelist of domains to have more acurate results.
