DROP DATABASE IF EXISTS pharmacy_db;
CREATE DATABASE pharmacy_db CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE pharmacy_db;

SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;

DROP TABLE IF EXISTS invoice_items;
DROP TABLE IF EXISTS invoices;
DROP TABLE IF EXISTS stock_transfers;
DROP TABLE IF EXISTS stock_imports;
DROP TABLE IF EXISTS medicines;
DROP TABLE IF EXISTS staffs;
DROP TABLE IF EXISTS categories;
DROP TABLE IF EXISTS branches;

CREATE TABLE branches (
    id BIGINT NOT NULL AUTO_INCREMENT,
    code VARCHAR(255) NOT NULL,
    name VARCHAR(255) NOT NULL,
    address VARCHAR(255) DEFAULT NULL,
    phone VARCHAR(255) DEFAULT NULL,
    PRIMARY KEY (id),
    UNIQUE KEY uk_branches_code (code)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE categories (
    id BIGINT NOT NULL AUTO_INCREMENT,
    name VARCHAR(255) NOT NULL,
    description VARCHAR(255) DEFAULT NULL,
    PRIMARY KEY (id),
    UNIQUE KEY uk_categories_name (name)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE staffs (
    id BIGINT NOT NULL AUTO_INCREMENT,
    full_name VARCHAR(255) NOT NULL,
    username VARCHAR(255) NOT NULL,
    password VARCHAR(255) NOT NULL,
    role ENUM('CEO','MANAGER','STAFF') NOT NULL,
    phone VARCHAR(255) DEFAULT NULL,
    active BIT(1) DEFAULT b'1',
    branch_id BIGINT DEFAULT NULL,
    PRIMARY KEY (id),
    UNIQUE KEY uk_staffs_username (username),
    KEY fk_staff_branch (branch_id),
    CONSTRAINT fk_staff_branch FOREIGN KEY (branch_id) REFERENCES branches (id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE medicines (
    id BIGINT NOT NULL AUTO_INCREMENT,
    code VARCHAR(255) NOT NULL,
    name VARCHAR(255) NOT NULL,
    unit VARCHAR(255) DEFAULT NULL,
    manufacturer VARCHAR(255) DEFAULT NULL,
    description VARCHAR(255) DEFAULT NULL,
    expiry_date DATE DEFAULT NULL,
    quantity INT NOT NULL,
    import_price DECIMAL(15,2) NOT NULL,
    sale_price DECIMAL(15,2) NOT NULL,
    category_id BIGINT DEFAULT NULL,
    branch_id BIGINT DEFAULT NULL,
    PRIMARY KEY (id),
    UNIQUE KEY uk_medicines_code_branch (code, branch_id),
    KEY fk_medicine_category (category_id),
    KEY fk_medicine_branch (branch_id),
    CONSTRAINT fk_medicine_category FOREIGN KEY (category_id) REFERENCES categories (id),
    CONSTRAINT fk_medicine_branch FOREIGN KEY (branch_id) REFERENCES branches (id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE invoices (
    id BIGINT NOT NULL AUTO_INCREMENT,
    invoice_code VARCHAR(255) NOT NULL,
    customer_name VARCHAR(255) DEFAULT NULL,
    customer_phone VARCHAR(255) DEFAULT NULL,
    total_amount DECIMAL(15,2) NOT NULL,
    created_at DATETIME(6) DEFAULT NULL,
    branch_id BIGINT DEFAULT NULL,
    staff_id BIGINT DEFAULT NULL,
    PRIMARY KEY (id),
    UNIQUE KEY uk_invoices_code (invoice_code),
    KEY fk_invoice_branch (branch_id),
    KEY fk_invoice_staff (staff_id),
    CONSTRAINT fk_invoice_branch FOREIGN KEY (branch_id) REFERENCES branches (id),
    CONSTRAINT fk_invoice_staff FOREIGN KEY (staff_id) REFERENCES staffs (id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE invoice_items (
    id BIGINT NOT NULL AUTO_INCREMENT,
    invoice_id BIGINT DEFAULT NULL,
    medicine_id BIGINT DEFAULT NULL,
    quantity INT NOT NULL,
    unit_price DECIMAL(15,2) NOT NULL,
    line_total DECIMAL(15,2) NOT NULL,
    PRIMARY KEY (id),
    KEY fk_invoice_item_invoice (invoice_id),
    KEY fk_invoice_item_medicine (medicine_id),
    CONSTRAINT fk_invoice_item_invoice FOREIGN KEY (invoice_id) REFERENCES invoices (id),
    CONSTRAINT fk_invoice_item_medicine FOREIGN KEY (medicine_id) REFERENCES medicines (id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE stock_imports (
    id BIGINT NOT NULL AUTO_INCREMENT,
    created_at DATETIME(6) DEFAULT NULL,
    medicine_id BIGINT DEFAULT NULL,
    staff_id BIGINT DEFAULT NULL,
    quantity INT NOT NULL,
    import_price DECIMAL(15,2) NOT NULL,
    note VARCHAR(255) DEFAULT NULL,
    PRIMARY KEY (id),
    KEY fk_stock_import_medicine (medicine_id),
    KEY fk_stock_import_staff (staff_id),
    CONSTRAINT fk_stock_import_medicine FOREIGN KEY (medicine_id) REFERENCES medicines (id),
    CONSTRAINT fk_stock_import_staff FOREIGN KEY (staff_id) REFERENCES staffs (id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE stock_transfers (
    id BIGINT NOT NULL AUTO_INCREMENT,
    created_at DATETIME(6) DEFAULT NULL,
    medicine_id BIGINT DEFAULT NULL,
    from_branch_id BIGINT DEFAULT NULL,
    to_branch_id BIGINT DEFAULT NULL,
    staff_id BIGINT DEFAULT NULL,
    quantity INT NOT NULL,
    note VARCHAR(255) DEFAULT NULL,
    PRIMARY KEY (id),
    KEY fk_stock_transfer_medicine (medicine_id),
    KEY fk_stock_transfer_from_branch (from_branch_id),
    KEY fk_stock_transfer_to_branch (to_branch_id),
    KEY fk_stock_transfer_staff (staff_id),
    CONSTRAINT fk_stock_transfer_medicine FOREIGN KEY (medicine_id) REFERENCES medicines (id),
    CONSTRAINT fk_stock_transfer_from_branch FOREIGN KEY (from_branch_id) REFERENCES branches (id),
    CONSTRAINT fk_stock_transfer_to_branch FOREIGN KEY (to_branch_id) REFERENCES branches (id),
    CONSTRAINT fk_stock_transfer_staff FOREIGN KEY (staff_id) REFERENCES staffs (id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

INSERT INTO branches (id, code, name, address, phone) VALUES
(1, 'CN001', 'Chi nhánh Cầu Giấy', '123 Xuân Thuỷ, Cầu Giấy, Hà Nội', '0241111111'),
(2, 'CN002', 'Chi nhánh Thanh Xuân', '456 Nguyễn Trãi, Thanh Xuân, Hà Nội', '0242222222'),
(3, 'CN003', 'Chi nhánh Hoàn Kiếm', '89 Hàng Bông, Hoàn Kiếm, Hà Nội', '0243333333');

INSERT INTO categories (id, name, description) VALUES
(1, 'Giảm đau - Hạ sốt', 'Thuốc giảm đau, hạ sốt thông dụng'),
(2, 'Kháng sinh', 'Thuốc kháng sinh theo đơn'),
(3, 'Vitamin', 'Vitamin và khoáng chất'),
(4, 'Tiêu hóa', 'Thuốc dạ dày, đường ruột, men vi sinh'),
(5, 'Hô hấp', 'Thuốc ho, cảm, sổ mũi'),
(6, 'Da liễu', 'Thuốc bôi ngoài da'),
(7, 'Tim mạch', 'Thuốc huyết áp, tim mạch'),
(8, 'Tiểu đường', 'Thuốc hỗ trợ điều trị tiểu đường');

INSERT INTO staffs (id, full_name, username, password, role, phone, active, branch_id) VALUES
(1, 'Nguyễn Trung Kiên Admin', 'admin', '$2y$10$/UNM6TUndV20/pAmJ4P/NOPvGMxC5bxO924HaUIFP6x50DU/FTpXW', 'CEO', '0901000001', b'1', 1),
(2, 'Trần Thị CEO Chi Nhánh', 'manager1', '$2y$10$gRxGOxQoGyxrawjNJXeruuc1KgJOp2EAJ//p6O9Q9BfTsC.AAs07y', 'MANAGER', '0901000002', b'1', 1),
(3, 'Phạm Văn CEO Chi Nhánh', 'manager2', '$2y$10$gRxGOxQoGyxrawjNJXeruuc1KgJOp2EAJ//p6O9Q9BfTsC.AAs07y', 'MANAGER', '0901000003', b'1', 2),
(4, 'Lê Thu Hà', 'staff1', '$2y$10$kPiU1FmoNPS/lyb.Jc7oMuqFFa14O5XOWwAatCgq22AiMYILqqWhK', 'STAFF', '0901000004', b'1', 1),
(5, 'Hoàng Văn Nam', 'staff2', '$2y$10$kPiU1FmoNPS/lyb.Jc7oMuqFFa14O5XOWwAatCgq22AiMYILqqWhK', 'STAFF', '0901000005', b'1', 1),
(6, 'Đỗ Minh Anh', 'staff3', '$2y$10$kPiU1FmoNPS/lyb.Jc7oMuqFFa14O5XOWwAatCgq22AiMYILqqWhK', 'STAFF', '0901000006', b'1', 2),
(7, 'Ngô Gia Bảo', 'staff4', '$2y$10$kPiU1FmoNPS/lyb.Jc7oMuqFFa14O5XOWwAatCgq22AiMYILqqWhK', 'STAFF', '0901000007', b'1', 3),
(8, 'Nhân viên nghỉ việc', 'inactive1', '$2y$10$uHzpxuAieSI.v5bPwXXhqOJ/sC09juLvDjKSpbhDyEYxqVI8CitQG', 'STAFF', '0901000008', b'0', 1);

INSERT INTO medicines (id, code, name, unit, manufacturer, description, expiry_date, quantity, import_price, sale_price, category_id, branch_id) VALUES
(1, 'TH001', 'Paracetamol 500mg', 'Hộp', 'DHG Pharma', 'Giảm đau, hạ sốt', '2027-12-31', 150, 12000.00, 18000.00, 1, 1),
(2, 'TH002', 'Efferalgan 500mg', 'Hộp', 'Upsa', 'Giảm đau, hạ sốt', '2027-10-15', 90, 25000.00, 32000.00, 1, 1),
(3, 'TH003', 'Hapacol 650', 'Hộp', 'DHG Pharma', 'Hạ sốt cho người lớn', '2028-03-01', 200, 18000.00, 26000.00, 1, 1),
(4, 'TH004', 'Amoxicillin 500mg', 'Hộp', 'Traphaco', 'Kháng sinh phổ rộng', '2027-08-20', 80, 35000.00, 48000.00, 2, 1),
(5, 'TH005', 'Augmentin 1g', 'Hộp', 'GSK', 'Kháng sinh mạnh', '2027-07-10', 45, 85000.00, 98000.00, 2, 1),
(6, 'TH006', 'Vitamin C 1000mg', 'Lọ', 'Imexpharm', 'Tăng sức đề kháng', '2028-01-30', 120, 45000.00, 60000.00, 3, 1),
(7, 'TH007', 'Centrum', 'Hộp', 'Pfizer', 'Vitamin tổng hợp', '2028-04-15', 50, 180000.00, 220000.00, 3, 1),
(8, 'TH008', 'Smecta', 'Hộp', 'Ipsen', 'Hỗ trợ tiêu chảy', '2027-11-11', 95, 70000.00, 85000.00, 4, 1),
(9, 'TH009', 'Enterogermina', 'Hộp', 'Sanofi', 'Men vi sinh', '2027-09-09', 70, 85000.00, 105000.00, 4, 1),
(10, 'TH010', 'Omeprazole 20mg', 'Hộp', 'Pymepharco', 'Hỗ trợ dạ dày', '2027-11-19', 100, 32000.00, 45000.00, 4, 1),
(11, 'TH011', 'Terpin Codein', 'Hộp', 'DHG Pharma', 'Giảm ho', '2027-06-30', 110, 18000.00, 25000.00, 5, 1),
(12, 'TH012', 'Decolgen', 'Hộp', 'United', 'Cảm cúm, sổ mũi', '2027-12-01', 130, 22000.00, 30000.00, 5, 1),
(13, 'TH013', 'Bepanthen Ointment', 'Tuýp', 'Bayer', 'Kem bôi da', '2028-02-20', 40, 75000.00, 95000.00, 6, 1),
(14, 'TH014', 'Gentrisone', 'Tuýp', 'Imexpharm', 'Thuốc bôi ngoài da', '2027-05-18', 55, 28000.00, 38000.00, 6, 1),
(15, 'TH015', 'Amlodipine 5mg', 'Hộp', 'Traphaco', 'Hỗ trợ huyết áp', '2028-01-05', 75, 40000.00, 52000.00, 7, 2),
(16, 'TH016', 'Bisoprolol 5mg', 'Hộp', 'Imexpharm', 'Thuốc tim mạch', '2027-10-10', 65, 55000.00, 68000.00, 7, 2),
(17, 'TH017', 'Metformin 500mg', 'Hộp', 'DHG Pharma', 'Hỗ trợ tiểu đường', '2027-09-25', 85, 30000.00, 42000.00, 8, 2),
(18, 'TH018', 'Glucophage 850mg', 'Hộp', 'Merck', 'Điều trị tiểu đường', '2027-08-08', 45, 95000.00, 120000.00, 8, 2),
(19, 'TH019', 'Panadol Extra', 'Hộp', 'GSK', 'Giảm đau nhanh', '2027-12-31', 140, 28000.00, 36000.00, 1, 2),
(20, 'TH020', 'Zinc 10mg', 'Hộp', 'Traphaco', 'Bổ sung kẽm', '2028-05-12', 95, 35000.00, 47000.00, 3, 2),
(21, 'TH021', 'Natri Clorid 0.9%', 'Chai', 'Bidiphar', 'Rửa mũi', '2027-12-15', 180, 8000.00, 12000.00, 5, 3),
(22, 'TH022', 'Acemuc 200mg', 'Hộp', 'Sanofi', 'Long đờm', '2027-07-22', 60, 42000.00, 55000.00, 5, 3),
(23, 'TH023', 'Berberin', 'Hộp', 'Nam Dược', 'Rối loạn tiêu hóa', '2027-10-30', 75, 15000.00, 22000.00, 4, 3),
(24, 'TH024', 'Vitamin B1', 'Hộp', 'Domesco', 'Bổ sung vitamin B1', '2027-06-10', 8, 12000.00, 18000.00, 3, 3),
(25, 'TH025', 'Clorpheniramin 4mg', 'Hộp', 'DHG Pharma', 'Dị ứng, sổ mũi', '2026-04-20', 6, 10000.00, 15000.00, 5, 3),
(26, 'TH026', 'Cefixim 200mg', 'Hộp', 'Imexpharm', 'Kháng sinh', '2026-04-18', 9, 55000.00, 72000.00, 2, 2),
(27, 'TH027', 'Hoạt huyết dưỡng não', 'Hộp', 'Traphaco', 'Hỗ trợ tuần hoàn não', '2026-05-02', 12, 48000.00, 65000.00, 7, 2),
(28, 'TH028', 'Men tiêu hóa Bio', 'Hộp', 'Hậu Giang', 'Hỗ trợ tiêu hóa trẻ em', '2026-04-25', 4, 28000.00, 39000.00, 4, 1);

INSERT INTO invoices (id, invoice_code, customer_name, customer_phone, total_amount, created_at, branch_id, staff_id) VALUES
(1, 'HD-000001', 'Nguyễn Thị Lan', '0911111111', 61000.00, '2026-04-01 08:30:00.000000', 1, 4),
(2, 'HD-000002', 'Trần Văn Bình', '0922222222', 105000.00, '2026-04-01 10:15:00.000000', 1, 5),
(3, 'HD-000003', 'Lê Thị Hoa', '0933333333', 220000.00, '2026-04-01 14:20:00.000000', 1, 4),
(4, 'HD-000004', 'Phạm Văn Nam', '0944444444', 96000.00, '2026-04-02 09:10:00.000000', 1, 5),
(5, 'HD-000005', 'Đỗ Thị Mai', '0955555555', 141000.00, '2026-04-02 16:45:00.000000', 2, 6),
(6, 'HD-000006', 'Khách lẻ', '0909000001', 86000.00, '2026-04-03 11:30:00.000000', 1, 4),
(7, 'HD-000007', 'Nguyễn Văn Tùng', '0909000002', 120000.00, '2026-04-03 15:05:00.000000', 2, 6),
(8, 'HD-000008', 'Hoàng Thị Hạnh', '0909000003', 95000.00, '2026-04-04 08:50:00.000000', 1, 5),
(9, 'HD-000009', 'Đặng Minh Đức', '0909000004', 54000.00, '2026-04-04 10:10:00.000000', 3, 7),
(10, 'HD-000010', 'Bùi Thu Trang', '0909000005', 144000.00, '2026-04-04 16:20:00.000000', 2, 6);

INSERT INTO invoice_items (id, invoice_id, medicine_id, quantity, unit_price, line_total) VALUES
(1, 1, 1, 2, 18000.00, 36000.00),
(2, 1, 11, 1, 25000.00, 25000.00),
(3, 2, 9, 1, 105000.00, 105000.00),
(4, 3, 7, 1, 220000.00, 220000.00),
(5, 4, 4, 1, 48000.00, 48000.00),
(6, 4, 12, 1, 30000.00, 30000.00),
(7, 4, 1, 1, 18000.00, 18000.00),
(8, 5, 17, 1, 42000.00, 42000.00),
(9, 5, 20, 1, 47000.00, 47000.00),
(10, 5, 19, 1, 36000.00, 36000.00),
(11, 6, 3, 2, 26000.00, 52000.00),
(12, 6, 12, 1, 30000.00, 30000.00),
(13, 7, 18, 1, 120000.00, 120000.00),
(14, 8, 13, 1, 95000.00, 95000.00),
(15, 9, 21, 2, 12000.00, 24000.00),
(16, 9, 25, 2, 15000.00, 30000.00),
(17, 10, 15, 1, 52000.00, 52000.00),
(18, 10, 16, 1, 68000.00, 68000.00),
(19, 10, 27, 1, 65000.00, 65000.00);

INSERT INTO stock_imports (id, created_at, medicine_id, staff_id, quantity, import_price, note) VALUES
(1, '2026-03-28 09:00:00.000000', 1, 2, 100, 12000.00, 'Nhập thêm Paracetamol cho chi nhánh 1'),
(2, '2026-03-28 09:10:00.000000', 3, 2, 120, 18000.00, 'Nhập Hapacol'),
(3, '2026-03-29 10:30:00.000000', 15, 3, 60, 40000.00, 'Nhập thuốc tim mạch'),
(4, '2026-03-29 10:45:00.000000', 17, 3, 80, 30000.00, 'Nhập Metformin'),
(5, '2026-03-30 14:00:00.000000', 21, 1, 150, 8000.00, 'Nhập Natri Clorid cho chi nhánh 3'),
(6, '2026-03-31 08:00:00.000000', 25, 1, 30, 10000.00, 'Nhập Clorpheniramin sắp hết');

INSERT INTO stock_transfers (id, created_at, medicine_id, from_branch_id, to_branch_id, staff_id, quantity, note) VALUES
(1, '2026-04-01 16:00:00.000000', 19, 2, 1, 3, 20, 'Chuyển Panadol Extra sang chi nhánh 1'),
(2, '2026-04-02 11:30:00.000000', 20, 2, 3, 3, 15, 'Chuyển Zinc sang chi nhánh 3'),
(3, '2026-04-03 09:15:00.000000', 8, 1, 3, 2, 10, 'Chuyển Smecta cho chi nhánh 3');

ALTER TABLE branches AUTO_INCREMENT = 4;
ALTER TABLE categories AUTO_INCREMENT = 9;
ALTER TABLE staffs AUTO_INCREMENT = 9;
ALTER TABLE medicines AUTO_INCREMENT = 29;
ALTER TABLE invoices AUTO_INCREMENT = 11;
ALTER TABLE invoice_items AUTO_INCREMENT = 20;
ALTER TABLE stock_imports AUTO_INCREMENT = 7;
ALTER TABLE stock_transfers AUTO_INCREMENT = 4;

SET FOREIGN_KEY_CHECKS = 1;

-- TAI KHOAN TEST
-- admin / admin123
-- manager1 / manager123 (Quan ly cua hang)
-- manager2 / manager123 (Quan ly cua hang)
-- staff1 / staff123
-- staff2 / staff123
-- staff3 / staff123
-- staff4 / staff123
-- inactive1 / 123456 (tai khoan nay dang bi khoa: active = false)

-- LENH TEST NHANH
-- SELECT * FROM branches;
-- SELECT * FROM categories;
-- SELECT id, full_name, username, role, active, branch_id FROM staffs;
-- SELECT id, code, name, quantity, sale_price, category_id, branch_id FROM medicines;
-- SELECT * FROM invoices;
-- SELECT * FROM invoice_items;
