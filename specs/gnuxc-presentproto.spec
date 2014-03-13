%?gnuxc_package_header
%undefine debug_package

Name:           gnuxc-presentproto
Version:        1.0
Release:        1%{?dist}
Summary:        Cross-compiled version of %{gnuxc_name} for the GNU system

License:        MIT
Group:          Development/System
URL:            http://www.x.org/
Source0:        http://xorg.freedesktop.org/releases/individual/proto/%{gnuxc_name}-%{version}.tar.bz2

Requires:       gnuxc-xextproto

BuildArch:      noarch

%description
%{summary}.


%prep
%setup -q -n %{gnuxc_name}-%{version}

%build
%gnuxc_configure \
    --enable-strict-compilation
%gnuxc_make %{?_smp_mflags} all

%install
%gnuxc_make_install

# Skip the documentation.
rm -rf %{buildroot}%{gnuxc_docdir}


%files
%{gnuxc_includedir}/X11/extensions/presentproto.h
%{gnuxc_includedir}/X11/extensions/presenttokens.h
%{gnuxc_libdir}/pkgconfig/presentproto.pc
%doc ChangeLog presentproto.txt


%changelog