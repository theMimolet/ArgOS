#!/bin/bash

# Install Linux Surface userspace support packages from the upstream Surface repo.
# https://pkg.surfacelinux.com/fedora/

set -ouex pipefail

# Keep temp files on container rootfs so kernel/dracut scriptlets avoid
# cross-device hardlink failures during image build.
export TMPDIR=/var/tmp

echo "::group:: === Installing Surface Packages ==="

dnf5 config-manager addrepo --from-repofile=https://pkg.surfacelinux.com/fedora/linux-surface.repo

# Replace base kernel with surface kernel in single solver transaction.
dnf5 -y swap --allowerasing kernel kernel-surface

# Bluefin base can still keep stock kernel-core/modules installed.
# Remove stock kernel package set so only surface modules remain for bootc lint.
dnf5 -y remove kernel-core kernel-modules kernel-modules-core kernel-modules-extra || true

dnf5 -y install --allowerasing iptsd libwacom-surface libwacom-surface-utils surface-control

echo "::endgroup::"

find /etc/yum.repos.d/ -maxdepth 1 -type f -name '*.repo' ! -name 'fedora.repo' ! -name 'fedora-updates.repo' ! -name 'fedora-updates-testing.repo' -exec rm -f {} +
rm -rf /tmp/* || true
dnf5 clean all
