"""
Converte o sptrans.db (SQLite) em um único arquivo .sql para o MySQL.
Uso:   python 04_exportar_mysql.py  sptrans.db  sptrans_mysql.sql
O arquivo gerado: recria o banco 'sptrans', cria as tabelas (01_schema.sql)
e insere todos os dados, já na ordem certa das chaves estrangeiras.
Só usa a biblioteca padrão do Python.
"""
import re, sqlite3, sys
from pathlib import Path

origem, destino = sys.argv[1], sys.argv[2]
ORDEM = ["dAgency", "dRoutes", "dCalendarServico", "dStops", "dFareAttributes",
         "dShape", "dTrip", "Shapes", "fStopTimes", "fFrequencies", "fFareRules",
         "fBusSubwayCPTM", "fIndividualPass", "fBusSubwayCPTMCompleto", "dCalendario"]
LOTE = 500   # linhas por INSERT

def lit(v):
    if v is None: return "NULL"
    if isinstance(v, int): return str(v)
    if isinstance(v, float): return repr(v)
    return "'" + str(v).replace("\\", "\\\\").replace("'", "''") + "'"

con = sqlite3.connect(origem)
schema = Path(__file__).with_name("01_schema.sql").read_text(encoding="utf-8")

with open(destino, "w", encoding="utf-8", newline="\n") as out:
    out.write("DROP DATABASE IF EXISTS sptrans;\n")
    out.write("CREATE DATABASE sptrans CHARACTER SET utf8mb4;\nUSE sptrans;\nSET NAMES utf8mb4;\n\n")
    out.write(schema + "\n\nSET FOREIGN_KEY_CHECKS = 0;\n\n")
    for t in ORDEM:
        info = con.execute(f"PRAGMA table_info({t})").fetchall()
        cols = [c[1] for c in info]
        # avisa se algum texto passa do tamanho do VARCHAR (o MySQL recusaria)
        for _, nome, tipo, *_ in info:
            m = re.match(r"VARCHAR\((\d+)\)", tipo or "", re.I)
            if m:
                mx = con.execute(f"SELECT MAX(LENGTH({nome})) FROM {t}").fetchone()[0] or 0
                if mx > int(m.group(1)):
                    print(f"ATENCAO: {t}.{nome} tem texto de {mx} caracteres (limite {m.group(1)})")
        n = 0
        cur = con.execute(f"SELECT {','.join(cols)} FROM {t}")
        while True:
            linhas = cur.fetchmany(LOTE)
            if not linhas: break
            vals = ",\n".join("(" + ",".join(lit(v) for v in l) + ")" for l in linhas)
            out.write(f"INSERT INTO {t} ({','.join(cols)}) VALUES\n{vals};\n")
            n += len(linhas)
        print(f"{t}: {n} linhas")
    out.write("\nSET FOREIGN_KEY_CHECKS = 1;\n")
print("Arquivo gerado:", destino)
