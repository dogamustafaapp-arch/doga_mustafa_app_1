# Collaborating with GitHub

This project uses **Git** and **GitHub** so you and your friend can share code and stay in sync.

---

## First-time setup (you)

1. **Create a GitHub repository**
   - Go to [github.com](https://github.com) and sign in (or create an account).
   - Click **New repository** (green button).
   - Name it (e.g. `doga_mustafa_app_1`), leave it **empty** (no README, no .gitignore).
   - Choose **Private** if you don’t want it public.
   - Click **Create repository**.

2. **Connect this project and push**
   - In the project folder, run (replace `YOUR_USERNAME` and `REPO_NAME` with your GitHub repo):

   ```bash
   git remote add origin https://github.com/YOUR_USERNAME/REPO_NAME.git
   git add .
   git commit -m "Initial commit"
   git push -u origin main
   ```

   - If GitHub asks for login, use your username and a **Personal Access Token** (not your password):  
     GitHub → Settings → Developer settings → Personal access tokens → Generate new token.

---

## First-time setup (your friend)

1. **Clone the repo**
   - Install [Git](https://git-scm.com/) if needed.
   - Run (replace with your repo URL):

   ```bash
   git clone https://github.com/YOUR_USERNAME/REPO_NAME.git
   cd REPO_NAME
   ```

2. **Install Flutter dependencies**
   ```bash
   flutter pub get
   ```

---

## Daily workflow (both of you)

- **Before you start working** (get your friend’s latest changes):
  ```bash
  git pull
  ```

- **After you finish a change** (share your code):
  ```bash
  git add .
  git commit -m "Short description of what you did"
  git push
  ```

- **Your friend gets your updates** by running:
  ```bash
  git pull
  ```

If you both edit the same file, Git may ask you to resolve **merge conflicts**. Open the file, fix the conflict markers (`<<<<<<<`, `=======`, `>>>>>>>`), then:

```bash
git add .
git commit -m "Resolve merge conflict"
git push
```

---

## Quick reference

| You want to…        | Command        |
|---------------------|----------------|
| Get latest code     | `git pull`     |
| Save your changes   | `git add .` then `git commit -m "message"` |
| Share your changes  | `git push`     |
| See status          | `git status`   |
