%?gnuxc_package_header

Name:           gnuxc-acl
Version:        2.2.52
Release:        1%{?dist}
Summary:        Cross-compiled version of %{gnuxc_name} for the GNU system

License:        LGPLv2+
URL:            http://savannah.nongnu.org/projects/acl
Source0:        http://download.savannah.gnu.org/releases/acl/%{gnuxc_name}-%{version}.src.tar.gz

BuildRequires:  gnuxc-attr-devel

BuildRequires:  gettext

%description
%{summary}.

%package devel
Summary:        Development files for %{name}
Requires:       %{name} = %{version}-%{release}
Requires:       gnuxc-glibc-devel

%description devel
The %{name}-devel package contains libraries and header files for developing
applications that use %{gnuxc_name} on GNU systems.

%package static
Summary:        Static libraries of %{name}
Requires:       %{name}-devel = %{version}-%{release}

%description static
The %{name}-static package contains the %{gnuxc_name} static libraries for
-static linking on GNU systems.  You don't need these, unless you link
statically, which is highly discouraged.


%prep
%autosetup -n %{gnuxc_name}-%{version}

%build
%gnuxc_configure \
    PLATFORM=gnu
%gnuxc_make_build \
    CPPFLAGS=-DPATH_MAX=4096

%install
%gnuxc_make_install install-lib install-dev \
    PKG_DEVLIB_DIR='$(PKG_LIB_DIR)'

# There is no need to install binary programs in the sysroot.
rm -f %{buildroot}%{gnuxc_bindir}/{chacl,getfacl,setfacl}

# We don't need libtool's help.
rm -f %{buildroot}%{gnuxc_libdir}/libacl.la

# Some libraries lack executable bits, befuddling the RPM scripts.
chmod -c 0755 %{buildroot}%{gnuxc_libdir}/libacl.so.1.1.0

# Skip the documentation.
rm -rf %{buildroot}%{gnuxc_docdir} %{buildroot}%{gnuxc_mandir}

rm -f %{buildroot}%{gnuxc_datadir}/locale/??/LC_MESSAGES/acl.mo


%files
%{gnuxc_libdir}/libacl.so.1
%{gnuxc_libdir}/libacl.so.1.1.0
%doc doc/*.txt doc/CHANGES doc/PORTING doc/TODO README
%license doc/COPYING doc/COPYING.LGPL

%files devel
%{gnuxc_includedir}/acl
%{gnuxc_includedir}/sys/acl.h
%{gnuxc_libdir}/libacl.so

%files static
%{gnuxc_libdir}/libacl.a
