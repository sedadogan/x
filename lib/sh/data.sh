# URL'deki veriyi standart çıktıda görüntüle
#
# Kullanım: <URL>
get() {
	curl -s -k "$@"
}


# Standart girdideki JSON verisinden değer oku
#
# Kullanım: [<anahtar...>]
json_get() {
	perl -e '
		use strict;
		use warnings;
		use feature qw(say);
		use open qw(:std :utf8);
		use Encode qw(encode_utf8);

		use JSON qw(decode_json);

		my $json = do { local $/; <STDIN> };
		die "Empty json content!\n" unless defined $json;
		$json = encode_utf8($json);

		my ($decoded_json, @stack) = (decode_json($json), ());
		while (@ARGV) {
			push @stack, (my $key = shift @ARGV);
			unless (exists $decoded_json->{$key}) {
				$key = join ".", @stack;
				die "no key: $key\n";
			}
			$decoded_json = $decoded_json->{$key};
		}

		if ((my $ref = ref $decoded_json) eq "") {
			say $decoded_json;
		}
		elsif ($ref =~ m/[Bb]oolean/) {
			say $decoded_json ? "1" : "0";
		}
		else {
			use Data::Dumper;
			$Data::Dumper::Terse = 1;
			$Data::Dumper::Deepcopy = 1;
			say Dumper $decoded_json;
		}
	' "$@"
}

# REPLY değişkenindeki JSON verisinden oku
#
# Kullanım: [<anahtar>...]
json_get_in_reply() {
	if [ -n "$REPLY" ]; then
		json_get "$@" <<<"$REPLY" 2>/dev/null
	fi
}

# Github API verisini REPLY'a oku
#
# Kullanım: <API yolu>
#
# API yolunda kullanılan '%s' dizgileri Github kullanıcı adıyle otomatik olarak
# değiştirilir.
#
# Örnekler:
#
# 	gh_api_fetch repos/%s/%s.github.com
# 	gh_api_fetch repos/%s/foo
#	gh_api_fetch repos/ecylmz/foo
#
gh_api_fetch() {
	local user path command

	: ${user:=$GITHUB_USER}
	: ${user:=$USER}

	unset REPLY

	path=$1
	path=$(printf "$path" "$user")
	path=${path#/}
	shift

	REPLY=$(get "https://api.github.com/${path}" "$@" 2>/dev/null) || return
}

# Github API verisinden verilen değerleri oku
#
# Kullanım: <API yolu> [<anahtar>...]
#
# API yolunda kullanılan '%s' dizgileri Github kullanıcı adıyle otomatik olarak
# değiştirilir.
#
# Örnekler:
#
# 	gh_api repos/%s/%s.github.com
# 	gh_api repos/%s/foo source owner gravatar_id
#	gh_api repos/ecylmz/foo
#
gh_api() {
	path=$1
	shift

	gh_api_fetch "$path" && json_get_in_reply "$@"
}
