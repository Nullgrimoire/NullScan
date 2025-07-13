# Security Policy

## Supported Versions

We actively support the following versions of NullScan with security updates:

| Version | Supported          |
| ------- | ------------------ |
| 1.0.x   | :white_check_mark: |
| < 1.0   | :x:                |

## Reporting a Vulnerability

We take security seriously. If you discover a security vulnerability in NullScan, please report it responsibly.

### How to Report

**Please do NOT create a public GitHub issue for security vulnerabilities.**

Instead, please email us at: **security@nullscan.dev**

Include the following information:
- Description of the vulnerability
- Steps to reproduce the issue
- Potential impact
- Any suggested fixes (if available)

### What to Expect

- **Acknowledgment**: We'll acknowledge receipt within 48 hours
- **Assessment**: We'll assess the vulnerability within 5 business days
- **Timeline**: We'll provide a timeline for fixes within 1 week
- **Credit**: We'll credit you in our security advisories (if desired)

### Security Best Practices for Users

When using NullScan:

1. **Permission**: Only scan systems you own or have explicit permission to test
2. **Rate Limiting**: Use appropriate concurrency settings to avoid overwhelming targets
3. **Network Isolation**: Run scans from isolated environments when possible
4. **Log Security**: Secure scan results that may contain sensitive information
5. **Updates**: Keep NullScan updated to the latest version

### Common Security Considerations

- NullScan performs network scanning which may be detected by security systems
- Banner grabbing may expose service information
- High concurrency scans may trigger rate limiting or blocking
- Always comply with local laws and regulations

Thank you for helping keep NullScan secure! 🔒
