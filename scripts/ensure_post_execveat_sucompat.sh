#!/bin/bash
# SUSFS gki patch calls ksu_handle_post_execveat_sucompat from fs/exec.c.
# SukiSU builtin already has the pre-exec hook and dropped this symbol.
set -euo pipefail

ROOT="${1:-.}"
FILE="$ROOT/kernel/feature/sucompat.c"

if [[ ! -f "$FILE" ]]; then
  echo "找不到 $FILE"
  exit 1
fi

if grep -q 'ksu_handle_post_execveat_sucompat' "$FILE"; then
  echo "ksu_handle_post_execveat_sucompat 已存在，跳过"
  exit 0
fi

cat >> "$FILE" << 'EOF'

#ifdef CONFIG_KSU_SUSFS
int ksu_handle_post_execveat_sucompat(int *fd, struct filename **filename_ptr,
		void *argv, void *envp, int *flags, int *retval)
{
	(void)fd;
	(void)filename_ptr;
	(void)argv;
	(void)envp;
	(void)flags;
	(void)retval;
	return 0;
}
#endif
EOF

echo "已补上 ksu_handle_post_execveat_sucompat"
