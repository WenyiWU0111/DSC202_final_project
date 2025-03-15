// Load papers
LOAD CSV WITH HEADERS FROM 'file:///papers.csv' AS row
CREATE (p:Paper {
    paper_id: row.paper_id,
    title: row.title,
    citation_count: toInteger(row.citation_count),
    abstract: row.abstract
});

// Load authors
LOAD CSV WITH HEADERS FROM 'file:///authors.csv' AS row
CREATE (a:Author {
    author_id: row.author_id,
    name: row.name
});

// Load paper-author relationships
LOAD CSV WITH HEADERS FROM 'file:///paper_authors.csv' AS row
MATCH (p:Paper {paper_id: row.paper_id})
MATCH (a:Author {author_id: row.author_id})
CREATE (p)-[:AUTHORED_BY]->(a);

// Load citations
LOAD CSV WITH HEADERS FROM 'file:///citations.csv' AS row
MATCH (citing:Paper {paper_id: row.citing_paper_id})
MATCH (cited:Paper {paper_id: row.cited_paper_id})
CREATE (citing)-[:CITES]->(cited);

// Load keywords and relationships
LOAD CSV WITH HEADERS FROM 'file:///keyword_relationships.csv' AS row
MATCH (p:Paper {paper_id: row.paper_id})
MERGE (k:Keyword {name: row.keyword})
CREATE (p)-[:HAS_KEYWORD]->(k);

// Create indexes
CREATE INDEX paper_citation_idx IF NOT EXISTS FOR (p:Paper) ON (p.citation_count);
CREATE INDEX paper_title_idx IF NOT EXISTS FOR (p:Paper) ON (p.title);
CREATE INDEX author_name_idx IF NOT EXISTS FOR (a:Author) ON (a.name);
