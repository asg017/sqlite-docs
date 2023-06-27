## legislators

All Members of Congress that have ever served in Congress, since 1789, as  well as cross-walks into other databases.  @source https://github.com/unitedstates/congress-legislators  @license CC0-1.0 https://github.com/unitedstates/congress-legislators/blob/main/LICENSE

| Column | Description
|-|-
|id|Primary text ID for a legislator. An alias of the id_bioguide column.
|name|The full name of the legislator.
|id_bioguide|The alphanumeric ID for this legislator in http://bioguide.congress.gov. Note that at one time some legislators (women who had changed their name when they got married) had two entries on the bioguide website. Only one bioguide ID is included here.
|id_govtrack|TODO The numeric ID for this legislator on https://www.govtrack.us
|id_icpsr|The numeric ID for this legislator in Keith Poole's VoteView.com website, originally based on an ID system by the Interuniversity Consortium for Political and Social Research (stored as an integer).
|id_wikipedia|The Wikipedia page name for the person (spaces are given as spaces, not underscores).
|id_wikidata|The Wikidata ID for the person. @details https://www.wikidata.org/wiki/Wikidata:Identifiers
|id_google_entity_id|TODO
|name_first|The legislator's recognizable first name. Many people go by a different name than their legal first name, often their legal middle name, and our approach is to ensure that our first + last name fields combine to a recognizable name of the legislator. Normally we'll follow the name as it appears on House.gov or Senate.gov (and bioguide.congress.gov), which follows the legislator's own preference for how they want to be named in official places. However, in some cases the legislator goes by a first name that is merely a common short or informal form of their legal first name (e.g. Chris vs Christopher), and while they may prefer the informal name, we may use their longer legal first name because they would be recognizable by their legal name. If they sign official documents (e.g. letters to agencies, FEC filings) using their longer legal first name, we would use their legal first name and put their preferred shorter name in the nickname field. When legislators go by a first initial and middle name, we set the first name field to the initial (one character plus a period).
|name_last|The legislator's last name. Some names include non-ASCII characters. When building search systems, it is advised to index both the raw value as well as a value with extended characters replaced with their ASCII equivalents
|bio_birthday|The legislator's birthday, in YYYY-MM-DD format.
|bio_gender|The legislator's gender, either "M" or "F".
|id_house_history|The numeric ID for this legislator on http://history.house.gov/People/Search/. The ID is present only for members who have served in the U.S. House.
|name_middle|The legislator's middle name or middle initial (with period). It is not recommended to display this field, unless the first name field is an
|name_nickname|The legislator's nick name when used as a common alternative to their first name. Usually displayed within quotes after the first name. If they are generally only known by a nickname, we would likely place the name in the first name field instead.
|id_ballotpedia|The ballotpedia.org page name for the person (spaces are given as spaces, not underscores).
|name_suffix|A suffix on the legislator's name, such as "Jr." or "III", but only if they use it in official contexts, such as if it appears on House.gov or Senate.gov.
|id_bioguide_previous|When bioguide.congress.gov mistakenly listed a legislator under multiple IDs, this field is a list of alternative IDs. (This often ocurred for women who changed their name.) The IDs in
|id_house_history_alternate|TODO
|other_names|TODO
|id_thomas|The numeric ID for this legislator on http://thomas.gov and http://beta.congress.gov. The ID is stored as a string with leading zeros preserved.
|id_cspan|The numeric ID for this legislator on C-SPAN's video website, e.g. http://www.c-spanvideo.org/person/1745
|id_votesmart|The numeric ID for this legislator on VoteSmart.org
|id_lis|lis: The alphanumeric ID for this legislator found in Senate roll call votes http://www.senate.gov/pagelayout/legislative/a_three_sections_with_teasers/votes.htm
|name_official_full|The legislator's nick name when used as a common alternative to their first name. Usually displayed within quotes after the first name. If they are generally only known by a nickname, we would likely place the name in the first name field instead.
|id_opensecrets|The alphanumeric ID for this legislator on OpenSecrets.org
|id_fec|A list of IDs for this legislator in Federal Election Commission data.
|id_maplight|The numeric ID for this legislator on maplight.org (stored as an integer).
|leadership_roles|TODO @schema ???
|family|TODO

## legislator_terms

legos terms

| Column | Description
|-|-
|legislator_id|TODO
|type|TODO
|state|TODO
|start|TODO
|end|TODO
|class|TODO
|party|TODO
|district|TODO
|how|TODO
|party_affiliations|TODO
|url|TODO
|caucus|TODO
|address|TODO
|phone|TODO
|fax|TODO
|contact_form|TODO
|office|TODO
|state_rank|TODO
|rss_url|TODO
|[end-type]|TODO

## offices

offices

| Column | Description
|-|-
|id|TODO
|legislator_id|TODO
|address|TODO
|suite|TODO
|city|TODO
|state|TODO
|zip|TODO
|latitude|TODO
|longitude|TODO
|phone|TODO
|fax|TODO
|building|TODO
|hours|TODO

## social_media

socy meddy

| Column | Description
|-|-
|id|TODO
|legislator_id|TODO
|twitter|TODO
|facebook|TODO
|youtube_id|TODO
|twitter_id|TODO
|youtube|TODO
|instagram|TODO
|instagram_id|TODO

## executives

execies

| Column | Description
|-|-
|id|TODO
|name|TODO
|id_bioguide|TODO
|id_govtrack|TODO
|id_icpsr_prez|TODO
|name_first|TODO
|name_last|TODO
|bio_birthday|TODO
|bio_gender|TODO
|id_icpsr|TODO
|name_suffix|TODO
|name_middle|TODO
|id_thomas|TODO
|name_nickname|TODO
|id_lis|TODO
|id_opensecrets|TODO
|id_votesmart|TODO
|id_fec|TODO
|id_cspan|TODO
|id_wikipedia|TODO
|id_wikidata|TODO
|id_google_entity_id|TODO
|id_ballotpedia|TODO
|id_house_history|TODO
|id_maplight|TODO
|name_official_full|TODO

## executive_terms

execy terms

| Column | Description
|-|-
|type|TODO
|start|TODO
|end|TODO
|party|TODO
|how|TODO
|executive_id|TODO


