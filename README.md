# Group Assignment - Data Driven Security

Group Assignment base repository for the Data Driven Security subject of the [CyberSecurity Management Msc](https://www.talent.upc.edu/ing/professionals/presentacio/codi/221101/cybersecurity-management/).

## Project Title

Domain graph malware analisys.


### Project Description

The project attempts to analyze the domain introduce by the user in order to create a graph with the sites and links. The purpose is to search malwary in the domain and related sites. 

1. Crawler.R
Read domains and analyze the site to search for links
Cleans the links information and format the links in a standard format to be able to analyse the information

2. ExpositionCrawlingData.R
Graph and summaries about collected data, e.g common external domains, ... 

3. MalwareData.R
Download malware domain information from several sources.

4. AnalyzeDomains.R
Analyze the links from the Crawler and compare them with the malware information

5. ExpositionMalwareData.R 
Show graphs about malwara data in the analized domain.


### Goals
The goal of the project is detect if it is possible to reach a domain with malware or spam from a given domain.  

### Data acquisition

Malware information can be found on the following sources:

  - www.malwaredomainlist.com
Malware domain list and host ips
  - https://github.com/mitchellkrogza/Ultimate.Hosts.Blacklist
Github with daily update of malware domains

### Data analysis
We can found a complete domain analysis on the youtube.com domain under vignettes

### Results / Conclusions.
After performing different analysis, we found it is very easy to reach a potentially dangerous domain from any kind of domain.
But the most difficult task is get a valid source of malware domain, with the current sources there are many false positives. So to have more acurate result it is needed to add a whitelist of domains
