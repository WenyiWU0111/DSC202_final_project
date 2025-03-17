import psycopg2
from neo4j import GraphDatabase
import networkx as nx
from pyvis.network import Network

# PostgreSQL Connection
pg_conn = psycopg2.connect(
    dbname="final_project",
    user="postgres",
    password="12345678",
    host="localhost",
    port="5432"
)
pg_cursor = pg_conn.cursor()

# Neo4j Connection
neo4j_driver = GraphDatabase.driver("bolt://localhost:7687", auth=("neo4j", "mypassword"))

# Function to get paper ID from title using PostgreSQL
def get_paper_id_by_title(paper_title):
    pg_cursor.execute(
        "SELECT paper_id FROM papers WHERE title ILIKE %s LIMIT 1",
        ('%' + paper_title + '%',)
    )
    result = pg_cursor.fetchone()
    
    if result:
        return result[0]
    else:
        print(f"No paper found with title: {paper_title}")
        return None

# Function to get top 3 related papers and their authors using Neo4j
def get_related_papers(paper_id):
    with neo4j_driver.session() as session:
        query = """
        MATCH (p:Paper {paper_id: $paper_id})-[:CITES]-(related:Paper)
        OPTIONAL MATCH (related)<-[:AUTHORED_BY]-(author:Author)
        WITH related, author
        ORDER BY related.citation_count DESC
        RETURN 
            related.paper_id AS related_paper_id,
            related.title AS related_title,
            related.citation_count AS related_citation_count,
            author.name AS author_name
        LIMIT 5
        """
        results = session.run(query, paper_id=paper_id)
        related_papers = results.data()

    if not related_papers:
        print(f"No related papers found for paper ID: {paper_id}")
        return

    print(f"\nRelated Papers for Paper ID: {paper_id}")
    for paper in related_papers:
        print(f"\n🔹 **{paper['related_title']}** (ID: {paper['related_paper_id']}, Citations: {paper['related_citation_count']})")
        if paper['author_name']:
            print(f"   - Author: {paper['author_name']}")


# Example 1: Search Papers by Keyword in PostgreSQL and Get Graph Data from Neo4j
def search_papers_by_keyword(keyword_name):
    # Step 1: Get the keyword_id for the given keyword_name
    pg_cursor.execute(
        "SELECT keyword_id FROM keywords WHERE keyword ILIKE %s",
        ('%' + keyword_name + '%',)
    )
    keyword = pg_cursor.fetchone()

    if not keyword:
        print(f"No papers found for keyword: {keyword_name}")
        return

    keyword_id = keyword[0]

    # Step 2: Get papers associated with this keyword
    pg_cursor.execute(
    """SELECT p.paper_id, p.title 
       FROM (
           SELECT * FROM papers ORDER BY paper_id LIMIT 10000
       ) AS p
       JOIN paper_keywords pk ON p.paper_id = pk.paper_id
       WHERE pk.keyword_id = %s
       LIMIT 10""",
    (keyword_id,)
    )

    papers = pg_cursor.fetchall()

    if not papers:
        print(f"No papers found for keyword: {keyword_name}")
        return
    
    G = nx.DiGraph()

    with neo4j_driver.session() as session:
        for paper_id, title in papers:
            # Step 3: Get papers that cite the current paper
            citation_query = """
            MATCH (p:Paper {paper_id: $paper_id})<-[:CITES]-(citing:Paper)
            with citing
            RETURN citing.paper_id AS citing_paper_id, citing.title AS citing_title
            ORDER BY citing.citation_count DESC
            LIMIT 5
            """
            result = session.run(citation_query, paper_id=paper_id)
            citations = result.data()

            # Add nodes to the graph
            G.add_node(paper_id, label=title, color="blue")
            # Add cited papers
            for c in citations:
                citing_id = c["citing_paper_id"]
                citing_title = c["citing_title"]
                G.add_node(citing_id, label=citing_title, color="red")
                G.add_edge(citing_id, paper_id, label="CITES")
            # Print Results
            print(f"\n📄 Paper: {title} (ID: {paper_id})")
            if citations:
                print("🔗 Cited By:")
                for c in citations:
                    print(f"  - {c['citing_title']} (ID: {c['citing_paper_id']})")
            else:
                print("No citations found.")

    # Create Pyvis network visualization
    net = Network(notebook=True, directed=True, cdn_resources="in_line")
    
    for node, data in G.nodes(data=True):
        net.add_node(node, label=data["label"], color=data["color"])

    for source, target, data in G.edges(data=True):
        net.add_edge(source, target, title=data["label"])

    # Save and show graph
    net.show("citation_graph.html")
    print("Graph saved as citation_graph.html. Open it in a browser to view.")
    

# Example usage
# search_papers_by_keyword("Generative Models")

# paper_title = "Few-shot generative compression approach for system health monitoring"
# paper_id = get_paper_id_by_title(paper_title)

# Main interactive prompt
def main():
    while True:
        print("\n📚 **Research Paper Search**")
        choice = input("Search by (1) Paper Title or (2) Keyword? (Type 'q' to quit): ").strip().lower()

        if choice == "q":
            print("Goodbye! 👋")
            neo4j_driver.close()
            break
        elif choice == "1":
            paper_title = input("Enter the paper title: ").strip()
            paper_id = get_paper_id_by_title(paper_title)
            if paper_id:
                get_related_papers(paper_id)
            else:
                print("No paper found with the given title.")
        elif choice == "2":
            keyword = input("Enter the keyword: ").strip()
            search_papers_by_keyword(keyword)
        else:
            print("Invalid choice. Please enter 1, 2, or 'q'.")

# Run the program
if __name__ == "__main__":
    main()