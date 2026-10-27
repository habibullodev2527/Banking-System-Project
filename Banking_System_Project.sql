create database Banking_System_Project;
use Banking_System_Project;

-- 🟢 Core Banking Tables

--1️ Customers – Bank mijozlari haqidagi ma’lumotlarni saqlaydi.

create table Customers (
	CustomerID int primary key identity(1,1),
	FullName varchar(70) NOT NULL,
	DOB date,
	Email varchar(50) UNIQUE NOT NULL,
	PhoneNumber varchar(50) NOT NULL,
	Address varchar(100),
	NationalID VARCHAR(20) UNIQUE,
	TaxID VARCHAR(20) UNIQUE, 
	EmploymentStatus varchar(50),
	AnnualIncome DECIMAL(18,2),
	CreatedAt datetime NOT NULL DEFAULT GETDATE(),
	UpdatedAt datetime NULL
);

-- 2️ Accounts – Mijozlarning bank hisob raqamlarini saqlaydi.

create table Accounts (
	AccountID int primary key identity(1,1),
	CustomerID int NOT NULL,
	AccountType varchar(50) NOT NULL CHECK (AccountType IN ('Savings', 'Checking', 'Business')),
	Balance decimal(18,2) NOT NULL CHECK (Balance >= 0),
	Currency char(3) NOT NULL,
	Status varchar(20) NOT NULL CHECK (Status IN ('Active','Inactive','Closed','Frozen')),
	BranchID int NOT NULL,
	CreatedDate datetime NOT NULL DEFAULT GETDATE(),

	FOREIGN KEY (CustomerID) REFERENCES Customers(CustomerID),
	FOREIGN KEY (BranchID) REFERENCES Branches(BranchID)
);


-- 3️ Transactions – Barcha bank operatsiyalarini qayd qiladi.

create table Transactions (
	TransactionID int primary key identity(1,1),
	AccountID int NOT NULL,
	TransactionType varchar(50) NOT NULL CHECK (TransactionType IN ('Deposit', 'Withdrawal', 'Transfer', 'Payment')),
	Amount decimal(18,2) NOT NULL CHECK (Amount > 0),
	Currency char(3) NOT NULL,
	TransactionDate datetime NOT NULL DEFAULT GETDATE(), 
	Status varchar(20) NOT NULL  CHECK (Status IN ('Completed', 'Pending', 'Failed', 'Cancelled')),
	ReferenceNo varchar(30) Unique NOT NULL, 

	FOREIGN KEY (AccountID) REFERENCES Accounts(AccountID)
);


-- 4️ Branches – Bank filiallari haqidagi ma’lumotlarni saqlaydi.

create table Branches (
	BranchID int primary key identity(1,1),
	BranchName varchar(50) NOT NULL UNIQUE,
	Address varchar(170) NOT NULL,
	City varchar(30) NOT NULL,
	State varchar(30) NOT NULL,
	Country varchar(30) NOT NULL DEFAULT 'Uzbekistan',
	ManagerID int NULL,
	ContactNumber varchar(20) NOT NULL
);

--5️ Employees – Bank xodimlari ma’lumotlarini saqlaydi.

create table Employees (
	EmployeeID int primary key identity(1,1),
	BranchID int NOT NULL,
	FullName varchar(70) NOT NULL,
	Position varchar(50) NOT NULL,
	Department int NOT NULL,
	Salary Decimal(18,2) NOT NULL CHECK (Salary > 0),
	HireDate date NOT NULL CHECK (HireDate <= GETDATE()), 
	Status varchar(30) NOT NULL CHECK (Status IN ('Active','Inactive','Fired','OnLeave'))
);

-- FK + Branches

alter table Branches
add constraint FK_Branch_Manager
FOREIGN KEY (ManagerID) REFERENCES Employees(EmployeeID);

-- FK + Employees

alter table Employees
add constraint FK_Employee_Branch
FOREIGN KEY (BranchID) REFERENCES Branches(BranchID)

ALTER TABLE Employees
ADD CONSTRAINT FK_Employees_Department
FOREIGN KEY (Department) REFERENCES Departments(DepartmentID);

--💳 Digital Banking & Payments

--6️ CreditCards – Mijozning kredit karta ma’lumotlari.

create table CreditCards (
	CardID int primary key identity(1,1),
	CustomerID int NOT NULL,
	CardNumber char(16) NOT NULL UNIQUE,
	CardType varchar(50) NOT NULL CHECK (CardType IN ('Visa', 'MasterCard', 'UzCard', 'Humo')),
	CVV char(3) NOT NULL,
	ExpiryDate Date NOT NULL,
	CreditLimit Decimal(18,2) NOT NULL CHECK (CreditLimit > 0),
	Status varchar(30) NOT NULL CHECK (Status IN ('Active', 'Blocked', 'Expired', 'Closed')),

	FOREIGN KEY (CustomerID) REFERENCES Customers(CustomerID)
);

--7️ CreditCardTransactions –Kredit karta tranzaksiyalarini qayd etadi.

create table CreditCardTransactions (
	TransactionID int primary key identity(1,1),
	CardID int NOT NULL,
	Merchant int NOT NULL,
	Amount decimal(18,2) NOT NULL CHECK (Amount > 0),
	Currency char(3) NOT NULL,
	TransactionDate datetime NOT NULL DEFAULT GETDATE(),
	Status varchar(50) NOT NULL CHECK (Status IN ('Completed', 'Pending', 'Failed', 'Cancelled')),
	
	FOREIGN KEY (CardID) REFERENCES CreditCards(CardID)
);

ALTER TABLE CreditCardTransactions
ADD CONSTRAINT FK_CCT_Merchant
FOREIGN KEY (Merchant)
REFERENCES Merchants(MerchantID);

--8️ OnlineBankingUsers – Internet banking uchun ro‘yxatdan o‘tgan mijozlar.

create table OnlineBankingUsers(
	UserID int primary key identity(1,1),
	CustomerID int NOT NULL UNIQUE,
	Username varchar(80) NOT NULL UNIQUE,
	PasswordHash varchar(300) NOT NULL,
	LastLogin datetime NULL,

	FOREIGN KEY (CustomerID) REFERENCES Customers(CustomerID)
);

--9️ BillPayments –Kommunal to‘lovlarni kuzatadi.

create table BillPayments (
	PaymentID int primary key identity(1,1),
	CustomerID int NOT NULL,
	BillerName varchar(80) NOT NULL,
	Amount decimal(18,2) NOT NULL CHECK (Amount > 0),
	PaymentDate datetime NOT NULL DEFAULT GETDATE(),
	Status varchar(50) NOT NULL CHECK (Status IN ('Pending', 'Completed', 'Failed', 'Cancelled')),

	FOREIGN KEY (CustomerID) REFERENCES Customers(CustomerID)
);

--10 MobileBankingTransactions –Mobil banking faoliyatini kuzatadi.

create table MobileBankingTransactions (
	TransactionID int primary key identity(1,1),
	CustomerID int NOT NULL,
	DeviceID varchar(100) NOT NULL,
	AppVersion varchar(20) NOT NULL,
	TransactionType varchar(20) NOT NULL CHECK (TransactionType IN ('Transfer', 'Payment', 'Deposit', 'Withdrawal')),
	Amount decimal(18,2) NOT NULL CHECK (Amount > 0),
	TransactionDate datetime NOT NULL DEFAULT GETDATE(),
	
	FOREIGN KEY (CustomerID) REFERENCES Customers(CustomerID)
);

--🏦 Loans & Credit

--1️1️ Loans – Kredit ma’lumotlarini saqlaydi.

create table Loans (
	LoanID int primary key identity(1,1),
	CustomerID int NOT NULL,
	LoanType varchar(50) NOT NULL CHECK (LoanType in ('Mortgage', 'Personal', 'Auto', 'Business')),
	Amount decimal(18,2) NOT NULL CHECK (Amount > 0),
	InterestRate decimal(5,2) NOT NULL CHECK (InterestRate >= 0 AND InterestRate <= 100),
	StartDate date NOT NULL DEFAULT GETDATE(),
	EndDate date NOT NULL,
	Status varchar(50) NOT NULL CHECK (Status IN ('Active', 'Closed', 'Defaulted', 'Pending')),

	CHECK (EndDate > StartDate),
	FOREIGN KEY (CustomerID) REFERENCES Customers(CustomerID)
);


--1️2️ LoanPayments – Kredit to‘lovlarini kuzatadi.

create table LoanPayments (
	PaymentID int primary key identity(1,1),
	LoanID int NOT NULL,
	AmountPaid decimal(18,2) NOT NULL CHECK (AmountPaid > 0),
	PaymentDate datetime NOT NULL DEFAULT GETDATE(),
	RemainingBalance decimal(18,2) NOT NULL CHECK (RemainingBalance >= 0),

	FOREIGN KEY (LoanID) REFERENCES Loans(LoanID)
);

--1️3️ CreditScores – Mijozlarning kredit reytinglari.

create table CreditScores (
	CustomerID int NOT NULL,
	CreditScore int NOT NULL CHECK (CreditScore > 0),
	UpdatedAt date NOT NULL DEFAULT GETDATE(),

	FOREIGN KEY (CustomerID) REFERENCES Customers(CustomerID)
);

--1️4️ DebtCollection – Muddati o‘tgan kreditlarni kuzatadi.

create table DebtCollection (
	DebtID int primary key identity(1,1),
	CustomerID int NOT NULL,
	AmountDue decimal(18,2) NOT NULL CHECK (AmountDue > 0),
	DueDate Date NOT NULL,
	CollectorAssigned varchar(50) NOT NULL,

	FOREIGN KEY (CustomerID) REFERENCES Customers(CustomerID)
);

--📊Moslik (compliance) va risklarni boshqarish.

--1️5️ KYC (Know Your Customer) – Mijozni tasdiqlash (verifikatsiya) ma’lumotlarini saqlaydi.

create table KYC (
	KYCID int primary key identity(1,1),
	CustomerID int NOT NULL, 
	DocumentType varchar(50) NOT NULL CHECK (DocumentType IN ('Passport','ID Card','Driver License')),
	DocumentNumber varchar(50) NOT NULL UNIQUE,
	Verifiedby varchar(50) NOT NULL,

	FOREIGN KEY (CustomerID) REFERENCES Customers(CustomerID)
);

--1️6️ FraudDetection – Shubhali tranzaksiyalarni belgilaydi.

create table FraudDetection (
	FraudID int primary key identity(1,1),
	CustomerID int NOT NULL, 
	TransactionID int NOT NULL, 
	RiskLevel varchar(10) NOT NULL CHECK (RiskLevel IN ('Low','Medium','High')),
	ReportedDate datetime NOT NULL DEFAULT GETDATE(),

	FOREIGN KEY (CustomerID) REFERENCES Customers(CustomerID),
	FOREIGN KEY (TransactionID) REFERENCES Transactions(TransactionID)
);

--1️7️ AML (Anti-Money Laundering) Cases – Moliyaviy jinoyatlarni tekshiradi.

create table AML_Cases (
	CaseID int primary key identity(1,1),
	CustomerID int NOT NULL,
	CaseType varchar(30) NOT NULL CHECK (CaseType IN ('Suspicious','MoneyLaundering','Fraud','Sanctions')),
	Status varchar(20) NOT NULL CHECK (Status IN ('Open','UnderReview','Closed','Escalated')),
	InvestigatorID int NOT NULL,

	FOREIGN KEY (CustomerID) REFERENCES Customers(CustomerID),
	FOREIGN KEY (InvestigatorID) REFERENCES Employees(EmployeeID)
);

--1️8️ RegulatoryReports – Regulyatorlar uchun moliyaviy hisobotlarni saqlaydi.

create table RegulatoryReports (
	ReportID int primary key identity(1,1),
	ReportType varchar(30) NOT NULL CHECK (ReportType IN ('AML','Transaction','SAR','Financial')),
	SubmissionDate datetime NOT NULL DEFAULT GETDATE()
);

--🧑‍💼 Human Resources & Payroll

--1️9️ Departments –Kompaniya bo‘limlarini saqlaydi.

create table Departments (
	DepartmentID int primary key identity(1,1),
	DepartmentName varchar(30) NOT NULL UNIQUE,
	ManagerID int NULL,

	FOREIGN KEY (ManagerID) REFERENCES Employees(EmployeeID)
);
drop 
--2️0️ Salaries –Xodimlarning ish haqi ma’lumotlari.

create table Salaries (
	SalaryID int primary key identity(1,1),
	EmployeeID int NOT NULL,
	BaseSalary decimal(18,2) NOT NULL CHECK (BaseSalary > 0),
	Bonus decimal(18,2) NOT NULL CHECK (Bonus >= 0),
	Deductions decimal(18,2) NOT NULL CHECK (Deductions >= 0),
	PaymentDate date NOT NULL DEFAULT GETDATE(),

	FOREIGN KEY (EmployeeID) REFERENCES Employees(EmployeeID),
	UNIQUE (EmployeeID, PaymentDate)
);

--2️1️ EmployeeAttendance – Ish soatlarini kuzatadi.

create table EmployeeAttendance (
	AttendanceID int primary key identity(1,1),
	EmployeeID int NOT NULL,
	CheckInTime datetime NOT NULL,
	CheckOutTime datetime NULL,
	TotalHours as 
        case 
            when CheckOutTime IS NULL then NULL
            else DATEDIFF(MINUTE, CheckInTime, CheckOutTime) / 60.0
        end,

	CHECK (CheckOutTime IS NULL OR CheckOutTime >= CheckInTime),
	FOREIGN KEY (EmployeeID) REFERENCES Employees(EmployeeID)
);

--📈 Investments & Treasury

--2️2️ Investments – Mijozlarning investitsiya ma’lumotlarini saqlaydi.

create table Investments (
	InvestmentID int primary key identity(1,1),
	CustomerID int NOT NULL,
	InvestmentType varchar(30) NOT NULL CHECK (InvestmentType IN ('FixedDeposit','MutualFund','Bond','Stock')),
	Amount decimal(18,2) NOT NULL CHECK (Amount > 0),
	ROI decimal(5,2) NOT NULL CHECK (ROI >= 0 AND ROI <= 100),
	MaturityDate date NOT NULL,

	FOREIGN KEY (CustomerID) REFERENCES Customers(CustomerID)
);

--2️3️ StockTradingAccounts – Bank orqali aksiyalar bilan savdo qilayotgan mijozlar.

create table StockTradingAccounts (
	StockAccountID int primary key identity(1,1),
	CustomerID int NOT NULL,
	BrokerageFirm varchar(50) NOT NULL,
	TotalInvested decimal(18,2) NOT NULL CHECK (TotalInvested >= 0),
	CurrentValue decimal(18,2) NOT NULL CHECK (CurrentValue >= 0),

	FOREIGN KEY (CustomerID) REFERENCES Customers(CustomerID)
);

--2️4️ ForeignExchange – Valyuta (forex) tranzaksiyalarini kuzatadi.

create table ForeignExchange (
	FXID int primary key identity(1,1),
	CustomerID int NOT NULL,
	CurrencyPair varchar(10) NOT NULL,
	ExchangeRate decimal(18,6) NOT NULL CHECK (ExchangeRate > 0),
	AmountExchanged decimal(18,2) NOT NULL CHECK (AmountExchanged > 0),

	FOREIGN KEY (CustomerID) REFERENCES Customers(CustomerID)
);

--📜 Insurance & Security

--2️5️ InsurancePolicies – Mijozlarning sug‘urta rejalari.

create table InsurancePolicies (
	PolicyID int primary key identity(1,1),
	CustomerID int NOT NULL,
	InsuranceType varchar(50) NOT NULL CHECK (InsuranceType IN ('Health','Life','Car','Property','Travel', 'Other')),
	PremiumAmount decimal(18,2) NOT NULL CHECK (PremiumAmount > 0),
	CoverageAmount decimal(18,2) NOT NULL CHECK (CoverageAmount > 0),

	FOREIGN KEY (CustomerID) REFERENCES Customers(CustomerID),
	CHECK (CoverageAmount >= PremiumAmount)
);

--2️6️ Claims – Sug‘urta da’volarini kuzatadi.

create table Claims (
	ClaimID int primary key identity(1,1),
	PolicyID int NOT NULL,
	ClaimAmount decimal(18,2) NOT NULL CHECK (ClaimAmount > 0),
	Status varchar(20) NOT NULL CHECK (Status IN ('Pending','Approved','Rejected','Paid', 'Other')),
	FiledDate datetime NOT NULL  DEFAULT GETDATE(),

	FOREIGN KEY (PolicyID) REFERENCES InsurancePolicies(PolicyID)
);

--2️7️ UserAccessLogs – Bank tizimi foydalanuvchilari uchun xavfsizlik loglarini saqlaydi.

create table UserAccessLogs (
	LogID int primary key identity(1,1),
	UserID int NOT NULL,
	ActionType varchar(30) NOT NULL CHECK (ActionType IN ('Login', 'Logout', 'PasswordChange', 'ProfileUpdate', 'Transfer', 'BillPayment', 'FailedLogin', 'Other')),
	ActionTime datetime NOT NULL  DEFAULT GETDATE(),

	FOREIGN KEY (UserID) REFERENCES OnlineBankingUsers(UserID)
);	

--2️8️ CyberSecurityIncidents – Ma’lumotlar buzilishi yoki kiberhujum holatlarini saqlaydi.

create table CyberSecurityIncidents (
	IncidentID int primary key identity(1,1),
	AffectedSystem varchar(50) NOT NULL,
	ReportedDate datetime NOT NULL DEFAULT GETDATE(),
	ResolutionStatus varchar(30) NOT NULL CHECK (ResolutionStatus IN ('Open','Investigating','Resolved','Closed'))
);

--🛒 Merchant Services

--2️9️ Merchants – Bank hamkorlari uchun savdogar (merchant) ma’lumotlarini saqlaydi.

create table Merchants (
	MerchantID int primary key identity(1,1),
	CustomerID int NOT NULL,
	MerchantName varchar(50) NOT NULL,
	Industry varchar(30) NOT NULL,
	Location varchar(50) NOT NULL,

	FOREIGN KEY (CustomerID) REFERENCES Customers(CustomerID)
);

--3️0️ MerchantTransactions – Savdogarlar bilan bog‘liq bank tranzaksiyalarini qayd etadi.

create table MerchantTransactions (
	TransactionID int primary key identity(1,1),
	MerchantID int NOT NULL,
	Amount decimal(18,2) NOT NULL CHECK (Amount > 0),
	PaymentMethod varchar(20) NOT NULL CHECK (PaymentMethod IN ('Cash','Card','BankTransfer','MobilePay','QR')),
	TransactionDate datetime NOT NULL DEFAULT GETDATE(),

	FOREIGN KEY (MerchantID) REFERENCES Merchants(MerchantID)
);


-- INSERT 10000 rows of data into tables

-- Insert to Branches

INSERT INTO Branches (BranchName, Address, City, State, Country, ManagerID, ContactNumber)
VALUES
('Tashkent Central', 'Amir Temur kochasi 10', 'Tashkent', 'Tashkent', 'Uzbekistan', NULL, '+998901111111'),
('Tashkent Yunusobod', 'Yunusobod 5-daha', 'Tashkent', 'Tashkent', 'Uzbekistan', NULL, '+998901111112'),
('Tashkent Chilonzor', 'Chilonzor 15-kvartal', 'Tashkent', 'Tashkent', 'Uzbekistan', NULL, '+998901111113'),
('Samarkand Main', 'Registon kochasi 12', 'Samarkand', 'Samarkand', 'Uzbekistan', NULL, '+998901111114'),
('Bukhara Main', 'Mustaqillik kochasi 8', 'Bukhara', 'Bukhara', 'Uzbekistan', NULL, '+998901111115'),
('Andijan Main', 'Bobur shoh kochasi 25', 'Andijan', 'Andijan', 'Uzbekistan', NULL, '+998901111116'),
('Namangan Main', 'Kosonsoy kochasi 17', 'Namangan', 'Namangan', 'Uzbekistan', NULL, '+998901111117'),
('Fergana Main', 'Al-Fargoni 9', 'Fergana', 'Fergana', 'Uzbekistan', NULL, '+998901111118'),
('Nukus Main', 'Berdaq kochasi 20', 'Nukus', 'Karakalpakstan', 'Uzbekistan', NULL, '+998901111119'),
('Urgench Main', 'Al-Xorazmiy 11', 'Urgench', 'Khorezm', 'Uzbekistan', NULL, '+998901111120'),
('Qarshi Main', 'Nasaf kochasi 14', 'Qarshi', 'Kashkadarya', 'Uzbekistan', NULL, '+998901111121'),
('Termiz Main', 'At-Termiziy 19', 'Termiz', 'Surkhandarya', 'Uzbekistan', NULL, '+998901111122'),
('Jizzakh Main', 'Sharof Rashidov 13', 'Jizzakh', 'Jizzakh', 'Uzbekistan', NULL, '+998901111123'),
('Gulistan Main', 'Shodlik kochasi 7', 'Gulistan', 'Sirdarya', 'Uzbekistan', NULL, '+998901111124'),
('Navoi Main', 'Navoiy kochasi 22', 'Navoi', 'Navoi', 'Uzbekistan', NULL, '+998901111125'),
('Angren Branch', 'Mustaqillik 31', 'Angren', 'Tashkent Region', 'Uzbekistan', NULL, '+998901111126'),
('Bekobod Branch', 'Istiqlol 5', 'Bekobod', 'Tashkent Region', 'Uzbekistan', NULL, '+998901111127'),
('Kokand Branch', 'Furqat kochasi 16', 'Kokand', 'Fergana', 'Uzbekistan', NULL, '+998901111128'),
('Margilan Branch', 'Atlas kochasi 21', 'Margilan', 'Fergana', 'Uzbekistan', NULL, '+998901111129'),
('Shahrisabz Branch', 'Oqsaroy 6', 'Shahrisabz', 'Kashkadarya', 'Uzbekistan', NULL, '+998901111130');

DELETE FROM Branches;
DBCC CHECKIDENT ('Accounts', RESEED, 0);

select *from Branches
-- Insert to Customers

DECLARE @i INT = 1;

WHILE @i <= 1500
BEGIN
    INSERT INTO Customers
    (
        FullName,
        DOB,
        Email,
        PhoneNumber,
        Address,
        NationalID,
        TaxID,
        EmploymentStatus,
        AnnualIncome,
        CreatedAt,
        UpdatedAt
    )
    VALUES
    (
        'Customer ' + CAST(@i AS VARCHAR(10)),
        DATEADD(DAY, -1 * (7000 + @i), GETDATE()),
        'customer' + CAST(@i AS VARCHAR(10)) + '@gmail.com',
        '+99890' + RIGHT('0000000' + CAST(@i AS VARCHAR(10)), 7),
        'Address ' + CAST(@i AS VARCHAR(10)),
        100000 + @i,
        200000 + @i,
        CASE (@i % 4)
            WHEN 0 THEN 'Employed'
            WHEN 1 THEN 'Self-Employed'
            WHEN 2 THEN 'Business Owner'
            ELSE 'Unemployed'
        END,
        5000 + (@i * 10),
        GETDATE(),
        NULL
    );

    SET @i = @i + 1;
END;

INSERT INTO Loans
(
    CustomerID,
    LoanType,
    Amount,
    InterestRate,
    StartDate,
    EndDate,
    Status,
    BranchID
)
SELECT
    a.CustomerID,
    'Personal',
    25000,
    12.5,
    GETDATE(),
    DATEADD(YEAR, 2, GETDATE()),
    'Active',
    a.BranchID
FROM
(
    SELECT DISTINCT CustomerID, BranchID
    FROM Accounts
    WHERE CustomerID IN (5, 17, 61, 120, 250, 333, 444, 555, 777, 999)
) a;

select COUNT(*) as BranchCount from Branches;
select COUNT(*) as CustomerCount from Customers;


-- Insert to Accounts

select *from Accounts

DECLARE @i INT = 1;
DECLARE @BranchID INT;
DECLARE @CustomerID INT;
DECLARE @Balance DECIMAL(18,2);

WHILE @i <= 3000
BEGIN
    SET @CustomerID = ((@i - 1) / 2) + 1;

    SELECT @BranchID = BranchID
    FROM (
        SELECT BranchID,
               ROW_NUMBER() OVER (ORDER BY BranchID) AS rn
        FROM Branches
    ) b
    WHERE b.rn = ((@CustomerID - 1) % 20) + 1;

    IF @CustomerID = 11
        SET @Balance = 450000 + (@i % 2) * 50000
    ELSE IF @CustomerID = 25
        SET @Balance = 430000 + (@i % 2) * 50000
    ELSE IF @CustomerID = 103
        SET @Balance = 410000 + (@i % 2) * 50000
    ELSE
        SET @Balance = 1000 + (ABS(CHECKSUM(NEWID())) % 90000);

    INSERT INTO Accounts
    (
        CustomerID,
        AccountType,
        Balance,
        Currency,
        Status,
        BranchID,
        CreatedDate
    )
    VALUES
    (
        @CustomerID,
        CASE (@i % 3)
            WHEN 0 THEN 'Savings'
            WHEN 1 THEN 'Checking'
            ELSE 'Business'
        END,
        @Balance,
        'USD',
        'Active',
        @BranchID,
        GETDATE()
    );

    SET @i = @i + 1;
END;


-- Insert to Loans

DECLARE @i INT = 1;
DECLARE @CustomerID INT;
DECLARE @BranchID INT;
DECLARE @LoanType VARCHAR(50);
DECLARE @Amount DECIMAL(18,2);
DECLARE @InterestRate DECIMAL(5,2);
DECLARE @StartDate DATE;
DECLARE @EndDate DATE;
DECLARE @Status VARCHAR(20);

WHILE @i <= 1400
BEGIN
    SET @CustomerID = ((@i - 1) % 1500) + 1;

    -- Customerning accountidan branchni olamiz
    SELECT TOP 1 @BranchID = BranchID
    FROM Accounts
    WHERE CustomerID = @CustomerID
    ORDER BY AccountID;

    -- LoanType
    SET @LoanType =
        CASE (@i % 4)
            WHEN 0 THEN 'Mortgage'
            WHEN 1 THEN 'Personal'
            WHEN 2 THEN 'Auto'
            ELSE 'Business'
        END;

    -- Amount
    SET @Amount = 5000 + (ABS(CHECKSUM(NEWID())) % 200000);

    -- InterestRate
    SET @InterestRate = 5 + (ABS(CHECKSUM(NEWID())) % 15);

    -- StartDate va EndDate
    SET @StartDate = DATEADD(DAY, -1 * (ABS(CHECKSUM(NEWID())) % 1000), GETDATE());
    SET @EndDate = DATEADD(DAY, (ABS(CHECKSUM(NEWID())) % 1000) + 30, @StartDate);

    -- KPI 2 uchun maxsus customerlarga ko‘proq active loan
    IF @CustomerID IN (5, 17, 61, 120, 250, 333, 444, 555, 777, 999)
        SET @Status = 'Active'
    ELSE
        SET @Status =
            CASE (@i % 10)
                WHEN 0 THEN 'Closed'
                WHEN 1 THEN 'Pending'
                WHEN 2 THEN 'Defaulted'
                ELSE 'Active'
            END;

    INSERT INTO Loans
    (
        CustomerID,
        LoanType,
        Amount,
        InterestRate,
        StartDate,
        EndDate,
        Status,
        BranchID
    )
    VALUES
    (
        @CustomerID,
        @LoanType,
        @Amount,
        @InterestRate,
        @StartDate,
        @EndDate,
        @Status,
        @BranchID
    );

    SET @i = @i + 1;
END;

select *from Loans;

-- Insert to Transactions

DECLARE @i INT = 1;
DECLARE @AccountID INT;
DECLARE @TransactionType VARCHAR(50);
DECLARE @Amount DECIMAL(18,2);
DECLARE @TransactionDate DATETIME;
DECLARE @Status VARCHAR(20);
DECLARE @ReferenceNo VARCHAR(30);
DECLARE @Country VARCHAR(50);

WHILE @i <= 3600
BEGIN
    SET @AccountID = ((@i - 1) % 3000) + 1;

    SET @TransactionType =
        CASE (@i % 4)
            WHEN 0 THEN 'Deposit'
            WHEN 1 THEN 'Withdrawal'
            WHEN 2 THEN 'Transfer'
            ELSE 'Payment'
        END;

    SET @Amount = 100 + (ABS(CHECKSUM(NEWID())) % 50000);

    SET @TransactionDate = DATEADD(MINUTE, -1 * (ABS(CHECKSUM(NEWID())) % 50000), GETDATE());

    SET @Status =
        CASE (@i % 10)
            WHEN 0 THEN 'Pending'
            WHEN 1 THEN 'Failed'
            WHEN 2 THEN 'Cancelled'
            ELSE 'Completed'
        END;

    SET @ReferenceNo = 'TXN' + RIGHT('000000' + CAST(@i AS VARCHAR(10)), 6);

    SET @Country =
        CASE (@i % 6)
            WHEN 0 THEN 'Uzbekistan'
            WHEN 1 THEN 'Kazakhstan'
            WHEN 2 THEN 'Turkey'
            WHEN 3 THEN 'UAE'
            WHEN 4 THEN 'Germany'
            ELSE 'South Korea'
        END;

    INSERT INTO Transactions
    (
        AccountID,
        TransactionType,
        Amount,
        Currency,
        TransactionDate,
        Status,
        ReferenceNo,
        Country
    )
    VALUES
    (
        @AccountID,
        @TransactionType,
        @Amount,
        'USD',
        @TransactionDate,
        @Status,
        @ReferenceNo,
        @Country
    );

    SET @i = @i + 1;
END;

DECLARE @Now DATETIME = GETDATE();

-- Customer 11
INSERT INTO Transactions (AccountID, TransactionType, Amount, Currency, TransactionDate, Status, ReferenceNo, Country)
SELECT TOP 1 AccountID, 'Transfer', 15000, 'USD', DATEADD(MINUTE, -50, @Now), 'Completed', 'KPI500001', 'Uzbekistan'
FROM Accounts WHERE CustomerID = 11 ORDER BY AccountID;

INSERT INTO Transactions (AccountID, TransactionType, Amount, Currency, TransactionDate, Status, ReferenceNo, Country)
SELECT TOP 1 AccountID, 'Transfer', 18000, 'USD', DATEADD(MINUTE, -20, @Now), 'Completed', 'KPI500002', 'Uzbekistan'
FROM Accounts WHERE CustomerID = 11 ORDER BY AccountID;

-- Customer 25
INSERT INTO Transactions (AccountID, TransactionType, Amount, Currency, TransactionDate, Status, ReferenceNo, Country)
SELECT TOP 1 AccountID, 'Payment', 12000, 'USD', DATEADD(MINUTE, -55, @Now), 'Completed', 'KPI500003', 'Turkey'
FROM Accounts WHERE CustomerID = 25 ORDER BY AccountID;

INSERT INTO Transactions (AccountID, TransactionType, Amount, Currency, TransactionDate, Status, ReferenceNo, Country)
SELECT TOP 1 AccountID, 'Payment', 17000, 'USD', DATEADD(MINUTE, -15, @Now), 'Completed', 'KPI500004', 'Turkey'
FROM Accounts WHERE CustomerID = 25 ORDER BY AccountID;

-- Customer 103
INSERT INTO Transactions (AccountID, TransactionType, Amount, Currency, TransactionDate, Status, ReferenceNo, Country)
SELECT TOP 1 AccountID, 'Withdrawal', 22000, 'USD', DATEADD(MINUTE, -45, @Now), 'Completed', 'KPI500005', 'UAE'
FROM Accounts WHERE CustomerID = 103 ORDER BY AccountID;

INSERT INTO Transactions (AccountID, TransactionType, Amount, Currency, TransactionDate, Status, ReferenceNo, Country)
SELECT TOP 1 AccountID, 'Withdrawal', 14000, 'USD', DATEADD(MINUTE, -10, @Now), 'Completed', 'KPI500006', 'UAE'
FROM Accounts WHERE CustomerID = 103 ORDER BY AccountID;

DECLARE @Now2 DATETIME = GETDATE();

-- Customer 250
INSERT INTO Transactions (AccountID, TransactionType, Amount, Currency, TransactionDate, Status, ReferenceNo, Country)
SELECT TOP 1 AccountID, 'Transfer', 8000, 'USD', DATEADD(MINUTE, -9, @Now2), 'Completed', 'KPI600001', 'Uzbekistan'
FROM Accounts WHERE CustomerID = 250 ORDER BY AccountID;

INSERT INTO Transactions (AccountID, TransactionType, Amount, Currency, TransactionDate, Status, ReferenceNo, Country)
SELECT TOP 1 AccountID, 'Transfer', 9000, 'USD', DATEADD(MINUTE, -3, @Now2), 'Completed', 'KPI600002', 'Germany'
FROM Accounts WHERE CustomerID = 250 ORDER BY AccountID;

-- Customer 777
INSERT INTO Transactions (AccountID, TransactionType, Amount, Currency, TransactionDate, Status, ReferenceNo, Country)
SELECT TOP 1 AccountID, 'Payment', 11000, 'USD', DATEADD(MINUTE, -8, @Now2), 'Completed', 'KPI600003', 'Turkey'
FROM Accounts WHERE CustomerID = 777 ORDER BY AccountID;

INSERT INTO Transactions (AccountID, TransactionType, Amount, Currency, TransactionDate, Status, ReferenceNo, Country)
SELECT TOP 1 AccountID, 'Payment', 13000, 'USD', DATEADD(MINUTE, -2, @Now2), 'Completed', 'KPI600004', 'UAE'
FROM Accounts WHERE CustomerID = 777 ORDER BY AccountID;

select *from Transactions


-- Insert to FraudDetection

INSERT INTO FraudDetection (CustomerID, TransactionID, RiskLevel, ReportedDate)
SELECT
    a.CustomerID,
    t.TransactionID,
    'High',
    GETDATE()
FROM Transactions t
JOIN Accounts a
    ON t.AccountID = a.AccountID
WHERE t.ReferenceNo IN
(
    'KPI500001','KPI500002','KPI500003','KPI500004','KPI500005','KPI500006',
    'KPI600001','KPI600002','KPI600003','KPI600004'
);

INSERT INTO FraudDetection (CustomerID, TransactionID, RiskLevel, ReportedDate)
SELECT TOP 470
    a.CustomerID,
    t.TransactionID,
    CASE ABS(CHECKSUM(NEWID())) % 3
        WHEN 0 THEN 'Low'
        WHEN 1 THEN 'Medium'
        ELSE 'High'
    END AS RiskLevel,
    DATEADD(DAY, -1 * (ABS(CHECKSUM(NEWID())) % 30), GETDATE()) AS ReportedDate
FROM Transactions t
JOIN Accounts a
    ON t.AccountID = a.AccountID
WHERE t.TransactionID NOT IN (
    SELECT TransactionID
    FROM FraudDetection
)
ORDER BY NEWID();

UPDATE Branches
SET Country = 'Kazakhstan'
WHERE BranchID = 2;

UPDATE Branches
SET Country = 'Turkey'
WHERE BranchID = 3;

UPDATE Branches
SET Country = 'UAE'
WHERE BranchID = 4;

INSERT INTO Accounts
    (CustomerID, AccountType, Balance, Currency, Status, BranchID)
VALUES
    (50, 'Savings', 15000, 'USD', 'Active', 1),
    (50, 'Checking', 12000, 'USD', 'Active', 2);

INSERT INTO Transactions
    (AccountID, TransactionType, Amount, Currency, TransactionDate, Status, ReferenceNo)
VALUES
    (3001, 'Transfer', 5000, 'USD', '2026-06-25 10:00:00', 'Completed', 'REF60001'),
    (3002, 'Transfer', 7000, 'USD', '2026-06-25 10:07:00', 'Completed', 'REF60002');

UPDATE Branches SET Country = 'Kazakhstan' WHERE BranchID = 2;
UPDATE Branches SET Country = 'Turkey' WHERE BranchID = 3;
UPDATE Branches SET Country = 'UAE' WHERE BranchID = 4;

INSERT INTO Accounts (CustomerID, AccountType, Balance, Currency, Status, BranchID)
VALUES
-- Customer 120
(120, 'Savings', 18000, 'USD', 'Active', 1),
(120, 'Checking',  9000, 'USD', 'Active', 2),

-- Customer 250
(250, 'Savings', 22000, 'USD', 'Active', 1),
(250, 'Checking', 11000, 'USD', 'Active', 3),

-- Customer 777
(777, 'Savings', 25000, 'USD', 'Active', 1),
(777, 'Checking', 13000, 'USD', 'Active', 4);

INSERT INTO Transactions
    (AccountID, TransactionType, Amount, Currency, TransactionDate, Status, ReferenceNo)
VALUES
-- Customer 120
(3003, 'Transfer', 4000, 'USD', '2026-06-25 11:00:00', 'Completed', 'REF61001'),
(3004, 'Transfer', 6500, 'USD', '2026-06-25 11:08:00', 'Completed', 'REF61002'),

-- Customer 250
(3005, 'Transfer', 5200, 'USD', '2026-06-25 12:00:00', 'Completed', 'REF62001'),
(3006, 'Transfer', 7100, 'USD', '2026-06-25 12:06:00', 'Completed', 'REF62002'),

-- Customer 777
(3007, 'Transfer', 8300, 'USD', '2026-06-25 13:00:00', 'Completed', 'REF63001'),
(3008, 'Transfer', 9100, 'USD', '2026-06-25 13:09:00', 'Completed', 'REF63002');

-- TASKS

-- Task1. ●	Barcha hisoblari bo‘yicha eng yuqori umumiy balansga ega top 3 ta mijoz

select top 3
	c.CustomerID,
	c.FullName,
	SUM(a.Balance) as TotalBalance
from Customers c
join Accounts a
on c.CustomerID=a.CustomerID
group by c.CustomerID, c.FullName
order by TotalBalance desc;


-- Task2. ●	Birdan ortiq faol kreditga ega bo‘lgan mijozlar

select *from Customers
select *from Loans

select 
	c.CustomerID,
	c.FullName,
	Count(l.LoanID) as ActiveLoanCnt
from Customers c
join Loans l
on c.CustomerID=l.CustomerID
where l.Status = 'Active'
group by c.CustomerID, c.FullName
having Count(l.LoanID) > 1
order by ActiveLoanCnt desc;


--Task3. ●	Firibgarlik (fraud) deb belgilangan tranzaksiyalar

select *from FraudDetection
select *from Transactions
select *from Customers

select 
	f.FraudID,
	c.CustomerID,
	c.FullName,
	t.TransactionID,
	t.TransactionType,
	t.Amount,
	t.TransactionDate,
	f.RiskLevel,
	f.ReportedDate
from FraudDetection f
join Transactions t
on f.TransactionID=t.TransactionID
join Customers c
on f.CustomerID=c.CustomerID
order by f.ReportedDate desc;


--Task4. ●	Har bir filial bo‘yicha berilgan jami kredit miqdori

select *from Branches
select *from Loans

;with CustomerBranch as (
	select 
		CustomerID,
		MIN(BranchID) as BranchID
	from Accounts
	group by CustomerID
)
select 
	b.BranchID,
	b.BranchName,
	Sum(l.Amount) as TotalLoanAmount
from Loans l
join CustomerBranch c
on l.CustomerID=c.CustomerID
join Branches b
on c.BranchID=b.BranchID
group by b.BranchID, b.BranchName
order by TotalLoanAmount desc;


--Task5. ●	Qisqa vaqt ichida (1 soatdan kam) bir nechta katta (10,000$ dan yuqori) tranzaksiyalar qilgan mijozlar

select distinct
	c.CustomerID,
	c.FullName
from Transactions t1
join Transactions t2
    on t1.TransactionID < t2.TransactionID and t1.AccountID = t2.AccountID
join Accounts a
    on t1.AccountID = a.AccountID
join Customers c
    on a.CustomerID = c.CustomerID
where ABS(DATEDIFF(MINUTE, t1.TransactionDate, t2.TransactionDate)) < 60 
and t1.Amount > 10000 and t2.Amount > 10000;



--Task6  ●	10 daqiqa ichida turli davlatlardan tranzaksiya qilgan mijozlar (firibgarlik uchun odatiy signal)


select distinct
	c.CustomerID,
	c.FullName
from Transactions t1
join Accounts a1
    on t1.AccountID=a1.AccountID
join Branches b1
    on a1.BranchID=b1.BranchID
join Transactions t2
    on t1.TransactionID<t2.TransactionID
join Accounts a2
    on t2.AccountID=a2.AccountID
join Branches b2
    on a2.BranchID=b2.BranchID 
join Customers c
    on a1.CustomerID=c.CustomerID
where a1.CustomerID = a2.CustomerID
and b1.Country<>b2.Country 
and ABS(DATEDIFF(MINUTE, t1.TransactionDate, t2.TransactionDate)) <= 10;