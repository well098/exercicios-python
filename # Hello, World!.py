# Hello, World!
#print("Hello, World!")

if False:
    nome = "Well" # Str - texto (sempre entre aspas )
    #idade = 283 # Int - número inteiro
    altura = 1.75 # Float - número decimal
    estudante = True # Bool - verdadeiro ou falso (True ou False)

    print("Nome:", nome)
    #print("idade:", idade)
    print("Altura:", altura)
    print("Estudante:", estudante)

# variaveis
if False:

  nome = "Well"
  idade = 28

  #print("Ola,"+ nome) #ola, Well
  #print("Voce tem", idade, "anos" ) # voce tem 28 anos

  # forma mais moderna de formatar string
  print (f"Ola, {nome} ! Voce tem {idade} anos.") # Ola, Well! Voce tem 28 anos.

if False:
  Nome = "Wellington"
  Idade = 28
  Curso = "Cibersegurança"
  conclusão = 2027

  print(f"Bem vindo ,{Nome} ! Sua idade atual é {Idade} anos")
  print (f"Qual curso esta cursando ? {Curso} , em qual ano conclui {conclusão}")


if False:
  # 1. Pergunte o nome do usuário
  # 2. Pergunte o salário dele
  # 3. Calcule quanto ele ganha por dia (salário dividido por 30)
  # 4. Imprima uma mensagem com o nome e o valor diário

  nome = input ("Qual o seu nome?")
  print (f"Olá, {nome}!")
  salario = float(input("Qual seu salario?"))
  ganho_dia =  salario / 30
  print(f"Olá, {nome}! Você ganha R$ {ganho_dia:.2f} por dia.")

if False:
  # Peça uma temperatura em Celsius
  # Converta para Fahrenheit: (celsius * 9/5) + 32
  # Mostre o resultado formatado

  Celcius = float(input("Qual a temperatura em Celcius ?"))
  print (f"A temperatura de hoje {Celcius}")
  fahrenheit = (Celcius * 9/5) + 32
  print (f"A temperatura em fahrenheit é {fahrenheit}")

if False:
  # Peça o nome de um produto e o preço original
  # Peça o percentual de desconto (ex: 10 para 10%)
  # Calcule e mostre o preço final com desconto

   produto = input("Qual produto ?")
   preco = float(input("Qual o preço?"))
   desconto = float(input("Qual o desconto?"))
   preco_final = preco - (preco * desconto/100)
   print(f" A(O) {produto} custava R${preco:.2f}, com {desconto}% de desconto fica R${preco_final:.2f}")

if False:
 # Peça a distância em km
 # Peça o consumo do carro (km por litro, ex: 12)
 # Peça o preço do combustível por litro
 # Calcule e mostre quanto vai gastar na viagem

 Distancia = float(input("Qual distancia em KM?"))
 Consumo_por_KM = float(input("Qual consumo ?"))
 Preco_combustivel = float(input("Preco do combustivel?"))

 litros = Distancia / Consumo_por_KM
 gasto_total = litros * Preco_combustivel

 print (f"O gasto da viagem sera de R${gasto_total:.2f}")


if False:
 # Peça o nome, peso (kg) e altura (m) do usuário
 # Calcule o IMC: peso / (altura ** 2)
 # Mostre o nome e o IMC com 2 casas decimais

 Nome = input ("qual seu nome?")
 Peso = float(input ("qual seu peso?"))
 Altura = float (input ("qual seu Altura?"))

 IMC = Peso / (Altura ** 2)
 print (f"Óla,{Nome}! o seu IMC é de {IMC:.2f}")

if False:
 # Peça um valor em reais
 # Converta para dólar (divida por 5.90)
 # Converta para euro (divida por 6.40)
 # Mostre os três valores formatados

 Reais = float(input("qual valor em reais?"))
 Dolar = Reais / 5.90
 Euro = Reais / 6.40

 print(f"O valor convertido em dolares é de {Dolar:.2f}, e em euro é de {Euro:.2f}, e em reais é de {Reais:.2f}")


if False:
  # Peça o nome do aluno
  # Peça 4 notas (use 4 variáveis diferentes)
  # Calcule a média
  # Mostre o nome e a média com 1 casa decimal
  # Dica: média = soma das 4 notas dividida por 4

  Aluno = input ("Qual o nome do aluno? ")
  Matematica = float(input ("qual a sua nota em matematica? "))
  Geografia = float(input ("qual a sua nota em geografia? "))
  Historia = float(input ("qual a sua nota em historia? "))
  Portugues = float(input ("qual a sua nota em portugues? "))

  Soma = (Matematica+Geografia+Historia+Portugues) / 4
  print(f"Olá, {Aluno} a sua media foi de {Soma:.1f} ")

if False:
 # Peça o valor da conta do restaurante
 # Peça o percentual de gorjeta (ex: 10 para 10%)
 # Calcule o valor da gorjeta e o total a pagar
 # Mostre os dois valores formatados

 Valor_conta = float (input("Qual valor da conta? "))
 Gorjeta = float (input("Qual porcentagem de gorjeta? "))
 Valor = Valor_conta * (Gorjeta / 100 )
 Total = Valor_conta + Valor

 print(f"O valor total da conta é R${Total:.2f} e da sua gorjeta é de R${Valor:.2f} ")

if False:
 # Peça uma quantidade de segundos
 # Converta para horas, minutos e segundos
 # Ex: 3661 segundos = 1h 1min 1seg
 # Dica: use // e %

 Segundos = int(input("Qual a quantidade de segundos? "))
 Horas = Segundos // 3600
 Minutos = (Segundos % 3600) // 60
 Seg_restantes = Segundos % 60

 print(f"Ola, suas horas são {Horas}h  {Minutos}M {Seg_restantes}S ")

if False:
 # Peça o valor inicial (capital)
 # Peça a taxa de juros ao mês (ex: 2 para 2%)
 # Peça o número de meses
 # Fórmula: juros = capital * (taxa/100) * meses
 # Mostre o juros e o valor total (capital + juros)

 Capital = float(input("Qual valor do capital inicial? "))
 Juros_mes = float(input("Qual a taxa de juros mensal? " ))
 Meses = int(input("Qual a quantidade de meses? "))
 Juros = Capital * (Juros_mes/100) * Meses
 Valor_total = Capital + Juros

 print(f"O valor do juros é de R${Juros:.2f} e valor total é de R${Valor_total:.2f} ")


if False:
 # Peça o nome do aparelho (ex: geladeira)
 # Peça a potência em watts (ex: 150)
 # Peça quantas horas por dia usa
 # Peça o preço do kWh (ex: 0.75)
 # Fórmula: consumo_mensal = (potencia * horas * 30) / 1000
 # Calcule o consumo em kWh e o custo mensal
 # Mostre tudo formatado

 Aparelho = input("Qual aparelho iremos calcular? ")
 Potencia = int(input("Qual a potencia? "))
 Horas_dia = int(input("Qual a quantidade de horas usada por dia? "))
 Preco_kwh = float(input("Qual o preço do kwh? "))
 Consumo_mensal = (Potencia * Horas_dia * 30) / 1000
 Custo_mensal = Preco_kwh * Consumo_mensal

 print(f"A {Aparelho} consome {Consumo_mensal:.2f}kwh custa R${Custo_mensal:.2f} por mes")


if False:
 # Peça o valor investido
 # Peça a rentabilidade mensal (ex: 1 para 1%)
 # Peça o número de meses
 # Fórmula: saldo = capital * (1 + taxa/100) ** meses
 # Mostre o saldo final e o lucro obtido

 Valor_investimento = float(input("Qual valor do investimento? "))
 Rentabilidade = float(input("Qual o valor da rentabilidade? "))
 Meses = int(input("Qual a quantidade de meses? "))
 Saldo_final = Valor_investimento * (1 + Rentabilidade/100) ** Meses
 Lucro = Saldo_final - Valor_investimento

 print(f"Saldo final R${Saldo_final:.2f} e o lucro obtido R${Lucro:.2f}")


if False:
 # Peça o valor total da conta
 # Peça o número de pessoas
 # Peça o percentual de gorjeta
 # Calcule: valor da gorjeta, total com gorjeta
 # e quanto cada pessoa paga
 # Mostre tudo detalhado

 Total = float(input("Qual valor total da conta? "))
 Numero_pessoas = int(input("Quantas pessoas? "))
 Gorjeta = int(input("Qual a % de gorjeta? "))
 Valor_gorjeta = Total * (Gorjeta / 100 )
 Total_gorjeta = Total + Valor_gorjeta
 Valor_por_pessoa = Total_gorjeta / Numero_pessoas

 print(f"valor da gorjeta R${Valor_gorjeta:.2f}, Total com a gorjeta R${Total_gorjeta:.2f}, e por pessoa R${Valor_por_pessoa:.2f}.")

if False:
  # Peça o nome do destino
  # Peça a distância em km (ida e volta)
  # Peça o consumo do carro em km/litro
  # Peça o preço do litro do combustível
  # Peça quantas pessoas vão dividir o custo
  # Mostre: litros necessários, custo total e custo por pessoa

  Destino = input("Qual o destino? ")
  Distancia = int(input("Qual a distância KM? "))
  Consumo_KM = int(input("Qual a quantidade de consumo por KM? "))
  Preco = float(input("Quanto esta o combustivel? "))
  Quantas_pessoas = int(input("Quantas pessoas? "))
  Litros = Distancia / Consumo_KM
  Custo_total = Preco * Litros
  Custo_pessoas = Custo_total / Quantas_pessoas

  print(f"Para o {Destino} irá precisar de {Litros:.2f} litros, que ficara R${Custo_total:.2f} de custo e saira R${Custo_pessoas:.2f} por pessoa.")



if False:
 # Peça o peso atual e o peso desejado
 # Peça quantos kg pretende perder por semana (ex: 0.5)
 # Calcule quantas semanas vai levar
 # Calcule quantos dias e meses aproximados (1 mês = 30 dias)
 # Mostre tudo formatado

 Peso_atual = float(input("Qual o peso atual? "))
 Peso_desejado = float(input("Qual o peso desejado? "))
 Kg_perder_semana = float(input("Qual a quantidade de Kg perder semana? "))
 Kg_perder = Peso_atual - Peso_desejado
 Semanas = Kg_perder / Kg_perder_semana
 Dias = Semanas * 7
 Meses = Dias / 30

 print(f"Você precisa perder {Kg_perder:.1f} em {Semanas:.0f} semanas e {Dias:.0f} dias em {Meses:.0f}  mes")


# Peça o nome do funcionário
# Peça o salário base
# Peça o número de horas extras (valor da hora extra = salário/220 * 1.5)
# Peça o percentual de desconto do INSS (ex: 11)
# Calcule: valor das horas extras, desconto INSS e salário final
# Mostre tudo detalhado

Nome = input("Qual o nome? ")
Salario = float(input("Qual o salario? "))
Hora_extra = float(input("Quantidade de hora extra? "))
INSS = int(input("Qual a quantidade de INSS? "))
Valor_extra = (Salario / 220 * 1.5) * Hora_extra
Desconto_INSS = Salario * (INSS / 100 )
Salario_final = Salario + Valor_extra - Desconto_INSS

print(f"Salario final R${Salario_final:.2f}, Hora extra R${Valor_extra:.2f} e desconto INSS R${Desconto_INSS:.2f}")
