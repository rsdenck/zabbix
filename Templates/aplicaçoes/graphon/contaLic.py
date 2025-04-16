import os
import re
import subprocess
import sys

class LicenseFileReader:
    def __init__(self, file_path):
        self.file_path = file_path

    def file_exists(self):
        return os.path.exists(self.file_path)

    def read_file_lines(self):
        try:
            with open(self.file_path, 'r', encoding='latin1') as license_file:
                return license_file.readlines()
        except Exception:
            return []  # Retorna lista vazia em caso de erro

class LicenseUsageAnalyzer:
    def __init__(self, file_lines):
        self.file_lines = file_lines

    def count_licenses(self):
        licenses_available = 0
        licenses_in_use = 0
        counting_licenses = False
        unique_sessions = set()

        for line in self.file_lines:
            line = line.strip()

            match = re.search(r"Total of (\d+) licenses available", line)
            if match:
                licenses_available = int(match.group(1))

            if "nodelocked license locked to NOTHING" in line:
                counting_licenses = True
                continue

            if counting_licenses and "start" in line:
                session_match = re.search(r"(\w+)\s+.+\((.+)\), start (.+)", line)
                if session_match:
                    session_id = f"{session_match.group(1)}-{session_match.group(2)}-{session_match.group(3)}"
                    if session_id not in unique_sessions:
                        unique_sessions.add(session_id)
                        licenses_in_use += 1

        return licenses_available, licenses_in_use

def main(metric):
    file_path = r'C:\Zabbix\scripts\appLic.txt'

    # Remover arquivo anterior, se existir
    try:
        if os.path.exists(file_path):
            os.remove(file_path)
    except Exception:
        pass  # Se der erro ao excluir, continua sem interromper

    # Executar o comando e capturar saída corretamente
    try:
        with open(file_path, "w") as output_file:
            subprocess.run([r'C:\Zabbix\scripts\lmutil.exe', 'lmstat', '-a'], stdout=output_file, stderr=subprocess.PIPE, text=True)
    except Exception:
        print(0)
        return  # Se falhar, retorna 0 e encerra

    # Verificar se o arquivo foi criado corretamente
    if not os.path.exists(file_path):
        print(0)
        return

    # Ler arquivo
    license_reader = LicenseFileReader(file_path)
    file_lines = license_reader.read_file_lines()

    # Processar dados
    license_analyzer = LicenseUsageAnalyzer(file_lines)
    available, in_use = license_analyzer.count_licenses()

    # Retornar valor correto
    if metric == "available":
        print(available if available is not None else 0)
    elif metric == "in_use":
        print(in_use if in_use is not None else 0)
    else:
        print(0)  # Retorna 0 se métrica inválida

if __name__ == "__main__":
    if len(sys.argv) > 1:
        main(sys.argv[1])
    else:
        print(0)  # Retorna 0 se não houver argumento
