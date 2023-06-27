.bail on

begin;

/*
insert into sqlite_docs(table, docs)
*/

CREATE TABLE legislators (
  --! All Members of Congress that have ever served in Congress, since 1789, as
  --! well as cross-walks into other databases.
  --! @source https://github.com/unitedstates/congress-legislators
  --! @license CC0-1.0 https://github.com/unitedstates/congress-legislators/blob/main/LICENSE

  --- Primary text ID for a legislator. An alias of the id_bioguide column.
  id TEXT PRIMARY KEY,

  --- The full name of the legislator.
  name TEXT,

  --- The alphanumeric ID for this legislator in http://bioguide.congress.gov.
  --- Note that at one time some legislators (women who had changed their name
  --- when they got married) had two entries on the bioguide website. Only one
  --- bioguide ID is included here.
  --- @example "O000172"
  id_bioguide TEXT,

  --- TODO The numeric ID for this legislator on https://www.govtrack.us
  --- @example 412804
  id_govtrack INTEGER,

  --- The numeric ID for this legislator in Keith Poole's VoteView.com website,
  --- originally based on an ID system by the Interuniversity Consortium for
  --- Political and Social Research (stored as an integer).
  --- @example 21949
  id_icpsr INTEGER,

  --- The Wikipedia page name for the person (spaces are given as spaces, not underscores).
  --- @example "Alexandria Ocasio-Cortez"
  id_wikipedia TEXT,

  --- The Wikidata ID for the person.
  --- @details https://www.wikidata.org/wiki/Wikidata:Identifiers
  --- @example "Q55223040"
  id_wikidata TEXT,

  --- Google's Knowledge Search Graph ID
  --- @details https://developers.google.com/knowledge-graph/
  --- @example "kg:/g/11f6y3nqg6"
  id_google_entity_id TEXT,

  --- The legislator's recognizable first name. Many people go by a different name than
  --- their legal first name, often their legal middle name, and our approach is to ensure
  --- that our first + last name fields combine to a recognizable name of the legislator.
  --- Normally we'll follow the name as it appears on House.gov or Senate.gov (and bioguide.congress.gov),
  --- which follows the legislator's own preference for how they want to be named in official places.
  --- However, in some cases the legislator goes by a first name that is merely a common short or informal
  --- form of their legal first name (e.g. Chris vs Christopher), and while they may prefer the informal
  --- name, we may use their longer legal first name because they would be recognizable by their legal name.
  --- If they sign official documents (e.g. letters to agencies, FEC filings) using their longer legal first
  --- name, we would use their legal first name and put their preferred shorter name in the nickname field.
  --- When legislators go by a first initial and middle name, we set the first name field to the initial
  --- (one character plus a period).
  --- @example "Alexandria"
  name_first TEXT,

  --- The legislator's last name. Some names include non-ASCII characters.
  --- When building search systems, it is advised to index both the raw value as
  --- well as a value with extended characters replaced with their ASCII equivalents
  --- @example "Ocasio-Cortez"
  name_last TEXT,

  --- The legislator's birthday, in YYYY-MM-DD format.
  --- @example "1989-10-13"
  bio_birthday TEXT,

  --- The legislator's gender, either "M" or "F".
  --- @example "F"
  bio_gender TEXT,

  --- The numeric ID for this legislator on http://history.house.gov/People/Search/.
  --- The ID is present only for members who have served in the U.S. House.
  id_house_history INTEGER,

  --- The legislator's middle name or middle initial (with period). It is not
  --- recommended to display this field, unless the first name field is an
  -- initial (one character plus a period).
  name_middle TEXT,

  --- The legislator's nick name when used as a common alternative to their first name.
  --- Usually displayed within quotes after the first name. If they are generally only
  --- known by a nickname, we would likely place the name in the first name field instead.
  name_nickname TEXT,

  --- The ballotpedia.org page name for the person (spaces are given as spaces, not underscores).
  id_ballotpedia TEXT,

  --- A suffix on the legislator's name, such as "Jr." or "III", but only if they use it in
  --- official contexts, such as if it appears on House.gov or Senate.gov.
  --- @example "III"
  name_suffix TEXT,

  --- When bioguide.congress.gov mistakenly listed a legislator under multiple IDs, this field is
  --- a list of alternative IDs. (This often ocurred for women who changed their name.) The IDs in
  -- this list probably were removed from bioguide.congress.gov but might still be in use in the wild.
  --- @example '["F000246"]'
  id_bioguide_previous TEXT,

  --- TODO
  --- @example 13283
  id_house_history_alternate INTEGER,

  --- TODO
  -- @example '	[{"end": "1846-01-12","middle": null,"last": "Levy"}]'
  other_names TEXT,

  --- The numeric ID for this legislator on http://thomas.gov and
  --- http://beta.congress.gov. The ID is stored as a string with leading zeros preserved.
  --- @example 02263
  id_thomas TEXT,

  --- The numeric ID for this legislator on C-SPAN's video website,
  --- e.g. http://www.c-spanvideo.org/person/1745
  --- @example 76364
  id_cspan INTEGER,

  --- The numeric ID for this legislator on VoteSmart.org
  --- @example 180416
  id_votesmart INTEGER,

  --- lis: The alphanumeric ID for this legislator found in Senate roll call votes
  --- http://www.senate.gov/pagelayout/legislative/a_three_sections_with_teasers/votes.htm
  --- @example TODO
  id_lis TEXT,

  --- The legislator's nick name when used as a common alternative to their first name.
  --- Usually displayed within quotes after the first name. If they are generally only
  --- known by a nickname, we would likely place the name in the first name field instead.
  --- @example "Alexandria Ocasio-Cortez"
  name_official_full TEXT,

  --- The alphanumeric ID for this legislator on OpenSecrets.org
  --- @example "N00041162"
  id_opensecrets TEXT,

  --- A list of IDs for this legislator in Federal Election Commission data.
  --- @example '["H8NY15148"]'
  id_fec TEXT,

  --- The numeric ID for this legislator on maplight.org (stored as an integer).
  --- @example 2104
  id_maplight INTEGER,

  --- TODO
  --- @schema ???
  --- @example '[{ "title": "House Republican Conference Chair", "chamber": "house", "start": "2021-05-14"}]'
  leadership_roles TEXT,

  --- TODO
  --- @example '[{"name": "Joseph Patrick Kennedy II","relation": "son"}, ...]'
  family TEXT
);


CREATE TABLE legislator_terms (
  --! Individual terms that legislators served for. One entry for each election.

  --- The legislator that served the term.
  legislator_id TEXT REFERENCES legislators(id),

  --- The type of the term. Either "sen" for senators or "rep" for representatives
  --- and delegates to the House.
  --- @values 'rep' OR 'sen'
  --- @example 'rep'
  type TEXT,

  --- The two-letter, uppercase USPS abbreviation for the state that the
  --- legislator is serving from.
  --- @example 'NY'
  state TEXT,

  --- The date legislative service began: the date the legislator was sworn in,
  --- if known, or else the beginning of the legislator's term. Since 1935
  --- regularly elected terms begin on January 3 at noon on odd-numbered years,
  ---  but when Congress does not first meet on January 3, term start dates might
  ---  reflect that swearing-in occurred on a later date. (Prior to 1935, terms
  --- began on March 4 of odd-numbered years, see here.)
  --- In YYYY-MM-DD format.
  --- @example '2019-01-03'
  start TEXT,

  --- End date of the legislative term. In YYYY-MM-DD format.
  --- @example '2021-01-03'
  end TEXT,

  --- TODO
  class INTEGER,

  --- The political party of the legislator. If the legislator changed parties, this
  --- is the most recent party held during the term and party_affiliations will be set.
  --- Values are typically "Democrat", "Independent", or "Republican".
  --- The value typically matches the political party of the legislator on the ballot
  --- in his or her last election, although for state affiliate parties such as
  --- "Democratic Farmer Labor" we will use the national party name ("Democrat") instead
  --- to keep the values of this field normalized.
  --- @example 'Democrat'
  party TEXT,

  --- TODO
  --- 0 for At-Large
  --- @example 14
  district INTEGER,

  --- TODO
  --- @example 'appointment'
  --- @possible 'appointment' OR 'special-election'
  how TEXT,

  --- TODO
  --- @example [{"start": "2019-01-03", "end": "2019-07-03", "party": "Republican" }, ... ]
  party_affiliations TEXT,

  --- TODO
  --- @example 'https://ocasio-cortez.house.gov'
  url TEXT,

  --- For independents, the party that the legislator caucuses with, using the same
  --- values as the party field--although not required for independents with no
  --- caucus. Omitted if the legislator caucuses with the party indicated in the
  --- party field. When in doubt about the difference between the party and caucus
  ---  fields, the party field is what displays after the legislator's name
  --- (i.e. "(D)") but the caucus field is what normally determines committee seniority.
  ---  This field was added starting with terms for the 113th Congress.
  --- @example 'Democrat'
  caucus TEXT,

  --- TODO
  --- @example '229 Cannon House Office Building Washington DC 20515-3214'
  address TEXT,

  --- TODO
  --- @example '202-225-3965'
  phone TEXT,

  --- TODO
  --- @example '202-228-5097'
  fax TEXT,

  --- TODO
  --- @example 'https://www.collins.senate.gov/contact'
  contact_form TEXT,

  --- TODO
  --- @example '229 Cannon House Office Building'
  office TEXT,

  --- TODO
  --- @example 'senior' OR 'junior'
  state_rank TEXT,

  --- The URL to the official website's RSS feed (only valid if the term is
  -- current, otherwise the last known URL).
  --- @example 'http://www.collins.senate.gov/public/?a=rss.feed'
  rss_url TEXT,

  --- TODO
  --- @example 'special-election'
  [end-type] TEXT
);
CREATE TABLE offices (
  --! offices

  --- TODO
  id TEXT PRIMARY KEY,
  --- TODO
  legislator_id TEXT REFERENCES legislators(id),
  --- TODO
  address TEXT,
  --- TODO
  suite TEXT,
  --- TODO
  city TEXT,
  --- TODO
  state TEXT,
  --- TODO
  zip TEXT,
  --- TODO
  latitude FLOAT,
  --- TODO
  longitude FLOAT,
  --- TODO
  phone TEXT,
  --- TODO
  fax TEXT,
  --- TODO
  building TEXT,
  --- TODO
  hours TEXT
);

CREATE TABLE social_media (
  --! socy meddy

  --- TODO
  id TEXT PRIMARY KEY,
  --- TODO
  legislator_id TEXT REFERENCES legislators(id),
  --- TODO
  twitter TEXT,
  --- TODO
  facebook TEXT,
  --- TODO
  youtube_id TEXT,
  --- TODO
  twitter_id INTEGER,
  --- TODO
  youtube TEXT,
  --- TODO
  instagram TEXT,
  --- TODO
  instagram_id INTEGER
);

CREATE TABLE executives (
  --! execies

  --- TODO
  id INTEGER PRIMARY KEY,
  --- TODO
  name TEXT,
  --- TODO
  id_bioguide TEXT,
  --- TODO
  id_govtrack INTEGER,
  --- TODO
  id_icpsr_prez INTEGER,
  --- TODO
  name_first TEXT,
  --- TODO
  name_last TEXT,
  --- TODO
  bio_birthday TEXT,
  --- TODO
  bio_gender TEXT,
  --- TODO
  id_icpsr INTEGER,
  --- TODO
  name_suffix TEXT,
  --- TODO
  name_middle TEXT,
  --- TODO
  id_thomas TEXT,
  --- TODO
  name_nickname TEXT,
  --- TODO
  id_lis TEXT,
  --- TODO
  id_opensecrets TEXT,
  --- TODO
  id_votesmart INTEGER,
  --- TODO
  id_fec TEXT,
  --- TODO
  id_cspan INTEGER,
  --- TODO
  id_wikipedia TEXT,
  --- TODO
  id_wikidata TEXT,
  --- TODO
  id_google_entity_id TEXT,
  --- TODO
  id_ballotpedia TEXT,
  --- TODO
  id_house_history INTEGER,
  --- TODO
  id_maplight INTEGER,
  --- TODO
  name_official_full TEXT
);

CREATE TABLE executive_terms (
  --! execy terms

  --- TODO
  type TEXT,
  --- TODO
  start TEXT,
  --- TODO
  end TEXT,
  --- TODO
  party TEXT,
  --- TODO
  how TEXT,
  --- TODO
  executive_id INTEGER REFERENCES executives(id)
);

commit;

attach database 'legislators.db' as legislators;

insert into legislators
select * from legislators.legislators;
