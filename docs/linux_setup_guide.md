# PostgreSQL Linux Setup Guide (Ubuntu/Debian)

Follow these steps to set up your local database for the MESMER project.

## 1. Install PostgreSQL
```bash
sudo apt update
sudo apt install postgresql postgresql-contrib
```

## 2. Start and Enable Service
```bash
sudo systemctl start postgresql
sudo systemctl enable postgresql
```

## 3. Create a Database and User
We recommend creating a specific user for the project instead of using the `postgres` superuser.

```bash
# Switch to the postgres system user
sudo -i -u postgres

# Enter the psql console
psql

# Inside the psql console (PROMPT: postgres=#)
# 1. Create the database
CREATE DATABASE mesmer_db;

# 2. Create the user with a secure password
CREATE USER mesmer_user WITH ENCRYPTED PASSWORD 'your_secure_password';

# 3. Grant privileges
GRANT ALL PRIVILEGES ON DATABASE mesmer_db TO mesmer_user;

# 4. Exit
\q
exit
```

## 4. Test Connectivity
Try logging in with your new user:
```bash
psql -h localhost -U mesmer_user -d mesmer_db
```

## 5. Configuration (if needed)
If you get "Password authentication failed", ensure your `pg_hba.conf` allows `md5` or `scram-sha-256` for local connections.

File location usually: `/etc/postgresql/14/main/pg_hba.conf` (version may vary).
Change `peer` to `md5` for the `local` connection line if necessary.

---

## Useful Commands
- `\l` : List databases
- `\c dbname` : Connect to database
- `\dt` : List tables
- `\du` : List users
- `\q` : Quit
