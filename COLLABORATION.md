# Collaborating with GitHub

This project uses **Git** and **GitHub** so you and your friend can share code and stay in sync.

---

## First-time setup (you)

1. **Create the GitHub repository** (one-time)
   - Open: **https://github.com/new?name=doga_mustafa_app_1**
   - Leave it **empty** (no README, no .gitignore). Choose **Private** if you want.
   - Click **Create repository**.

2. **Push your code** (remote is already set to `dogamustafaapp-arch/doga_mustafa_app_1`):
   ```bash
   git push -u origin main
   ```
   - If GitHub asks for login, use username `dogamustafaapp-arch` and a **Personal Access Token** (not your password):  
     GitHub → Settings → Developer settings → Personal access tokens → Generate new token (with `repo` scope).

---

## First-time setup (your friend)

**Do not create a new project.** Clone the repo so you get the same code and stay in sync.

1. **You add him as collaborator** (one-time)  
   Repo on GitHub → **Settings** → **Collaborators** → **Add people** → enter his GitHub username → he accepts the invite.

2. **He clones the repo**
   - Open **Terminal** (or Cursor’s terminal). Pick a folder (e.g. Desktop or a projects folder).
   - Run:
   ```bash
   git clone https://github.com/dogamustafaapp-arch/doga_mustafa_app_1.git
   cd doga_mustafa_app_1
   ```

3. **Open in Cursor**  
   **File → Open Folder** → choose the `doga_mustafa_app_1` folder he just cloned. That’s his project.

4. **Install Flutter dependencies** (in Cursor terminal or any terminal inside the project):
   ```bash
   flutter pub get
   ```

He’s ready. He uses **Daily workflow** below to pull your changes and push his.

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
