"""
Carrega os CSVs limpos do Power Query (pasta dados_limpos) em um banco SQLite.
Uso:   python 03_carga_csv.py  <pasta_dados_limpos>  <banco.db>
Só usa a biblioteca padrão do Python (sem pip install).
Para PostgreSQL/MySQL/SQL Server: rode 01_schema.sql no servidor e importe
os CSVs com COPY / LOAD DATA / BULK INSERT na ordem listada em ORDEM.
"""
import csv, sqlite3, sys
from datetime import date, timedelta
from pathlib import Path

pasta, destino = Path(sys.argv[1]), sys.argv[2]
con = sqlite3.connect(destino)
con.execute("PRAGMA foreign_keys = ON")
con.executescript(Path(__file__).with_name("01_schema.sql").read_text(encoding="utf-8"))

def ler(nome):
    # tenta UTF-8 primeiro; se o arquivo for Windows-1252 (comum no Excel/Power Query), usa cp1252
    for enc in ("utf-8-sig", "cp1252"):
        try:
            with open(pasta / f"{nome}.csv", newline="", encoding=enc) as f:
                r = csv.DictReader(f)
                return r.fieldnames, [{k: (v if v != "" else None) for k, v in row.items()} for row in r]
        except UnicodeDecodeError:
            continue
    raise SystemExit(f"Não consegui decodificar {nome}.csv (nem UTF-8 nem cp1252).")

def inserir(tabela, cols, linhas):
    sql = f"INSERT INTO {tabela} ({','.join(cols)}) VALUES ({','.join('?'*len(cols))})"
    con.executemany(sql, ([l[c] for c in cols] for l in linhas))
    print(f"{tabela}: {len(linhas)} linhas")

# ordem importa por causa das chaves estrangeiras
ORDEM = ["dAgency", "dRoutes", "dCalendarServico", "dStops", "dFareAttributes",
         "dShape", "dTrip", "Shapes", "fStopTimes", "fFrequencies", "fFareRules",
         "fBusSubwayCPTM", "fIndividualPass", "fBusSubwayCPTMCompleto"]

dados = {n: ler(n) for n in ORDEM if n != "dShape"}
# dShape é derivada: todos os shape_id de Shapes e dTrip
ids = {l["shape_id"] for n in ("Shapes", "dTrip") for l in dados[n][1] if l["shape_id"]}
dados["dShape"] = (["shape_id"], [{"shape_id": i} for i in sorted(ids)])

for nome in ORDEM:
    cols, linhas = dados[nome]
    # datas do Power Query vêm como "2026-01-01 00:00:00": guarda só a data
    if nome == "dCalendarServico":
        for l in linhas:
            for c in ("start_date", "end_date"):
                if l[c]: l[c] = l[c][:10]
    inserir(nome, cols, linhas)

# dCalendario: mesma lógica do Power Query (01/10/2023 a 01/05/2027)
MESES = ["janeiro","fevereiro","março","abril","maio","junho","julho","agosto","setembro","outubro","novembro","dezembro"]
DIAS = ["segunda-feira","terça-feira","quarta-feira","quinta-feira","sexta-feira","sábado","domingo"]
d, fim, cal = date(2023, 10, 1), date(2027, 5, 1), []
while d <= fim:
    cal.append((d.isoformat(), d.year, d.month, MESES[d.month-1], d.strftime("%Y-%m"), d.isoweekday(), DIAS[d.weekday()]))
    d += timedelta(days=1)
con.executemany("INSERT INTO dCalendario VALUES (?,?,?,?,?,?,?)", cal)
print("dCalendario:", len(cal), "linhas")

con.commit(); con.close()
print("Carga concluída.")