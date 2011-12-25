# apt-get sarmalayıcı (dikkat!  güvensiz paketleri de kurar)
xaptget() {
	local command
	[ $# -gt 0 ] || return 0

	command="$1"
	shift

	sudo apt-get $command --option APT::Get::HideAutoRemove=1 \
		--quiet --yes --allow-unauthenticated \
		--force-yes --no-install-recommends --ignore-missing "$@"
}

# aptitude sarmalayıcı (dikkat!  güvensiz paketleri de kurar)
xaptitude() {
	# Paket kurulumu için bunu tercih ediyoruz çünkü aptitude eksik paketleri
	# atlayarak kurulum yapabiliyor, bk. http://bugs.debian.org/503215
	# Dikkat!  Ubuntu'da aptitude standart olarak kurulu gelmiyor.
	local command
	[ $# -gt 0 ] || return 0

	command="$1"
	shift

	sudo aptitude $command -f --quiet --assume-yes --allow-untrusted --without-recommends --safe-resolver "$@"
}

# Aptitude hata verdiğinde bir de APT ile dene
aptitude_or_aptget() {
	xaptitude "$@" || xaptget "$@"
}

# deb paketlerini hata halinde tekrar deneyerek kur
installdebs() {
	local message="$1"
	shift ||:

	say "${message}..."

	local try=2
	while [ $try -gt 0 ]; do
		err=0

		aptitude_or_aptget install "$@" || err=$?

		# hata yoksa çık
		[ $err -ne 0 ] || break

		cry "Bazı Deb paketlerinin kurulumunda hata oluştu. " \
		    "Tekrar denenerek kuruluma devam edilecek..."
		try=$(($try - 1))
	done
}

# adresi verilen bir deb paketini indir ve kur
debinstallfromurl() {
	local url deb

	url="$1"

	deb=$(mktemp) || die "Geçici dosya oluşturulamadı"
	if wget "$url" -O"$deb" 2>/dev/null; then
		if [ ! -f "$deb" ]; then
			echo >&2 "$url adresinden bir dosya indirilemedi."
			return 1
		fi
		if [ -n "$(which file 2>/dev/null ||:)" ]; then
			case "$(file --mime-type $deb 2>/dev/null ||:)" in
			*:\ application/octet-stream)
				;;
			*)
				echo >&2 "$url adresinden indirilen dosya bir ikili paket değil."
				return 1
				;;
			esac
		fi

		sudo dpkg -i "$deb" && return 0

		echo >&2 "$url kurulurken hatayla karşılaşıldı; düzeltilecek."
		sudo apt-get -f install ||:
	fi

	return 1
}

# debian paket deposu ekle
adddebrepository() {
	local name repository distribution components keyurl

	[ $# -ge 4 ] || bug "adddebrepository: argüman sayısı eksik"

	name="$1"
	repository="$2"
	distribution="$3"
	components="$4"
	keyurl="$5"

	case "$distribution" in
	""|-) distribution=$(lsb_release -s -c 2>/dev/null ||:) ;;
	esac
	case "$components" in
	""|-) components='main' ;;
	esac
	case "$repository" in
	http:|ftp:) ;;
	*) repository="http://${repository}" ;;
	esac
	case "$keyurl" in
	http:|ftp:) ;;
	"") ;;
	*) keyurl="http://${keyurl}" ;;
	esac

	list=/etc/apt/sources.list.d/$name.list
	if [ ! -f "$list" ]; then
		sudoattempt
		sudo sh -c "cat >$list <<EOF
deb $repository $distribution $components
EOF
"
		if [ -n "$keyurl" ]; then
			wget "$keyurl" -qO- | sudo apt-key add -
		fi
	fi
}

# wajig sarmalayıcı
xwajig() {
	local command
	[ $# -gt 1 ] || return 0

	command="$1"
	shift

	wajig -n -q -y $command "$@"
}

# gem sarmalayıcı (öntanımlı)
xgem() {
	local command
	[ $# -gt 1 ] || return 0

	command="$1"
	shift

	sudo gem $command --quiet --force --no-ri --no-rdoc "$@"
}

# gem sarmalayıcı (1.9 serisi ile)
xgem191() {
	local command
	[ $# -gt 1 ] || return 0

	command="$1"
	shift

	sudo gem1.9.1 $command --quiet --force --no-ri --no-rdoc "$@"
}

# gem paketlerini hata halinde tekrar deneyerek kur
installgems() {
	local message="$1"
	shift ||:

	say "${message}..."

	local try=2
	while [ $try -gt 0 ]; do
		err=0

		xgem191 install "$@" || err=$?

		# hata yoksa çık
		[ $err -ne 0 ] || break

		cry "Bazı Gem paketlerinin kurulumunda hata oluştu. " \
		    "Tekrar denenerek kuruluma devam edilecek..."
		try=$(($try - 1))
	done
}
