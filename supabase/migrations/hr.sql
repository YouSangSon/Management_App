-- 직원 기본 정보 테이블
CREATE TABLE employees (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    employee_id VARCHAR(10) UNIQUE NOT NULL,  -- 사번
    name VARCHAR(50) NOT NULL,                -- 이름
    department VARCHAR(50) NOT NULL,          -- 부서
    position VARCHAR(50) NOT NULL,            -- 직위
    employment_type VARCHAR(20) NOT NULL,     -- 고용형태
    email VARCHAR(100) UNIQUE NOT NULL,       -- 이메일
    phone VARCHAR(20) NOT NULL,               -- 전화번호
    hire_date DATE NOT NULL,                  -- 입사일
    address TEXT,                             -- 주소
    photo_url TEXT,                          -- 프로필 사진 URL
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 학력 정보 테이블
CREATE TABLE education (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    employee_id UUID REFERENCES employees(id) ON DELETE CASCADE,
    school VARCHAR(100) NOT NULL,             -- 학교명
    major VARCHAR(100) NOT NULL,              -- 전공
    degree VARCHAR(50) NOT NULL,              -- 학위
    start_date DATE NOT NULL,                 -- 입학일
    end_date DATE,                            -- 졸업일
    gpa VARCHAR(20),                          -- 학점
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 경력 정보 테이블
CREATE TABLE career (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    employee_id UUID REFERENCES employees(id) ON DELETE CASCADE,
    company VARCHAR(100) NOT NULL,            -- 회사명
    position VARCHAR(50) NOT NULL,            -- 직위
    start_date DATE NOT NULL,                 -- 시작일
    end_date DATE,                            -- 종료일
    responsibilities TEXT,                    -- 담당업무
    salary INTEGER,                           -- 연봉
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 자격증 정보 테이블
CREATE TABLE certificates (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    employee_id UUID REFERENCES employees(id) ON DELETE CASCADE,
    name VARCHAR(100) NOT NULL,               -- 자격증명
    level VARCHAR(50),                        -- 등급
    issue_date DATE NOT NULL,                 -- 취득일
    expiry_date DATE,                         -- 만료일
    organization VARCHAR(100) NOT NULL,       -- 발급기관
    verified BOOLEAN DEFAULT false,           -- 검증여부
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 어학능력 정보 테이블
CREATE TABLE language_skills (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    employee_id UUID REFERENCES employees(id) ON DELETE CASCADE,
    test_name VARCHAR(50) NOT NULL,           -- 시험명
    score VARCHAR(20) NOT NULL,               -- 점수
    test_date DATE NOT NULL,                  -- 시험일
    expiry_date DATE,                         -- 만료일
    organization VARCHAR(100) NOT NULL,       -- 시험기관
    verified BOOLEAN DEFAULT false,           -- 검증여부
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 급여 정보 테이블
CREATE TABLE payroll (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    employee_id UUID REFERENCES employees(id) ON DELETE CASCADE,
    payment_date DATE NOT NULL,               -- 지급일
    basic_salary INTEGER NOT NULL,            -- 기본급
    allowance INTEGER NOT NULL DEFAULT 0,     -- 수당
    deduction INTEGER NOT NULL DEFAULT 0,     -- 공제
    total_payment INTEGER NOT NULL,           -- 총지급액
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 은행 계좌 정보 테이블
CREATE TABLE bank_accounts (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    employee_id UUID REFERENCES employees(id) ON DELETE CASCADE,
    bank_name VARCHAR(50) NOT NULL,           -- 은행명
    account_number VARCHAR(50) NOT NULL,      -- 계좌번호
    account_holder VARCHAR(50) NOT NULL,      -- 예금주
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 자동 업데이트 트리거 함수
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ language 'plpgsql';

-- 각 테이블에 업데이트 트리거 적용
CREATE TRIGGER update_employees_updated_at
    BEFORE UPDATE ON employees
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_education_updated_at
    BEFORE UPDATE ON education
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_career_updated_at
    BEFORE UPDATE ON career
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_certificates_updated_at
    BEFORE UPDATE ON certificates
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_language_skills_updated_at
    BEFORE UPDATE ON language_skills
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_payroll_updated_at
    BEFORE UPDATE ON payroll
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_bank_accounts_updated_at
    BEFORE UPDATE ON bank_accounts
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

-- 인덱스 생성
CREATE INDEX idx_employees_employee_id ON employees(employee_id);
CREATE INDEX idx_employees_department ON employees(department);
CREATE INDEX idx_employees_employment_type ON employees(employment_type);
CREATE INDEX idx_education_employee_id ON education(employee_id);
CREATE INDEX idx_career_employee_id ON career(employee_id);
CREATE INDEX idx_certificates_employee_id ON certificates(employee_id);
CREATE INDEX idx_language_skills_employee_id ON language_skills(employee_id);
CREATE INDEX idx_payroll_employee_id ON payroll(employee_id);
CREATE INDEX idx_bank_accounts_employee_id ON bank_accounts(employee_id);
