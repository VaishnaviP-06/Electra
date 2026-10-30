-- Electra Sample Demonstration Data
-- Reproducible seed data compatible with Electra application logic

USE electra_db;

-- -----------------------------------------------------------------------------
-- 0. Safe cleanup of existing sample data in reverse dependency order
-- (No foreign key check disabling needed: exact foreign key hierarchy respected)
-- -----------------------------------------------------------------------------
DELETE FROM elective_form_reviews;
DELETE FROM allocations;
DELETE FROM allocation_runs;
DELETE FROM student_preferences;
DELETE FROM preference_submissions;
DELETE FROM electives;
DELETE FROM allocation_forms;
DELETE FROM student_profile;
DELETE FROM students;
DELETE FROM users;

ALTER TABLE users AUTO_INCREMENT = 1;
ALTER TABLE students AUTO_INCREMENT = 1;
ALTER TABLE allocation_forms AUTO_INCREMENT = 1;
ALTER TABLE electives AUTO_INCREMENT = 1;
ALTER TABLE preference_submissions AUTO_INCREMENT = 1;
ALTER TABLE student_preferences AUTO_INCREMENT = 1;
ALTER TABLE allocation_runs AUTO_INCREMENT = 1;
ALTER TABLE allocations AUTO_INCREMENT = 1;
ALTER TABLE elective_form_reviews AUTO_INCREMENT = 1;

-- -----------------------------------------------------------------------------
-- 1. Users (Admin and Students)
-- Passwords:
--   admin_demo:      AdminPassword123
--   student_demo_01: StudentPassword123
--   student_demo_02: StudentPassword123
--   student_demo_03: StudentPassword123
-- BCrypt hashes verified against com.electra.util.BCrypt.checkpw()
-- -----------------------------------------------------------------------------
INSERT INTO users (user_id, username, password_hash, role, is_active)
VALUES
    (1, 'admin_demo',      '$2a$10$j5grDGngm3saytCgFm76Xe3geVjCpwXPpGVSCbdko3Xxc5Lala2J2', 'ADMIN',   TRUE),
    (2, 'student_demo_01', '$2a$10$5ANwo021HQu5./4eCK4Cjut3t9wPKsKVuVgiXTfrpccgT5KJoAH7e', 'STUDENT', TRUE),
    (3, 'student_demo_02', '$2a$10$RQphDbgVU2aKxBZoia93veZJqgydqsMq3MiFFlYHUJVOBYDO4bewq', 'STUDENT', TRUE),
    (4, 'student_demo_03', '$2a$10$OGxHMWmXzYrsjd8V5Uj.leyQNlcS7kIKWLWPQnjrbIwRNbfE2XxOC', 'STUDENT', TRUE);

-- -----------------------------------------------------------------------------
-- 2. Student Profiles (Core table `students`)
-- Supports login resolution via username, roll number, or email.
-- CGPAs:
--   student_demo_01: 9.20
--   student_demo_02: 8.70
--   student_demo_03: 8.10
-- -----------------------------------------------------------------------------
INSERT INTO students (student_id, user_id, roll_number, student_name, cgpa, email, batch_or_cycle)
VALUES
    (1, 2, 'CE055', 'Demo Student One',   9.20, 'student1@example.com', 'TE-CE-2026'),
    (2, 3, 'CE056', 'Demo Student Two',   8.70, 'student2@example.com', 'TE-CE-2026'),
    (3, 4, 'CE057', 'Demo Student Three', 8.10, 'student3@example.com', 'TE-CE-2026');

-- Synchronize supplementary student_profile table
INSERT INTO student_profile (student_id, full_name, email, roll_number, department, academic_year, cgpa)
VALUES
    (1, 'Demo Student One',   'student1@example.com', 'CE055', 'CMPN', 'Third Year', 9.20),
    (2, 'Demo Student Two',   'student2@example.com', 'CE056', 'CMPN', 'Third Year', 8.70),
    (3, 'Demo Student Three', 'student3@example.com', 'CE057', 'CMPN', 'Third Year', 8.10);


-- -----------------------------------------------------------------------------
-- 3. Allocation Forms
-- Four actual elective categories for AY 2026-27, Semester V.
--
-- Form 1: Programme Elective Courses - Open
-- Form 2: Multidisciplinary Minor-II - Closed
-- Form 3: Open Elective Courses-II - Closed
-- Form 4: Honours / Minors - Completed and Reviewed
--
-- Dates are NULL because the supplied dates are examination dates,
-- not confirmed preference-submission deadlines.
-- -----------------------------------------------------------------------------

INSERT INTO allocation_forms
    (form_id, form_name, category_name, batch_or_cycle,
     opening_date, submission_deadline, form_status,
     allocation_status, review_status, results_published)
VALUES
    (1, 'Programme Elective Courses (PE)', 'PE', 'TE-CE-2026',
     NULL, NULL, 'OPEN', 'NOT_STARTED', 'NOT_STARTED', FALSE),

    (2, 'Multidisciplinary Minor-II (MDM-II)', 'MDM', 'TE-CE-2026',
     NULL, NULL, 'CLOSED', 'NOT_STARTED', 'NOT_STARTED', FALSE),

    (3, 'Open Elective Courses-II (OEC-II)', 'OEC', 'TE-CE-2026',
     NULL, NULL, 'CLOSED', 'NOT_STARTED', 'NOT_STARTED', FALSE),

    (4, 'Honours / Minors', 'HONORS', 'TE-CE-2026',
     NULL, NULL, 'CLOSED', 'COMPLETED', 'REVIEWED', FALSE);


-- -----------------------------------------------------------------------------
-- 4. Electives
-- Total: 23 subjects across all four categories.
-- -----------------------------------------------------------------------------

-- -----------------------------------------------------------------------------
-- FORM 1: PROGRAMME ELECTIVE COURSES
-- 4 subjects
-- -----------------------------------------------------------------------------

INSERT INTO electives
    (elective_id, form_id, elective_code, elective_name, syllabus,
     faculty_name, total_seats, min_students, min_cgpa,
     is_active, enrolment_status)
VALUES
    (101, 1, 'CE5PE_CX1', 'Machine Learning',
     'Introduction to machine learning, supervised and unsupervised learning,
      regression, classification, clustering and model evaluation.',
     'Professor A', 2, 1, 7.00, TRUE, 'PENDING'),

    (102, 1, 'CE5PE_CX2', 'Ethical Hacking and Digital Forensics',
     'Ethical hacking methodologies, penetration testing, vulnerability
      assessment, cyber security and digital forensic investigation.',
     'Professor B', 2, 1, 7.00, TRUE, 'PENDING'),

    (103, 1, 'CE5PE_CX3', 'Computer Graphics',
     'Graphics primitives, 2D and 3D transformations, clipping,
      projections, rendering and computer animation.',
     'Professor C', 2, 1, NULL, TRUE, 'PENDING'),

    (104, 1, 'CE5PE_CX4', 'Internet Programming',
     'Web application development using HTML, CSS, JavaScript, jQuery,
      AJAX, XML, PHP and server-side programming.',
     'Professor D', 2, 1, NULL, TRUE, 'PENDING');


-- -----------------------------------------------------------------------------
-- FORM 2: MULTIDISCIPLINARY MINOR-II
-- 9 subjects
-- -----------------------------------------------------------------------------

INSERT INTO electives
    (elective_id, form_id, elective_code, elective_name, syllabus,
     faculty_name, total_seats, min_students, min_cgpa,
     is_active, enrolment_status)
VALUES
    (201, 2, 'IT5MM_CX1', 'Advanced Data Management Technologies',
     'Advanced database technologies, distributed databases,
      data storage, data integration and modern data management systems.',
     'Professor E', 2, 1, 7.00, TRUE, 'PENDING'),

    (202, 2, 'CE5MM_CX1', 'Database Management System',
     'Database architecture, relational data models, SQL,
      normalization, transaction management and database security.',
     'Professor F', 2, 1, NULL, TRUE, 'PENDING'),

    (203, 2, 'A15MM_CX1', 'Data Mining and Predictive Analytics',
     'Data preprocessing, association rule mining, classification,
      clustering and predictive modelling techniques.',
     'Professor G', 2, 1, 8.00, TRUE, 'PENDING'),

    (204, 2, 'EE5MM_CX1', 'Electric Vehicle Systems and Control',
     'Electric vehicle architecture, battery management,
      electric drives, power electronics and vehicle control systems.',
     'Professor H', 2, 1, NULL, TRUE, 'PENDING'),

    (205, 2, 'EC5MM_CX1', 'Data Management, Cloud Integration and Analytics',
     'Cloud-based data management, cloud integration,
      data pipelines, storage systems and cloud analytics.',
     'Professor I', 2, 1, 7.50, TRUE, 'PENDING'),

    (206, 2, 'ET5MM_CX1', 'Discrete Time Signal Processing',
     'Discrete-time signals and systems, Z-transforms, DFT,
      digital filters and signal processing applications.',
     'Professor J', 2, 1, NULL, TRUE, 'PENDING'),

    (207, 2, 'ET5MM_CX2', 'Microprocessor & Micro-controllers',
     'Microprocessor architecture, instruction sets, interfacing,
      microcontrollers and embedded system applications.',
     'Professor K', 2, 1, NULL, TRUE, 'PENDING'),

    (208, 2, 'ME5MM_CX1', 'CAD for Additive Manufacturing',
     'Computer-aided design, 3D modelling, product design,
      additive manufacturing and rapid prototyping.',
     'Professor L', 2, 1, NULL, TRUE, 'PENDING'),

    (209, 2, 'ME5MM_CX2', 'Mobile Robotics and Path Planning',
     'Mobile robot architecture, robot kinematics, localization,
      mapping, navigation and autonomous path planning.',
     'Professor M', 2, 1, 7.00, TRUE, 'PENDING');


-- -----------------------------------------------------------------------------
-- FORM 3: OPEN ELECTIVE COURSES-II
-- 8 subjects
-- -----------------------------------------------------------------------------

INSERT INTO electives
    (elective_id, form_id, elective_code, elective_name, syllabus,
     faculty_name, total_seats, min_students, min_cgpa,
     is_active, enrolment_status)
VALUES
    (301, 3, 'IL5OE_CX1', 'Project Management Practices',
     'Project planning, scheduling, resource management,
      risk management, project monitoring and execution.',
     'Professor N', 2, 1, NULL, TRUE, 'PENDING'),

    (302, 3, 'IL5OE_CX2', 'Digital Product Development',
     'Digital product lifecycle, ideation, prototyping,
      product strategy, agile development and innovation.',
     'Professor O', 2, 1, NULL, TRUE, 'PENDING'),

    (303, 3, 'IL5OE_CX3', 'Systems Reliability Engineering',
     'Reliability theory, failure analysis, fault-tree analysis,
      maintenance strategies and reliability modelling.',
     'Professor P', 2, 1, 7.00, TRUE, 'PENDING'),

    (304, 3, 'IL5OE_CX4', 'Decision Science & Business Optimization',
     'Decision-making models, operations research,
      linear programming, optimization and business analytics.',
     'Professor Q', 2, 1, NULL, TRUE, 'PENDING'),

    (305, 3, 'IL5OE_CX5', 'Smart Business Information Systems',
     'Business information systems, enterprise applications,
      digital transformation and intelligent business processes.',
     'Professor R', 2, 1, NULL, TRUE, 'PENDING'),

    (306, 3, 'IL5OE_CX6', 'Design of Experiments and Data Analytics',
     'Experimental design, statistical analysis,
      hypothesis testing, regression and data interpretation.',
     'Professor S', 2, 1, 7.50, TRUE, 'PENDING'),

    (307, 3, 'IL5OE_CX7', 'Energy Audit and Management',
     'Energy conservation, energy auditing, efficiency assessment,
      energy management and sustainability practices.',
     'Professor T', 2, 1, NULL, TRUE, 'PENDING'),

    (308, 3, 'IL5OE_CX8', 'Climate Change and Disaster Management',
     'Climate change, environmental impacts, disaster preparedness,
      risk assessment, mitigation and management strategies.',
     'Professor U', 2, 1, NULL, TRUE, 'PENDING');


-- -----------------------------------------------------------------------------
-- FORM 4: HONOURS / MINORS
-- 2 subjects
--
-- Demonstrates minimum-enrolment review:
-- HMMIDA5C1: 2 provisional students, minimum 1 -> APPROVED
-- HMVLSI5C1: 1 provisional student, minimum 2 -> BELOW MINIMUM
-- -----------------------------------------------------------------------------

INSERT INTO electives
    (elective_id, form_id, elective_code, elective_name, syllabus,
     faculty_name, total_seats, min_students, min_cgpa,
     is_active, enrolment_status)
VALUES
    (401, 4, 'HMMIDA5C1', 'Machine Intelligence',
     'Foundations of intelligent systems, artificial intelligence,
      machine learning, intelligent agents and advanced computational methods.',
     'Professor V', 2, 1, 8.00, TRUE, 'OK'),

    (402, 4, 'HMVLSI5C1', 'Hardware Modeling using Verilog',
     'Digital system design, Verilog HDL, RTL modelling,
      combinational and sequential circuits, simulation and verification.',
     'Professor W', 2, 2, 7.50, TRUE, 'BELOW_MINIMUM_ENROLMENT');


-- -----------------------------------------------------------------------------
-- 5. Preference Submissions
-- Form 1: One existing submission; remaining students can submit interactively.
-- Forms 2, 3 and 4: All three students have submitted preferences.
-- -----------------------------------------------------------------------------

INSERT INTO preference_submissions
    (submission_id, student_id, form_id, submitted_at, submission_status)
VALUES
    -- Programme Electives
    (1, 1, 1, '2026-10-20 10:00:00', 'SUBMITTED'),

    -- Multidisciplinary Minor-II
    (2, 1, 2, '2026-10-20 11:00:00', 'SUBMITTED'),
    (3, 2, 2, '2026-10-20 12:00:00', 'SUBMITTED'),
    (4, 3, 2, '2026-10-20 13:00:00', 'SUBMITTED'),

    -- Open Elective Courses-II
    (5, 1, 3, '2026-10-21 09:00:00', 'SUBMITTED'),
    (6, 2, 3, '2026-10-21 10:00:00', 'SUBMITTED'),
    (7, 3, 3, '2026-10-21 11:00:00', 'SUBMITTED'),

    -- Honours / Minors
    (8, 1, 4, '2026-10-22 09:30:00', 'SUBMITTED'),
    (9, 2, 4, '2026-10-22 10:15:00', 'SUBMITTED'),
    (10, 3, 4, '2026-10-22 11:45:00', 'SUBMITTED');


-- -----------------------------------------------------------------------------
-- Student Preferences
-- Students submit up to three ranked preferences per form.
-- -----------------------------------------------------------------------------

INSERT INTO student_preferences
    (preference_id, submission_id, form_id, elective_id, preference_rank)
VALUES
    -- FORM 1: Programme Electives
    -- Student 1: Machine Learning > Internet Programming > Computer Graphics
    (1, 1, 1, 101, 1),
    (2, 1, 1, 104, 2),
    (3, 1, 1, 103, 3),

    -- FORM 2: Multidisciplinary Minor-II
    -- Student 1
    (4, 2, 2, 201, 1),
    (5, 2, 2, 203, 2),
    (6, 2, 2, 209, 3),

    -- Student 2
    (7, 3, 2, 203, 1),
    (8, 3, 2, 201, 2),
    (9, 3, 2, 205, 3),

    -- Student 3
    (10, 4, 2, 209, 1),
    (11, 4, 2, 207, 2),
    (12, 4, 2, 206, 3),

    -- FORM 3: Open Elective Courses-II
    -- Student 1
    (13, 5, 3, 301, 1),
    (14, 5, 3, 302, 2),
    (15, 5, 3, 304, 3),

    -- Student 2
    (16, 6, 3, 302, 1),
    (17, 6, 3, 306, 2),
    (18, 6, 3, 305, 3),

    -- Student 3
    (19, 7, 3, 304, 1),
    (20, 7, 3, 308, 2),
    (21, 7, 3, 307, 3),

    -- FORM 4: Honours / Minors
    -- Student 1: Machine Intelligence
    (22, 8, 4, 401, 1),

    -- Student 2: Machine Intelligence > Hardware Modelling
    (23, 9, 4, 401, 1),
    (24, 9, 4, 402, 2),

    -- Student 3: Hardware Modelling > Machine Intelligence
    (25, 10, 4, 402, 1),
    (26, 10, 4, 401, 2);


-- -----------------------------------------------------------------------------
-- 6. Allocation Run & Results for Form 4 (Honours / Minors)
--
-- Initial allocation:
-- Student 1 (9.20) -> Machine Intelligence
-- Student 2 (8.70) -> Machine Intelligence
-- Student 3 (8.10) -> Hardware Modeling using Verilog
--
-- Following admin review:
-- Machine Intelligence: 2/1 minimum -> ALLOCATED
-- Hardware Modeling: 1/2 minimum -> NOT_ALLOTTED
-- -----------------------------------------------------------------------------

INSERT INTO allocation_runs
    (allocation_run_id, form_id, run_timestamp, run_status, run_type)
VALUES
    (1, 4, '2026-10-23 14:00:00', 'COMPLETED', 'INITIAL');

INSERT INTO allocations
    (allocation_id, allocation_run_id, form_id, student_id,
     elective_id, allocation_status, allocation_reason, created_at)
VALUES
    (1, 1, 4, 1, 401,
     'ALLOCATED',
     'Assigned by merit at preference rank 1',
     '2026-10-23 14:00:05'),

    (2, 1, 4, 2, 401,
     'ALLOCATED',
     'Assigned by merit at preference rank 1',
     '2026-10-23 14:00:05'),

    (3, 1, 4, 3, 402,
     'NOT_ALLOTTED',
     'Elective did not meet minimum enrolment after review',
     '2026-10-23 14:00:05');


-- -----------------------------------------------------------------------------
-- 7. Minimum Enrolment Reviews for Form 4
--
-- Machine Intelligence:
-- 2 students / minimum 1 -> REVIEWED
--
-- Hardware Modeling using Verilog:
-- 1 student / minimum 2 -> BELOW_MINIMUM_ENROLMENT
--
-- Results remain unpublished to allow testing the admin Publish Results UI.
-- -----------------------------------------------------------------------------

INSERT INTO elective_form_reviews
    (review_id, form_id, elective_id, review_status,
     review_notes, reviewed_by, reviewed_at)
VALUES
    (1, 4, 401, 'REVIEWED',
     'Initial check: enrolment OK (2/1). Admin: Approved for offering.',
     1, '2026-10-24 10:30:00'),

    (2, 4, 402, 'BELOW_MINIMUM_ENROLMENT',
     'Initial check: below minimum enrolment (1/2). Admin: Insufficient enrolment; course deferred.',
     1, '2026-10-24 10:35:00');

-- -----------------------------------------------------------------------------
-- END OF ELECTRA SAMPLE DEMONSTRATION DATA
-- -----------------------------------------------------------------------------
