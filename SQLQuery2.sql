-- =============================================
-- KHỞI TẠO DATABASE VÀ CẤU HÌNH BAN ĐẦU (T-SQL)
-- =============================================
USE master;
GO

-- Xóa Database cũ nếu tồn tại
IF DB_ID('qlhs') IS NOT NULL
BEGIN
    ALTER DATABASE qlhs SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE qlhs;
END
GO

-- Tạo Database mới với Collation tiếng Việt
CREATE DATABASE qlhs COLLATE Vietnamese_CI_AS;
GO

USE qlhs;
GO

-- 2. Xóa các bảng (theo thứ tự phụ thuộc ngược)
DROP TABLE IF EXISTS users;
DROP TABLE IF EXISTS phuhuynh;
DROP TABLE IF EXISTS diem;
DROP TABLE IF EXISTS thoikhoabieu;
DROP TABLE IF EXISTS hocsinh;
DROP TABLE IF EXISTS lop;
DROP TABLE IF EXISTS giaovien;
DROP TABLE IF EXISTS monhoc;
GO

-- =============================================
-- PHẦN 1: TẠO CÁC BẢNG (DDL CHO T-SQL)
-- =============================================

-- 📚 BẢNG MÔN HỌC
CREATE TABLE monhoc (
    id INT NOT NULL IDENTITY(1,1),
    tenmonhoc NVARCHAR(100) UNIQUE NOT NULL,
    PRIMARY KEY (id)
);
GO

-- 🧑‍🏫 BẢNG GIÁO VIÊN
CREATE TABLE giaovien (
    magv INT NOT NULL IDENTITY(1,1),
    hoten NVARCHAR(100),
    sodt VARCHAR(15),
    chuyenmon NVARCHAR(50), 
    chunhiemlop NVARCHAR(20),
    monhoc_id INT,
    PRIMARY KEY (magv),
    FOREIGN KEY (monhoc_id) REFERENCES monhoc(id)
);
GO

-- 🏫 BẢNG LỚP HỌC
CREATE TABLE lop (
    id INT NOT NULL IDENTITY(1,1),
    tenlop NVARCHAR(20) UNIQUE NOT NULL,
    magv_chunhiem INT,
    PRIMARY KEY (id),
    FOREIGN KEY (magv_chunhiem) REFERENCES giaovien(magv) ON DELETE SET NULL
);
GO

-- 👨‍🎓 BẢNG HỌC SINH
CREATE TABLE hocsinh (
    mahs INT NOT NULL IDENTITY(1,1),
    holot NVARCHAR(50),
    ten NVARCHAR(50),
    lop_id INT,
    gioitinh NVARCHAR(10),
    ngaysinh DATE,
    chucvu NVARCHAR(50),
    hanhkiem NVARCHAR(20),
    hocluc NVARCHAR(20),
    tbcanam FLOAT,
    diachi NVARCHAR(255),
    dienthoai VARCHAR(20),
    PRIMARY KEY (mahs),
    FOREIGN KEY (lop_id) REFERENCES lop(id)
);
GO

-- 👨‍👩‍👧 BẢNG PHỤ HUYNH
CREATE TABLE phuhuynh (
    id INT NOT NULL IDENTITY(1,1),
    mahs INT NOT NULL, 	
    tenphu NVARCHAR(100) NOT NULL,
    sdt VARCHAR(20),
    diachi NVARCHAR(255),
    quanhe NVARCHAR(50), 	
    nghenghiep NVARCHAR(100),
    PRIMARY KEY (id), 	
    FOREIGN KEY (mahs) REFERENCES hocsinh(mahs) ON DELETE CASCADE
);
GO

-- 📚 BẢNG ĐIỂM (ĐÃ SỬA: Thêm cột hocky)
CREATE TABLE diem (
    id INT NOT NULL IDENTITY(1,1),
    mahs INT NOT NULL, 	
    monhoc_id INT NOT NULL, 
    hocky TINYINT NOT NULL DEFAULT 1, -- 1: Học kỳ 1, 2: Học kỳ 2
    mieng FLOAT,
    kt_15p FLOAT, 	
    kt_15p_lan2 FLOAT, 	
    giua_ky FLOAT,
    cuoi_ky FLOAT,
    dtb_mon FLOAT, 	
    PRIMARY KEY (id), 	
    FOREIGN KEY (mahs) REFERENCES hocsinh(mahs) ON DELETE CASCADE,
    FOREIGN KEY (monhoc_id) REFERENCES monhoc(id) ON DELETE CASCADE,
    -- >> RÀNG BUỘC UNIQUE MỚI <<
    CONSTRAINT uk_diem_hs_mh_hk UNIQUE (mahs, monhoc_id, hocky) -- Chỉ 1 bản ghi cho mỗi HS, Môn học, Học kỳ
);
GO

-- 📅 BẢNG THỜI KHÓA BIỂU
CREATE TABLE thoikhoabieu (
    id INT NOT NULL IDENTITY(1,1),
    lop_id INT NOT NULL, 	
    thu NVARCHAR(20) NOT NULL, 	
    tiet INT NOT NULL, 	
    monhoc_id INT NOT NULL, 	
    magv INT NOT NULL, 	
    PRIMARY KEY (id), 	
    FOREIGN KEY (lop_id) REFERENCES lop(id) ON DELETE CASCADE,
    FOREIGN KEY (monhoc_id) REFERENCES monhoc(id) ON DELETE CASCADE,
    FOREIGN KEY (magv) REFERENCES giaovien(magv) ON DELETE CASCADE,
    CONSTRAINT uk_tkb_lop_thu_tiet UNIQUE (lop_id, thu, tiet)
);
GO

-- 🔐 BẢNG TÀI KHOẢN NGƯỜI DÙNG
CREATE TABLE users (
    id INT NOT NULL IDENTITY(1,1),
    username VARCHAR(50) UNIQUE NOT NULL, 	
    password VARCHAR(255) NOT NULL, 		
    fullname NVARCHAR(150),
    role VARCHAR(20) NOT NULL, 	
    PRIMARY KEY (id)
);
GO

-- =============================================
-- PHẦN 2: CHÈN DỮ LIỆU (DML CHO T-SQL)
-- =============================================

-- Chèn Môn học (Thêm N'...' cho chuỗi Unicode)
INSERT INTO monhoc (tenmonhoc) VALUES
(N'Toán'), (N'Văn'), (N'Anh'), (N'Lý'), (N'Hóa'), (N'Sinh'),
(N'Sử'), (N'Địa'), (N'GDCD'), (N'Thể chất'), (N'Quốc phòng');

-- Chèn Lớp học
INSERT INTO lop (tenlop) VALUES
(N'10A1'), (N'10A2'), (N'10A3'), (N'10A4'), (N'10A5'),
(N'11A1'), (N'11A2'), (N'11A3'), (N'11A4'), (N'11A5'),
(N'12A1'), (N'12A2'), (N'12A3');

-- Chèn GIÁO VIÊN
INSERT INTO giaovien (hoten, sodt, monhoc_id, chuyenmon, chunhiemlop) VALUES
(N'Nguyễn Văn Hùng', '0912345671', (SELECT id FROM monhoc WHERE tenmonhoc = N'Toán'), N'Toán', NULL),
(N'Trần Thị Hoa', '0912345672', (SELECT id FROM monhoc WHERE tenmonhoc = N'Văn'), N'Văn', NULL),
(N'Phạm Quốc Bảo', '0912345673', (SELECT id FROM monhoc WHERE tenmonhoc = N'Anh'), N'Anh', NULL),
(N'Ngô Văn Phước', '0912345674', (SELECT id FROM monhoc WHERE tenmonhoc = N'Lý'), N'Lý', NULL),
(N'Phạm Thị Ngọc', '0912345675', (SELECT id FROM monhoc WHERE tenmonhoc = N'Hóa'), N'Hóa', NULL),
(N'Nguyễn Thị Lan', '0912345676', (SELECT id FROM monhoc WHERE tenmonhoc = N'Sinh'), N'Sinh', NULL),
(N'Trần Thị Thu', '0912345677', (SELECT id FROM monhoc WHERE tenmonhoc = N'Sử'), N'Sử', NULL),
(N'Lê Văn Dũng', '0912345678', (SELECT id FROM monhoc WHERE tenmonhoc = N'Địa'), N'Địa', NULL),
(N'Ngô Văn Hoàng', '0912345742', (SELECT id FROM monhoc WHERE tenmonhoc = N'Toán'), N'Toán', NULL),
(N'Bùi Văn Lộc', '0912345746', (SELECT id FROM monhoc WHERE tenmonhoc = N'Văn'), N'Văn', NULL),
(N'Trần Thị Thảo', '0912345679', (SELECT id FROM monhoc WHERE tenmonhoc = N'GDCD'), N'GDCD', NULL),
(N'Phạm Văn Tâm', '0912345680', (SELECT id FROM monhoc WHERE tenmonhoc = N'Thể chất'), N'Thể chất', NULL),
(N'Lê Tấn Dũng', '0912345681', (SELECT id FROM monhoc WHERE tenmonhoc = N'Quốc phòng'), N'Quốc phòng', NULL);

-- Cập nhật GVCN cho lớp
UPDATE lop SET magv_chunhiem = (SELECT magv FROM giaovien WHERE hoten = N'Nguyễn Văn Hùng') WHERE tenlop = N'10A1';
UPDATE lop SET magv_chunhiem = (SELECT magv FROM giaovien WHERE hoten = N'Trần Thị Hoa') WHERE tenlop = N'10A2';
UPDATE lop SET magv_chunhiem = (SELECT magv FROM giaovien WHERE hoten = N'Phạm Quốc Bảo') WHERE tenlop = N'10A3';
UPDATE lop SET magv_chunhiem = (SELECT magv FROM giaovien WHERE hoten = N'Ngô Văn Phước') WHERE tenlop = N'10A4';
UPDATE lop SET magv_chunhiem = (SELECT magv FROM giaovien WHERE hoten = N'Phạm Thị Ngọc') WHERE tenlop = N'10A5';
UPDATE lop SET magv_chunhiem = (SELECT magv FROM giaovien WHERE hoten = N'Nguyễn Thị Lan') WHERE tenlop = N'11A1';
UPDATE lop SET magv_chunhiem = (SELECT magv FROM giaovien WHERE hoten = N'Trần Thị Thu') WHERE tenlop = N'11A2';
UPDATE lop SET magv_chunhiem = (SELECT magv FROM giaovien WHERE hoten = N'Lê Văn Dũng') WHERE tenlop = N'11A3';
UPDATE lop SET magv_chunhiem = (SELECT magv FROM giaovien WHERE hoten = N'Ngô Văn Hoàng') WHERE tenlop = N'11A4';
UPDATE lop SET magv_chunhiem = (SELECT magv FROM giaovien WHERE hoten = N'Bùi Văn Lộc') WHERE tenlop = N'11A5';
UPDATE lop SET magv_chunhiem = (SELECT magv FROM giaovien WHERE hoten = N'Trần Thị Thảo') WHERE tenlop = N'12A1';
UPDATE lop SET magv_chunhiem = (SELECT magv FROM giaovien WHERE hoten = N'Phạm Văn Tâm') WHERE tenlop = N'12A2';
UPDATE lop SET magv_chunhiem = (SELECT magv FROM giaovien WHERE hoten = N'Lê Tấn Dũng') WHERE tenlop = N'12A3';

-- Cập nhật tên lớp chủ nhiệm vào bảng giáo viên (Cú pháp UPDATE...FROM...JOIN của T-SQL)
UPDATE g
SET g.chunhiemlop = l.tenlop
FROM giaovien g
JOIN lop l ON g.magv = l.magv_chunhiem;
GO

-- Chèn HỌC SINH (65 HS)
INSERT INTO hocsinh (holot, ten, lop_id, gioitinh, ngaysinh, chucvu, hanhkiem, diachi, dienthoai)
VALUES
(N'Nguyễn Thị', N'Mai', (SELECT id FROM lop WHERE tenlop = N'10A1'), N'Nữ', '2010-03-15', N'Lớp trưởng', N'Tốt', N'123 Nguyễn Trãi, Long Xuyên, An Giang', '0901234567'),
(N'Phạm Minh', N'Quân', (SELECT id FROM lop WHERE tenlop = N'10A1'), N'Nam', '2010-06-22', N'Bí thư', N'Tốt', N'45 Lê Lợi, Châu Đốc, An Giang', '0902345678'),
(N'Trần Thị', N'Thu', (SELECT id FROM lop WHERE tenlop = N'10A1'), N'Nữ', '2010-09-10', N'Không có', N'Tốt', N'78 Hai Bà Trưng, An Phú, An Giang', '0903456789'),
(N'Lê Văn', N'Phú', (SELECT id FROM lop WHERE tenlop = N'10A1'), N'Nam', '2010-12-05', N'Phó học tập', N'Tốt', N'90 Nguyễn Huệ, Tịnh Biên, An Giang', '0904567890'),
(N'Đỗ Thị', N'Yến', (SELECT id FROM lop WHERE tenlop = N'10A1'), N'Nữ', '2010-02-18', N'Không có', N'Tốt', N'12 Lý Tự Trọng, Châu Phú, An Giang', '0905678901'),
(N'Nguyễn Văn', N'Tú', (SELECT id FROM lop WHERE tenlop = N'10A2'), N'Nam', '2010-05-21', N'Lớp trưởng', N'Tốt', N'101 Nguyễn Huệ, Long Xuyên, An Giang', '0906789012'),
(N'Trần Ngọc', N'Hà', (SELECT id FROM lop WHERE tenlop = N'10A2'), N'Nữ', '2010-11-02', N'Bí thư', N'Tốt', N'34 Trần Hưng Đạo, Châu Phú, An Giang', '0907890123'),
(N'Phạm Quốc', N'Đạt', (SELECT id FROM lop WHERE tenlop = N'10A2'), N'Nam', '2010-04-15', N'Không có', N'Tốt', N'67 Hai Bà Trưng, Châu Đốc, An Giang', '0908901234'),
(N'Lê Thị', N'Nhung', (SELECT id FROM lop WHERE tenlop = N'10A2'), N'Nữ', '2010-08-25', N'Thủ quỹ', N'Tốt', N'45 Nguyễn Trãi, An Phú, An Giang', '0909012345'),
(N'Võ Hoàng', N'Nam', (SELECT id FROM lop WHERE tenlop = N'10A2'), N'Nam', '2010-07-12', N'Không có', N'Tốt', N'22 Nguyễn Đình Chiểu, Tịnh Biên, An Giang', '0910123456'),
(N'Phan Thị', N'Hồng', (SELECT id FROM lop WHERE tenlop = N'10A3'), N'Nữ', '2010-01-08', N'Lớp trưởng', N'Tốt', N'56 Nguyễn Văn Linh, Long Xuyên, An Giang', '0911234567'),
(N'Ngô Văn', N'Phước', (SELECT id FROM lop WHERE tenlop = N'10A3'), N'Nam', '2010-03-29', N'Bí thư', N'Tốt', N'17 Lê Lai, Châu Phú, An Giang', '0912345678'),
(N'Trần Thị', N'Bích', (SELECT id FROM lop WHERE tenlop = N'10A3'), N'Nữ', '2010-09-19', N'Không có', N'Tốt', N'98 Hai Bà Trưng, Tịnh Biên, An Giang', '0913456789'),
(N'Lê Hoàng', N'Vũ', (SELECT id FROM lop WHERE tenlop = N'10A3'), N'Nam', '2010-10-02', N'Phó học tập', N'Tốt', N'11 Nguyễn Huệ, Châu Đốc, An Giang', '0914567890'),
(N'Đặng Thị', N'Tú', (SELECT id FROM lop WHERE tenlop = N'10A3'), N'Nữ', '2010-06-14', N'Không có', N'Tốt', N'21 Trần Hưng Đạo, An Phú, An Giang', '0915678901'),
(N'Nguyễn Văn', N'Long', (SELECT id FROM lop WHERE tenlop = N'10A4'), N'Nam', '2010-02-17', N'Lớp trưởng', N'Tốt', N'23 Nguyễn Văn Cừ, Long Xuyên, An Giang', '0916789012'),
(N'Trần Thị', N'Kim', (SELECT id FROM lop WHERE tenlop = N'10A4'), N'Nữ', '2010-05-05', N'Bí thư', N'Tốt', N'47 Nguyễn Thái Học, Châu Phú, An Giang', '0917890123'),
(N'Phạm Văn', N'Bình', (SELECT id FROM lop WHERE tenlop = N'10A4'), N'Nam', '2010-08-22', N'Không có', N'Tốt', N'89 Trần Hưng Đạo, Tịnh Biên, An Giang', '0918901234'),
(N'Lê Thị', N'Ngân', (SELECT id FROM lop WHERE tenlop = N'10A4'), N'Nữ', '2010-11-12', N'Phó học tập', N'Tốt', N'33 Lý Tự Trọng, An Phú, An Giang', '0919012345'),
(N'Võ Quốc', N'Trung', (SELECT id FROM lop WHERE tenlop = N'10A4'), N'Nam', '2010-07-30', N'Không có', N'Tốt', N'12 Nguyễn Văn Linh, Châu Đốc, An Giang', '0920123456'),
(N'Nguyễn Thị', N'Lan', (SELECT id FROM lop WHERE tenlop = N'10A5'), N'Nữ', '2010-04-09', N'Lớp trưởng', N'Tốt', N'89 Nguyễn Huệ, Long Xuyên, An Giang', '0921234567'),
(N'Phạm Minh', N'Hào', (SELECT id FROM lop WHERE tenlop = N'10A5'), N'Nam', '2010-09-25', N'Bí thư', N'Tốt', N'77 Lê Lợi, Châu Phú, An Giang', '0922345678'),
(N'Trần Thị', N'Thúy', (SELECT id FROM lop WHERE tenlop = N'10A5'), N'Nữ', '2010-06-08', N'Không có', N'Tốt', N'55 Nguyễn Văn Cừ, Tịnh Biên, An Giang', '0923456789'),
(N'Lê Văn', N'Phước', (SELECT id FROM lop WHERE tenlop = N'10A5'), N'Nam', '2010-01-19', N'Phó học tập', N'Tốt', N'101 Trần Hưng Đạo, An Phú, An Giang', '0924567890'),
(N'Đỗ Thị', N'Nga', (SELECT id FROM lop WHERE tenlop = N'10A5'), N'Nữ', '2010-10-10', N'Không có', N'Tốt', N'99 Nguyễn Thái Học, Châu Đốc, An Giang', '0925678901'),
(N'Nguyễn Văn', N'Hùng', (SELECT id FROM lop WHERE tenlop = N'11A1'), N'Nam', '2009-04-18', N'Lớp trưởng', N'Tốt', N'12 Nguyễn Huệ, Long Xuyên, An Giang', '0931111111'),
(N'Trần Thị', N'Phương', (SELECT id FROM lop WHERE tenlop = N'11A1'), N'Nữ', '2009-07-05', N'Bí thư', N'Tốt', N'89 Trần Hưng Đạo, Châu Phú, An Giang', '0931222222'),
(N'Lê Minh', N'Tài', (SELECT id FROM lop WHERE tenlop = N'11A1'), N'Nam', '2009-02-12', N'Phó học tập', N'Tốt', N'34 Nguyễn Văn Linh, Châu Đốc, An Giang', '0931333333'),
(N'Phạm Thị', N'Như', (SELECT id FROM lop WHERE tenlop = N'11A1'), N'Nữ', '2009-08-25', N'Không có', N'Tốt', N'56 Hai Bà Trưng, Tịnh Biên, An Giang', '0931444444'),
(N'Đặng Hoàng', N'Nam', (SELECT id FROM lop WHERE tenlop = N'11A1'), N'Nam', '2009-11-30', N'Không có', N'Tốt', N'23 Nguyễn Trãi, An Phú, An Giang', '0931555555'),
(N'Võ Thị', N'Hà', (SELECT id FROM lop WHERE tenlop = N'11A2'), N'Nữ', '2009-03-10', N'Lớp trưởng', N'Tốt', N'45 Nguyễn Huệ, Long Xuyên, An Giang', '0931666666'),
(N'Nguyễn Hoàng', N'Tú', (SELECT id FROM lop WHERE tenlop = N'11A2'), N'Nam', '2009-09-01', N'Bí thư', N'Tốt', N'78 Trần Hưng Đạo, Châu Đốc, An Giang', '0931777777'),
(N'Phan Văn', N'Lộc', (SELECT id FROM lop WHERE tenlop = N'11A2'), N'Nam', '2009-06-14', N'Phó học tập', N'Tốt', N'11 Lý Tự Trọng, Châu Phú, An Giang', '0931888888'),
(N'Lê Thị', N'Thảo', (SELECT id FROM lop WHERE tenlop = N'11A2'), N'Nữ', '2009-12-09', N'Không có', N'Tốt', N'90 Nguyễn Văn Cừ, Tịnh Biên, An Giang', '0931999999'),
(N'Trần Quốc', N'Hưng', (SELECT id FROM lop WHERE tenlop = N'11A2'), N'Nam', '2009-01-22', N'Không có', N'Tốt', N'33 Nguyễn Thái Học, An Phú, An Giang', '0932000000'),
(N'Phạm Thị', N'Trang', (SELECT id FROM lop WHERE tenlop = N'11A3'), N'Nữ', '2009-05-06', N'Lớp trưởng', N'Tốt', N'67 Nguyễn Văn Linh, Long Xuyên, An Giang', '0932111111'),
(N'Ngô Văn', N'Hiếu', (SELECT id FROM lop WHERE tenlop = N'11A3'), N'Nam', '2009-10-11', N'Bí thư', N'Tốt', N'21 Trần Hưng Đạo, Châu Phú, An Giang', '0932222222'),
(N'Đỗ Thị', N'Hồng', (SELECT id FROM lop WHERE tenlop = N'11A3'), N'Nữ', '2009-07-29', N'Phó học tập', N'Tốt', N'44 Nguyễn Huệ, Tịnh Biên, An Giang', '0932333333'),
(N'Lê Văn', N'Trung', (SELECT id FROM lop WHERE tenlop = N'11A3'), N'Nam', '2009-03-17', N'Không có', N'Tốt', N'15 Hai Bà Trưng, An Phú, An Giang', '0932444444'),
(N'Trần Thị', N'Yến', (SELECT id FROM lop WHERE tenlop = N'11A3'), N'Nữ', '2009-11-05', N'Không có', N'Tốt', N'100 Nguyễn Văn Cừ, Châu Đốc, An Giang', '0932555555'),
(N'Nguyễn Thị', N'Ngọc', (SELECT id FROM lop WHERE tenlop = N'11A4'), N'Nữ', '2009-02-18', N'Lớp trưởng', N'Tốt', N'88 Nguyễn Huệ, Long Xuyên, An Giang', '0932666666'),
(N'Phạm Minh', N'Khôi', (SELECT id FROM lop WHERE tenlop = N'11A4'), N'Nam', '2009-09-14', N'Bí thư', N'Tốt', N'25 Trần Hưng Đạo, Châu Phú, An Giang', '0932777777'),
(N'Lê Thị', N'Thanh', (SELECT id FROM lop WHERE tenlop = N'11A4'), N'Nữ', '2009-12-25', N'Phó học tập', N'Tốt', N'70 Nguyễn Văn Linh, Tịnh Biên, An Giang', '0932888888'),
(N'Trần Văn', N'Phong', (SELECT id FROM lop WHERE tenlop = N'11A4'), N'Nam', '2009-04-02', N'Không có', N'Tốt', N'33 Nguyễn Thái Học, An Phú, An Giang', '0932999999'),
(N'Võ Thị', N'Diễm', (SELECT id FROM lop WHERE tenlop = N'11A4'), N'Nữ', '2009-06-08', N'Không có', N'Tốt', N'22 Hai Bà Trưng, Châu Đốc, An Giang', '0933000000'),
(N'Nguyễn Văn', N'Tuấn', (SELECT id FROM lop WHERE tenlop = N'11A5'), N'Nam', '2009-05-21', N'Lớp trưởng', N'Tốt', N'56 Nguyễn Huệ, Long Xuyên, An Giang', '0933111111'),
(N'Trần Thị', N'Anh', (SELECT id FROM lop WHERE tenlop = N'11A5'), N'Nữ', '2009-09-10', N'Bí thư', N'Tốt', N'77 Lê Lợi, Châu Phú, An Giang', '0933222222'),
(N'Phạm Hoàng', N'Duy', (SELECT id FROM lop WHERE tenlop = N'11A5'), N'Nam', '2009-01-28', N'Phó học tập', N'Tốt', N'99 Nguyễn Văn Cừ, Tịnh Biên, An Giang', '0933333333'),
(N'Lê Thị', N'Mai', (SELECT id FROM lop WHERE tenlop = N'11A5'), N'Nữ', '2009-07-19', N'Không có', N'Tốt', N'11 Trần Hưng Đạo, An Phú, An Giang', '0933444444'),
(N'Đỗ Văn', N'Trí', (SELECT id FROM lop WHERE tenlop = N'11A5'), N'Nam', '2009-10-23', N'Không có', N'Tốt', N'44 Nguyễn Thái Học, Châu Đốc, An Giang', '0933555555'),
(N'Nguyễn Thị', N'Mai', (SELECT id FROM lop WHERE tenlop = N'12A1'), N'Nữ', '2007-05-12', N'Lớp trưởng', N'Tốt', N'12 Nguyễn Văn Cừ', '0912345678'),
(N'Phạm Văn', N'Hải', (SELECT id FROM lop WHERE tenlop = N'12A1'), N'Nam', '2007-09-04', N'Tổ trưởng', N'Tốt', N'9 Nguyễn Trãi', '0934567890'),
(N'Lê Minh', N'Tuấn', (SELECT id FROM lop WHERE tenlop = N'12A1'), N'Nam', '2007-01-25', N'', N'Khá', N'15 Hai Bà Trưng', '0987654321'),
(N'Trần Ngọc', N'Hân', (SELECT id FROM lop WHERE tenlop = N'12A1'), N'Nữ', '2007-03-18', N'', N'Tốt', N'21 Lý Tự Trọng', '0909123456'),
(N'Đặng Hoàng', N'Phúc', (SELECT id FROM lop WHERE tenlop = N'12A1'), N'Nam', '2007-06-22', N'', N'Tốt', N'47 Nguyễn Huệ', '0918765432'),
(N'Phan Nhật', N'Khang', (SELECT id FROM lop WHERE tenlop = N'12A2'), N'Nam', '2007-08-09', N'Lớp trưởng', N'Tốt', N'5 Trần Bình Trọng', '0941234567'),
(N'Ngô Thị', N'Hạnh', (SELECT id FROM lop WHERE tenlop = N'12A2'), N'Nữ', '2007-04-11', N'Tổ trưởng', N'Tốt', N'8 Phạm Ngũ Lão', '0963456789'),
(N'Bùi Đức', N'Tài', (SELECT id FROM lop WHERE tenlop = N'12A2'), N'Nam', '2007-02-03', N'', N'Khá', N'31 Nguyễn Du', '0976543210'),
(N'Võ Thị', N'Như', (SELECT id FROM lop WHERE tenlop = N'12A2'), N'Nữ', '2007-10-07', N'', N'Tốt', N'29 Lý Nam Đế', '0912345987'),
(N'Đoàn Văn', N'Trí', (SELECT id FROM lop WHERE tenlop = N'12A2'), N'Nam', '2007-12-14', N'', N'Trung bình', N'10 Nguyễn Công Trứ', '0923456789'),
(N'Trịnh Gia', N'Bảo', (SELECT id FROM lop WHERE tenlop = N'12A3'), N'Nam', '2007-07-01', N'Lớp trưởng', N'Tốt', N'7 Nguyễn Khuyến', '0981122334'),
(N'Lưu Thị', N'Lan', (SELECT id FROM lop WHERE tenlop = N'12A3'), N'Nữ', '2007-05-21', N'Tổ trưởng', N'Tốt', N'22 Bạch Đằng', '0919988776'),
(N'Huỳnh Công', N'Đạt', (SELECT id FROM lop WHERE tenlop = N'12A3'), N'Nam', '2007-09-30', N'', N'Khá', N'15 Nguyễn Thái Học', '0977332211'),
(N'Nguyễn Thị', N'Trang', (SELECT id FROM lop WHERE tenlop = N'12A3'), N'Nữ', '2007-11-09', N'', N'Tốt', N'11 Phan Đình Phùng', '0955566778'),
(N'Đỗ Thành', N'Long', (SELECT id FROM lop WHERE tenlop = N'12A3'), N'Nam', '2007-03-15', N'', N'Khá', N'27 Hoàng Văn Thụ', '0922233445');
GO

-- =============================================
-- PHẦN 2B: CHÈN DỮ LIỆU PHỤ HUYNH (ĐẦY ĐỦ 65 HỌC SINH)
-- =============================================
INSERT INTO phuhuynh (mahs, tenphu, sdt, diachi, quanhe, nghenghiep) VALUES
(1, N'Nguyễn Văn Bình', '0901112233', N'123 Nguyễn Trãi, Long Xuyên, An Giang', N'Cha', N'Kỹ sư'),
(1, N'Trần Thị Hoa', '0912223344', N'123 Nguyễn Trãi, Long Xuyên, An Giang', N'Mẹ', N'Nội trợ'),
(2, N'Phạm Minh Long', '0902345678', N'45 Lê Lợi, Châu Đốc, An Giang', N'Cha', N'Kinh doanh'),
(2, N'Lê Thị Lan', '0902345679', N'45 Lê Lợi, Châu Đốc, An Giang', N'Mẹ', N'Giáo viên'),
(3, N'Trần Văn Nam', '0903456789', N'78 Hai Bà Trưng, An Phú, An Giang', N'Cha', N'Tài xế'),
(3, N'Võ Thị Hằng', '0903456780', N'78 Hai Bà Trưng, An Phú, An Giang', N'Mẹ', N'Nội trợ'),
(4, N'Lê Văn Tài', '0904567890', N'90 Nguyễn Huệ, Tịnh Biên, An Giang', N'Cha', N'Bác sĩ'),
(4, N'Mai Thị Cúc', '0904567891', N'90 Nguyễn Huệ, Tịnh Biên, An Giang', N'Mẹ', N'Y tá'),
(5, N'Đỗ Văn Hùng', '0905678901', N'12 Lý Tự Trọng, Châu Phú, An Giang', N'Cha', N'Bộ đội'),
(5, N'Phan Thị Lan', '0905678902', N'12 Lý Tự Trọng, Châu Phú, An Giang', N'Mẹ', N'Thợ may'),
(6, N'Nguyễn Văn Hùng', '0906789012', N'101 Nguyễn Huệ, Long Xuyên, An Giang', N'Cha', N'Công nhân'),
(6, N'Lý Thị Mai', '0906789013', N'101 Nguyễn Huệ, Long Xuyên, An Giang', N'Mẹ', N'Buôn bán'),
(7, N'Trần Ngọc Sơn', '0907890123', N'34 Trần Hưng Đạo, Châu Phú, An Giang', N'Cha', N'Kỹ sư'),
(7, N'Ngô Thị Hà', '0907890124', N'34 Trần Hưng Đạo, Châu Phú, An Giang', N'Mẹ', N'Nội trợ'),
(8, N'Phạm Quốc Tuấn', '0908901234', N'67 Hai Bà Trưng, Châu Đốc, An Giang', N'Cha', N'Giám đốc'),
(8, N'Đinh Thị Thu', '0908901235', N'67 Hai Bà Trưng, Châu Đốc, An Giang', N'Mẹ', N'Kế toán'),
(9, N'Lê Văn Tâm', '0909012345', N'45 Nguyễn Trãi, An Phú, An Giang', N'Cha', N'Nông dân'),
(9, N'Nguyễn Thị Nhung', '0909012346', N'45 Nguyễn Trãi, An Phú, An Giang', N'Mẹ', N'Nông dân'),
(10, N'Võ Hoàng Long', '0910123456', N'22 Nguyễn Đình Chiểu, Tịnh Biên, An Giang', N'Cha', N'Công an'),
(10, N'Bùi Thị Anh', '0910123457', N'22 Nguyễn Đình Chiểu, Tịnh Biên, An Giang', N'Mẹ', N'Giáo viên'),
(11, N'Phan Văn Tài', '0911234567', N'56 Nguyễn Văn Linh, Long Xuyên, An Giang', N'Cha', N'Thợ điện'),
(11, N'Trần Thị Hồng', '0911234568', N'56 Nguyễn Văn Linh, Long Xuyên, An Giang', N'Mẹ', N'Nội trợ'),
(12, N'Ngô Văn Nam', '0912345678', N'17 Lê Lai, Châu Phú, An Giang', N'Cha', N'Bộ đội'),
(12, N'Huỳnh Thị Lan', '0912345679', N'17 Lê Lai, Châu Phú, An Giang', N'Mẹ', N'Buôn bán'),
(13, N'Trần Văn Bình', '0913456789', N'98 Hai Bà Trưng, Tịnh Biên, An Giang', N'Cha', N'Kinh doanh'),
(13, N'Lê Thị Bích', '0913456780', N'98 Hai Bà Trưng, Tịnh Biên, An Giang', N'Mẹ', N'Thợ may'),
(14, N'Lê Hoàng Dũng', '0914567890', N'11 Nguyễn Huệ, Châu Đốc, An Giang', N'Cha', N'Kỹ sư'),
(14, N'Phạm Thị Ánh', '0914567891', N'11 Nguyễn Huệ, Châu Đốc, An Giang', N'Mẹ', N'Nội trợ'),
(15, N'Đặng Văn Minh', '0915678901', N'21 Trần Hưng Đạo, An Phú, An Giang', N'Cha', N'Công nhân'),
(15, N'Nguyễn Thị Tú', '0915678902', N'21 Trần Hưng Đạo, An Phú, An Giang', N'Mẹ', N'Nội trợ'),
(16, N'Nguyễn Văn Hải', '0916789012', N'23 Nguyễn Văn Cừ, Long Xuyên, An Giang', N'Cha', N'Bác sĩ'),
(16, N'Hoàng Thị Thu', '0916789013', N'23 Nguyễn Văn Cừ, Long Xuyên, An Giang', N'Mẹ', N'Y tá'),
(17, N'Trần Văn Dũng', '0917890123', N'47 Nguyễn Thái Học, Châu Phú, An Giang', N'Cha', N'Công an'),
(17, N'Phạm Thị Kim', '0917890124', N'47 Nguyễn Thái Học, Châu Phú, An Giang', N'Mẹ', N'Giáo viên'),
(18, N'Phạm Văn An', '0918901234', N'89 Trần Hưng Đạo, Tịnh Biên, An Giang', N'Cha', N'Nông dân'),
(18, N'Lê Thị Hiền', '0918901235', N'89 Trần Hưng Đạo, Tịnh Biên, An Giang', N'Mẹ', N'Nội trợ'),
(19, N'Lê Văn Hùng', '0919012345', N'33 Lý Tự Trọng, An Phú, An Giang', N'Cha', N'Kỹ sư'),
(19, N'Nguyễn Thị Ngân', '0919012346', N'33 Lý Tự Trọng, An Phú, An Giang', N'Mẹ', N'Buôn bán'),
(20, N'Võ Quốc Hùng', '0920123456', N'12 Nguyễn Văn Linh, Châu Đốc, An Giang', N'Cha', N'Bộ đội'),
(20, N'Đặng Thị Mai', '0920123457', N'12 Nguyễn Văn Linh, Châu Đốc, An Giang', N'Mẹ', N'Thợ may'),
(21, N'Nguyễn Văn Dũng', '0921234567', N'89 Nguyễn Huệ, Long Xuyên, An Giang', N'Cha', N'Kinh doanh'),
(21, N'Phan Thị Lan', '0921234568', N'89 Nguyễn Huệ, Long Xuyên, An Giang', N'Mẹ', N'Nội trợ'),
(22, N'Phạm Minh Tuấn', '0922345678', N'77 Lê Lợi, Châu Phú, An Giang', N'Cha', N'Giáo viên'),
(22, N'Trần Thị Lan', '0922345679', N'77 Lê Lợi, Châu Phú, An Giang', N'Mẹ', N'Bác sĩ'),
(23, N'Trần Văn Nam', '0923456789', N'55 Nguyễn Văn Cừ, Tịnh Biên, An Giang', N'Cha', N'Công nhân'),
(23, N'Lê Thị Thúy', '0923456780', N'55 Nguyễn Văn Cừ, Tịnh Biên, An Giang', N'Mẹ', N'Nội trợ'),
(24, N'Lê Văn Hùng', '0924567890', N'101 Trần Hưng Đạo, An Phú, An Giang', N'Cha', N'Công an'),
(24, N'Nguyễn Thị Phước', '0924567891', N'101 Trần Hưng Đạo, An Phú, An Giang', N'Mẹ', N'Buôn bán'),
(25, N'Đỗ Văn Hải', '0925678901', N'99 Nguyễn Thái Học, Châu Đốc, An Giang', N'Cha', N'Tài xế'),
(25, N'Trần Thị Nga', '0925678902', N'99 Nguyễn Thái Học, Châu Đốc, An Giang', N'Mẹ', N'Thợ may'),
(26, N'Nguyễn Văn Nam', '0931111112', N'12 Nguyễn Huệ, Long Xuyên, An Giang', N'Cha', N'Kỹ sư'),
(26, N'Đặng Thị Bích', '0931111113', N'12 Nguyễn Huệ, Long Xuyên, An Giang', N'Mẹ', N'Nội trợ'),
(27, N'Trần Văn Tâm', '0931222223', N'89 Trần Hưng Đạo, Châu Phú, An Giang', N'Cha', N'Giáo viên'),
(27, N'Lê Thị Phương', '0931222224', N'89 Trần Hưng Đạo, Châu Phú, An Giang', N'Mẹ', N'Buôn bán'),
(28, N'Lê Minh Hùng', '0931333334', N'34 Nguyễn Văn Linh, Châu Đốc, An Giang', N'Cha', N'Bộ đội'),
(28, N'Võ Thị Lan', '0931333335', N'34 Nguyễn Văn Linh, Châu Đốc, An Giang', N'Mẹ', N'Nội trợ'),
(29, N'Phạm Văn Long', '0931444445', N'56 Hai Bà Trưng, Tịnh Biên, An Giang', N'Cha', N'Công nhân'),
(29, N'Hoàng Thị Như', '0931444446', N'56 Hai Bà Trưng, Tịnh Biên, An Giang', N'Mẹ', N'Thợ may'),
(30, N'Đặng Hoàng Sơn', '0931555556', N'23 Nguyễn Trãi, An Phú, An Giang', N'Cha', N'Kinh doanh'),
(30, N'Lê Thị Hằng', '0931555557', N'23 Nguyễn Trãi, An Phú, An Giang', N'Mẹ', N'Nội trợ'),
(31, N'Võ Văn Hùng', '0931666667', N'45 Nguyễn Huệ, Long Xuyên, An Giang', N'Cha', N'Bác sĩ'),
(31, N'Trần Thị Hà', '0931666668', N'45 Nguyễn Huệ, Long Xuyên, An Giang', N'Mẹ', N'Y tá'),
(32, N'Nguyễn Hoàng Dũng', '0931777778', N'78 Trần Hưng Đạo, Châu Đốc, An Giang', N'Cha', N'Công an'),
(32, N'Lê Thị Cúc', '0931777779', N'78 Trần Hưng Đạo, Châu Đốc, An Giang', N'Mẹ', N'Nội trợ'),
(33, N'Phan Văn Hùng', '0931888889', N'11 Lý Tự Trọng, Châu Phú, An Giang', N'Cha', N'Kỹ sư'),
(33, N'Đỗ Thị Lộc', '0931888880', N'11 Lý Tự Trọng, Châu Phú, An Giang', N'Mẹ', N'Giáo viên'),
(34, N'Lê Văn Tâm', '0931999990', N'90 Nguyễn Văn Cừ, Tịnh Biên, An Giang', N'Cha', N'Nông dân'),
(34, N'Nguyễn Thị Thảo', '0931999991', N'90 Nguyễn Văn Cừ, Tịnh Biên, An Giang', N'Mẹ', N'Nội trợ'),
(35, N'Trần Quốc Tuấn', '0932000001', N'33 Nguyễn Thái Học, An Phú, An Giang', N'Cha', N'Bộ đội'),
(35, N'Lê Thị Kim', '0932000002', N'33 Nguyễn Thái Học, An Phú, An Giang', N'Mẹ', N'Buôn bán'),
(36, N'Phạm Văn Nam', '0932111112', N'67 Nguyễn Văn Linh, Long Xuyên, An Giang', N'Cha', N'Công nhân'),
(36, N'Nguyễn Thị Trang', '0932111113', N'67 Nguyễn Văn Linh, Long Xuyên, An Giang', N'Mẹ', N'Thợ may'),
(37, N'Ngô Văn Hùng', '0932222223', N'21 Trần Hưng Đạo, Châu Phú, An Giang', N'Cha', N'Kinh doanh'),
(37, N'Trần Thị Lan', '0932222224', N'21 Trần Hưng Đạo, Châu Phú, An Giang', N'Mẹ', N'Nội trợ'),
(38, N'Đỗ Văn Hùng', '0932333334', N'44 Nguyễn Huệ, Tịnh Biên, An Giang', N'Cha', N'Bác sĩ'),
(38, N'Lê Thị Hồng', '0932333335', N'44 Nguyễn Huệ, Tịnh Biên, An Giang', N'Mẹ', N'Y tá'),
(39, N'Lê Văn Hùng', '0932444445', N'15 Hai Bà Trưng, An Phú, An Giang', N'Cha', N'Công an'),
(39, N'Mai Thị Hoa', '0932444446', N'15 Hai Bà Trưng, An Phú, An Giang', N'Mẹ', N'Nội trợ'),
(40, N'Trần Văn Dũng', '0932555556', N'100 Nguyễn Văn Cừ, Châu Đốc, An Giang', N'Cha', N'Kỹ sư'),
(40, N'Hoàng Thị Yến', '0932555557', N'100 Nguyễn Văn Cừ, Châu Đốc, An Giang', N'Mẹ', N'Giáo viên'),
(41, N'Nguyễn Văn Nam', '0932666667', N'88 Nguyễn Huệ, Long Xuyên, An Giang', N'Cha', N'Nông dân'),
(41, N'Lê Thị Ngọc', '0932666668', N'88 Nguyễn Huệ, Long Xuyên, An Giang', N'Mẹ', N'Nội trợ'),
(42, N'Phạm Minh Long', '0932777778', N'25 Trần Hưng Đạo, Châu Phú, An Giang', N'Cha', N'Bộ đội'),
(42, N'Nguyễn Thị Thu', '0932777779', N'25 Trần Hưng Đạo, Châu Phú, An Giang', N'Mẹ', N'Buôn bán'),
(43, N'Lê Văn Tuấn', '0932888889', N'70 Nguyễn Văn Linh, Tịnh Biên, An Giang', N'Cha', N'Công nhân'),
(43, N'Đặng Thị Thanh', '0932888880', N'70 Nguyễn Văn Linh, Tịnh Biên, An Giang', N'Mẹ', N'Thợ may'),
(44, N'Trần Văn Hùng', '0932999990', N'33 Nguyễn Thái Học, An Phú, An Giang', N'Cha', N'Kinh doanh'),
(44, N'Lê Thị Lan', '0932999991', N'33 Nguyễn Thái Học, An Phú, An Giang', N'Mẹ', N'Nội trợ'),
(45, N'Võ Văn Tâm', '0933000001', N'22 Hai Bà Trưng, Châu Đốc, An Giang', N'Cha', N'Bác sĩ'),
(45, N'Nguyễn Thị Diễm', '0933000002', N'22 Hai Bà Trưng, Châu Đốc, An Giang', N'Mẹ', N'Y tá'),
(46, N'Nguyễn Văn Nam', '0933111112', N'56 Nguyễn Huệ, Long Xuyên, An Giang', N'Cha', N'Công an'),
(46, N'Trần Thị Bích', '0933111113', N'56 Nguyễn Huệ, Long Xuyên, An Giang', N'Mẹ', N'Nội trợ'),
(47, N'Trần Văn Hải', '0933222223', N'77 Lê Lợi, Châu Phú, An Giang', N'Cha', N'Kỹ sư'),
(47, N'Phạm Thị Anh', '0933222224', N'77 Lê Lợi, Châu Phú, An Giang', N'Mẹ', N'Giáo viên'),
(48, N'Phạm Hoàng Nam', '0933333334', N'99 Nguyễn Văn Cừ, Tịnh Biên, An Giang', N'Cha', N'Nông dân'),
(48, N'Lê Thị Thu', '0933333335', N'99 Nguyễn Văn Cừ, Tịnh Biên, An Giang', N'Mẹ', N'Nội trợ'),
(49, N'Lê Văn Hùng', '0933444445', N'11 Trần Hưng Đạo, An Phú, An Giang', N'Cha', N'Bộ đội'),
(49, N'Nguyễn Thị Mai', '0933444446', N'11 Trần Hưng Đạo, An Phú, An Giang', N'Mẹ', N'Buôn bán'),
(50, N'Đỗ Văn Hùng', '0933555556', N'44 Nguyễn Thái Học, Châu Đốc, An Giang', N'Cha', N'Công nhân'),
(50, N'Trần Thị Hoa', '0933555557', N'44 Nguyễn Thái Học, Châu Đốc, An Giang', N'Mẹ', N'Thợ may'),
(51, N'Nguyễn Văn Nam', '0912345679', N'12 Nguyễn Văn Cừ', N'Cha', N'Kinh doanh'),
(51, N'Lê Thị Mai', '0912345670', N'12 Nguyễn Văn Cừ', N'Mẹ', N'Nội trợ'),
(52, N'Phạm Văn Hùng', '0934567891', N'9 Nguyễn Trãi', N'Cha', N'Bác sĩ'),
(52, N'Trần Thị Hải', '0934567892', N'9 Nguyễn Trãi', N'Mẹ', N'Y tá'),
(53, N'Lê Minh Hoàng', '0987654322', N'15 Hai Bà Trưng', N'Cha', N'Công an'),
(53, N'Võ Thị Lan', '0987654323', N'15 Hai Bà Trưng', N'Mẹ', N'Nội trợ'),
(54, N'Trần Ngọc Dũng', '0909123457', N'21 Lý Tự Trọng', N'Cha', N'Kỹ sư'),
(54, N'Phạm Thị Hân', '0909123458', N'21 Lý Tự Trọng', N'Mẹ', N'Giáo viên'),
(55, N'Đặng Hoàng Nam', '0918765433', N'47 Nguyễn Huệ', N'Cha', N'Nông dân'),
(55, N'Nguyễn Thị Phúc', '0918765434', N'47 Nguyễn Huệ', N'Mẹ', N'Nội trợ'),
(56, N'Phan Nhật Hùng', '0941234568', N'5 Trần Bình Trọng', N'Cha', N'Bộ đội'),
(56, N'Lê Thị Lan', '0941234569', N'5 Trần Bình Trọng', N'Mẹ', N'Buôn bán'),
(57, N'Ngô Văn Dũng', '0963456780', N'8 Phạm Ngũ Lão', N'Cha', N'Công nhân'),
(57, N'Trần Thị Hạnh', '0963456781', N'8 Phạm Ngũ Lão', N'Mẹ', N'Thợ may'),
(58, N'Bùi Đức Hùng', '0976543211', N'31 Nguyễn Du', N'Cha', N'Kinh doanh'),
(58, N'Phạm Thị Lan', '0976543212', N'31 Nguyễn Du', N'Mẹ', N'Nội trợ'),
(59, N'Võ Văn Tâm', '0912345988', N'29 Lý Nam Đế', N'Cha', N'Bác sĩ'),
(59, N'Hoàng Thị Như', '0912345989', N'29 Lý Nam Đế', N'Mẹ', N'Y tá'),
(60, N'Đoàn Văn Dũng', '0923456780', N'10 Nguyễn Công Trứ', N'Cha', N'Công an'),
(60, N'Lê Thị Hằng', '0923456781', N'10 Nguyễn Công Trứ', N'Mẹ', N'Nội trợ'),
(61, N'Trịnh Gia Hùng', '0981122335', N'7 Nguyễn Khuyến', N'Cha', N'Kỹ sư'),
(61, N'Nguyễn Thị Thu', '0981122336', N'7 Nguyễn Khuyến', N'Mẹ', N'Giáo viên'),
(62, N'Lưu Văn Nam', '0919988777', N'22 Bạch Đằng', N'Cha', N'Nông dân'),
(62, N'Trần Thị Lan', '0919988778', N'22 Bạch Đằng', N'Mẹ', N'Nội trợ'),
(63, N'Huỳnh Công Hùng', '0977332212', N'15 Nguyễn Thái Học', N'Cha', N'Bộ đội'),
(63, N'Đỗ Thị Bích', '0977332213', N'15 Nguyễn Thái Học', N'Mẹ', N'Buôn bán'),
(64, N'Nguyễn Văn Nam', '0955566779', N'11 Phan Đình Phùng', N'Cha', N'Công nhân'),
(64, N'Lê Thị Trang', '0955566770', N'11 Phan Đình Phùng', N'Mẹ', N'Thợ may'),
(65, N'Đỗ Thành Hùng', '0922233446', N'27 Hoàng Văn Thụ', N'Cha', N'Kinh doanh'),
(65, N'Phạm Thị Thu', '0922233447', N'27 Hoàng Văn Thụ', N'Mẹ', N'Nội trợ');
GO

-- 📚 KHỞI TẠO BẢN GHI ĐIỂM RỖNG CHO TẤT CẢ HS
INSERT INTO diem (mahs, monhoc_id)
SELECT hs.mahs, m.id
FROM hocsinh hs
CROSS JOIN monhoc m
WHERE NOT EXISTS (
    SELECT 1 FROM diem d
    WHERE d.mahs = hs.mahs AND d.monhoc_id = m.id
);
GO

-- =============================================
-- PHẦN 3: ĐIỀN DỮ LIỆU ĐIỂM NGẪU NHIÊN CHO 2 HỌC KỲ
-- =============================================

-- 1. KHỞI TẠO BẢN GHI ĐIỂM CHO HK1 VÀ HK2
INSERT INTO diem (mahs, monhoc_id, hocky)
SELECT hs.mahs, m.id, hk.hocky
FROM hocsinh hs
CROSS JOIN monhoc m
CROSS JOIN (VALUES (1), (2)) AS hk(hocky) -- Thêm học kỳ 1 và 2
WHERE NOT EXISTS (
    SELECT 1 FROM diem d
    WHERE d.mahs = hs.mahs AND d.monhoc_id = m.id AND d.hocky = hk.hocky
);
GO

-- 2. ĐIỀN ĐIỂM THÀNH PHẦN NGẪU NHIÊN CHO CẢ HK1 VÀ HK2
UPDATE diem
SET
    mieng = ROUND(6.0 + (ABS(CHECKSUM(NEWID())) % 4001 / 1000.0), 1),
    kt_15p = ROUND(6.0 + (ABS(CHECKSUM(NEWID())) % 4001 / 1000.0), 1),
    kt_15p_lan2 = ROUND(6.0 + (ABS(CHECKSUM(NEWID())) % 4001 / 1000.0), 1),
    giua_ky = ROUND(6.0 + (ABS(CHECKSUM(NEWID())) % 4001 / 1000.0), 1),
    cuoi_ky = ROUND(6.0 + (ABS(CHECKSUM(NEWID())) % 4001 / 1000.0), 1);
GO

-- 3. TÍNH TOÁN ĐIỂM TRUNG BÌNH MÔN (DTB_MON) CHO CẢ HK1 VÀ HK2
UPDATE diem
SET
    dtb_mon = ROUND((mieng + kt_15p + kt_15p_lan2 + giua_ky * 2 + cuoi_ky * 3) / 8, 2);
GO

-- 3. CHÈN DỮ LIỆU THỜI KHÓA BIỂU
INSERT INTO thoikhoabieu (lop_id, thu, tiet, monhoc_id, magv) VALUES
-- TKB KHỐI 10
((SELECT id FROM lop WHERE tenlop = N'10A1'), N'Thứ 2', 1, (SELECT id FROM monhoc WHERE tenmonhoc = N'Toán'), (SELECT magv FROM giaovien WHERE hoten = N'Nguyễn Văn Hùng')),
((SELECT id FROM lop WHERE tenlop = N'10A2'), N'Thứ 2', 1, (SELECT id FROM monhoc WHERE tenmonhoc = N'Văn'), (SELECT magv FROM giaovien WHERE hoten = N'Trần Thị Hoa')),
((SELECT id FROM lop WHERE tenlop = N'10A3'), N'Thứ 2', 1, (SELECT id FROM monhoc WHERE tenmonhoc = N'Anh'), (SELECT magv FROM giaovien WHERE hoten = N'Phạm Quốc Bảo')),
((SELECT id FROM lop WHERE tenlop = N'10A4'), N'Thứ 2', 1, (SELECT id FROM monhoc WHERE tenmonhoc = N'Lý'), (SELECT magv FROM giaovien WHERE hoten = N'Ngô Văn Phước')),
((SELECT id FROM lop WHERE tenlop = N'10A5'), N'Thứ 2', 1, (SELECT id FROM monhoc WHERE tenmonhoc = N'Hóa'), (SELECT magv FROM giaovien WHERE hoten = N'Phạm Thị Ngọc')),
((SELECT id FROM lop WHERE tenlop = N'10A1'), N'Thứ 2', 2, (SELECT id FROM monhoc WHERE tenmonhoc = N'Văn'), (SELECT magv FROM giaovien WHERE hoten = N'Trần Thị Hoa')),
((SELECT id FROM lop WHERE tenlop = N'10A2'), N'Thứ 2', 2, (SELECT id FROM monhoc WHERE tenmonhoc = N'Anh'), (SELECT magv FROM giaovien WHERE hoten = N'Phạm Quốc Bảo')),
((SELECT id FROM lop WHERE tenlop = N'10A3'), N'Thứ 2', 2, (SELECT id FROM monhoc WHERE tenmonhoc = N'Toán'), (SELECT magv FROM giaovien WHERE hoten = N'Nguyễn Văn Hùng')),
((SELECT id FROM lop WHERE tenlop = N'10A4'), N'Thứ 2', 2, (SELECT id FROM monhoc WHERE tenmonhoc = N'Hóa'), (SELECT magv FROM giaovien WHERE hoten = N'Phạm Thị Ngọc')),
((SELECT id FROM lop WHERE tenlop = N'10A5'), N'Thứ 2', 2, (SELECT id FROM monhoc WHERE tenmonhoc = N'Sinh'), (SELECT magv FROM giaovien WHERE hoten = N'Nguyễn Thị Lan')),
((SELECT id FROM lop WHERE tenlop = N'10A1'), N'Thứ 2', 3, (SELECT id FROM monhoc WHERE tenmonhoc = N'Anh'), (SELECT magv FROM giaovien WHERE hoten = N'Phạm Quốc Bảo')),
((SELECT id FROM lop WHERE tenlop = N'10A2'), N'Thứ 2', 3, (SELECT id FROM monhoc WHERE tenmonhoc = N'Toán'), (SELECT magv FROM giaovien WHERE hoten = N'Nguyễn Văn Hùng')),
((SELECT id FROM lop WHERE tenlop = N'10A3'), N'Thứ 2', 3, (SELECT id FROM monhoc WHERE tenmonhoc = N'Văn'), (SELECT magv FROM giaovien WHERE hoten = N'Trần Thị Hoa')),
((SELECT id FROM lop WHERE tenlop = N'10A4'), N'Thứ 2', 3, (SELECT id FROM monhoc WHERE tenmonhoc = N'Sinh'), (SELECT magv FROM giaovien WHERE hoten = N'Nguyễn Thị Lan')),
((SELECT id FROM lop WHERE tenlop = N'10A5'), N'Thứ 2', 3, (SELECT id FROM monhoc WHERE tenmonhoc = N'Lý'), (SELECT magv FROM giaovien WHERE hoten = N'Ngô Văn Phước')),
((SELECT id FROM lop WHERE tenlop = N'10A1'), N'Thứ 3', 1, (SELECT id FROM monhoc WHERE tenmonhoc = N'Lý'), (SELECT magv FROM giaovien WHERE hoten = N'Ngô Văn Phước')),
((SELECT id FROM lop WHERE tenlop = N'10A2'), N'Thứ 3', 1, (SELECT id FROM monhoc WHERE tenmonhoc = N'Hóa'), (SELECT magv FROM giaovien WHERE hoten = N'Phạm Thị Ngọc')),
((SELECT id FROM lop WHERE tenlop = N'10A3'), N'Thứ 3', 1, (SELECT id FROM monhoc WHERE tenmonhoc = N'Sinh'), (SELECT magv FROM giaovien WHERE hoten = N'Nguyễn Thị Lan')),
((SELECT id FROM lop WHERE tenlop = N'10A4'), N'Thứ 3', 1, (SELECT id FROM monhoc WHERE tenmonhoc = N'Toán'), (SELECT magv FROM giaovien WHERE hoten = N'Nguyễn Văn Hùng')),
((SELECT id FROM lop WHERE tenlop = N'10A5'), N'Thứ 3', 1, (SELECT id FROM monhoc WHERE tenmonhoc = N'Văn'), (SELECT magv FROM giaovien WHERE hoten = N'Trần Thị Hoa')),
((SELECT id FROM lop WHERE tenlop = N'10A1'), N'Thứ 3', 2, (SELECT id FROM monhoc WHERE tenmonhoc = N'Hóa'), (SELECT magv FROM giaovien WHERE hoten = N'Phạm Thị Ngọc')),
((SELECT id FROM lop WHERE tenlop = N'10A2'), N'Thứ 3', 2, (SELECT id FROM monhoc WHERE tenmonhoc = N'Sinh'), (SELECT magv FROM giaovien WHERE hoten = N'Nguyễn Thị Lan')),
((SELECT id FROM lop WHERE tenlop = N'10A3'), N'Thứ 3', 2, (SELECT id FROM monhoc WHERE tenmonhoc = N'Lý'), (SELECT magv FROM giaovien WHERE hoten = N'Ngô Văn Phước')),
((SELECT id FROM lop WHERE tenlop = N'10A4'), N'Thứ 3', 2, (SELECT id FROM monhoc WHERE tenmonhoc = N'Văn'), (SELECT magv FROM giaovien WHERE hoten = N'Trần Thị Hoa')),
((SELECT id FROM lop WHERE tenlop = N'10A5'), N'Thứ 3', 2, (SELECT id FROM monhoc WHERE tenmonhoc = N'Anh'), (SELECT magv FROM giaovien WHERE hoten = N'Phạm Quốc Bảo')),
((SELECT id FROM lop WHERE tenlop = N'10A1'), N'Thứ 3', 3, (SELECT id FROM monhoc WHERE tenmonhoc = N'Sinh'), (SELECT magv FROM giaovien WHERE hoten = N'Nguyễn Thị Lan')),
((SELECT id FROM lop WHERE tenlop = N'10A2'), N'Thứ 3', 3, (SELECT id FROM monhoc WHERE tenmonhoc = N'Lý'), (SELECT magv FROM giaovien WHERE hoten = N'Ngô Văn Phước')),
((SELECT id FROM lop WHERE tenlop = N'10A3'), N'Thứ 3', 3, (SELECT id FROM monhoc WHERE tenmonhoc = N'Hóa'), (SELECT magv FROM giaovien WHERE hoten = N'Phạm Thị Ngọc')),
((SELECT id FROM lop WHERE tenlop = N'10A4'), N'Thứ 3', 3, (SELECT id FROM monhoc WHERE tenmonhoc = N'Anh'), (SELECT magv FROM giaovien WHERE hoten = N'Phạm Quốc Bảo')),
((SELECT id FROM lop WHERE tenlop = N'10A5'), N'Thứ 3', 3, (SELECT id FROM monhoc WHERE tenmonhoc = N'Toán'), (SELECT magv FROM giaovien WHERE hoten = N'Nguyễn Văn Hùng')),
((SELECT id FROM lop WHERE tenlop = N'10A1'), N'Thứ 4', 1, (SELECT id FROM monhoc WHERE tenmonhoc = N'Sử'), (SELECT magv FROM giaovien WHERE hoten = N'Trần Thị Thu')),
((SELECT id FROM lop WHERE tenlop = N'10A2'), N'Thứ 4', 1, (SELECT id FROM monhoc WHERE tenmonhoc = N'Địa'), (SELECT magv FROM giaovien WHERE hoten = N'Lê Văn Dũng')),
((SELECT id FROM lop WHERE tenlop = N'10A3'), N'Thứ 4', 1, (SELECT id FROM monhoc WHERE tenmonhoc = N'GDCD'), (SELECT magv FROM giaovien WHERE hoten = N'Trần Thị Thảo')),
((SELECT id FROM lop WHERE tenlop = N'10A4'), N'Thứ 4', 1, (SELECT id FROM monhoc WHERE tenmonhoc = N'Thể chất'), (SELECT magv FROM giaovien WHERE hoten = N'Phạm Văn Tâm')),
((SELECT id FROM lop WHERE tenlop = N'10A5'), N'Thứ 4', 1, (SELECT id FROM monhoc WHERE tenmonhoc = N'Quốc phòng'), (SELECT magv FROM giaovien WHERE hoten = N'Lê Tấn Dũng')),
((SELECT id FROM lop WHERE tenlop = N'10A1'), N'Thứ 4', 2, (SELECT id FROM monhoc WHERE tenmonhoc = N'Địa'), (SELECT magv FROM giaovien WHERE hoten = N'Lê Văn Dũng')),
((SELECT id FROM lop WHERE tenlop = N'10A2'), N'Thứ 4', 2, (SELECT id FROM monhoc WHERE tenmonhoc = N'GDCD'), (SELECT magv FROM giaovien WHERE hoten = N'Trần Thị Thảo')),
((SELECT id FROM lop WHERE tenlop = N'10A3'), N'Thứ 4', 2, (SELECT id FROM monhoc WHERE tenmonhoc = N'Thể chất'), (SELECT magv FROM giaovien WHERE hoten = N'Phạm Văn Tâm')),
((SELECT id FROM lop WHERE tenlop = N'10A4'), N'Thứ 4', 2, (SELECT id FROM monhoc WHERE tenmonhoc = N'Quốc phòng'), (SELECT magv FROM giaovien WHERE hoten = N'Lê Tấn Dũng')),
((SELECT id FROM lop WHERE tenlop = N'10A5'), N'Thứ 4', 2, (SELECT id FROM monhoc WHERE tenmonhoc = N'Sử'), (SELECT magv FROM giaovien WHERE hoten = N'Trần Thị Thu')),
((SELECT id FROM lop WHERE tenlop = N'10A1'), N'Thứ 4', 3, (SELECT id FROM monhoc WHERE tenmonhoc = N'GDCD'), (SELECT magv FROM giaovien WHERE hoten = N'Trần Thị Thảo')),
((SELECT id FROM lop WHERE tenlop = N'10A2'), N'Thứ 4', 3, (SELECT id FROM monhoc WHERE tenmonhoc = N'Thể chất'), (SELECT magv FROM giaovien WHERE hoten = N'Phạm Văn Tâm')),
((SELECT id FROM lop WHERE tenlop = N'10A3'), N'Thứ 4', 3, (SELECT id FROM monhoc WHERE tenmonhoc = N'Quốc phòng'), (SELECT magv FROM giaovien WHERE hoten = N'Lê Tấn Dũng')),
((SELECT id FROM lop WHERE tenlop = N'10A4'), N'Thứ 4', 3, (SELECT id FROM monhoc WHERE tenmonhoc = N'Sử'), (SELECT magv FROM giaovien WHERE hoten = N'Trần Thị Thu')),
((SELECT id FROM lop WHERE tenlop = N'10A5'), N'Thứ 4', 3, (SELECT id FROM monhoc WHERE tenmonhoc = N'Địa'), (SELECT magv FROM giaovien WHERE hoten = N'Lê Văn Dũng')),
((SELECT id FROM lop WHERE tenlop = N'10A1'), N'Thứ 5', 1, (SELECT id FROM monhoc WHERE tenmonhoc = N'Thể chất'), (SELECT magv FROM giaovien WHERE hoten = N'Phạm Văn Tâm')),
((SELECT id FROM lop WHERE tenlop = N'10A2'), N'Thứ 5', 1, (SELECT id FROM monhoc WHERE tenmonhoc = N'Quốc phòng'), (SELECT magv FROM giaovien WHERE hoten = N'Lê Tấn Dũng')),
((SELECT id FROM lop WHERE tenlop = N'10A3'), N'Thứ 5', 1, (SELECT id FROM monhoc WHERE tenmonhoc = N'Sử'), (SELECT magv FROM giaovien WHERE hoten = N'Trần Thị Thu')),
((SELECT id FROM lop WHERE tenlop = N'10A4'), N'Thứ 5', 1, (SELECT id FROM monhoc WHERE tenmonhoc = N'Địa'), (SELECT magv FROM giaovien WHERE hoten = N'Lê Văn Dũng')),
((SELECT id FROM lop WHERE tenlop = N'10A5'), N'Thứ 5', 1, (SELECT id FROM monhoc WHERE tenmonhoc = N'GDCD'), (SELECT magv FROM giaovien WHERE hoten = N'Trần Thị Thảo')),
((SELECT id FROM lop WHERE tenlop = N'10A1'), N'Thứ 5', 2, (SELECT id FROM monhoc WHERE tenmonhoc = N'Quốc phòng'), (SELECT magv FROM giaovien WHERE hoten = N'Lê Tấn Dũng')),
((SELECT id FROM lop WHERE tenlop = N'10A2'), N'Thứ 5', 2, (SELECT id FROM monhoc WHERE tenmonhoc = N'Sử'), (SELECT magv FROM giaovien WHERE hoten = N'Trần Thị Thu')),
((SELECT id FROM lop WHERE tenlop = N'10A3'), N'Thứ 5', 2, (SELECT id FROM monhoc WHERE tenmonhoc = N'Địa'), (SELECT magv FROM giaovien WHERE hoten = N'Lê Văn Dũng')),
((SELECT id FROM lop WHERE tenlop = N'10A4'), N'Thứ 5', 2, (SELECT id FROM monhoc WHERE tenmonhoc = N'GDCD'), (SELECT magv FROM giaovien WHERE hoten = N'Trần Thị Thảo')),
((SELECT id FROM lop WHERE tenlop = N'10A5'), N'Thứ 5', 2, (SELECT id FROM monhoc WHERE tenmonhoc = N'Thể chất'), (SELECT magv FROM giaovien WHERE hoten = N'Phạm Văn Tâm')),
-- TKB KHỐI 11
((SELECT id FROM lop WHERE tenlop = N'11A1'), N'Thứ 2', 4, (SELECT id FROM monhoc WHERE tenmonhoc = N'Toán'), (SELECT magv FROM giaovien WHERE hoten = N'Nguyễn Văn Hùng')),
((SELECT id FROM lop WHERE tenlop = N'11A2'), N'Thứ 2', 4, (SELECT id FROM monhoc WHERE tenmonhoc = N'Văn'), (SELECT magv FROM giaovien WHERE hoten = N'Trần Thị Hoa')),
((SELECT id FROM lop WHERE tenlop = N'11A3'), N'Thứ 2', 4, (SELECT id FROM monhoc WHERE tenmonhoc = N'Anh'), (SELECT magv FROM giaovien WHERE hoten = N'Phạm Quốc Bảo')),
((SELECT id FROM lop WHERE tenlop = N'11A4'), N'Thứ 2', 4, (SELECT id FROM monhoc WHERE tenmonhoc = N'Lý'), (SELECT magv FROM giaovien WHERE hoten = N'Ngô Văn Phước')),
((SELECT id FROM lop WHERE tenlop = N'11A5'), N'Thứ 2', 4, (SELECT id FROM monhoc WHERE tenmonhoc = N'Hóa'), (SELECT magv FROM giaovien WHERE hoten = N'Phạm Thị Ngọc')),
((SELECT id FROM lop WHERE tenlop = N'11A1'), N'Thứ 2', 5, (SELECT id FROM monhoc WHERE tenmonhoc = N'Văn'), (SELECT magv FROM giaovien WHERE hoten = N'Trần Thị Hoa')),
((SELECT id FROM lop WHERE tenlop = N'11A2'), N'Thứ 2', 5, (SELECT id FROM monhoc WHERE tenmonhoc = N'Anh'), (SELECT magv FROM giaovien WHERE hoten = N'Phạm Quốc Bảo')),
((SELECT id FROM lop WHERE tenlop = N'11A3'), N'Thứ 2', 5, (SELECT id FROM monhoc WHERE tenmonhoc = N'Toán'), (SELECT magv FROM giaovien WHERE hoten = N'Nguyễn Văn Hùng')),
((SELECT id FROM lop WHERE tenlop = N'11A4'), N'Thứ 2', 5, (SELECT id FROM monhoc WHERE tenmonhoc = N'Hóa'), (SELECT magv FROM giaovien WHERE hoten = N'Phạm Thị Ngọc')),
((SELECT id FROM lop WHERE tenlop = N'11A5'), N'Thứ 2', 5, (SELECT id FROM monhoc WHERE tenmonhoc = N'Sinh'), (SELECT magv FROM giaovien WHERE hoten = N'Nguyễn Thị Lan')),
((SELECT id FROM lop WHERE tenlop = N'11A1'), N'Thứ 3', 4, (SELECT id FROM monhoc WHERE tenmonhoc = N'Lý'), (SELECT magv FROM giaovien WHERE hoten = N'Ngô Văn Phước')),
((SELECT id FROM lop WHERE tenlop = N'11A2'), N'Thứ 3', 4, (SELECT id FROM monhoc WHERE tenmonhoc = N'Hóa'), (SELECT magv FROM giaovien WHERE hoten = N'Phạm Thị Ngọc')),
((SELECT id FROM lop WHERE tenlop = N'11A3'), N'Thứ 3', 4, (SELECT id FROM monhoc WHERE tenmonhoc = N'Sinh'), (SELECT magv FROM giaovien WHERE hoten = N'Nguyễn Thị Lan')),
((SELECT id FROM lop WHERE tenlop = N'11A4'), N'Thứ 3', 4, (SELECT id FROM monhoc WHERE tenmonhoc = N'Toán'), (SELECT magv FROM giaovien WHERE hoten = N'Nguyễn Văn Hùng')),
((SELECT id FROM lop WHERE tenlop = N'11A5'), N'Thứ 3', 4, (SELECT id FROM monhoc WHERE tenmonhoc = N'Văn'), (SELECT magv FROM giaovien WHERE hoten = N'Trần Thị Hoa')),
((SELECT id FROM lop WHERE tenlop = N'11A1'), N'Thứ 3', 5, (SELECT id FROM monhoc WHERE tenmonhoc = N'Hóa'), (SELECT magv FROM giaovien WHERE hoten = N'Phạm Thị Ngọc')),
((SELECT id FROM lop WHERE tenlop = N'11A2'), N'Thứ 3', 5, (SELECT id FROM monhoc WHERE tenmonhoc = N'Sinh'), (SELECT magv FROM giaovien WHERE hoten = N'Nguyễn Thị Lan')),
((SELECT id FROM lop WHERE tenlop = N'11A3'), N'Thứ 3', 5, (SELECT id FROM monhoc WHERE tenmonhoc = N'Lý'), (SELECT magv FROM giaovien WHERE hoten = N'Ngô Văn Phước')),
((SELECT id FROM lop WHERE tenlop = N'11A4'), N'Thứ 3', 5, (SELECT id FROM monhoc WHERE tenmonhoc = N'Văn'), (SELECT magv FROM giaovien WHERE hoten = N'Trần Thị Hoa')),
((SELECT id FROM lop WHERE tenlop = N'11A5'), N'Thứ 3', 5, (SELECT id FROM monhoc WHERE tenmonhoc = N'Anh'), (SELECT magv FROM giaovien WHERE hoten = N'Phạm Quốc Bảo')),
((SELECT id FROM lop WHERE tenlop = N'11A1'), N'Thứ 4', 4, (SELECT id FROM monhoc WHERE tenmonhoc = N'Sử'), (SELECT magv FROM giaovien WHERE hoten = N'Trần Thị Thu')),
((SELECT id FROM lop WHERE tenlop = N'11A2'), N'Thứ 4', 4, (SELECT id FROM monhoc WHERE tenmonhoc = N'Địa'), (SELECT magv FROM giaovien WHERE hoten = N'Lê Văn Dũng')),
((SELECT id FROM lop WHERE tenlop = N'11A3'), N'Thứ 4', 4, (SELECT id FROM monhoc WHERE tenmonhoc = N'GDCD'), (SELECT magv FROM giaovien WHERE hoten = N'Trần Thị Thảo')),
((SELECT id FROM lop WHERE tenlop = N'11A4'), N'Thứ 4', 4, (SELECT id FROM monhoc WHERE tenmonhoc = N'Thể chất'), (SELECT magv FROM giaovien WHERE hoten = N'Phạm Văn Tâm')),
((SELECT id FROM lop WHERE tenlop = N'11A5'), N'Thứ 4', 4, (SELECT id FROM monhoc WHERE tenmonhoc = N'Quốc phòng'), (SELECT magv FROM giaovien WHERE hoten = N'Lê Tấn Dũng')),
((SELECT id FROM lop WHERE tenlop = N'11A1'), N'Thứ 4', 5, (SELECT id FROM monhoc WHERE tenmonhoc = N'Địa'), (SELECT magv FROM giaovien WHERE hoten = N'Lê Văn Dũng')),
((SELECT id FROM lop WHERE tenlop = N'11A2'), N'Thứ 4', 5, (SELECT id FROM monhoc WHERE tenmonhoc = N'GDCD'), (SELECT magv FROM giaovien WHERE hoten = N'Trần Thị Thảo')),
((SELECT id FROM lop WHERE tenlop = N'11A3'), N'Thứ 4', 5, (SELECT id FROM monhoc WHERE tenmonhoc = N'Thể chất'), (SELECT magv FROM giaovien WHERE hoten = N'Phạm Văn Tâm')),
((SELECT id FROM lop WHERE tenlop = N'11A4'), N'Thứ 4', 5, (SELECT id FROM monhoc WHERE tenmonhoc = N'Quốc phòng'), (SELECT magv FROM giaovien WHERE hoten = N'Lê Tấn Dũng')),
((SELECT id FROM lop WHERE tenlop = N'11A5'), N'Thứ 4', 5, (SELECT id FROM monhoc WHERE tenmonhoc = N'Sử'), (SELECT magv FROM giaovien WHERE hoten = N'Trần Thị Thu')),
((SELECT id FROM lop WHERE tenlop = N'11A1'), N'Thứ 5', 3, (SELECT id FROM monhoc WHERE tenmonhoc = N'GDCD'), (SELECT magv FROM giaovien WHERE hoten = N'Trần Thị Thảo')),
((SELECT id FROM lop WHERE tenlop = N'11A2'), N'Thứ 5', 3, (SELECT id FROM monhoc WHERE tenmonhoc = N'Thể chất'), (SELECT magv FROM giaovien WHERE hoten = N'Phạm Văn Tâm')),
((SELECT id FROM lop WHERE tenlop = N'11A3'), N'Thứ 5', 3, (SELECT id FROM monhoc WHERE tenmonhoc = N'Quốc phòng'), (SELECT magv FROM giaovien WHERE hoten = N'Lê Tấn Dũng')),
((SELECT id FROM lop WHERE tenlop = N'11A4'), N'Thứ 5', 3, (SELECT id FROM monhoc WHERE tenmonhoc = N'Sử'), (SELECT magv FROM giaovien WHERE hoten = N'Trần Thị Thu')),
((SELECT id FROM lop WHERE tenlop = N'11A5'), N'Thứ 5', 3, (SELECT id FROM monhoc WHERE tenmonhoc = N'Địa'), (SELECT magv FROM giaovien WHERE hoten = N'Lê Văn Dũng')),
((SELECT id FROM lop WHERE tenlop = N'11A1'), N'Thứ 5', 4, (SELECT id FROM monhoc WHERE tenmonhoc = N'Thể chất'), (SELECT magv FROM giaovien WHERE hoten = N'Phạm Văn Tâm')),
((SELECT id FROM lop WHERE tenlop = N'11A2'), N'Thứ 5', 4, (SELECT id FROM monhoc WHERE tenmonhoc = N'Quốc phòng'), (SELECT magv FROM giaovien WHERE hoten = N'Lê Tấn Dũng')),
((SELECT id FROM lop WHERE tenlop = N'11A3'), N'Thứ 5', 4, (SELECT id FROM monhoc WHERE tenmonhoc = N'Sử'), (SELECT magv FROM giaovien WHERE hoten = N'Trần Thị Thu')),
((SELECT id FROM lop WHERE tenlop = N'11A4'), N'Thứ 5', 4, (SELECT id FROM monhoc WHERE tenmonhoc = N'Địa'), (SELECT magv FROM giaovien WHERE hoten = N'Lê Văn Dũng')),
((SELECT id FROM lop WHERE tenlop = N'11A5'), N'Thứ 5', 4, (SELECT id FROM monhoc WHERE tenmonhoc = N'GDCD'), (SELECT magv FROM giaovien WHERE hoten = N'Trần Thị Thảo')),
((SELECT id FROM lop WHERE tenlop = N'11A1'), N'Thứ 5', 5, (SELECT id FROM monhoc WHERE tenmonhoc = N'Quốc phòng'), (SELECT magv FROM giaovien WHERE hoten = N'Lê Tấn Dũng')),
((SELECT id FROM lop WHERE tenlop = N'11A2'), N'Thứ 5', 5, (SELECT id FROM monhoc WHERE tenmonhoc = N'Sử'), (SELECT magv FROM giaovien WHERE hoten = N'Trần Thị Thu')),
((SELECT id FROM lop WHERE tenlop = N'11A3'), N'Thứ 5', 5, (SELECT id FROM monhoc WHERE tenmonhoc = N'Địa'), (SELECT magv FROM giaovien WHERE hoten = N'Lê Văn Dũng')),
((SELECT id FROM lop WHERE tenlop = N'11A4'), N'Thứ 5', 5, (SELECT id FROM monhoc WHERE tenmonhoc = N'GDCD'), (SELECT magv FROM giaovien WHERE hoten = N'Trần Thị Thảo')),
((SELECT id FROM lop WHERE tenlop = N'11A5'), N'Thứ 5', 5, (SELECT id FROM monhoc WHERE tenmonhoc = N'Thể chất'), (SELECT magv FROM giaovien WHERE hoten = N'Phạm Văn Tâm')),
-- TKB KHỐI 12
((SELECT id FROM lop WHERE tenlop = N'12A1'), N'Thứ 6', 1, (SELECT id FROM monhoc WHERE tenmonhoc = N'Toán'), (SELECT magv FROM giaovien WHERE hoten = N'Nguyễn Văn Hùng')),
((SELECT id FROM lop WHERE tenlop = N'12A2'), N'Thứ 6', 1, (SELECT id FROM monhoc WHERE tenmonhoc = N'Văn'), (SELECT magv FROM giaovien WHERE hoten = N'Trần Thị Hoa')),
((SELECT id FROM lop WHERE tenlop = N'12A3'), N'Thứ 6', 1, (SELECT id FROM monhoc WHERE tenmonhoc = N'Anh'), (SELECT magv FROM giaovien WHERE hoten = N'Phạm Quốc Bảo')),
((SELECT id FROM lop WHERE tenlop = N'12A1'), N'Thứ 6', 2, (SELECT id FROM monhoc WHERE tenmonhoc = N'Văn'), (SELECT magv FROM giaovien WHERE hoten = N'Bùi Văn Lộc')),
((SELECT id FROM lop WHERE tenlop = N'12A2'), N'Thứ 6', 2, (SELECT id FROM monhoc WHERE tenmonhoc = N'Toán'), (SELECT magv FROM giaovien WHERE hoten = N'Ngô Văn Hoàng')),
((SELECT id FROM lop WHERE tenlop = N'12A3'), N'Thứ 6', 2, (SELECT id FROM monhoc WHERE tenmonhoc = N'Lý'), (SELECT magv FROM giaovien WHERE hoten = N'Ngô Văn Phước')),
((SELECT id FROM lop WHERE tenlop = N'12A1'), N'Thứ 6', 3, (SELECT id FROM monhoc WHERE tenmonhoc = N'Hóa'), (SELECT magv FROM giaovien WHERE hoten = N'Phạm Thị Ngọc')),
((SELECT id FROM lop WHERE tenlop = N'12A2'), N'Thứ 6', 3, (SELECT id FROM monhoc WHERE tenmonhoc = N'Sinh'), (SELECT magv FROM giaovien WHERE hoten = N'Nguyễn Thị Lan')),
((SELECT id FROM lop WHERE tenlop = N'12A3'), N'Thứ 6', 3, (SELECT id FROM monhoc WHERE tenmonhoc = N'Sử'), (SELECT magv FROM giaovien WHERE hoten = N'Trần Thị Thu')),
((SELECT id FROM lop WHERE tenlop = N'12A1'), N'Thứ 6', 4, (SELECT id FROM monhoc WHERE tenmonhoc = N'Địa'), (SELECT magv FROM giaovien WHERE hoten = N'Lê Văn Dũng')),
((SELECT id FROM lop WHERE tenlop = N'12A2'), N'Thứ 6', 4, (SELECT id FROM monhoc WHERE tenmonhoc = N'GDCD'), (SELECT magv FROM giaovien WHERE hoten = N'Trần Thị Thảo')),
((SELECT id FROM lop WHERE tenlop = N'12A3'), N'Thứ 6', 4, (SELECT id FROM monhoc WHERE tenmonhoc = N'Thể chất'), (SELECT magv FROM giaovien WHERE hoten = N'Phạm Văn Tâm')),
((SELECT id FROM lop WHERE tenlop = N'12A1'), N'Thứ 6', 5, (SELECT id FROM monhoc WHERE tenmonhoc = N'Quốc phòng'), (SELECT magv FROM giaovien WHERE hoten = N'Lê Tấn Dũng'));
GO

-- 4. CHÈN DỮ LIỆU TÀI KHOẢN
INSERT INTO users (username, password, fullname, role) VALUES
('admin', '12345', N'Quản trị viên', 'admin');

-- Chuyển CONCAT thành phép cộng chuỗi và CAST
INSERT INTO users (username, password, fullname, role)
SELECT ('gv' + CAST(magv AS VARCHAR(10))) AS username, '12345' AS password, hoten AS fullname, 'teacher' AS role FROM giaovien;

-- Chuyển CONCAT thành phép cộng chuỗi và CAST
INSERT INTO users (username, password, fullname, role)
SELECT CAST(mahs AS VARCHAR(50)) AS username, '12345' AS password, (holot + N' ' + ten) AS fullname, 'student' AS role FROM hocsinh;
GO

-- 5. TÍNH TOÁN LẠI HỌC LỰC VÀ TB CẢ NĂM
-- Cú pháp UPDATE...FROM...JOIN của T-SQL
UPDATE h
SET
    h.tbcanam = ROUND(d.avg_dtb, 2),
    h.hocluc = CASE
        WHEN d.avg_dtb >= 8.0 THEN N'Giỏi'
        WHEN d.avg_dtb >= 6.5 THEN N'Khá'
        WHEN d.avg_dtb >= 5.0 THEN N'Trung bình'
        ELSE N'Yếu'
    END
FROM hocsinh h
JOIN (
    SELECT mahs, AVG(dtb_mon) AS avg_dtb FROM diem WHERE dtb_mon IS NOT NULL GROUP BY mahs
) d ON h.mahs = d.mahs;
GO

-- =============================================
-- HOÀN TẤT
-- =============================================
SELECT N'🎉🎉🎉 Database QLHS đã được tạo và chuẩn hóa HOÀN TOÀN cho SQL Server! 🎉🎉🎉' AS Status;
GO