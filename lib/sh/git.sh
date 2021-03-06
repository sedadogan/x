# tepe dizini göster
git_top_level() {
	git rev-parse --show-toplevel
}

# hangi daldayız?
git_current_branch() {
	local br

	br=$(git symbolic-ref -q HEAD)
	br=${br##refs/heads/}
	br=${br:-HEAD}

	echo "$br"
}

# dal mevcut mu?
git_branch_exist() {
	git show-ref -q "$1"
}

# depo temiz durumda mı?
git_is_clean() {
	{
		git diff-index HEAD --exit-code --quiet &&
		git diff-index --cached HEAD --exit-code --quiet
	} >/dev/null 2>&1 || return 1
	return 0
}

# geçici olarak tüm değişiklikleri kaydet
git_stash_push() {
	unset GIT_STASH_PUSHED
	if ! git_is_clean; then
		GIT_STASH_PUSHED=yes
		git stash save -q
	fi
}

# değişiklikleri geri yükle
git_stash_pop() {
	if [ -n "$GIT_STASH_PUSHED" ]; then
		git stash pop -q
	fi
}

# verilen dala geçerek bir şey yap ve geri dön
git_on_branch() {
	local br callback cur

	br="$1"
	callback="$2"
	shift 2

	if git_branch_exist "$br"; then
		cur=$(git_current_branch)
		git_stash_push
		git checkout "$br"
		$callback "$@"
		git checkout "$cur"
		git_stash_pop
	else
		echo >&2 "$br dalı yok veya sorunlu"
		return 1
	fi
}

# verilen dizin bir git çalışma kopyası mı?
git_iswc() {
	case "$(
		LC_ALL=C GIT_DIR="$1/.git" /usr/bin/git rev-parse --is-inside-work-tree 2>/dev/null ||:
	)" in
	true)  return 0 ;;
	false) return 1 ;;
	*)     return 2 ;;
	esac
}

# deponun durumunu izle ve değişmişse raporla
unset GIT_HEAD_FOLLOWED_ GIT_DIR_FOLLOWED_
git_head_follow() {
	local dir

	dir="${1:-.}"
	case "$dir" in
	*/.git) ;;
	*) dir="${dir}/.git" ;;
	esac

	GIT_DIR_FOLLOWED_="$dir"
	GIT_HEAD_FOLLOWED_=$(
		git --git-dir="$GIT_DIR_FOLLOWED_" rev-parse HEAD 2>/dev/null ||:
	)
}
git_head_unfollow() {
	local repo
	local ret=0

	if isnull GIT_HEAD_FOLLOWED_ || isnull GIT_DIR_FOLLOWED_; then
		bug "İzlenen bir depo yok; önce git_head_follow çağrılmalı"
	fi

	case $(
		git --git-dir="$GIT_DIR_FOLLOWED_" rev-parse HEAD 2>/dev/null ||:
	) in
	"$GIT_HEAD_FOLLOWED_")
		ret=1
		;;
	esac

	unset GIT_HEAD_FOLLOWED_ GIT_DIR_FOLLOWED_

	return $ret
}

# depoyu güncelle ve değişiklik varsa (doğru dönerek) bildir
git_pull_success_on_update() {
	local prev

	prev=$(git rev-parse HEAD 2>/dev/null ||:)
	GIT_MERGE_AUTOEDIT=no git pull "$@" || return 0
	case "$(git rev-parse HEAD 2>/dev/null ||:)" in
	$prev)
		return 1
		;;
	esac
}

# GitHub

# github ssh ile erişilebilir durumda mı?
gh_writable() {
	# SSH kontrolünü sadece bir kere yapmak için sonucu sakla
	if [ -z "${IS_SSHABLE+X}" ]; then
		# SSH agent aktif değilse basitçe gerek şartları kontrol edeceğiz.
		if [ -z "$(ssh-add -l 2>/dev/null ||:)" ]; then
			# ~/.ssh dizini yok veya boşsa SSH kullanılamaz.
			if ! [ -d ~/.ssh ] || [ -r ~/.ssh/id_rsa ] || [ -r ~/.ssh/id_dsa ]; then
				IS_SSHABLE=no
			fi
			cry "SSH yetkilendirme ajanı aktif değil."
			cry "Yeni bir yetkilendirme ajanı oluşturulacak;" \
                            "lütfen öntanımlı SSH anahtarına ait parolayı girin."
			eval $(ssh-agent)
			ssh-add
		fi
		if [ -z "${IS_SSHABLE+X}" ]; then
			# Aksi halde daha yorucu ve çirkin bir kontrol gerekiyor.
			cry "SSH erişimi kontrol ediliyor (SSH parolası istenebilir)..."
			if ssh -T -o StrictHostKeyChecking=no git@github.com 2>&1 |
				egrep -q 'successfully authenticated'; then
				IS_SSHABLE=yes
			else
				IS_SSHABLE=no
			fi
		fi
	fi

	case "$IS_SSHABLE" in yes) return 0 ;; no) return 1 ;; esac
}
