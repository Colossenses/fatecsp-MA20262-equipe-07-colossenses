from openpyxl import load_workbook
import os

pasta = os.path.dirname(os.path.abspath(__file__))

arquivo = os.path.join(pasta, "transport.xlsx")
arquivo_saida = os.path.join(pasta, "transport_atualizado.xlsx")

wb = load_workbook(arquivo)
ws = wb["Bus+Subway+CPTM"]

# Localizar a coluna trip_id
coluna = None

for celula in ws[1]:
    if celula.value == "trip_id":
        coluna = celula.column
        break

if coluna is None:
    raise ValueError("Coluna trip_id não encontrada.")

for linha in range(2, ws.max_row + 1):
    celula = ws.cell(row=linha, column=coluna)
    valor = celula.value

    if isinstance(valor, str) and not isinstance(valor, bool):
        celula.value = (
            f'=_xlfn.XLOOKUP("{valor}",Trip[trip_id],Trip[trip_id],"Não encontrado")'
        )

wb.calculation.fullCalcOnLoad = True
wb.calculation.forceFullCalc = True
wb.calculation.calcMode = "auto"

wb.save(arquivo_saida)

print("Arquivo salvo:", arquivo_saida)