// Ensure unique Paper nodes
CREATE CONSTRAINT paper_id_unique IF NOT EXISTS 
FOR (p:Paper) REQUIRE p.paper_id IS UNIQUE;

// Ensure unique Author nodes
CREATE CONSTRAINT author_id_unique IF NOT EXISTS 
FOR (a:Author) REQUIRE a.author_id IS UNIQUE;

// Ensure unique Keyword nodes
CREATE CONSTRAINT keyword_id_unique IF NOT EXISTS 
FOR (k:Keyword) REQUIRE k.keyword_id IS UNIQUE;

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
WITH row WHERE row.paper_id IS NOT NULL AND row.paper_id <> '' LIMIT 10000
CREATE (p:Paper {
    paper_id: row.paper_id,
    title: row.title,
    citation_count: toInteger(row.citation_count)
});
// Load authors
LOAD CSV WITH HEADERS FROM 'file:///authors.csv' AS row
MERGE (a:Author {author_id: row.author_id});

// Load paper-author relationships
LOAD CSV WITH HEADERS FROM 'file:///paper_authors.csv' AS row
MATCH (p:Paper {paper_id: row.paper_id})
MATCH (a:Author {author_id: row.author_id})
MERGE (p)-[:AUTHORED_BY]->(a);

// Step 2: Update Author nodes with names in batches
LOAD CSV WITH HEADERS FROM 'file:///authors.csv' AS row
MATCH (a:Author {author_id: row.author_id})
SET a.name = row.name;

// Load citations
LOAD CSV WITH HEADERS FROM 'file:///citations.csv' AS row
MATCH (citing:Paper {paper_id: row.citing_paper_id})
MATCH (cited:Paper {paper_id: row.cited_paper_id})
MERGE (citing)-[:CITES]->(cited);

// Load keywords
LOAD CSV WITH HEADERS FROM 'file:///keywords.csv' AS row
MERGE (k:Keyword {keyword_id: row.keyword_id})
SET k.name = row.keyword;

// Load keywords and relationships
LOAD CSV WITH HEADERS FROM 'file:///keyword_relationships.csv' AS row
MATCH (p:Paper {paper_id: row.paper_id})
MERGE (k:Keyword {name: row.keyword})
MERGE (p)-[:HAS_KEYWORD]->(k);