# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DESCRIPTION="Happ — user-friendly GUI client for xray-core with TUN/VPN support"
HOMEPAGE="https://happ.info/ https://github.com/Happ-proxy/happ-desktop"
SRC_URI="https://github.com/Happ-proxy/happ-desktop/releases/latest/download/Happ.linux.x64.deb -> ${P}.deb"

# Happ распространяется как проприетарное ПО. Значение 'custom' указывает Portage
# искать файл с описанием лицензии в каталоге licenses/ вашего оверлея.
LICENSE="custom"
SLOT="0"
KEYWORDS="~amd64"

# Зависимости, взятые из вывода dpkg-deb. Для OpenSSL использован подслот :0/3.
RDEPEND="
    >=sys-libs/glibc-2.34
    dev-libs/openssl:0/3
"

# Пакет предоставляется как готовый бинарник.
RESTRICT="mirror bindist strip"
QA_PREBUILT="*"

BDEPEND="app-arch/dpkg"

src_unpack() {
    dpkg-deb -x "${DISTDIR}/${P}.deb" "${S}"
}

src_install() {
    # 1. Копируем все файлы из .deb-пакета в образ установки.
    #    Структура /opt/happ/... будет сохранена.
    cp -pPR "${S}"/* "${ED}"/

    # 2. Создаём каталоги для демона happd с правильными правами.
    #    Это исправляет ошибку "unable to open database file" из лога.
    #    Демон должен иметь возможность писать в /var/lib/happd.
    diropts -m 0700 -o root -g root
    dodir /var/lib/happd
    dodir /var/log

    # 3. Устанавливаем init-скрипт OpenRC для управления демоном happd.
    #    newinitd автоматически поместит файл в /etc/init.d/.
    newinitd "${FILESDIR}/happd.initd" happd

    # 4. (Опционально) Создаём символическую ссылку для удобного запуска GUI.
    #    Приложение находится в /opt/happ/bin/Happ, судя по логу.
    # dosym "/opt/happ/bin/Happ" "/usr/bin/happ"
}
