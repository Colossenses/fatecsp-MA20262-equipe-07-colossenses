# Dados GTFS da SPTrans

Este repositório contém arquivos de transporte público da SPTrans no padrão **GTFS (General Transit Feed Specification)**.

Os dados permitem consultar quais linhas existem, seus pontos e itinerários, os dias e horários de operação, a frequência dos veículos e as tarifas aplicáveis.

## Arquivos

| Arquivo | Descrição |
|---|---|
| `agency.txt` | Informações sobre a empresa responsável pelo serviço, como nome, site, idioma e fuso horário. |
| `routes.txt` | Cadastro das linhas de transporte, incluindo número, nome, tipo e cores de identificação. |
| `trips.txt` | Viagens e sentidos de cada linha, incluindo destino, calendário de operação e trajeto geográfico. |
| `stops.txt` | Cadastro dos pontos e estações, com nome, latitude e longitude. |
| `stop_times.txt` | Horários de chegada e partida e a ordem dos pontos em cada viagem. |
| `calendar.txt` | Dias da semana e período de validade de cada serviço. |
| `frequencies.txt` | Intervalo planejado entre veículos em diferentes faixas de horário. |
| `shapes.txt` | Coordenadas que formam o desenho dos itinerários no mapa. |
| `fare_attributes.txt` | Valores, moeda e condições das tarifas. |
| `fare_rules.txt` | Regras que relacionam as tarifas às linhas correspondentes. |

## Relacionamento entre os dados

```text
agency
   |
   v
routes --> trips --> stop_times --> stops
             |           
             +--> calendar
             +--> frequencies
             +--> shapes

routes --> fare_rules --> fare_attributes
```

Principais chaves utilizadas nos cruzamentos:

- `agency_id`: relaciona a operadora às linhas;
- `route_id`: relaciona linhas, viagens e regras tarifárias;
- `trip_id`: relaciona viagens, horários e frequências;
- `stop_id`: relaciona os horários aos pontos;
- `service_id`: relaciona as viagens ao calendário;
- `shape_id`: relaciona as viagens aos desenhos dos itinerários;
- `fare_id`: relaciona as regras aos valores das tarifas.

## Possíveis utilizações

Com esses arquivos, é possível:

- localizar pontos e estações em um mapa;
- desenhar os itinerários das linhas;
- consultar os horários previstos de uma viagem;
- verificar os dias em que uma linha opera;
- calcular o intervalo médio entre veículos;
- identificar o sentido e o destino de uma viagem;
- consultar as tarifas associadas às linhas;
- produzir análises e painéis no Excel, Python ou Power BI.

## Observação

Os arquivos `.txt` utilizam estrutura tabular semelhante a CSV. Eles podem ser abertos em editores de texto, planilhas ou ferramentas de análise de dados.

Mais informações sobre o formato estão disponíveis na [documentação oficial do GTFS](https://gtfs.org/documentation/schedule/reference/).
