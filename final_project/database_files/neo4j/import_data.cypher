// Create indexes first for better performance
CREATE INDEX IF NOT EXISTS FOR (p:Paper) ON (p.paper_id);
CREATE INDEX IF NOT EXISTS FOR (p:Paper) ON (p.citation_count);
CREATE INDEX IF NOT EXISTS FOR (p:Paper) ON (p.title);
CREATE INDEX IF NOT EXISTS FOR (a:Author) ON (a.author_id);
CREATE INDEX IF NOT EXISTS FOR (a:Author) ON (a.name);
CREATE INDEX IF NOT EXISTS FOR (k:Keyword) ON (k.name);

CALL db.awaitIndexes(); 
// Load papers
LOAD CSV WITH HEADERS FROM 'file:///cleaned_papers.csv' AS row
WITH row WHERE row.paper_id IS NOT NULL AND row.paper_id <> '' LIMIT 1000
CREATE (p:Paper {
    paper_id: row.paper_id,
    title: row.title,
    citation_count: toInteger(row.citation_count)
});
// Load authors
LOAD CSV WITH HEADERS FROM 'file:///authors.csv' AS row
WITH row LIMIT 1000
CREATE (a:Author {
    author_id: row.author_id,
    name: row.name
});
// Load paper-author relationships
LOAD CSV WITH HEADERS FROM 'file:///paper_authors.csv' AS row
WITH row LIMIT 5000
MATCH (p:Paper {paper_id: row.paper_id})
MATCH (a:Author {author_id: row.author_id})
CREATE (p)-[:AUTHORED_BY]->(a);
// Load citations
LOAD CSV WITH HEADERS FROM 'file:///citations.csv' AS row
WITH row LIMIT 5000
MATCH (citing:Paper {paper_id: row.citing_paper_id})
MATCH (cited:Paper {paper_id: row.cited_paper_id})
MERGE (citing)-[:CITES]->(cited);
// Load keywords and relationships
LOAD CSV WITH HEADERS FROM 'file:///keyword_relationships.csv' AS row
WITH row LIMIT 5000
MATCH (p:Paper {paper_id: row.paper_id})
MERGE (k:Keyword {name: row.keyword})
MERGE (p)-[:HAS_KEYWORD]->(k);

