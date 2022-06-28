Instalar as dependencias:
mix deps.get

Subir o container do mongo:
docker run --name mongo -d mongo:3
(pode ser que precise do --net="host")

Criar o banco e os indexes:
mix ecto.create &&
mix ecto.migrate
(se precisar alterar algo no banco e quiser começar de novo faça um 'mix ecto.drop' antes)

Iniciar o projeto:
iex -S mix phx.server

=D be happy

Criando um user:
curl -X POST \
  http://localhost:4000/user \
  -H 'Content-Type: application/json' \
  -d '{
	"email": "brunodisanto@gmail.com",
	"name": "Bruno di Santo",
	"document_number": "333333333-03",
	"contacts": [
		{"type": "email", "value": "happyappsbr@gmail.com"},
		{"type": "celular", "value": "13 332211332211"}
		],
	"password": "123mudar"
}'

Autenticando user:
curl -X POST \
  http://localhost:4000/authenticate \
  -H 'Content-Type: application/json' \
  -d '{
	"email": "brunodisanto@gmail.com",
	"password": "123mudar"
}'

Com a resposta (token jwt) pode-se fazer chamadas onde é necessário autenticação (atenção ao header Authorization):
Ex. Criar uma conta:
curl -X POST \
  http://localhost:4000/account \
  -H 'Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJhdWQiOiJlYXN5bWFya2V0cGxhY2UiLCJleHAiOjE1NDg4MTg1NzIsImlhdCI6MTU0ODczMjE3MiwiaXNzIjoiZWFzeW1hcmtldHBsYWNlIiwianRpIjoiODM4NjIzMTMtMGQzYS00ZmUyLWFlYWYtY2YyOWFiODFlMjZlIiwibmJmIjoxNTQ4NzMyMTcxLCJzdWIiOiJ1c2VyX2lkIiwidHlwIjoiYWNjZXNzIiwidXNlcl9pZCI6IjVjNGZiZmRmZGZhZWQyMGJjMTljM2YxYyJ9.H9mDfRcKtXHWqxyU7QF8Q5kul4ZxmOjj7X6WzDyvB8E' \
  -H 'Content-Type: application/json' \
  -d '{
	"name": "super loja vendedora",
	"trading_name": "Lojão da massa",
	"document_number": "987364987263497826",
	"locked": false,
	"state_id": "2937892374982734",
	"address": "av moema 55",
	"address_line_2": "apto xyz",
	"state": "SP",
	"postal_code": "04077020",
	"city": "sao paulo",
	"country": "Brasil",
	"contacts": [
		{"type": "email", "value": "happyappsbr@gmail.com"},
		{"type": "celular", "value": "13 997437729"}
		]
}'

Outra chamada de exemplo (consultar informações sobre a conta criada):
curl -X GET \
	http://localhost:4000/account \
	-H 'Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJhdWQiOiJlYXN5bWFya2V0cGxhY2UiLCJleHAiOjE1NDg4MTg1NzIsImlhdCI6MTU0ODczMjE3MiwiaXNzIjoiZWFzeW1hcmtldHBsYWNlIiwianRpIjoiODM4NjIzMTMtMGQzYS00ZmUyLWFlYWYtY2YyOWFiODFlMjZlIiwibmJmIjoxNTQ4NzMyMTcxLCJzdWIiOiJ1c2VyX2lkIiwidHlwIjoiYWNjZXNzIiwidXNlcl9pZCI6IjVjNGZiZmRmZGZhZWQyMGJjMTljM2YxYyJ9.H9mDfRcKtXHWqxyU7QF8Q5kul4ZxmOjj7X6WzDyvB8E' \
	-H 'Content-Type: application/json'

Chamada para consultar as informaçoes de contato do usuário logado:
curl -X GET \
	http://localhost:4000/user/info/contacts \
	-H 'Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJhdWQiOiJlYXN5bWFya2V0cGxhY2UiLCJleHAiOjE1NDg4MTY3MzgsImlhdCI6MTU0ODczMDMzOCwiaXNzIjoiZWFzeW1hcmtldHBsYWNlIiwianRpIjoiMTY3ZDQ3YWMtNGI2NS00OTE5LWI1NDMtZDdkNzk0OTM3ZTM1IiwibmJmIjoxNTQ4NzMwMzM3LCJzdWIiOiJ1c2VyX2lkIiwidHlwIjoiYWNjZXNzIiwidXNlcl9pZCI6IjVjNGZiZmRmZGZhZWQyMGJjMTljM2YxYyJ9.Fvtiek44yBJI9cYVVx5aToMok_vTFIpgwJOAIWcd9Fc'