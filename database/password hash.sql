USE electra_db;

START TRANSACTION;

UPDATE users
SET password_hash = '$2a$10$j5grDGngm3saytCgFm76Xe3geVjCpwXPpGVSCbdko3Xxc5Lala2J2'
WHERE user_id = 1 AND username = 'admin_demo'
  AND role = 'ADMIN' AND is_active = 1
  AND password_hash = 'TEMPORARY_HASH_REPLACE_LATER';

UPDATE users
SET password_hash = '$2a$10$5ANwo021HQu5./4eCK4Cjut3t9wPKsKVuVgiXTfrpccgT5KJoAH7e'
WHERE user_id = 2 AND username = 'student_demo_01'
  AND role = 'STUDENT' AND is_active = 1
  AND password_hash = 'TEMPORARY_HASH_REPLACE_LATER';

UPDATE users
SET password_hash = '$2a$10$RQphDbgVU2aKxBZoia93veZJqgydqsMq3MiFFlYHUJVOBYDO4bewq'
WHERE user_id = 3 AND username = 'student_demo_02'
  AND role = 'STUDENT' AND is_active = 1
  AND password_hash = 'TEMPORARY_HASH_REPLACE_LATER';

UPDATE users
SET password_hash = '$2a$10$OGxHMWmXzYrsjd8V5Uj.leyQNlcS7kIKWLWPQnjrbIwRNbfE2XxOC'
WHERE user_id = 4 AND username = 'student_demo_03'
  AND role = 'STUDENT' AND is_active = 1
  AND password_hash = 'TEMPORARY_HASH_REPLACE_LATER';

SELECT user_id, username, role,
       LEFT(password_hash, 7) AS hash_prefix,
       LENGTH(password_hash) AS hash_length
FROM users
WHERE user_id BETWEEN 1 AND 4
ORDER BY user_id;


commit;