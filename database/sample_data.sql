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
    (1, 2, 'CE055', 'Demo Student One',   9.20, 'student1@example.com', 'TY-CE-2026'),
    (2, 3, 'CE056', 'Demo Student Two',   8.70, 'student2@example.com', 'TY-CE-2026'),
    (3, 4, 'CE057', 'Demo Student Three', 8.10, 'student3@example.com', 'TY-CE-2026');

-- Synchronize supplementary student_profile table
INSERT INTO student_profile (student_id, full_name, email, roll_number, department, academic_year, cgpa)
VALUES
    (1, 'Demo Student One',   'student1@example.com', 'CE055', 'CMPN', 'Third Year', 9.20),
    (2, 'Demo Student Two',   'student2@example.com', 'CE056', 'CMPN', 'Third Year', 8.70),
    (3, 'Demo Student Three', 'student3@example.com', 'CE057', 'CMPN', 'Third Year', 8.10);

-- -----------------------------------------------------------------------------
-- 3. Allocation Forms (Independent test scenarios)
-- Form 1: Open Form for interactive student preference submission & admin editing
--         Dates set to NULL so the form is permanently open and unaffected by clock progression.
-- Form 2: Closed Form with submissions ready for running initial allocation & review
-- Form 3: Completed & Reviewed Form (Results Unpublished) for testing final publish & reports
-- -----------------------------------------------------------------------------
INSERT INTO allocation_forms
    (form_id, form_name, category_name, batch_or_cycle, opening_date, submission_deadline,
     form_status, allocation_status, review_status, results_published)
VALUES
    (1, 'Institute Open Electives (OE-1)', 'OEC', 'TY-CE-2026',
        NULL, NULL,
        'OPEN', 'NOT_STARTED', 'NOT_STARTED', FALSE),

    (2, 'Department Electives (PE-1)', 'DEPARTMENTAL', 'TY-CE-2026',
        '2026-01-01 09:00:00', '2026-01-15 18:00:00',
        'CLOSED', 'NOT_STARTED', 'NOT_STARTED', FALSE),

    (3, 'Honors Electives (HON-1)', 'HONORS', 'TY-CE-2026',
        '2026-01-01 09:00:00', '2026-01-20 18:00:00',
        'CLOSED', 'COMPLETED', 'REVIEWED', FALSE);

-- -----------------------------------------------------------------------------
-- 4. Electives
-- Form 1 electives (form_id = 1)
-- -----------------------------------------------------------------------------
INSERT INTO electives
    (elective_id, form_id, elective_code, elective_name, syllabus, faculty_name,
     total_seats, min_students, min_cgpa, is_active, enrolment_status)
VALUES
    (101, 1, 'OEC101', 'Introduction to Economics',
     'Fundamentals of micro and macroeconomics, market structures, and public finance.',
     'Dr. Robert Vance', 2, 1, NULL, TRUE, 'PENDING'),

    (102, 1, 'OEC102', 'Design Thinking & Innovation',
     'Human-centered design principles, prototyping, and agile problem solving.',
     'Prof. Sarah Jenkins', 2, 2, 7.00, TRUE, 'PENDING'),

    (103, 1, 'OEC103', 'Business Analytics',
     'Data-driven decision making, regression models, and predictive analytics in business.',
     'Dr. Alan Turing', 1, 1, 8.00, TRUE, 'PENDING');

-- Form 2 electives (form_id = 2)
INSERT INTO electives
    (elective_id, form_id, elective_code, elective_name, syllabus, faculty_name,
     total_seats, min_students, min_cgpa, is_active, enrolment_status)
VALUES
    (201, 2, 'DE201', 'Cloud Computing Architecture',
     'Distributed systems, AWS/GCP patterns, virtualization, and serverless compute.',
     'Prof. Michael Scott', 2, 1, 7.00, TRUE, 'PENDING'),

    (202, 2, 'DE202', 'Cyber Security & Forensics',
     'Network defence, cryptography, penetration testing, and digital forensics.',
     'Dr. Dwight Schrute', 2, 2, NULL, TRUE, 'PENDING'),

    (203, 2, 'DE203', 'Natural Language Processing',
     'Text embeddings, language modelling, transformers, and sequence-to-sequence networks.',
     'Dr. Pam Beesly', 1, 1, 8.50, TRUE, 'PENDING');

-- Form 3 electives (form_id = 3)
-- Demonstrates minimum enrolment rules:
--   HON301 has 2 provisional students (min_students = 1) -> OK
--   HON302 has 1 provisional student (min_students = 2)  -> BELOW_MINIMUM_ENROLMENT
--   HON303 has 0 provisional students (min_students = 1) -> BELOW_MINIMUM_ENROLMENT
INSERT INTO electives
    (elective_id, form_id, elective_code, elective_name, syllabus, faculty_name,
     total_seats, min_students, min_cgpa, is_active, enrolment_status)
VALUES
    (301, 3, 'HON301', 'Quantum Computing Systems',
     'Qubits, quantum gates, quantum algorithms (Shor, Grover), and quantum hardware models.',
     'Dr. Richard Feynman', 2, 1, 8.00, TRUE, 'OK'),

    (302, 3, 'HON302', 'Autonomous Robotics',
     'ROS, SLAM, kinematics, path planning, and computer vision for mobile robots.',
     'Prof. Rodney Brooks', 2, 2, 7.50, TRUE, 'BELOW_MINIMUM_ENROLMENT'),

    (303, 3, 'HON303', 'Deep Reinforcement Learning',
     'Markov decision processes, policy gradients, Q-learning, and multi-agent systems.',
     'Dr. Sutton Barto', 2, 1, 8.50, TRUE, 'BELOW_MINIMUM_ENROLMENT');

-- -----------------------------------------------------------------------------
-- 5. Preference Submissions & Student Preferences
-- Form 1: student_demo_01 submitted preferences; student_demo_02 and student_demo_03 can submit interactively
-- -----------------------------------------------------------------------------
INSERT INTO preference_submissions (submission_id, student_id, form_id, submitted_at, submission_status)
VALUES
    (1, 1, 1, '2026-02-01 10:00:00', 'SUBMITTED');

INSERT INTO student_preferences (preference_id, submission_id, form_id, elective_id, preference_rank)
VALUES
    (1, 1, 1, 103, 1),
    (2, 1, 1, 101, 2),
    (3, 1, 1, 102, 3);

-- Form 2: Submissions for students 1, 2, and 3 (Closed form ready for running allocation)
INSERT INTO preference_submissions (submission_id, student_id, form_id, submitted_at, submission_status)
VALUES
    (2, 1, 2, '2026-01-10 11:00:00', 'SUBMITTED'),
    (3, 2, 2, '2026-01-10 12:00:00', 'SUBMITTED'),
    (4, 3, 2, '2026-01-10 13:00:00', 'SUBMITTED');

INSERT INTO student_preferences (preference_id, submission_id, form_id, elective_id, preference_rank)
VALUES
    -- Student 1 (CGPA 9.20): 203 (rank 1), 201 (rank 2), 202 (rank 3)
    (4, 2, 2, 203, 1),
    (5, 2, 2, 201, 2),
    (6, 2, 2, 202, 3),

    -- Student 2 (CGPA 8.70): 203 (rank 1), 201 (rank 2), 202 (rank 3)
    (7, 3, 2, 203, 1),
    (8, 3, 2, 201, 2),
    (9, 3, 2, 202, 3),

    -- Student 3 (CGPA 8.10): 201 (rank 1), 202 (rank 2)
    (10, 4, 2, 201, 1),
    (11, 4, 2, 202, 2);

-- Form 3: Submissions for students 1, 2, and 3
INSERT INTO preference_submissions (submission_id, student_id, form_id, submitted_at, submission_status)
VALUES
    (5, 1, 3, '2026-01-15 09:30:00', 'SUBMITTED'),
    (6, 2, 3, '2026-01-15 10:15:00', 'SUBMITTED'),
    (7, 3, 3, '2026-01-15 11:45:00', 'SUBMITTED');

INSERT INTO student_preferences (preference_id, submission_id, form_id, elective_id, preference_rank)
VALUES
    -- Student 1 (CGPA 9.20): 301 (rank 1), 302 (rank 2)
    (12, 5, 3, 301, 1),
    (13, 5, 3, 302, 2),

    -- Student 2 (CGPA 8.70): 301 (rank 1), 302 (rank 2)
    (14, 6, 3, 301, 1),
    (15, 6, 3, 302, 2),

    -- Student 3 (CGPA 8.10): 302 (rank 1), 303 (rank 2 - fails min_cgpa 8.50)
    (16, 7, 3, 302, 1),
    (17, 7, 3, 303, 2);

-- -----------------------------------------------------------------------------
-- 6. Allocation Runs & Results for Form 3
-- Allocation run executed and completed:
--   Allocations have been finalized following admin review (AllocationService.finalizeReviewedAllocation()):
--   Student 1 (9.20) -> HON301 (Rank 1, ALLOCATED: elective met enrolment >= 1)
--   Student 2 (8.70) -> HON301 (Rank 1, ALLOCATED: elective met enrolment >= 1)
--   Student 3 (8.10) -> HON302 (Rank 1, NOT_ALLOTTED: elective did not meet minimum enrolment after review)
-- -----------------------------------------------------------------------------
INSERT INTO allocation_runs (allocation_run_id, form_id, run_timestamp, run_status, run_type)
VALUES
    (1, 3, '2026-01-21 14:00:00', 'COMPLETED', 'INITIAL');

INSERT INTO allocations
    (allocation_id, allocation_run_id, form_id, student_id, elective_id, allocation_status, allocation_reason, created_at)
VALUES
    (1, 1, 3, 1, 301, 'ALLOCATED', 'Assigned by merit at preference rank 1', '2026-01-21 14:00:05'),
    (2, 1, 3, 2, 301, 'ALLOCATED', 'Assigned by merit at preference rank 1', '2026-01-21 14:00:05'),
    (3, 1, 3, 3, 302, 'NOT_ALLOTTED', 'Elective did not meet minimum enrolment after review', '2026-01-21 14:00:05');

-- -----------------------------------------------------------------------------
-- 7. Minimum Enrolment Reviews for Form 3
-- Admin reviewed all 3 active electives:
--   HON301 (2 enrolled >= 1 min): REVIEWED
--   HON302 (1 enrolled < 2 min):  BELOW_MINIMUM_ENROLMENT with admin review notes
--   HON303 (0 enrolled < 1 min):  BELOW_MINIMUM_ENROLMENT with admin review notes
-- Reviewed by admin_demo (user_id = 1).
-- Results remain unpublished (results_published = FALSE) so admin can inspect review
-- and test the "Publish Results" button in the UI.
-- -----------------------------------------------------------------------------
INSERT INTO elective_form_reviews
    (review_id, form_id, elective_id, review_status, review_notes, reviewed_by, reviewed_at)
VALUES
    (1, 3, 301, 'REVIEWED',
     'Initial check: enrolment OK (2/1). Admin: Approved for offering.',
     1, '2026-01-22 10:30:00'),

    (2, 3, 302, 'BELOW_MINIMUM_ENROLMENT',
     'Initial check: below minimum enrolment (1/2). Admin: Cannot run with single student; deferred.',
     1, '2026-01-22 10:35:00'),

    (3, 3, 303, 'BELOW_MINIMUM_ENROLMENT',
     'Initial check: zero enrolment (0/1). Admin: Dropped due to lack of enrolment.',
     1, '2026-01-22 10:36:00');
