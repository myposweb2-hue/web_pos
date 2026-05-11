# TODO - fix .env nano permission issue

## Completed
- [x] Inspected `.env` permissions (confirmed you have FullControl on the file).
- [x] Removed stale nano backup file `.env~` so nano can recreate it.

## Next steps (for deployment)
- [ ] Edit `.env` using VSCode/Notepad (avoid nano on this Windows environment).
- [ ] Save `.env` successfully.
- [ ] Start production stack with Docker on the target (Linux droplet), not from this Windows environment.
- [ ] Verify by checking Flask and Postgres container logs.

