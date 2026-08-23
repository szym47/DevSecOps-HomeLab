import os
import pymssql
from faker import Faker
from dotenv import load_dotenv

# 1. Załadowanie hasła z .env
load_dotenv()
DB_PASSWORD = os.getenv("DB_PASSWORD") 

# 2. Faker dla danych pl
fake = Faker('pl_PL')

def main():
    print("[*] Łączenie z bazą danych...")
    
    # Połączenie do bazy (autocommit=True do wykonania backupu)
    conn = pymssql.connect(
        server='localhost',
        user='SA',
        password=DB_PASSWORD,
        database='DevSecOpsDB',
        autocommit=True 
    )
    cursor = conn.cursor()

    # 3. Kopia zapasowa
    print("[*] Wykonywanie backupu przed modyfikacją...")
    backup_query = "BACKUP DATABASE DevSecOpsDB TO DISK = '/var/opt/mssql/data/DevSecOpsDB_backup.bak'"
    cursor.execute(backup_query)
    print("[+] Backup zakończony sukcesem (DevSecOpsDB_backup.bak).")

    # Przełączamy spowrotnem na tryb transakcyjny dla bezpieczeństwa update'ów
    conn.autocommit(False)

    # 4. Pobranie wszystkich ID klientów do zmiany
    print("[*] Pobieranie rekordów RODO do anonimizacji...")
    cursor.execute("SELECT id FROM Klienci")
    klienci_ids = cursor.fetchall()
    print(f"[*] Znaleziono {len(klienci_ids)} rekordów. Rozpoczynam podmianę...")

    # 5. Pętla anonimizująca
    for row in klienci_ids:
        klient_id = row[0]
        
        # Generowanie realistycznych fałszywek
        fake_imie = fake.first_name()
        fake_nazwisko = fake.last_name()
        fake_email = fake.email()
        fake_telefon = fake.phone_number()
        fake_pesel = fake.pesel()

        # Bezpieczny UPDATE (%s zapobiegając SQL Injection)
        update_query = """
            UPDATE Klienci 
            SET imie=%s, nazwisko=%s, email=%s, telefon=%s, pesel=%s 
            WHERE id=%s
        """
        cursor.execute(update_query, (fake_imie, fake_nazwisko, fake_email, fake_telefon, fake_pesel, klient_id))
    
    # 6. Zapisanie zmian na stałe w bazie
    conn.commit()
    print("[+] Baza danych została pomyślnie zanonimizowana!")

    # 7. Weryfikacja pracy skryptu - wydruk nowych danych do konsoli
    print("\n[*] Weryfikacja nowych (zanonimizowanych) danych:")
    cursor.execute("SELECT * FROM Klienci")
    for row in cursor.fetchall():
         print(f"ID: {row[0]} | {row[1]} {row[2]} | Email: {row[3]} | Tel: {row[4]} | PESEL: {row[5]}")

    conn.close()

if __name__ == "__main__":
    main()