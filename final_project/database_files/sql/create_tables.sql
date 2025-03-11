
CREATE TABLE papers (
    paper_id VARCHAR(255) PRIMARY KEY,
    title TEXT NOT NULL,
    citation_count INTEGER,
    abstract TEXT
);

CREATE TABLE authors (
    author_id VARCHAR(255) PRIMARY KEY,  -- Changed to VARCHAR for semantic scholar authorId
    name VARCHAR(255) NOT NULL
);

CREATE TABLE paper_authors (
    paper_id VARCHAR(255),
    author_id VARCHAR(255),  -- Changed to VARCHAR
    PRIMARY KEY (paper_id, author_id),
    FOREIGN KEY (paper_id) REFERENCES papers(paper_id),
    FOREIGN KEY (author_id) REFERENCES authors(author_id)
);

CREATE TABLE keywords (
    keyword_id INTEGER PRIMARY KEY,
    keyword VARCHAR(255) NOT NULL UNIQUE
);

CREATE TABLE paper_keywords (
    paper_id VARCHAR(255),
    keyword_id INTEGER,
    PRIMARY KEY (paper_id, keyword_id),
    FOREIGN KEY (paper_id) REFERENCES papers(paper_id),
    FOREIGN KEY (keyword_id) REFERENCES keywords(keyword_id)
);

CREATE TABLE citations (
    citing_paper_id VARCHAR(255),
    cited_paper_id VARCHAR(255),
    PRIMARY KEY (citing_paper_id, cited_paper_id),
    FOREIGN KEY (citing_paper_id) REFERENCES papers(paper_id),
    FOREIGN KEY (cited_paper_id) REFERENCES papers(paper_id)
);

CREATE INDEX idx_papers_citation_count ON papers(citation_count);
CREATE INDEX idx_papers_title ON papers(title);
CREATE INDEX idx_authors_name ON authors(name);
CREATE INDEX idx_keywords_keyword ON keywords(keyword);
