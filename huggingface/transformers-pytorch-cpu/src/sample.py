from transformers import pipeline
# Allocate a pipeline for sentiment-analysis
classifier = pipeline('sentiment-analysis')
classifier('We are very happy to introduce pipeline to the transformers repository.')

# Allocate a pipeline for question-answering
question_answerer = pipeline('question-answering')
question_answerer({
    'question': 'What is the name of the repository ?',
    'context': 'Pipeline has been included in the huggingface/transformers repository'
    })

from transformers import AutoTokenizer, AutoModel
tokenizer = AutoTokenizer.from_pretrained("bert-base-uncased")
model = AutoModel.from_pretrained("bert-base-uncased")
inputs = tokenizer("Hello world!", return_tensors="pt")
outputs = model(**inputs)
