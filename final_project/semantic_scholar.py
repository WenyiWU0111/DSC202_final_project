import requests
import json
import time

keywords = [
    "Machine Learning",
    "Deep Learning", 
    "Artificial Intelligence",
    "AI",
    "Artificial General Intelligence",
    "AGI",
    "Large Language Models",
    "LLMs", 
    "VLMs",
    "Generative Models",
    "Natural Language Processing",
    "NLP",
    "Computer Vision",
    "Reinforcement Learning",
    "Big Data",
    "Data Mining",
    "Explainable AI",
    "XAI",
    "Interpretable Machine Learning",
    "Graph Neural Networks",
    "Bayesian Inference",
    "Causal Inference",
    "Causal Discovery",
    "Foundation Models",
    "Self-Supervised Learning",
    "Multi-Agent Systems",
    "Ethics and Bias in AI"
]


for keyword in keywords:
    print(f'Fetching papers for {keyword}...')
    r = requests.get(
        'https://api.semanticscholar.org/graph/v1/paper/search',
        params={'fields': 'paperId,citationCount,title,authors,'
        'citations.paperId,citations.citationCount,citations.title,citations.authors', 
                'query': keyword,
                'minCitationCount': 10,
                'fieldsOfStudy': 'Computer Science, Mathematics, Engineering',
                "next": 100}
    )
    filename = f'/Users/wwy/Documents/UCSD/DSC202/final_project/semanticscholar_json/{keyword}.json'
    with open(filename, 'w', encoding='utf-8') as f:
        json.dump(r.json(), f, indent=2, ensure_ascii=False)
    time.sleep(30)
    #print(json.dumps(r.json(), indent=2))
