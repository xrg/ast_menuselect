%define git_repo menuselect
%define git_head xrg

%define name ast_menuselect
%define version %{git_get_ver}
%define release 0%{git_get_rel}

Summary:	Asterisk Menuselect build tool
Name:		%{name}
Version:	%{version}
Release:	%{release}
License:	GPL
Group:		System/Tools
URL:		http://www.asterisk.org/
Source0:	%{name}-%{version}.tar.gz
BuildRequires:	newt-devel
BuildRoot:	%{_tmppath}/%{name}-%{version}-root


%description
Menuselect is a tool designed to be used in conjunction with GNU make. It
allows for an XML specification of Makefile variables and optional space
delimited values of these variables. These values can then be used in the
Makefile to make various decisions during the build process.

This tool is essential for Asterisk build and other projects based
on asterisk's codebase.

%prep
%git_get_source
%setup -q


%build
./bootstrap.sh
%configure
%make

%install
install -d %{buildroot}/%{_bindir}
install menuselect %{buildroot}/%{_bindir}/ast_menuselect

%clean
[ "%{buildroot}" != "/" ] && rm -rf %{buildroot}

%files
%defattr(-,root,root)
%doc README
%attr(0755,root,root)		%{_bindir}/*
