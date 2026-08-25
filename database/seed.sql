CREATE DATABASE DevSecOpsDB;
GO
USE DevSecOpsDB;
GO
CREATE TABLE Klienci (
    id INT IDENTITY(1,1) PRIMARY KEY,
    imie VARCHAR(50),
    nazwisko VARCHAR(50),
    email VARCHAR(100),
    telefon VARCHAR(15),
    pesel VARCHAR(11)
);
GO
INSERT INTO Klienci (imie, nazwisko, email, telefon, pesel) VALUES
('Jan', 'Kowalski', 'jan.kowalski@example.com', '123456789', '80101012345'),
('Anna', 'Nowak', 'anna.nowak@example.com', '987654321', '92020254321'),
('Piotr', 'Wisniewski', 'piotr.w@example.com', '555666777', '75030311122');
GO
SELECT * FROM Klienci;
GO