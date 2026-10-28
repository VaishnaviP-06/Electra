
CREATE DATABASE IF NOT EXISTS electra_db
    CHARACTER SET utf8mb4
    COLLATE utf8mb4_unicode_ci;

USE electra_db;

-- 1. Users: credentials and roles
CREATE TABLE users (
    user_id BIGINT PRIMARY KEY AUTO_INCREMENT,
    username VARCHAR(50) NOT NULL UNIQUE,
    password_hash VARCHAR(255) NOT NULL,
    role ENUM('STUDENT', 'ADMIN') NOT NULL,
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB;

-- 2. Student profiles
CREATE TABLE students (
    student_id BIGINT PRIMARY KEY AUTO_INCREMENT,
    user_id BIGINT NOT NULL UNIQUE,
    roll_number VARCHAR(30) NOT NULL UNIQUE,
    student_name VARCHAR(100) NOT NULL,
    cgpa DECIMAL(4,2) NOT NULL,
    email VARCHAR(150),
    batch_or_cycle VARCHAR(50),

    CONSTRAINT fk_students_user
        FOREIGN KEY (user_id)
        REFERENCES users(user_id),

    CONSTRAINT chk_student_cgpa
        CHECK (cgpa >= 0 AND cgpa <= 10)
) ENGINE=InnoDB;

-- 3. Independent elective allocation forms
CREATE TABLE allocation_forms (
    form_id BIGINT PRIMARY KEY AUTO_INCREMENT,
    form_name VARCHAR(100) NOT NULL,
    category_name VARCHAR(50) NOT NULL,
    batch_or_cycle VARCHAR(50) NOT NULL,

    opening_date DATETIME NULL,
    submission_deadline DATETIME NULL,

    form_status ENUM('DRAFT', 'OPEN', 'CLOSED')
        NOT NULL DEFAULT 'DRAFT',

    allocation_status ENUM(
        'NOT_STARTED', 'IN_PROGRESS', 'COMPLETED'
    ) NOT NULL DEFAULT 'NOT_STARTED',

    review_status ENUM(
        'NOT_STARTED', 'PENDING', 'REVIEWED'
    ) NOT NULL DEFAULT 'NOT_STARTED',

    results_published BOOLEAN NOT NULL DEFAULT FALSE,

    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT chk_form_dates CHECK (
        opening_date IS NULL
        OR submission_deadline IS NULL
        OR submission_deadline >= opening_date
    )
) ENGINE=InnoDB;

-- 4. Electives belonging to a specific form
CREATE TABLE electives (
    elective_id BIGINT PRIMARY KEY AUTO_INCREMENT,
    form_id BIGINT NOT NULL,
    elective_code VARCHAR(30) NOT NULL,
    elective_name VARCHAR(150) NOT NULL,
    syllabus TEXT,
    faculty_name VARCHAR(100),

    total_seats INT NOT NULL,
    min_students INT NOT NULL DEFAULT 1,
    min_cgpa DECIMAL(4,2) NULL,

    is_active BOOLEAN NOT NULL DEFAULT TRUE,

    enrolment_status ENUM(
        'PENDING', 'OK', 'BELOW_MINIMUM_ENROLMENT'
    ) NOT NULL DEFAULT 'PENDING',

    UNIQUE KEY uq_form_elective_code (form_id, elective_code),
    UNIQUE KEY uq_form_elective_id (form_id, elective_id),

    CONSTRAINT fk_electives_form
        FOREIGN KEY (form_id)
        REFERENCES allocation_forms(form_id),

    CONSTRAINT chk_elective_seats
        CHECK (total_seats > 0),

    CONSTRAINT chk_min_students
        CHECK (min_students >= 0 AND min_students <= total_seats),

    CONSTRAINT chk_elective_cgpa
        CHECK (min_cgpa IS NULL OR (min_cgpa >= 0 AND min_cgpa <= 10))
) ENGINE=InnoDB;

-- 5. One current preference submission per student per form
CREATE TABLE preference_submissions (
    submission_id BIGINT PRIMARY KEY AUTO_INCREMENT,
    student_id BIGINT NOT NULL,
    form_id BIGINT NOT NULL,

    submitted_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,

    submission_status ENUM('DRAFT', 'SUBMITTED')
        NOT NULL DEFAULT 'SUBMITTED',

    UNIQUE KEY uq_student_form_submission (student_id, form_id),
    UNIQUE KEY uq_submission_form (submission_id, form_id),

    CONSTRAINT fk_submission_student
        FOREIGN KEY (student_id)
        REFERENCES students(student_id),

    CONSTRAINT fk_submission_form
        FOREIGN KEY (form_id)
        REFERENCES allocation_forms(form_id)
) ENGINE=InnoDB;

-- 6. Ranked elective choices
CREATE TABLE student_preferences (
    preference_id BIGINT PRIMARY KEY AUTO_INCREMENT,
    submission_id BIGINT NOT NULL,
    form_id BIGINT NOT NULL,
    elective_id BIGINT NOT NULL,
    preference_rank INT NOT NULL,

    UNIQUE KEY uq_submission_elective (submission_id, elective_id),
    UNIQUE KEY uq_submission_rank (submission_id, preference_rank),

    CONSTRAINT fk_preference_submission
        FOREIGN KEY (submission_id, form_id)
        REFERENCES preference_submissions(submission_id, form_id),

    CONSTRAINT fk_preference_elective
        FOREIGN KEY (form_id, elective_id)
        REFERENCES electives(form_id, elective_id),

    CONSTRAINT chk_preference_rank
        CHECK (preference_rank > 0)
) ENGINE=InnoDB;

-- 7. Each allocation run belongs to one form
CREATE TABLE allocation_runs (
    allocation_run_id BIGINT PRIMARY KEY AUTO_INCREMENT,
    form_id BIGINT NOT NULL,

    run_timestamp TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,

    run_status ENUM('RUNNING', 'COMPLETED', 'FAILED')
        NOT NULL DEFAULT 'RUNNING',

    run_type ENUM('INITIAL', 'RERUN')
        NOT NULL DEFAULT 'INITIAL',

    CONSTRAINT fk_run_form
        FOREIGN KEY (form_id)
        REFERENCES allocation_forms(form_id),

    UNIQUE KEY uq_run_form (allocation_run_id, form_id)
) ENGINE=InnoDB;

-- 8. Provisional and finalized allocation records
CREATE TABLE allocations (
    allocation_id BIGINT PRIMARY KEY AUTO_INCREMENT,
    allocation_run_id BIGINT NOT NULL,
    form_id BIGINT NOT NULL,
    student_id BIGINT NOT NULL,
    elective_id BIGINT NULL,

    allocation_status ENUM(
        'PROVISIONAL', 'ALLOCATED', 'NOT_ALLOTTED'
    ) NOT NULL DEFAULT 'PROVISIONAL',

    allocation_reason VARCHAR(100) NULL,

    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,

    UNIQUE KEY uq_run_student (allocation_run_id, student_id),

    CONSTRAINT fk_allocation_run
        FOREIGN KEY (allocation_run_id, form_id)
        REFERENCES allocation_runs(allocation_run_id, form_id),

    CONSTRAINT fk_allocation_student
        FOREIGN KEY (student_id)
        REFERENCES students(student_id),

    CONSTRAINT fk_allocation_elective
        FOREIGN KEY (form_id, elective_id)
        REFERENCES electives(form_id, elective_id)
) ENGINE=InnoDB;

-- 9. Administrator review of minimum enrolment
CREATE TABLE elective_form_reviews (
    review_id BIGINT PRIMARY KEY AUTO_INCREMENT,
    form_id BIGINT NOT NULL,
    elective_id BIGINT NOT NULL,

    review_status ENUM(
        'PENDING', 'BELOW_MINIMUM_ENROLMENT', 'REVIEWED'
    ) NOT NULL DEFAULT 'PENDING',

    review_notes VARCHAR(500),
    reviewed_by BIGINT NULL,
    reviewed_at DATETIME NULL,

    UNIQUE KEY uq_form_review (form_id, elective_id),

    CONSTRAINT fk_review_elective
        FOREIGN KEY (form_id, elective_id)
        REFERENCES electives(form_id, elective_id),

    CONSTRAINT fk_review_admin
        FOREIGN KEY (reviewed_by)
        REFERENCES users(user_id)
) ENGINE=InnoDB;


-- Student profile details
CREATE TABLE student_profile (
    student_id BIGINT PRIMARY KEY,
    full_name VARCHAR(100) NOT NULL,
    email VARCHAR(150) NOT NULL,
    roll_number VARCHAR(30) NOT NULL UNIQUE,
    department ENUM('CMPN', 'INFT', 'EXTC', 'ECS') NOT NULL,
    academic_year ENUM('Second Year', 'Third Year', 'Final Year') NOT NULL,
    cgpa DECIMAL(4,2) NOT NULL,

    CONSTRAINT chk_profile_cgpa
        CHECK (cgpa >= 0 AND cgpa <= 10),

    CONSTRAINT fk_profile_student
        FOREIGN KEY (student_id)
        REFERENCES students(student_id)
) ENGINE=InnoDB;

-- Useful indexes for common queries
CREATE INDEX idx_forms_status
    ON allocation_forms(form_status);

CREATE INDEX idx_electives_form_active
    ON electives(form_id, is_active);

CREATE INDEX idx_preferences_submission_rank
    ON student_preferences(submission_id, preference_rank);

CREATE INDEX idx_allocations_form_student
    ON allocations(form_id, student_id);
