%?gnuxc_package_header

Name:           gnuxc-libgcrypt
Version:        1.5.3
Release:        1%{?dist}
Summary:        Cross-compiled version of %{gnuxc_name} for the GNU system

License:        LGPLv2+
Group:          System Environment/Libraries
URL:            http://www.gnu.org/software/libgcrypt/
Source0:        ftp://ftp.gnupg.org/gcrypt/libgcrypt/%{gnuxc_name}-%{version}.tar.bz2

BuildRequires:  gnuxc-libgpg-error-devel

BuildArch:      noarch

%description
%{summary}.

%package devel
Summary:        Development files for %{name}
Group:          Development/Libraries
Requires:       %{name} = %{version}-%{release}
Requires:       gnuxc-libgpg-error-devel

%description devel
The %{name}-devel package contains libraries and header files for developing
applications that use %{gnuxc_name} on GNU systems.

%package static
Summary:        Static libraries of %{name}
Group:          Development/Libraries
Requires:       %{name}-devel = %{version}-%{release}

%description static
The %{name}-static package contains the %{gnuxc_name} static libraries for
-static linking on GNU systems.  You don't need these, unless you link
statically, which is highly discouraged.


%prep
%setup -q -n %{gnuxc_name}-%{version}

%build
%gnuxc_configure \
    --bindir=%{gnuxc_root}/bin \
    \
    --enable-hmac-binary-check \
    --enable-m-guard \
    --enable-static \
    \
    --disable-asm
%gnuxc_make %{?_smp_mflags} all

%install
%gnuxc_make_install

# Provide a cross-tools version of the config script.
install -dm 755 %{buildroot}%{_bindir}
ln %{buildroot}%{gnuxc_root}/bin/libgcrypt-config \
    %{buildroot}%{_bindir}/%{gnuxc_target}-libgcrypt-config

# There is no need to install binary programs in the sysroot.
rm -f %{buildroot}%{gnuxc_root}/bin/{dumpsexp,hmac256}

# We don't need libtool's help.
rm -f %{buildroot}%{gnuxc_libdir}/libgcrypt.la

# This functionality should be used from the system package.
rm -rf %{buildroot}%{gnuxc_datadir}/aclocal

# Skip the documentation.
rm -rf %{buildroot}%{gnuxc_infodir}


%files
%{gnuxc_libdir}/libgcrypt.so.11
%{gnuxc_libdir}/libgcrypt.so.11.8.2
%doc AUTHORS ChangeLog* COPYING* NEWS README* THANKS TODO

%files devel
%{_bindir}/%{gnuxc_target}-libgcrypt-config
%{gnuxc_root}/bin/libgcrypt-config
%{gnuxc_includedir}/gcrypt.h
%{gnuxc_includedir}/gcrypt-module.h
%{gnuxc_libdir}/libgcrypt.so

%files static
%{gnuxc_libdir}/libgcrypt.a


%changelog